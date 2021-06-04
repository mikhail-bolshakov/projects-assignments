import pandas as pd
import os
import csv
import xlrd
import datetime

import psycopg2
import sys


job_title = "bi_assignment"
build_start = datetime.datetime.now()
flat_time = build_start.strftime("%Y%m%d_%H%M%S")

current_folder = os.path.dirname(os.path.abspath(__file__))

# adding log file
os.chdir(f"{current_folder}\logs")
log = open(job_title + "_" + flat_time + ".txt", "w")
# sys.stdout = (
#     log  # comment out this line if you want to see the output in terminal window
# )

print("Job " + job_title + " start at " + flat_time)

dwh_creds = {
    "connectstring": "host=localhost dbname=postgres user=postgres password=postgres"
}
current_folder = os.path.dirname(os.path.abspath(__file__))
xlxs_path = os.path.join(current_folder, "BI analytics assessment 2020.xlsx")


# function to convert xlxs to csv

os.chdir(current_folder)


def xlxs2csv(xlxs_path, sheet_name, csv_name):
    df = pd.read_excel(
        xlxs_path, sheet_name, usecols=lambda x: "Unnamed" not in x, skiprows=range(4)
    )
    df.to_csv(csv_name, index=False)


# get sheet names and csv file names
csv_list = []
sheet_list = []
xls = xlrd.open_workbook(xlxs_path, on_demand=True)
[csv_list.append(i.lower().replace(" ", "_") + ".csv") for i in xls.sheet_names()[1:]]
[sheet_list.append(i) for i in xls.sheet_names()[1:]]


for sheet_name, csv_name in zip(sheet_list, csv_list):
    xlxs2csv(xlxs_path, sheet_name, csv_name)
    print(sheet_name + " converted to " + csv_name + " succesfully")


def execute_script(filename):
    # Open and read the file as a single buffer

    with open(filename, "r", encoding="utf-8") as fd:
        sql_file = fd.read()
    # all sql commands (split on ';')
    sql_query = sql_file.split(";")
    # Execute every command from the input file
    conn = psycopg2.connect(dwh_creds["connectstring"])
    cur = conn.cursor()
    for command in sql_query:
        print(command)
        cur.execute(command)
        conn.commit()

    cur.close()


execute_script("tables_create.sql")

os.chdir(f"{current_folder}")
try:
    conn = psycopg2.connect(dwh_creds["connectstring"])
    cur = conn.cursor()
except:
    print("Connection failed")
try:
    for csv_file in csv_list:
        with open(csv_file, newline="") as f:
            table_name = csv_file.split(".")[0]
            # reader = csv.reader(f)
            # print([row.lower() for row in next(reader)])
            print(table_name)
            cur.execute(f"""TRUNCATE TABLE test.{table_name}""")
            cur.copy_expert(
                f"""COPY test.{table_name} FROM STDIN WITH (FORMAT csv, header)""", f
            )
            print(table_name, "have been imported")
except:
    print("Error csv import")
conn.commit()
cur.close()
print("Job " + job_title + " finish at " + flat_time)
