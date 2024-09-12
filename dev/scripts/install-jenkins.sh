#!/usr/bin/env bash

set -e

# Update the instance
yum update -y

# Install Amazon Corretto 17 (OpenJDK 17)
rpm --import https://yum.corretto.aws/corretto.key
curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
yum install -y java-17-amazon-corretto-devel

# Add Jenkins repository and import the GPG key
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins and Git
yum install -y jenkins git

# Enable Jenkins service to start on boot
systemctl enable jenkins

# Start Jenkins service
systemctl start jenkins
