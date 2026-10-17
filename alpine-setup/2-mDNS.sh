#! /bin/sh

set -eu

# References:
# https://wiki.alpinelinux.org/wiki/MDNS

echo "....Creating logfile"
export LOGFILE=$HOME/Logfiles/mDNS.log
echo "" > $LOGFILE

echo "....Adding packages"
doas apk add -vv \
    avahi \
    avahi-doc \
    avahi-tools \
    avahi2dns@testing \
    drill \
    openresolv \
    openresolv-doc \
    unbound \
    unbound-doc \
    >> $LOGFILE 2>&1

echo "....Setting configuration files"
echo "......resolvconf.conf"
doas cp resolvconf.conf /etc/resolvconf.conf

echo "......avahi-local.conf"
doas mkdir -p /etc/unbound/unbound.conf.d/
doas cp avahi-local.conf /etc/unbound/unbound.conf.d/avahi-local.conf

echo ""
echo "....Setting up services"
doas rc-update add avahi-daemon
doas rc-update add avahi2dns
doas rc-update add unbound
doas rc-service avahi-daemon start
doas rc-service avahi2dns start
doas rc-service unbound start
echo ""

echo "....Indexing man pages"
doas makewhatis

echo "....Updating plocate database"
doas updatedb

echo ""
echo ""
echo "....Setup complete"

echo "....Finished"
echo ""
