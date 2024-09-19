#!/usr/bin/env bash
set -e

# Update the instance
yum update -y

# Install OpenJDK 17 (using Amazon Corretto or native OpenJDK)
rpm --import https://yum.corretto.aws/corretto.key
curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
yum install -y java-17-amazon-corretto-devel git

# Nexus Repository Setup
NEXUS_VERSION=3.72.0-04
NEXUS_DIR=/opt/nexus
NEXUS_USER=nexus

# Create Nexus user
useradd -m -d $NEXUS_DIR -s /bin/bash $NEXUS_USER
echo "nexus" | passwd --stdin $NEXUS_USER

# Download and install Nexus
wget -O /tmp/nexus-$NEXUS_VERSION-unix.tar.gz https://download.sonatype.com/nexus/3/nexus-$NEXUS_VERSION-unix.tar.gz
tar -xvzf /tmp/nexus-$NEXUS_VERSION-unix.tar.gz -C $NEXUS_DIR/
rm -rf /tmp/nexus-$NEXUS_VERSION-unix.tar.gz
ln -s $NEXUS_DIR/nexus-$NEXUS_VERSION $NEXUS_DIR/latest

# Configure Nexus to run as the Nexus user
chown -R $NEXUS_USER:$NEXUS_USER $NEXUS_DIR
sed -i 's/#run_as_user=""/run_as_user="nexus"/' $NEXUS_DIR/latest/bin/nexus.rc

# Configure JVM options
cat << EOF >> $NEXUS_DIR/latest/bin/nexus.vmoptions
-Xms1024m
-Xmx1024m
-XX:MaxDirectMemorySize=1024m
-XX:LogFile=./sonatype-work/nexus3/log/jvm.log
-XX:-OmitStackTraceInFastThrow
-Djava.net.preferIPv4Stack=true
-Dkaraf.home=.
-Dkaraf.base=.
-Dkaraf.etc=etc/karaf
-Djava.util.logging.config.file=/etc/karaf/java.util.logging.properties
-Dkaraf.data=./sonatype-work/nexus3
-Dkaraf.log=./sonatype-work/nexus3/log
-Djava.io.tmpdir=./sonatype-work/nexus3/tmp
EOF

# Create a systemd service file for Nexus
cat << EOF > /etc/systemd/system/nexus.service
[Unit]
Description=Nexus Service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=$NEXUS_DIR/latest/bin/nexus start
ExecStop=$NEXUS_DIR/latest/bin/nexus stop
User=nexus
Restart=on-abort
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=nexus-%i

[Install]
WantedBy=multi-user.target
EOF

# Start and enable Nexus service
systemctl daemon-reload
systemctl start nexus
systemctl enable nexus
