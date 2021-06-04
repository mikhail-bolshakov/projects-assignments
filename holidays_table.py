from datetime import date

import holidays

de_holidays = holidays.Germany()
it_holidays = holidays.Italy()
fr_holidays = holidays.France()
ch_holidays = holidays.Switzerland()
se_holidays = holidays.Sweden()
at_holidays = holidays.Austria()
pl_holidays = holidays.Poland()
nl_holidays = holidays.Netherlands()
gb_holidays = holidays.UnitedKingdom()

# for i in de_holidays:
#     print(i.values())

print(holidays.list_supported_countries())
start_date = "2020-06-01"
end_date = "2025-12-31"
all_list = []

    #fd.write(myCsvRow)
for date, name in sorted(
    holidays.Germany(years=[2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026]).items()
):
    #print("(", "'" + str(date) + "'", ",", "'" + name + "'", ")", ",")
    date_name = ['"'+str(date)+'"'+","+'"'+name+'"' + ","+'"'+ de_holidays.country+'"']
    if date_name not in all_list:
    	all_list.append(date_name)
    #myCsvRow = '"'+str(date)+'"'+","+'"'+name+'"' + ","+'"' de_holidays.country + '\n'
    #print(myCsvRow)
    #fd.write(myCsvRow)
for date, name in sorted(
    holidays.Italy(years=[2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026]).items()
):
    date_name = ['"'+str(date)+'"'+","+'"'+name+'"' + ","+'"'+  it_holidays.country+'"']
    if date_name not in all_list:
    	all_list.append(date_name)
    #myCsvRow = '"'+str(date)+'"'+","+'"'+name+'"' + ","+'"' it_holidays.country + '\n'
    #print(myCsvRow)
    #fd.write(myCsvRow)
for date, name in sorted(
    holidays.France(years=[2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026]).items()
):
    date_name = ['"'+str(date)+'"'+","+'"'+name+'"' + ","+'"'+  fr_holidays.country+'"']
    if date_name not in all_list:
    	all_list.append(date_name)
    #myCsvRow = '"'+str(date)+'"'+","+'"'+name+'"' + ","+'"' fr_holidays.country + '\n'
    #print(myCsvRow)
    #fd.write(myCsvRow)
for date, name in sorted(
 	holidays.Switzerland(years=[2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026]).items()
):
    date_name = ['"'+str(date)+'"'+","+'"'+name+'"' + ","+'"'+  ch_holidays.country+'"']
    if date_name not in all_list:
    	all_list.append(date_name)
    #myCsvRow = '"'+str(date)+'"'+","+'"'+name+'"' + ","+'"' ch_holidays.country + '\n'
    #print(myCsvRow)
    #fd.write(myCsvRow)

for date, name in sorted(
    holidays.Sweden(years=[2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026]).items()
):	
	if not name == 'Söndag':
		date_name = ['"'+str(date)+'"'+","+'"'+name+'"' + ","+'"'+  se_holidays.country+'"']
	if date_name not in all_list:
		all_list.append(date_name)
   	#myCsvRow = '"'+str(date)+'"'+","+'"'+name+'"' + ","+'"' se_holidays.country + '\n'
    #print(myCsvRow)
    #fd.write(myCsvRow)
for date, name in sorted(
    holidays.Austria(years=[2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026]).items()
):
    date_name = ['"'+str(date)+'"'+","+'"'+name+'"' + ","+'"' + at_holidays.country+'"']
    if date_name not in all_list:
    	all_list.append(date_name)
for date, name in sorted(
    holidays.Netherlands(years=[2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026]).items()
):
    date_name = ['"'+str(date)+'"'+","+'"'+name+'"' + ","+'"' + nl_holidays.country+'"']
    if date_name not in all_list:
    	all_list.append(date_name)
for date, name in sorted(
    holidays.UnitedKingdom(years=[2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026]).items()
):
    date_name = ['"'+str(date)+'"'+","+'"'+name+'"' + ","+'"' + "GB" +'"']
    if date_name not in all_list:
    	all_list.append(date_name)
    #myCsvRow = '"'+str(date)+'"'+","+'"'+name+'"' + ","+'"' at_holidays.country + '\n'
    #print(myCsvRow)
    #fd.write(myCsvRow)
for date, name in sorted(
    holidays.Poland(years=[2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026]).items()
):
    date_name = ['"'+str(date)+'"'+","+'"'+name+'"' + ","+'"' + pl_holidays.country+'"']
    if date_name not in all_list:
    	all_list.append(date_name)
    #myCsvRow = '"'+str(date)+'"'+","+'"'+name+'"' + ","+'"' pl_holidays.country + '\n'
    #print(myCsvRow)
    #fd.write(myCsvRow)

# with open('country_holidays_2019_2026.csv','a', newline='', encoding='utf-8') as fd:
# 	for myCsvRow in all_list:
# 		fd.write(str(myCsvRow)

with open('country_holidays_2019_2026.csv','w', newline='\n', encoding='utf-8') as fd:
	for i in all_list:
		fd.write(str(*i))
		fd.write('\n')