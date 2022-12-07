SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that will be used

SELECT 
location, date, total_cases, new_cases, total_deaths, population
FROM
PortfolioProject..CovidDeaths
order by 1,2

-- Examining Total Cases vs Total Deaths in a specific country
-- Shows likelihood of death if you contracted COVID in your country between 2020-01-22 and 2021-04-30

SELECT 
location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM
PortfolioProject..CovidDeaths
WHERE location = 'United States'
order by 1,2

-- Examining Total Cases vs Population
-- Shows percentage of population that contracted COVID between 2020-01-22 and 2021-04-30

SELECT 
location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
FROM
PortfolioProject..CovidDeaths
WHERE location = 'United States'
order by 1,2

-- Looking at countries with Highest Infection Rate compared to Population

SELECT
location, population, MAX(total_cases) as HighestInfectionCount, MAX ((total_cases/population))*100 AS PercentPopulationInfected
FROM
PortfolioProject..CovidDeaths
group by location, Population
order by PercentPopulationInfected desc

-- Looking at countries with Highest Death Count compared to Population

USE PortfolioProject
GO
Create View TotalDeathCount AS
SELECT
location, max(cast(total_deaths as int)) as TotalDeathCount
FROM
PortfolioProject..CovidDeaths
WHERE
continent is not null
Group by location
--order by TotalDeathCount desc

-- Expanding breakdown to continents

SELECT
location, max(cast(total_deaths as int)) as TotalDeathCount
FROM
PortfolioProject..CovidDeaths
WHERE
continent is null
Group by location
order by TotalDeathCount desc


-- Global statistics by day


SELECT 
date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as GlobalDeathPercentage
FROM
PortfolioProject..CovidDeaths
WHERE continent is not null
Group by date
order by 1,2

-- Global statistics overall
SELECT 
SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as GlobalDeathPercentage
FROM
PortfolioProject..CovidDeaths
WHERE continent is not null
--Group by date
order by 1,2


--Changing to vaccination information to examine Populatoin vs Vaccinations

SELECT
*
FROM 
PortfolioProject..CovidVaccinations as vac
Join PortfolioProject..CovidDeaths as dea
on dea.location = vac.location
and dea.date = vac.date


-- Total Population vs Total Vaccination
USE PortfolioProject
GO
Create View TotalPopulationvsTotalVaccination AS
SELECT
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM 
PortfolioProject..CovidVaccinations as vac
Join PortfolioProject..CovidDeaths as dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

SELECT
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated, 
--(RollingPeopleVaccinated/population)*100
FROM 
PortfolioProject..CovidVaccinations as vac
Join PortfolioProject..CovidDeaths as dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 

--Creating TEMP table


DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidVaccinations as vac
Join PortfolioProject..CovidDeaths as dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualization


SELECT
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidVaccinations as vac
Join PortfolioProject..CovidDeaths as dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 