Hi, 

1) the Part 1: SQL Challenge final results are stored in the results.csv
2) the sql query that returns the results is final_query.sql

Note:
The task guide pdf says "each shop is also linked to bhshop_entry, which is not quite true, as there are multiple shops without 
bhshop_id, which makes it impossible to map to bhshop_entry. 
I have assumed that those shops from shops dataset do not offer any business hours and do not participate in the appointment hours
calculation (used inner join).

To automate the process and to make it more interesting i have solved it using Python:
	all three worksheets from gsheet DrSmile Data Analytics Challenge - Data Sets 
	have been downloaded as csv files into datasets folder.
	main.py script handles all operations:
		- runs all queries from build_queries folder:
    			- dates_table_202011142257.sql - creates and populates the dates_tables 
    			(WATCH OUT!: it also creates help_tables schema);
    			- runs tables_create.sql - creates 3 tables.
		- reads csvs from datasets folder.
		- populates tables that were created earlier with data from csv.
		- runs the final_query to get top 3 shops with highest appointment times available as of 2020-11-12
		- writes query results into results.csv file.

In order to run the main.py you need to change the dwh_creds = {
    "connectstring": "host=localhost dbname=postgres user=postgres password=postgres"}. 
It will run, at least it should, successfully as long as the folders and files names inside the \part_1_sql_challenge directory remain as is.

