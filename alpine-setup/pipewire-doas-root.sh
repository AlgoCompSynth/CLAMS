#! /bin/sh

set -eu

# https://wiki.alpinelinux.org/wiki/PipeWire
echo "....Adding packages"
apk add \
  bluez \
  bluez-openrc \
  pipewire \
  pipewire-alsa \
  pipewire-doc \
  pipewire-jack \
  pipewire-pulse \
  pipewire-spa-bluez \
  wireplumber \
  wireplumber-doc

echo "....Enabling/starting services"
rc-update add bluetooth
rc-service bluetooth start

echo "....Updating plocate database"
updatedb

echo "....Finished"
echo ""
