#! /bin/sh

set -eu

# https://wiki.alpinelinux.org/wiki/NetworkManager
echo "....Creating logfile"
export LOGFILE=$HOME/Logfiles/networkmanager.log
echo "" > $LOGFILE

echo "....Adding packages"
doas apk add -vv \
    networkmanager \
    networkmanager-cli \
    networkmanager-doc \
    networkmanager-wifi \
    >> $LOGFILE 2>&1

echo "....Adding $USER to the plugdev group"
doas adduser $USER plugdev

echo "....Updating /etc/NetworkManager/NetworkManager.conf"
doas mkdir -p /etc/NetworkManager/
doas cat NetworkManager.conf >> /etc/NetworkManager/NetworkManager.conf

echo ""
echo "....Enabling/starting services"
doas rc-update add networkmanager default
doas rc-update del networking boot
doas rc-update del wpa_supplicant boot

echo "....Updating plocate database"
doas updatedb

echo "....Reboot to switch to NetworkManager"

echo "....Finished"
echo ""
