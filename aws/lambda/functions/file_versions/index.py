import json
import os
import boto3

s3 = boto3.client('s3')
BUCKET_NAME = os.environ['BUCKET_NAME']

def lambda_handler(event, context):
    key = event.get('queryStringParameters', {}).get('key')
    
    if not key:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Missing required parameter: key"})
        }
    
    try:
        versions = s3.list_object_versions(Bucket=BUCKET_NAME, Prefix=key)
        version_list = [
            {
                "versionId": v["VersionId"],
                "lastModified": str(v["LastModified"]),
                "size": v["Size"]
            }
            for v in versions.get("Versions", [])
        ]

        return {
            "statusCode": 200,
            "body": json.dumps({"versions": version_list})
        }
    
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": f"Failed to fetch versions: {str(e)}"})
        }
