import boto3
import os

client = boto3.client('secretsmanager')


def get_token():
    response = client.get_secret_value(
        SecretId=os.environ["SECRET_ARN"],
    )

    f = open("/token/token.json", "w")
    f.write(response["SecretString"])
    f.close()


def set_token():
    f = open("/token/token.json", "r")
    token = f.read()

    client.put_secret_value(
        SecretId=os.environ["SECRET_ARN"],
        SecretString=token,
    )
