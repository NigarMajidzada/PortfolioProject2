Select * 
from CovidDeaths
Where continent is not null
order by 3,4

--Select data that we are going to be useing
	Select location
		, date
		, total_cases
		, new_cases
		, total_deaths
		,population
	from CovidDeaths
	Where continent is not null

--Looking total cases and total deaths
--Show likelihood  of dying if you contract covid in your country 

Select location
		, date
		, total_cases
		, new_cases
		, total_deaths
		,(total_deaths/total_cases)*100 as DeathPencentage
	from CovidDeaths
	Where location like '%aze%' and continent is not null
	Order by 1,2

--Looking  at Total Cases and Population
--Shows what percentage of population got Covid		
Select location
		, date
		, population
		, total_cases
		,(total_cases/population)*100 as DeathPencentage
	from CovidDeaths
	--Where location like '%states%'
	Order by 1,2 desc	
	
--Looking at Countries  with Higest Infection Rate compared to Population

	Select location
		, population
		, Max(total_cases) as HighestInfectionCounts
		, Max((total_cases/population))*100 as PercentPoputaionInfected
	from CovidDeaths
	--Where location like '%states%'
	Group by location,population
	Order by PercentPoputaionInfected desc

--Showing Countries with Higest Death Count per Population

Select location
		, MAX(total_deaths) as TotalDeathCount
from CovidDeaths
	--Where location like '%states%'
	Where continent is not null
	Group by location
	Order by TotalDeathCount desc

--LET'S BREAK  THINGS DOWN BY CONTINENT


--Showing continents with the highest death count per population 
Select continent
		, MAX(total_deaths) as TotalDeathCount
from CovidDeaths
	--Where location like '%states%'
	Where continent is not null
	Group by continent
	Order by TotalDeathCount desc

--Global numbers 


SELECT
     SUM(CAST(new_cases AS bigint)) AS total_new_cases,
    SUM(new_deaths) AS total_deaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN NULL
        ELSE SUM(new_deaths) * 100.0 / SUM(new_cases)
    END AS DeathPercentag
FROM
    CovidDeaths
WHERE
    continent IS NOT NULL
ORDER BY 1,2

--Lokking at Total  Population vs Vaccinations

Select d.continent
	, d.location
	, d.date
	, d.population
	, v.new_vaccinations
	, Sum(v.new_vaccinations) over (Partition by d.location) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100 
From CovidDeaths D Inner join CovidVaccinations V on D.location=v.location and d.date=v.date
Where d.continent is not null 
order by 2,3

--Use CTE

with PopvsVac  (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as  
(
Select d.continent
	, d.location
	, d.date
	, d.population
	, v.new_vaccinations
	, Sum(v.new_vaccinations) over (Partition by d.location) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100 
From CovidDeaths D Inner join CovidVaccinations V on D.location=v.location and d.date=v.date
Where d.continent is not null 
--order by 2,3
) 

Select * , (RollingPeopleVaccinated/population)*100 
From PopvsVac

--Temp Table
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
	  continent nvarchar(255)
	, location nvarchar(255)
	, date datetime
	, population numeric 
	, new_vaccinations numeric
	, RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated


Select d.continent
	, d.location
	, d.date
	, d.population
	, v.new_vaccinations
	, Sum(v.new_vaccinations) over (Partition by d.location) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100 
From CovidDeaths D Inner join CovidVaccinations V on D.location=v.location and d.date=v.date
--Where d.continent is not null 
--order by 2,3

Select * , (RollingPeopleVaccinated/population)*100 
From #PercentPopulationVaccinated

--Create view to store data for visualizatins

Create view vw_PercentPopulationVaccinated as

Select d.continent
	, d.location
	, d.date
	, d.population
	, v.new_vaccinations
	, Sum(v.new_vaccinations) over (Partition by d.location) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100 
From CovidDeaths D Inner join CovidVaccinations V on D.location=v.location and d.date=v.date
Where d.continent is not null 
--order by 2,3

select* from vw_PercentPopulationVaccinated
