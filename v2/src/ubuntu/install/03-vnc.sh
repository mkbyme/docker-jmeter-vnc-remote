#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install TigerVNC server"
apt-get install -y --no-install-recommends \
    tigervnc-standalone-server \
    tigervnc-common \
    tigervnc-tools \
    tigervnc-xorg-extension \
    x11-apps \
    at-spi2-core \
    dconf-gsettings-backend \
    glib-networking

# Create required directories for VNC
mkdir -p /headless/.vnc
cat > /headless/.vnc/xstartup << EOF
#!/bin/bash
export XKL_XMODMAP_DISABLE=1
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec dbus-run-session startxfce4
EOF

# Set permissions
chmod 755 /headless/.vnc
chmod +x /headless/.vnc/xstartup
chown -R 1000:1000 /headless/.vnc
