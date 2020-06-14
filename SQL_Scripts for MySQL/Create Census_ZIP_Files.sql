-- ZIP Code Files


-- Create ME ZIP-Code CSV 2019 census import table from
--    www.https://www.maine-demographics.com/zip_codes_by_population

CREATE TABLE covid.zip_census_me_csv (
	ZIP TEXT,
	Population INT DEFAULT NULL)
ENGINE=InnoDB DEFAULT
CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM covid_19.zip_census_me_csv;


-- Create ZIP-Code working table

CREATE TABLE covid_19.zip_census_me (
	ZIP CHAR(5) PRIMARY KEY,
	Population INT)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM covid_19.zip_census_me;


-- Create US Census ZIP-code file - 2015 IRS data from
--    https://www.unitedstateszipcodes.org/zip-code-database/

CREATE TABLE covid_19.zip_code_database (
	ZIP CHAR(5) PRIMARY KEY,
	`Type`  VARCHAR(10),
	Decommissioned TINYINT,
	Primary_City VARCHAR(30),
	Acceptable_Cities VARCHAR(290),
	Unacceptable_Cities VARCHAR(2210),
	State CHAR(2),
	County VARCHAR(40),
	Timezone VARCHAR(30),
	Area_Codes VARCHAR(40),
	World_Region CHAR(2),
	Country CHAR(2),
	Latitude DECIMAL(6,2),
	Longitude DECIMAL(5,2),
	IRS_est_population_2015 MEDIUMINT)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;



-- INSERT data from CSV files

INSERT INTO covid_19.zip_census_me (ZIP, Population)
SELECT
	ZIP, 
	CONVERT(Population, UNSIGNED) AS Population
FROM covid_19.zip_census_me_csv
ORDER BY ZIP;


INSERT INTO covid_19.zip_code_database (ZIP,`Type`, Decommissioned, Primary_City, Acceptable_Cities, 	Unacceptable_Cities, State, County, Timezone, Area_Codes, World_Region, Country, Latitude, Longitude, IRS_est_population_2015)
SELECT
	ZIP,
	`Type`,
	CONVERT(Decommissioned, UNSIGNED) AS Decommisioned,
	Primary_City,
	Acceptable_Cities,
	Unacceptable_Cities,
	State,
	County,
	Timezone,
	Area_Codes,
	World_Region,
	Country,
	CONVERT(Latitude, SIGNED) AS Latitude,
	CONVERT(Longitude, SIGNED) AS Longitude,
	CONVERT(IRS_estimated_population_2015, UNSIGNED) AS IRS_est_population_2015
FROM covid_19.zip_code_database_csv
ORDER BY State, County;

SELECT * FROM covid_19.zip_code_database;


-- Compare data from 2019 ME census file and IR-derived 2015 US Census file 

SELECT C.*, Z.*
FROM
	covid_19.zip_census_me AS C,
	covid_19.zip_code_database AS Z
WHERE
	C.ZIP = Z.ZIP AND
	C.Population < Z.IRS_est_population_2015;