#!/usr/bin/env bash

# Update the package list
sudo yum update -y

# Install Nginx
sudo amazon-linux-extras install nginx1 -y

# Install EPEL repository for additional packages
sudo amazon-linux-extras install epel -y

# Install PHP 8.x and related modules
sudo amazon-linux-extras enable php8.0
sudo yum install -y php php-cli php-fpm php-mysqlnd php-xml php-opcache php-mbstring php-zip

# Install PostgreSQL support for PHP
sudo yum install -y php-pgsql

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Start and enable PHP-FPM
sudo systemctl start php-fpm
sudo systemctl enable php-fpm

# Print versions to verify installation
php -v
nginx -v

PHP_FPM_DIR=/etc/php-fpm/www.conf
# change php-fpm user/group
sed -i "/user = apache/user = nginx" $PHP_FPM_DIR
sed -i "/group = apache/group = nginx" $PHP_FPM_DIR

systemctl restart php-fpm

# re-config nginx for website
rm -rf /etc/nginx/nginx.conf.default
cat << EOF > /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    include /etc/nginx/conf.d/*.conf;

    server {
        listen 80;

        root /var/www/html/public/;
        index index.php;

        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;

        location = /favicon.ico {
            log_not_found off;
            access_log off;
        }

        location = /robots.txt {
            allow all;
            log_not_found off;
            access_log off;
        }

        location / {
            try_files \$uri \$uri/ /index.php?\$args;
        }

        location ~ \.php$ {
            try_files $uri = 404;
            fastcgi_pass unix:/run/php-fpm/www.sock;
            fastcgi_index   index.php;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            include fastcgi_params;
        }

        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires max;
            log_not_found off;
        }

    }
}
EOF

systemctl restart nginx