import psycopg2
import csv
import os
import sys
import datetime


def tables_create():
    """Function reads DDL sql files from build queries folder, those
    create 3 tables to hold data from csv files, help_tables schema,
    help_tables.dates_table and populates dates_table"""

    job_title = "tabls_create"
    build_start = datetime.datetime.now()
    flat_time = build_start.strftime("%Y%m%d_%H%M%S")
    current_folder = os.path.dirname(os.path.abspath(__file__))
    dwh_creds = {
        "connectstring": "host=localhost dbname=postgres user=postgres password=postgres"
    }
    sql_file_list = [query for query in os.listdir(f"{current_folder}/build_queries")]

    try:
        conn = psycopg2.connect(dwh_creds["connectstring"])
        cur = conn.cursor()
    except:
        raise
    try:
        os.chdir(f"{current_folder}\\build_queries")
        for sql_file in sql_file_list:
            with open(sql_file, "r", encoding="utf-8") as fd:
                sql_file = fd.read()
            # all sql commands (split on ';')
            query_list = sql_file.split(";")
            for query in query_list:
                cur.execute(query)
    except:
        raise
    conn.commit()
    cur.close()
