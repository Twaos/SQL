-- Korduv CTE
-- Tegemist on CTE-ga, mis viitab iseendale. Seda kasutatakse siis, kui on vaja andmeid näidata
-- hierarhiliselt.

drop table if exists Employee;

create table Employee (
    EmployeeId int primary key,
    Name nvarchar(30),
    ManagerId int
);

select * from Employee;

insert into Employee values
         (1, 'Tom', 2),
         (2, 'Josh', null),
         (3, 'Mike', 2),
         (4, 'John', 3),
         (5, 'Pam', 1),
         (6, 'Mary', 3),
         (7, 'James', 1),
         (8, 'Sam', 5),
         (9, 'Simon', 1);

-- Võimalik kuvada NULL veeru asemel 'Super Boss', kasutades Self joini:
select e.Name as [Employee Name],
       isNull(Manager.Name, 'Super Boss') as [Manager Name]
from dbo.Employee as e
left join Employee Manager
on e.ManagerId = Manager.EmployeeId;

-- Sama on võimalik teha ka CTE-ga:
with EmployeeCTE(Id, Name, ManagerId, [Level])
as
(
    select EmployeeId, Name, ManagerId, 1
    from Employee
    where ManagerId is null
    union all

    select e.EmployeeId, e.Name,
           e.ManagerId, EmployeeCTE.[Level] + 1
    from Employee as e
    join EmployeeCTE
    on e.ManagerId = EmployeeCTE.Id
)
select EmpCTE.Name as Employee,
       isnull(MgrCTE.Name, 'Super Boss') as [Manager Name],
       EmpCTE.[Level]
    from EmployeeCTE EmpCTE
    left join EmployeeCTE MgrCTE
    on EmpCTE.ManagerId = MgrCTE.Id