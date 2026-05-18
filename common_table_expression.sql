--- CTE e common table expression
 create table Employee (
     Id int primary key,
     FirstName nvarchar(30),
     LastName nvarchar(30),
     Gender nvarchar(10),
     DepartmentId int
 )

insert into Employee values(1, 'John', 'Bravo','Male', 3)
insert into Employee values(2, 'Mike', 'Mendez','Male', 2)
insert into Employee values(3, 'Pam', 'Graham','Female', 1)
insert into Employee values(4, 'Todd', 'Kod','Male', 4)
insert into Employee values(5, 'Sara','Lee','Female', 1)
insert into Employee values(6, 'Ben', 'Ten','Male', 3)

create table Department
(
Id int primary key,
DepartmentName nvarchar(20)
)

insert into Department values (1, 'IT'),
                                  (2, 'Finance'),
                                  (3, 'HR'),
                                  (4, 'Helpdesk');

with EmployeeCount(DepartmentName, DepartmentId, TotalEmployees)
as
    (
        select DepartmentName, DepartmentId, count(*) as TotalEmployees
        from Employee
        join Department
        on Employee.DepartmentId = Department.Id
        group by DepartmentName, DepartmentId
	)
select
    DepartmentName, TotalEmployees
    from EmployeeCount
    where TotalEmployees >= 2

-- CTE-d võiva sarnaneda temp. tabeliga
-- Need on sarnased päritud tabelile ja ei ole salvestatud objektina,
-- kestavad päringu ulatuses.
-- NÄIDE: võrdluseks sama väljend päritud tabelina
select DepartmentName, TotalEmployees
from
(
	select DepartmentName, DepartmentId, count(*) as TotalEmployees
	from Employee
	join Department
	on Employee.DepartmentId = Department.Id
	group by DepartmentName, DepartmentId
)
as EmployeeCount
where TotalEmployees >= 2

--- Mitu CTE-d järjest:
with EmployeeCountBy_Payroll_IT_Dept(DepartmentName, Total)
as
(
	select DepartmentName, count(Employee.Id) as TotalEmployees
	from Employee
	join Department
	on Employee.DepartmentId = Department.Id
	where DepartmentName in('Payroll', 'IT')
	group by DepartmentName
), -- (<- Peale koma panemist saab uue CTE juurde kirjutada)
EmployeeCountBy_HR_Admin_Dept(DepartmentName, Total)
as
(
	select DepartmentName, count(Employee.Id) as TotalEmployees
	from Employee
	join Department
	on Employee.DepartmentId = Department.Id
	group by DepartmentName
) -- (Kui on kaks CTE-d...)
select * from EmployeeCountBy_Payroll_IT_Dept
union -- (<- ...siis unioni abil ühendatakse päringud)
select * from EmployeeCountBy_HR_Admin_Dept

-- CTE-de kasutamise eesmärgid:
-- 1. Parem loetavus: CTE-d jagavad keerulised päringud väiksemateks loogilisteks osadeks.
    -- Selle asemel, et kasutada sügavalt pesastatud alampäringuid, defineerid sa sammud WITH-klausli abil tehtava
    -- päringu alguses.

-- 2. Koodi taaskasutatavus: Saad defineerida CTE üks kord ja viidata sellele sama päringu piires korduvalt.
    -- See hoiab koodi puhtana.

-- 3. Rekursiivsus: See on CTE-de eriline omadus. Rekursiivne CTE saab viidata iseendale, mis on hädavajalik
    -- hierarhiliste andmete töötlemiseks.

--- 4. Lihtsam testimine: Kuna iga osa on eraldi nimega plokk, on konkreetseid loogika osi liht sam kontrollida ja
    -- veatuvastust teha.