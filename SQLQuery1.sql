select *
from CovidDeaths
order by 3,4

--select *
--from CovidVaccinations
--order by 3,4 

-- select the necessary data
select location, date, total_cases, new_cases, total_deaths, population
from covidDeaths

order by 1,2 

-- Total cases vs deaths of covid in Nigeria 
select location, date, total_cases, total_deaths
from covidDeaths
where location = 'Nigeria'
order by 1,2

-- Likelihood of dying from covid in Nigeria 
select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 As CovidDeathLikelihoodPercent
from covidDeaths
where location = 'Nigeria'
order by 1,2

-- Total cases of Covid vs population
select location, date, population, total_cases, (total_cases / population) * 100 As PopulationInfectionPercent
from covidDeaths
where location = 'Nigeria'
order by 1,2

-- Highest Infection Rate vs Population
select location, population, max(total_cases) As highestInfectionCount, (max(total_cases / population) * 100 ) As PopulationInfectionPercent
from covidDeaths
--where location = 'Nigeria'
group by location, population
order by PopulationInfectionPercent desc

-- Showing Countries with highest Death Count vs Population
select Location,population, max(cast(total_deaths as Int)) As total_deaths
from covidDeaths
where continent is not null
group by location, population
order by total_deaths desc


-- BREAKING DATA BY CONTINENTS
select continent, max(cast(total_deaths as Int)) As total_deaths
from covidDeaths
where continent is not null
group by continent
order by total_deaths desc

-- BREAKING DATA BY CONTINENTS CORRECT WAY
select continent, max(cast(total_deaths as Int)) As total_deaths
from covidDeaths
where continent is not null
group by continent
order by total_deaths desc

-- GLOBAL NUMBERS
Select DISTINCT(location), population, max(cast(total_deaths as Int)) As total_deaths_int
from covidDeaths
where continent is not null
group by location, population
order by total_deaths_int desc

-- TAKING A LOOK AT DATA GLOBALLY
Select date, (SUM(new_cases)) as total_cases_global, SUM (cast(new_deaths as int)) As total_deaths_global, (SUM(new_cases)) / SUM (cast(new_deaths as int))  *100 
--SUM(new_cases) as total_cases, SUM (cast(new_deaths) as int)) As total_deaths , ((total_cases)/(total_deaths) *100) as Death Percentage
from covidDeaths
where continent is not null
--group by date
order by 1,2


-- joining the covid death and the covid vaccination databases 
select *
from covidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date


-- Looking at Total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date ) as rollingPeopleVaccinated
from covidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date
order by 2,3 

-- Date Nigeria started vaccinating
SELECT continent, date, location, new_vaccinations
From covidVaccinations
Where date IN
(select min(dea.date)  
FROM covidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location 
where dea.continent is not null AND  dea.location = 'Nigeria' AND vac.new_vaccinations is not null
and dea.date = vac.date) AND Location = 'Nigeria'

-- using CTE tables
With PopvsVac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date ) as rollingPeopleVaccinated
from covidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date
-- order by 2,3
)

select *, (rollingPeopleVaccinated / population)* 100 
from PopvsVac
order by 2,3

-- using Temp table 
DROP Table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated (
	continent nvarchar(250),
	Location nvarchar(250),
	Date datetime,
	Population numeric, 
	new_vaccinations numeric,
	rollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated 
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date ) as rollingPeopleVaccinated
from covidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date
-- order by 2,3

create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date ) as rollingPeopleVaccinated
from covidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date
-- order by 2,3
where dea.continent is not null

select *
from PercentPopulationVaccinated

select *, (rollingPeopleVaccinated / population)* 100 
from #PercentPopulationVaccinated
order by 2,3

-- Creating views to store later for visualizations
