Select Location, date, total_cases, total_deaths, population
From CovidDeaths$
Order by 1,2

--total cases vs total deaths 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From CovidDeaths$
where location like '%India%'
Order by 1,2

--total cases vs population. This show what percentage of people got covid 
Select Location, date, population total_cases, (total_cases/population)*100 as casespercentage
From CovidDeaths$
where location like '%India%'
Order by 1,2

-- finding highest infection
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as percentagepopinfected
From CovidDeaths$
Group by Location, Population
Order by percentagepopinfected desc

-- finding highest death count 
-- here the total deaths are in VARCHAR and therefore needs to be converted to INT
select location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From CovidDeaths$
where continent is not null
Group by Location
Order by TotalDeathCount DESC

-- by continent
select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From CovidDeaths$
where continent is not null
Group by continent
Order by TotalDeathCount DESC

-- Global Number
Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths$
Where continent is not null
group by date 
order by 1,2

-- Using CTE
With PopvsVac(Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as(
Select dea.continent,dea.location, dea.date,  dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from CovidDeaths$ dea
Join CovidVaccinations$ vac 
On dea.location = vac.location and dea.date=vac.date
where dea.continent is not null
)
Select *,(RollingPeopleVaccinated/Population)*100 as Percentage From PopvsVac


-- temp table 
drop table if exists #percentagepopulationvaccinated
Create table #percentagepopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vacations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentagepopulationvaccinated
Select dea.continent,dea.location, dea.date,  dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from CovidDeaths$ dea
Join CovidVaccinations$ vac 
On dea.location = vac.location and dea.date=vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #percentagepopulationvaccinated



