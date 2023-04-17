import json
import boto3
import urllib3

s3 = boto3.resource('s3')

def lambda_handler(event, context):
    
    result = "Successfully stored image"
    api = "https://api.nasa.gov/planetary/apod?api_key=o2MO9B3QaMNEwXQB5CYb6sI5L1VH176BFMRR63Td"
    http = urllib3.PoolManager()
    response = http.request('GET',api)
    nasa_potd = json.loads(response.data.decode('utf-8'))
    potd = nasa_potd["url"]
    http = urllib3.PoolManager()
    response = http.request('GET',potd)
    file_name = potd.split('/').pop()
    try:
        s3.Bucket('daniel-barak-hill.io').put_object(Body=response.data,Key='potd.jpg')
    except:
        result = 'An error occurred'
    
    return {
        'statusCode': 200,
        'body': json.dumps(result)
    }
