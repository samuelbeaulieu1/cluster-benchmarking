#!/bin/bash

# Installing dependencies and docker
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    awscli

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo aws ecr get-login-password --region ${REGION} | sudo docker login --username AWS --password-stdin ${CONTAINER_REPOSITORY_URL}

# Running app from docker container repository with env vars as input to script
sudo docker run --restart always -d -e "INSTANCE_ID=$INSTANCE_ID" -p 80:5000 ${CONTAINER_REPOSITORY_URL}/flask-app:latest
