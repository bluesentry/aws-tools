#!/bin/bash

# Grabs ssh key from AWS Secrets Manger and stores temporarily so you can access an isntance through SSH.  
# Once connection is made, script deletes ssh key so it is not om the users hard drive.

rawstring=$(aws secretsmanager get-secret-value --secret-id [SECRETNAME] --profile [CUSTOMER_PROFILE] --region [REGION] --output text --query 'SecretString')
(echo $rawstring | sed 's/^.*-----BEGIN/-----BEGIN/' | sed 's/-----END RSA PRIVATE KEY-----*//g') > /tmp/sshkey.pem

ssh -i /tmp/sshkey.pem $1@$2

rm /tmp/sshkey.pem
