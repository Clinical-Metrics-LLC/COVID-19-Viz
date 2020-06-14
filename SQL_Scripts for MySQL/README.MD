SQL Scripts for COVOD-19 Data</br>

There are two versions for most scripts:</br>
- The "Verbose" version is heavily commented, and meant to explain the underlying SQL,</br>
There are also SELECT statements for checking the progress and accuracy of the loading process.</br>
- The RUNtime version is stripped down to the essential SQL and is meant to be run in the</br>
MySQL Workshop using the "Run" option in the File Menu.  It runs non-stop until it finishes.</br>
The dialog box will show only the phase of execution, and any errors.</br>
(The most common error is failure to find the US_USA_CSV.csv file (because it hasn't been created yet),</br>
or failure to run it due to an Operating System (OS) error due to a file that is "locked", often for</br>
unknown reasons).</br>

If you receive the OS error:</br>
1. Rename the C:\COVID-19 directory as C:\COVID-19x.</br>
2. Create a new C:\COVID-19 directory.</br>
3. Copy all files in C:\COVID-19x to C:\COVID-19.</br>
4. Run the SQL file again.</br>
5. If successful, delete the C:\COVID-19x directory.</br>

The NYT data loading SQL is in two forms:</br>
1. The "tables only" version.</br>
2. The "Create CSV version.</br>
They are virtually identical - the "Create CSV" version has extra lines to write the CSV file</br>
from the already created tables.  If connecting directly to a database, the CSV files as not needed.</br>

The Census data SQL needs to be run only once, if at all.  If you have received all of the Census CSV</br>
files there is no need to run this again.
