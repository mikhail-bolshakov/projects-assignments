from logger import logger
import psycopg2
import csv
import os
import sys
import datetime

#connection credentials
#=========================================================================================================
#!!! PLEASE UPDATE THE CONNECTION HOST, PORT AND CREDENTIALS!!!
dwh_creds = {"connectstring" : "host= <host_url> dbname=<database_name> user=<username> password=<password>"}

#=========================================================================================================

job_title = "bi_assignment"
build_start = datetime.datetime.now()
flat_time = build_start.strftime("%Y%m%d_%H%M%S")
current_folder = os.path.dirname(os.path.abspath(__file__))
#adding log file
os.chdir(f"{current_folder}\logs")
log = open(job_title +'_' + flat_time+'.txt', 'w')
#sys.stdout = log  # comment out this line if you want to see the output in terminal window

build_scripts_dir = f"{current_folder}\sql_scripts"
results_dir = f"{current_folder}\query_results"
def execute_script(filename):
    # Open and read the file as a single buffer
    
    os.chdir(build_scripts_dir)
    with open(filename, 'r', encoding = 'utf-8') as fd:
        sql_file = fd.read()
    # all sql commands (split on ';')
    sql_query = sql_file.split(';')
    # Execute every command from the input file
    conn = psycopg2.connect(dwh_creds["connectstring"])
    cur = conn.cursor()
    for command in sql_query:
        try:
            print(command)
            cur.execute(command)
            conn.commit()
        except psycopg2.Error as errorMsg:
            logger(job_title, str(errorMsg) + ", but it doesn`t matter, Skynet has become self aware...", "error")
            
        finally:
            conn.commit()
    cur.close()

execute_script('dates_table_create.sql')
execute_script('tables_create.sql')
             
csv_import_dir = f"{current_folder}\csv_inputs"
os.chdir(csv_import_dir)

#removing files that contain _input after last run, making sure that file number doesn`t grow
file_list = os.listdir(csv_import_dir)
for file in file_list: 
    if '_input' in file:
        os.remove(os.path.join(csv_import_dir, file))
file_list = os.listdir(csv_import_dir)
        
#creating new files, adding _input to the input files and reading all rows that contain data, avoiding empty rows
for file in file_list:
    filename = os.path.join(csv_import_dir, file)
    base, extension = os.path.splitext(filename)
    new_filename = base + '_input' + str(extension)
    os.rename(filename, new_filename)
    in_fnam, out_fnam  = new_filename, filename
    with open(in_fnam, encoding = 'utf-8') as in_file:
        with open(out_fnam, 'w', encoding = 'utf-8', newline='') as out_file:
            writer = csv.writer(out_file)
            for row in csv.reader(in_file):
                if any(row):
                    writer.writerow(row) 
                    
#function reading data from csv files and wring it to tables
def upload(file, table):
    logger(job_title, "connecting to DWH", "log")
    try:
        conn = psycopg2.connect(dwh_creds["connectstring"])
        cur = conn.cursor()
    except:
        logger(job_title, "connecting connecting to DWH failed", "error")
        raise
    logger(job_title, "writing to DWH", "log")
    try:
        cur.execute(f"TRUNCATE TABLE {table}")    #truncating table, keeping table structure, when script runs daily 
        os.chdir(csv_import_dir)
        with open(file, 'r', encoding = 'utf-8') as file:
            cur.copy_expert(f"""COPY {table} FROM STDIN WITH (FORMAT csv, DELIMITER ',', QUOTE '"', HEADER True)""", file) #reading data from csv into table
        cur.execute(f"""ALTER TABLE {table} ADD COLUMN id SERIAL PRIMARY KEY; ALTER TABLE {table} DROP COLUMN id_{table.split('_')[3]}""") #adding unique primary key and dropping the old id col
        conn.commit()
        cur.close()
    except:
        logger(job_title, f"writing to test_mb.{table} failed", "error")
        raise
    finally:
        conn.commit()
        cur.close()
    logger(job_title, "copying file to DWH done", "log")

   
for file in file_list:
    schema_name = 'test_mb.'
    table = schema_name + os.path.splitext(file)[0].lower()
    print(file, table)
    upload(file, table)

#altering tables by adding fkey
execute_script('alter_fkey.sql')


#running query calcaulating result and writing to csv
try:
    conn = psycopg2.connect(dwh_creds["connectstring"])
    cur = conn.cursor()
except:
    logger(job_title, "connecting connecting to DWH failed", "error")
    raise
logger(job_title, "writing to DWH", "log")
try:
    os.chdir(build_scripts_dir)
    with open("result.sql", 'r', encoding = 'utf-8') as fd:
        sql_file = fd.read()
    # all sql commands (split on ';')
    sql_query = sql_file.split(';')
    sql_query_file_output = f"COPY ({sql_query[0]}) TO STDOUT WITH CSV HEADER"
    os.chdir(results_dir)
    with open("result.csv", 'w', newline='') as outcsv:
        cur.copy_expert(sql_query_file_output, outcsv)
    conn.commit()
    cur.close()
except:
    logger(job_title, "writing results failed", "error")
    raise
finally:
    conn.commit()
    cur.close()
    logger(job_title, "Voila!!!", "log")