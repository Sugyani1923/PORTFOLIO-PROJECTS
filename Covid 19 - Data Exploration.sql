
select *
From Portfolioproject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From Portfolioproject..CovidVaccinations
--order by 3,4

--Select Data that we are using

select Location, date, total_cases, new_cases, total_deaths, population
From Portfolioproject..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolioproject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

select Location, date,Population, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
From Portfolioproject..CovidDeaths
--where location like '%states%'
order by 1,2


--Looking at Countries with Highest Infection Rate compard to Population

select Location, Population,date, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From Portfolioproject..CovidDeaths
--where location like '%states%'
Group by Location, Population,date
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per population

select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT


select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(cast(new_deaths as int)) as DeathPercentage
From Portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
--Group By date
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--use CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinnated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Create view to store data foe later visualizations

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From Portfolioproject..CovidVaccinations vac
Join Portfolioproject..CovidDeaths dea
on vac.location = dea.location
and vac.date=dea.date
where dea.continent is not null

