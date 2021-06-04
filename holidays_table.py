from datetime import date
import holidays

all_list = []

country_list = ['Germany', 'Italy', 'France', 'Switzerland', 'Netherlands', 'Sweden', 'Austria', 'UnitedKingdom', 'Poland']
years_list = [2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026]

def country_holidays_csv(country_name, years_list):
	for date, name in sorted(
	    getattr(holidays, country_name)(years=years_list).items()
	):
	    date_name = ['"'+str(date)+'"'+","+'"'+name+'"' + ","+'"'+ getattr(holidays, country_name)().country +'"']
	    if not name == 'Söndag':
		    if date_name not in all_list:
	    		all_list.append(date_name)
	with open('country_holidays_2019_2026.csv','a', newline='', encoding='utf-8') as fd:
		for i in all_list:
			fd.write(str(*i))
			fd.write('\n')

for country_name in country_list:
	country_holidays_csv(country_name, years_list)