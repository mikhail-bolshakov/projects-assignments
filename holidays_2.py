
import requests
import json
import time


s = requests.Session()
# api_baseurl = "https:///api/v3/PublicHolidays/{Year}/{CountryCode}/"
counter = 0
resultsList = []
year_list = [2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026]
country_list = ['DE', 'AT', 'CH', 'SE', 'IT', 'FR', 'ES', 'PL']

for year in year_list:
	for country in country_list:
		api_baseurl = "https://date.nager.at/api/v3/publicholidays/{year}/{country}"
		res = s.get(api_baseurl) 
		print(res, res.status_code)

		

