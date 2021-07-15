SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

 -- Select Data that we are going to be using

 Select location, date, total_cases, new_cases, total_deaths, population
 FROM PortfolioProject..CovidDeaths
 WHERE continent is not null
 ORDER BY 1,2

 -- Looking at Total Cases vs Total Deaths
 -- Shows likelihood of dying if you contract covid in your country
 Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
 FROM PortfolioProject..CovidDeaths
 WHERE location like 'Thailand'
 AND continent is not null
 ORDER BY 1,2

 -- Looking at Total Cases vs Population
 -- Show what percentage of population got Covid

 Select location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
 FROM PortfolioProject..CovidDeaths
 WHERE location like 'Thailand'
 AND continent is not null
 ORDER BY 1,2

 -- Looking at Countries with Highest Infection Rate compared to Population
 
 Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
 FROM PortfolioProject..CovidDeaths
 WHERE continent is not null
 GROUP BY location, population
 ORDER BY PercentPopulationInfected desc

 -- Showing Countries with Highest Death Count 

 Select location, MAX(cast(total_deaths as int))as TotalDeathCount
 FROM PortfolioProject..CovidDeaths
 WHERE continent is not null
 GROUP BY location
 ORDER BY TotalDeathCount desc
 
 -- Let's break things down by continent

 -- Showing continent with the highest death count
 Select continent, MAX(cast(total_deaths as int))as TotalDeathCount
 FROM PortfolioProject..CovidDeaths
 WHERE continent is not null
 GROUP BY continent
 ORDER BY TotalDeathCount desc


 -- GLOBAL NUMBERS
 
 SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage
 FROM PortfolioProject..CovidDeaths
 --WHERE location like 'Thailand'
 WHERE continent is not null
 ORDER BY 1,2


 -- Looking at Total Population vs Vaccination
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
 FROM PortfolioProject..CovidDeaths as dea
 JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
 WHERE dea.continent is not null
 ORDER BY 2,3


 -- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vacinations, RollingPeopleVaccinated)
as 
(
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
 FROM PortfolioProject..CovidDeaths as dea
 JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
 WHERE dea.continent is not null
 --ORDER BY 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
 FROM PortfolioProject..CovidDeaths as dea
 JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
 --WHERE dea.continent is not null
 --ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
 FROM PortfolioProject..CovidDeaths as dea
 JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
 WHERE dea.continent is not null
 --ORDER BY 2,3


 Select*
 From PercentPopulationVaccinated