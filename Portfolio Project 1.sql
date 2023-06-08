Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3, 4


Select *
From PortfolioProject..CovidVaccinations
Where continent is not null
order by 3, 4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1, 2


-- Total Cases vs Total Deaths

Select date, total_cases, total_deaths, (CAST(total_deaths AS decimal))/(CAST(total_cases AS decimal))*100 as death_percentage
From PortfolioProject..CovidDeaths
Where continent is not null --and location like '%Singapore%'
order by 1, 2

--Total cases vs Population
Select Location, date, total_cases, population, ((CAST(total_cases AS decimal))/population)*100 as cases_percentage
From PortfolioProject..CovidDeaths
Where continent is not null and location like '%Singapore%'
order by 1, 2

--Countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount,(MAX(total_cases)/population)*100 as infection_rate
From PortfolioProject..CovidDeaths
Where continent is not null
Group By Location, population
order by infection_rate desc

--Splitting information based of continent
Select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc
--Continent with highest deathcount


--Countries with highest death count per population
Select location, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc


-- Global Numbers Death Percentage
Select SUM(cast(total_cases as decimal)) as Total_Cases, SUM(cast(total_deaths as decimal)) 
as Total_Deaths, SUM(cast(total_deaths as decimal))/SUM(cast(total_cases as decimal))*100 
as Death_Percentage
From PortfolioProject..CovidDeaths
Where continent is not null
--group by date
order by 1, 2




--Total population vs Vaccinations
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaxx.new_vaccinations,
SUM(CONVERT(bigint, vaxx.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location,
deaths.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations vaxx
Join PortfolioProject..CovidDeaths deaths
	On deaths.location = vaxx.location 
	and deaths.date = vaxx.date
Where deaths.continent is not null
order by 2, 3


--Using CTE(Common Table Expressions)
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaxx.new_vaccinations,
SUM(CONVERT(bigint, vaxx.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location,
deaths.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations vaxx
Join PortfolioProject..CovidDeaths deaths
	On deaths.location = vaxx.location 
	and deaths.date = vaxx.date
Where deaths.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaxx.new_vaccinations,
SUM(CONVERT(bigint, vaxx.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location,
deaths.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations vaxx
Join PortfolioProject..CovidDeaths deaths
	On deaths.location = vaxx.location 
	and deaths.date = vaxx.date
Where deaths.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaxx.new_vaccinations,
SUM(CONVERT(bigint, vaxx.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location,
deaths.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations vaxx
Join PortfolioProject..CovidDeaths deaths
	On deaths.location = vaxx.location 
	and deaths.date = vaxx.date
Where deaths.continent is not null
--order by 2, 3


Select * 
From PercentPopulationVaccinated