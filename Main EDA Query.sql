--We have added the data in the form of 2 tables namely COVID_Deaths & COVID_Vaccinations from the 2 Excel Sheets. Let us query them to see what data we have.

SELECT *
FROM Portfolio_Project. .COVID_Deaths
ORDER BY 3, 4;

SELECT * 
FROM COVID_Vaccinations
ORDER BY 3, 4;

--Let us select the data that we need. We see a lot of columns that we may not need for the Analysis. Hence, we shall filter the data from the existing dataset.

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM COVID_Deaths
ORDER BY 1, 2;

--We shall begin our Exploratory Data Analysis (EDA) process from the 2 tables.
--Let us now find the Death Percentage i.e. number of deaths for number of cases. 
--We shall first look at the world data and later filter the data to show the death percentage in India. Death percentage shows the likelihood of death should one contract the virus in India.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM COVID_Deaths
WHERE location LIKE 'INDIA'
ORDER BY 1, 2;

--Let us now find the Infection Percentage for India i.e. number of infections for the total population in India.
--Infection percentage shows the likelihood of getting infected if you are in India.

SELECT location, date, total_cases, population, (total_cases/population)*100 as Infection_Percentage
FROM COVID_Deaths
WHERE location LIKE 'INDIA'
ORDER BY 1, 2;

--Let us now find the countries with the highest Infection Percentage.

SELECT location, population, MAX(total_cases), MAX((total_cases/population)*100) as Infection_Percentage
FROM COVID_Deaths
GROUP BY location, population
ORDER BY Infection_Percentage DESC;

--Let us now find the countries with the highest deaths.

SELECT continent, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM Portfolio_Project..COVID_Deaths
WHERE location is null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--Let us now find the metrics (total cases, total deaths, death percentage) globally without filtering the data by country or continent.

SELECT SUM(new_cases) AS New_Cases, SUM(new_deaths) AS New_Deaths, SUM(new_deaths)/SUM(new_cases)*100 as Death_Percentage
FROM Portfolio_Project..COVID_Deaths
--GROUP BY date
ORDER BY 1, 2;

--Let us now look at global vaccinations. We will compare the number of people vaccinated with respect to the country's population.

SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
from Portfolio_Project. .COVID_Deaths dea
JOIN Portfolio_Project. .COVID_Vaccinations vac
ON dea.location = vac.location
AND dea.date =vac.date
ORDER by 2,3

--We shall now find out the percentage of people vaccinated with respect to the country's population. But we cannot use the RollingPeopleVaccinated column as it is because it is not a part of the 2 tables.
--So, the best method to find the percentage of people vaccinated against the country's population is to create a CTE. We shall create a CTE and find the percentage of people vaccinated against the country's population

WITH POPvsVAC (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
from Portfolio_Project. .COVID_Deaths dea
JOIN Portfolio_Project. .COVID_Vaccinations vac
ON dea.location = vac.location
AND dea.date =vac.date
)

SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaccinationPercentage
from POPvsVAC


--We shall now create a TEMP TABLE to have the above calculation saved


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

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
from Portfolio_Project. .COVID_Deaths dea
JOIN Portfolio_Project. .COVID_Vaccinations vac
ON dea.location = vac.location
AND dea.date =vac.date

SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaccinationPercentage
from #PercentPopulationVaccinated
ORDER by 2, 3;


--We shall now create a VIEW to store data that will be needed for visualization in Tableau later

USE Portfolio_Project
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
from Portfolio_Project. .COVID_Deaths dea
JOIN Portfolio_Project. .COVID_Vaccinations vac
ON dea.location = vac.location
AND dea.date =vac.date

SELECT * 
from PercentPopulationVaccinated


--We are done with the Exploratory Data Analysis (EDA) process for the COVID-19 Analysis. We shall now be importing that data from the created VIEW to Tableau for visualization.