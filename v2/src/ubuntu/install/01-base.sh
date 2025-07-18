#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install base system tools and dependencies"
apt-get install -y --no-install-recommends \
    lsb-release \
    net-tools \
    openssl \
    perl \
    procps \
    psmisc \
    shared-mime-info \
    sudo \
    tzdata \
    mousepad \
    gvfs \
    gvfs-backends \
    xauth

# Configure sudo - check if ubuntu user exists first
if ! getent passwd ubuntu > /dev/null; then
    useradd -m -s /bin/bash ubuntu
fi
usermod -aG sudo ubuntu
echo "ubuntu ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ubuntu
chmod 0440 /etc/sudoers.d/ubuntu

# Ensure .Xauthority exists for ubuntu user
sudo -u ubuntu touch /home/ubuntu/.Xauthority
