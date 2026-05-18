-- Transaction on käskluste kogum, mida täidetakse korraga ühtse tööüksusena.
-- See kontrollib vigu - kui on viga, siis see taastab andmebaasi algse oleku (mis on vahetult enne tehingut).
-- Prepared SQL code that can be reused

create table MailingAddress (
    Id int primary key not null,
    EmployeeNumber int not null,
    HouseNumber nvarchar(50),
    StreetAddress nvarchar(50),
    City nvarchar(20),
    PostalCode nvarchar(20)
);

insert into MailingAddress
values (1, 101, '#10', 'King Street', 'London', 'CR27DW');

create table PhysicalAddress (
    Id int primary key not null,
    EmployeeNumber int not null,
    HouseNumber nvarchar(50),
    StreetAddress nvarchar(50),
    City nvarchar(20),
    PostalCode nvarchar(20)
);

insert into PhysicalAddress
values (1, 101, '#10', 'King Street', 'Londoon', 'CR27DW');


create procedure spUpdateAddress
as begin
    begin try
        begin transaction
            update MailingAddress set City = 'LONDON'
            where MailingAddress.Id = 1 and EmployeeNumber = 101

            update PhysicalAddress set City = 'LONDON'
            where PhysicalAddress.Id = 1 and EmployeeNumber = 101
        commit transaction
    end try
    begin catch
        rollback transaction
    end catch
end
go
----
spUpdateAddress

select * from MailingAddress
select * from PhysicalAddress

-- Kasutame sama SP-d, aga muudame sisu:
create procedure spUpdateAddressNew()
as begin
    begin try
        begin transaction
            update MailingAddress set City = 'LONDON 12'
            where MailingAddress.Id = 1 and EmployeeNumber = 101

            update PhysicalAddress set City = 'LONDON LONDON'
            where PhysicalAddress.Id = 1 and EmployeeNumber = 101
        commit transaction
    end try
    begin catch
        rollback transaction
    end catch
end
go
----
spUpdateAddressNew

select * from MailingAddress;
select * from PhysicalAddress;

------
truncate table MailingAddress; -- Tühjendab tabeli
truncate table PhysicalAddress;
drop procedure spUpdateAddress;

    -- Kui teine uuendus ei lähe läbi, ei lähe ka esimene.

-- Transaction ACID test:
    -- A - atomic:
        -- Kõik tehingud on kas edukalt läbitud või need lükatakse tagasi.
    -- C - consistent:
        -- Kõik tehinguid puudutavad andmed jäetakse loogiliselt järjepidevases olekusse. Nt laoesemete vähendamisel peab
        -- tabelis olema vastav kanne, inventuur ei saa lihtsalt kaduda.
    -- I - isolated:
        -- Tehing peab andmeid mõjutama ilma teistesse samaaegsetesse tehingutesse sekkumata.
    -- D - durable:
        -- Kui muudatus on tehtud, siis see on püsiv.