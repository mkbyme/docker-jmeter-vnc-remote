#!/bin/bash
set -e
cd "$HOME"
# Thêm key và repo của Google Chrome chính thức
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
apt-get update
# Cài Google Chrome stable 
apt-get install -y google-chrome-stable
# Cài các thư viện hỗ trợ cho Firefox tar.xz
apt-get install -y libdbus-glib-1-2 libxt6 libx11-xcb1 libxdamage1 libxcomposite1 libxrandr2 libgtk-3-0 xz-utils
# Tải và giải nén Firefox
wget "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US" -O firefox.tar.xz
mkdir -p /opt/firefox
tar -xJf firefox.tar.xz -C /opt/firefox --strip-components=1
rm firefox.tar.xz
ln -sf /opt/firefox/firefox /usr/bin/firefox
# Tạo thư mục Desktop nếu chưa có
mkdir -p "$HOME/Desktop"
# Tạo shortcut .desktop cho Chrome
cat > "$HOME/Desktop/google-chrome.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Google Chrome
Exec=/usr/local/bin/google-chrome-stable
Icon=google-chrome
Terminal=false
Categories=Network;WebBrowser;
StartupNotify=true
Trusted=true
EOF
# Tạo shortcut .desktop cho Firefox
cat > "$HOME/Desktop/firefox.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Firefox
Exec=/opt/firefox/firefox %u
Icon=/opt/firefox/browser/chrome/icons/default/default128.png
Path=/opt/firefox
Terminal=false
Categories=Network;WebBrowser;
StartupNotify=true
Trusted=true
EOF

# cấu hình shortcut để chạy được và không bị hỏi prompt
# Tạo thư mục ứng dụng nếu chưa có
APPLICATIONS_DIR="/usr/share/applications"
export APPLICATIONS_DIR

chmod a+x "$HOME/Desktop/google-chrome.desktop" "$HOME/Desktop/firefox.desktop" || true
mkdir -p "$HOME/share/applications"
# Copy file .desktop bỏ dấu ngoặc kép để mở rộng đúng
if ls $HOME/Desktop/*.desktop 1> /dev/null 2>&1; then
    # Tạo thư mục ứng dụng cho người dùng để chạy mà không bị hỏi prompt chạy từ đường dẫn không tin cậy
    cp $HOME/Desktop/*.desktop -R "$APPLICATIONS_DIR"
fi

chown -R 1000:1000 "$HOME/Desktop" "/opt/firefox/" || true

# Xóa file desktop Chrome nếu có
CHROME_DESKTOP="$APPLICATIONS_DIR/com.google.Chrome.desktop"
if [ -f "$CHROME_DESKTOP" ]; then
    echo "Removing Chrome desktop entry: $CHROME_DESKTOP"
    rm -f "$CHROME_DESKTOP"
else
    echo "Chrome desktop entry not found: $CHROME_DESKTOP"
fi

# Thay thế Exec cho xfce4-web-browser.desktop nếu tồn tại (trình duyệt mặc định)
FILE="/usr/share/applications/xfce4-web-browser.desktop"
if [ -f "$FILE" ]; then
    sed -i 's|^Exec=.*|Exec=/usr/local/bin/google-chrome-stable|' "$FILE"
else
    echo "File $FILE không tồn tại, bỏ qua thay thế Exec."
fi
