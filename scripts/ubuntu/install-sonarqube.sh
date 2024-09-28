#!/usr/bin/env bash

set -e

# ------ PostgreSQL Installation ------
apt-get update && apt-get upgrade -y
apt-get install -y postgresql postgresql-contrib vim

# Initialize PostgreSQL Database (done automatically during installation on Ubuntu)

# Update PostgreSQL configurations
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/14/main/postgresql.conf
sed -i "s/peer/md5/" /etc/postgresql/14/main/pg_hba.conf

# Start and enable PostgreSQL service
systemctl start postgresql
systemctl enable postgresql

# Change the password for the 'postgres' Linux user
echo "postgres:postgres123" | chpasswd

# Switch to 'postgres' user and configure PostgreSQL
su - postgres << EOF
psql -c "ALTER USER postgres WITH PASSWORD 'postgres123';"
psql -c "CREATE USER sonar WITH ENCRYPTED PASSWORD 'sonar123';"
psql -c "CREATE DATABASE sonarqube OWNER sonar;"
psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;"
EOF

# ------ SonarQube Installation ------
apt-get update -y
apt-get install -y openjdk-17-jdk unzip wget

SONAR_USER=sonar
SONAR_VERSION=10.6.0.92116
SONAR_DIR=/opt/sonar

# Create a SonarQube user
useradd -m -d $SONAR_DIR -s /bin/bash $SONAR_USER
echo "sonar:sonar" | chpasswd

# Download and extract SonarQube
wget -O /tmp/sonar-$SONAR_VERSION.zip https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip
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
sed -i "/APP_NAME=/a RUN_AS_USER=$SONAR_USER" $SONAR_DIR/sonarqube-$SONAR_VERSION/bin/linux-x86-64/sonar.sh

# Configure system limits
cat << EOF > /etc/sysctl.d/99-sonarqube.conf
vm.max_map_count=524288
fs.file-max=131072
EOF
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
systemctl enable --now sonarqube
systemctl start sonarqube
systemctl status sonarqube
