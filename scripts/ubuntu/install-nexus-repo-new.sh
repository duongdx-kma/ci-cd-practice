#!/usr/bin/env bash
set -e

# Update the system
echo "===== Ubuntu update ====="
apt-get update && apt-get upgrade -y

# Install OpenJDK 17 and Git
echo "===== install openjdk and dependencies ====="
apt-get install -y openjdk-17-jdk \
    git \
    wget tar \
    systemd net-tools

# Nexus Repository Setup
ARCHITECTURE=$(uname -m)
NEXUS_VERSION=3.87.0-03
NEXUS_DIR="/opt/nexus"
DATA_DIR="/opt/sonatype-work"
NEXUS_USER=nexus
DOWNLOAD_DIR=/tmp

echo "===== Creating Nexus User ====="
# Create Nexus user
useradd -r -m -U -d $NEXUS_DIR -s /bin/false nexus || true
# echo "nexus:nexus" | chpasswd

echo "===== Downloading Nexus to /tmp ====="

# change dir to /tmp
cd $DOWNLOAD_DIR

# Download and install Nexus
wget -O nexus.tar.gz https://download.sonatype.com/nexus/3/nexus-$NEXUS_VERSION-linux-$ARCHITECTURE.tar.gz

echo "===== Extracting Nexus ====="
tar -xvzf nexus.tar.gz
rm -rf nexus.tar.gz

# Detect extracted folder name automatically
EXTRACTED_FOLDER=$(ls -d nexus-* | head -n 1)
echo "Moving to $NEXUS_DIR"
if [ -d "$EXTRACTED_FOLDER" ] && [ "$(ls -A "$EXTRACTED_FOLDER")" ]; then
    mv "$EXTRACTED_FOLDER"/* "$NEXUS_DIR"/
else
    echo "❌ Folder is empty or doesn't exist: $EXTRACTED_FOLDER"
fi

echo "===== Configure nexus run_as_user ====="
# Configure Nexus to run as the Nexus user
chown -R $NEXUS_USER:$NEXUS_USER $NEXUS_DIR
touch $NEXUS_DIR/bin/nexus.rc
sed -i 's/#run_as_user=""/run_as_user="nexus"/' $NEXUS_DIR/bin/nexus.rc

# configure nexus data directory
mkdir -p $DATA_DIR
chown -R $NEXUS_USER:$NEXUS_USER $DATA_DIR

echo "===== Configure nexus JVM ====="

VM_OPTIONS_FILE="$NEXUS_DIR/bin/nexus.vmoptions"

# Configure JVM options
sed -i 's/^-Xms.*/-Xms2G/' $VM_OPTIONS_FILE
sed -i 's/^-Xmx.*/-Xmx4G/' $VM_OPTIONS_FILE

# Ensure backup
sudo cp "${VM_OPTIONS_FILE}" "${VM_OPTIONS_FILE}.bak.$(date +%s)"

# Remove existing conflicting entries
sudo sed -i "/LogFile=/d" "${VM_OPTIONS_FILE}"
sudo sed -i "/karaf.data=/d" "${VM_OPTIONS_FILE}"
sudo sed -i "/karaf.log=/d" "${VM_OPTIONS_FILE}"
sudo sed -i "/java.io.tmpdir=/d" "${VM_OPTIONS_FILE}"

# Append new settings
cat <<EOF | sudo tee -a "${VM_OPTIONS_FILE}" >/dev/null
# Custom Nexus JVM settings
-XX:LogFile=${DATA_DIR}/log/jvm.log
-Dkaraf.data=${DATA_DIR}/data
-Dkaraf.log=${DATA_DIR}/log
-Djava.io.tmpdir=${DATA_DIR}/tmp
EOF

echo "===== Creating Systemd Service ====="
# Create a systemd service file for Nexus
cat << EOF > /etc/systemd/system/nexus.service
[Unit]
Description=Nexus Service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=$NEXUS_DIR/bin/nexus start
ExecStop=$NEXUS_DIR/bin/nexus stop
User=nexus
Restart=on-abort
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=nexus-%i

[Install]
WantedBy=multi-user.target
EOF

echo "===== Starting Nexus Service ====="
# Start and enable Nexus service
systemctl daemon-reload
systemctl start nexus
systemctl enable nexus