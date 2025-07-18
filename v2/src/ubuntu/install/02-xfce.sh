#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install XFCE4 UI components"
apt-get install -y --no-install-recommends \
    xorg \
    xserver-xorg \
    dbus-x11 \
    x11-xserver-utils \
    x11-utils \
    xauth \
    xinit \
    xfce4 \
    xfce4-panel \
    xfce4-session \
    xfce4-settings \
    xfce4-terminal \
    xfdesktop4 \
    xfwm4 \
    xfce4-appfinder \
    thunar \
    tumbler \
    xdg-utils

echo "Install fonts"
apt-get install -y --no-install-recommends \
    fonts-dejavu \
    fonts-liberation \
    fonts-ubuntu \
    xfonts-base \
    xfonts-75dpi \
    xfonts-100dpi \
    xfonts-scalable

echo "Install themes"
apt-get install -y --no-install-recommends \
    gtk2-engines-pixbuf \
    adwaita-icon-theme \
    hicolor-icon-theme \
    gnome-themes-extra \
    arc-theme
