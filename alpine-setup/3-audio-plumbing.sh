#! /bin/sh

set -eu

# https://wiki.alpinelinux.org/wiki/Bluetooth
# https://wiki.alpinelinux.org/wiki/PipeWire
echo "....Adding packages"
apk add \
    alsa-plugins \
    alsa-plugins-doc \
    alsa-utils \
    alsa-utils-doc \
    bluez \
    bluez-doc \
    bluez-openrc \
    pipemixer \
    pipemixer-doc \
    pipewire \
    pipewire-alsa \
    pipewire-doc \
    pipewire-pulse \
    pipewire-spa-bluez \
    pipewire-tools \
    rtkit \
    rtkit-doc \
    wireplumber \
    wireplumber-doc \
    wireplumber-bash-completion

echo "....Enabling/starting services"
rc-update add bluetooth
rc-service bluetooth start

echo "....Updating plocate database"
updatedb

echo "....Finished"
echo ""
