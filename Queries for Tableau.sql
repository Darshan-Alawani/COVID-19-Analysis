--We are done with the Exploratory Data Analysis (EDA) process for the COVID-19 dataset. We shall be importing the dataset to Tableau now.
--Before importing to Tableau, we shall run a few queries to get different types of data we need for visulization.

--1) We shall first see the Global numbers such as Total Cases, Total Deaths & the Death Percentage, all worldwide.

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases) * 100 AS Death_Percentage
FROM Portfolio_Project. .COVID_Deaths
WHERE continent IS NOT NULL
order by 1,2;

--2) Next, we shall check the total number of deaths in each of the continents.

Select continent, SUM(cast(new_deaths as int)) as TotalDeathCount
From Portfolio_Project..COVID_Deaths
Where continent is not null 
and location not in ('World', 'European Union', 'International')
Group by continent
order by TotalDeathCount desc

--3) We shall now check the countries with the highest percentage of population infected by the virus along with the most number of cases.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio_Project..COVID_Deaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--Finally, we shall check the percentage of population infected by the virus date-wise. This will generate a time-series chart showing the trends for number of cases for each country date-wise.

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio_Project..COVID_Deaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc

--Now that we have the final tables needed for visualizations on Tableau, we shall save the results for each of these queries and upload the tables to Tableau.