import base64
import json

def handler(event, context):
    output = []
    
    attributes = ['name', 'abv', 'ibu', 'target_fg', 'target_og', 'ebc', 'srm', 'ph']
    
    for record in event['records']:
        payload = json.loads(base64.b64decode(record['data']).decode("utf-8"))
        payload = payload[0]
        csv_payload = ','.join([str(payload.get(key)) for key in attributes]) + '\n'
        csv_payload = base64.b64encode(csv_payload.encode('utf-8')).decode('utf-8')
        
        output_record = {
            'recordId': record['recordId'],
            'result': 'Ok',
            'data': csv_payload
        }
        
        output.append(output_record)

    return {'records': output}
