#!/bin/bash

if [ ! -f updates.installed ]; then
  echo "## Running updates"
  sudo sudo yum update -y

  echo "## Installting tools.."
  sudo yum install nano -y
  sudo yum install wget -y
  sudo yum install unzip -y
  sudo yum install yum-utils -y
  sudo yum -y install epel-release
  sudo yum -y install htop

  echo "## Install new version of git"
  # gocd needs newer version of git
  sudo yum install http://opensource.wandisco.com/centos/7/git/x86_64/wandisco-git-release-7-1.noarch.rpm -y
  sudo yum install git -y

  echo "## Install Java OpenJDK"
  # gocd needs it
  sudo yum -y install java-1.8.0-openjdk-devel

  # only run once
  touch updates.installed
else 
  echo "### System already updated"
fi 
