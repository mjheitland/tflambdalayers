import custom_func as cf
import logging
import requests # Python library 'requests' is part of our layer!

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def mylambda(event, context):
    cf.custom_func()

    response = requests.get('https://w3schools.com/python/demopage.htm')
    logger.info(response.text)        

    return {
        'statusCode': 200,
        'body': 'Hello from Lambda Layers!'
    }