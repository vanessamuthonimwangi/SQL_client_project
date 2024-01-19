/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From SQLPersonalProject..CovidDeaths$
Where continent is not null
order by 3,4

--Select *
--From SQLPersonalProject..CovidVaccinations$
--order by 3,4


--Select Data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From SQLPersonalProject..CovidDeaths$
Where continent is not null
order by 1,2


-- Total cases vs Total Deaths
-- Explored the likelihood of death if you would contact COVID in Kenya which is 1.7098 as of 2021-04-30
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From SQLPersonalProject..CovidDeaths$
Where location like '%kenya%'
and continent is not null
order by 1,2


-- Exploring Total Cases vs Population
-- Shows what percentage of population infected with Covid 
Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From SQLPersonalProject..CovidDeaths$
Where location like '%kenya%'
order by 1,2


-- Countries with Highest Infection Rate Compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From SQLPersonalProject..CovidDeaths$
--Where location like '%kenya%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Exploring Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_cases as int)) as TotalDeathCount
From SQLPersonalProject..CovidDeaths$
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing Continents with The Highest Death Count per Population
Select continent, MAX(cast(Total_cases as int)) as TotalDeathCount
From SQLPersonalProject..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From SQLPersonalProject..CovidDeaths$
Where continent is not null
--Group BY date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLPersonalProject..CovidDeaths$ dea
Join SQLPersonalProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLPersonalProject..CovidDeaths$ dea
Join SQLPersonalProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP Table

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLPersonalProject..CovidDeaths$ dea
Join SQLPersonalProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for visualizations on Tableau

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLPersonalProject..CovidDeaths$ dea
Join SQLPersonalProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

