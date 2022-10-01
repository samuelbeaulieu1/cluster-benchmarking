#!/bin/sh

REGION="us-east-1"
AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""

# Session token is required for temporary access credentials
AWS_SESSION_TOKEN=""

while getopts a:s:t: flag;
do
    case "${flag}" in
        a) AWS_ACCESS_KEY_ID=${OPTARG};;
        s) AWS_SECRET_ACCESS_KEY=${OPTARG};;
        t) AWS_SESSION_TOKEN=${OPTARG};;
    esac
done

if [[ -z $AWS_ACCESS_KEY_ID ]] || [[ -z $AWS_SECRET_ACCESS_KEY ]] || [[ -z $AWS_SESSION_TOKEN ]]; then
    echo "Parameters -a (Access key ID), -s (Secret access key) and -t (session token) are required to execute"
    exit
fi

# Setting up AWS CLI
./infrastructure/setup_aws_cli.sh -a $AWS_ACCESS_KEY_ID -s $AWS_SECRET_ACCESS_KEY -t $AWS_SESSION_TOKEN -r $REGION

# Getting account ID for urls
ACCOUNT_ID=`aws sts get-caller-identity --query "Account" --output text`
CONTAINER_REPOSITORY_URL="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

# Building app and pushing to ECR
./infrastructure/push_app_ecr.sh -c $CONTAINER_REPOSITORY_URL -r $REGION


# Terraform build for EC2 instances, load balancer, target groups ...