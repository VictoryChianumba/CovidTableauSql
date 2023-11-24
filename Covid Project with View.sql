 -- select the data for use
select * from coviddeaths where continent is not null;

select 
Location, date, total_cases, new_cases, total_deaths, population
from coviddeaths 
 order by 1,2;
 
 -- total deaths / total_cases for the United Kingdom 
 
select 
Location, date, total_cases, total_deaths, (total_deaths / total_cases	) * 100 as death_percentage
from coviddeaths 
where location like '%kingdom%'
order by 1,2;

-- total cases / population  for the United Kingdom 

select 
Location, date, total_cases, population, (total_cases / population	) * 100 as infection_percentage
from coviddeaths 
where location like '%kingdom%'
order by 1,2;

-- Highest comparitive infection rate for each country 

select 
Location, population, MAX(total_cases) as PeakInfectionCount, MAX((total_cases / population)) * 100 as Peak_infection_percentage
from coviddeaths 
Group by Location, population
order by 1,2;

-- Highest comparitive death count for each country 

select 
Location, MAX(total_deaths) as TotalDeathCount
from coviddeaths
where continent is not null
Group by Location
order by 2 desc;

-- Continents with the highest death count per population 
select 
location, MAX(total_deaths) as TotalDeathCount
from coviddeaths
where continent is  null
Group by location
order by 2 desc;

-- Global numbers 

select 
date, SUM(new_cases) as WorldCases, SUM(new_deaths) as WorldDeaths, (SUM(new_deaths)/SUM(new_cases)) * 100 as WorldDeawthPercentage
from coviddeaths 
where continent is not null 
group by date
order by 1,2;

-- total population vs vaccination 

select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as rollingVaccinations
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date  
where dea.continent is not null
order by 2,3;

-- use CTE

With PopvsVac (continent, locatin, date, population, new_vaccinations, rollingVaccinations) 
as

(

select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as rollingVaccinations
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date  
where dea.continent is not null
order by 2,3

)

select
* , rollingVaccinations/population * 100  as peoplevaccinated
from PopvsVac;
 
 -- Temp table
DROP TABLE if exists PopVaccinatedPercentage;
Create Table PopVaccinatedPercentage 
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rollingVaccinations numeric
 );
 
insert into PopVaccinatedPercentage
select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as rollingVaccinations
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date  
where dea.continent is not null
order by 2,3;

select
 * , rollingVaccinations/population * 100 as peoplevaccinated
 from PopVaccinatedPercentage;
 
-- creating view for later visualisations 

create view PopulationVaccinatedPercentage as 
select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as rollingVaccinations
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date  
where dea.continent is not null
order by 2,3;