import csv

# open the file in universal line ending mode 
with open('test.csv', 'rU') as infile:
  # read the file as a dictionary for each row ({header : value})
  reader = csv.DictReader(infile)
  data = {}
  for row in reader:
    for header, value in row.items():
      try:
        data[header].append(value)
      except KeyError:
        data[header] = [value]

# extract the variables you want
names = data['name']
latitude = data['latitude']
longitude = data['longitude']


#======================================

for row in reader:
        content = list(row[i] for i in included_cols)
        print content
#=======================================

import pandas as pd
df = pd.read_csv(csv_file)
saved_column = df.column_name #you can also use df['column_name']


names = df.Names

#=====================================
with open('some.csv', newline='') as f:
  reader = csv.reader(f)
  row1 = next(reader)