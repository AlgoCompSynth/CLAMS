#! /bin/sh

set -eu

# https://wiki.alpinelinux.org/wiki/PipeWire
echo "....Adding packages"
apk add \
    alsa-plugins \
    alsa-plugins-doc \
    alsa-utils \
    alsa-utils-doc \
    pipemixer \
    pipemixer-doc \
    pipewire \
    pipewire-alsa \
    pipewire-doc \
    pipewire-pulse \
    pipewire-tools \
    rtkit \
    rtkit-doc \
    wireplumber \
    wireplumber-doc \
    wireplumber-bash-completion

echo "....Updating plocate database"
updatedb

echo "....Finished"
echo ""
