-- Triggerid
-- Tüübid: DML, DDL, LOGON

-- Trigger on stored procedure eriliik, mis käivitub automaatselt, kui andmebaasis toimub mingi tegevus.

-- DML - Data Manipulation Language
-- Põhikäsklused insert, update, delete
-- Saab jaotada:
-- 1. After Trigger - käivitub peale sündmust , kui kuskil on tehtud insert, update, delete
-- 2. Instead of Trigger

create table EmployeeAudit(
    Id int identity(1, 1) primary key,
    AuditData nvarchar(100)
);

CREATE TABLE Employees_ (
    Id INT PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Gender NVARCHAR(10),
    Salary INT,
    City NVARCHAR(50),
    DepartmentName NVARCHAR(50)
);

INSERT INTO Employees_ (Id, FirstName, LastName, Gender, Salary, City, DepartmentName)
VALUES
    (1, 'Jüri', 'Tamm', 'Mees', 2500, 'Tallinn', 'IT'),
    (2, 'Mari', 'Kask', 'Naine', 2800, 'Tartu', 'IT'),
    (3, 'Kalle', 'Kuusk', 'Mees', 2100, 'Pärnu', 'Sales'),
    (4, 'Tiina', 'Mänd', 'Naine', 3200, 'Tallinn', 'IT');

-- create trigger trEmployeeForInsert
--     on Employees_
--     for insert
--     as begin
--     declare @Id int
--     select @Id = Id from inserted
--         insert into EmployeeAudit
--         values ('New employee with Id = ' + cast(@Id as nvarchar)
--                + 'is added at ' + cast(getdate() as nvarchar) )
-- end;

select * from EmployeeAudit;