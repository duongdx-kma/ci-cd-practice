#!/usr/bin/env bash

set -e

# Update the system
apt-get update && apt-get upgrade -y

# Install required dependencies
apt-get install -y wget gnupg net-tools

# Install OpenJDK 17 (default)
apt-get install -y openjdk-17-jdk

# Install OpenJDK 11
apt-get install -y openjdk-11-jdk

# Add Jenkins repository and GPG key using the new method
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | gpg --dearmor -o /usr/share/keyrings/jenkins-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/jenkins-archive-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package lists and install Jenkins
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y jenkins

# Enable Jenkins to start on boot and start the service
systemctl enable jenkins
systemctl start jenkins

# Configure alternatives to manage multiple Java versions
update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-17-openjdk-amd64/bin/java 1
update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-11-openjdk-amd64/bin/java 2
update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac 1
update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-11-openjdk-amd64/bin/javac 2

# Set the default Java version to OpenJDK 17
update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java
update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac

# Set JAVA_HOME environment variable for OpenJDK 17
cat << EOF >> /etc/profile.d/jdk.sh
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export JAVA11_HOME=/usr/lib/jvm/java-11-openjdk-amd64

export PATH=\$JAVA11_HOME/bin:\$JAVA_HOME/bin:\$PATH
EOF

# Create symbolic links for java11 and javac11 commands to use Java 11 explicitly
ln -s /usr/lib/jvm/java-11-openjdk-amd64/bin/java /usr/local/bin/java11 || true
ln -s /usr/lib/jvm/java-11-openjdk-amd64/bin/javac /usr/local/bin/javac11 || true

# Apply the JAVA_HOME settings
source /etc/profile.d/jdk.sh
