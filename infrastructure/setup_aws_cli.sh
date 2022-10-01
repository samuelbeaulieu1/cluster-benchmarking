#!/bin/sh

AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""
REGION="us-east-1"

# Session token is required for temporary access credentials
AWS_SESSION_TOKEN=""

while getopts a:s:t:r flag;
do
    case "${flag}" in
        a) AWS_ACCESS_KEY_ID=${OPTARG};;
        s) AWS_SECRET_ACCESS_KEY=${OPTARG};;
        t) AWS_SESSION_TOKEN=${OPTARG};;
        r) REGION=${OPTARG};;
    esac
done

sudo aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
sudo aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
sudo aws configure set aws_session_token $AWS_SESSION_TOKEN
sudo aws configure set default.region $REGION