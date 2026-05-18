-- Pivot
drop table if exists ProductSales;

create table ProductSales (
    SalesAgent nvarchar(20),
    SalesCountry nvarchar(20),
    SalesAmount int
)

insert into ProductSales values
     ('Tom', 'UK', 200),
     ('John', 'US', 180),
     ('John', 'UK', 260),
     ('David', 'India', 450),
     ('Tom', 'India', 350),
     ('David', 'US', 200),
     ('Tom', 'US', 130),
     ('John', 'India', 540),
     ('John', 'UK', 120),
     ('David', 'UK', 220),
     ('John', 'UK', 420),
     ('David', 'US', 320),
     ('Tom', 'US', 340),
     ('Tom', 'UK', 660),
     ('John', 'India', 430),
     ('David', 'India', 230),
     ('David', 'India', 280),
     ('Tom', 'UK', 480),
     ('John', 'UK', 360),
     ('David', 'UK', 140)


select SalesCountry, SalesAgent, sum(SalesAmount) as Total
from ProductSales
group by SalesCountry, SalesAgent
order by SalesCountry ,SalesAgent;

-- Päring, kus kasutatakse pivot võtmesõna. Tulemus näeb samasugune välja.
select SalesAgent,
       India,
       US,
       UK
from ProductSales
pivot
(
    sum(SalesAmount) for SalesCountry in
    ([India], [US], [UK])
) as PivotTable;

-- Pivot kasutamine võimaldab muuta ridu veergudeks ja teha andmete koondamist.
-- Lisada veerg nimega ID int primary key

alter table ProductSales add Id int identity(1, 1) primary key;

-- Kui kasutada sama pivot käsklust, nagu enne, siis tulemus on nüüd teistsugune.

-- Selle parandamiseks tuleb eraldada ID ülejäänud pivotist.
select SalesAgent, India, US, UK
from
    ( -- Kogu tabel miinus ID rida.
        select SalesAgent, SalesCountry, SalesAmount from ProductSales
    )
as SourceTable
pivot (
        sum(SalesAmount) for SalesCountry in ([India], [US], [UK])
    )
as PivotTable
-- Niimoodi ei korrata SalesAgent nimesid ning vastavad väärtused tulevad kõik samasse ritta.