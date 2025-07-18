#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install browser dependencies"
apt-get install -y --no-install-recommends \
    bzip2 \
    fonts-liberation \
    xdg-utils \
    libgtk-3-0 \
    libdbus-glib-1-2

echo "Install Brave Browser"
curl -fsS https://dl.brave.com/install.sh | sh
CHROMIUM_PATH="/usr/bin/brave-browser"
echo "Brave Browser installed."

echo "Install Firefox ESR"
mkdir -p /opt/firefox
wget -O firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-esr-latest-ssl&os=linux64&lang=en-US"
tar xjf firefox.tar.bz2 -C /opt/
rm firefox.tar.bz2
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


# Brave Browser desktop entry
cat > /headless/Desktop/brave.desktop << EOF
[Desktop Entry]
Version=1.0
Name=Brave Web Browser
Name[vi]=Trình duyệt web Brave
Comment=Browse the Internet with Brave
Comment[vi]=Để duyệt các trang web với Brave
GenericName=Web Browser
GenericName[vi]=Trình duyệt Web
Keywords=Internet;WWW;Browser;Web;Explorer;Brave
Keywords[vi]=Internet;WWW;Browser;Web;Explorer;Trình duyệt;Trang web;Brave
Exec=$CHROMIUM_PATH --no-sandbox --disable-gpu --user-data-dir --window-size=1280,1024 --window-position=0,0 --disable-features=UseDbus %U
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=brave-browser
Categories=GNOME;GTK;Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;video/webm;application/pdf;
StartupNotify=true
X-KDE-StartupNotify=true
Trusted=true
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
