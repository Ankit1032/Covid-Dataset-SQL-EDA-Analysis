select * from covid_deaths
where continent is not null
order by 3,4 desc;

--select * from covid_vaccinations
--order by 3,4 desc;

SELECT column_name
FROM USER_TAB_COLUMNS
WHERE table_name = 'COVID_VACCINATIONS'
ORDER BY column_name;

SELECT column_name
FROM USER_TAB_COLUMNS
WHERE table_name = 'COVID_DEATHS'
ORDER BY column_name;


select location,dates,total_cases,new_cases,total_deaths,population
from covid_deaths
order by location,dates;

--Calculate deathPercentage of covid cases per day in India
select location,dates, total_cases, total_deaths, round((total_deaths/total_cases)*100,4) as DeathPercentage
from covid_deaths
where location like '%India%'
order by location,dates;

--print all countries starting with A,I and U
select distinct(location) from covid_deaths
where regexp_like(location,'^[A,I,U]')
order by 1;

--Find out what population of the population has got covid(per day)
select location,dates,total_cases,population, round((total_cases/population)*100,8) as "CovidCase% per population"
from covid_deaths
where location like '%India%'
order by 1 , 2;

--which country has highest covidcase% in terms of population
select * from(
select location,dates,total_cases,population, round((total_cases/population)*100,8) as CovidCasePercentagePerPopulation
from covid_deaths)
where CovidCasePercentagePerPopulation = (select max(round((total_cases/population)*100,8)) from covid_deaths)
and rownum = 1;

-- show the dates of each country when they had highest new cases in a day
select * from
(select location,dates,EXTRACT(YEAR from DATES) "YEAR", new_cases,
rank() over(partition by location order by new_cases desc) as highest_New_Cases
from covid_deaths)
where highest_New_Cases = 1 and new_cases >=0
order by new_cases desc;

-- show countries wise highest cases of covid with highest "CovidCase% per population"
select location,population,
max(total_cases) as HighestCovidCases,
round(max((total_cases/population))*100,6) as "CovidCase% per population"
from covid_deaths
group by location,population
order by HighestCovidCases desc;


-- showing countries with highest death count per population


-- show max death of each continent[Data issue as some continent is null in data]
select continent,max(total_deaths) as TotalDeathCount
from covid_deaths
where continent is not null
group by continent
order by TotaldeathCount Desc;

-- show max death of each continent[correct]
select location,max(total_deaths) as TotalDeathCount
from covid_deaths
where continent is null
group by location
order by TotaldeathCount Desc;


-- sum of all highest per day new cases in each country

select sum(NEW_CASES) from
(select LOCATION,NEW_CASES,
rank() over(partition by location order by NEW_CASES desc) as rnk_new_cases
from covid_deaths)
where rnk_new_cases = 1 and new_cases is not null;

-- find the date which had highest number of new covid cases throughtout the world
select dates,sum(new_cases) from covid_deaths
having sum(new_cases) is not null
group by dates
order by sum(new_cases) desc;

-- find new_cases and new_deaths per day throughout the world
select dates, sum(new_cases) as total_cases,
sum(cast(new_deaths as int)) as total_deaths,
round(sum(cast(new_deaths as int))/sum(new_cases),6) as DeathPercentage
from covid_deaths
where continent is not null and
new_deaths is not null and
new_cases is not null
group by dates
order by 1 desc;

-- Looking at total population vs vaccinations
-- just checking how many people are vaccinated vs total population %
WITH CTE_COVID(continent,location,dates,population,new_vaccinations,ROLLINGSUMPERLOCATION) AS
(
select d.continent,d.location,d.dates,d.population,
v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over(partition by d.location order by d.location,d.dates) as RollingSumPerLocation
from covid_deaths d
-- (ROLLINGSUMPERLOCATION/POPULATION) * 100
join covid_vaccinations v
    on d.dates = v.dates 
    and d.location = v.location
where d.continent is not null
--and v.new_vaccinations is not null
order by d.location,d.dates
)
select location,max(rollingsumperlocation),max(round((rollingsumperlocation/population)*100,6))
from CTE_COVID
group by location;

--create view
create or replace view total_death as
select location,max(total_deaths) as TotalDeathCount
from covid_deaths
where continent is null
group by location
order by TotaldeathCount Desc;

--RUN VIEW
select * from total_death;













