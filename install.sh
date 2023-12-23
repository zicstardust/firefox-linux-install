#!/usr/bin/env bash

mkdir -p ~/.local/opt ~/.local/bin
cd /tmp

curl --location "https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=linux64&lang=en-US" | tar --extract --verbose --preserve-permissions --bzip2

mv firefox ~/.local/opt/firefox-dev
ln -s ~/.local/opt/firefox/firefox-dev ~/.local/bin/firefox-dev

# Create desktop launcher
cat > ~/.local/share/applications/firefox-dev.desktop <<DESKTOP_ENTRY
[Desktop Entry]
Name=Firefox Developer Edition
GenericName=Web Browser
Exec=${HOME}/.local/bin/firefox-dev %u
Icon=${HOME}/.local/opt/firefox-dev/browser/chrome/icons/default/default128.png
Terminal=false
Type=Application
MimeType=text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;text/mml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
Categories=Network;WebBrowser;
Keywords=web;browser;internet;
Actions=new-window;new-private-window;profile-manager;
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
DESKTOP_ENTRY