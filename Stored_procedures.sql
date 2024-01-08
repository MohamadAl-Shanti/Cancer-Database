-- Section 2: Stored Procedures

/* 
 Procedure 1: Adds a Danger_level attribute to the Fossil_fuel_emissions table which assigns
 each row a Danger_level depending on the Emission_value of that row. Takes a boolean out 
 parameter called global_risk which is returned as true or false depending on how many
 countries have Danger_level = 'Dangerous'
*/

DROP PROCEDURE IF EXISTS VeryDangerous;
DELIMITER $$
CREATE PROCEDURE GlobalRisk(OUT global_risk BOOLEAN)
BEGIN
	-- Start of transaction
	START TRANSACTION;
    
	-- Adds Danger_level attribute to Fossil_fuel_emissions table. Exits procedure if Danger_level already exists
	IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name = 'Fossil_fuel_emissions' AND column_name = 'Danger_level') THEN
		ALTER TABLE Fossil_fuel_emissions ADD COLUMN Danger_level VARCHAR(100);
		ELSE ROLLBACK;
	END IF;
        
	-- Assigns each row a danger_level value depending on Emission_value
	UPDATE Fossil_fuel_emissions AS f
	JOIN (
		SELECT Year_number, Country_ID
		FROM Fossil_fuel_emissions
		WHERE year_number <> 2
	) AS subquery ON f.Year_number = subquery.Year_number AND f.Country_ID = subquery.Country_ID
	SET f.danger_level = CASE
		WHEN f.Emission_value > 15 THEN 'Dangerous'
		WHEN f.Emission_value > 10 THEN 'Concerning'
		ELSE 'good'
	END;
	
	-- Sets input parameter global_risk to TRUE if more than 100 rows have Danger_level = 'Dangerous', sets it to FALSE otherwise
	IF (SELECT COUNT(*) FROM Fossil_fuel_emissions WHERE Danger_level = 'Dangerous') > 100 THEN
		SET global_risk := TRUE;
	ELSE 
		SET global_risk := FALSE;
	END IF;
        
	-- End of transaction
	COMMIT;
END $$
DELIMITER ;

-- Parameter initialization: Value does not matter
SET @result := FALSE;

-- Procedure call
CALL GlobalRisk(@result);

-- Procedure result
SELECT @result;


/*  
 Procedure 2: Adds a mortality attribute to the Deaths_per_country table which
 calculates a mortality value that depends on how the Death_count of any row
 compares to an input threshold number.
*/ 

DROP PROCEDURE IF EXISTS MortalityRate;
DELIMITER $$
CREATE PROCEDURE MortalityRate(IN threshold INT)
BEGIN
	-- Start of transaction
    START TRANSACTION;
    
    -- Adds the mortality rate attribute if it does not already exist in the table
    IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name = 'Deaths_per_country' AND column_name = 'Mortality') THEN
        ALTER TABLE Deaths_per_country ADD COLUMN Mortality VARCHAR(100);
        ELSE ROLLBACK;
    END IF;

    -- Set mortality based on Death_count compared to threshold parameter
    UPDATE Deaths_per_country
    SET Mortality = CASE
        WHEN Death_count > threshold THEN 'High'
        WHEN Death_count > threshold / 2 THEN 'Moderate'
        ELSE 'Low'
    END
    WHERE Country_ID <> 'P';

    -- Some smoothing for fun in case death_count is ever 0 because why not
    UPDATE Deaths_per_country
    SET Death_count = 1
    WHERE Death_count = 0 AND Country_ID <> 'P';

	-- End of transaction
    COMMIT;
END $$
DELIMITER ;

-- Threshold value
SET @threshold := 300000;

-- Procedure call
CALL MortalityRate(@threshold);

-- Check Updated table after procedure
SELECT * FROM Deaths_per_country;