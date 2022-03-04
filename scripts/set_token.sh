#!/bin/bash

if [ -n "$ACCOUNT_ID" ] && [ -n "$AWS_ACCESS_KEY_ID" ] && [ -n "$AWS_SECRET_ACCESS_KEY" ] && [ -n "$AWS_DEFAULT_REGION" ] && [ -n "$SECRET_ARN" ]; then
  cd bot
  docker build -t tdbot:latest .
  cd ../

  docker run -it -e ACCOUNT_ID=$ACCOUNT_ID -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION -e SECRET_ARN=$SECRET_ARN \
    -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID tdbot:latest set_token.py
else
  echo "Please set ACCOUNT_ID environment variable to your TD Ameritrade account ID"
  echo "Please set AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY and AWS_DEFAULT_REGION environment variables"
  echo "export ACCOUNT_ID=\"<your account ID>\""
fi