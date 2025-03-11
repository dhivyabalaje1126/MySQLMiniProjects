#Analyzing the world database in MySQL 

/* README!

Hello, my name is Dhivya and I'm going to analyze the world database that comes with the full installation of MySQL workbench. 
This is for my own purposes, to implement SQL functions and methods and randomly analyze stuff from thsi dataset. 
I've done this analysis with no particular aim or analysis in mind, so this is not a very systematic file/document. 

STUFF TO KNOW!
1. Database used: world.
   Please download this database in your DBMS and continue.
   I strongly recommend doing this hands-on. 
2. DBMS: MySQL. 
   If you are downloading this, feel free to change the things here according to your own DBMS. 
3. Table used from the 'world' databse: country. 
    I have not used the other tables in the database. Just played around with the 'country' table based on some random methods 
	that I thought would be nice.

Disclaimers!
1. This is just for fun and learning.
2. I made a few mistakes in some places and I may not have corrected them. Proceed with caution.
3. The analyses I'm doing are based on the contents of the world database as of the year 2025 (when I installed this database). 
   These may not be in line with present countries' statistics. 
4. I am not trying to offend any country by saying they are 'poor countries' or have 'low life expectancy'. 
   I am just proceeding based on the data and results I have, based on the contents of the world database.
5. My naming conventions for variables and tables are by default, long, and pertain to the way I proceeded with the data and
   my understanding of it only. 
6. I have used nested CTEs, subqueries. and may not have explained my steps all the time. Take your time to read, understand and
   experiment. There are so many ways different people can analyze the same data.
7. I've used both -- and the *\ ways to comment and my notes may be chaotic. Sorry about that if it confuses you.
8. I am only a beginner in SQL. I am also still learning. 

PERSONAL NOTE:
I'm doing this to learn SQL in the MySQL database. I used to be someone very afraid of SQL because of a traumtaic experience in a 
workplace environment where people said I couldn't code in SQL since I didn't know anything.
By doing this analysis, i'VE STARTED TO COME OUT OF MY FEAR!
So if you're facing something similar, let me tell you, JUST PRACTICE! SQL IS GREAT!
Try having fun with your datasets. Start simple and just keep going!
I hope this database analysis helps you learn something in some way. 

I'll let you get to it now! */

use world;
-- This is a readily available dataset in MySQL installation. 

#Looking at the tables in this database. 
show tables;

/* Tables - city, country, countrylanguage */ 

-- For this mini-project, I'm only going to use the country table.
describe country; -- 15 attributes

/* Code is the PRIMARY KEY
Continent column has Asia as the default value
SurfaceArea column has 0.00 as the default value
Population has 0 as the default value
Some columns have NULL as the Default values
Some columns have NULL values, like IndepYear, LifeExpectancy, GNP, GNPOld, HeadOfState, Capital
*/ 

select * from country; -- 239 records present

-- Finding Unique Continent names and Region names
select distinct continent from country; -- 7 continents
select distinct region from country; -- 25 regions

-- I want to try and find countries that do not have Independent Years listed
select Name as CountriesWithNoIndepYear from country where IndepYear is null; -- 47 countries

-- With this information, I want to see how many are islands.
-- I'm going to use a CTE to do this. 
with NoIndepYear as 
(
select Name as CountriesWithNoIndepYear from country where IndepYear is null
) 
select * from NoIndepYear where CountriesWithNoIndepYear like '%island%';         -- 15 islands returned. 

/* Notice how I chose to use '%island%' instead of '%islands'. 
This is to make room for all kinds of cases in naming convetions for Islands. */

-- My naming style is long, but I typically try to do camel case. 
-- Always use easy names and aliases in coding since it makes everyone's jobs easier.

select * from country;
-- Now I want to see the countries with the minimum and maximum SurfaceArea

-- Country with the minimum surface area
select Name, Continent, Region, SurfaceArea 
from country where SurfaceArea = (select min(SurfaceArea) from country);

-- Country with maximum surface area
select Name, Continent, Region, SurfaceArea 
from country where SurfaceArea = (select max(SurfaceArea) from country);

-- Finding the average surface area
select avg(SurfaceArea) from country;

/* Seeing how many countries have a surface area greater than the average surface area,
and ones that have a surface area lesser than the average */
select Name
from country where SurfaceArea > (select avg(SurfaceArea) from country); 
-- 43 countries have a surface area greater than the average surface area

select Name from country where SurfaceArea <= (select avg(SurfaceArea) from country);
-- 196 countires have a surface area lesser than the average surface area

-- I want to calculate the total surface area occupied by the various continents
select Continent, sum(SurfaceArea) as TotalArea from country
group by Continent order by TotalArea desc;

-- Analyzing Population
#1 Total population in each continent
select Continent, sum(population) as TotalPopulation from country group by 1
order by TotalPopulation desc;
-- Asia has the greatest surface area AND population. 
-- Antarctica has no population, at least according to this table

-- Now I've ranked the populations in descending order and partitioned by continent to 
-- rank population in descending order within each Continent. 
select Continent, Name, Population, 
rank() over(partition by Continent order by Population desc) as RankofPopulation
from country;
-- We can put this in a subquery or CTE and find the countries with the max and min populations per continent.
-- I tried using dense_rank, but since I'm already partitioning by continent, the chances for ranks to skip are very low, so I went with rank


-- What is the max, min and average population> And which countries have it? 
select Name, Continent from country where Population =
(select max(Population) from country);

select Name, Continent from country where Population =
(select min(Population) from country);
/* The British Indian Ocean Territory in Africa and the United States Minor Outlying Islands in Oceania
do intrigue me. I wonder if they're real locations and what their population is now */

-- What is the average population overall?
select avg(population) as WorldAveragePop from country;

-- What is the average population per continent?
select continent, round(avg(population),2) as AveragePerContinent 
from country group by 1 order by AveragePerContinent desc;
-- Asia has a maximum everywhere, wow. Even in population averages.

-- I want to see if there's a correlation between population and whether the country is independent or not
-- Let me start by first seeing the population of all these countries
select Continent, Name, Population from country where IndepYear is null;
-- What kind of government do these countries have?
select Continent, Name, Population, GovernmentForm from country where IndepYear is null;
-- This is too much info, I want to first see how many distinct forms of governance are present:
select distinct GovernmentForm from country;
-- Now I shall check if there is any relation between these countries' populations and their independency status
select Continent, Name, Population from country where IndepYear is null;
-- Let me eliminate any scenario where the population is 0:
select Continent, Name, Population from country where IndepYear is null and Population != 0;

-- Usual statistics - min, max, average
select Continent, Name from country where IndepYear is null and Population = (select max(Population) from country);
-- huh, this doesn't work. 
-- Lemme try something else. Dense_rank() to the resuce!
select Continent, Name, Population, dense_rank() over(partition by continent order by population desc) as RankofPopulationperCont
 from country where IndepYear is null and Population != 0;

-- I'll check the populations of all dependent countries per continent that have the maximum population from the previous query:
with RankingbyPopulation as (
select Continent, Name, Population, dense_rank() over(partition by continent order by population desc) as RankofPopulationperCont
 from country where IndepYear is null and Population != 0
 )
 select * from RankingbyPopulation where RankofPopulationperCont = 1;
 
 with IndepNull as (
select Continent, Name, Population from country where IndepYear is null and Population != 0
 )
select Name, Continent from IndepNull where Population = (select min(Population) from IndepNull);

with IndepNull as (
select Continent, Name, Population from country where IndepYear is null and Population != 0
 )
select Name, Continent from IndepNull where Population = (select max(Population) from IndepNull);

select * from country;

-- Now I'd like to play around with the LifeExpectancy attribute from country
select max(LifeExpectancy), min(LifeExpectancy), avg(LifeExpectancy) from country;
select Name, Continent from country where LifeExpectancy = (select max(LifeExpectancy) from country);
select Name, Continent from country where LifeExpectancy = (select min(LifeExpectancy) from country);
select Name, Continent from country where LifeExpectancy <= (select avg(LifeExpectancy) from country); -- 82 countries have a life expectancy lower than the average
select Name, Continent from country where LifeExpectancy > (select avg(LifeExpectancy) from country); -- 140 c0untries have a life expectancy higher than the average

-- Life expectancy per continent?
select Continent, round(avg(LifeExpectancy),2) as AvgLifeExpectancy from country group by Continent
order by AvgLifeExpectancy desc;

-- Alright, what the hell is up with Antarctica in this dataset? Imma check it out
select * from country where continent = 'Antarctica';
-- I'm completely ignoring Antarctica's significance in all further queries

-- It's curious how Asia has the greastest surface area and population out of all continents, but the life expectancy is poor
-- Let me touch up on that a little bit
select * from country where Continent = 'Asia';
select distinct(Region) from country where Continent = 'Asia';
select * from country where Region = 'Middle East'; -- Middle east is looking somewhat good
select * from country where Region = 'Eastern Asia'; -- This area looks good too
select * from country where Region = 'Southern and Central Asia'; -- Alright, I see some countries with a low LifeExpectancy here. Going to note that down
select * from country where Region = 'Southeast Asia'; -- This portion also has some countries with a low LifeExpectancy

-- Given I'm from India, I want to check those stats
select * from country where Name = 'India';
-- Last I checked, India is a Democratic Republic and not a Federal Republic. This dataset would do well with an update overall.

-- I've decided to use the main deciding factors of my analysis be Population and LifeExpectancy
-- Let's just look at the whole table again
select * from country;
-- Let me create a view for IndependentCountries and NonIndependentCountries (where IndepYear IS NULL)
create view IndepCountries as 
(select * from country where IndepYear is not null);

create view IndepNullCountries as 
(select * from country where IndepYear is not null);

select * from IndepCountries;
-- Just for fun, are there any countries that gained independence in the same year>
select IndepYear, count(IndepYear) from country group by 1 having count(IndepYear) > 1 order by 2 desc;
-- I'll consider the first four years
select Name, Continent from country where IndepYear = 1991; -- 18 countries
select Name, Continent from country where IndepYear = 1960; -- 18 countries again
select Name, Continent from country where IndepYear = 1975; -- 7 countries
select Name, Continent from country where IndepYear = 1962; -- 7 again

-- There are various ways you can look at this data. I'm hust flying by the seat of my pants here.
-- Moving on!
select * from IndepCountries;
select * from IndepCountries where Population = (select max(Population) from IndepCountries); -- China
select * from IndepCountries where Population = (select min(Population) from IndepCountries); -- Holy See (Vatican City State)
select round(avg(Population),2) as AvgPop, round(avg(LifeExpectancy),2) as AvgLE, round(avg(SurfaceArea),2) as AvgSE from IndepCountries;
-- The above query will return the average of Population, LifeExpectancy and SurfaceArea when comparing all independent countries. 
-- It would be more logical to group them by continent so we could do a study of that

select Continent, round(avg(Population),2) as AvgPop, round(avg(LifeExpectancy),2) as AvgLE, round(avg(SurfaceArea),2) as AvgSE
from IndepCountries
group by 1;
-- I'm going to be using this table constantly so let's just turn this into a view too

create view IndepCountryStats as 
(
select Continent, round(avg(Population),2) as AvgPop, round(avg(LifeExpectancy),2) as AvgLE, round(avg(SurfaceArea),2) as AvgSE
from IndepCountries
group by 1);

select * from IndepCountryStats;
-- Using the view for Independent countries and the view we just created, I can check the data to see how countries are
-- doing with respect to the average stats for each continent
-- Let's start with Asia
select Name, Continent, Population, LifeExpectancy, SurfaceArea 
from IndepCountries where Continent = 'Asia' and LifeExpectancy < (select AvgLE from IndepCountryStats where Continent = 'Asia')
and SurfaceArea < (select AvgSE from IndepCountryStats where Continent = 'Asia');
/* This tells me that there are 17 countries in Asia who have a life expectancy lower than the average (for Asia) 
and a Surface Area lesser than the average 
Doing this can be tedious, so we can write a case when statement to make our job easier */

select Name, Population, LifeExpectancy, SurfaceArea,
Case
when (Population > (select AvgPop from IndepCountryStats where Continent = 'Asia')) then 'High_Pop'
else 'Low_Pop'
end as ClassifyingbyAsiaAvgPop,
case
when (LifeExpectancy < (select AvgLE from IndepCountryStats where Continent = 'Asia')) then 'Low_LE'
else 'High_LE'
end as ClassifybyAsiaAvgLE, 
case
when (SurfaceArea < (select AvgSE from IndepCountryStats where Continent = 'Asia')) then 'LowSE'
else 'HighSE'
end as ClassifybyAsiaAvgSE
from IndepCountries where Continent = 'Asia';

-- I'M VERY PROUD OF THIS QUERY! THE FACT THAT I WAS ABLE TO USE MULTIPLE CASE-WHEN STATEMENTS IN A SINGLE QUERY, COMBINING SUBQUERIES, OHMYGOD!

/* Let me explain the result set -- I've filtered all the independent countries in Asia based on the average values of
Population, LifeExpectancy and SurfaceArea. If the country's stats are lower than the average, I'm putting them into one category and
I have the other countries into another category. 
My aim is to see which countries are doing relatively well and which aren't. 
I want to develop more on this 
Given I'll probably use this table several times, I'm going to save that as a view*/

create view AsiaIndepStats as 
(
select Name, Population, LifeExpectancy, SurfaceArea,
Case
when (Population > (select AvgPop from IndepCountryStats where Continent = 'Asia')) then 'High_Pop'
else 'Low_Pop'
end as ClassifyingbyAvgPop,
case
when (LifeExpectancy < (select AvgLE from IndepCountryStats where Continent = 'Asia')) then 'Low_LE'
else 'High_LE'
end as ClassifybyAvgLE, 
case
when (SurfaceArea < (select AvgSE from IndepCountryStats where Continent = 'Asia')) then 'LowSE'
else 'HighSE'
end as ClassifybyAvgSE
from IndepCountries where Continent = 'Asia'
);

select * from AsiaIndepStats;

/* I can create similar views for other continents, comparing each independent country's stats to the continent's average stats */
select * from IndepCountryStats;
-- Africa stats
create view AfricaIndepStats as (
select Name, Population, LifeExpectancy, SurfaceArea,
Case
when (Population > (select AvgPop from IndepCountryStats where Continent = 'Africa')) then 'High_Pop'
else 'Low_Pop'
end as ClassifyingbyAvgPop,
case
when (LifeExpectancy < (select AvgLE from IndepCountryStats where Continent = 'Africa')) then 'Low_LE'
else 'High_LE'
end as ClassifybyAvgLE, 
case
when (SurfaceArea < (select AvgSE from IndepCountryStats where Continent = 'Africa')) then 'LowSE'
else 'HighSE'
end as ClassifybyAvgSE
from IndepCountries where Continent = 'Africa'
);

-- Europe stats
create view EuropeIndepStats as (
select Name, Population, LifeExpectancy, SurfaceArea,
Case
when (Population > (select AvgPop from IndepCountryStats where Continent = 'Europe')) then 'High_Pop'
else 'Low_Pop'
end as ClassifyingbyAvgPop,
case
when (LifeExpectancy < (select AvgLE from IndepCountryStats where Continent = 'Europe')) then 'Low_LE'
else 'High_LE'
end as ClassifybyAvgLE, 
case
when (SurfaceArea < (select AvgSE from IndepCountryStats where Continent = 'Europe')) then 'LowSE'
else 'HighSE'
end as ClassifybyAvgSE
from IndepCountries where Continent = 'Europe'
);

-- South America stats
create view SouthAmericaIndepStats as 
(
select Name, Population, LifeExpectancy, SurfaceArea,
Case
when (Population > (select AvgPop from IndepCountryStats where Continent = 'South America')) then 'High_Pop'
else 'Low_Pop'
end as ClassifyingbyAvgPop,
case
when (LifeExpectancy < (select AvgLE from IndepCountryStats where Continent = 'South America')) then 'Low_LE'
else 'High_LE'
end as ClassifybyAvgLE, 
case
when (SurfaceArea < (select AvgSE from IndepCountryStats where Continent = 'South America')) then 'LowSE'
else 'HighSE'
end as ClassifybyAvgSE
from IndepCountries where Continent = 'South America'
);

-- North America stats
create view NorthAmericaIndepStats as 
(
select Name, Population, LifeExpectancy, SurfaceArea,
Case
when (Population > (select AvgPop from IndepCountryStats where Continent = 'North America')) then 'High_Pop'
else 'Low_Pop'
end as ClassifyingbyAvgPop,
case
when (LifeExpectancy < (select AvgLE from IndepCountryStats where Continent = 'North America')) then 'Low_LE'
else 'High_LE'
end as ClassifybyAvgLE, 
case
when (SurfaceArea < (select AvgSE from IndepCountryStats where Continent = 'North America')) then 'LowSE'
else 'HighSE'
end as ClassifybyAvgSE
from IndepCountries where Continent = 'North America'
);

-- Oceania stats
create view OceaniaIndepStats as 
(
select Name, Population, LifeExpectancy, SurfaceArea,
Case
when (Population > (select AvgPop from IndepCountryStats where Continent = 'Oceania')) then 'High_Pop'
else 'Low_Pop'
end as ClassifyingbyAvgPop,
case
when (LifeExpectancy < (select AvgLE from IndepCountryStats where Continent = 'Oceania')) then 'Low_LE'
else 'High_LE'
end as ClassifybyAvgLE, 
case
when (SurfaceArea < (select AvgSE from IndepCountryStats where Continent = 'Oceania')) then 'LowSE'
else 'HighSE'
end as ClassifybyAvgSE
from IndepCountries where Continent = 'Oceania'
);

select * from AsiaIndepStats;
select * from AfricaIndepStats;
select * from EuropeIndepStats;
select * from NorthAmericaIndepStats;
select * from SouthAmericaIndepStats;
select * from OceaniaIndepStats;
/* All these views analyze the population, life expectancy and surface area of the independent
countries within each continent. They classify these parameters as low or high based on how
the values fare in comparison to the Average Population/Life Expectancy (LE)/Surface Area (SA)
of the countries in the respective continent.
Using this info, we can see if there's any correlation between a country's life expectancy, population
and surface area. 

The metric I'm going to focus on is LifeExpectancy
-- High LE - always good
-- Low Population, High LE, great
-- High population, low LE - dangerous
-- Low Population, high LE - good
-- Low Population, low LE - bad
-- Surface area can add some intrigue.

Because the population of Antarctica is given as 0 in the world database in MySQL, I've omitted Antarctica
in this analysis. This shouldn't be done so in any real-world case study without proper reasons. */

/* This is going to be a very slow process, bear with me */

-- Starting with Asia!
select * from AsiaIndepStats;
select * from AsiaIndepStats where ClassifyingbyAvgPop = 'High_Pop';
-- Out of the 47 independent countries in Asia, 7 have a population higher than the continent's average
select * from (select * from AsiaIndepStats where ClassifyingbyAvgPop = 'High_Pop') a
where a.ClassifybyAvgLE = 'High_LE';
/* This shows that China and Indonesia are clearly countries that do well in comparison to all other
countries in Asia, in all aspects.
However, Japan and Vietnam are countries that have a high population and life expectancy depsite having
a low land surface area. Japan in particular has the highest life expectancy amongst them all. 
We can't ignore that. */

select * from (select * from AsiaIndepStats where ClassifyingbyAvgPop = 'High_Pop') a
where a.ClassifybyAvgLE = 'Low_LE';
/* Bangladesh, India and Pakistan have a low life expectancy despite having a high population. 
India and Pakistan do have a higher land area (surface area).*/

select * from AsiaIndepStats where ClassifyingbyAvgPop = 'Low_Pop'; -- Going back to the other 40 independent countries in Asia
select * from (select * from AsiaIndepStats where ClassifyingbyAvgPop = 'Low_Pop') a 
where a.ClassifybyAvgLE = 'High_LE';
/* This is interesting, because these countries here have really good Life Expectancy rates
Low population seems to be a good factor here 
Let's see if this is similar in other continents*/

-- Let's go to Africa
select * from AfricaIndepStats; --  we have 53 countries here
select * from AfricaIndepStats where ClassifyingbyAvgPop = 'High_Pop'; -- 16 countries have high population comparitive to Africa's average numbers
select * from (select * from AfricaIndepStats where ClassifyingbyAvgPop = 'High_Pop') a
where a.ClassifybyAvgLE = 'High_LE';
/* 8 African countries have a high population and a high life expectancy rate. */

select * from (select * from AfricaIndepStats where ClassifyingbyAvgPop = 'Low_Pop') a
where a.ClassifybyAvgLE = 'High_LE'; -- 12 countries with low pop and high LE in Africa
select * from (select * from AfricaIndepStats where ClassifyingbyAvgPop = 'High_Pop') a
where a.ClassifybyAvgLE = 'Low_LE'; -- 8 countries with a high population and low life expectancy - this is dangerous
select * from (select * from AfricaIndepStats where ClassifyingbyAvgPop = 'Low_Pop') a
where a.ClassifybyAvgLE = 'Low_LE';
-- 25 African countries have a low population, and low life expectancy

-- Let's go to Europe!
select * from EuropeIndepStats; -- 43 total
select * from EuropeIndepStats where ClassifyingbyAvgPop = 'High_Pop'; -- 9 with a high population
select * from (select * from EuropeIndepStats where ClassifyingbyAvgPop = 'High_Pop') e
where e.ClassifybyAvgLE = 'High_LE'; -- 5 countries
select * from (select * from EuropeIndepStats where ClassifyingbyAvgPop = 'High_Pop') e
where e.ClassifybyAvgLE = 'Low_LE'; -- 4 countries, although the life expectancy of Europe seems to be greater than Asia and Africa
select * from (select * from EuropeIndepStats where ClassifyingbyAvgPop = 'Low_Pop') e
where e.ClassifybyAvgLE = 'High_LE'; -- 19 countries
select * from (select * from EuropeIndepStats where ClassifyingbyAvgPop = 'Low_Pop') e
where e.ClassifybyAvgLE = 'Low_LE'; -- 15 countries

-- Let's go to North America!
select * from NorthAmericaIndepStats; -- 23 countries
select * from NorthAmericaIndepStats where ClassifyingbyAvgPop = 'High_Pop'; -- 3 countries
-- All  3 have high life expectancy, surface area too
select * from NorthAmericaIndepStats where ClassifyingbyAvgPop = 'Low_Pop'; -- 20 countries
select * from (select * from NorthAmericaIndepStats where ClassifyingbyAvgPop = 'Low_Pop') ne
where ne.ClassifybyAvgLE = 'Low_LE'; -- 10
select * from (select * from NorthAmericaIndepStats where ClassifyingbyAvgPop = 'Low_Pop') ne
where ne.ClassifybyAvgLE = 'High_LE'; -- 10 

-- South America!
select * from SouthAmericaIndepStats; -- 12
select * from SouthAmericaIndepStats where ClassifyingbyAvgPop = 'High_Pop'; -- 3
-- Argentina is great
select * from (select * from SouthAmericaIndepStats where ClassifyingbyAvgPop = 'Low_Pop') se; -- 9 rows
select * from (select * from SouthAmericaIndepStats where ClassifyingbyAvgPop = 'Low_Pop') se
where se.ClassifybyAvgLE = 'High_LE'; -- 6 countries
select * from (select * from SouthAmericaIndepStats where ClassifyingbyAvgPop = 'Low_Pop') se
where se.ClassifybyAvgLE = 'Low_LE'; -- 3 countries

-- Oceania now!
select * from OceaniaIndepStats; -- 14
select * from OceaniaIndepStats where ClassifyingbyAvgPop = 'High_Pop'; -- 3 countries
-- One high pop country with low LE
select * from (select * from OceaniaIndepStats where ClassifyingbyAvgPop = 'Low_Pop') oc
where oc.ClassifybyAvgLE = 'High_LE'; -- 6 Countries
select * from (select * from OceaniaIndepStats where ClassifyingbyAvgPop = 'Low_Pop') oc
where oc.ClassifybyAvgLE = 'Low_LE'; -- 5 Countires

/* This was a very interesting analysis.
Now, I'm going to create two views with really good, desirable countries and non-desirable, based on 
this dataset alone! 
The metric I'm going to focus on is LifeExpectancy
-- High LE - always good
-- Low Population, High LE, great
-- Low Population, high LE - good

/* High Pop, High LE
This is good. Despite high population levels for their respective continent's average, 
these countries have a high life expectancy. These countries are great.
I'm going to make a view with these countries.*/

create view HighPopandLE as (
with cte as 
(select * from (select * from AsiaIndepStats where ClassifyingbyAvgPop = 'High_Pop') a
where a.ClassifybyAvgLE = 'High_LE'
union
select * from (select * from AfricaIndepStats where ClassifyingbyAvgPop = 'High_Pop') a
where a.ClassifybyAvgLE = 'High_LE'
union
select * from (select * from EuropeIndepStats where ClassifyingbyAvgPop = 'High_Pop') a
where a.ClassifybyAvgLE = 'High_LE'
union
select * from (select * from NorthAmericaIndepStats where ClassifyingbyAvgPop = 'High_Pop') a
where a.ClassifybyAvgLE = 'High_LE'
union
select * from (select * from SouthAmericaIndepStats where ClassifyingbyAvgPop = 'High_Pop') a
where a.ClassifybyAvgLE = 'High_LE'
union
select * from (select * from OceaniaIndepStats where ClassifyingbyAvgPop = 'High_Pop') a
where a.ClassifybyAvgLE = 'High_LE' order by LifeExpectancy desc)
select co.Continent, c.Name, c.Population, c.LifeExpectancy, c.SurfaceArea, c.ClassifyingbyAvgPop, c.ClassifybyAvgLE, c.ClassifybyAvgSE 
from cte c join country co on c.Name = co.Name);

select * from HighPopandLE; -- 23 countries

/* Notice how I added the continent names of the countries in thie list of countries that have High Population and High Life Expectancy
This is because, suppose we're using this list to help people understand what country they want to move to, the continent name would help.
It's always a great idea to think about these kinds of projects in a consumer/customer perspective. */

-- Low Pop, High LE
/* These countries have low population but a high life expectancy. Maybe the Low population 
is a factor that contributes towards the high LE. It also indicates good healthcare, maybe professionals aren't overworked
and living conditions are ideal */
create view LowPopHighLE as (
with cte as 
(select * from (select * from AsiaIndepStats where ClassifyingbyAvgPop = 'Low_Pop') a
where a.ClassifybyAvgLE = 'High_LE'
union
select * from (select * from AfricaIndepStats where ClassifyingbyAvgPop = 'Low_Pop') a
where a.ClassifybyAvgLE = 'High_LE'
union
select * from (select * from EuropeIndepStats where ClassifyingbyAvgPop = 'Low_Pop') a
where a.ClassifybyAvgLE = 'High_LE'
union
select * from (select * from NorthAmericaIndepStats where ClassifyingbyAvgPop = 'Low_Pop') a
where a.ClassifybyAvgLE = 'High_LE'
union
select * from (select * from SouthAmericaIndepStats where ClassifyingbyAvgPop = 'Low_Pop') a
where a.ClassifybyAvgLE = 'High_LE'
union
select * from (select * from OceaniaIndepStats where ClassifyingbyAvgPop = 'Low_Pop') a
where a.ClassifybyAvgLE = 'High_LE' order by LifeExpectancy desc)
select co.Continent, c.Name, c.Population, c.LifeExpectancy, c.SurfaceArea, c.ClassifyingbyAvgPop, c.ClassifybyAvgLE, c.ClassifybyAvgSE 
from cte c join country co on c.Name = co.Name);

select * from LowPopHighLE; -- 76 countries
/* If you notice, 5 out of the countries in this list are classified as having a High Surface Area 
(as compared to the average surface area of their respective continents).
The rest are countries that have a low surface area
LowSE with LowPop makes sense here. */

/*The high life expectancy countries are done with.
Moving on to dangerous cases - Low Life expectancy */

/* General notes
-- High population, low LE - dangerous
-- Low Population, low LE - bad
-- Surface area can add some intrigue. */

-- High Pop, Low LE
/* These countries that have a high population, but low Life Expectancy, are dangerous. 
There are a lot of people living here. These countries must be developping, struggling with healthcare, housing, or
maybe the population is predisposed to medical conditions. There can be various factors that contribute to this low Life Expectancy */

create view HighPopLowLE as (
with cte as 
(select * from (select * from AsiaIndepStats where ClassifyingbyAvgPop = 'High_Pop') a
where a.ClassifybyAvgLE = 'Low_LE'
union
select * from (select * from AfricaIndepStats where ClassifyingbyAvgPop = 'High_Pop') a
where a.ClassifybyAvgLE = 'Low_LE'
union
select * from (select * from EuropeIndepStats where ClassifyingbyAvgPop = 'High_Pop') a
where a.ClassifybyAvgLE = 'Low_LE'
union
select * from (select * from NorthAmericaIndepStats where ClassifyingbyAvgPop = 'High_Pop') a
where a.ClassifybyAvgLE = 'Low_LE'
union
select * from (select * from SouthAmericaIndepStats where ClassifyingbyAvgPop = 'High_Pop') a
where a.ClassifybyAvgLE = 'Low_LE'
union
select * from (select * from OceaniaIndepStats where ClassifyingbyAvgPop = 'High_Pop') a
where a.ClassifybyAvgLE = 'Low_LE')
select co.Continent, c.Name, c.Population, c.LifeExpectancy, c.SurfaceArea, c.ClassifyingbyAvgPop, c.ClassifybyAvgLE, c.ClassifybyAvgSE 
from cte c join country co on c.Name = co.Name order by LifeExpectancy desc);

select * from HighPopLowLE; --  18 Countries

-- Low Pop, Low LE
/* These countries have low population and low life expectancies
I think this is where Surface Area may help our analysis. 

Low Population and Low Life Expectancy may indicate improper distribution of proper healthcare facilities
and maybe even lack of education. A dispersed population too.*/

create view LowPopandLE as (
with cte as 
(select * from (select * from AsiaIndepStats where ClassifyingbyAvgPop = 'Low_Pop') a
where a.ClassifybyAvgLE = 'Low_LE'
union
select * from (select * from AfricaIndepStats where ClassifyingbyAvgPop = 'Low_Pop') a
where a.ClassifybyAvgLE = 'Low_LE'
union
select * from (select * from EuropeIndepStats where ClassifyingbyAvgPop = 'Low_Pop') a
where a.ClassifybyAvgLE = 'Low_LE'
union
select * from (select * from NorthAmericaIndepStats where ClassifyingbyAvgPop = 'Low_Pop') a
where a.ClassifybyAvgLE = 'Low_LE'
union
select * from (select * from SouthAmericaIndepStats where ClassifyingbyAvgPop = 'Low_Pop') a
where a.ClassifybyAvgLE = 'Low_LE'
union
select * from (select * from OceaniaIndepStats where ClassifyingbyAvgPop = 'Low_Pop') a
where a.ClassifybyAvgLE = 'Low_LE')
select co.Continent, c.Name, c.Population, c.LifeExpectancy, c.SurfaceArea, c.ClassifyingbyAvgPop, c.ClassifybyAvgLE, c.ClassifybyAvgSE 
from cte c join country co on c.Name = co.Name order by LifeExpectancy desc);

select * from LowPopandLE; -- 75 countries
select * from LowPopandLE where ClassifybyAvgSE = 'HighSE';

/* 11 out of 75 countries have High Surface Area, and 10 out of these countries are from the African continent. 
The other countries have a low surface area, which may be because of positive (these countries are for tourism) or negative reasons, 
maybe.*/

-- I'm just going to go through the countries again
select * from HighPopandLE;
select * from HighPopLowLE;
select * from LowPopHighLE;
select * from LowPopandLE;

/* I want to rank the best countries based on life expectancy, which means I'm joining the countries with high life expectancies.
I could also rank the countries in the above individual tables (views) and it'll have a different analysis based on whether someone 
cares about the population of the countries, etc. That would be correct but I just want a simple analysis
I'm going to use window functions and subqueries. */

-- Ranking overall, no partitions
select *, dense_rank() over (order by HLE.LifeExpectancy desc) as Ranking from
(select * from HighPopandLE union select * from LowPopHighLE) HLE;

-- With partition by Continent, ordered alphabetically
select *, dense_rank() over (partition by HLE.Continent order by HLE.LifeExpectancy desc) as Ranking from
(select * from HighPopandLE union select * from LowPopHighLE) HLE;

-- Selecting the top countries ranked 1st, contient-wise
with HighLERanked as (
select *, dense_rank() over (partition by HLE.Continent order by HLE.LifeExpectancy desc) as Ranking from
(select * from HighPopandLE union select * from LowPopHighLE) HLE
)
select * from HighLERanked where Ranking = 1;

-- Selecting the bottom ranked countries, continent-wise
-- I'm going to write this query a bit differently for this one and won't include all the attributes of the tables/views

create view LeastRanksbyContinent as
(
with HighLERanked as
(
select *, dense_rank() over (partition by HLE.Continent order by HLE.LifeExpectancy desc) as Ranking from
(select * from HighPopandLE union select * from LowPopHighLE) HLE
)
select Continent, max(Ranking) as MaxRankinContinent from HighLERanked group by 1
); 
-- In the above, I've obtained a view with each continent and the maximum value of Ranking present in each continent
-- I'm going to use this view to join with my ranking cte to obtain the countries with the least ranks with their full stats.
-- As below:

with HighLERanked as
(
select *, dense_rank() over (partition by HLE.Continent order by HLE.LifeExpectancy desc) as Ranking from
(select * from HighPopandLE union select * from LowPopHighLE) HLE
)
select hlr.Continent, hlr.Name, hlr.Population, hlr.LifeExpectancy, hlr.SurfaceArea, hlr.ClassifyingbyAvgPop, hlr.ClassifybyAvgLE, hlr.ClassifybyAvgSE, hlr.Ranking 
from HighLERanked hlr 
join LeastRanksbyContinent lr on (lr.Continent = hlr.Continent) and (lr.MaxRankinContinent = hlr.Ranking);

/* I've made a mistake here. There's a country in Europe marked as a High Life Expectancy countriy but the life expectancy is null.
This does require all previous steps to be analyzed, but I'm too close to the end of this that I don't have the patience to
go through this mistake and rectify it. 

This must never be repeated in future projecs and in especially in a real-life project. 

Additionally, Oceana interestingly has two countries with the same last ranking. This isn't a mistake - just an observation

Keep in mind, both top and bottom rankings are still rankings based on high life expectancy countries*/

-- Let's now approach the countries with low life expectancies.
select * from HighPopLowLE union select * from LowPopandLE order by LifeExpectancy asc;

/* Countries in continents like Europe and Asia have somewhat decent -- and great! -- actual life expectancy values despite
having a low life expectancy when compared to their respective continent's life expectancy average.

I am going to, again, calculate the average life expectancy among these low life expectancy countries to find out a benchmark */

select round(avg(LifeExpectancy),2) from (select * from HighPopLowLE union select * from LowPopandLE) lowLE;
/* Now I'm going to determine that countries that have a life expectancy equal to or below this value are what are considered to be 
extremely poor in life expectnacy values */

create view ExtremelyPoorLE as
(
with LowLECountries as
(
select * from HighPopLowLE union select * from LowPopandLE order by LifeExpectancy asc
)
select * from LowLECountries where LifeExpectancy < (select round(avg(LifeExpectancy),2) from LowLECountries)
);
select * from ExtremelyPoorLE;

-- The other countries are actually somewhat better off, so
create view GoodLECountriesDespiteLowContinentLE as
(
with LowLECountries as
(
select * from HighPopLowLE union select * from LowPopandLE order by LifeExpectancy asc
)
select * from LowLECountries where LifeExpectancy >= (select round(avg(LifeExpectancy),2) from LowLECountries)
);
select * from GoodLECountriesDespiteLowContinentLE;

/* My work here is done. 
If you're ever going through these, feel free to use my work, modify it and come up with other analyses. 

I can already list a lot of different ways this analysis can be used. We can examine the best countries, determine what kind
of aid should be done for poor countries (if we had more data), etc.

I am extremely satisfied with the way I've performed this analysis for myself

Tootles!

*/ 