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
    networkmanager-tui \
    networkmanager-wifi \
    >> $LOGFILE 2>&1

echo "....Adding $USER to the plugdev group"
doas adduser $USER plugdev

echo "....Updating /etc/NetworkManager/NetworkManager.conf"
doas mkdir -p /etc/NetworkManager/
cat NetworkManager.conf | doas tee -a /etc/NetworkManager/NetworkManager.conf > /dev/null

echo ""
echo "....Setting up NetworkManager after reboot"
echo "....WARNING! You will have to configure and enable wireless from a *wired* connection"
doas rc-update add networkmanager default
doas rc-update del networking boot
doas rc-update del wpa_supplicant boot
echo ""

echo "....Updating plocate database"
doas updatedb

echo "....Finished"
echo ""
