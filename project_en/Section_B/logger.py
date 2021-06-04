import datetime
import sys
import os

date =  datetime.datetime.now().strftime("%Y%m%d")
current_folder = os.path.dirname(os.path.abspath(__file__))
def logger(job_title, message, type):
    time = datetime.datetime.now()
    time = time.strftime("%Y-%m-%d %H:%M:%S")
    log_message = "[" + time + "] "+ "["+job_title+"] " + message + "\n"    
    os.chdir(f"{current_folder}\logs")
    file_name = "errorlog."+date+".txt"
    
    if type == "error":
        with open(file_name, "a+") as myfile:
            myfile.write(log_message)
    
    print(log_message)        
    return log_message