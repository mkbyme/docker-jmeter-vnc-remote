#!/bin/bash
set -e
export DISPLAY=:1

#!/bin/bash
# --- every exit != 0 fails the script
set -e

echo "---------------------------------------------------------"
echo "--- PREPARE MOUNT CONFIG (Plugins, Certs, Config      ---"
echo "---------------------------------------------------------"
if [ -d /plugins ] && [ -n "$(ls -A /plugins)" ]
then
    echo "Copied plugin from plugins to $JMETER_HOME/lib/ext"
    for plugin in /plugins/*.jar; do
        cp $plugin $JMETER_HOME/lib/ext
    done;
else
    echo "No plugin or empty at folder '/plugins' to install"
fi

# Install misa sefl-cert.crt available on /certs volume
if [ -d /certs ] && [ -n "$(ls -A /certs)" ]
then
    echo "Trusted cert *.crt from /certs"
    mkdir /usr/local/share/ca-certificates/ -p
    cp /certs/*.crt /usr/local/share/ca-certificates/
    update-ca-certificates
else
    echo "No cert or folder empty at folder '/certs' to trust"
fi

# Copy jmeter user.properties config  available on /home/jmeterconfig volume
if [ -d /home/jmeterconfig ] && [ -n "$(ls -A /home/jmeterconfig)" ]
then
    echo "Copied jmeter config from /home/jmeterconfig to $JMETER_BIN"
    cp /home/jmeterconfig/*.properties $JMETER_BIN
else
    echo "No config or empty at folder '/home/jmeterconfig' to config jmeter at $JMETER_BIN"
fi

# Copy guideline to /headless/Desktop  available on /home/jmeterguide volume
DESKTOP_PATH="$HOME/Desktop"
if [ -d /home/jmeterguide ] && [ -n "$(ls -A /home/jmeterguide)" ]
then
    echo "Copied jmeter guide from /home/jmeterguide to $DESKTOP_PATH"
    cp /home/jmeterguide/* $DESKTOP_PATH
else
    echo "No guide or empty at folder '/home/jmeterguide' to config jmeter at $DESKTOP_PATH"
fi

echo "---------------------------------------------------------"
echo "--- PREPARE MOUNT CONFIG (Plugins, Certs, Config) END ---"
echo "---------------------------------------------------------"

# Đảm bảo thư mục .vnc có quyền phù hợp
chown -R $(id -u):$(id -g) $HOME/.vnc || true
chmod 700 $HOME/.vnc || true
# Tạo file .Xauthority nếu chưa có và tạo khóa truy cập
touch "$HOME/.Xauthority"
xauth generate $DISPLAY . trusted || true
# Đặt quyền sở hữu cho file .Xauthority
chown $(id -u):$(id -g) $HOME/.Xauthority

# Kill nếu có phiên VNC server cũ đang chạy trên :1
vncserver -kill :1 > /dev/null 2>&1 || true
# Khởi động lại VNC server mới với độ phân giải và độ sâu màu phù hợp
vncserver :1 -geometry 1280x800 -depth 24
# Cho phép mọi kết nối tới X server (dùng trong container, chú ý an toàn)
xhost +

# Khởi động noVNC proxy để phục vụ VNC qua trình duyệt web ở cổng 6901 với SSL cert
$HOME/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 6901
# Giữ container chạy và theo dõi log của VNC server để debug
tail -f $HOME/.vnc/*.log