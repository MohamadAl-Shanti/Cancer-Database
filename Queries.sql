-- Section 3:

-- Query 1: WHERE clause
 
SELECT Cancer_name, AVG(death_count) AS Hodgkin_death_average
FROM Deaths_per_country
    WHERE Cancer_name LIKE 'Hodgkin Lymphoma'
    GROUP BY Cancer_name;

-- Query 2: JOIN

SELECT y.Year_number, SUM(ffe.Emission_value) AS Total_Emission_value, SUM(y.Death_count) AS Year_total_deaths
    FROM Deaths_per_year y
    LEFT OUTER JOIN Fossil_fuel_emissions ffe ON y.Year_number = ffe.Year_number
    GROUP BY y.Year_number;
    

-- Query 3: Grouping 

SELECT Cancer_name, SUM(Death_count) AS Total_deaths
    FROM Deaths_per_country
    GROUP BY Cancer_name
    ORDER BY SUM(Death_count) DESC
    LIMIT 5;

-- Query 4: Subquery

SELECT * FROM (
	SELECT dpc.Country_ID, AVG(dpc.Death_Count / ffe.Emission_value) AS 'Emission_death_correlation'
    FROM Deaths_per_country dpc INNER JOIN Fossil_fuel_emissions ffe USING(Country_ID)
    GROUP BY Country_ID) AS Correlation_coefficients
    ORDER BY Correlation_coefficients.Emission_death_correlation DESC;
    
-- Query 5: View creation

DROP VIEW IF EXISTS Cancer_group_deaths;

-- Creation of view
CREATE VIEW Cancer_group_deaths AS (
	SELECT c.Cancer_group AS 'Cancer_group', SUM(dpc.Death_count) AS 'Total_deaths'
    FROM  Cancers c INNER JOIN Deaths_per_country dpc USING(Cancer_name)
    GROUP BY c.Cancer_group
    ORDER BY Total_deaths DESC
    );
    
-- Rerun after update to show its effects
SELECT * FROM Cancer_group_deaths;

-- Update
UPDATE Deaths_per_country
SET Death_count = ((3/2) * Death_count) / Death_count
WHERE Country_id <> 'P';