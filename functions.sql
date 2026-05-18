drop table if exists Employee;

create table Employee(
    Id int primary key,
    Name varchar(20),
    DateOfBirth datetime
);

INSERT INTO Employee (Id, Name, DateOfBirth)
VALUES (1, 'Sam', '1980-12-30 00:00:00.000');
INSERT INTO Employee (Id, Name, DateOfBirth)
VALUES (2, 'Pam', '1982-09-01 12:02:36.260');
INSERT INTO Employee (Id, Name, DateOfBirth)
VALUES (3, 'John', '1985-08-22 12:03:30.370');
INSERT INTO Employee (Id, Name, DateOfBirth)
VALUES (4, 'Sara', '1979-11-29 12:59:30.670');

create function fnComputeAge(@DOB datetime)
returns nvarchar(50)
as begin
	declare @tempdate datetime, @years int, @months int, @days int
	select @tempdate = @DOB

	select @years = datediff(year, @tempdate, getdate()) - case when (month(@DOB) > month(getdate())) or (month(@DOB))
	= month(getdate()) and day(@DOB) > day(getdate()) then 1 else 0 end
	select @tempdate = dateadd(year, @years, @tempdate)

	select @months = datediff(month, @tempdate, getdate()) - case when day(@DOB) > day(getdate()) then 1 else 0 end
	select @tempdate = dateadd(month, @months, @tempdate)

	select @days = datediff(day, @tempdate, getdate())

	declare @Age nvarchar(50)
		set @Age = cast(@years as nvarchar(10)) + ' years, '
		+ cast(@months as nvarchar(10)) + ' months, '
		+ cast(@days as nvarchar(10)) + ' days old'
	return @Age
end

-- Saame vanuse välja arvutada, kui kasutame fnComputeAge funktsiooni:
select Name, DateOfBirth, dbo.fnComputeAge(DateOfBirth) as Age
from Employee;

-- Number peale DOB muutujat näitab, mis järjes me tahame näidata veeru sisu
select Id, Name, DateOfBirth,
convert(nvarchar,DateOfBirth, 109) as ConvertedDOB
from Employee;

select Id, Name, Name + ' - ' + cast(Id as nvarchar) as [Name-Id]
from Employee;

select cast(getdate() as date) --tänane kp
select convert(date, getdate()) --tänane kp

-- Mõned matemaatilised funktsioonid:
select abs(-101.5) --absoluutväärtus, tagastab 101.5
select ceiling(101.5) --tagastab 102, ümardab üles
select CEILING(-101.5) --tagastab -101, ümardab üles positiivsema nr poole
select floor(101.5) --tagastab 101, ümardab alla
select floor(-101.5) --tagastab -102, ümardab alla negatiivsema nr poole
select power(2, 4) -- 2 astmel 4 e 2x2x2x2, esimene nr on alus
select SQUARE(5) -- tagastab 25, võtab arvu ja korrutab iseendaga
select sqrt(25) --tagastab 5, võtab arvu ja leiab selle ruutjuure

select rand() --tagastab juhusliku arvu vahemikus 0 kuni 1

-- Scalar function: tagastab mingis vahemikus olevad väärtused
create function fn_EmployeesByGender(@Gender nvarchar(10))
returns table
as
return (select Id, Name, DateOfBirth, DepartmentId, Gender
		from EmployeesWithDates
		where Gender = @Gender);

-- Inline function
create function fn_GetEmployees()
returns table as
return (select Id, Name, cast(DateOfBirth as date)
		as DOB
		from EmployeesWithDates);

select * from fn_GetEmployees();

-- Multi-statement table valued function
create function fn_MS_GetEmployees()
returns @Table Table (Id int, Name nvarchar(20), DOB date)
as begin
	insert into @Table
	select Id, Name, cast(DateOfBirth as date) from EmployeesWithDates

	return
end

select * from fn_MS_GetEmployees()
