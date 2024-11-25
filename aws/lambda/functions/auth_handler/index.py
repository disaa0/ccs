import json
import boto3
import os
from botocore.exceptions import ClientError

cognito = boto3.client('cognito-idp')
dynamodb = boto3.resource('dynamodb')
user_permissions_table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

def lambda_handler(event, context):
    # Parse the HTTP method and path
    http_method = event['httpMethod']
    resource_path = event['resource']
    
    try:
        # Route the request based on the path
        if resource_path == '/auth/login':
            return handle_login(json.loads(event['body']))
        elif resource_path == '/auth/register':
            return handle_register(json.loads(event['body']))
        else:
            return {
                'statusCode': 404,
                'body': json.dumps({'error': 'Not found'})
            }
            
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

def handle_login(body):
    try:
        # Initiate auth with Cognito
        response = cognito.initiate_auth(
            ClientId=os.environ['COGNITO_CLIENT_ID'],
            AuthFlow='USER_PASSWORD_AUTH',
            AuthParameters={
                'USERNAME': body['username'],
                'PASSWORD': body['password']
            }
        )
        
        # Get user permissions from DynamoDB
        user_permissions = user_permissions_table.get_item(
            Key={'user_id': body['username']}
        ).get('Item', {}).get('permissions', [])
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'token': response['AuthenticationResult']['IdToken'],
                'permissions': user_permissions
            })
        }
        
    except ClientError as e:
        return {
            'statusCode': 401,
            'body': json.dumps({'error': 'Invalid credentials'})
        }

def handle_register(body):
    try:
        # Register user in Cognito
        response = cognito.sign_up(
            ClientId=os.environ['COGNITO_CLIENT_ID'],
            Username=body['username'],
            Password=body['password'],
            UserAttributes=[
                {
                    'Name': 'email',
                    'Value': body['email']
                }
            ]
        )
        
        # Create initial permissions in DynamoDB
        user_permissions_table.put_item(
            Item={
                'user_id': body['username'],
                'permissions': ['read']  # Default permission
            }
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'User registered successfully'})
        }
        
    except ClientError as e:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': str(e)})
        }
