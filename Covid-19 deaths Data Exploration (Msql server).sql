select *
from PortfolioProject..CovidDeaths
order by 3, 4

select *
from PortfolioProject..Covidvaccinations
order by 3, 4

Select date, location, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 2,1

Select date, location, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 2,1

Select date, location, population, total_cases, (total_cases/population)*100 as PercentPopulationinfected
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 2,1

--3
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationinfected
from PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationinfected desc

--4
Select date, location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationinfected
from PortfolioProject..CovidDeaths
group by date, location, population
order by PercentPopulationinfected desc

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc
--2
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
and location not in ('World', 'European Union', 'International')
group by location
order by TotalDeathCount desc

--1
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 2,1


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 2,1

select *
from PortfolioProject..CovidDeaths Dea
Join PortfolioProject..Covidvaccinations Vac
On Dea.location = Vac.location
and Dea.date = Vac.date


select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
from PortfolioProject..CovidDeaths Dea
Join PortfolioProject..Covidvaccinations Vac
On Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
order by location, date



select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
SUM(cast(Vac.new_vaccinations as bigint)) OVER (Partition by Dea.location)
from PortfolioProject..CovidDeaths Dea
Join PortfolioProject..Covidvaccinations Vac
On Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
order by location, date

select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
SUM(CONVERT(bigint, Vac.new_vaccinations)) OVER (Partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths Dea
Join PortfolioProject..Covidvaccinations Vac
On Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
order by location, date

With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
SUM(CONVERT(bigint, Vac.new_vaccinations)) OVER (Partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths Dea
Join PortfolioProject..Covidvaccinations Vac
On Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
--order by location, date
)
Select * , (RollingPeopleVaccinated/population)*100
from PopVsVac

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
SUM(CONVERT(bigint, Vac.new_vaccinations)) OVER (Partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths Dea
Join PortfolioProject..Covidvaccinations Vac
On Dea.location = Vac.location
and Dea.date = Vac.date
--where Dea.continent is not null

Select * , (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

Create View PerPopulationVaccinated as
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
SUM(CONVERT(bigint, Vac.new_vaccinations)) OVER (Partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths Dea
Join PortfolioProject..Covidvaccinations Vac
On Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null

select * from PerPopulationVaccinated