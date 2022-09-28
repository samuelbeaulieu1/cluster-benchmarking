#!/bin/bash

INSTANCEID=1
REPOSITORY_URL=""

while getopts r:i: flag;
do
    case "${flag}" in
        i) INSTANCEID=${OPTARG};;
        r) REPOSITORY_URL=${OPTARG};;
    esac
done

# Installing dependencies and docker
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Running app from docker container repository with env vars as input to script
sudo docker run --restart always -d -e "INSTANCE_ID=$INSTANCEID" -p 80:5000 ${REPOSITORY_URL}/flask-app:latest
