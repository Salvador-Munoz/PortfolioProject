Select * 
from [Portfolio Project].dbo.CovidDeaths
where continent is not NULL
order by 3,4

-- Select the data that we are going to be using

Select location, date,  total_cases, new_cases, total_deaths, population
from [Portfolio Project].dbo.CovidDeaths
where continent is not NULL
Order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in the United States

Select location, date,  total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project].dbo.CovidDeaths
where location like '%states%'
and continent is not NULL
Order by 1,2

--Looking at Total cases vs Population
--Shows what percentage of population contracted Covid in the United States

Select location, date,  total_cases, population, (total_cases/population)*100 as CovidCotractionPercentage
from [Portfolio Project].dbo.CovidDeaths
where location like '%states%'
and continent is not NULL
Order by 1,2

--Looking at countries with highest infection rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
from [Portfolio Project].dbo.CovidDeaths
--where location like '%states%'
where continent is not NULL
group by location, population 
Order by PercentPopulationInfected desc

--Showing countries with highest Death count per Population

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project].dbo.CovidDeaths
--where location like '%states%'
where continent is not NULL
group by location, population 
Order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing Continents with highest death count

Select continent ,MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project].dbo.CovidDeaths
--where location like '%states%'
where continent is not NULL
group by continent 
Order by TotalDeathCount desc


-- Global numbers

--Death percentage by day

Select date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Portfolio Project].dbo.CovidDeaths
--where location like '%states%'
where continent is not NULL
group by date
Order by 1,2

--Total death percentage

Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Portfolio Project].dbo.CovidDeaths
--where location like '%states%'
where continent is not NULL
Order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingVaccination
--, (RollingVaccination/population) *100
From [Portfolio Project].dbo.CovidDeaths dea
join [Portfolio Project].dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
Order by 1,2,3

-- USING CTE

With PopVsVac (continent, location, date, population, new_vaccinations, RollingVaccination)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
	dea.date) as RollingVaccination
--, (RollingVaccination/population) *100
from [Portfolio Project].dbo.CovidDeaths dea
join [Portfolio Project].dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
--Order by 2,3
)

Select *, (RollingVaccination/population)*100
from PopVsVac



--TEMP table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccination numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
	dea.date) as RollingVaccination
--, (RollingVaccination/population) *100
from [Portfolio Project].dbo.CovidDeaths dea
join [Portfolio Project].dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not NULL
--Order by 2,3


Select * , (RollingVaccination/population)*100
From #PercentPopulationVaccinated


---Creating View to store Data later for visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
	dea.date) as RollingVaccination
--, (RollingVaccination/population) *100
from [Portfolio Project].dbo.CovidDeaths dea
join [Portfolio Project].dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
--Order by 2,3

Select *
From PercentPopulationVaccinated