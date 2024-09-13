#!/usr/bin/env bash

set -e

# Install Jenkins
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

# Install Maven
MAVEN_VERSION=3.9.5
MAVEN_DIR=/opt/maven

wget https://dlcdn.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz
mkdir -p $MAVEN_DIR
tar -xvzf apache-maven-$MAVEN_VERSION-bin.tar.gz -C $MAVEN_DIR
ln -s $MAVEN_DIR/apache-maven-$MAVEN_VERSION /opt/maven/latest
ln -s /opt/maven/latest/bin/mvn /usr/bin/mvn

# Verify Maven installation
mvn -version