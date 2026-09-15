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
    faust \
    faust-doc \
    faust-tools \
    love \
    love-doc \
    milkytracker \
    milkytracker-doc \
    pipemixer \
    pipemixer-doc \
    pipewire \
    pipewire-alsa \
    pipewire-doc \
    pipewire-jack \
    pipewire-pulse \
    pipewire-spa-bluez \
    pipewire-tools \
    rtkit \
    rtkit-doc \
    schismtracker \
    schismtracker-doc \
    wireplumber \
    wireplumber-doc \
    wireplumber-bash-completion

echo "....Enabling/starting services"
rc-update add bluetooth
rc-service bluetooth start

echo "....Listing Faust version"
faust --version > faust-version.txt
echo "" >> faust-version.txt
ls -1 /usr/bin/faust2* | sed 's;/usr/bin/;;' >> faust-version.txt

echo "....Updating plocate database"
updatedb

echo "....Finished"
echo ""
