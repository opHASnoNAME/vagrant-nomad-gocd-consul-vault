#!/bin/bash

if [ ! -f docker.installed ]; then
  echo "### Install Docker"

  sudo yum-config-manager \
  --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo

  sudo yum install docker-ce docker-ce-cli containerd.io -y
  sudo systemctl start docker
  sudo systemctl enable docker

  # allow go user to use docker
  sudo usermod -aG docker go

  # start docker registry on port 5000
  sudo docker run -d -p 5000:5000 --restart=always --name registry registry:2

  touch docker.installed
else 
  echo "### DOCKER already installed"
fi 
