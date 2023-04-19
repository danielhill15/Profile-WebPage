import json
import http.client
import boto3

s3 = boto3.resource('s3')

def lambda_handler(event, context):

    conn = http.client.HTTPSConnection("andruxnet-random-famous-quotes.p.rapidapi.com")

    headers = {
        'X-RapidAPI-Key': "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
        'X-RapidAPI-Host': "andruxnet-random-famous-quotes.p.rapidapi.com"
        }
    
    conn.request("GET", "/?cat=famous&count=10", headers=headers)
    
    res = conn.getresponse()
    print(res)
    data = res.read()
    
    file_name = "quotes.txt"
    lambda_path = "/tmp/" + file_name
    
    with open(lambda_path, 'w') as file:
        file.write("      Random Quotes of the Day")
        file.write('\n')
        file.write('\n')
        for quote in json.loads(data.decode("utf-8"))[:5]:
            q = quote['quote']
            a = '      - {}'.format(quote['author'])
            file.write(q)
            file.write('\n')
            file.write(a)
            file.write('\n')
            file.write('\n')
        file.close()
        
    s3 = boto3.resource('s3')
    s3.meta.client.upload_file(lambda_path, 'daniel-barak-hill.io', file_name, 
    ExtraArgs={'ContentDisposition' : 'inline','ACL': 'public-read','ContentType':'text/plain'}
    )
    
    print(data.decode("utf-8"))

    # TODO implement
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
