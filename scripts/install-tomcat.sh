#!/usr/bin/env bash

set -e

# Update the instance
yum update -y

# Install Amazon Corretto 17 (OpenJDK 17)
rpm --import https://yum.corretto.aws/corretto.key
curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
yum install -y java-17-amazon-corretto-devel

# create `tomcat` user
useradd -r -s /bin/false tomcat

# install tomcat
TOMCAT_DIR=/opt/tomcat
TOMCAT_VERSION=9.0.86

# make tomcat dir
mkdir -p $TOMCAT_DIR
chown -R tomcat:tomcat $TOMCAT_DIR

# download tomcat
wget -O /tmp/apache-tomcat-$TOMCAT_VERSION.tar.gz \
  https://archive.apache.org/dist/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

# extract tomcat
tar -xvzf /tmp/apache-tomcat-$TOMCAT_VERSION.tar.gz -C $TOMCAT_DIR

# remove origin tar.gz
rm -rf /tmp/apache-tomcat-$TOMCAT_VERSION.tar.gz

# Set ownership of Tomcat files
chown -R tomcat:tomcat $TOMCAT_DIR/apache-tomcat-$TOMCAT_VERSION

# create link files for tomcat:
ln -s $TOMCAT_DIR/apache-tomcat-$TOMCAT_VERSION $TOMCAT_DIR/latest
# ln -s $TOMCAT_DIR/latest/bin/startup.sh /usr/local/bin/tomcatup
# ln -s $TOMCAT_DIR/latest/bin/shutdown.sh /usr/local/bin/tomcatdown

# # Set correct permissions for startup and shutdown scripts
# mkdir -p /usr/local/bin
# chmod +x /usr/local/bin/tomcatup
# chmod +x /usr/local/bin/tomcatdown

# Create Tomcat systemd service file
cat << EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat
Environment="JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto"
Environment="CATALINA_PID=$TOMCAT_DIR/latest/temp/tomcat.pid"
Environment="CATALINA_HOME=$TOMCAT_DIR/latest"
Environment="CATALINA_BASE=$TOMCAT_DIR/latest"
ExecStart=$TOMCAT_DIR/latest/bin/catalina.sh start
ExecStop=$TOMCAT_DIR/latest/bin/catalina.sh stop
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=tomcat-%i
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# check tomcat service logs:
# journalctl -u tomcat.service


# Reload systemd to apply the new service
systemctl daemon-reload

# Enable and start Tomcat service
systemctl enable tomcat
systemctl start tomcat

# Modify `context.xml` to allow access from all IPs
cat << EOF > $TOMCAT_DIR/apache-tomcat-$TOMCAT_VERSION/webapps/manager/META-INF/context.xml
<?xml version="1.0" encoding="UTF-8"?>

<Context antiResourceLocking="false" privileged="true" >
  <CookieProcessor className="org.apache.tomcat.util.http.Rfc6265CookieProcessor"
                   sameSiteCookies="strict" />
  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow=".*" />
  <Manager sessionAttributeValueClassNameFilter="java\.lang\.(?:Boolean|Integer|Long|Number|String)|org\.apache\.catalina\.filters\.CsrfPreventionFilter\$LruCache(?:\$1)?|java\.util\.(?:Linked)?HashMap"/>
</Context>
EOF

# Add user to `tomcat-users.xml`
cat << EOF > $TOMCAT_DIR/apache-tomcat-$TOMCAT_VERSION/conf/tomcat-users.xml
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">

  <role rolename="manager-gui"/>
  <role rolename="manager-script"/>
  <role rolename="manager-jmx"/>
  <role rolename="manager-status"/>

  <user username="admin" password="admin" roles="manager-gui,manager-script,manager-jmx,manager-status"/>
  <user username="deployer" password="deployer" roles="manager-script"/>
  <user username="tomcat" password="s3cret" roles="manager-gui"/>
</tomcat-users>

EOF

# Restart Tomcat to apply the changes
systemctl restart tomcat