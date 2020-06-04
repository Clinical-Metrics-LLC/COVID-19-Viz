-- RUNTIME Complete SQL for 'us_usa', 'us_usa_csv', 'us_states', 'us_states_csv', 'us_counties' and 'us_counties_csv' table creation,
--    Imports from 'US_USA_CSV.csv', 'US_States_CSV.csv', 'US_Counties_CSV.csv', and updates table with New_Cases and New_Deaths
--    Creates 'US_USA.csv', 'US_States.csv', 'US_Counties.csv' files for use with Tableau Public

-- For MySQL - Produces NY Times COVID-19 CSV files for use with Tableau Public (requires Census tables and CSV files to be done first)


-- William L. Salomon, MD MS MPH
-- Clinical Metrics, LLC
-- Revised 2020-06-03

-- Prime the database for prolonged JOINS (default is 30 sec.)

SET net_read_timeout = 600;
SET net_write_timeout = 600;
SET innodb_lock_wait_timeout = 600; 



-- CREATE a Schema (Database) 'covid_19' if one does not already exist

CREATE DATABASE IF NOT EXISTS covid_19;



-- CREATE 'us_usa_csv', 'us_states_csv', 'us_counties_csv' table for CSV import

DROP TABLE IF EXISTS covid_19.us_usa_csv;

CREATE TABLE covid_19.us_usa_csv (
	`Date` VARCHAR(50),
	 Cases  VARCHAR(50),
	 Deaths VARCHAR(50)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS covid_19.us_states_csv;

CREATE TABLE covid_19.us_states_csv (
	`Date` VARCHAR(50),
	 State VARCHAR(50),
     FIPS VARCHAR(50),
	 Cases VARCHAR(50),
	 Deaths VARCHAR(50)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS covid_19.us_counties_csv;

CREATE TABLE covid_19.us_counties_csv (
	`Date` VARCHAR(50),
	 County VARCHAR(50),
	 State VARCHAR(50),
	 FIPS VARCHAR(50),
	 Cases VARCHAR(50),
	 Deaths VARCHAR(50),
	 INDEX (County, State)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;



-- IMPORT the CSV data from 'us_usa_csv.csv, 'US_states.csv', and 'us_counties_csv.csv'

LOAD DATA INFILE 'C:\\COVID-19\\US_USA_CSV.csv' INTO TABLE covid_19.us_usa_csv
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:\\COVID-19\\US_States_CSV.csv' INTO TABLE covid_19.us_states_csv
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:\\COVID-19\\US_Counties_CSV.csv' INTO TABLE covid_19.us_counties_csv
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;



-- Now transfer the data from 'us_usa_csv', 'us_states_csv, 'us_counties_csv' to
--    'us_usa', 'us_states', 'us_counties'

-- CREATE 'us_usa', 'us_states', 'us_counties' tables

DROP TABLE IF EXISTS covid_19.us_usa;

CREATE TABLE covid_19.us_usa(
	 Row_ID MEDIUMINT AUTO_INCREMENT PRIMARY KEY,
	`Date` DATE,
	 Tot_Cases DECIMAL(11,1),
	 New_Cases DECIMAL(11,1),
	 Tot_Deaths DECIMAL(11,1),
	 New_Deaths DECIMAL(11,1)
	)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS covid_19.us_states;

CREATE TABLE covid_19.us_states(
	 Row_ID MEDIUMINT AUTO_INCREMENT PRIMARY KEY,
	`Date` Date,
	 State VARCHAR(50),
	 FIPS MEDIUMINT NULL,
	 Tot_Cases DECIMAL(11,1),
	 New_Cases DECIMAL(11,1),
	 Tot_Deaths DECIMAL(11,1),
	 New_Deaths DECIMAL(11,1),
	 INDEX (FIPS, State)
	)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS covid_19.us_counties;

CREATE TABLE covid_19.us_counties(
	 Row_ID MEDIUMINT AUTO_INCREMENT PRIMARY KEY,
	`Date` Date,
	 State VARCHAR(50),
	 County VARCHAR(50),
	 FIPS MEDIUMINT NULL,
	 Tot_Cases DECIMAL(11,1),
	 New_Cases DECIMAL(11,1),
	 Tot_Deaths DECIMAL(11,1),
	 New_Deaths DECIMAL(11,1),
	 INDEX (FIPS, State, County)
	)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;



-- INSERT transformed (converted) data from 'us_usa_csv', 'us_states_csv', 'us_counties_csv', ordered by State, County, Date

INSERT IGNORE INTO covid_19.us_usa (`Date`, Tot_Cases, Tot_Deaths)
SELECT
	CONVERT(`Date`, DATE) AS `Date`,
	CONVERT(Cases, SIGNED) AS Tot_Cases,
	CONVERT(Deaths, SIGNED) AS Tot_Deaths
FROM covid_19.us_usa_csv
ORDER BY `Date`;


INSERT IGNORE INTO covid_19.us_states (`Date`, State, FIPS, Tot_Cases, Tot_Deaths)
SELECT
	CONVERT (`Date`, DATE) AS `Date`,
	State,
	CONVERT(FIPS, UNSIGNED) * 1000 AS FIPS,
	CONVERT(Cases, SIGNED) AS Tot_Cases,
	CONVERT(Deaths, SIGNED) AS Tot_Deaths
FROM covid_19.us_states_csv
ORDER BY State, `Date`;


INSERT IGNORE INTO covid_19.us_counties (`Date`, State, County, FIPS, Tot_Cases, Tot_Deaths)
SELECT
	CONVERT (`Date`, DATE) AS Date,
	State,
	County,
	CONVERT(FIPS, UNSIGNED) AS FIPS,
	CONVERT(Cases, SIGNED) AS Tot_Cases,
	CONVERT(Deaths, SIGNED) AS Tot_Deaths
FROM covid_19.us_counties_csv
ORDER BY State, County, Date;



-- Update table with joined offset table to give New_Cases and New Deaths

UPDATE covid_19.us_usa,
	(SELECT
		T1.Row_ID,
		CASE
			WHEN T2.Row_ID IS NULL		THEN T1.Tot_Cases
			ELSE T1.Tot_Cases - T2.Tot_Cases
		END AS New_Cases1,
        CASE
			WHEN T2.Row_ID IS NULL		THEN T1.Tot_Deaths
			ELSE T1.Tot_Deaths - T2.Tot_Deaths
		END AS New_Deaths1
	FROM covid_19.us_usa AS T1
		LEFT JOIN covid_19.us_usa AS T2							
		ON T1.Row_ID - 1 = T2.Row_ID) AS New_Values
SET
	covid_19.us_usa.New_Cases = New_Values.New_Cases1,
    covid_19.us_usa.New_Deaths = New_Values.New_Deaths1
WHERE covid_19.us_usa.Row_ID = New_Values.Row_ID;


 UPDATE covid_19.us_states,
	(SELECT
		T1.Row_ID,
		CASE
			WHEN T2.Row_ID IS NULL				THEN T1.Tot_Cases
			WHEN (T1.State <> T2.State)		THEN T1.Tot_Cases
			ELSE T1.Tot_Cases - T2.Tot_Cases
		END AS New_Cases1,
        CASE
			WHEN T2.Row_ID IS NULL				THEN T1.Tot_Deaths
			WHEN (T1.State <> T2.State)		THEN T1.Tot_Deaths
			ELSE T1.Tot_Deaths - T2.Tot_Deaths
		END AS New_Deaths1
	 FROM covid_19.us_states AS T1
		LEFT JOIN covid_19.us_states AS T2							
		ON T1.Row_ID - 1 = T2.Row_ID) AS New_Values
SET
	covid_19.us_states.New_Cases = New_Values.New_Cases1,
	covid_19.us_states.New_Deaths = New_Values.New_Deaths1
WHERE covid_19.us_states.Row_ID = New_Values.Row_ID;


 UPDATE	covid_19.us_counties,
	(SELECT
		T1.Row_ID,
		CASE
			WHEN T2.Row_ID IS NULL											THEN T1.Tot_Cases
			WHEN (T1.State <> T2.State) OR (T1.County <> T2.County)		THEN T1.Tot_Cases
			ELSE T1.Tot_Cases - T2.Tot_Cases
		END AS New_Cases1,
        CASE
			WHEN T2.Row_ID IS NULL											THEN T1.Tot_Deaths
			WHEN (T1.State <> T2.State) OR (T1.County <> T2.County)		THEN T1.Tot_Deaths
			ELSE T1.Tot_Deaths - T2.Tot_Deaths
		END AS New_Deaths1
	 FROM covid_19.us_counties AS T1
		LEFT JOIN covid_19.us_counties AS T2							
		ON T1.Row_ID - 1 = T2.Row_ID) AS New_Values
SET
	covid_19.us_counties.New_Cases = New_Values.New_Cases1,
	covid_19.us_counties.New_Deaths = New_Values.New_Deaths1
WHERE covid_19.us_counties.Row_ID = New_Values.Row_ID;



-- UPDATE 'FIPS' from 'covid_19.census_county_2019'  (no UPDATE needed for 'covid_19.census_states')

UPDATE	covid_19.us_counties,
	(SELECT FIPS, County, State
     FROM covid_19.census_county) AS C
SET covid_19.us_counties.FIPS = C.FIPS
WHERE
	covid_19.us_counties.County = C.County AND
	covid_19.us_counties.State = C.State AND
	covid_19.us_counties.FIPS = 0;
	
	
	
-- New York City split into the 5 boroughs (Counties)

-- INSERT "Bronx" rows

INSERT IGNORE INTO covid_19.us_counties ( 
	`Date`,
	 State,
	 County,
	 FIPS,
	 Tot_Cases,
	 New_Cases,
	 Tot_Deaths,
	 New_Deaths
)
SELECT
	`Date`,
	 "New York",
	 "Bronx",
	 "36005",
	 CAST((Tot_Cases * 0.17) AS DECIMAL(11,1)),
	 CAST((New_Cases * 0.17) AS DECIMAL(11,1)),
	 CAST((Tot_Deaths * 0.17) AS DECIMAL(11,1)),
	 CAST((New_Deaths * 0.17) AS DECIMAL(11,1))
FROM covid_19.us_counties
WHERE FIPS = 3651000;


-- INSERT "Kings" (Brooklyn) rows

INSERT IGNORE INTO covid_19.us_counties ( 
	`Date`,
	 State,
	 County,
	 FIPS,
	 Tot_Cases,
	 New_Cases,
	 Tot_Deaths,
     New_Deaths
)
SELECT
	`Date`,
	 "New York",
	 "Kings",
	 "36047",
	 CAST((Tot_Cases * 0.17) AS DECIMAL(11,1)),
	 CAST((New_Cases * 0.17) AS DECIMAL(11,1)),
	 CAST((Tot_Deaths * 0.17) AS DECIMAL(11,1)),
	 CAST((New_Deaths * 0.17) AS DECIMAL(11,1))
FROM covid_19.us_counties
WHERE FIPS = 3651000;


-- INSERT "New York" (Manhattan) rows

INSERT IGNORE INTO covid_19.us_counties ( 
	`Date`,
	 State,
	 County,
	 FIPS,
	 Tot_Cases,
	 New_Cases,
	 Tot_Deaths,
     New_Deaths
)
SELECT
	`Date`,
	 "New York",
	 "New York",
	 "36061",
	 CAST((Tot_Cases * 0.17) AS DECIMAL(11,1)),
	 CAST((New_Cases * 0.17) AS DECIMAL(11,1)),
	 CAST((Tot_Deaths * 0.17) AS DECIMAL(11,1)),
	 CAST((New_Deaths * 0.17) AS DECIMAL(11,1))
FROM covid_19.us_counties
WHERE FIPS = 3651000;


-- INSERT "Queens" rows

INSERT IGNORE INTO covid_19.us_counties ( 
	`Date`,
	 State,
	 County,
	 FIPS,
	 Tot_Cases,
	 New_Cases,
	 Tot_Deaths,
     New_Deaths
)
SELECT
	`Date`,
	 "New York",
	 "Queens",
	 "36081",
	 CAST((Tot_Cases * 0.17) AS DECIMAL(11,1)),
	 CAST((New_Cases * 0.17) AS DECIMAL(11,1)),
	 CAST((Tot_Deaths * 0.17) AS DECIMAL(11,1)),
	 CAST((New_Deaths * 0.17) AS DECIMAL(11,1))
FROM covid_19.us_counties
WHERE FIPS = 3651000;


-- INSERT "Richmond" (Staten Island) rows

INSERT IGNORE INTO covid_19.us_counties ( 
	`Date`,
	 State,
	 County,
	 FIPS,
	 Tot_Cases,
	 New_Cases,
	 Tot_Deaths,
     New_Deaths
)
SELECT
	`Date`,
	 "New York",
	 "Richmond",
	 "36085",
	 CAST((Tot_Cases * 0.17) AS DECIMAL(11,1)),
	 CAST((New_Cases * 0.17) AS DECIMAL(11,1)),
	 CAST((Tot_Deaths * 0.17) AS DECIMAL(11,1)),
	 CAST((New_Deaths * 0.17) AS DECIMAL(11,1))
FROM covid_19.us_counties
WHERE FIPS = 3651000;



-- EXPORT CSV files

SELECT 'Row_ID', 'Date', 'Tot_Cases', 'New_Cases', 'Tot_Deaths', 'New_Deaths'
UNION
SELECT * FROM covid_19.us_usa
INTO OUTFILE 'C:\\COVID-19\\US_USA.csv'
FIELDS OPTIONALLY ENCLOSED BY '' TERMINATED BY ',' ESCAPED BY '\\'
LINES TERMINATED BY '\n';

SELECT 'Row_ID', 'Date', 'State', 'FIPS', 'Tot_Cases', 'New_Cases', 'Tot_Deaths', 'New_Deaths'
UNION
SELECT * FROM covid_19.us_states
INTO OUTFILE 'C:\\COVID-19\\US_States.csv'
FIELDS OPTIONALLY ENCLOSED BY '' TERMINATED BY ',' ESCAPED BY '\\'
LINES TERMINATED BY '\n';

SELECT 'Row_ID', 'Date', 'State', 'County', 'FIPS', 'Tot_Cases', 'New_Cases', 'Tot_Deaths', 'New_Deaths'
UNION
SELECT * FROM covid_19.us_counties
INTO OUTFILE 'C:\\COVID-19\\US_Counties.csv'
FIELDS OPTIONALLY ENCLOSED BY '' TERMINATED BY ',' ESCAPED BY '\\'
LINES TERMINATED BY '\n';


--  NY Times COVID-19 data CSV files are ready to be loaded to Tableau Public along with Census CSV files