#!/bin/bash
set -e
VNC_PASS=${VNC_PASSWORD:-"12345678@Abc"}
mkdir -p "$HOME/.vnc"
echo "$VNC_PASS" | vncpasswd -f > "$HOME/.vnc/passwd"
chmod 600 "$HOME/.vnc/passwd"
cat > "$HOME/.vnc/xstartup" <<EOF
#!/bin/bash
xrdb \$HOME/.Xresources
export XKL_XMODMAP_DISABLE=1
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec dbus-run-session startxfce4
EOF
chmod +x "$HOME/.vnc/xstartup"


# Đặt quyền sở hữu thư mục và file về user ubuntu (UID/GID 1000)
chown -R 1000:1000 "$HOME/.vnc"
