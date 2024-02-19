Select *
From PortofolioProject..CovidDeaths
order by 3,4

--Select *
--From PortofolioProject..CovidVaccinations
--order by 3,4

--Select the data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From PortofolioProject..CovidDeaths
order by 1,2

-- Looking at total_cases vs total_deaths
--Show the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortofolioProject..CovidDeaths
Where location like '%states%'
order by 1,2


-- Looking at the total_cases vs Population 
--Shows what percentage of population got covid.
Select location, date,population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortofolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2



--  Looking at Countries with highest Infection rate

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From PortofolioProject..CovidDeaths
--Where location like '%states%'
group by location, population
order by PercentagePopulationInfected desc


--Showing countries highest death count per population
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc



-- Let's break things down by continent

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
--Where location like '%states%'
where continent is   null
Group by location
order by TotalDeathCount desc




-- Showing the continents with Highest Death Counts
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortofolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
order by 1,2


Select date, sum(new_cases) as NewCases, sum(cast(new_deaths as int)) as NewDeaths, sum(cast(new_deaths as int))/sum(new_cases) as DeathPercentage
From PortofolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
group by date
order by 1,2


-- TOTAL CASES
Select  sum(new_cases) as NewCases, sum(cast(new_deaths as int)) as NewDeaths, sum(cast(new_deaths as int))/sum(new_cases) as DeathPercentage
From PortofolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
--group by date
order by 1,2



-- Let;s do for CovidVaccinations

Select *
From PortofolioProject..CovidDeaths as cd
join PortofolioProject..CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date

-- Looking at Total_Population vs Vaccinations

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths as cd
join PortofolioProject..CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2,3


--Use CTE
with PopvsVac(Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths as cd
join PortofolioProject..CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- TEMP TABLE

create table #PercentagePopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentagePopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths as cd
join PortofolioProject..CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentagePopulationVaccinated


-- If we execute the table we will get the error, so to avoid it Use Drop

Drop Table if exists #PercentagePopulationVaccinated

create table #PercentagePopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentagePopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths as cd
join PortofolioProject..CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentagePopulationVaccinated



-- CREATING  a view to store the data for later visualizations

Create view PercentagePopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths as cd
join PortofolioProject..CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 2,3


select *
from PercentagePopulationVaccinated