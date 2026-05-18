-- Indekseeritud view

create table Product(
    Id int primary key,
    Name nvarchar(20),
    UnitPrice int
);

insert into Product values
                        (1, 'Books', 20),
                        (2, 'Pens', 14),
                        (3, 'Pencils', 11),
                        (4, 'Clips', 10);


create table ProductSales(
    ProductId int ,
    QuantitySold int
);


insert into ProductSales values
                             (1, 10),
                             (2, 21),
                             (3, 12),
                             (4, 13),
                             (2, 12),
                             (1, 14),
                             (3, 12),
                             (4, 20);

-- Koosta view, millega arvutatakse müüdud ühikute kogusumma ja tulu.
create view vProductSalesCalculated with schemabinding as
    select P.Id,
    P.Name,
    P.UnitPrice,
    SUM(isnull(PS.QuantitySold, 0)) as TotalQuantitySold,
    SUM(isnull(PS.QuantitySold * P.UnitPrice, 0)) as TotalRevenue,
    COUNT_BIG(*) as TotalTransactions
from dbo.Product P
join dbo.ProductSales PS on P.id = PS.ProductId
group by P.Id, P.Name, P.UnitPrice
go
-- PS: siin peaks olema ka asendusväärtus defineeritud.

select * from vProductSalesCalculated;
drop view vProductSalesCalculated;

-- Mõned reeglid:
-- 1. View tuleb luua koos schemabindinguga.
-- 2. Kui lisafunktsioon select list viitab väljendile ja selle tulemuseks võib olla NULL,
--      siis asendusväärtus peab olema täpsustatud.
-- 3. Kui GroupBy on täpsustatud siis vide select list peab sisalda COUNT_BIG(*) väljendit
-- 4. Baastabelis peaksid view'd olema viidatud kaheosalise nimega ehk dbo.TableName etc.
--      COUNT_BIG() tagastab bigint väärtuse, mis on suurem tavalise int max väärtusest.

create unique clustered index UIX_vTotalSalesByProduct_Name
on vProductSalesCalculated(Name);

-- Temp. table kasutamine
create table ##TestTempTable(
    Id int,
    FirstName nvarchar(30),
    Gender nvarchar(10)
);

insert into ##TestTempTable values
                                (101, 'Martin', 'Male'),
                                (102, 'Joe', 'Male'),
                                (103, 'Pam', 'Female'),
                                (104, 'James', 'Male');

drop table Product;
drop table ProductSales;

-- Kas saab luua view'd ajutisest tabelist?
-- --- Why Doesn't SQL Server Allow Views on Temporary Tables? ----
-- Persistence: Temporary tables are created and dropped automatically during the session.
--  Views, however, need to be persistent objects within the database schema. Allowing a view to depend on a
--  temporary table would break this persistence model because views are expected to be available across sessions,
--  unlike temporary tables.
-- Session Specific: Temporary tables only exist for the duration of a session, while
--  views are meant to be reusable by all users and can be referenced at any time. Since views require the data
--  to be accessible beyond the session, SQL Server does not allow creating a view on a temporary table.