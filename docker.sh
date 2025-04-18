#!/bin/bash

# Load environment variables from .env file
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo ".env file not found! Please create one with DOCKER_USERNAME and DOCKER_PASSWORD."
  exit 1
fi

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install Docker components
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Log in to Docker Hub
if [[ -z "$DOCKER_USERNAME" || -z "$DOCKER_PASSWORD" ]]; then
  echo "Docker Hub credentials are not set in .env. Aborting login."
  exit 1
fi

echo "$DOCKER_PASSWORD" | sudo docker login -u "$DOCKER_USERNAME" --password-stdin

if [ $? -eq 0 ]; then
  echo "Successfully logged into Docker Hub."
else
  echo "Failed to log into Docker Hub."
  exit 1
fi