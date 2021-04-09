import json
from urllib.request import Request, urlopen
import logging

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

def run(event, context):
    
    url = 'https://api.punkapi.com/v2/beers/random'

    # TODO - Change user agent
    req = Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    res_body = urlopen(req).read()

    data = json.loads(res_body.decode("utf-8"))

    logger.info(f'Bear name: {data[0]["name"]}')

    return {
        "message": "Go Serverless v1.0! Your function executed successfully!",
        "event": event
    }
