CREATE DATABASE IF NOT EXISTS ess11;

Use ess11;

CREATE TABLE ess
(
name Varchar(255),
essround int,
edition int,
proddate date,
idno int,
cntry varchar(3),
nwspol int,
netusoft int,
netustm int,
ppltrst int,
pplfair int,
pplhlp int,
polintr int,
psppsgva int,
actrolga int,
psppipla int,
cptppola int,
trstprl int,
trstlgl int,
trstplc int,
trstplt int,
trstprt int,
trstep int,
trstun int,
vote int,
contplt int,
donprty int,
badge int,
sgnptit int,
pbldmna int,
bctprd int,
pstplonl int,
volunfp int,
clsprty int,
prtdgcl int,
lrscale int,
stflife int,
stfeco int,
stfgov int,
stfdem int,
stfedu int,
stfhlth int,
gincdif int,
freehms int,
hmsfmlsh int,
hmsacld int,
euftf int,
lrnobed int,
loylead int,
imsmetn int,
imdfetn int,
impcntr int,
imbgeco int,
imueclt int,
imwbcnt int,
happy int,
gndr int
);

select * from ess;

-- Load csv 'infile' for faster importing

LOAD DATA INFILE 'ess11.csv' INTO TABLE ess
FIELDS TERMINATED BY ','
lines terminated by '\n'
IGNORE 1 LINES;

SELECT * from ess;

-- Check if there are any missing gender values

select count(gndr)
from ess 
where gndr != 1 and gndr != 2
;

-- Number of people on each country that were interviewed and gender distribution (Table 1)
select cntry country, count(cntry) 'number of participants per country',
	 sum(case when gndr = 1 then 1 else 0 end) as male,
     sum(case when gndr = 2 then 1 else 0 end) as female,
     sum(case when gndr = 9 then 1 else 0 end) as no_answer
from ess
group by cntry
order  by cntry ASC
;

-- Check average of happiness in each country, based on political leaning and gender (Table 2, 3 and 4)

select cntry country, round(avg(happy),2) as avg_happy
from ess
where happy <= 10
group by cntry
order by avg_happy DESC
;

select lrscale left_leaning_scale, round(avg(happy),2) as avg_happy
from ess
where happy <= 10 and lrscale <= 10
group by lrscale
order by lrscale DESC
;

select gndr gender, round(avg(happy),2) as avg_happy
from ess
where happy <= 10 and gndr < 3
group by gender
order by gender DESC
;

-- Check for average time of use of the internet and happiness (Table 5)

select
    (FLOOR(netustm/30)+1)*30 as internet_use,
    avg(happy) avg_happy
from ess
where happy <=10 and netustm not in (6666, 7777, 8888, 9999)
group by internet_use
having COUNT(*) > 10
order by internet_use desc
;
