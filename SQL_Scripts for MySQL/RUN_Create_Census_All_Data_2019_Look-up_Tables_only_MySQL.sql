-- RUNTIME For creation of US Census Bureau demographic data from 2019-07-01, used for all population-based calculations
-- This needs to be created before the Data is imported	 

-- For MySQL - Direct connection to Tableau Desktop

-- William L. Salomon, MD MS MPH
-- Clinical Metrics, LLC
-- Revised 2020-06-01


-- CREATE a Schema (Database) 'covid_19' if one does not already exist

CREATE DATABASE IF NOT EXISTS covid_19;


-- CREATE the 'census_all_data_csv' table for US Census State, County 2019-07-01 data. (This is a temporary table)

DROP TABLE IF EXISTS covid_19.census_all_data_csv;

CREATE TABLE covid_19.census_all_data_csv (
	Sum_Level VARCHAR(50),
	Region_FIPS VARCHAR(50),
	Division_FIPS VARCHAR(50),
	State_FIPS VARCHAR(50),
	County_FIPS VARCHAR(50),
	FIPS MEDIUMINT PRIMARY KEY,
	State VARCHAR(50),
	County VARCHAR(50),
	Pop_2019 VARCHAR(50)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;


-- IMPORT the CSV data from 'Census_All_Data.csv'

LOAD DATA INFILE 'C:\\COVID-19\\Census_All_Data.csv'
	INTO TABLE covid_19.census_all_data_CSV
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;



-- CREATE the 'census_all_data' table

DROP TABLE IF EXISTS covid_19.census_all_data;

CREATE TABLE covid_19.census_all_data (
	Sum_Level TINYINT,
	Region_FIPS TINYINT,
	Division_FIPS TINYINT,
	State_FIPS TINYINT,
	County_FIPS SMALLINT,
	FIPS MEDIUMINT,
	State VARCHAR(50),
	County VARCHAR(50),
	Pop_2019 INT,
	INDEX (FIPS, State, County))
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

	
-- INSERT from 'covid_19.census_all_data_csv' into 'covid_19.census_all_data' with data types converted in the SELECT statement, included, ordered by State, County

INSERT INTO covid_19.census_all_data (Sum_Level, Region_FIPS, Division_FIPS, State_FIPS, County_FIPS, FIPS, State,
    County, Pop_2019)
SELECT
	CONVERT(Sum_Level, UNSIGNED) AS Sum_Level,
	CONVERT(Region_FIPS, UNSIGNED) AS Region_FIPS,
	CONVERT(Division_FIPS, UNSIGNED) AS Division_FIPS,
	CONVERT(State_FIPS, UNSIGNED) AS State_FIPS,
	CONVERT(County_FIPS, UNSIGNED) AS County_FIPS,
	CONVERT(FIPS, UNSIGNED) AS FIPS,
	State,
	County,
	CONVERT(Pop_2019, UNSIGNED) AS Pop_2019
FROM covid_19.census_all_data_csv
ORDER BY State, County;


-- INSERT into 'covid_19.census_all_data' a row for each state for "Unknown" Counties
	
INSERT INTO covid_19.census_all_data (Sum_Level, Region_FIPS, Division_FIPS, State_FIPS, County_FIPS, FIPS, State,
    County, Pop_2019)
SELECT
	20 AS Sum_Level,
	Region_FIPS,
	Division_FIPS,
	State_FIPS,
	999 AS County_FIPS,
	((State_FIPS * 1000) + 999) AS FIPS,
	State,
	"Unknown" AS County,
	1 AS Pop_2019
FROM covid_19.census_all_data
WHERE
	FIPS > 0 AND
    FIPS NOT IN (2938000, 3651000) AND
    State_FIPS NOT IN (11, 66, 69, 72, 78)
GROUP BY State;



DROP TABLE IF EXISTS covid_19.census_all_data;

CREATE TABLE covid_19.census_all_data (
	Sum_Level TINYINT,
	Region_FIPS TINYINT,
	Division_FIPS TINYINT,
	State_FIPS TINYINT,
	County_FIPS SMALLINT,
	FIPS MEDIUMINT,
	State VARCHAR(50),
	County VARCHAR(50),
	Pop_2019 INT,
	INDEX (FIPS, State, County))
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

	
-- INSERT from 'covid_19.census_all_data_csv' into 'covid_19.census_all_data' with data types converted in the SELECT statement, included, ordered by State, County

INSERT INTO covid_19.census_all_data (Sum_Level, Region_FIPS, Division_FIPS, State_FIPS, County_FIPS, FIPS, State,
    County, Pop_2019)
SELECT
	CONVERT(Sum_Level, UNSIGNED) AS Sum_Level,
	CONVERT(Region_FIPS, UNSIGNED) AS Region_FIPS,
	CONVERT(Division_FIPS, UNSIGNED) AS Division_FIPS,
	CONVERT(State_FIPS, UNSIGNED) AS State_FIPS,
	CONVERT(County_FIPS, UNSIGNED) AS County_FIPS,
	CONVERT(FIPS, UNSIGNED) AS FIPS,
	State,
	County,
	CONVERT(Pop_2019, UNSIGNED) AS Pop_2019
FROM covid_19.census_all_data_csv
ORDER BY State, County;


-- INSERT into 'covid_19.census_all_data' a row for each state for "Unknown" Counties
	
INSERT INTO covid_19.census_all_data (Sum_Level, Region_FIPS, Division_FIPS, State_FIPS, County_FIPS, FIPS, State,
    County, Pop_2019)
SELECT
	20 AS Sum_Level,
	Region_FIPS,
	Division_FIPS,
	State_FIPS,
	999 AS County_FIPS,
	((State_FIPS * 1000) + 999) AS FIPS,
	State,
	"Unknown" AS County,
	1 AS Pop_2019
FROM covid_19.census_all_data
WHERE
	FIPS > 0 AND
    FIPS NOT IN (2938000, 3651000) AND
    State_FIPS NOT IN (11, 60, 64, 66, 67, 68, 69, 70, 71, 72, 74, 76, 78, 79, 81, 84, 86, 89, 95)
GROUP BY State;

-- Tables ready for use with NY Times COVID-19 data tables