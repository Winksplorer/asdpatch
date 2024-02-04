#!/bin/bash

echo "Apple SuperDrive Patcher (asdpatch) v1.0"

if [ $(whoami) != "root" ]; then
  echo "You must be root to patch the superdrive"
  exit 1
fi

echo "Installing sg3-utils..."
# Check if sg3 is already installed
if [ -x "$(command -v sg_raw)" ]; then
  echo "sg3-utils is already installed"
else
    echo
    echo "Select your package manager:"
    echo "1) apt-get"
    echo "2) apk"
    echo "3) pacman"
    echo "4) yum"
    echo "5) dnf"

    read pm

    case $pm in
    1)
        apt-get install sg3-utils
        ;;
    2)
        apk add sg3-utils
        ;;
    3)
        pacman -S sg3-utils
        ;;
    4)
        yum install sg3-utils
        ;;
    5)
        dnf install sg3-utils
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
    esac
fi

echo "Patching system..."

cat <<- EOF | tee  /etc/udev/rules.d/90-mac-superdrive.rules > /dev/null
# Initialise Apple SuperDrive
ACTION=="add", ATTRS{idProduct}=="1500", ATTRS{idVendor}=="05ac", DRIVERS=="usb", RUN+="/usr/bin/sg_raw %r/sr%n EA 00 00 00 00 00 01"
EOF

echo "Superdrive patched. Reboot the system for patch to take effect."
notify-send -t 5000 -u normal "Superdrive patched. Reboot the system for patch to take effect." 2>/dev/null