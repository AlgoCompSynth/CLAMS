#! /bin/sh

set -eu

# https://wiki.alpinelinux.org/wiki/NetworkManager
# https://wiki.alpinelinux.org/wiki/MDNS
echo "....Creating logfile"
export LOGFILE=$HOME/Logfiles/networkmanager.log
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

echo "....Adding $USER to the plugdev group"
doas adduser $USER plugdev

echo "....Setting configuration files"

echo "......NetworkManager.conf"
doas mkdir -p /etc/NetworkManager/
diff NetworkManager.conf /etc/NetworkManager/NetworkManager.conf || true
doas cp NetworkManager.conf /etc/NetworkManager/NetworkManager.conf

echo "......mdns.conf"
doas mkdir -p /etc/NetworkManager/dnsmasq.d/
diff mdns.conf /etc/NetworkManager/dnsmasq.d/mdns.conf || true
doas cp mdns.conf /etc/NetworkManager/dnsmasq.d/mdns.conf

echo "......resolvconf"
doas mkdir -p /etc/udhcpc/post-bound/resolvconf
diff resolvconf /etc/udhcpc/post-bound/resolvconf || true
doas cp resolvconf /etc/udhcpc/post-bound/resolvconf

echo ""
echo "....Setting up services for next reboot"
echo "....WARNING! You will have to configure and enable wireless from a *wired* connection"
doas rc-update add avahi-daemon
doas rc-update add avahi2dns
doas rc-update add networkmanager default
doas rc-update del networking boot || true
doas rc-update del wpa_supplicant boot || true
echo ""

echo "....Updating plocate database"
doas updatedb

echo "....Finished"
echo ""
