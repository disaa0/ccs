# TODO Finish testing
import unittest
from unittest.mock import patch
from moto import mock_dynamodb2
import boto3
import json
from permission_checker import lambda_handler, allow_policy, deny_policy

class TestPermissionChecker(unittest.TestCase):
    
    @mock_dynamodb2
    def setUp(self):
        # Set up the mocked DynamoDB table
        self.dynamodb = boto3.resource('dynamodb', region_name='eu-north-1')
        self.table = self.dynamodb.create_table(
            TableName='ccs_user_permissions',
            KeySchema=[
                {
                    'AttributeName': 'user_id',
                    'KeyType': 'HASH'
                }
            ],
            AttributeDefinitions=[
                {
                    'AttributeName': 'user_id',
                    'AttributeType': 'S'
                }
            ],
            ProvisionedThroughput={
                'ReadCapacityUnits': 5,
                'WriteCapacityUnits': 5
            }
        )
        self.table.wait_until_exists()

        # Adding some test data
        self.table.put_item(Item={'user_id': 'user123', 'permission': 'read'})
        self.table.put_item(Item={'user_id': 'user456', 'permission': 'write'})
        self.table.put_item(Item={'user_id': 'user789', 'permission': 'delete'})
    
    @mock_dynamodb2
    def tearDown(self):
        # Delete the table after tests
        self.table.delete()
    
    def test_read_permission(self):
        event = {
            'requestContext': {
                'authorizer': {
                    'claims': {'sub': 'user123'}
                }
            }
        }

        response = lambda_handler(event, None)
        expected_response = allow_policy("s3:GetObject")
        self.assertEqual(response, expected_response)
    
    def test_write_permission(self):
        event = {
            'requestContext': {
                'authorizer': {
                    'claims': {'sub': 'user456'}
                }
            }
        }

        response = lambda_handler(event, None)
        expected_response = allow_policy("s3:PutObject")
        self.assertEqual(response, expected_response)

    def test_delete_permission(self):
        event = {
            'requestContext': {
                'authorizer': {
                    'claims': {'sub': 'user789'}
                }
            }
        }

        response = lambda_handler(event, None)
        expected_response = allow_policy("s3:DeleteObject")
        self.assertEqual(response, expected_response)

    def test_no_permission(self):
        event = {
            'requestContext': {
                'authorizer': {
                    'claims': {'sub': 'unknown_user'}
                }
            }
        }

        response = lambda_handler(event, None)
        expected_response = deny_policy()
        self.assertEqual(response, expected_response)

if __name__ == '__main__':
    unittest.main()

Explanation:

    SetUp:
        We use moto.mock_dynamodb2 to mock the DynamoDB service.
        We create a table called ccs_user_permissions and insert some test data for different users (user123, user456, user789), each with a different permission (read, write, delete).

    tearDown:
        After each test, we delete the mock table to ensure a clean environment for the next test.

    Test Cases:
        Each test case checks the Lambda function behavior when a user with a specific permission (or no permission) invokes it.
        For example, in test_read_permission(), we check that a user with read permission gets the expected policy allowing s3:GetObject.

How It Works:

    moto mocks the DynamoDB interactions, so no actual AWS calls are made.
    The tests simulate what happens when users with different permissions invoke the Lambda function.
    You can extend this by adding more test cases if needed.

Let me know if you need help with anything else!
class TestPermissionChecker(unittest.TestCase):
    
    @mock_dynamodb2
    def setUp(self):
        # Set up the mocked DynamoDB table
        self.dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
        self.table = self.dynamodb.create_table(
            TableName='ccs_user_permissions',
            KeySchema=[
                {
                    'AttributeName': 'user_id',
                    'KeyType': 'HASH'
                }
            ],
            AttributeDefinitions=[
                {
                    'AttributeName': 'user_id',
                    'AttributeType': 'S'
                }
            ],
            ProvisionedThroughput={
                'ReadCapacityUnits': 5,
                'WriteCapacityUnits': 5
            }
        )
        self.table.wait_until_exists()

        # Adding some test data
        self.table.put_item(Item={'user_id': 'user123', 'permission': 'read'})
        self.table.put_item(Item={'user_id': 'user456', 'permission': 'write'})
        self.table.put_item(Item={'user_id': 'user789', 'permission': 'delete'})
    
    @mock_dynamodb2
    def tearDown(self):
        # Delete the table after tests
        self.table.delete()
    
    def test_read_permission(self):
        event = {
            'requestContext': {
                'authorizer': {
                    'claims': {'sub': 'user123'}
                }
            }
        }

        response = lambda_handler(event, None)
        expected_response = allow_policy("s3:GetObject")
        self.assertEqual(response, expected_response)
    
    def test_write_permission(self):
        event = {
            'requestContext': {
                'authorizer': {
                    'claims': {'sub': 'user456'}
                }
            }
        }

        response = lambda_handler(event, None)
        expected_response = allow_policy("s3:PutObject")
        self.assertEqual(response, expected_response)

    def test_delete_permission(self):
        event = {
            'requestContext': {
                'authorizer': {
                    'claims': {'sub': 'user789'}
                }
            }
        }

        response = lambda_handler(event, None)
        expected_response = allow_policy("s3:DeleteObject")
        self.assertEqual(response, expected_response)

    def test_no_permission(self):
        event = {
            'requestContext': {
                'authorizer': {
                    'claims': {'sub': 'unknown_user'}
                }
            }
        }

        response = lambda_handler(event, None)
        expected_response = deny_policy()
        self.assertEqual(response, expected_response)

if __name__ == '__main__':
    unittest.main()
