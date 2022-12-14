

--1 over view
select  sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null
order by 1,2 desc

--2 Total death in each region

Select location, sum(cast(new_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
Where continent is null
And location not in ('World', 'European Union', 'International')
Group by location
Order by TotalDeathCount desc

--3 Percent Population Infected

Select location, Population, Max(total_cases) as HighestInfectionCount, 
	Max(total_cases/population)*100 as PercentPopulationInfected
From dbo.CovidDeaths
--where location like '%viet%'
Group by location, population
Order by PercentPopulationInfected desc

-- 4 add Date for Percent Population Infected
Select location, Population, date, Max(total_cases) as HighestInfectionCount, 
	Max(total_cases/population)*100 as PercentPopulationInfected
From dbo.CovidDeaths
--where location like '%viet%'
Group by location, population, date
Order by PercentPopulationInfected desc