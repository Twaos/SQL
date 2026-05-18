DROP TABLE IF EXISTS Employees;
CREATE TABLE Employees (
    Id INT PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Gender NVARCHAR(10),
    Salary INT,
    City NVARCHAR(50),
    DepartmentId int,
    Email nvarchar(30),
    ManagerId int
);

INSERT INTO Employees (Id, FirstName, LastName, Gender, Salary, City, DepartmentId, Email, ManagerId)
VALUES
    (1, 'Jüri', 'Tamm', 'Mees', 2500, 'Tallinn',1,
    'hello@world.com', 3)


SELECT * FROM Employees;

drop table if exists EmployeeAudit;
create table EmployeeAudit
(
Id int identity(1,1) primary key,
AuditData nvarchar(1000)
)

drop trigger if exists trEmployeeForInsert;

create trigger trEmployeeForInsert
on Employees
for insert
as begin
declare @Id int
select @Id = Id from inserted
insert into EmployeeAudit
values ('New employee with Id = ' + cast(@Id as nvarchar(5)) + ' is added at ' +
cast(getdate() as nvarchar(20)))
end

drop trigger if exists trEmployeeForUpdate;

create trigger trEmployeeForUpdate
on Employees
for update
as begin
    -- Muutujate deklareerimine
    declare @Id int
    declare @OldGender nvarchar(10), @NewGender nvarchar(10)
    declare @OldSalary int, @NewSalary int
    declare @OldDepartmentId int, @NewDepartmentId int
	declare @OldManagerId int, @NewManagerId int
	declare @OldFirstName nvarchar(20), @NewFirstName nvarchar(20)
	declare @OldMiddleName nvarchar(20), @NewMiddleName nvarchar(20)
	declare @OldLastName nvarchar(20), @NewLastName nvarchar(20)
	declare @OldEmail nvarchar(50), @NewEmail nvarchar(50)

    -- Muutuja, kuhu läheb lõpptekst
	declare @AuditString nvarchar(1000)

	-- Laeb kõik uuendatud andmed temp tabeli alla
	select * into #TempTable
	from inserted

	-- Käib läbi kõik andmed temp tabelis
	while(exists(select Id from #TempTable))
	begin
		set @AuditString = ''
	-- Valib esimese rea andmed  temp tabelist
	select top 1 @Id = Id, @NewGender = Gender,
	@NewSalary = Salary, @NewDepartmentId = DepartmentId,
	@NewManagerId = ManagerId, @NewFirstName = FirstName,
	@NewLastName = LastName,
	@NewEmail = Email
	from #TempTable
	-- (Võtab vanad andmed kustutatud tabelist)
	select @OldGender = Gender,
	@OldSalary = Salary, @OldDepartmentId = DepartmentId,
	@OldManagerId = ManagerId, @OldFirstName = FirstName,
	@OldLastName = LastName,
	@OldEmail = Email
	from deleted where Id = @Id

	-- Toimub võrdlus veergude osasz, kinnitamaks, kas toimus andmete muutmine
	set @AuditString = 'Employee with Id = ' + cast(@Id as nvarchar(4)) + ' changed '
	if(@OldGender <> @NewGender)
		set @AuditString = @AuditString + ' Gender from ' + @OldGender + ' to ' +
		@NewGender

	if(@OldSalary <> @NewSalary)
		set @AuditString = @AuditString + ' Salary from ' + cast(@OldSalary as nvarchar(20))
		+ ' to ' + cast(@NewSalary as nvarchar(10))
    if(@OldDepartmentId <> @NewDepartmentId)
		set @AuditString = @AuditString + ' DepartmentId from ' + cast(@OldDepartmentId as nvarchar(20))
		+ ' to ' + cast(@NewDepartmentId as nvarchar(10))

	if(@OldManagerId <> @NewManagerId)
		set @AuditString = @AuditString + ' ManagerId from ' + cast(@OldManagerId as nvarchar(20))
		+ ' to ' + cast(@NewManagerId as nvarchar(10))

	if(@OldFirstName <> @NewFirstName)
		set @AuditString = @AuditString + ' FirstName from ' + @OldFirstName + ' to ' +
		@NewFirstName

	if(@OldMiddleName <> @NewMiddleName)
		set @AuditString = @AuditString + ' MiddleName from ' + @OldMiddleName + ' to ' +
		@NewMiddleName

	if(@OldLastName <> @NewLastName)
		set @AuditString = @AuditString + ' LastName from ' + @OldLastName + ' to ' +
		@NewLastName

	if(@OldEmail <> @NewEmail)
		set @AuditString = @AuditString + ' Email from ' + @OldEmail + ' to ' +
		@NewEmail

	insert into dbo.EmployeeAudit values (@AuditString)
	-- kustutab temp tabelist rea, et saaksime liikuda uue rea juurde
	delete from #TempTable where Id = @Id
    end
end

create table Department (
    Id int primary key,
    DepartmentName nvarchar(20)
)

insert into Employees values (2, 'John', 'Tron', 'Male', 4000, 'Tallinn', 3, null, null);
insert into Employees values (3, 'Heidi', 'Klum', 'Female', 3000, 'Tallinn', 2, null, null);
insert into Employees values (4, 'Josh', 'Bosh', 'Male', 2500, 'Tartu', 4, null, null);
select * from Employees;

insert into dbo.Department values (1, 'IT'),
                                  (2, 'Finance'),
                                  (3, 'HR');

drop view if exists vEmployeeDetails;

create view vEmployeeDetails
as
    select e.Id, e.FirstName, e.LastName, e.Gender, d.DepartmentName from Employees as e
join Department as d
on e.DepartmentId = d.Id;

 -- Ei saa uuendada andmeid, sest mitu tabelit on sellest mõjutatud.
-- update vEmployeeDetails
-- set FirstName = 'Johnny', DepartmentName = 'IT'
-- where Id = 1;

 select * from vEmployeeDetails;

create trigger tr_vEmployeeDetails_InsteadOfUpdate
    on vEmployeeDetails
    instead of update
    as begin
        if(UPDATE(Id))
        begin
            raiserror('Id cannot be changed', 16, 1)
            return
        end

        if(update(DepartmentName))
        begin
            declare @DeptId int
            select @DeptId = Department.Id
            from Department
            join inserted
            on inserted.DepartmentName = Department.DepartmentName

            if(@DeptId is null)
            begin
                raiserror('Invalid Department name', 16, 1)
                return
            end

            update Employees set DepartmentId = @DeptId
            from inserted
            join Employees
            on Employees.Id = inserted.Id

            if(update(Gender))
            begin
                update Employees set Gender = inserted.Gender
                from inserted
                join Employees
                on Employees.Id = inserted.Id
            end

            if(update(FirstName))
            begin
                update Employees set FirstName = inserted.FirstName
                from inserted
                join Employees
                on Employees.Id = inserted.Id
            end

            if(update(LastName))
            begin
                update Employees set LastName = inserted.LastName
                from inserted
                join Employees
                on Employees.Id = inserted.Id
            end
        end
end

    -- Tavaline update, kus on Id 1
update vEmployeeDetails set FirstName = 'Johnny' where id = 1;
update vEmployeeDetails set Gender = 'Male' where id = 1;
-- update vEmployeeDetails set DepartmentId = 3 where id = 1; -- DepartmentId was not added to the view

-- View, mis kasutab join ja tabelid on Employee ja Department
--selectis kasutame veerge DeptId, DeptName ja siis loendab ridade arvu tabelis
--lõpus grupeerib ära DeptName ja DeptId järgi

create view vEmployeeCount
as
select DepartmentId, City, DepartmentName, count(*) as TotalEmployees
from Employees as e
join Department as d
on e.DepartmentId = d.Id
group by DepartmentName, DepartmentId, City

select * from vEmployeeCount

--näitab ära osakonnad, kus on töötajaid 2 või rohkem
select DepartmentName, TotalEmployees from vEmployeeCount
where TotalEmployees >= 2

-- Kasutame temp. tabelit
select DepartmentName, DepartmentId, count(*) as TotalEmployees
into #TempEmployeeCount
from Employees as e
join Department as d
on e.DepartmentId = d.Id
group by DepartmentName, DepartmentId

select * from #TempEmployeeCount

-- Proovime info saada temp tabelist ja kus >= 2 töötajaga osakond
select DepartmentName, TotalEmployees
from #TempEmployeeCount
where TotalEmployees >= 2

-- NB! Kui kustutame InsteadofDelete triggeri vEmployeeDetailsi alt siis saab veateate läbi samal ajal
-- view kustutamise
create trigger trEmployeeDetails_InsteadOfDelete
on vEmployeeDetails
instead of delete
as begin
    delete e
    from Employees as e
    join deleted
    on e.Id = deleted.Id
end

delete from vEmployeeDetails where Id = 3

-- drop view vEmployeeCount;
-- drop view vEmployeesDataExceptSalary;
-- drop view vITEmployeesInDepartment;
-- drop view vProductSalesCalculated;
drop view vEmployeeDetails;

drop table _Employees;
drop table EmployeeFirstName;
drop table Employees;
drop table Employees_;
drop table EmployeeAudit;