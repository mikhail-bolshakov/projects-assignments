import requests
import json
import time
import snowflake.connector
import json
import sys
import time
import datetime
import dateutil.parser
from dateutil.parser import ParserError
import re


COUNTRY_LIST = {
"country_name":"audience_id",
"country_name":"audience_id",
"country_name":"audience_id",
}

payload_schema = [
    "EMAIL",
    "PHONE",
    "GEN",
    "DOBY",
    "DOBM",
    "DOBD",
    "LN",
    "FN",
    "CT",
    "ZIP",
    "COUNTRY",
    "LOOKALIKE_VALUE",
]


fields = []

params = {
  'name': 'TEST value-based custom audience',
  'subtype': 'CUSTOM',
  'is_value_based': True,
  'customer_file_source': 'PARTNER_PROVIDED_ONLY',
}

get_params = dict(access_token=access_token)
s = requests.Session()



snowflake_client = snowflake.connector.connect(
  account= "account_id",
      user= "user_name",
      password= "password",
      role= "role",
      database= "database",
      warehouse= "warehouse",
      schema= "schema"
)


class FacebookApiClient:
    @classmethod
    def connect(cls):
        return cls()

    def __init__(self, country, audience):
        self.s = requests.Session()
        self.app_id = "app_id"
        self.app_secret = "app_secret"
        self.access_token = "access_token"
        self.account_id = "account_id"
        self.fb_base_url = "https://graph.facebook.com/v10.0/"
        self.country = country
        self.audience = audience

    def post_users(self, audience_id, payload):
        get_params = {**dict(access_token=self.access_token)}
        return self.s.post(
            self.fb_base_url + audience_id + "/users",
            params=get_params,
            json=payload,
        )

class FacebookLookAlike(FacebookApiClient):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def post(self):
       
        with snowflake_client as conn:
        	cur = conn.cursor()
        	cur.execute(
                """select EMAIL, PHONE, GEN, DOBY, DOBM, DOBD, LN, FN, CT, ZIP, COUNTRY, SCORE as LOOKALIKE_VALUE
                from dwh_prd.analytical_schema.facebook_audience_a
                where country_raw = ?""",
                [self.country.lower()],
            )
            result = cur.fetchall()

        customer_list = [list(res) for res in result]
        
        for i in range(0, len(customer_list), 10000):
            customer_list = customer_list[i:i+10000]
            payload = {'payload': {'schema': payload_schema, 'data': customer_list}}
  
            audience_id = audience
            return self.post_users(audience_id, payload) 



for country, audience in COUNTRY_LIST.items():

    s = FacebookLookAlike(country, audience)
    a = s.post()
    print(a.json())