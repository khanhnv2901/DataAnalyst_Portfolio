select *
from dbo.CovidDeaths
order by 3,4

select *
from dbo.CovidVaccine
order by 3,4

-- select data that we are going to be using

select location, date, total_cases , new_cases, total_deaths, population
from dbo.CovidDeaths
order by 1, 2

-- total cases vs total deaths
-- shows likelihood of dying if u cotract covid in ur country
select location, date, total_cases, total_deaths,
	round((total_deaths/total_cases)*100, 2) as DeathPercentage
from dbo.CovidDeaths
where location like '%viet%'
and continent is not null
order by 1,2

-- total cases vs population
-- percentage of population got covid
select location, date, total_cases, population,
	round((total_cases/population)*100, 5) as GotCovidPercentage
from dbo.CovidDeaths
where continent is not null
and location like '%viet%'
order by 1,2

-- countries with highest infection rate compared to population
select location, population, Max(total_cases) as InfectionCount,
	Max((total_cases/population)*100) as PercentagePopulationInfected
from dbo.CovidDeaths
where continent is not null
group by location, population
order by 4 DESC

-- countries with hightest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null
group by location
order by 2 DESC

-- let's break things down by continent
select location, max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is null
group by location
order by 2 DESC

-- continents with the hightest death count per populations
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null
group by continent
order by 2 DESC

-- global numbers
select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null
group by date
order by 4 desc

- overview
select  sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null
order by 1,2 desc

-- VACCINATIONS
select people_vaccinated, people_fully_vaccinated
from dbo.CovidVaccine
where location like '%viet%'

-- Join two tables

-- compare population and vaccinations, percentage
with PopvsVac(Continent, Location, Date, Population, New_vaccinations, TotalVac, PeopleVaccinated, VaccinatedPercent)
as
(
select dea.continent, dea.location, dea.date, dea.population,
	vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date),
	sum(cast(vac.people_vaccinated as int)),
	sum(cast(vac.people_vaccinated as int))/dea.population * 100
from dbo.CovidDeaths dea	
join dbo.CovidVaccine vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and dea.location like '%viet%'
group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
-- order by 1,2,3 
)

select * from PopvsVac

-- temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, 
	dea.location, 
	dea.date, 
	dea.population,
	vac.new_vaccinations, 
	--sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date),
	sum(cast(vac.new_vaccinations as bigint))  over (partition by dea.location order by dea.location, dea.date)
	as RollingPeopleVaccinated
	--RollingPeopleVaccinated/dea.population * 100
from dbo.CovidDeaths dea	
join dbo.CovidVaccine vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--group by dea.continent, dea.location, dea.date, dea.population,
--	vac.new_vaccinations
--order by 1,2,3

select *,RollingPeopleVaccinated/population*100 from #PercentPopulationVaccinated

-- creating view to store data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent, 
	dea.location, 
	dea.date, 
	dea.population,
	vac.new_vaccinations, 
	--sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date),
	sum(cast(vac.new_vaccinations as bigint))  over (partition by dea.location order by dea.location, dea.date)
	as RollingPeopleVaccinated
	--RollingPeopleVaccinated/dea.population * 100
from dbo.CovidDeaths dea	
join dbo.CovidVaccine vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--group by dea.continent, dea.location, dea.date, dea.population,
--	vac.new_vaccinations
--order by 1,2,3

select * from PercentPopulationVaccinated


