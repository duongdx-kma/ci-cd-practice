#!/usr/bin/env bash

set -e

# ------ PostgreSQL Installation ------
yum update -y

amazon-linux-extras install postgresql14 vim epel
yum install -y postgresql-server postgresql

# Initialize PostgreSQL Database
postgresql-setup --initdb

# Update PostgreSQL configurations
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /var/lib/pgsql/data/postgresql.conf
sed -i "s/ident/md5/" /var/lib/pgsql/data/pg_hba.conf

# Start and enable PostgreSQL service
systemctl start postgresql
systemctl enable postgresql

# Change the password for the 'postgres' Linux user
echo "postgres123" | passwd --stdin postgres

# Switch to 'postgres' user and configure PostgreSQL
su - postgres << EOF
# Change the password for the 'postgres' database user
psql -c "ALTER USER postgres WITH PASSWORD 'postgres123';"

# Create user 'sonar' and database 'sonarqube'
psql -c "CREATE USER sonar WITH ENCRYPTED PASSWORD 'sonar123';"
psql -c "CREATE DATABASE sonarqube OWNER sonar;"
psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;"
EOF

# ------ SonarQube Installation ------

# Update system and install Amazon Corretto 17 (OpenJDK 17)
yum update -y
rpm --import https://yum.corretto.aws/corretto.key
curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
yum install -y java-17-amazon-corretto-devel

SONAR_USER=sonar
SONAR_VERSION=10.6.0.92116
SONAR_DIR=/opt/sonar

# Create a SonarQube user
useradd -m -d $SONAR_DIR -s /bin/bash $SONAR_USER
echo "sonar" | passwd --stdin $SONAR_USER

# Download and extract SonarQube
wget -O /tmp/sonar-$SONAR_VERSION.zip \
  https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip
unzip /tmp/sonar-$SONAR_VERSION.zip -d $SONAR_DIR
rm -f /tmp/sonar-$SONAR_VERSION.zip

# Set correct ownership for SonarQube files
chown -R $SONAR_USER:$SONAR_USER $SONAR_DIR/sonarqube-$SONAR_VERSION

# Create a symbolic link to the latest SonarQube version
ln -s $SONAR_DIR/sonarqube-$SONAR_VERSION $SONAR_DIR/latest

# Configure SonarQube database connection
cat << EOF >> $SONAR_DIR/sonarqube-$SONAR_VERSION/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=sonar123
sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube
sonar.web.host=0.0.0.0
sonar.web.port=9000
EOF

# Set SonarQube to run as the 'sonar' user
cp $SONAR_DIR/sonarqube-$SONAR_VERSION/bin/linux-x86-64/sonar.sh $SONAR_DIR/sonarqube-$SONAR_VERSION/bin/linux-x86-64/sonar.sh.bak

# Insert the line after the line containing `APP_NAME=`
sed -i "/APP_NAME=/a RUN_AS_USER=$SONAR_USER" $SONAR_DIR/sonarqube-$SONAR_VERSION/bin/linux-x86-64/sonar.sh

# Configure system limits
cat << EOF > /etc/sysctl.d/99-sonarqube.conf
vm.max_map_count=524288
fs.file-max=131072
EOF

# Apply sysctl settings
sysctl -p /etc/sysctl.d/99-sonarqube.conf

cat << EOF > /etc/security/limits.d/99-sonarqube.conf
sonar   -   nofile   131072
sonar   -   nproc    8192
EOF

# Configure systemd service for SonarQube
cat << EOF > /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=$SONAR_DIR/latest/bin/linux-x86-64/sonar.sh start
ExecStop=$SONAR_DIR/latest/bin/linux-x86-64/sonar.sh stop
User=$SONAR_USER
Group=$SONAR_USER
Restart=always
LimitNOFILE=131072
LimitNPROC=8192
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=sonar-%i

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start SonarQube service
systemctl daemon-reload
systemctl enable --now sonar
systemctl start sonar
systemctl status sonar
