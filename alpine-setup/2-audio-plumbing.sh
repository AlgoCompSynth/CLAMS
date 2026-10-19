#! /bin/sh

set -eu

# References:
# https://wiki.alpinelinux.org/wiki/Bluetooth
# https://wiki.alpinelinux.org/wiki/PipeWire

echo "....Creating logfile"
export LOGFILE=$HOME/Logfiles/audio-plumbing.log
echo "" > $LOGFILE

echo "....Adding packages"
doas apk add -vv \
    alsa-lib \
    alsa-lib-dev \
    bluetui@testing \
    bluetui-doc@testing \
    bluez \
    bluez-doc \
    bluez-openrc \
    fluidsynth \
    fluidsynth-dev \
    fluidsynth-doc \
    pipemixer@testing \
    pipemixer-doc@testing \
    pipewire \
    pipewire-alsa \
    pipewire-dev \
    pipewire-doc \
    pipewire-jack \
    pipewire-jack-dev \
    pipewire-pulse \
    pipewire-spa-bluez \
    pipewire-spa-tools \
    pipewire-tools \
    rtkit \
    rtkit-doc \
    wireplumber \
    wireplumber-dev \
    wireplumber-doc \
    >> $LOGFILE 2>&1

echo ""
echo "....Setting up services for next reboot"
rc-update -U add pipewire console
rc-update -U add pipewire-pulse console
rc-update -U add wireplumber console
doas rc-update add bluetooth
doas rc-service bluetooth start

echo "....Adding $USER to the pipewire and rtkit groups"
doas adduser $USER pipewire
doas adduser $USER rtkit

echo "....Indexing man pages"
doas makewhatis

echo "....Updating plocate database"
doas updatedb

echo "....Log out and back in again to start user services"

echo "....Finished"
echo ""
