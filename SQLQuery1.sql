use PortfolioProject

Select * from CovidDeaths
where continent is not null
order by 3,4

Select * from CovidVaccination
order by 3,4


Select * from CovidDeaths
order by 3 ,4 

--Select * from CovidVaccination
--order by 3 ,4 

---SELECT DATA THAT WE ARE GOING TO BE USING  

Select location , date, total_cases , new_cases , total_deaths , population 
	from CovidDeaths
	where continent is not null
	order by 1 ,2 

--LOOKING AT TOTAL CASES VS TOTAL DEATHS 
--Show likelihood of dying i you contract covid in your country 

Select location , date , total_cases, total_deaths , 
(CAST(total_deaths as int ) / CAST(total_cases as int)) *100 as DeathPercentage
 from CovidDeaths
 where location like '%states%'
 and continent is not null 
 order by 1,2


 ---Looking at total cases vs population 

 Select location , date , population, total_cases , 
 (CAST(total_cases as int)) / (CAST(total_deaths as int)) *100 as PercentagePopulationInffected
  from CovidDeaths
--  where location like '%states%'
  order by 1,2


---Looking at countries with highest inffection rate compared to population 

select location , population ,MAX (total_cases ) as HighestInfectionCount
, MAX(total_cases/ population * 100 )as PerfcentagePopulationInffected
 from CovidDeaths
 group by location , population
 order by PerfcentagePopulationInffected desc 



--shpw what %of population got covid ----
select location, date,population , total_cases, (CONVERT(DECIMAL(18,2), total_deaths) /
CONVERT(DECIMAL(18,2), total_cases) )*100 as PercentPopulationinfected
from CovidDeaths
where continent is not null
order by 1,2


---Looking at countries with highest infection rate compared to population--

Select location ,population, MAX(total_cases) as HighestInfectionCount , Max((total_cases/population))*100
as PercentPopulationinfected from CovidDeaths
	where continent is not null
	group by location ,population
	order by PercentPopulationinfected desc

---Showing the country with highest death count with population --

Select location , MAX (cast(total_deaths as int)) as TotalDeathCount 
	from CovidDeaths
	where continent is not null
	group by location 
	order by TotalDeathCount  desc

----------let's break things down by continent -

Select continent , MAX(CAST(total_deaths as int)) As TotalDeathCount from CovidDeaths
	where continent is not null
	group by continent
	order by TotalDeathCount desc 

---Showing continent with highest DeathCount--

Select continent , Max(CAST(total_deaths as int)) as HighestDeathCount
 from CovidDeaths
	where continent is not null
	group by continent
	order by HighestDeathCount desc 


--------GLOBAL NUMBERS 


Select  SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int )) as TotalDeaths, SUM(CAST(new_deaths as int ))/
SUM(new_cases) * 100 as DeathPercentage from CovidDeaths
where continent is not null 
--group by date
order by 1 ,2


----Looking at Total Population vs Vaccination 
Select dea.continent  , dea.location ,dea.date , dea.population , vac.new_vaccinations 
, SUM(Convert(int, new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated 
----, (RollingPeopleVaccinated/population)*100
	from PortfolioProject..CovidDeaths as dea
	join PortfolioProject..CovidVaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3


-----USE CTE 


WITH PopVsVac (Continent,location,date,population,new_vaccinations,RollingPeopleVaccinated ) as 
	(Select dea.continent  , dea.location ,dea.date , dea.population , vac.new_vaccinations 
, SUM(Convert(int, new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated 
----, (RollingPeopleVaccinated/population)*100
	from PortfolioProject..CovidDeaths as dea
	join PortfolioProject..CovidVaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
	)
Select *, (RollingPeopleVaccinated/population)*100
 from PopVsVac



 ----Temp Table --

-- Drop the temporary table if it already exists
DROP TABLE IF EXISTS #PercentPopulationVaccinated;

-- Create the temporary table
CREATE TABLE #PercentPopulationVaccinated (
    Continent VARCHAR(255),
    location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated BIGINT
);

-- Insert data into #PercentPopulationVaccinated temporary table
INSERT INTO #PercentPopulationVaccinated
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..CovidDeaths AS dea
JOIN 
    PortfolioProject..CovidVaccination AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date;

-- Select data from #PercentPopulationVaccinated and calculate percentage
SELECT 
    *,
    (CAST(RollingPeopleVaccinated AS FLOAT) / CAST(population AS FLOAT)) * 100 AS PercentPopulationVaccinated
FROM 
    #PercentPopulationVaccinated;

----------Creating view to store data for later visualisations 

create view PercentPopulationVaccinated as 
Select dea.continent  , dea.location ,dea.date , dea.population , vac.new_vaccinations 
, SUM(Convert(int, new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated 
----, (RollingPeopleVaccinated/population)*100
	from PortfolioProject..CovidDeaths as dea
	join PortfolioProject..CovidVaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

Select * from PercentPopulationVaccinated