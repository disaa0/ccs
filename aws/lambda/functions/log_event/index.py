import json
import boto3
import os
import datetime
import uuid

dynamodb = boto3.resource("dynamodb")
table_name = os.getenv("DYNAMODB_TABLE")
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    """
    Lambda function to log API events into DynamoDB.
    """
    try:
        # Parse the request body
        body = json.loads(event.get("body", "{}"))
        
        # Extract necessary details
        log_entry = {
            "user_id": body.get("user_id", "anonymous"),  # Primary key
            "timestamp": datetime.datetime.utcnow().isoformat(),  # Sort key
            "event_id": str(uuid.uuid4()),  # Unique identifier
            "event_type": body.get("event_type", "unknown"),
            "metadata": body.get("metadata", {}),
        }
        
        # Store the log entry in DynamoDB
        table.put_item(Item=log_entry)
        
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",  # Configure as needed
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "message": "Event logged successfully",
                "event": log_entry
            }),
        }
    except Exception as e:
        print(f"Error logging event: {e}")
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*",  # Configure as needed
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "error": "Failed to log event",
                "details": str(e)
            }),
        }
