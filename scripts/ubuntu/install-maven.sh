#!/usr/bin/env bash

set -e

# Detect OS and version
os=""
version=""
if [[ -e /etc/centos-release ]]; then
    os="centos"
    version=$(rpm -q --queryformat '%{VERSION}' centos-release)
elif [[ -e /etc/lsb-release ]]; then
    os="ubuntu"
    version=$(lsb_release -sr)
fi

# Function to install dependencies for CentOS
install_centos() {
    # Update the instance
    yum update -y

    # Install OpenJDK 17 for CentOS
    yum install -y java-17-openjdk-devel git

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
}

# Function to install dependencies for Ubuntu
install_ubuntu() {
    # Update the instance
    apt-get update -y
    apt-get upgrade -y

    # Install OpenJDK 17 for Ubuntu
    apt-get install -y openjdk-17-jdk git wget

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
}

# Jenkins user configuration
configure_jenkins() {
    JENKINS_HOME=/home/jenkins
    useradd -m -s /bin/bash jenkins || true
    mkdir -p $JENKINS_HOME/.ssh
    chmod 700 $JENKINS_HOME/.ssh
    touch $JENKINS_HOME/.ssh/authorized_keys
    chmod 600 $JENKINS_HOME/.ssh/authorized_keys

    # Copy authorized_keys from root or current user
    cat ~/.ssh/authorized_keys >> $JENKINS_HOME/.ssh/authorized_keys
    chown -R jenkins:jenkins $JENKINS_HOME/.ssh

    # Allow Jenkins to run mvn without password
    echo 'jenkins ALL=NOPASSWD: /usr/bin/mvn' >> /etc/sudoers

    # Enable password authentication in SSH
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    systemctl restart sshd
}

# Main installation logic
if [[ "$os" == "centos" ]]; then
    echo "Running installation on CentOS $version"
    install_centos
elif [[ "$os" == "ubuntu" ]]; then
    echo "Running installation on Ubuntu $version"
    install_ubuntu
else
    echo "Unsupported OS"
    exit 1
fi

# Jenkins setup
configure_jenkins

echo "Maven installation and user configuration completed successfully."
