-- 21.04
-- Temporary tables - tabelid, mis on loodud ajutiselt ja kustutatakse automaatselt.
-- Neid on kahte tüüpi: local temporary tables, global temporary tables
-- Local - #; Global - ##
create table #PersonDetails(Id int, Name nvarchar(30))

-- Temp tabeleid ei salvestata tavalise andmebaasi tabelite alla, vaid süsteemsesse andmebaasi tempdb.

insert into #PersonDetails values(1, 'Mike')
insert into #PersonDetails values(2, 'Max')
insert into #PersonDetails values(3, 'Uhura')
go

select * from #PersonDetails

-- Objekti saab otsida üles:
select Name from tempdb.sys.tables
where Name like '#PersonDetails%'

drop table #PersonDetails

-- Stored procedure - loob local temp tabeli ja täidab selle andmetega --
create proc spCreateLocalTempTable
as begin
    create table #PersonDetails(Id int, Name nvarchar(30))

    insert into #PersonDetails values(1, 'Mike')
    insert into #PersonDetails values(2, 'Max')
    insert into #PersonDetails values(3, 'Uhura')

    select * from #PersonDetails
end
go

exec spCreateLocalTempTable; -- <- miskipärast jääb lõputult executima

-- Globaalse tabeli loomine
create table ##GlobalPersonDetails(Id int, Name nvarchar(20))

-- Erinevused globaalse ja lokaalse tabeli vahel:
-- 1. Lokaalne on nähtav ainult sellele kasutajale/sessioonile, kes selle lõi, globaalne on nähtav kõikidele
--      kasutajatele ja kõikidele aktiivsetele sessioonidele andmebaasis.
-- 2. Lokaalne tabel kustutatakse automaatselt, kui tabeli loonud sessioon (aken/ühendus) suletakse.
--      Globaalne kustutatakse siis, kui kõik seda tabelit kasutavad sessioonid on suletud.
-- 3. Lokaalne on kasutuse poolest rohkem levinud, kui globaalne. Viimast kasutatakse siis, kui
--      on vaja andmeid liigutada erinevate rakenduste või kasutajate vahel ilma päris tabelit loomata.

-- 4.1 Lõin stored procedure selleks, et saada tabelist dbo.DimEmployee kätte töötajate ees-ja perekonnanime, kui ka tööliste soo pärimise
CREATE PROCEDURE spGetEmployees
AS 
BEGIN
	SELECT FirstName, LastName, Gender FROM dbo.DimEmployee
END

EXECUTE spGetEmployees

--4.2 Parem turvalisus;  parema koodi taaskasutus ja hooldus; Hoiab ära SQL Injecton rünnakud; Vähendab võrguliiklust -> peab saatma ainult käskluse EXECUTE SP_SPNimi võrku ja viimaseks täide viiva plaani säilitamine ja taaskasutus
--4.3 Tabelist võtan ja loon funktsiooni, kus tabel tagastab eesnime järgi töölisi enda valikul

CREATE FUNCTION fn_EmployeeByFirstName(@FirstName nvarchar(50))
RETURNS TABLE
AS 
RETURN (
	SELECT FirstName, LastName, Gender
	FROM dbo.DimEmployee
	WHERE @FirstName = FirstName
)

SELECT * FROM fn_EmployeeByFirstName('David')
SELECT * FROM fn_EmployeeByFirstName('Mandar')

--4.4 

--4.5 Funktsiooni saab krüpteerida ning näide on siin:
ALTER FUNCTION fn_GetEmployeeNameById(@Id int)
RETURNS nvarchar(20)
WITH ENCRYPTION jne… 

--4.6 
CREATE TABLE #ProductDetails(EnglishProductName nvarchar(50), Status nvarchar(7))
--4.7 
CREATE TABLE ##ProductDetails(EnglishProductName nvarchar(50), Status nvarchar(7))

--4.8 Globaalse ajutised tabelid on nähtavad kõikidele ühendustele serveris ja hävitatakse/hävib kui viimane ühendust on kinni pandud. 
Lokaalsed ajutised tabelid on automaatselt kustutatud, kui selle loonud sessioon on kinni pandud. 
MITU kasutajad mitmes ühenduses saavad sama nimega lokaalses ajutises tabeli luua, aga globaalne peab olema unikaalse nimega
Lokaalsed ajutised tabelid on # ühe märgiga, aga globaalselt on kaks # märki 
--4.9 Indeksit kasutatakse päringute tegemisel, mis annavad kiiresti andmeid. Indeksid
saavad aidata päringuid, mis küsivad sorteeritud tulemust, Skaneerib indekseid alates esimesest kuni viimaseni ja tagastab read sorteeritult. Välistab päringu käivitamisel ridade sorteerimist ehk nagu library, mis aitab ka kindlaid asukohti kasutada ning määrata. 
--4.10 
CREATE INDEX IX_tblProduct_ProductKey
ON dbo.DimProduct(ProductKey ASC)
EXECUTE sp_helpindex DimProduct
SELECT * FROM dbo.DimProduct WHERE ProductKey > 500 and ProductKey < 1000 



Tagastab õiges järjekorras ProductKey järgi dbo.DimProduct tabelist andmeid ehk leiab antud määratud vahemikus ProductKey üles andmed ja tagastab selle järgi 
--4.11 JOIN-ga
CREATE VIEW vWEmployeeBySalesTerritory
AS 
SELECT FirstName, LastName, Gender, SalesTerritoryCountry
FROM dbo.DimEmployee
JOIN dbo.DimSalesTerritory
ON dbo.DimEmployee.SalesTerritoryKey = dbo.DimSalesTerritory.SalesTerritoryKey

SELECT * FROM vWEmployeeBySalesTerritory

Teine lihtsalt view vaade:
CREATE VIEW vWEmployeeWithLoginId
AS 
SELECT LoginID, FirstName, LastName, Gender
FROM dbo.DimEmployee

SELECT * FROM vWEmployeeWithLoginId

