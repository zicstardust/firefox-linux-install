#!/usr/bin/bash

set -e
: "${LANG:=en-US}"
: "${EDITION:=stable}"
: "${SCOPE:=user}"

if [ "$SCOPE" == "user" ]; then
    BASE_DIR="${HOME}/.local"
    LOCAL_DIR=$BASE_DIR
elif [ "$SCOPE" == "computer" ]; then
    if [ "$(whoami)" != "root" ]; then
        echo "Scope Computer need run with root"
        exit 1
    fi
    BASE_DIR=""
    LOCAL_DIR="/usr/local"
else
    echo "SCOPE: \"${SCOPE}\" invalid"
    exit 1
fi

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
mkdir -p ${BASE_DIR}/opt ${LOCAL_DIR}/bin

curl --location "$firefox_url" --output /tmp/firefox-${EDITION}.tar.xz
tar --extract --verbose --preserve-permissions -f /tmp/firefox-${EDITION}.tar.xz
rm -f /tmp/firefox-${EDITION}.tar.xz

if [ -d "${BASE_DIR}/opt/firefox-${EDITION}" ]; then
    rm -Rf "${BASE_DIR}/opt/firefox-${EDITION}"
fi

mv firefox ${BASE_DIR}/opt/firefox-${EDITION}

cat > ${LOCAL_DIR}/bin/firefox-${EDITION} <<EXEC
#!/usr/bin/bash

if [ "\$1" == "--uninstall" ]; then
    exec ${BASE_DIR}/opt/firefox-${EDITION}/uninstall.sh
else
    exec ${BASE_DIR}/opt/firefox-${EDITION}/firefox "\$@"
fi
EXEC
chmod +x ${LOCAL_DIR}/bin/firefox-${EDITION}

#Icons
mkdir -p ${LOCAL_DIR}/share/icons/hicolor/{16x16,32x32,48x48,64x64,128x128}/apps
ln -s ${BASE_DIR}/opt/firefox-${EDITION}/browser/chrome/icons/default/default16.png ${LOCAL_DIR}/share/icons/hicolor/16x16/apps/firefox-${EDITION}.png
ln -s ${BASE_DIR}/opt/firefox-${EDITION}/browser/chrome/icons/default/default32.png ${LOCAL_DIR}/share/icons/hicolor/32x32/apps/firefox-${EDITION}.png
ln -s ${BASE_DIR}/opt/firefox-${EDITION}/browser/chrome/icons/default/default48.png ${LOCAL_DIR}/share/icons/hicolor/48x48/apps/firefox-${EDITION}.png
ln -s ${BASE_DIR}/opt/firefox-${EDITION}/browser/chrome/icons/default/default64.png ${LOCAL_DIR}/share/icons/hicolor/64x64/apps/firefox-${EDITION}.png
ln -s ${BASE_DIR}/opt/firefox-${EDITION}/browser/chrome/icons/default/default128.png ${LOCAL_DIR}/share/icons/hicolor/128x128/apps/firefox-${EDITION}.png

# Create uninstall script
cat > ${BASE_DIR}/opt/firefox-${EDITION}/uninstall.sh <<UNINSTALL
#!/usr/bin/bash

SCRIPT_DIR=\$( cd -- "\$( dirname -- "\${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "\$SCRIPT_DIR" == "/opt/firefox-${EDITION}" ] && [ "\$(whoami)" != "root" ]; then
    sudo \$0
else
    rm -Rf ${LOCAL_DIR}/share/icons/hicolor/{16x16,32x32,48x48,64x64,128x128}/apps/firefox-${EDITION}.png
    rm -f ${LOCAL_DIR}/bin/firefox-${EDITION} 
    rm -f ${LOCAL_DIR}/share/applications/firefox-${EDITION}.desktop 
    rm -Rf ${BASE_DIR}/opt/firefox-${EDITION}
fi
UNINSTALL
chmod +x ${BASE_DIR}/opt/firefox-${EDITION}/uninstall.sh

# Create desktop launcher
mkdir -p ${LOCAL_DIR}/share/applications
cat > ${LOCAL_DIR}/share/applications/firefox-${EDITION}.desktop <<DESKTOP_ENTRY
[Desktop Entry]
Name=${firefox_name}
GenericName=Web Browser
Exec=${LOCAL_DIR}/bin/firefox-${EDITION} %u
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
Exec=${LOCAL_DIR}/bin/firefox-${EDITION} %u

[Desktop Action new-private-window]
Name=Open a New Private Window
Exec=${LOCAL_DIR}/bin/firefox-${EDITION} --private-window %u

[Desktop Action profile-manager]
Name=Open Profile Manager
Exec=${LOCAL_DIR}/bin/firefox-${EDITION} -p %u

DESKTOP_ENTRY
