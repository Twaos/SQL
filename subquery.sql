drop table if exists Product;
drop table if exists ProductSales;

create table Product(
    Id int identity primary key,
    Name nvarchar(50),
    Description nvarchar(250)
)

create table ProductSales
(
    Id int primary key identity,
    ProductId int foreign key references Product(id),
    UnitPrice int,
    QuantitySold int
);

insert into Product (Name, Description)
values
    ('TV', '52" display  black color television'),
    ('Laptop', 'Very thin silver color laptop'),
    ('Desktop PC', 'HP high performance desktop PC');

insert into ProductSales (ProductId, UnitPrice, QuantitySold)
values
    (3, 450, 10),
    (2, 250, 7),
    (3, 450, 4),
    (3, 450, 9);

select * from Product;
select * from ProductSales;

-- Subquery müümata toodete kohta info pärimiseks
select Id, Name, Description
from Product
where Id not in
    ( -- Subquery:
        select distinct ProductId from ProductSales
    );