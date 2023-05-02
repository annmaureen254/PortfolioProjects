SELECT*
FROM CovidDeaths$
ORDER BY 3,4

SELECT *
FROM CovidVaccinations$
ORDER BY 3, 4

-- Select the data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
ORDER BY 1,2

--Looking at the Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths
FROM CovidDeaths$
ORDER BY 1,2 

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CovidDeaths$'

SELECT location, date, total_cases, total_deaths 
FROM CovidDeaths$

SELECT location, date, total_cases, total_deaths, ((CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100) as DeathPercentage
FROM CovidDeaths$
WHERE location like '%Kenya%'
ORDER BY 1,2 DESC

-- Looking at the Total cases vs Population
--Shows what percentage of population got covid
SELECT location, date, total_cases, population, ((CAST(total_cases AS FLOAT)/population)*100) AS PercentPopulationInfected
FROM CovidDeaths$
--WHERE location like '%Africa%'
ORDER BY 1,2

--Looking at countries with highest infection rate compare to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((CAST(total_cases AS FLOAT)/population)*100) AS PercentPopulationInfected
FROM CovidDeaths$
WHERE location like '%Kenya%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--SHOWING THE CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION
SELECT continent,  MAX(CAST(total_deaths AS int)) HighestDeathCount
FROM CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount desc

-- GLOBAL NUMBERS
SELECT location, date, total_cases, total_deaths, CAST(total_cases AS int)/CAST(total_deaths AS int) AS DeathPercentage
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

SELECT date, SUM(new_cases)
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT date, SUM(new_cases) NC, SUM(CAST(new_deaths AS int)) ND
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2  

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS FLOAT)) as total_deaths,((SUM(CAST(new_deaths AS FLOAT))/
SUM(CAST(new_cases AS FLOAT)+ 0.00001))*100) AS DeathPercentage
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS FLOAT)) as total_deaths,((SUM(CAST(new_deaths AS FLOAT))/
SUM(CAST(new_cases AS FLOAT)+ 0.00001))*100) AS DeathPercentage
FROM CovidDeaths$
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

SELECT *
FROM CovidVaccinations$

SELECT *
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- Looking at total population vs vaccinations
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3

SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER 
(Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER 
(Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population*100)
FROM PopvsVac


--TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
Continent varchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated 
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER 
(Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent varchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated 
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER 
(Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
ORDER BY 2,3


SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to Store data for lata visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER 
(Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT*
FROM PercentPopulationVaccinated