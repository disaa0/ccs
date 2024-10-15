import json
import boto3

def lambda_handler(event, context):
    user_id = event['requestContext']['authorizer']['claims']['sub']
    
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('ccs_user_permissions')

    # Fetch user permissions from DynamoDB
    response = table.get_item(
        Key={
            'user_id': user_id
        }
    )
    
    if 'Item' in response:
        permission = response['Item']['permission']
    else:
        permission = 'none'

    # Update S3 policy dynamically based on permission
    if permission == 'read':
        return allow_policy("s3:GetObject")
    elif permission == 'write':
        return allow_policy("s3:PutObject")
    elif permission == 'delete':
        return allow_policy("s3:DeleteObject")
    else:
        return deny_policy()


def allow_policy(action):
    return {
        'principalId': 'user',
        'policyDocument': {
            'Version': '2012-10-17',
            'Statement': [{
                'Action': action,
                'Effect': 'Allow',
                'Resource': 'arn:aws:s3:::ccs/*'
            }]
        }
    }

def deny_policy():
    return {
        'principalId': 'user',
        'policyDocument': {
            'Version': '2012-10-17',
            'Statement': [{
                'Action': '*',
                'Effect': 'Deny',
                'Resource': '*'
            }]
        }
    }

