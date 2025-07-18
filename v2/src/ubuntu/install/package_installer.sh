#!/usr/bin/env bash
set -e

SCRIPT_PATH=$(dirname $(realpath $0))

echo "Update package repositories"

apt-get update

# Install minimal dependencies first
echo "Installing minimal dependencies"
apt-get install -y --no-install-recommends \
    locales \
    dbus \
    dbus-x11 \
    software-properties-common \
    ca-certificates \
    curl \
    wget \
    apt-transport-https \
    gpg \
    libnss-wrapper

# Add universe repository
add-apt-repository -y universe

# Setup locales
echo "Setting up locales"
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Initialize DBus
echo "Initialize DBus"
mkdir -p /var/run/dbus
dbus-uuidgen > /var/lib/dbus/machine-id

# Install components in correct order
echo "Installing base system"
source $SCRIPT_PATH/01-base.sh

echo "Installing XFCE4 desktop"
source $SCRIPT_PATH/02-xfce.sh

echo "Installing VNC server"
source $SCRIPT_PATH/03-vnc.sh

echo "Installing noVNC HTML5 client"
source $SCRIPT_PATH/04-novnc.sh

echo "Installing web browsers"
source $SCRIPT_PATH/05-browsers.sh

echo "Installing java"
source $SCRIPT_PATH/06-java.sh

# Create startup directory and setup user mapping
echo "Setting up user environment"
mkdir -p /dockerstartup
cp /headless/install/user_mapping.sh /dockerstartup/
chmod +x /dockerstartup/*.sh

# Execute user mapping script to setup environment
echo "Running user mapping setup"
bash /dockerstartup/user_mapping.sh

echo "Final cleanup"
# Remove any automatically installed dependencies
apt-get autoremove -y

# Clean package cache and temp files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set final permissions
find /headless -type d -exec chmod 755 {} \;
chown -R 1000:1000 /headless
chmod 755 /var/run/dbus
