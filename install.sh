#!/usr/bin/bash

set -e
: "${LANG:=en-US}"
: "${EDITION:=stable}"


if [[ $(uname -m) == "aarch64" ]]; then
  ARCH="64-aarch64"
elif [[ $(uname -m) == "x86_64" ]]; then
  ARCH="64"
else
  echo "architecture \"$(uname -m)\" not support"
  exit 1
fi


if [ "$EDITION" == 'stable' ]; then
    EDITION_URL=''
    firefox_name="Firefox"
elif [ "$EDITION" == 'esr' ]; then
    EDITION_URL='esr-'
    firefox_name="Firefox Extended Support Release"
elif [ "$EDITION" == 'dev' ]; then
    EDITION_URL='devedition-'
    firefox_name="Firefox Developer Edition"
elif [ "$EDITION" == 'nightly' ]; then
    EDITION_URL='nightly-'
    firefox_name="Firefox Nightly"
elif [ "$EDITION" == 'beta' ]; then
    EDITION_URL='beta'
    firefox_name="Firefox Beta"
else
    echo "Edition: \"${EDITION}\" invalid"
    exit 1
fi

firefox_url="https://download.mozilla.org/?product=firefox-${EDITION_URL}latest-ssl&os=linux${ARCH}&lang=${LANG}"

#Install firefox
mkdir -p ~/.local/opt ~/.local/bin

curl --location "$firefox_url" --output /tmp/firefox-${EDITION}.tar.xz
tar --extract --verbose --preserve-permissions -f /tmp/firefox-${EDITION}.tar.xz
rm -f /tmp/firefox-${EDITION}.tar.xz

if [ -d "~/.local/opt/firefox-${EDITION}" ]; then
    rm -Rf "~/.local/opt/firefox-${EDITION}"
fi

mv firefox ~/.local/opt/firefox-${EDITION}

cat > ~/.local/bin/firefox-${EDITION} <<EXEC
#!/usr/bin/bash

if [ "\$1" == "--uninstall" ]; then
    exec ~/.local/opt/firefox-${EDITION}/uninstall.sh
else
    exec  ~/.local/opt/firefox-${EDITION}/firefox "\$@"
fi
EXEC
chmod +x ~/.local/bin/firefox-${EDITION}

#Icons
mkdir -p ~/.local/share/icons/hicolor/{16x16,32x32,48x48,64x64,128x128}/apps
ln -s ~/.local/opt/firefox-${EDITION}/browser/chrome/icons/default/default16.png ~/.local/share/icons/hicolor/16x16/apps/firefox-${EDITION}.png
ln -s ~/.local/opt/firefox-${EDITION}/browser/chrome/icons/default/default32.png ~/.local/share/icons/hicolor/32x32/apps/firefox-${EDITION}.png
ln -s ~/.local/opt/firefox-${EDITION}/browser/chrome/icons/default/default48.png ~/.local/share/icons/hicolor/48x48/apps/firefox-${EDITION}.png
ln -s ~/.local/opt/firefox-${EDITION}/browser/chrome/icons/default/default64.png ~/.local/share/icons/hicolor/64x64/apps/firefox-${EDITION}.png
ln -s ~/.local/opt/firefox-${EDITION}/browser/chrome/icons/default/default128.png ~/.local/share/icons/hicolor/128x128/apps/firefox-${EDITION}.png

# Create uninstall script
cat > ~/.local/opt/firefox-${EDITION}/uninstall.sh <<UNINSTALL
#!/usr/bin/bash
rm -Rf ${HOME}/.local/share/icons/hicolor/{16x16,32x32,48x48,64x64,128x128}/apps/firefox-${EDITION}.png
rm -f ${HOME}/.local/bin/firefox-${EDITION} 
rm -f ${HOME}/.local/share/applications/firefox-${EDITION}.desktop 
rm -Rf ${HOME}/.local/opt/firefox-${EDITION}

UNINSTALL
chmod +x ~/.local/opt/firefox-${EDITION}/uninstall.sh

# Create desktop launcher
cat > ~/.local/share/applications/firefox-${EDITION}.desktop <<DESKTOP_ENTRY
[Desktop Entry]
Name=${firefox_name}
GenericName=Web Browser
Exec=${HOME}/.local/bin/firefox-${EDITION} %u
Icon=firefox-${EDITION}
Terminal=false
Type=Application
MimeType=text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;text/mml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
Categories=Network;WebBrowser;
Keywords=web;browser;internet;
Actions=new-window;new-private-window;profile-manager;
StartupWMClass=${firefox_name}

[Desktop Action new-window]
Name=Open a New Window
Exec=${HOME}/.local/bin/firefox-${EDITION} %u

[Desktop Action new-private-window]
Name=Open a New Private Window
Exec=${HOME}/.local/bin/firefox-${EDITION} --private-window %u

[Desktop Action profile-manager]
Name=Open Profile Manager
Exec=${HOME}/.local/bin/firefox-${EDITION} -p %u

DESKTOP_ENTRY
