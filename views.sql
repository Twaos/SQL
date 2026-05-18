-- VIEW ei salvesta andmeid vaikimisi
-- See on salvestatud virtuaalne tabel

    -- Virtual table based on the result set of an SQL statement.
    -- The fields are from one or more real tables in the DB.
    -- They are not real tables, but can be interacted with as if they were.

--Milleks vaja:
-- Saab kasutada andmebaasi skeemi keesukuse lihtsustamiseks, mitte IT-inimesele piiratud ligipääs andmetele.

CREATE TABLE Employees (
    Id INT PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Gender NVARCHAR(10),
    Salary INT,
    City NVARCHAR(50),
    DepartmentName NVARCHAR(50)
);

INSERT INTO Employees (Id, FirstName, LastName, Gender, Salary, City, DepartmentName)
VALUES
    (1, 'Jüri', 'Tamm', 'Mees', 2500, 'Tallinn', 'IT'),
    (2, 'Mari', 'Kask', 'Naine', 2800, 'Tartu', 'IT'),
    (3, 'Kalle', 'Kuusk', 'Mees', 2100, 'Pärnu', 'Sales'),
    (4, 'Tiina', 'Mänd', 'Naine', 3200, 'Tallinn', 'IT'),
    (5, 'Peeter', 'Oja', 'Mees', 1900, 'Narva', 'Logistics'),
    (6, 'Liis', 'Lepik', 'Naine', 2400, 'Viljandi', 'Sales'),
    (7, 'Andres', 'Salu', 'Mees', 2700, 'Tallinn', 'IT'),
    (8, 'Kadri', 'Kivi', 'Naine', 2300, 'Haapsalu', 'HR'),
    (9, 'Marten', 'Sepp', 'Mees', 3500, 'Tartu', 'HR'),
    (10, 'Eva', 'Karu', 'Naine', 2000, 'Kuressaare', 'Klienditugi');


SELECT * FROM Employees;

-- View, kus näeb ainlt IT-töötajaid
create view vITEmployeesInDepartment as
    select Id, LastName, City, DepartmentName
    from Employees
    where DepartmentName = 'IT';

select * from vITEmployeesInDepartment;

-- Veeru taseme turvalisus

create view vEmployeesCountByDepartment as
select DepartmentName, count(Employees.Id) as TotalEmployees
from Employees
group by DepartmentName

select  * from vEmployeesCountByDepartment;

-- View query sisu vaatamiseks: sp_helptext
sp_helptext vEmployeesCountByDepartment;

-- Muutmiseks kasutatakse võtmesõna alter:
-- alter view vEmployeesCountByDepartment...;

-- Kustutamine:
drop view vEmployeesCountByDepartment;

create view vEmployeesDataExceptSalary as
    select Id, FirstName, LastName, Gender, City, DepartmentName
from Employees;

-- Muuda id 2 rida: Eesnimi Tom
update vEmployeesDataExceptSalary
set FirstName = 'Pam'
where Id = 2;


select * from vEmployeesDataExceptSalary;

delete from vEmployeesDataExceptSalary where Id = 2;

insert into vEmployeesDataExceptSalary (Id, Gender, DepartmentName, FirstName)
values (2, 'Female', 'IT', 'Pam');