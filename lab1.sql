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
VALUES (1, 1001, 'Smith', 'John', '1990-01-01', '123456789', 'New York', '123 Main St', 'Sales', 'Manager');

INSERT INTO Structural_unit (id, code, name_of_unit)
VALUES (1, 100, 'Sales');

--14
DELETE FROM Working_hours;

--15
DELETE FROM Employee
WHERE id = 1;


