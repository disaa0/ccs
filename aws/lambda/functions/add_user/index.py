import boto3
import json
import os

iam = boto3.client("iam")
s3 = boto3.client("s3")
bucket_name = os.environ.get('BUCKET_NAME')

def create_iam_role(user_name):
    role_name = f"{user_name}_role"
    
    assume_role_policy = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {"AWS": "*"},
                "Action": "sts:AssumeRole"
            }
        ]
    }

    try:
        response = iam.create_role(
            RoleName=role_name,
            AssumeRolePolicyDocument=json.dumps(assume_role_policy)
        )
        return response['Role']['Arn']
    except iam.exceptions.EntityAlreadyExistsException:
        return iam.get_role(RoleName=role_name)['Role']['Arn']

def attach_s3_policy(role_name, user_name):
    policy_document = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": ["s3:GetObject", "s3:PutObject"],
                "Resource": f"arn:aws:s3:::{bucket_name}/{user_name}/*"
            }
        ]
    }

    iam.put_role_policy(
        RoleName=role_name,
        PolicyName=f"{user_name}_s3_policy",
        PolicyDocument=json.dumps(policy_document)
    )

def lambda_handler(event, context):

    if "body" in event:
        body = json.loads(event["body"])  # API Gateway request
    else:
        body = event  # Direct Lambda invocation

    user_name = body.get("username")

    if not user_name:
        return {"statusCode": 400, "body": json.dumps({"error": "Username required"})}

    role_arn = create_iam_role(user_name)
    attach_s3_policy(f"{user_name}_role", user_name)

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "User IAM Role Created", "role_arn": role_arn})
    }
