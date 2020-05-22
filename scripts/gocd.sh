#!/bin/bash

if [ ! -f gocd.installed ]; then
  
  echo "### Install GoCD Server"

  # See: https://github.com/gocd/gocd/issues/6947
  sudo setenforce 0
  
  # Add Repos
  sudo curl https://download.gocd.org/gocd.repo -o /etc/yum.repos.d/gocd.repo

  sudo yum install -y go-server
  sudo systemctl start go-server
  sudo systemctl enable go-server
  sudo mkdir /opt/artifacts
  sudo chown -R go:go /opt/artifacts

  sudo yum install -y go-agent
  sudo systemctl start go-agent
  sudo systemctl enable go-agent

  # only run once
  touch gocd.installed
else 
  echo "### GoCD already installed"
fi 