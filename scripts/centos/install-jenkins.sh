#!/usr/bin/env bash
set -e

# Update the system
yum update -y

# Install OpenJDK 17
yum install -y java-17-openjdk

# Add Jenkins repository and GPG key
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

# Install Jenkins and Git
yum install -y jenkins git

# Enable Jenkins on boot and start the service
systemctl enable jenkins
systemctl start jenkins
