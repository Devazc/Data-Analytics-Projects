--  COVID Data Analysis using Microsoft SQL Server
/*
> DataSet Source: https://ourworldindata.org/covid-deaths
> Types of SQL operations used to retrieve, manipulate, and analyze data in a relational database.
>> Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

USE [My Project Database]

SELECT * FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


-- STARTING WITH COVID_DEATHS DATA SET TO ANALYZE

SELECT LOCATION, DATE, TOTAL_CASES, NEW_CASES, TOTAL_DEATHS, POPULATION
FROM CovidDeaths
WHERE continent IS NOT NULL -- In Continent Column some values are noted as NULL, So we removed them
ORDER BY 1,2 -- Sorted by 1st Column Location and 2nd Column Date


-- TOTAL CASES VS TOATL DEATHS
-- CHANCE OF DEATH IF CONTRACT WITH COVID IN PERCENTAGE

SELECT LOCATION, DATE, POPULATION, TOTAL_CASES,TOTAL_DEATHS, (TOTAL_DEATHS/TOTAL_CASES)*100 AS DEATH_PERCENTAGE
FROM CovidDeaths
WHERE LOCATION LIKE 'INDIA'
AND CONTINENT IS NOT NULL
ORDER BY 1,2


-- TOTAL CASES VS TOTAL POPULATION
-- PERCENTAGE OF POPULATION INFECTED WITH COVID

SELECT LOCATION, DATE, POPULATION, TOTAL_CASES, (TOTAL_CASES/POPULATION)*100 AS POPULATION_INFECTED_PERCENTAGE
FROM CovidDeaths
ORDER BY 1,2


-- COUNTRIES WITH HIGHEST INFECTION RATE

SELECT LOCATION, POPULATION, MAX(TOTAL_CASES) AS HighestInfectionCount, MAX(TOTAL_CASES/POPULATION) AS POPULATION_INFECTED_PERCENTAGE
FROM CovidDeaths
GROUP BY LOCATION, POPULATION
ORDER BY POPULATION_INFECTED_PERCENTAGE DESC


-- By Continent
-- Continents with Highest DeathCount per Population

SELECT CONTINENT, MAX(CAST(TOTAL_DEATHS AS INT)) AS TOTAL_DEATH_COUNT
FROM CovidDeaths
WHERE CONTINENT IS NOT NULL
GROUP BY CONTINENT 
ORDER BY TOTAL_DEATH_COUNT DESC


-- GLOBAL NUMBERS

SELECT SUM(NEW_CASES) AS TOTAL_CASES, SUM(CAST(NEW_DEATHS AS INT)) AS TOTAL_DEATHS, SUM(CAST(NEW_DEATHS AS INT))/SUM(NEW_CASES)*100 AS TOATL_DEATH_PERCENTAGE
FROM CovidDeaths
WHERE CONTINENT IS NOT NULL
ORDER BY 1,2


-- COVID_VACCINATIONS

-- TOTAL_POPULATION VS VACCINATIONS
-- PERCENTAGE OF POPULATION THAT HAS RECEIVED ATLEAST ONE DOSE OF COVID VACCINATION

SELECT D.CONTINENT, D.LOCATION, D.DATE, D.POPULATION, V.NEW_VACCINATIONS
, SUM(CONVERT(INT, V.NEW_VACCINATIONS)) OVER (PARTITION BY D.LOCATION ORDER BY D.LOCATION, D.DATE) AS ROLLING_PEOPLE_VACCINATED

FROM CovidDeaths D 
JOIN CovidVaccinations V 
ON D.LOCATION = V.LOCATION AND D.DATE = V.DATE

WHERE D.CONTINENT IS NOT NULL
ORDER BY 2,3 


-- CTE, SUBQUERY
-- Using CTE to perform Calculation on Partition

WITH POP_VS_VAC (CONTINENT, LOCATION, DATE, POPULATION, NEW_VACCINATIONS, ROLLING_PEOPLE_VACCINATED)
AS
(
    SELECT D.CONTINENT, D.LOCATION, D.DATE, D.POPULATION, V.NEW_VACCINATIONS
    , SUM(CONVERT(INT, V.NEW_VACCINATIONS)) OVER (PARTITION BY D.LOCATION ORDER BY D.LOCATION, D.DATE) AS ROLLING_PEOPLE_VACCINATED

    FROM CovidDeaths D 
    JOIN CovidVaccinations V 
    ON D.LOCATION = V.LOCATION AND D.DATE = V.DATE

    WHERE D.CONTINENT IS NOT NULL
    -- ORDER BY 2,3
)
SELECT *, (ROLLING_PEOPLE_VACCINATED/POPULATION)*100 AS VAC_PERCENTAGE
FROM POP_VS_VAC


-- Using Temporary Table to perform Calculation on Partition By in previous QUERY

DROP TABLE IF EXISTS #POPULATION_VACCINATED_PERCENTAGE
CREATE TABLE #POPULATION_VACCINATED_PERCENTAGE
(
    CONTINENT NVARCHAR(255),
    LOCATION NVARCHAR(255),
    DATE DATETIME,
    POPULATION NUMERIC,
    NEW_VACCINATIONS NUMERIC,
    ROLLING_PEOPLE_VACCINATED NUMERIC,
)

INSERT INTO #POPULATION_VACCINATED_PERCENTAGE
SELECT D.CONTINENT, D.LOCATION, D.DATE, D.POPULATION, V.NEW_VACCINATIONS
, SUM(CONVERT(INT, V.NEW_VACCINATIONS)) OVER (PARTITION BY D.LOCATION ORDER BY D.LOCATION, D.DATE) AS ROLLING_PEOPLE_VACCINATED

FROM CovidDeaths D 
JOIN CovidVaccinations V 
ON D.LOCATION = V.LOCATION AND D.DATE = V.DATE

-- WHERE D.CONTINENT IS NOT NULL
-- ORDER BY 2,3

SELECT *, (ROLLING_PEOPLE_VACCINATED/POPULATION)*100 AS VAC_PERCENTAGE
FROM #POPULATION_VACCINATED_PERCENTAGE


-- STORING DATA FOR VISUALIZATION
-- Creating View to Store Data for later Visualizations

CREATE VIEW POPULATION_VACCINATED_PERCENTAGE AS

SELECT D.CONTINENT, D.LOCATION, D.DATE, D.POPULATION, V.NEW_VACCINATIONS
, SUM(CONVERT(INT, V.NEW_VACCINATIONS)) OVER (PARTITION BY D.LOCATION ORDER BY D.LOCATION, D.DATE) AS ROLLING_PEOPLE_VACCINATED

FROM CovidDeaths D 
JOIN CovidVaccinations V 
ON D.LOCATION = V.LOCATION AND D.DATE = V.DATE

WHERE D.CONTINENT IS NOT NULL


-- Further Developments
/*
> Data Visualization of the Acquired Data
> Analysis of COVID Vaccinations (INDIA)
*/