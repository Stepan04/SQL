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
