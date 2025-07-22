#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install browser dependencies"
apt-get install -y --no-install-recommends \
    bzip2 \
    fonts-liberation \
    xdg-utils \
    libgtk-3-0 \
    libdbus-glib-1-2 \
    wget \
    gnupg \
    ca-certificates \
    libnss3 \
    lsb-release \
    libx11-xcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxrandr2 \
    libasound2t64 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libgbm1 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libxcb1 \
    libxss1 \
    libdrm2 \
    fonts-noto-color-emoji \
    xz-utils

echo "Install Google Chrome"
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
apt-get update
apt-get install -y google-chrome-stable
echo "Google Chrome installed."

echo "Install Firefox (latest official release)"
mkdir -p /opt/firefox
wget -O firefox.tar.xz "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US"
tar xJf firefox.tar.xz -C /opt/
rm firefox.tar.xz
ln -s /opt/firefox/firefox /usr/local/bin/firefox

# Setup browser desktop entries
mkdir -p /headless/Desktop

# Firefox desktop entry
cat > /headless/Desktop/firefox.desktop << EOF
[Desktop Entry]
Version=1.0
Name=Firefox Web Browser
Name[vi]=Trình duyệt web Firefox
Comment=Browse the World Wide Web
Comment[vi]=Để duyệt các trang web
GenericName=Web Browser
GenericName[vi]=Trình duyệt Web
Keywords=Internet;WWW;Browser;Web;Explorer
Keywords[vi]=Internet;WWW;Browser;Web;Explorer;Trình duyệt;Trang web
Exec=/usr/local/bin/firefox %u
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=/opt/firefox/browser/chrome/icons/default/default128.png
Categories=GNOME;GTK;Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
StartupNotify=true
X-KDE-StartupNotify=true
Trusted=true
EOF

# Google Chrome desktop entry
cat > /headless/Desktop/chrome.desktop << EOF
[Desktop Entry]
Version=1.0
Name=Google Chrome
Comment=Access the Internet
Exec=/usr/local/bin/google-chrome-stable
Terminal=false
Type=Application
Icon=google-chrome
Categories=Network;WebBrowser;
StartupNotify=true
EOF

chmod +x /headless/Desktop/*.desktop
chmod +x /usr/local/bin/firefox
chown -R 1000:1000 /opt/firefox /headless/Desktop

# Setup XFCE menu integration
mkdir -p /headless/.config/menus/applications-merged
mkdir -p /headless/.local/share/applications

# Copy desktop files to applications directory
cp /headless/Desktop/*.desktop /headless/.local/share/applications/

# Set permissions for menu files
chown -R 1000:1000 /headless/.config /headless/.local
