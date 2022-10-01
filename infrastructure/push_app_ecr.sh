#!/bin/sh

CONTAINER_REPOSITORY_URL=""
REGION=""

while getopts u:c: flag;
do
    case "${flag}" in
        c) CONTAINER_REPOSITORY_URL=${OPTARG};;
        r) REGION=${OPTARG};;
    esac
done

# Settings ECR credentials on docker
sudo aws ecr get-login-password --region ${REGION} | sudo docker login --username AWS --password-stdin ${CONTAINER_REPOSITORY_URL}

# Create repository if not exists
sudo aws ecr describe-repositories --repository-names flask-app || sudo aws ecr create-repository --repository-name flask-app

# Build docker image for app
sudo docker build -f ./app/Dockerfile -t flask-app:latest ./app

# Pushing new version on ECR
sudo docker tag flask-app:latest ${CONTAINER_REPOSITORY_URL}/flask-app:latest
sudo docker push ${CONTAINER_REPOSITORY_URL}/flask-app:latest