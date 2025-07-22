#!/bin/bash
set -e
apt-get update
# 1. Các công cụ cơ bản & hỗ trợ cài đặt, tải file, xử lý ssl, python3-pip,...
apt-get install -y --no-install-recommends \
    sudo wget curl gnupg2 python3-pip openssl unzip xz-utils git \
    iproute2 net-tools tzdata

# Thiết lập múi giờ theo biến môi trường TZ
if [ -L /etc/localtime ]; then
    unlink /etc/localtime
fi
# Thiết lập múi giờ theo biến môi trường TZ (nếu có), mặc định sẽ được Dockerfile truyền vào
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
echo "$TZ" > /etc/timezone

# 2. Môi trường Desktop và VNC server (TigerVNC)
apt-get install -y --no-install-recommends \
    xfce4 xfce4-terminal tigervnc-standalone-server tigervnc-common tigervnc-tools
# 3. Các thành phần hỗ trợ D-Bus, X11 và xác thực cùng gvfs-backends cho thùng rác
apt-get install -y --no-install-recommends \
    dbus-x11 dbus-user-session x11-xserver-utils xauth gvfs-backends
# 4. Thư viện đồ họa và giao diện (fonts, GTK, lib xử lý đồ họa)
apt-get install -y --no-install-recommends \
    fonts-liberation libnss3 libxss1 libatk-bridge2.0-0 libgtk-3-0 libx11-xcb1 \
    libxcomposite1 libxdamage1 libxrandr2 libatk1.0-0 libgbm1 libpango-1.0-0 \
    libpangocairo-1.0-0 libxcb1 libdrm2 libxxf86vm1 libxfixes3 libxrender1 \
    xfonts-base xfonts-75dpi xfonts-100dpi xfonts-encodings
# 5. Trình soạn thảo, Java 17
apt-get install -y --no-install-recommends \
    vim mousepad openjdk-17-jdk
# 6. Thêm user ubuntu vào nhóm sudo nếu chưa có
if id -nG ubuntu | grep -qw sudo; then
    echo "User ubuntu đã thuộc nhóm sudo."
else
    usermod -aG sudo ubuntu
    echo "Đã thêm user ubuntu vào nhóm sudo."
fi
# 7. Cho phép user ubuntu dùng sudo không cần mật khẩu nếu chưa có file thiết lập
if [ ! -f /etc/sudoers.d/90_ubuntu_nopasswd ]; then
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90_ubuntu_nopasswd
    chmod 440 /etc/sudoers.d/90_ubuntu_nopasswd
    echo "Đã tạo file sudoers cho phép ubuntu dùng sudo không cần mật khẩu."
else
    echo "File sudoers không mật khẩu cho ubuntu đã tồn tại."
fi
apt-get clean
rm -rf /var/lib/apt/lists/*
