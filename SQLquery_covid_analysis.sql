use SQLProject;
select * 
from SQLProject..Covid_deaths
order by 3,4;

-- selecting the data that we are going to use 

select location,date,total_cases,new_cases,total_deaths,population,reproduction_rate,hosp_patients
From SQLProject..Covid_deaths
where location like '%india%'
order by 1,2;

-- total death vs total cases  ( DeathPercentage)

select location,date,total_cases,new_cases,total_deaths, round((total_deaths/total_cases)*100,2) as DeathPercentage
From SQLProject..Covid_deaths
where location like '%india%'
order by DeathPercentage desc;

-- new cases vs poputation
select location,date,total_cases,new_cases,population,(new_cases/population)*100 as newcasePercentage
From SQLProject..Covid_deaths
where location like '%india%'
order by newcasePercentage desc;

--total cases vs poputation 
select location,date,total_cases,new_cases,population,(total_cases/population)*100 as totalcasePercentage
From SQLProject..Covid_deaths
where location like '%india%'
order by 1,2;

-- country with highest infection rate 
select location,population,max(total_cases) as highesttotalcase ,max((total_cases/population)*100) as totalcasePercentage
From SQLProject..Covid_deaths
group by location,population
--having location like '%india%'
order by totalcasePercentage desc;

--highest death count
select location,max(cast(total_deaths as int)) as highestdeath 
From SQLProject..Covid_deaths
where continent is not null   --only country
group by location
order by highestdeath desc;

-- only continent 
select location,max(cast(total_deaths as int)) as highestdeath 
From SQLProject..Covid_deaths
where continent is null   --only country
group by location
order by highestdeath desc;

-- showing continent with highest death count 
select continent,max(cast(total_deaths as int)) as highestdeath 
From SQLProject..Covid_deaths
where continent is not null   --only country
group by continent
order by highestdeath desc;

--- global 
--- date which has highestest death count
-- 20 jaunary 2021
select date,sum(cast(new_cases as int)) as totalcase,sum(cast(new_deaths as int)) as totaldeaths, 
								round(sum(cast(new_deaths as int))/sum(new_cases),4) as deathpercentage
From SQLProject..Covid_deaths
where continent is not null
group by date
order by date ;

-- total population vs new vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
	sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as rollingvaccinated
from SQLProject..Covid_deaths dea
join SQLProject..Covid_vaccination vac
 on dea.location=vac.location and
 dea.date=vac.date 
 where dea.continent is not null 
 order by 2,3;



 --- use  CTE
 WITH populationvsvac(continent,location,date,population,new_vaccinations,rollingvaccinated)
 as 
 (
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
	sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as rollingvaccinated
from SQLProject..Covid_deaths dea
join SQLProject..Covid_vaccination vac
 on dea.location=vac.location and
 dea.date=vac.date 
 where dea.continent is not null 

 )
 select *,(rollingvaccinated/population)*100 as vaccinationpercentage 
 from populationvsvac;
------



 --- using temp table

 drop table if exists populationvsvaccination
 create table populationvsvaccination
 (
 continent varchar(225),
 location varchar(225),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rollingvaccinated numeric
)

 insert into populationvsvaccination
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
	sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as rollingvaccinated
from SQLProject..Covid_deaths dea
join SQLProject..Covid_vaccination vac
 on dea.location=vac.location and
 dea.date=vac.date 
 where dea.continent is not null 


 select *,(rollingvaccinated/population)*100 as vaccinationpercentage 
 from populationvsvaccination;

--- using view 
 --- creating view to store data for later visualizations
0.010178982128568
create view populationvsvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
	sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as rollingvaccinated
from SQLProject..Covid_deaths dea
join SQLProject..Covid_vaccination vac
 on dea.location=vac.location and
 dea.date=vac.date 
 where dea.continent is not null 

 select * from populationvsvaccinated;

 -- for tableau visualizations
 -- table 1
 select sum(new_cases) as total_cases, sum(cast(new_deaths as bigint)) as total_death, sum(cast(new_deaths as bigint))/sum(new_cases) deathpercentage
 from SQLProject..Covid_deaths
 where continent is not null

 -- table 2
select location, sum(cast(new_deaths as bigint)) as total_death
from SQLProject..Covid_deaths
where continent is null and location not in ('world','European Union','International','Lower middle income','Upper middle income','Low income','High income')
group by location
order by total_death desc

-- table 3 
 
select ISNULL(location,0) as location ,ISNULL(population,0) as population,ISNULL(max(new_cases),0) as Highestinfectioncount,ISNULL(sum(new_cases)/population,0) as infectionpercentage
from SQLProject..Covid_deaths
where continent is not null
group by location,population
order by infectionpercentage desc

-- table 4

select ISNULL(location,0) as location,ISNULL(population,0) as population ,ISNULL(date,0) as date,ISNULL(max(new_cases),0) as Highestinfectioncount,ISNULL(sum(new_cases)/population,0) as infectionpercentage
from SQLProject..Covid_deaths
where continent is not null and location like '%state%'
group by location,population,date
order by infectionpercentage desc






























