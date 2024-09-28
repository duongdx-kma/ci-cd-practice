#!/usr/bin/env bash

# Update the package list
apt-get update -y

# Install Nginx and PHP
apt-get install -y nginx php php-cli php-fpm php-mysql php-xml php-opcache php-mbstring php-zip php-pgsql

# Start and enable services
systemctl start nginx
systemctl enable nginx
systemctl start php-fpm
systemctl enable php-fpm

# Modify PHP-FPM configuration
sed -i 's/user = www-data/user = nginx/' /etc/php/7.4/fpm/pool.d/www.conf
sed -i 's/group = www-data/group = nginx/' /etc/php/7.4/fpm/pool.d/www.conf
systemctl restart php7.4-fpm

# Configure Nginx (you can copy your existing configuration here)
