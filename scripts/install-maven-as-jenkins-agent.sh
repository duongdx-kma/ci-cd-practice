#!/usr/bin/env bash

set -e

# Install Jenkins
# Update the instance
yum update -y

# Install Amazon Corretto 17 (OpenJDK 17)
rpm --import https://yum.corretto.aws/corretto.key
curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
yum install -y java-17-amazon-corretto-devel \
  git

# Install Maven
MAVEN_VERSION=3.9.5
MAVEN_DIR=/opt/maven

wget https://dlcdn.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz
mkdir -p $MAVEN_DIR
tar -xvzf apache-maven-$MAVEN_VERSION-bin.tar.gz -C $MAVEN_DIR
ln -s $MAVEN_DIR/apache-maven-$MAVEN_VERSION $MAVEN_DIR/latest
ln -s $MAVEN_DIR/latest/bin/mvn /usr/bin/mvn

# Verify Maven installation
mvn -version

# Configure `This` server as `Jenkins Agent`

JENKINS_HOME=/home/jenkins
# Add the jenkins user and set up SSH access
useradd -m -s /bin/bash jenkins
mkdir -p $JENKINS_HOME/.ssh
chmod 700 $JENKINS_HOME/.ssh
touch $JENKINS_HOME/.ssh/authorized_keys
chmod 600 $JENKINS_HOME/.ssh/authorized_keys

# copy authorized_keys from ec2-user
cat /home/ec2-user/.ssh/authorized_keys >> $JENKINS_HOME/.ssh/authorized_keys
chown -R jenkins:jenkins $JENKINS_HOME/.ssh

# Modify the sudoers file to allow jenkins and ec2-user to use sudo without a password
echo 'jenkins ALL=NOPASSWD: /usr/bin/mvn' >> /etc/sudoers

# Enable Password Authentication in SSH
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Restart SSHD to apply the new settings
systemctl restart sshd

echo "Maven installation and user configuration completed successfully."
