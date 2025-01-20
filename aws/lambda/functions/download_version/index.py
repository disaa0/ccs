import json
import os
import boto3

s3 = boto3.client('s3')
BUCKET_NAME = os.environ['BUCKET_NAME']

def lambda_handler(event, context):
    params = event.get('queryStringParameters', {})
    key = params.get('key')
    version_id = params.get('versionId')

    if not key or not version_id:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Missing required parameters: key and versionId"})
        }

    try:
        url = s3.generate_presigned_url(
            'get_object',
            Params={'Bucket': BUCKET_NAME, 'Key': key, 'VersionId': version_id},
            ExpiresIn=60  # Link expires in 60 seconds
        )

        return {
            "statusCode": 200,
            "body": json.dumps({"url": url})
        }
    
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": f"Failed to generate download URL: {str(e)}"})
        }
