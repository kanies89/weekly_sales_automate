SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET DATEFIRST 1
DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1
--select @ostatni_tydzien


IF OBJECT_ID ('tempdb..#channels') IS NOT NULL DROP TABLE #channels
CREATE TABLE #channels
(sc varchar(32),rok int,week int,sort int) 
INSERT INTO #channels VALUES ('Direct sales and big merchants',@rok,@ostatni_tydzien,3)
INSERT INTO #channels VALUES ('DSA',@rok,@ostatni_tydzien,9)
INSERT INTO #channels VALUES ('Corporate Partners',@rok,@ostatni_tydzien,10)
INSERT INTO #channels VALUES ('MILLENNIUM',@rok,@ostatni_tydzien,5)
INSERT INTO #channels VALUES ('Remote sales Millennium',@rok,@ostatni_tydzien,12)
INSERT INTO #channels VALUES ('Cooperative Banks',@rok,@ostatni_tydzien,6)
INSERT INTO #channels VALUES ('Direct Sales - Key clients',@rok,@ostatni_tydzien,4)
INSERT INTO #channels VALUES ('GL migration',@rok,@ostatni_tydzien,11)
INSERT INTO #channels VALUES ('Regional Sales Managers',@rok,@ostatni_tydzien,8)
INSERT INTO #channels VALUES ('Dealers sales channel',@rok,@ostatni_tydzien,1)
INSERT INTO #channels VALUES ('Sales representatives',@rok,@ostatni_tydzien,7)
INSERT INTO #channels VALUES ('Dealers sales channel - leads',@rok,@ostatni_tydzien,2)
INSERT INTO #channels VALUES ('Operations',@rok,@ostatni_tydzien,17)
INSERT INTO #channels VALUES ('Multipay',@rok,@ostatni_tydzien,16)
INSERT INTO #channels VALUES ('ICP',@rok,@ostatni_tydzien,15)
INSERT INTO #channels VALUES ('Remote sales other',@rok,@ostatni_tydzien,14)
INSERT INTO #channels VALUES ('Remote sales NestBank',@rok,@ostatni_tydzien,13)
INSERT INTO #channels VALUES ('No channel info',@rok,@ostatni_tydzien,18)

---split---

DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1

if object_id (N'tempdb..#t1')  is not null drop table #t1
select 
td.sales_channel2,
tr_tvid,SUM(cast(td.value as money))/100 as val,
td.week_number as week_txn,
td.miesiac as mies_txn,
sd.active_date,
DATEPART(week,sd.active_date) as week_act,
DATEPART(month,sd.active_date) as month_act 
into #t1
from [konkursy].[dbo].[sales_channel_trans_details] td
left join [konkursy].[dbo].[sales_channel_details] sd on sd.t_vid=td.tr_tvid Collate Polish_CI_AS
where 
DATEPART(YEAR,sd.active_date)>=@rok and 
DATEPART(week,sd.active_date)<=@ostatni_tydzien and 
td.week_number<=@ostatni_tydzien and 
td.rok>=@rok
and td.lightpos = 'lightpos'
group by td.sales_channel2,td.tr_tvid,td.week_number,td.miesiac,sd.active_date,DATEPART(week,sd.active_date),DATEPART(month,sd.active_date)

---split---

DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1

if object_id (N'tempdb..#t2')  is not null drop table #t2
select 
td.sales_channel2,
tr_tvid,SUM(cast(td.value as money))/100 as val,
td.week_number as week_txn,
td.miesiac as mies_txn,
sd.active_date,
DATEPART(week,sd.active_date) as week_act,
DATEPART(month,sd.active_date) as month_act 
into #t2
from [konkursy].[dbo].[sales_channel_trans_details] td
left join [konkursy].[dbo].[sales_channel_details] sd on sd.t_vid=td.tr_tvid Collate Polish_CI_AS
where DATEPART(YEAR,sd.active_date)>=@rok and 
DATEPART(week,sd.active_date)<=@ostatni_tydzien and 
td.week_number=@ostatni_tydzien and 
td.rok>=@rok
group by td.sales_channel2,td.tr_tvid,td.week_number,td.miesiac,sd.active_date,DATEPART(week,sd.active_date),DATEPART(month,sd.active_date)

---split---

DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
DECLARE @rok_prev as int
DECLARE @miesiac_prev as int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1
SET @rok_prev = YEAR(CAST(DATEADD(month,-1,getdate()) as date))
SET @miesiac_prev = MONTH(CAST(DATEADD(month,-1,getdate()) as date))

if object_id (N'tempdb..#t3_1')  is not null drop table #t3_1
select t_vid,active_date,sales_channel2
into #t3_1
from [konkursy].[dbo].[sales_channel_details]
where sc_symbol<>'GL' and DATEPART(month,active_date)=@miesiac_prev and 
DATEPART(YEAR,active_date)>=@rok_prev

---split---

DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
DECLARE @rok_prev as int
DECLARE @miesiac_prev as int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1
SET @rok_prev = YEAR(CAST(DATEADD(month,-1,getdate()) as date))
SET @miesiac_prev = MONTH(CAST(DATEADD(month,-1,getdate()) as date))

if object_id (N'tempdb..#t3_2')  is not null drop table #t3_2
select tr_tvid,SUM(cast(td.value as money))/100 as val
into #t3_2
from [konkursy].[dbo].[sales_channel_trans_details] td
where td.week_number=@ostatni_tydzien and 
td.rok>=@rok
group by tr_tvid

---split---

DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1
if object_id (N'tempdb..#av')  is not null drop table #av
select 
COUNT(distinct tr_tvid) as POS,
sales_channel2, 
sc_symbol2,
SUM(cast(value as money))/100 as value,
week_number,
rok
into #av
from [konkursy].[dbo].[sales_channel_trans_details]
--left join #diler on tr_tvid collate Polish_CS_AI = t_vid 
where rok>=@rok and week_number=@ostatni_tydzien --and channel_symbol not in ('DLZL','DLBR','SPP')
and sales_channel2 NOT IN ('Sprzedażowy Program Pracowniczy')
group by sales_channel2,sc_symbol2,week_number,rok

---split---

DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1

if object_id (N'tempdb..#t22')  is not null drop table #t22
select 
td.sales_channel2,
tr_tvid,SUM(cast(td.value as money))/100 as val,
td.week_number as week_txn,
td.miesiac as mies_txn,
sd.active_date,
DATEPART(week,sd.active_date) as week_act,
DATEPART(month,sd.active_date) as month_act 
into #t22
from [konkursy].[dbo].[sales_channel_trans_details] td
left join [konkursy].[dbo].[sales_channel_details] sd on sd.t_vid=td.tr_tvid Collate Polish_CI_AS
where DATEPART(YEAR,sd.active_date)>=@rok and 
DATEPART(week,sd.active_date)<=@ostatni_tydzien and 
td.week_number=@ostatni_tydzien and 
td.rok>=@rok
and td.lightpos='lightpos' and sd.lightpos='lightpos'
group by td.sales_channel2,td.tr_tvid,td.week_number,td.miesiac,sd.active_date,DATEPART(week,sd.active_date),DATEPART(month,sd.active_date)

---split---

DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
DECLARE @rok_prev as int
DECLARE @miesiac_prev as int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1
SET @rok_prev = YEAR(CAST(DATEADD(month,-1,getdate()) as date))
SET @miesiac_prev = MONTH(CAST(DATEADD(month,-1,getdate()) as date))

if object_id (N'tempdb..#t3_11')  is not null drop table #t3_11
select t_vid,active_date,sales_channel2
into #t3_11
from [konkursy].[dbo].[sales_channel_details]
where sc_symbol<>'GL' and DATEPART(month,active_date)=@miesiac_prev and 
DATEPART(YEAR,active_date)>=@rok_prev

---split---

DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
DECLARE @rok_prev as int
DECLARE @miesiac_prev as int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1
SET @rok_prev = YEAR(CAST(DATEADD(month,-1,getdate()) as date))
SET @miesiac_prev = MONTH(CAST(DATEADD(month,-1,getdate()) as date))

if object_id (N'tempdb..#t3_22')  is not null drop table #t3_22
select tr_tvid,SUM(cast(td.value as money))/100 as val
into #t3_22
from [konkursy].[dbo].[sales_channel_trans_details] td
where td.week_number=@ostatni_tydzien and 
td.rok>=@rok
and lightpos = 'lightpos'
group by tr_tvid

---split---

DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1
if object_id (N'tempdb..#av1')  is not null drop table #av1
select 
COUNT(distinct tr_tvid) as POS,
sales_channel2, 
sc_symbol2,
SUM(cast(value as money))/100 as value,
week_number,
rok
into #av1
from [konkursy].[dbo].[sales_channel_trans_details]
--left join #diler on tr_tvid collate Polish_CS_AI = t_vid 
where rok>=@rok and week_number=@ostatni_tydzien --and channel_symbol not in ('DLZL','DLBR','SPP')
and sales_channel2 NOT IN ('Sprzedażowy Program Pracowniczy')
and lightpos = 'lightpos'
group by sales_channel2,sc_symbol2,week_number,rok

---split---

DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1

if object_id (N'tempdb..#t11')  is not null drop table #t11
select 
td.sales_channel2,
tr_tvid,SUM(cast(td.value as money))/100 as val,
td.week_number as week_txn,
td.miesiac as mies_txn,
sd.active_date,
DATEPART(week,sd.active_date) as week_act,
DATEPART(month,sd.active_date) as month_act 
into #t11
from [konkursy].[dbo].[sales_channel_trans_details] td
left join [konkursy].[dbo].[sales_channel_details] sd on sd.t_vid=td.tr_tvid Collate Polish_CI_AS
where 
DATEPART(YEAR,sd.active_date)>=@rok and 
DATEPART(week,sd.active_date)<=@ostatni_tydzien and 
td.week_number<=@ostatni_tydzien and 
td.rok>=@rok
group by td.sales_channel2,td.tr_tvid,td.week_number,td.miesiac,sd.active_date,DATEPART(week,sd.active_date),DATEPART(month,sd.active_date)