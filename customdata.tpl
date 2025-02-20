#!/bin/bash
sudo apt-get update -y &&
sudo apt-get install -y \

apt-transport-https \
ca-certificates \
curl \
gnupg-agent \
software-properties-common \
git \
vim \
htop \
python3-pip \
docker-compose &&

# Add Docker repository and install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && 
sudo apt-get update -y &&
sudo apt-get install docker-ce docker-ce-cli containerd.io -y &&

# Add user to docker group
sudo usermod -aG docker azureuser &&

# Install docker-compose 
sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose &&
sudo chmod +x /usr/local/bin/docker-compose &&

# Verify 
echo "Installation complete."
docker --version
docker-compose --version
git --version
vim --version
htop --version
python3 --version
pip3 --version
