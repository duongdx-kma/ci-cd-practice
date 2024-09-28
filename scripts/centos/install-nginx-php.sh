#!/usr/bin/env bash

# Update the system
yum update -y

# Install EPEL for additional packages
yum install epel-release -y

# Install Nginx and PHP
yum install -y nginx php php-cli php-fpm php-mysqlnd php-xml php-opcache php-mbstring php-zip php-pgsql

# Start and enable services
systemctl start nginx
systemctl enable nginx
systemctl start php-fpm
systemctl enable php-fpm

# Modify PHP-FPM configuration
sed -i 's/user = apache/user = nginx/' /etc/php-fpm.d/www.conf
sed -i 's/group = apache/group = nginx/' /etc/php-fpm.d/www.conf
systemctl restart php-fpm

# Configure Nginx (you can copy your existing configuration here)
