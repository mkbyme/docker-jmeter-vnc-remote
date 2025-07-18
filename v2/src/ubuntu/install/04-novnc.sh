#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install noVNC dependencies"
apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-numpy

echo "Setup noVNC - HTML5 based VNC viewer"
mkdir -p /headless/noVNC/utils/websockify
wget -qO- https://github.com/novnc/noVNC/archive/v1.6.0.tar.gz | tar xz --strip 1 -C /headless/noVNC
wget -qO- https://github.com/novnc/websockify/archive/v0.13.0.tar.gz | tar xz --strip 1 -C /headless/noVNC/utils/websockify

# Configure noVNC
chmod +x -v /headless/noVNC/utils/novnc_proxy
ln -s /headless/noVNC/vnc.html /headless/noVNC/index.html

# Set permissions
chmod -R 755 /headless/noVNC
chown -R 1000:1000 /headless/noVNC

# Generate self-signed certificates
mkdir -p /headless/noVNC/utils/certificates
cd /headless/noVNC/utils
openssl req -new -x509 -days 365 -nodes \
    -out certificates/self.pem -keyout certificates/self.pem \
    -subj "/C=US/ST=CA/L=Sunnyvale/O=noVNC/OU=noVNC/CN=www.noVNC.com"
