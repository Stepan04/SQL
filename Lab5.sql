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
---- ��������� ����������� ���� ����� ���'������� � ������
--CREATE USER HRManagerUser FOR LOGIN HRManager;

---- ������� ������� �� ��������� ������ SELECT, INSERT, UPDATE, DELETE � �������� Employee �� Structural_unit
--GRANT SELECT, INSERT, UPDATE, DELETE ON Employee TO HRManagerUser;
--GRANT SELECT, INSERT, UPDATE, DELETE ON Structural_unit TO HRManagerUser;

---- ��������� ����������� ���� ����� ���'������� � ������
--CREATE USER FinancialAnalystUser FOR LOGIN FinancialAnalyst;

---- ������� ������� �� ��������� ������ SELECT � ������� Salary �� Vacation
--GRANT SELECT ON Salary TO FinancialAnalystUser;
--GRANT SELECT ON Vacation TO FinancialAnalystUser;

------ ������������ ��������� �� ����������� ������� �����, �� ������ ���� �������� � ������� Salary
----ALTER USER FinancialAnalystUser WITH ROW_LIMIT 100;

---- ��������� ����������� ���� ����� ���'������� � ������
--CREATE USER DepartmentManagerUser FOR LOGIN DepartmentManager;

---- ������� ������� �� ��������� ������ SELECT, UPDATE � ������� Employee
--GRANT SELECT, UPDATE ON Employee TO DepartmentManagerUser;

---- ������������ ��������� �� ��������� UPDATE ������, ��� �������� ����� ���� position
--REVOKE UPDATE ON Employee([name], surname, date_of_birth, passport_data, place_of_birth, home_address, structural_unit) FROM DepartmentManagerUser;

---- ��������� ����������� ���� ����� ���'������� � ������
--CREATE USER SystemAdministratorUser FOR LOGIN SystemAdministrator;

---- ������� ������� �� ��������� ����-���� ������ � ��� ��������
--GRANT ALL PRIVILEGES TO SystemAdministratorUser;


----3-4
----��������� ��� "HRManagerRole":
--CREATE ROLE HRManagerRole;
--GRANT SELECT, INSERT, UPDATE, DELETE ON Employee TO HRManagerRole;
--GRANT SELECT, INSERT, UPDATE, DELETE ON Structural_unit TO HRManagerRole;

----��������� ��� "FinancialAnalystRole":
--CREATE ROLE FinancialAnalystRole;
--GRANT SELECT ON Salary TO FinancialAnalystRole;
--GRANT SELECT ON Vacation TO FinancialAnalystRole;

----5
---- ����������� ��� "HRManagerRole" ����������� "HRManagerUser"
--ALTER USER HRManagerUser WITH DEFAULT_SCHEMA = dbo;
--ALTER ROLE HRManagerRole ADD MEMBER HRManagerUser;

---- ����������� ��� "FinancialAnalystRole" ����������� "FinancialAnalystUser"
--ALTER USER FinancialAnalystUser WITH DEFAULT_SCHEMA = dbo;
--ALTER ROLE FinancialAnalystRole ADD MEMBER FinancialAnalystUser;

------------------------------------------------
----6
---- ³��������� �������, ����������� ����� ���� "HRManagerRole" � ����������� "HRManagerUser"
--REVOKE SELECT, INSERT, UPDATE, DELETE ON Employee FROM HRManagerUser;
--REVOKE SELECT, INSERT, UPDATE, DELETE ON Position FROM HRManagerUser;

---- ³��������� �������, ����������� ����� ���� "FinancialAnalystRole" � ����������� "FinancialAnalystUser"
--REVOKE SELECT, UPDATE ON Salary FROM FinancialAnalystUser;
--REVOKE SELECT, UPDATE ON Structural_unit FROM FinancialAnalystUser;

---------------------------------------------------
----7
---- ³��������� ��� "HRManagerRole" � ����������� "HRManagerUser"
--REVOKE HRManagerRole FROM HRManagerUser;

---- ³��������� ��� "FinancialAnalystRole" � ����������� "FinancialAnalystUser"
--REVOKE FinancialAnalystRole FROM FinancialAnalystUser;

-------------------------------------------------
--8
-- ��������� ��� "HRManagerRole"
DROP ROLE HRManagerRole;

-- ��������� ��� "FinancialAnalystRole"
DROP ROLE FinancialAnalystRole;

--------------------------------------
-- ��������� ����������� "HRManagerUser"
DROP USER HRManagerUser;

-- ��������� ����������� "FinancialAnalystUser"
DROP USER FinancialAnalystUser;
