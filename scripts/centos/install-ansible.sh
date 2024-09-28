#!/usr/bin/env bash
set -e

# Enable EPEL repository
yum install epel-release -y

# Install required packages including Ansible
yum install -y python3 python3-devel python3-pip ansible

# Add the user ansibleadmin
useradd ansibleadmin

# Set password for ansibleadmin
echo "ansibleansible" | passwd --stdin ansibleadmin

# Modify sudoers for passwordless sudo
echo 'ansibleadmin     ALL=(ALL)      NOPASSWD: ALL' >> /etc/sudoers
echo 'centos     ALL=(ALL)      NOPASSWD: ALL' >> /etc/sudoers

# Enable Password Authentication for SSH
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

echo "Ansible installation and user configuration completed successfully."
