create table EmployeeWithSalary
(
    Id int primary key,
    Name nvarchar(25),
    Salary int,
    Gender nvarchar(10)
)

insert into EmployeeWithSalary values(1, 'Sam', 2500, 'Male')
insert into EmployeeWithSalary values(2, 'Pam', 6500, 'Female')
insert into EmployeeWithSalary values(3, 'John', 4500, 'Male')
insert into EmployeeWithSalary values(4, 'Sara', 5500, 'Female')
insert into EmployeeWithSalary values(5, 'Todd', 3100, 'Male')

select * from EmployeeWithSalary
where Salary > 5000 and Salary < 7000

-- Loome indeksi, mis järjestab palgad kahanevasse järjekorda:
create index IX_Employee_Salary
on EmployeeWithSalary(Salary desc)

-- Allpool on Filtered Index (filtreeritud indeks).
-- Ei sisalda andmeid kõigi töötajate kohta, vaid ainult nende kohta, kelle palk on vahemikus 4001–6999.
create index IX_Employee_Salary_Range
on EmployeeWithSalary(Salary)
where Salary > 4000 and Salary < 7000

select * from EmployeeWithSalary
with (index(IX_Employee_Salary))

-- SQL Server ei saa tagastada "kõiki ridu" (SELECT *), kasutades indeksit, kus on ainult osa ridu.
SELECT * FROM EmployeeWithSalary
WITH (INDEX(IX_Employee_Salary_Range))
WHERE Salary > 4000 AND Salary < 7000;

-- INDEKSITE TÜÜBID: --
-- 1. Klastris olevad - Clustered Index
-- 2. Mitte klastris olevad - Non-Clustered Index
-- 3. Unikaalsed - Unique Index
-- 4. Filtreeritud - Filtered Index
-- 5. XML
-- 6. Täistekst - Full-Text Index
-- 7. Ruumiline - Spatial Index
-- 8. Veerusäilitav/Veergude indeksid - Columnstore Index
-- 9. Väljaarvatud veergudega indeksid - Index with Included Columns

-- KOKKUVÕTE --
-- Kui vajad kiiret otsingut id-järgi, kasuta Clustered (Primary Key).
--
-- Kui vajad kiiret otsingut nime/kuupäeva järgi, kasuta Non-Clustered.
--
-- Kui analüüsid miljoneid ridu, kasuta Columnstore.
--
-- Kui otsid asukohti kaardilt, kasuta Spatial.

-- NÄITED --
-- Clustered index:
create table EmployeeCity(
    Id int primary key,
    Name nvarchar(25),
    Salary int,
    Gender nvarchar(10),
    City nvarchar(20)
)

insert into EmployeeWithSalary values(3, 'John', 4500, 'Male')
insert into EmployeeWithSalary values(1, 'Sam', 2500, 'Male')
insert into EmployeeWithSalary values(4, 'Sara', 5500, 'Female')
insert into EmployeeWithSalary values(5, 'Todd', 3100, 'Male')
insert into EmployeeWithSalary values(2, 'Pam', 6500, 'Female')

-- Andmete sisestamisel tulevad need ikka õiges järjekorras primary key pärast.

-- klastris olevad indeksid dikteerivad säilitatud andmete järjestuse tabelis
-- ja seda saab klastrite puhul olla ainult üks
CREATE clustered index IX_EmployeeCity_Name
on EmployeeCity(Name)
--- annab veateate, et tabelis saab olla ainult üks klastris olev indeks
--- kui soovid, uut indeksit luua, siis kustuta olemasolev

--- saame luua ainult ühe klastris oleva indeksi tabeli peale
--- klastris olev indeks on analoogne telefoni nr-le
--- enne seda päringut kustutasime primaarvõtme indeksi ära

--mitte klastris olev indeks
create nonclustered index IX_EmployeeCity_Name123
on EmployeeCity(Name)


--- erinevused kahe indeksi vahel
--- 1. ainult üks klastris olev indeks saab olla tabeli peale,
--- mitte-klastris olevaid indekseid saab olla mitu
--- 2. klastris olevad indeksid on kiiremad kuna indeks peab
--- tagasi viitama tabelile
--- Juhul, kui selekteeritud veerg ei ole olemas indeksis
--- 3. Klastris olev indeks määratleb ära tabeli ridade slavestusjärjestuse
--- ja ei nõua kettal lisa ruumi. Samas mitte klastris olevad indeksid on
--- salvestatud tabelist eraldi ja nõuab lisa ruumi