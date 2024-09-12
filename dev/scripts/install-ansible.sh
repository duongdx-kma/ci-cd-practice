#!/usr/bin/env bash

set -e

# Enable the EPEL repository
amazon-linux-extras install epel -y

# Install required packages including Ansible
yum install -y python3 python3-devel python3-pip ansible

# Add the user ansibleadmin
useradd ansibleadmin

# Set password for ansibleadmin
echo "ansibleansible" | passwd --stdin ansibleadmin

# Modify the sudoers file to allow ansibleadmin and ec2-user to use sudo without a password
echo 'ansibleadmin     ALL=(ALL)      NOPASSWD: ALL' >> /etc/sudoers
echo 'ec2-user     ALL=(ALL)      NOPASSWD: ALL' >> /etc/sudoers

# Enable Password Authentication in SSH
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Restart SSHD to apply the new settings
systemctl restart sshd

echo "Ansible installation and user configuration completed successfully."
