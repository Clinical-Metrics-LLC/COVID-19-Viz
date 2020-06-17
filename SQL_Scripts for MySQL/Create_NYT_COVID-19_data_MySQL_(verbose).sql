-- Complete SQL for 'us', 'us_usa_csv', 'us_states', 'us_states_csv', 'us_counties' and 'us_counties_csv' table creation,
--    import from 'US_USA_CS.csv', 'US_States_CSV.csv', 'US_Counties_CSV.csv', and updating table with New_Cases and New_Deaths

-- For MySQL


-- William L. Salomon, MD MS MPH
-- Clinical Metrics, LLC
-- Revised 2020-06-17

-- Data from NY Times Github covid_19 data,
--    orginally in Date order only begining in Washington 2020-01-21
-- https://github.com/nytimes/covid-19-data/archive/master.zip

-- The initialization file 'My.ini'
--    must be changed with a text editor like Notepad
--  Back up the 'my.ini' by saving it as 'my.ini.bak'
--  Change the following parameter
--  	  # Secure File Priv.
--  	  secure-file-priv="C:/ProgramData/MySQL/MySQL Server 8.0/Uploads"
-- to
--  	  # Secure File Priv.
--  	  secure-file-priv=""
-- Then save the change in 'my.ini'
-- Simply deleting the this item will cause it to resort to the Default path, and cause an error
--   if a file is imported from anywhere else.


-- THE DATA DOWNLOAD AND DATABASE LOADING AND TRANSFORMATION PROCESS FOLLOWS BELOW 
-- At each command, set your cursor somewhere over the command and press <Ctrl><Enter> to execute it


-- Download the .zip file from
--      https://github.com/nytimes/covid-19-data/archive/master.zip
--  with your browser

-- Count rows in the CSV file by opening the file with Excel
-- Extract the us.csv file and rename as_us_usa_CSV.csv
-- Extract the us-states.csv file and rename as US_States_CSV.csv
-- Extract the us-counties.csv file and rename US_Counties_CSV.csv


-- This whole download and extraction process has been automated by 'Extracts_us_counties_csv.bat'
--   and should take less then a 1 minute, depending on the latency for github for reaching the web-page

-- From this point, running all the commands below should take less than 1 minute (really!)



-- Prime the database for prolonged JOINS (default is 30 sec.)
show variables;

SET net_read_timeout = 600;
SET net_write_timeout = 600;
SET innodb_lock_wait_timeout = 600;



-- CREATE a Schema (Database) 'covid_19' if one does not already exist

CREATE DATABASE IF NOT EXISTS covid_19;



-- CREATE 'us_usa_csv', 'us_states_csv', 'us_counties_csv' table for CSV import

-- All values are VARCHAR(50) on import
-- Rows ordered by Date only
-- CSV data in format "date,county,State,fips,cases,deaths"
-- 'FIPS' are numbers of 4 or 5 digits
--     Counties the last 3 digits are 1, 2, 3 digits, padded with 0's to give 3 digits
--     states are the leading 1 or 2 digits
--     The State digits are concatenated with the County digits to give the 4 or digit number
--     These are stored as INT not VARCHAR 
--    NULL data is indicated in the .csv file as "date,county,state,,cases,deaths"
--    These NULLs become empty strings '' in Table (not NULLs)
--    They are usually associated with 'Unknown' counties
-- In MySQL, columns are *not* NULLable unless specified as NULL

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



-- Import the CSV data from 'us_usa_csv.csv, 'US_states.csv', and 'us_counties_csv.csv'
-- This assumes the your browser saves files in your local Dowloads directory (folder)
--   and has been moved to a C:\COVID-19 directory 
-- This is automated by a batch file - 'Extracts_us_counties_csv.bat'

-- Windows file names require pre-prending of an additional "\" for files paths in this script
--      'C:\COVID-19\US_USA_CSV.csv'
--      'C:\COVID-19\US_States_CSV.csv'
--      'C:\COVID-19\US_Counties_CSV.csv'
--    becomes
--      'C:\\COVID-19\\US_USA_CSV.csv'
--      'C:\\COVID-19\\US_States_CSV.csv'
--      'C:\\COVID-19\\US_Counties_CSV.csv'

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



-- The data has now been imported, so  check that the number of rows is okay and
-- that the latest date is what you expect it tobe

SELECT COUNT(Date) AS 'Row_Count', MAX(Date) AS Latest_Date
FROM covid_19.us_usa_csv;

SELECT * FROM covid_19.us_usa_csv;

SELECT COUNT(Date) AS 'Row_Count', MAX(Date) AS Latest_Date
FROM covid_19.us_states_csv;

SELECT * FROM covid_19.us_states_csv;

SELECT COUNT(Date) AS 'Row_Count', MAX(Date) AS Latest_Date
FROM covid_19.us_counties_csv;

SELECT * FROM covid_19.us_counties_csv;



-- Now transfer the data from 'us_usa_csv', 'us_states_csv, 'us_counties_csv' to
-- 'us', 'us_states', 'us_counties'

-- CREATE 'us', 'us_states', 'us_counties' tables

-- Holds transferred data from 'us_usa_csv', 'us_states_csv, 'us_counties_csv' tables
-- Data types will be converted during INSERT which was sorted by 'State', 'County', 'Date'
-- Adds auto-generated 'Row_ID; to maintain sort
-- 'FIPS' NULL data which was indicated as date,county,State,,cases,deaths becomes '' in Table (not NULL)
--     usually associated with "Unknown" counties
--     When transferred to the final table, these are converted to 0 with a conversion warning
--     as the result of the IGNORE (warning) keyword.
-- 'FIPS' codes are 4-5 digits numbers (Except for local level codes for "Kansas City, MO" and "New York City, NY" which are 7 digits
--     County FIP is a 3 digit number (9in origtinal Census file 1, 2, 3, gidgits padded with o'
--     County FIP is 1 or 2 digit number
--     The entire number is the concatentation of the 1 or 2 digit State and 3 digit county
--     This are stored as MEDIUMINT
-- State maximum length 24 (Northern Mariana Islands)
-- 'County' maximum length 31 (Southeast Fairbanks Census Area)
-- Cases & Deaths are stored as DECIMAL(11,1).
--    Ordinarily this would be as MEDIUMINT, but given the split for
--    "New York City" to the 5 buroughs this was carried to 1 decimal place
-- In MySQL columns are *not* NULLable unless specified otherwise (NULL)
-- The Indexes markedly speed up the run time


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

-- Values converted from VARCHAR to DATE and INT where needed
-- Rows sorted by 'State', 'County', then 'Date'
-- Throws a warning, but if Duration Time shows, it is complete

INSERT IGNORE INTO covid_19.us_usa (`Date`, Tot_Cases, Tot_Deaths)
SELECT
	CONVERT(`Date`, DATE) AS `Date`,
	CONVERT(Cases, SIGNED) AS Tot_Cases,
	CONVERT(Deaths, SIGNED) AS Tot_Deaths
FROM covid_19.us_usa_csv
ORDER BY `Date`;


INSERT IGNORE INTO covid_19.us_states (`Date`, State, FIPS, Tot_Cases, Tot_Deaths)
SELECT

	 CONVERT(`Date`, DATE) AS `Date`,
	 State,
	 CONVERT(FIPS, UNSIGNED) * 1000 AS FIPS,
	 CONVERT(Cases, SIGNED) AS Tot_Cases,
	 CONVERT(Deaths, SIGNED) AS Tot_Deaths
FROM covid_19.us_states_csv
ORDER BY State, `Date`;


INSERT IGNORE INTO covid_19.us_counties (`Date`, State, County, FIPS, Tot_Cases, Tot_Deaths)
SELECT
	 CONVERT(`Date`, DATE) AS `Date`,
	 State,
	 County,
	 CONVERT(FIPS, UNSIGNED) AS FIPS,
	 CONVERT(Cases, SIGNED) AS Tot_Cases,
	 CONVERT(Deaths, SIGNED) AS Tot_Deaths
FROM covid_19.us_counties_csv
ORDER BY State, County, Date;



-- Check the imported data

SELECT COUNT(*) FROM covid_19.us_usa;

SELECT * FROM covid_19.us_usa;

SELECT COUNT(*) FROM covid_19.us_states;

SELECT * FROM covid_19.us_states;

SELECT COUNT(*) FROM covid_19.us_counties;

SELECT * FROM covid_19.us_counties;



-- Update table with joined offset table to give New_Cases and New Deaths

-- The CASE clause deals with 3 situations
--    First row in JOINed tables has a NULL on right side of JOIN, so  New_Case = Today's Tot_Case
--    Today's State AND/OR 'County' has changed from yesterday, so New_Case = Today's Tot_Case
--    Today's State AND 'County' is the same as yesterday, so New_Case = Today's Tot_Case - Yesterday's Tot_Case  
-- The JOIN's Left side ('T1') joins to itself (the Right side) shifted down one row  ('T2')
--    This accomplishes a subtraction without using a Cursor

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


-- Check the update data - New_Cases and New_Deaths are no longer NULLs

SELECT COUNT(*) FROM covid_19.us_usa;

SELECT * FROM covid_19.us_usa;

SELECT COUNT(*) FROM covid_19.us_states;

SELECT * FROM covid_19.us_states;

SELECT COUNT(*) FROM covid_19.us_counties;

SELECT * FROM covid_19.us_counties;




-- UPDATE 'FIPS' from 'covid_19.census_county_2019'  (no UPDATE needed for 'covid_19.census_states')

UPDATE	covid_19.us_counties,
	(SELECT FIPS, County, State
     FROM covid_19.census_county) AS C
SET covid_19.us_counties.FIPS = C.FIPS
WHERE
	covid_19.us_counties.County = C.County AND
	covid_19.us_counties.State = C.State AND
	covid_19.us_counties.FIPS = 0;

	
-- Check the update data - the be no FIPS = 0

SELECT COUNT(*) FROM covid_19.us_counties;

SELECT * FROM covid_19.us_counties;
	


-- Now take care of "New York City" as this will not show on a Tableau map
-- Hence, taing the poulation of 5 individual Boroughs (Counties) and arbitrarily
--   assigning a proportion for NYC, sd "CAST((Tot_Cases * 0.17) AS DECIMAL(11,1))"

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


-- Check the update data - all the 5 Boroughs should be present, and the only
--    ones with Cases & Deaths with non-integer values 

SELECT COUNT(*) FROM covid_19.us_counties;

SELECT * FROM covid_19.us_counties;



-- CREATE VIEW for State/County Map using Moving Average New_Cases -4/+2 (7-day Moving Average)
--    Window Functions cannot be used in UPDATE statements, a VIEW accomplishes the same thing

DROP VIEW IF EXISTS covid_19.us_counties_mvg_avg_vw;

CREATE VIEW covid_19.us_counties_mvg_avg_vw AS
SELECT
	 Row_ID,
	`Date`,
     State,
     County,
     FIPS,
     Tot_Cases,
	 New_Cases,
     TRUNCATE(AVG(New_Cases)
		OVER(
			PARTITION BY State, County
            ORDER BY `Date`
            ROWS BETWEEN 4 PRECEDING AND 2 FOLLOWING
            ),3) AS New_Cases_MvgAvg,
	 Tot_Deaths,
	 New_Deaths,
     TRUNCATE(AVG(New_Deaths)
		OVER(
			PARTITION BY State, County
            ORDER BY `Date`
            ROWS BETWEEN 4 PRECEDING AND 2 FOLLOWING
            ),3) AS New_Deaths_MvgAvg
FROM covid_19.us_counties;



-- At this point -- Script stops here for Database direct connection to Tableau Desktop


-- Now EXPORT the data to CSV files

-- The CSV file *must* have already been deleted (this was mentioned above)
-- The file is left with a final LineFeed, (\n, 0x0A) and blank line when viewed in text editors,
--    this can be manually removed.
-- The column headings are added back in the one-line SELECT stament and the UNION.
-- The 'Row_Id's were from the transformation in the order of "State", "County' and "Date.  Thhey will
--    not remain the same from day to day.
-- Note: the output file is 'US_Counties.csv', the input from the NY Times is 'us-counties.csv'
--   The input file has a '-" and is smaller, out output file has a '_' and is larger as it has 'Row_ID's


SELECT 'Row_ID', "Date", '2Tot_Cases', 'New_Cases', 'Tot_Deaths', 'New_Deaths'
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


SELECT 'Row_ID', 'Date', 'State', 'County', 'FIPS', 'Tot_Cases', 'New_Cases', 'New_Cases_MvgAvg',
	'Tot_Deaths', 'New_Deaths', 'New_Deaths_MvgAvg'
UNION
SELECT * FROM covid_19.us_counties_mvg_avg_vw
INTO OUTFILE 'C:\\COVID-19\\US_Counties_Mvg_Avg.csv'
FIELDS OPTIONALLY ENCLOSED BY '' TERMINATED BY ',' ESCAPED BY '\\'
LINES TERMINATED BY '\n';

--  NY Times COVID-19 data CSV files are ready to be loaded to Tableau Public along with Census CSV files