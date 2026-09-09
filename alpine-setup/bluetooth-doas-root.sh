#! /bin/sh

set -eu

# https://wiki.alpinelinux.org/wiki/Bluetooth
echo "....Adding packages"
apk add \
    bluez \
    bluez-doc \
    bluez-alsa \
    bluez-alsa-doc \
    bluez-alsa-openrc \
    bluez-alsa-utils

echo "....Enabling/starting services"
rc-update add bluetooth
rc-service bluetooth start

echo "....Updating plocate database"
updatedb

echo "....Finished"
echo ""
