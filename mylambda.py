import custom_func as cf

def mylambda(event, context):
    cf.custom_func()
    return {
        'statusCode': 200,
        'body': 'Hello from Lambda Layers!'
    }