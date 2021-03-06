import json
import logging
from urllib.request import Request, urlopen
import boto3

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

def run(event, context):
    
    endpoint = 'https://api.punkapi.com/v2/beers/random'

    req = Request(endpoint, headers={'User-Agent': 'Mozilla/5.0'})
    res_body = urlopen(req).read()

    payload = json.loads(res_body.decode("utf-8"))

    logger.info(f'Beer name: {payload[0]["name"]}')

    kinesis_client = boto3.client('kinesis', region_name='sa-east-1')

    my_stream_name = 'punk-stream'
    partition_key = 'partition_1'
    put_response = kinesis_client.put_record(
                        StreamName=my_stream_name,
                        Data=json.dumps(payload),
                        PartitionKey=partition_key)

    return {
        "message": "Get beer executed successfully!",
        "event": event
    }

