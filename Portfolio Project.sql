Use PortfolioProject


SELECT *
FROM coviddeaths
WHERE continent is not null
ORDER BY 3,4;

SELECT *
FROM Covidvaccinations
ORDER BY 3,4 ;

###### Selecting the data to work with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE continent is not null
ORDER BY 1,2;

##### Total cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, Round((total_deaths/total_cases),2) as DeathPercentage
FROM coviddeaths
--WHERE Location = 'Namibia'
WHERE continent is not null
ORDER BY 1,2;

##### Total cases vs Total Population
##### Exploring what percentage has been infected by Covid

SELECT Location, date, Population, total_cases, (total_cases/Population) as PercentagePopulationInfected
FROM coviddeaths
-- WHERE location= 'Namibia'
WHERE continent is not null
ORDER BY 1,2;

##### Countries with highest infection rates compared to population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, Round(MAX((total_cases/Population)),4) 
as PercentagePopulationInfected
FROM coviddeaths
-- WHERE location= 'Namibia'
WHERE continent is not null
GROUP BY location, Population
ORDER BY PercentagePopulationInfected desc;

#### Creating a view

Create View HighestInfectionRates as
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/Population)
 as PercentagePopulationInfected
FROM coviddeaths
-- WHERE location= 'Namibia'
WHERE continent is not null
GROUP BY location, Population
-- ORDER BY PercentagePopulationInfected desc;


#### Countries with Highest Death Count per Population

SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM coviddeaths
-- WHERE location = 'Namibia'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc;

### Exploring the continents with the highest Death  Count per Population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM coviddeaths
-- WHERE location = 'Namibia'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;


### Exploring Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM coviddeaths
-- WHERE location = 'Namibia'
WHERE continent is not null
-- GROUP BY date
ORDER BY 1,2;

### Creating a view
Create View GlobalNumbers as
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM coviddeaths
-- WHERE location = 'Namibia'
WHERE continent is not null
-- GROUP BY date
-- ORDER BY 1,2;


#### Exploring Total Population vs Vaccinations

SELECT dt.continent, dt.Location, dt.date, dt.population, vc.new_vaccinations, 
SUM(Convert(int, vc.new_vaccinations)) OVER (Partition by dt.Location Order by dt.Location, 
dt.date) as CurrentPeopleVaccinated
FROM
    Coviddeaths dt
        JOIN
    Covidvaccinations vc ON dt.Location = vc.Location
        AND dt.date = vc.date
WHERE dt.continent is not null
ORDER BY 2,3; 

###Temp Table

DROP TABLE IF EXISTS PercentPopulationVaccinated

CREATE TABLE PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CurrentPeopleVaccinated numeric)

Insert into PercentPopulationVaccinated
SELECT dt.continent, dt.Location, dt.date, dt.population, vc.new_vaccinations,
SUM(cast(vc.new_vaccinations as int)) OVER (Partition by dt.Location Order by dt.Location, 
dt.date) as CurrentPeopleVaccinated
FROM
    Coviddeaths dt
        JOIN
    Covidvaccinations vc ON dt.Location = vc.Location
        AND dt.date = vc.date
WHERE dt.continent is not null
Order By 2,3;

SELECT 
    *, (CurrentPeopleVaccinated / Population) * 100
FROM
    PercentPopulationVaccinated


#### Creating a view for PercentPopulationVaccinated

Create View PercentPopulationVaccinated1 as
SELECT dt.continent, dt.Location, dt.date, dt.population, vc.new_vaccinations, 
SUM(Convert(int, vc.new_vaccinations)) OVER (Partition by dt.Location Order by dt.Location, 
dt.date) as CurrentPeopleVaccinated
FROM
    Coviddeaths dt
        JOIN
    Covidvaccinations vc ON dt.Location = vc.Location
        AND dt.date = vc.date
WHERE dt.continent is not null
; 

SELECT *
FROM
PercentPopulationVaccinated1









