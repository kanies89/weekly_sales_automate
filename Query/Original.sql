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


----===== # CONTRACTS (for installed and activated POS & LightPOS)
DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1
		SELECT  c.sort,sc,
		 s.sc_symbol2, s.rok,s.week_number, COUNT(distinct contract_id) AS contract
		 FROM #channels c
		LEFT JOIN  [konkursy].[dbo].[sales_channel_details] s on sc = sales_channel2 collate Polish_CS_AI and c.rok =  s.rok and c.week = s.week_number
		WHERE c.rok = @rok  and  c.week = @ostatni_tydzien
		GROUP BY sc,s.sc_symbol2,week_number,s.rok,c.sort
		ORDER BY c.sort



----===== # POS terminals & LightPOS (installed and activated) 

DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1
		SELECT  c.sort,sc,
		 s.sc_symbol2, s.rok,s.week_number, COUNT(distinct t_vid) AS POS
		 FROM #channels c
		LEFT JOIN  [konkursy].[dbo].[sales_channel_details] s on sc = sales_channel2 collate Polish_CS_AI and c.rok =  s.rok and c.week = s.week_number
		WHERE c.rok = @rok  and  c.week = @ostatni_tydzien
		GROUP BY sc,s.sc_symbol2,week_number,s.rok,c.sort
		ORDER BY c.sort


----========= # LightPOS (installed and activated) 
DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1
		
		SELECT  c.sort,c.sc,
		 l.sales_channel2, l.rok,l.week_number, ISNULL(POS,0) as POS
		 FROM #channels c
		LEFT JOIN 
		(select sales_channel2,rok,week_number,COUNT(distinct t_vid) AS POS
		FROM
		[konkursy].[dbo].[sales_channel_details] 
		WHERE rok = @rok and week_number = @ostatni_tydzien
				and lightpos = 'lightpos'
		GROUP BY sales_channel2,rok,week_number) as l on l.sales_channel2 = c.sc collate Polish_CI_AS
		ORDER BY sort

----======= # # transactions (ePay) all merchants POS & LightPOS
		-- #transactions ePay allmerchants
		-- w PBI - qty_txn
DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1

		SELECT   c.sort,sc,
		 s.sc_symbol2, s.rok,s.week_number, SUM(qty) AS qty
		 FROM #channels c
		LEFT JOIN [konkursy].[dbo].[sales_channel_trans_details] s on c.sc = s.sales_channel2 collate Polish_CI_AS and c.rok = s.rok and c.week = s.week_number
		WHERE c.rok = @rok  and  c.week = @ostatni_tydzien
		GROUP BY sc,s.sc_symbol2,week_number,s.rok,c.sort
		ORDER BY c.sort

-----=======  # transactions (ePay) all merchants LightPOS
DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1
		
		SELECT  c.sort,c.sc,
		 l.sales_channel2, l.rok,l.week_number,  ISNULL(qty,0) as qty
		 FROM #channels c
		LEFT JOIN 
		(select sales_channel2,rok,week_number,SUM(qty) as  qty
		FROM
		[konkursy].[dbo].[sales_channel_trans_details] 
		WHERE rok = @rok and week_number = @ostatni_tydzien
				and lightpos = 'lightpos'
		GROUP BY sales_channel2,rok,week_number) as l on l.sales_channel2 = c.sc collate Polish_CI_AS
		ORDER BY sort


----======= Σ value transactions (ePay) all merchants POS & LightPOS
DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1

		SELECT   c.sort,sc,
		 s.sc_symbol2, s.rok,s.week_number, SUM(cast(value as money))/100 AS value
		 FROM #channels c
		LEFT JOIN [konkursy].[dbo].[sales_channel_trans_details] s on c.sc = s.sales_channel2 collate Polish_CI_AS and c.rok = s.rok and c.week = s.week_number
		WHERE c.rok = @rok  and  c.week = @ostatni_tydzien
		GROUP BY sc,s.sc_symbol2,week_number,s.rok,c.sort
		ORDER BY c.sort

-----======= Σ value transactions (ePay) all merchants LightPOS
DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1
		
		SELECT  c.sort,c.sc,
		 l.sales_channel2, l.rok,l.week_number,  ISNULL(value,0) as value
		 FROM #channels c
		LEFT JOIN 
		(select sales_channel2,rok,week_number,SUM(cast(value as money))/100 AS value
		FROM
		[konkursy].[dbo].[sales_channel_trans_details] 
		WHERE rok = @rok and week_number = @ostatni_tydzien
				and lightpos = 'lightpos'
		GROUP BY sales_channel2,rok,week_number) as l on l.sales_channel2 = c.sc collate Polish_CI_AS
		ORDER BY sort

-----===============================================================================
----Σ value (cumulatively) transactions (ePay) generated by POS & LightPOS acquired since the beginning of the year
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
group by td.sales_channel2,td.tr_tvid,td.week_number,td.miesiac,sd.active_date,DATEPART(week,sd.active_date),DATEPART(month,sd.active_date)


select 
c.sort,c.sc,sales_channel2,ISNULL(SUM(val),0) as value 
from #channels c
left join #t1 t on c.sc = t.sales_channel2 collate Polish_CS_AI
group by c.sort,c.sc,sales_channel2
order by c.sort

-----===================================================================================================================================
----- Σ value (cumulatively) transactions (ePay) generated by LightPOS acquired since the beginning of the year
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


select 
c.sort,c.sc,sales_channel2,ISNULL(SUM(val),0) as value 
from #channels c
left join #t1 t on c.sc = t.sales_channel2 collate Polish_CS_AI
group by c.sort,c.sc,sales_channel2
order by c.sort
----===== Σ value transactions (ePay) of last week generated by POS & LightPOS acquired since the beginning of the year
--- transakcje z last week dla POS  pozyskanych w 2021-------------------------
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


select 
c.sort,c.sc,sales_channel2,ISNULL(SUM(val),0) as value 
from #channels c
left join #t2 t on c.sc = t.sales_channel2 collate Polish_CS_AI
group by c.sort,c.sc,sales_channel2
order by c.sort

----===============================================================================================================================================
---- Σ value transactions (ePay) of last week generated by LightPOS acquired since the beginning of the year

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
and td.lightpos='lightpos' and sd.lightpos='lightpos'
group by td.sales_channel2,td.tr_tvid,td.week_number,td.miesiac,sd.active_date,DATEPART(week,sd.active_date),DATEPART(month,sd.active_date)


select 
c.sort,c.sc,sales_channel2,ISNULL(SUM(val),0) as value 
from #channels c
left join #t2 t on c.sc = t.sales_channel2 collate Polish_CS_AI
group by c.sort,c.sc,sales_channel2
order by c.sort

----==============================================================================================================================================
---- Σ value transactions (ePay) of last week generated by POS & LightPOS acquired in previous month
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

if object_id (N'tempdb..#t3_2')  is not null drop table #t3_2
select tr_tvid,SUM(cast(td.value as money))/100 as val
into #t3_2
from [konkursy].[dbo].[sales_channel_trans_details] td
where td.week_number=@ostatni_tydzien and 
td.rok>=@rok
group by tr_tvid

select 
c.sort,c.sc,sales_channel2,ISNULL(SUM(val),0) as value 
from #channels c
left join #t3_1 t on c.sc = t.sales_channel2 collate Polish_CS_AI
left join #t3_2 on tr_tvid=t_vid Collate Polish_CS_AI
group by c.sort,c.sc,t.sales_channel2
order by c.sort
----==============================================================================================================================================
---- Σ value transactions (ePay) of last week generated by LightPOS acquired in previous month
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

if object_id (N'tempdb..#t3_2')  is not null drop table #t3_2
select tr_tvid,SUM(cast(td.value as money))/100 as val
into #t3_2
from [konkursy].[dbo].[sales_channel_trans_details] td
where td.week_number=@ostatni_tydzien and 
td.rok>=@rok
and lightpos = 'lightpos'
group by tr_tvid

select 
c.sort,c.sc,sales_channel2,ISNULL(SUM(val),0) as value 
from #channels c
left join #t3_1 t on c.sc = t.sales_channel2 collate Polish_CS_AI
left join #t3_2 on tr_tvid=t_vid Collate Polish_CS_AI
group by c.sort,c.sc,t.sales_channel2
order by c.sort
----==============================================================================================================================================
---- AVG turnover/POS & LightPOS (ePay)  for all merchants
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


select 
c.sort,c.sc,a.sales_channel2,a.week_number,a.rok ,
SUM(value)/SUM(POS)  as avg_turnover
from 
#channels c 
left join #av a on c.sc = a.sales_channel2 collate Polish_CS_AI and c.week = a.week_number and c.rok = a.rok
group by c.sort,c.sc,a.sales_channel2,a.week_number,a.rok 
order by c.sort
----==============================================================================================================================================
---- AVG turnover/ LightPOS (ePay)  for all merchants
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
and lightpos = 'lightpos'
group by sales_channel2,sc_symbol2,week_number,rok


select 
c.sort,c.sc,a.sales_channel2,a.week_number,a.rok ,
ISNULL(SUM(value)/SUM(POS),0)  as avg_turnover
from 
#channels c 
left join #av a on c.sc = a.sales_channel2 collate Polish_CS_AI and c.week = a.week_number and c.rok = a.rok
group by c.sort,c.sc,a.sales_channel2,a.week_number,a.rok 
order by c.sort
----==============================================================================================================================================
---- AVG time (days) between activation date and first transaction POS & LightPOS
DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1

select  
 c.sort,c.sc,sales_channel2,d.rok,
week_number, 
AVG(cast(days_diff as money)) as AVG_days_first_transaction
--count(*) - count(days_diff) as number_of_null,
--count(days_diff) as number_of_tvid_transaction
FROM 
#channels c
LEFT JOIN [konkursy].[dbo].[sales_channel_details] d on c.sc = d.sales_channel2 collate Polish_CS_AI and c.rok = d.rok and c.week = d.week_number
where c.rok>=@rok and c.week=@ostatni_tydzien
group by  c.sort,c.sc,sales_channel2,d.rok,
week_number
order by c.sort
----==============================================================================================================================================
---- AVG time (days) between activation date and first transaction  LightPOS
DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1

select  
 c.sort,c.sc,sales_channel2,d.rok,
d.week_number, 
 AVG_days_first_transaction
--count(*) - count(days_diff) as number_of_null,
--count(days_diff) as number_of_tvid_transaction
FROM 
#channels c
LEFT JOIN ( SELECT rok,week_number,sales_channel2,AVG(cast(days_diff as money)) as AVG_days_first_transaction
from [konkursy].[dbo].[sales_channel_details] 
where rok=@rok and week_number=@ostatni_tydzien and lightpos='lightpos'
group by rok,week_number,sales_channel2) as d on  d.sales_channel2 = c.sc collate Polish_CI_AS
order by c.sort
----==============================================================================================================================================
---- # POS & LightPOS with transactions according to week of activation
DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1

select  
 c.sort,c.sc,sales_channel2,d.rok,
week_number, 
--AVG(cast(days_diff as money)) as AVG_days_first_transaction,
--count(*) - count(days_diff) as number_of_null,
count(days_diff) as number_of_tvid_transaction
FROM 
#channels c
LEFT JOIN [konkursy].[dbo].[sales_channel_details] d on c.sc = d.sales_channel2 collate Polish_CS_AI and c.rok = d.rok and c.week = d.week_number
where c.rok>=@rok and c.week=@ostatni_tydzien
group by  c.sort,c.sc,sales_channel2,d.rok,
week_number
order by c.sort
----==============================================================================================================================================
---- #LightPOS with transactions according to week of activation

DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1

select  
 c.sort,c.sc,sales_channel2,d.rok,
d.week_number, 
-- AVG_days_first_transaction
--count(*) - count(days_diff) as number_of_null,
 number_of_tvid_transaction
FROM 
#channels c
LEFT JOIN ( SELECT rok,week_number,sales_channel2,count(days_diff) as number_of_tvid_transaction
from [konkursy].[dbo].[sales_channel_details] 
where rok=@rok and week_number=@ostatni_tydzien and lightpos='lightpos'
group by rok,week_number,sales_channel2) as d on  d.sales_channel2 = c.sc collate Polish_CI_AS
order by c.sort


-----------============= POWERBI 
--                       1st trx
---- # POS & LightPOS with transactions according to week of activation
DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1

select  
 c.sort,c.sc,d.sc_symbol2,week_number,
AVG(cast(days_diff as money)) as AVG_days_first_transaction,
count(*) - count(days_diff) as number_of_null,
count(days_diff) as number_of_tvid_transaction,d.rok
FROM 
#channels c
LEFT JOIN [konkursy].[dbo].[sales_channel_details] d on c.sc = d.sales_channel2 collate Polish_CS_AI and c.rok = d.rok and c.week = d.week_number
where c.rok>=@rok and c.week=@ostatni_tydzien and d.rok is not null
group by  c.sort,c.sc,d.rok,
week_number,d.sc_symbol2
order by c.sort

----===========PWOERBI ======================POWERBI=============================================================================================================
---- AVG turnover/POS & LightPOS (ePay)  for all merchants
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


select 
SUM(POS) as pos,
a.sales_channel2,
a.sc_symbol2,
SUM(value) as val,
a.week_number,a.rok
from 
#channels c 
left join #av a on c.sc = a.sales_channel2 collate Polish_CS_AI and c.week = a.week_number and c.rok = a.rok
group by a.sales_channel2,
a.sc_symbol2,a.week_number,a.rok

------CONTRACT
DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1
		SELECT  c.sort,sc,
		 s.sc_symbol2,s.week_number, COUNT(distinct contract_id) AS contract,s.rok
		 FROM #channels c
		LEFT JOIN  [konkursy].[dbo].[sales_channel_details] s on sc = sales_channel2 collate Polish_CS_AI and c.rok =  s.rok and c.week = s.week_number
		WHERE c.rok = @rok  and  c.week = @ostatni_tydzien
		and s.rok is not null
		GROUP BY sc,s.sc_symbol2,week_number,s.rok,c.sort
		ORDER BY c.sort


		-----POS

DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1
		SELECT  c.sort,sc,
		 s.sc_symbol2,s.week_number,COUNT(distinct t_vid) AS POS, s.rok
		 FROM #channels c
		LEFT JOIN  [konkursy].[dbo].[sales_channel_details] s on sc = sales_channel2 collate Polish_CS_AI and c.rok =  s.rok and c.week = s.week_number
		WHERE c.rok = @rok  and  c.week = @ostatni_tydzien and s.rok is not null
		GROUP BY sc,s.sc_symbol2,week_number,s.rok,c.sort
		ORDER BY c.sort



		----QTY


DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1

		SELECT   c.sort,sc,
		 s.sc_symbol2, SUM(qty) AS qty,s.week_number,s.rok
		 FROM #channels c
		LEFT JOIN [konkursy].[dbo].[sales_channel_trans_details] s on c.sc = s.sales_channel2 collate Polish_CI_AS and c.rok = s.rok and c.week = s.week_number
		WHERE c.rok = @rok  and  c.week = @ostatni_tydzien and s.rok is not null
		GROUP BY sc,s.sc_symbol2,week_number,s.rok,c.sort
		ORDER BY c.sort



		-----VALUE
DECLARE @ostatni_tydzien AS int
DECLARE @rok AS int
SET @rok = YEAR(DATEADD(ww, -1,getdate()))
SET @ostatni_tydzien = datename(ww, getdate())-1

		SELECt sc,
		 s.sc_symbol2, SUM(cast(value as money))/100 AS value,s.week_number,s.rok
		 FROM #channels c
		LEFT JOIN [konkursy].[dbo].[sales_channel_trans_details] s on c.sc = s.sales_channel2 collate Polish_CI_AS and c.rok = s.rok and c.week = s.week_number
		WHERE c.rok = @rok  and  c.week = @ostatni_tydzien
		GROUP BY sc,s.sc_symbol2,week_number,s.rok,c.sort
		ORDER BY c.sort
