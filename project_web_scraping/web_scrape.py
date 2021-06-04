import requests
import re
import csv
import lxml
import numpy as np
import pandas as pd
from bs4 import BeautifulSoup
sec_url = 'https://www.sec.gov'


def get_request(url):
    return requests.get(url)


def create_url(cik):
    return 'https://www.sec.gov/cgi-bin/browse-edgar?CIK={}&owner=exclude&action=getcompany&type=13F-HR'.format(cik)


def get_user_input():
    cik = input("Enter CIK number: ")
    return cik


requested_cik = get_user_input()

# Find mutual fund by CIK number on EDGAR
response = get_request(create_url(requested_cik))
soup = BeautifulSoup(response.text, "html.parser")
tags = soup.findAll('a', id="documentsbutton")

# Find latest 13F report for mutual fund
response_two = get_request(sec_url + tags[0]['href'])
soup_two = BeautifulSoup(response_two.text, "html.parser")
tags_two = soup_two.findAll('a', attrs={'href': re.compile('xml')})
xml_url = tags_two[3].get('href')
response_xml = get_request(sec_url + xml_url)
soup_xml = BeautifulSoup(response_xml.content, "lxml")

# DataFrame
df = pd.DataFrame()
df['companies'] = soup_xml.body.findAll(re.compile('nameofissuer'))
df['value'] = soup_xml.body.findAll(re.compile('value'))

for row in df.index:
    df.loc[row, 'value'] = df.loc[row, 'value'].text
    df.loc[row, 'companies'] = df.loc[row, 'companies'].text
df['value'] = df['value'].astype(float)
df = df.groupby('companies').sum()
df = df.sort_values('value', ascending=False)
for row in df.index:
    df.loc[row, 'percent'] = df.loc[row, 'value']/df['value'].sum()
df
