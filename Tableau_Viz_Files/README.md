About the Viz Files...</br>

These are Tableau Workbook Files for the NY Times Data.</br>
These are 4 sets - 3 graphed sets for US-, State/Territory-, and County-level data,</br>
and 1 Map for State/County.</br>

For each set there are 4 versions...</br>
-   Two for MySQL-ODBC database data (one in .twbx and one in .twb form)</br>
-   One using CSV data generated from MySQL (.twbx), suitable for Tableau Public</br>
-   One or two static PDF versions from all 4 Workbooks</br>
   
The CSV versions contain all US data as of the the "save" date.  As a result they may</br>
be opened with Tableau Reader and are "live" as of the save date.</br>
This is how the PDF versions were created, and you can create PDFs of your own</br>
from the saved data (they will *not* update to newer data).</br>
 
 
Adapting these files for your own use against your own database or CSV Files...</br>

(Note: This material was created for COVID-19 data, but could be used for any similar</br>
Epidemiological data with changes in the header text. It was created as "generically"</br>
as possbile to allow for easy reuse in another epidemic.  With ZIP-code-level data, and</br>
a US Census ZCTA (ZIP Code Tabulation Area) population file and "shapefile", a new graphed</br>
Workbook and Map Workbook could be created in an hour or two from the existing material.)</br>

Tableau is most "unforgiving" about creating new Data Sources when replacing exising ones.</br>
Failing to do the following precisely will end up with corrupted formulas that you will need</br>
to fix manually. Given that some Workbooks have 22 Panes, preventing problems is far easier</br>
than fixing the "aftermath".</br>
1. Ensure that all column names are *precisely* those in the Workbooks given./br>
2. Be aware that different databases have "reserved" words that may cause "problems".</br>
      when used as column names - the most common is the word "Date" (in some "State" as well).</br>
3. If you encounter a reserved word being used as a column name, you must use the database's</br>
      "escape" character to surround the word to have it acceptable as a column name<./br>
4. In MySQL, the escape character is backwards single quote ( \` ). To use the reserved word</br>
      "Date", you would create your tables for the column (attribute) "Date" as \`Date`.</br>
      For other databases such as SQL-Server and Oracle, check the documentation.</br>
5. When running a query against your database, the escape characters will *not* show in</br>
      the query's column headers;  \`Date` will be shown only as "Date" (the double</br>
      quotes are meant to emphasize the word, they are not shown literally).</br>
6. Do not attempt to use MS Access as a database - the SQL scripts used here will not work.</br>
