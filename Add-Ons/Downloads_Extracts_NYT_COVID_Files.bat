REM Extracts 'us.csv', 'us-states.csv' and 'us-counties.csv' from 'covid-19-data-master.zip",
REM removes old files and renames

REM -- William Salomon, MD MS MPH
REM -- Clinical Metrics, LLC
REM -- Revised 2020-05-31


REM Create a Directory in C:\ named C:\COVID-19 (shortens searching for files)
REM If Directory already present, error does not appear, and script keeps on going
MD C:\COVID-19 > NUL  2> NUL

REM Changes working directory
CD C:\COVID-19

REM Removes old files
DEL /Q C:\Users\hpressler\Downloads\covid-19-data-master.zip
DEL /Q covid-19-data-master.zip
DEL /Q US*.csv
RD /Q /S covid-19-data-master


REM Downloads the file from 'https://github.com/nytimes/covid-19-data/archive/master.zip' using Firefox
REM When Firefox opens and downloads, click "Save file" and close
C:\PROGRA~1\MOZILL~1\firefox.exe https://github.com/nytimes/covid-19-data/archive/master.zip

REM Moves downloaded file to working directory
MOVE /Y C:\Users\hpressler\Downloads\covid-19-data-master.zip C:\COVID-19

 
REM TIMEOUT 10

REM Extracts
C:\PROGRA~1\7-Zip\7z x covid-19-data-master.zip
REM Moves 'us_counties.csv' and 'us_states.csv' out of 'covid-19-data-master' directory to Downloafds and renames
MOVE /Y covid-19-data-master\us.csv US_USA_CSV.csv
MOVE /Y covid-19-data-master\us-states.csv US_States_CSV.csv
MOVE /Y covid-19-data-master\us-counties.csv US_Counties_CSV.csv

REM Deletes the extracted covid-19-data-master directory
RD /S /Q covid-19-data-master

REM Start MySQL if not already started
net start MySQL80

REM Start Excel for a quick check, then close it
REM "C:\Program Files\Microsoft Office\root\Office16\Excel.exe" C:\COVID-19\US_USA_CSV.csv
REM "C:\Program Files\Microsoft Office\root\Office16\Excel.exe" C:\COVID-19\US_States_CSV.csv
REM "C:\Program Files\Microsoft Office\root\Office16\Excel.exe" C:\COVID-19\US_Counties_CSV.csv


REM Start MySQL Workshop, if not already started, Command windows closes when it starts
START C:\PROGRA~1\MySQL\MYSQLW~1.0CE\MySQLWorkbench.exe
