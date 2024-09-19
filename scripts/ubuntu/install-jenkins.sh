#!/usr/bin/env bash

set -e

# Update the system
apt-get update && apt-get upgrade -y

# Install required dependencies
apt-get install -y openjdk-17-jdk wget gnupg net-tools

# Add Jenkins repository and GPG key using the new method
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | gpg --dearmor -o /usr/share/keyrings/jenkins-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/jenkins-archive-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package lists and install Jenkins
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y jenkins

# Enable Jenkins to start on boot and start the service
systemctl enable jenkins
systemctl start jenkins
