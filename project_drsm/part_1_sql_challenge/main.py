import csv
import os
import datetime
import pandas as pd
import psycopg2
import sys
from io import StringIO
from tables_create import tables_create


job_title = "bi_assignment"
build_start = datetime.datetime.now()
flat_time = build_start.strftime("%Y%m%d_%H%M%S")
current_folder = os.path.dirname(os.path.abspath(__file__))

# adding log file and indicate the log files location
os.chdir(f"{current_folder}\logs")
log = open(job_title + "_" + flat_time + ".txt", "w")
sys.stdout = (
    log  # comment out this line if you want to see the output in terminal window
)
print("Job " + job_title + " started at " + flat_time)

# credentials to connect to existing dwh
dwh_creds = {
    "connectstring": "host=localhost dbname=postgres user=postgres password=postgres"
}

# imported function from tables_create.py to drop if existed, create 3 tables to hold csv data and dates table.
tables_create()

# specify number of columns to read from each csv file, write it to dictionary
table_cols = {
    "shops.csv": 4,
    "public_holiday_calendar_entry.csv": 3,
    "bhshop_entry.csv": 17,
}

# go to datasets folder
os.chdir(f"{current_folder}\datasets")

# connect to dwh using credentials from connect string
try:
    conn = psycopg2.connect(dwh_creds["connectstring"])
    cur = conn.cursor()
except:
    print("Connection failed")

# read data from csv
try:
    for filename, cols in table_cols.items():
        with open(filename, newline="") as f:
            table_name = "drsmile." + filename.split(".")[0]  # define table names
            df = pd.read_csv(
                filename, usecols=[i for i in range(cols)]
            )  # read csv with pandas module, number of columns from dictionary
            print("Reading columns: ", *(df.columns.values), " from " + filename, "\n")

            # convert the data from buffer into an in-memory StringIO object.
            buffer = StringIO()  # create an in-memory text stream
            df.to_csv(
                buffer, index=False, header=False
            )  # write the DataFrame contents to the text stream's buffer as a CSV
            buffer.seek(
                0
            )  # in order to read from the buffer afterwards, its position should be set to the beginning

            cur.execute(f"""TRUNCATE TABLE {table_name}""")
            cur.copy_from(
                buffer, table_name, sep=",", null=""
            )  # write data from memory into dwh tables
            print(table_name, "have been imported", "\n")
            buffer.close()
            conn.commit()
except (Exception, psycopg2.DatabaseError) as error:

    print("Error: %s" % error)
    conn.rollback()
    cur.close()

# open and run the final_query.sql file, write results into results csv file
with open(os.path.join(current_folder, "final_query.sql"), "r", encoding="utf-8") as fd:
    sql_file = fd.read()
    sql_query_file_output = f"COPY ({sql_file}) TO STDOUT WITH CSV HEADER"

    with open(os.path.join(current_folder, "results.csv"), "w", newline="") as outcsv:
        cur.copy_expert(sql_query_file_output, outcsv)

conn.commit()
cur.close()

print("Job " + job_title + " finished at " + flat_time)