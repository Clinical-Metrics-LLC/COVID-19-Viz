COVID-19-Viz# COVID-19-Viz
COVID-19 Visualizations from NY Times COVID-19 Data Repository at https://github.com/nytimes/covid-19-data/


Contains:

1. Windows batch file downloading and extracting files from covid-19-data-master.zip (in Add-Ons)</br>
2. MySQL Extraction, Transformation, and Loading (ETL) scripts for the New York Times data and Census Bureau)</br>
       data as of 2019 (the scripts are in both Verbose (heavily commented) and Runtime versions))</br>
3. Tableau Visualization files in .twbx and .twb versions for a MySQL ODBC connection and a .twbx file)</br>
       downloaded from Tableau Public (they are identical in "content")</br>
   a. 'COVID-19 - Cases & Deaths (US)' requires no Census file (US population is fixed))</br>
   b. 'COVID-19 - Cases & Deaths (State)' requires 'US States' Census file)</br>
   c. 'COVID-19 - Cases & Deaths (County)' requires 'US Counties' Census file)</br>
   d. 'COVID-19 - Cases & Deaths by State - County - Map' requires 'US Counties' Census file)</br>
4. Census 2019 .CSV files for States and Counties)</br>
   a. FIPS added for "New York City, NY" ((3651000) and "Kansas City, MO" (2938000))</br>
   b. "Synthetic" FIPS added for "Unknown" Counties (1-2 digit State FIPS + "999" (e.g. "Unknown, NY" is 36999))</br>

Daily Cases/Deaths have been extracted from the Cummulative Cases/Deaths. In some cases there are negative Daily Counts</br>
    where errors) have been subtracted from the Cumulative Counts
