-- For creation of US Census Bureau demographic data from 2019-07-01, used for all population-based calculations	 

-- For MySQL

-- William L. Salomon, MD MS MPH
-- Clinical Metrics, LLC
-- Revised 2020-06-02


-- Source - https://www.census.gov/data/datasets/time-series/demo/popest/2010s-counties-total.html
-- Data description - https://www2.census.gov/programs-surveys/popest/technical-documentation/methodology/2010-2019/natstcopr-methv2.pdf
-- Data layout - https://www2.census.gov/programs-surveys/popest/datasets/2010-2019/counties/totals/co-est2019-alldata.pdf
-- Data - https://www2.census.gov/programs-surveys/popest/datasets/2010-2019/counties/totals/co-est2019-alldata.csv
-- Data transformed by combining 2-digit State FIPS and 3-digit County FIPS to form combined 5-digit FIPS 
-- FIPS are numbers, but when combined are characters strings some cases have leading 0's to padded up to 5 characters.
-- FIPS for "Kansas City, MO" and "New York City, NY" a local 7 digit codes
 
-- Summary levels (SUM_LEVEL)
--     50 - County
--     40 - State
--     30 - "New York City, NY", "Kansas City, MO"   (added)
--     20 - "Unknown" County  (added)
--     10 - "USA"             (added)

-- The original file 'co-est2019-alldata.csv' has 3193 rows
-- The cleaned up data is in 'Census_All_Data_2019.csv'

-- Manual edits to 'Census_All_Data.csv' in Excel before loading to 'covid_19.census_all_data_2019_csv'


-- ***** This script only needs to be run once (or until new Census data appears) *****

-- The Downloaded 'Census_est_2019.csv' file has had one row added for "New York City"
-- This is in addition to the existing 5 boroughs - New York (Manhattan), Kings (Brooklyn), Queens, Bronx, and Richmond (Staten Island)
-- The population of New York City is the sum of 5 boroughs
-- If all counties popuations are added together (including New York City), New York City would had been counted twice
-- COVID-19 data does not list the 5 boroughs, just New York City only, hence this "alteration" of the original data
-- The FIPS was created by concatenating the 1-2 digit State_FIPS and the 1-3 digits County_FIPS (padded with 0's
--   when need to make a 3-digit number.  The resulting FIPS is 4 or 5 digits.
-- Kansas City, MO is missing being in several Counties - NY Times has allocated non-"Kansas City" to Jackson, Clay, Cass & Platte Counties
-- However, a number of states in the COVID-19 data have FIPS = "32767"; that would be in Nevada (State = '32") but does not exist.
-- There, a JOIN using States and Counties is used instead of FIPS.

-- The added rows are
--   Sum_Level, Region FIPS, Division_FIPS, State_FIPS, County_FIPS, FIPS,    State,         County,   Pop_Est_2019 
--    ( 30,	         2,          4,            29,           380,   2938000, "Missouri", "Kansas City"  ,    491918 )
--    ( 30,          1,          2,            36,           510,   3651000, "New York", "New York City",   8336817 )
         
-- A row is also added for the the entire US
--    ( 10,          0,          0,             0,             0,       0,    "USA"   ,       "USA"   , 328239523 )

--  Rows have been added for Outlying Territories for both 	'State' as Sum_Level

-- Scripted modifications to 'covid_19.census_all_data_2019_csv' after loading (occurring below)

-- The table will have rows inserted in SQL for "Unknown" Counties in the form of where the "x" is from the State
--    ( 20,          x,          x,            xx,           999,   xx999,  "State"  ,     "Unknown"   ,      1   )

-- Several exploratory queries and JOINS were done examnine COVID-19 / Censes data integrity
-- See 'Create_Table_for_Merged_COVID-19_and Census_2019_Data.sql'


-- CREATE a Schema (Database) 'covid_19' if one does not already exist

CREATE DATABASE IF NOT EXISTS covid_19;



-- CREATE the 'census_all_data_csv' table for US Census State, County 2019-07-01 data. (This is a temporary table)

-- All values are VARCHAR(50) on import
-- 'State' and 'County' lengths are maximally 44, so VARCHAR is set to 50 for safety
-- Rows ordered by FIPS (Primary Key)

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


-- Import the CSV data from 'Census_All_Data.csv'
-- It is highly suggested that you create a directory C:\COVID-19 since this will shorten file names

-- Windows file names require pre-prending of an additional "\" for files paths in this script
--      'C:\COVID-10\Census_All_Data.csv'
--    becomes
--      'C:\\COVID-19\\Census_All_Data.csv'

-- The one (1) IGNORED row is the Column Name header

LOAD DATA INFILE 'C:\\COVID-19\\Census_All_Data.csv'
	INTO TABLE covid_19.census_all_data_CSV
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


-- Check import

SELECT COUNT(*) FROM covid_19.census_all_data_csv;		-- 3232 rows, includes the adds for "Kansas City, MO", "New York City, NY",  and "USA"
														-- All SUM_LEVELs

SELECT * FROM covid_19.census_all_data_csv;				-- 3232 rows, includes the adds for "Kansas City, MO", "New York City, NY",  and "USA"
														-- All SUM_LEVELs

                                                       
SELECT SUM_LEVEL, FIPS, State, County FROM covid_19.census_all_data_csv		--  4 rows, includes NY as a State, County of NY, and NYC, and Kansas City
WHERE																		-- SUM-LEVELs 50, 40 and 30
	(State = "New York"  AND County LIKE "New York%") OR
    (State = "Missouri"  AND County = "Kansas City");


SELECT COUNT(*) FROM covid_19.census_all_data_csv		-- 70 States, includes DC, USA, and Territories (excludes "Kansas City, MO", "New York City, NY") 
WHERE
	MOD(FIPS, 1000) = 0 AND							-- SUM_LEVELs 40 and 10
	FIPS NOT IN (2938000, 3651000);

SELECT * FROM covid_19.census_all_data_csv				-- 70 States, includes DC, USA, and Territories (excludes "Kansas City, MO", "New York City, NY")
WHERE													-- SUM_LEVELs 40 and 10
	MOD(FIPS, 1000) = 0 AND
	FIPS NOT IN (2938000, 3651000);


SELECT COUNT(*) FROM covid_19.census_all_data_csv		-- 69 States, including DC (only) and Territories, no USA
WHERE													-- SUM_LEVEL 40
	MOD(FIPS, 1000) = 0 AND
	FIPS <> 0 AND
	FIPS NOT IN (2938000, 3651000);

SELECT * FROM covid_19.census_all_data_csv				-- 69 States, including DC (only) and Territories, No USA
WHERE													-- SUM_LEVEL 40
	MOD(FIPS, 1000) = 0 AND
    FIPS <> 0 AND
	FIPS NOT IN (2938000, 3651000);


SELECT COUNT(*) FROM covid_19.census_all_data_csv	-- 3162 Counties (excludes States, includes Counties with same name as State AR, DC, HI, ID, IO, NY OK, UT)
WHERE												-- SUM_LEVELs 50 and 30, and 20 for US Territories (8 rows)
	MOD(FIPS, 1000) <> 0 OR
    FIPS IN (2938000, 3651000);

SELECT * FROM covid_19.census_all_data_csv			-- 3162 Counties (excludes States, includes Counties with same name as State AR, DC, HI, ID, IO, NY OK, UT
WHERE												-- SUM_LEVELs 50 and 30, and 20 for US Territories (8 rows)
	MOD(FIPS, 1000) <> 0 OR
    FIPS IN (2938000, 3651000);
                  


-- CREATE the 'census_all_data' table

-- Holds transferred data from 'census_all_data_csv' table
-- Data types will be converted during INSERT
-- Data sorted by FIPS
-- 'State' maximum length 24 (Northern Mariana Islands)
-- 'County' maximum length 31 (Southeast Fairbanks Census Area)
-- In MySQL columns are *not* NULLable unless specified otherwise (NULL)

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
	INDEX (State, County))
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

	
-- INSERT 'us_counties_CSV' with data types converted in the SELECT statement, included, ordered by State, County

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


-- Check import

SELECT COUNT(*) FROM covid_19.census_all_data;		-- 3232 rows, includes the adds for "Kansas City, MO", "New York City, NY", and "USA"
													-- All SUM_LEVELs

SELECT * FROM covid_19.census_all_data;				-- 3232 rows, includes the adds for "Kansas City, MO", "New York City, NY", and "USA"
													-- All SUM_LEVELs


INSERT INTO covid_19.census_all_data (Sum_Level, Region_FIPS, Division_FIPS, State_FIPS, County_FIPS, FIPS, State,
    County, Pop_2019)							-- 50 rows are inserted (the 50 States only, not DC or Territories)
    SELECT											-- Territories have already been inserted with Population = State Population, and DC doesn't need one
		0 AS Sum_Level,
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
    FIPS NOT IN (2938000, 3651000) AND					-- Leaves out "Kansas City, MO" and "New York City, NY" as these are multiples of 1,000
    State_FIPS NOT IN (11, 66, 69, 72, 78)
GROUP BY State;


-- Check the Insert

SELECT COUNT(*) FROM covid_19.census_all_data			-- 67 rows (includes Territories, not DC)
WHERE County = "Unknown";

SELECT * FROM covid_19.census_all_data					-- 67 rows (includes Territories, not DC)
WHERE County = "Unknown";

-- The above data is ready to be used in queries, but...
--    Has redundant New York City, NY population
--    Has redundant Kansas City, MO population
--    Has redundant USA population

-- A check query to make sure all States are present (indicated by County_FIPS - 0 and FIPS is a multiple of 1000)

SELECT COUNT(*)											-- 69 rows, includes DC and Territories (not "Kansas City, MO", "New York City, NY" or USA)
FROM covid_19.census_all_data
WHERE
	MOD(FIPS, 1000) = 0 AND
    FIPS <> 0 AND
	FIPS NOT IN (2938000, 3651000);



SELECT *
FROM covid_19.census_all_data						-- 69 rows, includes DC and Territories (not "Kansas City, MO", "New York City, NY" or USA)
WHERE
	MOD(FIPS, 1000) = 0 AND
    FIPS <> 0 AND
	FIPS NOT IN (2938000, 3651000);



-- A check query to make sure all Counties are present (indicated by County_FIPS - 0 and FIPS is a multiple of 1000)

SELECT COUNT(*) FROM covid_19.census_all_data			-- 3212 rows, includes "Unknown" (not for DC), "New York City", and "Kansas City"
WHERE
	MOD(FIPS, 1000) <> 0 OR
	FIPS IN (2938000, 3651000);

SELECT * FROM covid_19.census_all_data					-- 3212 rows, includes "Unknown" (not for DC), "New York City", and "Kansas City"
WHERE
	MOD(FIPS, 1000) <> 0 OR
	FIPS IN (2938000, 3651000);
    
    
-- A check query to make sure all "Unknown" Counties are present (indicated by County_FIPS - 0 and FIPS is a multiple of 1000)

SELECT COUNT(*) FROM covid_19.census_all_data				-- 67 rows  (no DC)
WHERE
	MOD(FIPS, 1000) <> 0 AND
    County = "Unknown";

SELECT * FROM covid_19.census_all_data						-- 67 rows  (no DC)
WHERE
	MOD(FIPS, 1000) <> 0 AND
    County = "Unknown";


-- Using the above check shows that all state entities can be removed,
--     but if the population is summed, the US Population will have New York City counted twice.


-- CREATE a VIEW of all States (Sum_Level = 40)
-- This the VIEW used for all State level demograpahic data
-- This is required as AK, DC, HI, ID, IO, OK, UT have counties with the state name
-- Excludes USA


-- CREATE TABLES for State and County

DROP TABLE IF EXISTS covid_19.census_state;

CREATE TABLE covid_19.census_state (
	FIPS MEDIUMINT,
	State VARCHAR(50),
	Pop_2019 INT,
	INDEX (FIPS, State))
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS covid_19.census_county;

CREATE TABLE covid_19.census_county (
	FIPS MEDIUMINT,
	State VARCHAR(50),
	County VARCHAR(50),
	Pop_2019 INT,
    INDEX (FIPS, State, County))
	ENGINE=InnoDB
	DEFAULT CHARSET=utf8mb4
	COLLATE=utf8mb4_0900_ai_ci;


-- INSERT values into State (Sum_Level = 40)

INSERT INTO covid_19.census_state (FIPS, State, Pop_2019)
SELECT
	FIPS,
	State,
	Pop_2019
FROM covid_19.census_all_data
WHERE Sum_Level = 40
ORDER BY State;


-- INSERT values into County (Sum_Level = 50, 30 (NY City, NY & Kansas City, MO), 20 ("Unknown"))

INSERT INTO covid_19.census_county (FIPS, State, County, Pop_2019)
SELECT
	FIPS,
	State,
	County,
	Pop_2019
FROM covid_19.census_all_data
WHERE Sum_Level IN (50, 30, 20)
ORDER BY State, County;


-- Check the INSERTS

SELECT COUNT(*)											-- 69 rows
FROM covid_19.census_state;

SELECT *												-- 69 rows
FROM covid_19.census_state;


SELECT COUNT(*)											-- 3212 rows
FROM covid_19.census_county;

SELECT *												-- 3212 rows
FROM covid_19.census_county;



-- Check "New York City" and the 5 boroughs (Counties)

SELECT *												-- 6 rows
FROM covid_19.census_county
WHERE FIPS IN (36005, 36047, 36061, 36081, 36085, 36998);

SELECT *												-- 2 rows ("Kansas City" AND "New York City")
FROM covid_19.census_county
WHERE FIPS IN (2938000, 3651000);



-- Script stops here for Database direct connection to Tableau Desktop



-- EXPORTS for all levels

-- EXPORT to 'Census_All_2019.csv'  (be sure to delete exsting file, otherwise throws error)
-- Yields 3283 rows - 1 header, 3282 data

SELECT 'State','County','FIPS','Pop_2019'
UNION
SELECT State, County, FIPS , Pop_2019
FROM covid_19.census_all_data
INTO OUTFILE 'C:\\COVID-19\\Census_All.csv'
FIELDS OPTIONALLY ENCLOSED BY '' TERMINATED BY ',' ESCAPED BY '\\'
LINES TERMINATED BY '\n';


-- EXPORT to 'Census_State_2019.csv'  (be sure to delete exsting file, otherwise throws error)
-- Yields 70 rows - 1 header, 69 data

SELECT 'State', 'FIPS','Pop_2019'
UNION
SELECT State, FIPS, Pop_2019
FROM covid_19.census_state
INTO OUTFILE 'C:\\COVID-19\\Census_State.csv'
FIELDS OPTIONALLY ENCLOSED BY '' TERMINATED BY ',' ESCAPED BY '\\'
LINES TERMINATED BY '\n';


-- EXPORT to 'Census_County_2019.csv'  (be sure to delete exsting file, otherwise throws error)
-- Yields 3213 rows - 1 header, 3212 data

SELECT 'State','County','FIPS','Pop_2019'
UNION
SELECT State, County, FIPS , Pop_2019
FROM covid_19.census_county
INTO OUTFILE 'C:\\COVID-19\\Census_County.csv'
FIELDS OPTIONALLY ENCLOSED BY '' TERMINATED BY ',' ESCAPED BY '\\'
LINES TERMINATED BY '\n';