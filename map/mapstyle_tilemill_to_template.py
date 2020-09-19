#!/usr/bin/python3
import json, sys
data = json.load(sys.stdin)

#print(data);
#data['Layer'][0]['Datasource']['password'] = '{{password}}'
#print(data.keys());
#data['minzoom'] = 4

for layer in data['Layer']:
  ds = layer['Datasource']
  ds['host']     = '{{ds_host}}'
  ds['port']     = '{{ds_port}}'
  ds['user']     = '{{ds_user}}'
  ds['password'] = '{{ds_password}}'

json.dump(data, sys.stdout, indent=2)
