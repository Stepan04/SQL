CREATE TABLE Employee (
  id INT PRIMARY KEY NOT NULL,
  roll_number INT NOT NULL,
  surname VARCHAR(255) NOT NULL,
  [name] VARCHAR(255) NOT NULL,
  date_of_birth DATE NOT NULL,
  passport_data VARCHAR(255) NOT NULL,
  place_of_birth VARCHAR(255) NOT NULL,
  home_address VARCHAR(255) NOT NULL,
  structural_unit VARCHAR(255) NOT NULL,
  position VARCHAR(255) NOT NULL
);
CREATE TABLE Position (
  id INT PRIMARY KEY NOT NULL,
  [name] VARCHAR(255) NOT NULL,
  hourly_rate DECIMAL(10, 2) NOT NULL,
  structure_unit_id INT NOT NULL,
  is_chief BOOLEAN NOT NULL DEFAULT FALSE,
  FOREIGN KEY (structure_unit_id) REFERENCES Employee(id)
);
CREATE TABLE Salary (
  id INT PRIMARY KEY NOT NULL,
  employee INT NOT NULL,
  [month] DATE NOT NULL,
  socia_tax DECIMAL(10,2) NOT NULL,
  basic_salary DECIMAL(10,2) NOT NULL,
  additional_salary DECIMAL(10,2) NOT NULL,
  vacation DECIMAL(10,2) NOT NULL,
  accrued_salary DECIMAL(10,2) NOT NULL
);
CREATE TABLE Structural_unit (
  id INT PRIMARY KEY NOT NULL,
  code VARCHAR(10) NOT NULL,
  name_of_unit VARCHAR(100) NOT NULL
);
CREATE TABLE Vacation (
  id INT PRIMARY KEY NOT NULL,
  employee INT NOT NULL,
  start_vacation DATE NOT NULL,
  duration INT NOT NULL
);
CREATE TABLE Vacation_days (
  id INT PRIMARY KEY NOT NULL,
  day INT NOT NULL,
  month INT NOT NULL,
  year INT NOT NULL
);
CREATE TABLE Working_hours (
  id INT PRIMARY KEY NOT NULL,
  employee INT NOT NULL,
  number_of_hours INT NOT NULL,
  date DATE NOT NULL
);

USE [Оплата_праці]

GO

INSERT INTO [dbo].[Employee]
           ([id]
           ,[roll_number]
           ,[surname]
           ,[name]
           ,[date_of_birth]
           ,[passport_data]
           ,[place_of_birth]
           ,[home_address]
           ,[structural_unit]
           ,[position])
     VALUES
           (3
           ,22
           ,'petro'
           ,'pavlo'
           ,'1980-01-01'
           ,'ukraine'
           ,'vinograd'
           ,'holovna6'
           ,'mvs'
           ,'shuler')
GO


--Лабораторна 2
--1 запит
SELECT * FROM Employee
WHERE passport_data='ukraine' AND name = 'Тарас' OR name = 'Григоріц' 
ORDER BY name ASC;

SELECT id, name
FROM Employee
WHERE position = '1' OR position = '2'
AND date_of_birth >= '1990-01-01'
ORDER BY [name] DESC;
 
 --2 запит
 select AVG(basic_salary) AS avg_salary From Salary;--1

 SELECT id, [name], YEAR('2023') - YEAR(date_of_birth) AS age --2
FROM Employee
WHERE surname = 'Франко';

--3 запит
SELECT e.id, e.[name], p.[name] AS position
FROM Employee e
JOIN Position p ON e.position = p.id
JOIN Structural_unit s ON p.structure_unit_id = s.id
WHERE (s.code = '1' OR s.code = '2') AND p.is_chief = 0
ORDER BY e.[name] ASC;

--4 запит
SELECT e.id, e.surname, p.name as position_name
FROM Employee e
LEFT OUTER JOIN Position p ON e.position = p.id;

--5 
SELECT * FROM Employee WHERE surname LIKE 'Фр%';

SELECT * FROM Salary WHERE socia_tax BETWEEN 1000 AND 2000;

SELECT * FROM Employee WHERE id IN (SELECT employee FROM Vacation);

SELECT * FROM Position WHERE hourly_rate > ALL (SELECT hourly_rate FROM Position WHERE is_chief = 0);

SELECT * FROM Position WHERE hourly_rate < ANY (SELECT hourly_rate FROM Position WHERE is_chief = 1);

--6
SELECT AVG(hourly_rate) AS avg_hourly_rate, structure_unit_id
FROM Position
GROUP BY structure_unit_id;

SELECT SUM(basic_salary + additional_salary) AS total_salary, employee
FROM Salary
WHERE month BETWEEN '2022-01-01' AND '2022-12-31'
GROUP BY employee;

--7
SELECT *
FROM Employee
WHERE structural_unit IN (
  SELECT code
  FROM Structural_unit
  WHERE code = '1')

--8--------
SELECT e.id, e.surname, e.[name], s.accrued_salary
FROM (
  SELECT id, [month], accrued_salary
  FROM Salary
  WHERE [month] BETWEEN '2022-01-01' AND '2022-12-31'
) s
JOIN Employee e ON s.employee = e.id
WHERE e.position = 'Грузчик'

--9 ---------------
WITH RECURSIVE EmployeeHierarchy AS (
  SELECT id, [name], surname, position, NULL AS manager_id, 0 AS depth
  FROM Employee
  WHERE position = 'CEO'
  
  UNION ALL
  
  SELECT e.id, e.[name], e.surname, e.position, eh.id AS manager_id, eh.depth + 1 AS depth
  FROM Employee e
  JOIN EmployeeHierarchy eh ON e.id = eh.manager_id
)
SELECT id, [name], surname, position, depth
FROM EmployeeHierarchy
ORDER BY depth ASC
--10--------
SELECT *
FROM
(
  SELECT employee, month, basic_salary
  FROM Salary
) AS SalaryTable
PIVOT
(
  SUM(basic_salary)
  FOR month IN ([January], [February], [March], [April], [May], [June], [July], [August], [September], [October], [November], [December])
) AS PivotTable;

--11
UPDATE Employee
SET home_address = '123 Main St.'
WHERE id = 1;

--12
UPDATE Salary
SET basic_salary = basic_salary * 1.05
FROM Salary s
INNER JOIN Employee e ON s.employee = e.id
INNER JOIN Position p ON e.position = p.name
WHERE p.is_chief = 1;

--13
INSERT INTO Employee (id, roll_number, surname, [name], date_of_birth, passport_data, place_of_birth, home_address, structural_unit, position)
VALUES (5, 1001, 'Smith', 'John', '1990-01-01', '123456789', 'New York', '123 Main St', '1', '1');

INSERT INTO Structural_unit (id, code, name_of_unit)
VALUES (5, 100, 'Грузчик');

--14
DELETE FROM Working_hours;

--15
DELETE FROM Employee
WHERE id = 1;

----------------------------------------------------------------------------
--Задання процедури

CREATE PROCEDURE CalculateSalary
  @employeeId INT,
  @month DATE
AS
BEGIN
  DECLARE @basicSalary DECIMAL(10,2)
  DECLARE @additionalSalary DECIMAL(10,2)
  DECLARE @vacation INT
  DECLARE @vacationPayment DECIMAL(10,2)

  -- Отримуємо базову зарплату для позиції працівника
  SELECT @basicSalary = p.hourly_rate * SUM(h.number_of_hours) 
  FROM Position p
  INNER JOIN Employee e ON p.id = e.position
  INNER JOIN Working_hours h ON e.id = h.employee
  WHERE e.id = @employeeId AND @month = DATEFROMPARTS(YEAR(h.date), MONTH(h.date), 1)
  GROUP BY p.hourly_rate

  -- Отримуємо додаткову зарплату для працівника
  SELECT @additionalSalary = SUM(s.additional_salary)
  FROM Salary s
  WHERE s.employee = @employeeId AND @month = DATEFROMPARTS(YEAR(s.month), MONTH(s.month), 1)

  -- Отримуємо відпусткові дні для працівника
  SELECT @vacation = v.duration
  FROM Vacation v
  WHERE v.employee = @employeeId AND @month BETWEEN v.start_vacation AND DATEADD(DAY, v.duration-1, v.start_vacation)

  -- Розраховуємо оплату за відпустку
  
  SET @vacationPayment = IIF(@vacation !=0, @basicSalary / (30 * @vacation),0)

  -- Додаємо нарахування соціального податку та відповідні зарплатні виплати
  INSERT INTO SSalary (employee, month, social_tax, basic_salary, additional_salary, vacation, accrued_salary)
  VALUES (@employeeId, @month, 1232, @basicSalary, @additionalSalary, @vacationPayment, @basicSalary + @additionalSalary + @vacationPayment - 1232)
END

CREATE PROCEDURE CalculateSalaryForAllEmployees
  @month DATE
AS
BEGIN
  DECLARE @employeeId INT
  DECLARE employee_cursor CURSOR FOR
    SELECT id FROM Employee
  OPEN employee_cursor
  FETCH NEXT FROM employee_cursor INTO @employeeId
  WHILE @@FETCH_STATUS = 0
  BEGIN
    EXEC CalculateSalary @employeeId, @month
    FETCH NEXT FROM employee_cursor INTO @employeeId
  END
  CLOSE employee_cursor
  DEALLOCATE employee_cursor



----------------------------------------
--Тригери
----------------------------------------
--1 тригер про заповнення та створення полів додаткових
ALTER TABLE Employee ADD UCR VARCHAR(255);
ALTER TABLE Employee ADD DCR DATETIME;
ALTER TABLE Employee ADD ULC VARCHAR(255);
ALTER TABLE Employee ADD DLC DATETIME;
CREATE TRIGGER trg_employee_insert
ON Employee
FOR INSERT
AS
BEGIN
    UPDATE Employee SET UCR = SUSER_SNAME(), DCR = GETDATE(), ULC = SUSER_SNAME(), DLC = GETDATE()
    FROM inserted WHERE Employee.id = inserted.id;
END;
CREATE TRIGGER trg_employee_update
ON Employee
FOR UPDATE
AS
BEGIN
    UPDATE Employee SET ULC = SUSER_SNAME(), DLC = GETDATE()
    FROM inserted WHERE Employee.id = inserted.id;
END;

ALTER TABLE Position ADD UCR VARCHAR(255);
ALTER TABLE Position ADD DCR DATETIME;
ALTER TABLE Position ADD ULC VARCHAR(255);
ALTER TABLE Position ADD DLC DATETIME;
CREATE TRIGGER trg_position_insert
ON Position
FOR INSERT
AS
BEGIN
    UPDATE Position SET UCR = SUSER_SNAME(), DCR = GETDATE(), ULC = SUSER_SNAME(), DLC = GETDATE()
    FROM inserted WHERE Position.id = inserted.id;
END;
CREATE TRIGGER trg_position_update
ON Position
FOR UPDATE
AS
BEGIN
    UPDATE Position SET ULC = SUSER_SNAME(), DLC = GETDATE()
    FROM inserted WHERE Position.id = inserted.id;
END;

ALTER TABLE SSalary ADD UCR VARCHAR(255);
ALTER TABLE SSalary ADD DCR DATETIME;
ALTER TABLE SSalary ADD ULC VARCHAR(255);
ALTER TABLE SSalary ADD DLC DATETIME;
CREATE TRIGGER trg_ssalary_insert
ON SSalary
FOR INSERT
AS
BEGIN
    UPDATE SSalary SET UCR = SUSER_SNAME(), DCR = GETDATE(), ULC = SUSER_SNAME(), DLC = GETDATE()
    FROM inserted WHERE SSalary.id = inserted.id;
END;
CREATE TRIGGER trg_ssalary_update
ON SSalary
FOR UPDATE
AS
BEGIN
    UPDATE SSalary SET ULC = SUSER_SNAME(), DLC = GETDATE()
    FROM inserted WHERE SSalary.id = inserted.id;
END;

ALTER TABLE Structural_unit ADD UCR VARCHAR(255);
ALTER TABLE Structural_unit ADD DCR DATETIME;
ALTER TABLE Structural_unit ADD ULC VARCHAR(255);
ALTER TABLE Structural_unit ADD DLC DATETIME;
CREATE TRIGGER trg_structural_unit_insert
ON Structural_unit
FOR INSERT
AS
BEGIN
    UPDATE Structural_unit SET UCR = SUSER_SNAME(), DCR = GETDATE(), ULC = SUSER_SNAME(), DLC = GETDATE()
    FROM inserted WHERE Structural_unit.id = inserted.id;
END;
CREATE TRIGGER trg_structural_unit_update
ON Structural_unit
FOR UPDATE
AS
BEGIN
    UPDATE Structural_unit SET ULC = SUSER_SNAME(), DLC = GETDATE()
    FROM inserted WHERE Structural_unit.id = inserted.id;
END;

ALTER TABLE Vacation ADD UCR VARCHAR(255);
ALTER TABLE Vacation ADD DCR DATETIME;
ALTER TABLE Vacation ADD ULC VARCHAR(255);
ALTER TABLE Vacation ADD DLC DATETIME;
CREATE TRIGGER trg_vacation_insert
ON Vacation
FOR INSERT
AS
BEGIN
    UPDATE Vacation SET UCR = SUSER_SNAME(), DCR = GETDATE(), ULC = SUSER_SNAME(), DLC = GETDATE()
    FROM inserted WHERE Vacation.id = inserted.id;
END;
CREATE TRIGGER trg_vacation_update
ON Vacation
FOR UPDATE
AS
BEGIN
    UPDATE Vacation SET ULC = SUSER_SNAME(), DLC = GETDATE()
    FROM inserted WHERE Vacation.id = inserted.id;
	END;

ALTER TABLE Vacation_days ADD UCR VARCHAR(255);
ALTER TABLE Vacation_days ADD DCR DATETIME;
ALTER TABLE Vacation_days ADD ULC VARCHAR(255);
ALTER TABLE Vacation_days ADD DLC DATETIME;
CREATE TRIGGER trg_vacation_days_insert
ON Vacation_days
FOR INSERT
AS
BEGIN
    UPDATE Vacation_days SET UCR = SUSER_SNAME(), DCR = GETDATE(), ULC = SUSER_SNAME(), DLC = GETDATE()
    FROM inserted WHERE Vacation_days.id = inserted.id;
END;
CREATE TRIGGER trg_vacation_days_update
ON Vacation_days
FOR UPDATE
AS
BEGIN
    UPDATE Vacation_days SET ULC = SUSER_SNAME(), DLC = GETDATE()
    FROM inserted WHERE Vacation_days.id = inserted.id;
	END;

ALTER TABLE Working_hours ADD UCR VARCHAR(255);
ALTER TABLE Working_hours ADD DCR DATETIME;
ALTER TABLE Working_hours ADD ULC VARCHAR(255);
ALTER TABLE Working_hours ADD DLC DATETIME;
CREATE TRIGGER trg_working_hours_insert
ON Working_hours
FOR INSERT
AS
BEGIN
    UPDATE Working_hours SET UCR = SUSER_SNAME(), DCR = GETDATE(), ULC = SUSER_SNAME(), DLC = GETDATE()
    FROM inserted WHERE Working_hours.id = inserted.id;
END;
CREATE TRIGGER trg_working_hours_days_update
ON Working_hours
FOR UPDATE
AS
BEGIN
    UPDATE Working_hours SET ULC = SUSER_SNAME(), DLC = GETDATE()
    FROM inserted WHERE Working_hours.id = inserted.id;
	END;


  --2 тригер для сурогатного ключа
  ALTER TABLE Employee ADD  emp_id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,;
CREATE TRIGGER tr_Employee_emp_id
ON Employee
INSTEAD OF INSERT
AS
BEGIN
  SET NOCOUNT ON;
  
  INSERT INTO Employee (emp_id, roll_number, surname, [name], date_of_birth, passport_data, place_of_birth, home_address, structural_unit, position)
  SELECT ROW_NUMBER() OVER (ORDER BY roll_number), roll_number, surname, [name], date_of_birth, passport_data, place_of_birth, home_address, structural_unit, position
  FROM inserted;
END;
---3 тригер для мінімальної зарплати та вивід з помилкою
CREATE TRIGGER trg_salary_min_salary
ON Ssalary
INSTEAD OF INSERT
AS
BEGIN
    IF (SELECT basic_salary FROM inserted) < 5600
    BEGIN
        RAISERROR ('Employee basic salary cannot be less than the minimum salary for their position', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;

EXEC CalculateSalary @employeeId = 1,   @month = '2023.01.01';
select* from Ssalary;

--4 тригер для того що працівник не може працювати одночасно в декількох місцях
CREATE TRIGGER trg_employee_position_unique
ON Employee
FOR INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Position
        WHERE id IN (SELECT id FROM inserted)
    )
    BEGIN
        RAISERROR ('Employee already has a position in another department', 16, 1);
        ROLLBACK TRANSACTION; -- Скасовуємо вставку
        RETURN;
    END;
END;


--5 тригер для того що якщо працівника звільнили то не може нараховуватись зарплата
CREATE TRIGGER tr_employee_termination
ON Salary
AFTER INSERT, UPDATE
AS
BEGIN
  DECLARE @termination_date DATE;
  SELECT @termination_date = DATEADD(DAY, 1, date_of_termination) FROM Employee
  WHERE id = (SELECT employee FROM inserted);

  IF EXISTS(SELECT 1 FROM inserted WHERE [month] > @termination_date)
  BEGIN
    RAISERROR ('Employee cannot accrue salary after their termination date.', 16, 1);
    ROLLBACK TRANSACTION;
    RETURN;
  END;
END;

--6 тригер для того що зарплата нарахована пізніше буде з пиннею 0,1%
CREATE TRIGGER tr_salary_payment
ON Salary
INSTEAD OF INSERT
AS
BEGIN
  DECLARE @payment_date DATE;
  DECLARE @current_date DATE;
  DECLARE @days_late INT;
  
  SELECT @payment_date = DATEADD(MONTH, 1, DATEFROMPARTS(YEAR([month]), MONTH([month]), 1)) FROM INSERTED;
  SET @current_date = GETDATE();
  
  IF @payment_date < @current_date
  BEGIN
    SET @days_late = DATEDIFF(DAY, @payment_date, @current_date);
    
    UPDATE Salary
    SET accrued_salary = INSERTED.accrued_salary * (1 - (@days_late * 0.001))
    FROM INSERTED
    WHERE Salary.id = INSERTED.id;
  END;
  
  INSERT INTO Salary (id, employee, [month], socia_tax, basic_salary, additional_salary, vacation, accrued_salary)
  SELECT id, employee, [month], socia_tax, basic_salary, additional_salary, vacation, accrued_salary
  FROM INSERTED;
END;

