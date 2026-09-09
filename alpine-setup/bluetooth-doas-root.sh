#! /bin/sh

set -eu

# https://wiki.alpinelinux.org/wiki/Bluetooth
echo "....Setting up udev"
setup-devd udev

echo "....Adding packages"
apk add \
    alsa-plugins \
    alsa-plugins-doc \
    alsa-utils \
    alsa-utils-doc \
    bluez \
    bluez-doc \
    bluez-alsa \
    bluez-alsa-doc \
    bluez-alsa-openrc \
    bluez-alsa-utils \
    tinyalsa \
    tinyalsa-doc

echo "....Enabling/starting services"
rc-update add bluetooth
rc-service bluetooth start

echo "....Updating plocate database"
updatedb

echo "....Finished"
echo ""
