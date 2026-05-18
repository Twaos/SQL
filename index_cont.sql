-- 28.04

-- Vaikimisi primaarvõti loob nikaalse klastris oleva indeksi,
--  samas unikaalne piirand loob unikaalse mitte klastris oleva indeksi.

-- Unikaalset indeksit või piirangut ei saa luua olemasolevasse tabelisse,
--  kui tabel juba sisaldab väärtusi võtmeveerus.

-- Vaikimisi ei ole korduvad väärtused veerus lubatud, kui peaks olema unikaane indeks või piirang.
-- NÄITEKS: Kui tahad sisestada 10 rida andmeid, millest 5 sisaldavad korduvaid andmeid, sis kõik 10 lükatakse tagasi.

-- Kui soovid ainult 5 rea tagasilükkamist ja ülejäänud 5 rea sisestamist, siis selleks tuleb kasutada IGNORE_DUP_KEY.



    create table EmployeeFirstName(
        Id int primary key,
        FirstName nvarchar(30),
        LastName nvarchar(30),
        Salary int,
        City nvarchar(30)
    )

    create unique index IX_EmployeeFirstName
    on EmployeeFirstName(City)
    with IGNORE_DUP_KEY

    insert into EmployeeFirstName values
                                      (3, 'Josh', 'Bosh', 2500, 'London'),
                                      (4, 'Josh', 'Bosh', 2500, 'Bristol')

    insert into EmployeeFirstName values
                                      (4, 'Josh', 'Bosh', 2500, 'Banana'),
                                      (6, 'Heidi', 'Klum', 5000,'Berlin')

