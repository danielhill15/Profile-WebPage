import json
import http.client

def lambda_handler(event, context):

    conn = http.client.HTTPSConnection("andruxnet-random-famous-quotes.p.rapidapi.com")

    headers = {
        'X-RapidAPI-Key': "5677e70ba2mshfbef6c9f5f96818p19744fjsn25c4b7008942",
        'X-RapidAPI-Host': "andruxnet-random-famous-quotes.p.rapidapi.com"
        }
    
    conn.request("GET", "/?cat=famous&count=10", headers=headers)
    
    res = conn.getresponse()
    data = res.read()
    
    print(data.decode("utf-8"))
    # TODO implement
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }