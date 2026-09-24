#! /bin/sh

set -eu

# References:
# https://wiki.alpinelinux.org/wiki/MDNS
# https://wiki.alpinelinux.org/wiki/NetworkManager

echo "....Creating logfile"
export LOGFILE=$HOME/Logfiles/network-manager.log
echo "" > $LOGFILE

echo "....Adding packages"
doas apk add -vv \
    avahi \
    avahi-doc \
    avahi-tools \
    avahi2dns@testing \
    drill \
    networkmanager \
    networkmanager-cli \
    networkmanager-dnsmasq \
    networkmanager-doc \
    networkmanager-tui \
    networkmanager-wifi \
    >> $LOGFILE 2>&1

echo "....Setting configuration files"
echo "......NetworkManager.conf"
doas mkdir -p /etc/NetworkManager/
doas cp NetworkManager.conf /etc/NetworkManager/NetworkManager.conf

echo "......mdns.conf"
doas mkdir -p /etc/NetworkManager/dnsmasq.d/
doas cp mdns.conf /etc/NetworkManager/dnsmasq.d/mdns.conf

echo "......resolvconf"
doas mkdir -p /etc/udhcpc/post-bound/resolvconf
doas cp resolvconf /etc/udhcpc/post-bound/resolvconf

echo ""
echo "....Setting up services for next reboot"
doas rc-update add avahi-daemon
doas rc-update add avahi2dns
doas rc-update add dbus
doas rc-update add networkmanager default
doas rc-update del networking boot || true
doas rc-update del wpa_supplicant boot || true
echo ""

echo "....Adding $USER to the plugdev group"
doas adduser $USER plugdev

echo "....Indexing man pages"
doas makewhatis

echo "....Updating plocate database"
doas updatedb

echo ""
echo ""
echo "....Setup complete - reboot"
echo "....WARNING! You will need either a console or wired Ethernet connection to reconfigure WiFi!"

echo "....Finished"
echo ""
