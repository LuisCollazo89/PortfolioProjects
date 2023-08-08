/*
Covid 19 Data Exploration 

Using: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT*
FROM PortfolioProject..COVIDDEATHS$
WHERE continent is NOT NULL
ORDER BY 3,4


-- The data we are starting with.


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..COVIDDEATHS$
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths,  (cast(total_deaths as numeric))/ cast(total_cases as numeric)*100 as deathpercentage
FROM PortfolioProject..COVIDDEATHS$
WHERE location = 'United States'
ORDER BY 1,2


-- Percenage of the population that contracted COVID.


SELECT location, date, total_cases, population, (cast(total_cases as numeric))/ cast(population as numeric)*100 as deathpercentage
FROM PortfolioProject..COVIDDEATHS$
WHERE location = 'United States'
ORDER BY 1,2


-- Highest infection rates compared to population.


SELECT location, MAX(total_cases)AS HighestInfectionCount, population, MAX(cast(total_cases as numeric))/ cast(population as numeric)*100 as
PercentOfPopulationInfected
FROM PortfolioProject..COVIDDEATHS$
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY PercentOfPopulationInfected DESC


--Highest DeathCount per population.


SELECT location, MAX(CAST (total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..COVIDDEATHS$
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Continents with highest death countper population.


SELECT continent, MAX(CAST (total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..COVIDDEATHS$
WHERE continent is NOT NULL AND continent not like '%income%'
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global Numbers.


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..COVIDDEATHS$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--Population VS Vaccination difference.


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as numeric)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..COVIDDEATHS$ dea
Join PortfolioProject..COVIDVACCINATIONS$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--Population VS Vaccinations.


WITH popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as numeric)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..COVIDDEATHS$ dea
Join PortfolioProject..COVIDVACCINATIONS$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
SELECT*, (RollingPeopleVaccinated/population)*100 AS PercentageVaccinated
FROM popvsvac


--Temp Table.


CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime, population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as numeric)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..COVIDDEATHS$ dea
Join PortfolioProject..COVIDVACCINATIONS$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

SELECT*, (RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated


--Create View for later Visualization


CREATE VIEW PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as numeric)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..COVIDDEATHS$ dea
Join PortfolioProject..COVIDVACCINATIONS$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


--Vaccinated individuals from United States.


SELECT *
FROM PercentagePopulationVaccinated
WHERE location = 'United States'