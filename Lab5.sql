----1
--CREATE LOGIN HRManager
--WITH PASSWORD = 'StrongPassword123';

--CREATE LOGIN FinancialAnalyst
--WITH PASSWORD = 'SecurePassword456';

--CREATE LOGIN DepartmentManager
--WITH PASSWORD = 'Password789';

--CREATE LOGIN SystemAdministrator
--WITH PASSWORD = 'AdminPassword123';

----2
---- Створення користувача бази даних пов'язаного з логіном
--CREATE USER HRManagerUser FOR LOGIN HRManager;

---- Надання дозволів на виконання запитів SELECT, INSERT, UPDATE, DELETE в таблицях Employee та Structural_unit
--GRANT SELECT, INSERT, UPDATE, DELETE ON Employee TO HRManagerUser;
--GRANT SELECT, INSERT, UPDATE, DELETE ON Structural_unit TO HRManagerUser;

---- Створення користувача бази даних пов'язаного з логіном
--CREATE USER FinancialAnalystUser FOR LOGIN FinancialAnalyst;

---- Надання дозволу на виконання запитів SELECT в таблиці Salary та Vacation
--GRANT SELECT ON Salary TO FinancialAnalystUser;
--GRANT SELECT ON Vacation TO FinancialAnalystUser;

------ Встановлення обмеження на максимальну кількість рядків, які можуть бути повернуті з таблиці Salary
----ALTER USER FinancialAnalystUser WITH ROW_LIMIT 100;

---- Створення користувача бази даних пов'язаного з логіном
--CREATE USER DepartmentManagerUser FOR LOGIN DepartmentManager;

---- Надання дозволів на виконання запитів SELECT, UPDATE в таблиці Employee
--GRANT SELECT, UPDATE ON Employee TO DepartmentManagerUser;

---- Встановлення обмеження на виконання UPDATE запитів, щоб змінювати тільки поле position
--REVOKE UPDATE ON Employee([name], surname, date_of_birth, passport_data, place_of_birth, home_address, structural_unit) FROM DepartmentManagerUser;

---- Створення користувача бази даних пов'язаного з логіном
--CREATE USER SystemAdministratorUser FOR LOGIN SystemAdministrator;

---- Надання дозволів на виконання будь-яких запитів в усіх таблицях
--GRANT ALL PRIVILEGES TO SystemAdministratorUser;


----3-4
----Створення ролі "HRManagerRole":
--CREATE ROLE HRManagerRole;
--GRANT SELECT, INSERT, UPDATE, DELETE ON Employee TO HRManagerRole;
--GRANT SELECT, INSERT, UPDATE, DELETE ON Structural_unit TO HRManagerRole;

----Створення ролі "FinancialAnalystRole":
--CREATE ROLE FinancialAnalystRole;
--GRANT SELECT ON Salary TO FinancialAnalystRole;
--GRANT SELECT ON Vacation TO FinancialAnalystRole;

----5
---- Призначення ролі "HRManagerRole" користувачу "HRManagerUser"
--ALTER USER HRManagerUser WITH DEFAULT_SCHEMA = dbo;
--ALTER ROLE HRManagerRole ADD MEMBER HRManagerUser;

---- Призначення ролі "FinancialAnalystRole" користувачу "FinancialAnalystUser"
--ALTER USER FinancialAnalystUser WITH DEFAULT_SCHEMA = dbo;
--ALTER ROLE FinancialAnalystRole ADD MEMBER FinancialAnalystUser;

------------------------------------------------
----6
---- Відкликання привілеїв, призначених через роль "HRManagerRole" у користувача "HRManagerUser"
--REVOKE SELECT, INSERT, UPDATE, DELETE ON Employee FROM HRManagerUser;
--REVOKE SELECT, INSERT, UPDATE, DELETE ON Position FROM HRManagerUser;

---- Відкликання привілеїв, призначених через роль "FinancialAnalystRole" у користувача "FinancialAnalystUser"
--REVOKE SELECT, UPDATE ON Salary FROM FinancialAnalystUser;
--REVOKE SELECT, UPDATE ON Structural_unit FROM FinancialAnalystUser;

---------------------------------------------------
----7
---- Відкликання ролі "HRManagerRole" у користувача "HRManagerUser"
--REVOKE HRManagerRole FROM HRManagerUser;

---- Відкликання ролі "FinancialAnalystRole" у користувача "FinancialAnalystUser"
--REVOKE FinancialAnalystRole FROM FinancialAnalystUser;

-------------------------------------------------
--8
-- Видалення ролі "HRManagerRole"
DROP ROLE HRManagerRole;

-- Видалення ролі "FinancialAnalystRole"
DROP ROLE FinancialAnalystRole;

--------------------------------------
-- Видалення користувача "HRManagerUser"
DROP USER HRManagerUser;

-- Видалення користувача "FinancialAnalystUser"
DROP USER FinancialAnalystUser;
