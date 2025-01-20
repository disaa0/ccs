import json
import os
import boto3

s3 = boto3.client('s3')
BUCKET_NAME = os.environ['BUCKET_NAME']

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])
        key = body.get('key')
        version_id = body.get('versionId')

        if not key or not version_id:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Missing required parameters: key and versionId"})
            }

        # Copy the specified version to the same key, effectively restoring it
        s3.copy_object(
            Bucket=BUCKET_NAME,
            CopySource={'Bucket': BUCKET_NAME, 'Key': key, 'VersionId': version_id},
            Key=key
        )

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Version restored successfully"})
        }
    
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": f"Failed to restore version: {str(e)}"})
        }
