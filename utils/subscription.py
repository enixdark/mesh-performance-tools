import requests
import json
with open('../samples/files/rdevices.json') as f:
    data = json.loads(f.read())

    uuid = data['devices'][0]['uuid']
    for elem in data['devices'][1:]:
        headers = {
          "meshblu_auth_uuid": elem['uuid'],
          "meshblu_auth_token": elem['token']
        }
        requests.post('http://localhost:3000/v2/devices/'+uuid+'/subscriptions/'+elem['uuid']+'/broadcast', headers = headers)
        # requests.post('http://localhost:3000/v2/devices/'+elem['uuid']+'/subscriptions/'+uuid+'/broadcast', headers = headers)
        # requests.post('http://localhost:3000/v2/devices/'+uuid+'/subscriptions/'+elem['uuid']+'/received', headers = headers)
        # requests.post('http://localhost:3000/v2/devices/'+elem['uuid']+'/subscriptions/'+uuid+'/received', headers = headers)
        # requests.post('http://localhost:3000/v2/devices/'+uuid+'/subscriptions/'+elem['uuid']+'/sent', headers = headers)
        # requests.post('http://localhost:3000/v2/devices/'+elem['uuid']+'/subscriptions/'+uuid+'/sent', headers = headers)