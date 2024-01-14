#!/usr/bin/env bash

mkdir -p ~/.local/opt ~/.local/bin
cd /tmp

curl --location "https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=linux64&lang=en-US" | tar --extract --verbose --preserve-permissions --bzip2

mv firefox ~/.local/opt/firefox-dev
ln -s ~/.local/opt/firefox-dev/firefox ~/.local/bin/firefox-dev

#Icons
mkdir -p ~/.local/share/icons/hicolor/{16x16,32x32,48x48,64x64,128x128}
ln -s ~/.local/opt/firefox-dev/browser/chrome/icons/default/default16.png ~/.local/share/icons/hicolor/16x16/apps/firefox-dev.png
ln -s ~/.local/opt/firefox-dev/browser/chrome/icons/default/default32.png ~/.local/share/icons/hicolor/32x32/apps/firefox-dev.png
ln -s ~/.local/opt/firefox-dev/browser/chrome/icons/default/default48.png ~/.local/share/icons/hicolor/48x48/apps/firefox-dev.png
ln -s ~/.local/opt/firefox-dev/browser/chrome/icons/default/default64.png ~/.local/share/icons/hicolor/64x64/apps/firefox-dev.png
ln -s ~/.local/opt/firefox-dev/browser/chrome/icons/default/default128.png ~/.local/share/icons/hicolor/128x128/apps/firefox-dev.png

# Create uninstall script
cat > ~/.local/opt/firefox-dev/uninstall.sh <<UNINSTALL
#!/bin/bash
rm -Rf ${HOME}/.local/share/icons/hicolor/{16x16,32x32,48x48,64x64,128x128}/apps/firefox-dev.png
rm -f ${HOME}/.local/bin/firefox-dev 
rm -f ${HOME}/.local/share/applications/firefox-dev.desktop 
rm -Rf ${HOME}/.local/opt/firefox-dev

UNINSTALL
chmod +x ~/.local/opt/firefox-dev/uninstall.sh

# Create desktop launcher
cat > ~/.local/share/applications/firefox-dev.desktop <<DESKTOP_ENTRY
[Desktop Entry]
Name=Firefox Developer Edition
GenericName=Web Browser
Exec=${HOME}/.local/bin/firefox-dev %u
Icon=firefox-dev
Terminal=false
Type=Application
MimeType=text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;text/mml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
Categories=Network;WebBrowser;
Keywords=web;browser;internet;
Actions=new-window;new-private-window;profile-manager;uninstall;
StartupWMClass=Firefox Developer Edition

[Desktop Action new-window]
Name=Open a New Window
Exec=${HOME}/.local/bin/firefox-dev %u

[Desktop Action new-private-window]
Name=Open a New Private Window
Exec=${HOME}/.local/bin/firefox-dev --private-window %u

[Desktop Action profile-manager]
Name=Open Profile Manager
Exec=${HOME}/.local/bin/firefox-dev -p %u

[Desktop Action uninstall]
Name=Uninstall
Exec=${HOME}/.local/opt/firefox-dev/uninstall.sh
DESKTOP_ENTRY
