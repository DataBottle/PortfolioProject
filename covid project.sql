SELECT *
FROM portfolio_project.`coviddeaths-cleaned`
WHERE continent IS NOT NULL;


/*
Select the data that we will be using
/*

SELECT 
	location,date, total_cases, new_cases, total_deaths, population
FROM
	portfolio_project.`coviddeaths-cleaned`
ORDER BY
	1,2;


/*
looking at total cases vs. total deaths
Shows the likelihood of dying if you contract Covid-19 in Sri Lanka
/*

SELECT 
	location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 AS death_percentage
FROM 
	portfolio_project.`coviddeaths-cleaned`
WHERE 
	location LIKE "%Sri%"
ORDER BY 
	2 DESC;
    
/*
Looking at total cases vs. population
Shows what population got Covid-19 in sri lanka
/*

SELECT 
	location, date, population, total_cases, (total_cases/population)*100 AS case_percentage
FROM 
	portfolio_project.`coviddeaths-cleaned`
WHERE 
	location LIKE "%Sri%"
ORDER BY 
	1,2 DESC;
    
/*
Looking at countries with highest infection rate compared to population
/*

SELECT 
	location,  population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentagePopulationInfected
FROM 
	portfolio_project.`coviddeaths-cleaned`
GROUP BY 
	location, population
ORDER BY 
	PercentagePopulationInfected DESC;
    
/*
Showing countries with the highest death count per population
/*

SELECT
	location,MAX(CAST(total_deaths AS float)) AS TotalDeathCount
FROM 
	portfolio_project.`coviddeaths-cleaned`
WHERE 
	continent IS NOT NULL
	AND location NOT IN ('World', 'Europe', 'Asia', 'Africa', 'North America', 'South America', 'Oceania', 'European Union')
GROUP BY
	location
ORDER BY 
	TotalDeathCount DESC;

/*
Looking for Total Population vs. Vaccinations
/*

SELECT 
	dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
    , SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM 
	portfolio_project.`coviddeaths-cleaned` AS dea
JOIN
	portfolio_project.`covidvaccinations` AS vac
ON 
	dea.location = vac.location
AND 
	dea.date = vac.date;
    
/*
Use CTE
/*

WITH PopVsVac (
    continent,
    location,
    date,
    population,
    new_vaccinations,
    rolling_people_vaccinated
) AS (
    SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(COALESCE(vac.new_vaccinations, 0) AS FLOAT)) OVER (
            PARTITION BY dea.location 
            ORDER BY dea.date
        ) AS rolling_people_vaccinated
    FROM 
        portfolio_project.`coviddeaths-cleaned` AS dea
    JOIN 
        portfolio_project.`covidvaccinations` AS vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
)

SELECT *,(rolling_people_vaccinated/population)*100
FROM PopVsVac

/*
Creating views for later visualizations.
/*
CREATE VIEW Total_death_count AS
SELECT  
    location,
    MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM   
    portfolio_project.`coviddeaths-cleaned`
WHERE   
    continent IS NOT NULL
    AND location NOT IN (
        'World', 'Europe', 'Asia', 'Africa',
        'North America', 'South America',
        'Oceania', 'European Union'
    )
GROUP BY  
    location;
    

    
SELECT * FROM Total_death_count
ORDER BY TotalDeathCount DESC;

    






    




	





