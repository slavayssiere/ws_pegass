#!/usr/local/bin/python3

import requests
import os
import datetime
import json

url = 'http://localhost:9292'
headers = {
    'username': os.getenv("PEGASS_USERNAME"), 
    'password': os.getenv("PEGASS_PASSWORD")
}

response = requests.get(url + "/v1/connect", headers=headers)

connect_data = response.json()

headers = {
    'LastMRH-Session': connect_data['LastMRH_Session'], 
    'shibsession_value': connect_data['SHIBSession']['value'],
    'SAML': connect_data['SAML'],
    'Authorization': 'Bearer',
    'Content-Type': 'application/json',
    'MRHSession': connect_data['MRHSession'],
    'JSESSIONID': connect_data['JSESSIONID'],
    'F5-ST': connect_data['F5_ST'],
    'shibsession_name': connect_data['SHIBSession']['name']
}

response = requests.get(url + '/v1/competences', headers=headers)
response = requests.get(url + '/v1/benevoles/all?ul=899&page=0', headers=headers)
response = requests.get(url + '/v1/benevoles/address/72211', headers=headers)

# print(json.dumps(response.json()['formations'], indent=4, sort_keys=True))

# t1 = datetime.datetime.now()
# response = requests.get(url + '/v1/benevoles/all?ul=899&page=0', headers=headers)
# response = requests.get(url + '/v1/benevoles/all?ul=899&page=1', headers=headers)
# response = requests.get(url + '/v1/benevoles/all?ul=899&page=2', headers=headers)
# response = requests.get(url + '/v1/benevoles/all?ul=899&page=3', headers=headers)
# response = requests.get(url + '/v1/benevoles/all?ul=899&page=4', headers=headers)
# response = requests.get(url + '/v1/benevoles/all?ul=899&page=5', headers=headers)
# t2 = datetime.datetime.now()
# print(t2 - t1)

# t1 = datetime.datetime.now()
# response = requests.get(url + '/v1/benevoles/all?ul=899&page=0', headers=headers)
# response = requests.get(url + '/v1/benevoles/all?ul=899&page=1', headers=headers)
# response = requests.get(url + '/v1/benevoles/all?ul=899&page=2', headers=headers)
# response = requests.get(url + '/v1/benevoles/all?ul=899&page=3', headers=headers)
# response = requests.get(url + '/v1/benevoles/all?ul=899&page=4', headers=headers)
# response = requests.get(url + '/v1/benevoles/all?ul=899&page=5', headers=headers)
# t2 = datetime.datetime.now()
# print(t2 - t1)


# response = requests.get(url + '/v1/benevoles/recyclagesdd/286?dd=75&page=1', headers=headers)
# resp_json = response.json()
# print(json.dumps(resp_json, indent=4, sort_keys=True))

# for x in range(2, resp_json['pages']):
#     response = requests.get(url + '/v1/benevoles/recyclagesdd/286?dd=75&page='+str(x), headers=headers)
#     resp_json = response.json()
#     print(json.dumps(resp_json, indent=4, sort_keys=True))