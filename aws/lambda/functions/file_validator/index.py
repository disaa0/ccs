import json
import zipfile
import io
import os
from typing import Dict, Any
import boto3

s3_client = boto3.client('s3')

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    key = None  # Initialize key outside try block
    try:
        # Parse request body
        body = json.loads(event['body'])
        key = body['key']
        filename = body['filename']
        
        # Get file from S3
        response = s3_client.get_object(
            Bucket=os.environ['BUCKET_NAME'],
            Key=key
        )
        file_content = response['Body'].read()
        
        # Create file-like object from bytes
        zip_buffer = io.BytesIO(file_content)
        
        # Validation criteria
        max_total_size = 100 * 1024 * 1024  # 100MB
        allowed_extensions = {'.txt', '.pdf', '.jpg', '.png'}
        total_size = 0
        
        # Validate ZIP structure and contents
        try:
            with zipfile.ZipFile(zip_buffer, 'r') as zip_file:
                # Process each file in the ZIP
                for zip_info in zip_file.filelist:
                    # Check file size
                    total_size += zip_info.file_size
                    if total_size > max_total_size:
                        raise ValueError('ZIP contents exceed maximum allowed size')
                    
                    # Check file extensions
                    _, ext = os.path.splitext(zip_info.filename.lower())
                    if ext not in allowed_extensions:
                        raise ValueError(f'File type {ext} is not allowed')
                
        except zipfile.BadZipFile:
            raise ValueError('Invalid ZIP file format')
        
        # Clean up temporary file
        s3_client.delete_object(
            Bucket=os.environ['BUCKET_NAME'],
            Key=key
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'valid': True,
                'message': 'ZIP file validated successfully'
            })
        }
        
    except Exception as error:
        # Clean up temporary file on error
        if key:  # Only attempt cleanup if key was set
            try:
                s3_client.delete_object(
                    Bucket=os.environ['BUCKET_NAME'],
                    Key=key
                )
            except Exception:
                # Ignore cleanup errors
                pass
        
        return {
            'statusCode': 400,
            'body': json.dumps({
                'valid': False,
                'message': str(error)
            })
        }
