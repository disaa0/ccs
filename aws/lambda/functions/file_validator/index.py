import json
import zipfile
import io
import os
from typing import Dict, Any
import boto3

s3_client = boto3.client('s3')

def move_s3_object(bucket: str, source_key: str, dest_key: str) -> None:
    """Move an S3 object from source to destination."""
    s3_client.copy_object(
        Bucket=bucket,
        CopySource={'Bucket': bucket, 'Key': source_key},
        Key=dest_key
    )
    s3_client.delete_object(Bucket=bucket, Key=source_key)

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    source_key = None
    try:
        # Parse request body
        body = json.loads(event['body'])
        # Remove any leading slashes from keys
        source_key = body['key'].lstrip('/')
        filename = body['filename']
        final_key = body['finalKey'].lstrip('/')
        
        print(f"Accessing source key: {source_key}")
        print(f"Final destination: {final_key}")
        
        # Get file from S3
        response = s3_client.get_object(
            Bucket=os.environ['BUCKET_NAME'],
            Key=source_key
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
        
        # Move file to final destination
        move_s3_object(
            bucket=os.environ['BUCKET_NAME'],
            source_key=source_key,
            dest_key=final_key
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
        if source_key:
            try:
                s3_client.delete_object(
                    Bucket=os.environ['BUCKET_NAME'],
                    Key=source_key
                )
            except Exception:
                pass
        
        return {
            'statusCode': 400,
            'body': json.dumps({
                'valid': False,
                'message': str(error)
            })
        }
