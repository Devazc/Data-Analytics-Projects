-- DATA VISUALIZATION TABLEAU

USE [My Project Database]

-- 1.

SELECT SUM(NEW_CASES) AS TOTAL_CASES, SUM(CAST(NEW_DEATHS AS INT)) AS TOTAL_DEATHS, SUM(CAST(NEW_DEATHS AS INT))/SUM(NEW_CASES)*100 AS DeathPercentage
FROM CovidDeaths
WHERE CONTINENT IS NOT NULL
ORDER BY 1,2

-- 2.

SELECT LOCATION, SUM(CAST(NEW_DEATHS AS INT)) AS TotalDeathCount
FROM CovidDeaths

WHERE CONTINENT IS NULL
    AND LOCATION NOT IN ('World', 'European Union', 'International')
GROUP BY LOCATION
ORDER BY TotalDeathCount DESC

-- 3.

SELECT LOCATION, POPULATION, MAX(TOTAL_CASES) AS HighestInfectionCount, MAX((TOTAL_CASES/POPULATION))*100 AS PercentPopulationInfected
FROM CovidDeaths

GROUP BY LOCATION, POPULATION
ORDER BY PercentPopulationInfected DESC

-- 4

SELECT LOCATION, POPULATION, DATE, MAX(TOTAL_CASES) AS HighestInfectionCount, MAX((TOTAL_CASES/POPULATION))*100 AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY LOCATION, POPULATION, DATE
ORDER BY PercentPopulationInfected DESC


-- Creating a COVID - Dashboard using Tableau.

