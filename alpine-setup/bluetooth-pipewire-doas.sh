#! /bin/sh

set -eu

# https://wiki.alpinelinux.org/wiki/Bluetooth
# https://wiki.alpinelinux.org/wiki/PipeWire
echo "....Adding packages"
apk add \
    bluez \
    bluez-doc \
    bluez-openrc \
    pipewire-spa-bluez

echo "....Enabling/starting services"
rc-update add bluetooth
rc-service bluetooth start

echo "....Updating plocate database"
updatedb

echo "....Finished"
echo ""
