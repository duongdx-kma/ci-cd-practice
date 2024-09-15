# SonarQube

## I. Component of SonarQube

### 1. SonarQube Server:
1. Rule
2. Database
3. Web Interface

### 2. SonarScanner:
1. SourceCode

# PostgreSQL and SonarQube Installation Guide

### 1. Install PostgreSQL

```bash
yum update -y
amazon-linux-extras install postgresql14 vim epel
yum install -y postgresql-server postgresql
```

### 2. Initialize PostgreSQL Database
```bash
postgresql-setup --initdb
```
### 3. Update PostgreSQL Configurations
```bash
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /var/lib/pgsql/data/postgresql.conf
sed -i "s/ident/md5/" /var/lib/pgsql/data/pg_hba.conf
```

### 4. Start and Enable PostgreSQL Service
```bash
systemctl start postgresql
systemctl enable postgresql
```

### 5. Change Password for 'postgres' Linux User
```bash
echo "postgres123" | passwd --stdin postgres
```

### 6. Configure PostgreSQL as 'postgres' User
```bash
su - postgres << EOF
psql -c "ALTER USER postgres WITH PASSWORD 'postgres123';"
psql -c "CREATE USER sonar WITH ENCRYPTED PASSWORD 'sonar123';"
psql -c "CREATE DATABASE sonarqube OWNER sonar;"
psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;"
EOF
```

### 7. Install Amazon Corretto 17 (OpenJDK 17)
```bash
yum update -y
rpm --import https://yum.corretto.aws/corretto.key
curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
yum install -y java-17-amazon-corretto-devel
```

### 8. Create SonarQube User
```bash
SONAR_USER=sonar
SONAR_VERSION=10.6.0.92116
SONAR_DIR=/opt/sonar

useradd -m -d $SONAR_DIR -s /bin/bash $SONAR_USER
echo "sonar" | passwd --stdin $SONAR_USER
```

### 9. Download and Extract SonarQube
```bash
wget -O /tmp/sonar-$SONAR_VERSION.zip \
  https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip
unzip /tmp/sonar-$SONAR_VERSION.zip -d $SONAR_DIR
rm -f /tmp/sonar-$SONAR_VERSION.zip
```

### 10. Set Ownership for SonarQube Files
```bash
chown -R $SONAR_USER:$SONAR_USER $SONAR_DIR/sonarqube-$SONAR_VERSION
```

### 11. Create Symbolic Link to Latest SonarQube Version
```bash
ln -s $SONAR_DIR/sonarqube-$SONAR_VERSION $SONAR_DIR/sonarqube
```

### 12. Configure SonarQube Database Connection
```bash
cat << EOF >> $SONAR_DIR/sonarqube-$SONAR_VERSION/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=sonar123
sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube
sonar.web.host=0.0.0.0
sonar.web.port=9000
EOF
```

### 13. Set SonarQube to Run as the 'sonar' User
```bash
cp $SONAR_DIR/sonarqube-$SONAR_VERSION/bin/linux-x86-64/sonar.sh $SONAR_DIR/sonarqube-$SONAR_VERSION/bin/linux-x86-64/sonar.sh.bak
sed -i "/APP_NAME=/a RUN_AS_USER=$SONAR_USER" $SONAR_DIR/sonarqube-$SONAR_VERSION/bin/linux-x86-64/sonar.sh
```

### 14. Configure System Limits
```bash
cat << EOF > /etc/sysctl.d/99-sonarqube.conf
vm.max_map_count=524288
fs.file-max=131072
EOF

sysctl -p /etc/sysctl.d/99-sonarqube.conf

cat << EOF > /etc/security/limits.d/99-sonarqube.conf
sonar   -   nofile   131072
sonar   -   nproc    8192
EOF
```

### 15. Configure systemd Service for SonarQube
```bash
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

systemctl daemon-reload
systemctl enable --now sonar
systemctl start sonar
systemctl status sonar
```

# Platform notes:

```
Editing system limits is recommended for SonarQube because the application can require higher resource limits than the default configurations, especially in production environments or when handling large codebases. Here's why these specific limits are important
```
### 1. vm.max_map_count (524288):
```
This setting controls the maximum number of memory map areas a process may have. SonarQube, along with Elasticsearch (which SonarQube uses), requires a large number of memory mappings to efficiently index and search through the codebase.
If this value is too low, Elasticsearch (and by extension SonarQube) may fail to start or work inefficiently.
```
### 2. fs.file-max (131072):
```
This setting controls the maximum number of file descriptors the system can handle. SonarQube may need to open many files during code analysis, and insufficient file descriptors can cause the system to run out of resources, leading to errors.
Increasing this ensures that the system can handle the number of files SonarQube needs to open simultaneously.
```
### 3. File Descriptors (ulimit -n to 131072):
```
This limit controls how many files a single process (in this case, SonarQube) can open at once. A low limit might result in "too many open files" errors, especially when analyzing large projects or when there are many simultaneous users.
```
### 4. Process Limits (ulimit -u to 8192):
```
This setting controls the number of processes/threads a user can create. SonarQube, being a Java application, may create many threads for background tasks, code analysis, and indexing.
By raising the thread count, you ensure that SonarQube won’t hit system-imposed thread limits, which can cause failures under heavy load.
Why Adjusting These Limits Is Necessary:
For large deployments: If you're running SonarQube in a small environment, you may not see immediate issues with default system limits, but as the codebase grows or the number of users increases, SonarQube can hit resource limits.
Elasticsearch: SonarQube uses Elasticsearch for indexing, which is resource-intensive. Elasticsearch requires these higher settings to perform optimally.
Even though your SonarQube instance is working now, if you plan to scale it, these limits will help prevent performance degradation, random crashes, or instability under load. Therefore, adjusting these limits is considered a best practice in any SonarQube setup, particularly for production or heavy use cases.
```