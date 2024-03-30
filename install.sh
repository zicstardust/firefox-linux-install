#!/usr/bin/bash

#check version
if [ $firefox_edition="esr" ];then
    firefox_url="https://download.mozilla.org/?product=firefox-esr-latest-ssl&os=linux64&lang=en-US"
    firefox_name="Firefox Extended Support Release"
elif [ $firefox_edition="dev" ];then
    firefox_url="https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=linux64&lang=en-US"
    firefox_name="Firefox Developer Edition"
elif [ $firefox_edition="nightly" ];then
    firefox_url="https://download.mozilla.org/?product=firefox-nightly-latest-ssl&os=linux64&lang=en-US"
    firefox_name="Firefox Nightly"
elif [ $firefox_edition="beta" ];then
    firefox_url="https://download.mozilla.org/?product=firefox-beta-latest-ssl&os=linux64&lang=en-US"
    firefox_name="Firefox Beta"
elif [ $firefox_edition="stable" ];then
    firefox_url="https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US"
    firefox_name="Firefox"
else
    echo "Invalid edition"
    exit 2
fi

#Install firefox
mkdir -p ~/.local/opt ~/.local/bin
cd /tmp

curl --location "$firefox_url" | tar --extract --verbose --preserve-permissions --bzip2

mv firefox ~/.local/opt/firefox-${firefox_edition}
ln -s ~/.local/opt/firefox-${firefox_edition}/firefox ~/.local/bin/firefox-${firefox_edition}

#Icons
mkdir -p ~/.local/share/icons/hicolor/{16x16,32x32,48x48,64x64,128x128}
ln -s ~/.local/opt/firefox-${firefox_edition}/browser/chrome/icons/default/default16.png ~/.local/share/icons/hicolor/16x16/apps/firefox-${firefox_edition}.png
ln -s ~/.local/opt/firefox-${firefox_edition}/browser/chrome/icons/default/default32.png ~/.local/share/icons/hicolor/32x32/apps/firefox-${firefox_edition}.png
ln -s ~/.local/opt/firefox-${firefox_edition}/browser/chrome/icons/default/default48.png ~/.local/share/icons/hicolor/48x48/apps/firefox-${firefox_edition}.png
ln -s ~/.local/opt/firefox-${firefox_edition}/browser/chrome/icons/default/default64.png ~/.local/share/icons/hicolor/64x64/apps/firefox-${firefox_edition}.png
ln -s ~/.local/opt/firefox-${firefox_edition}/browser/chrome/icons/default/default128.png ~/.local/share/icons/hicolor/128x128/apps/firefox-${firefox_edition}.png

# Create uninstall script
cat > ~/.local/opt/firefox-${firefox_edition}/uninstall.sh <<UNINSTALL
#!/bin/bash
rm -Rf ${HOME}/.local/share/icons/hicolor/{16x16,32x32,48x48,64x64,128x128}/apps/firefox-${firefox_edition}.png
rm -f ${HOME}/.local/bin/firefox-${firefox_edition} 
rm -f ${HOME}/.local/share/applications/firefox-${firefox_edition}.desktop 
rm -Rf ${HOME}/.local/opt/firefox-${firefox_edition}

UNINSTALL
chmod +x ~/.local/opt/firefox-${firefox_edition}/uninstall.sh

# Create desktop launcher
cat > ~/.local/share/applications/firefox-${firefox_edition}.desktop <<DESKTOP_ENTRY
[Desktop Entry]
Name=${firefox_name}
GenericName=Web Browser
Exec=${HOME}/.local/bin/firefox-${firefox_edition} %u
Icon=firefox-${firefox_edition}
Terminal=false
Type=Application
MimeType=text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;text/mml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
Categories=Network;WebBrowser;
Keywords=web;browser;internet;
Actions=new-window;new-private-window;profile-manager;uninstall;
StartupWMClass=${firefox_name}

[Desktop Action new-window]
Name=Open a New Window
Exec=${HOME}/.local/bin/firefox-${firefox_edition} %u

[Desktop Action new-private-window]
Name=Open a New Private Window
Exec=${HOME}/.local/bin/firefox-${firefox_edition} --private-window %u

[Desktop Action profile-manager]
Name=Open Profile Manager
Exec=${HOME}/.local/bin/firefox-${firefox_edition} -p %u

[Desktop Action uninstall]
Name=Uninstall
Exec=${HOME}/.local/opt/firefox-${firefox_edition}/uninstall.sh
DESKTOP_ENTRY
