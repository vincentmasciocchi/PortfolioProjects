-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY location, date;

-- Looking at Total Cases vs Total Deaths
-- Showing the Death Rate
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100  AS "Death Percentage"
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY location, date;

-- Looking at Total Cases vs Population
-- Showing the Percentage of Population that has been Infected
Select location, date, total_cases, total_deaths, population, (total_cases/population)* 100 As "PercentPopulationInfected"
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY location, date;

-- Looking at Countries with the Highest Infection Rate compared to Population
Select location, Population, MAX(total_cases) AS "Total Infected", MAX((total_cases/population))*100 AS "PercentPopulationInfected"
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Looking at Countries with Highest Death Count per Population
Select location, population, MAX(cast(total_deaths AS Int)) AS "Total Deaths"
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY 'Total Deaths' DESC;

-- Showing continents with the highest death count per population
Select location, MAX(cast(total_deaths AS Int)) AS "Total Deaths"
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY 'Total Deaths' DESC;

-- Global Numbers
Select SUM(new_cases) AS "Total_Cases", SUM(cast(new_deaths AS INT)) AS "Total_Deaths", (SUM(cast(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;

-- Looking at Total Population vs Vaccinations Using CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, rolling_vaccinations_count)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations AS INT)) OVER (Partition BY dea.location ORDER BY dea.location, dea.DATE) AS rolling_vaccinations_count
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3;
)
SELECT *, (rolling_vaccinations_count/Population)*100 AS rolling_percent_vaccinated
FROM PopvsVac
ORDER BY 2,3

-- Looking at Total Population vs Vaccinations Using Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
rolling_vaccinations_count numeric
)
INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations AS INT)) OVER (Partition BY dea.location ORDER BY dea.location, dea.DATE) AS rolling_vaccinations_count
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (rolling_vaccinations_count/Population)*100 AS rolling_percent_vaccinated
FROM #PercentPopulationVaccinated
ORDER BY 2,3

-- Creating View to Store Data for Later Visualiazations

Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations AS INT)) OVER (Partition BY dea.location ORDER BY dea.location, dea.DATE) AS rolling_vaccinations_count
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null