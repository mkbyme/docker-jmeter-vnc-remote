#!/bin/bash
### every exit != 0 fails the script
set -e

# Source environment variables
[[ -f "$HOME/.bashrc" ]] && source $HOME/.bashrc

# Initialize Chrome settings
if [[ -f "/src/common/scripts/chrome-init.sh" ]]; then
    echo "------------------ initializing Chrome settings ------------------"
    bash /src/common/scripts/chrome-init.sh
fi

echo "------------------ startup of Xfce4 window manager ------------------"

### disable screensaver and power management
xset -dpms &
xset s noblank &
xset s off &

# Start XFCE with DBus session
dbus-run-session /usr/bin/startxfce4 --replace > $HOME/wm.log 2>&1 &
