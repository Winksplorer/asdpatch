#!/bin/bash

patch_err() {
    echo "PATCH FAILED"
    if [ $1 -eq 0 ]; then
        echo "CODE 0: You must be root to patch the superdrive"
        echo "You can use -nr flag to attempt to run the script without root privileges, but it will likely fail to patch the superdrive."
    elif [ $1 -eq 1 ]; then
        echo "CODE 1: No package manager found. Please install sg3-utils manually."
        echo "You can use -di flag to skip installation of sg3-utils, instead you can install it manually before running asdpatch."
    fi
}

echo "Apple SuperDrive Patcher (asdpatch) v1.0"

# Check for flags
if [ "$1" == "-nr" ]; then
  echo "Running without root privileges..."
elif [ "$1" == "-di" ]; then
  echo "Skipping installation of sg3-utils..."
fi

# bash is a programming language that doesn't make me go insane, totally
if [ "$1" != "-nr" ]; then
    if [ $(whoami) != "root" ]; then
    echo "You must be root to patch the superdrive"
    patch_err 0
    fi
fi

# Check if system is already patched
if [ -f /etc/udev/rules.d/90-mac-superdrive.rules ]; then
  echo "Superdrive was already patched"
  exit 0
fi

echo "Installing sg3-utils..."
if [ "$1" != "-di" ]; then
    # Check if sg3 is already installed
    if [ -x "$(command -v sg_raw)" ]; then
    echo "sg3-utils is already installed"
    else
        # Choose which package manager to use, by using command -v to check if the package manager is installed
        if [ -x "$(command -v apt)" ]; then
            apt install sg3-utils -y
        elif [ -x "$(command -v dnf)" ]; then
            dnf install sg3-utils -y
        elif [ -x "$(command -v yum)" ]; then
            yum install sg3-utils -y
        elif [ -x "$(command -v pacman)" ]; then
            pacman -S sg3_utils --noconfirm
        elif [ -x "$(command -v apk)" ]; then
            apk add sg3-utils
        else
            echo "No package manager found. Please install sg3-utils manually."
            patch_err 1
        fi
    fi
fi

echo "Patching system..."

cat <<- EOF | tee  /etc/udev/rules.d/90-mac-superdrive.rules > /dev/null
# Initialise Apple SuperDrive
ACTION=="add", ATTRS{idProduct}=="1500", ATTRS{idVendor}=="05ac", DRIVERS=="usb", RUN+="/usr/bin/sg_raw %r/sr%n EA 00 00 00 00 00 01"
EOF

echo "Superdrive patched. Reboot the system for patch to take effect."
notify-send -t 5000 -u normal "Superdrive patched. Reboot the system for patch to take effect." 2>/dev/null