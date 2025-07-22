#!/usr/bin/env bash
set -e
echo "Setup noVNC"
NO_VNC_DIR="$HOME/noVNC"
WEBSOCKIFY_DIR="$NO_VNC_DIR/utils/websockify"
# Xóa thư mục cũ nếu có
sudo -u "$USER" rm -rf "$NO_VNC_DIR"
sudo -u "$USER" mkdir -p "$WEBSOCKIFY_DIR"
# Tải noVNC và giải nén dưới user hiện tại
sudo -u "$USER" wget -qO- https://github.com/novnc/noVNC/archive/v1.6.0.tar.gz | sudo -u "$USER" tar xz --strip 1 -C "$NO_VNC_DIR"
sudo -u "$USER" wget -qO- https://github.com/novnc/websockify/archive/v0.13.0.tar.gz | sudo -u "$USER" tar xz --strip 1 -C "$WEBSOCKIFY_DIR"
# Đặt quyền thực thi cho novnc_proxy, tạo liên kết index.html
sudo -u "$USER" chmod +x "$NO_VNC_DIR/utils/novnc_proxy"
sudo -u "$USER" ln -sf "$NO_VNC_DIR/vnc.html" "$NO_VNC_DIR/index.html"
# Set quyền sở hữu và phân quyền
chown -R $(id -u $USER):$(id -g $USER) "$NO_VNC_DIR"
chmod -R 755 "$NO_VNC_DIR"
# Tạo thư mục certificates và tạo chứng chỉ tự ký dưới quyền user
sudo -u "$USER" mkdir -p "$NO_VNC_DIR/utils/certificates"
cd "$NO_VNC_DIR/utils"
sudo -u "$USER" openssl req -new -x509 -days 365 -nodes \
    -out certificates/self.pem -keyout certificates/self.pem \
    -subj "/C=US/ST=CA/L=Sunnyvale/O=noVNC/OU=noVNC/CN=www.noVNC.com"
