#!/usr/bin/env bash
set -e

echo "Install TigerVNC server"
apt install tightvncserver -y
apt install xfonts-75dpi xfonts-100dpi xfonts-scalable -y
# mv $HOME/.vnc/xstartup ~/.vnc/xstartup.bak
mkdir -p $HOME/.vnc/
cat > $HOME/.vnc/xstartup <<EOF 
#!/bin/bash
export XKL_XMODMAP_DISABLE=1
touch $HOME/.Xresources
xrdb $HOME/.Xresources
exec ck-launch-session startxfce4
#startxfce4 &
EOF
chmod +x $HOME/.vnc/xstartup
# apt install tigervnc-standalone-server tigervnc-xorg-extension tigervnc-viewer xfonts-75dpi xfonts-scalable -y
# wget -qO- https://udomain.dl.sourceforge.net/project/tigervnc/stable/1.12.0/tigervnc-1.12.0.x86_64.tar.gz | tar xz --strip 1 -C /
# wget -qO- https://jaist.dl.sourceforge.net/project/tigervnc/stable/1.8.0/tigervnc-1.8.0.x86_64.tar.gz | tar xz --strip 1 -C /

