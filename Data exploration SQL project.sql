
USE portfolioproject

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY 1,2

-- Changing the total_deaths and total_cases column to its appropriate datatype

ALTER TABLE covid_deaths
ALTER COLUMN total_deaths FLOAT

ALTER TABLE covid_deaths
ALTER COLUMN total_cases FLOAT


-- Daily death percentage by countries
SELECT location, date, total_deaths, total_cases,  
					CASE 
						WHEN total_cases = 0 THEN 0.0
					ELSE (total_deaths / total_cases) *100 END AS death_percent 
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total new deaths in each location
SELECT location,  SUM(CAST(new_deaths AS int)) AS Total_new_deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY  location
ORDER BY 1

-- Daily Covid infection rate by countries
SELECT location, date, population, total_cases, (total_cases/population) *100 AS infect_percent
FROM covid_deaths
ORDER BY 1,2

-- Changing the new_cases column from varchar to FLOAT
ALTER TABLE covid_deaths
ALTER COLUMN new_cases FLOAT

-- overall Covid infection rate by countries

SELECT location, population, SUM(new_cases) AS total_new_cases, (SUM(new_cases)/population) *100 AS infect_percent
FROM covid_deaths
GROUP BY location, population
ORDER BY 1,2


-- Countries with the highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS Highest_infection_count, MAX((total_cases/population)) *100 AS Highest_population_infected_percent
FROM covid_deaths
GROUP BY location, population
ORDER BY 4 DESC

-- Changing the new_deaths datatype for aggregation
ALTER TABLE covid_deaths
ALTER COLUMN new_deaths FLOAT

-- Global numbers
SELECT date, SUM(new_cases) AS Total_new_cases, SUM(new_deaths) AS Total_new_deaths,  
				(SUM(new_deaths) / CASE 
						WHEN new_cases = 0 THEN NULL
					ELSE  SUM(new_cases) END) *100 AS death_percent
FROM covid_deaths
GROUP BY date, new_cases
ORDER BY 1 DESC


-- Changing the new_vaccination datatype from varchar() to FLOAT
ALTER TABLE Covid_vaccination
ALTER COLUMN new_vaccinations FLOAT 


-- Looking at total population vs vaccination  

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
			SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rooling_people_vaccination
FROM covid_deaths AS dea
JOIN Covid_vaccination AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USING CTE to show the relationship between the total population and vaccination

WITH PocvsVac (continent, location, date, population, new_vaccinations, Rolling_people_vaccination)
AS (
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
			SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_people_vaccination
FROM covid_deaths AS dea
JOIN Covid_vaccination AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (Rolling_people_vaccination/population)*100
FROM PocvsVac



-- USING TEMP TABLE to show the relationship between the total population and vaccinations
DROP TABLE IF EXISTS  #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
Continent varchar(100),
Location varchar(100),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rolling_people_vaccination numeric
)

INSERT INTO #percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
			SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_people_vaccination
FROM covid_deaths AS dea
JOIN Covid_vaccination AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (Rolling_people_vaccination/population)*100 AS  Rolling_people_vaccination_percent
FROM #percent_population_vaccinated



-- Creating view to store data for later visualizations

CREATE VIEW  percent_population_vaccinated
AS
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
			SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_people_vaccination
FROM covid_deaths AS dea
JOIN Covid_vaccination AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM percent_population_vaccinated


