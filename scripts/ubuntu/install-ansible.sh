#!/usr/bin/env bash
set -e

# Update the system and install necessary packages
apt-get update
apt-get install -y python3 python3-dev python3-pip ansible

# Add the user ansibleadmin
useradd -m -s /bin/bash ansibleadmin

# Set password for ansibleadmin
echo "ansibleadmin:ansibleansible" | chpasswd

# Modify sudoers for passwordless sudo
echo 'ansibleadmin     ALL=(ALL)      NOPASSWD: ALL' >> /etc/sudoers
echo 'ubuntu     ALL=(ALL)      NOPASSWD: ALL' >> /etc/sudoers

# Enable Password Authentication for SSH
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart ssh

echo "Ansible installation and user configuration completed successfully."
