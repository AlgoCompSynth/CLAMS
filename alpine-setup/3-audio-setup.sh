#! /bin/sh

set -eu

# References:
# https://wiki.alpinelinux.org/wiki/Bluetooth
# https://wiki.alpinelinux.org/wiki/PipeWire

echo "....Creating logfile"
export LOGFILE=$HOME/Logfiles/audio-setup.log
echo "" > $LOGFILE

echo "....Adding packages"
doas apk add -vv \
    alsa-plugins \
    alsa-plugins-doc \
    alsa-utils \
    alsa-utils-doc \
    bluetui@testing \
    bluetui-doc@testing \
    bluez \
    bluez-doc \
    bluez-openrc \
    clang20 \
    clang20-ccache \
    clang20-dev \
    clang20-extra-tools \
    clang20-headers \
    clang20-libclang \
    clang20-libs \
    clang20-rtlib \
    clang20-static \
    faust@testing \
    faust-dev@testing \
    faust-doc@testing \
    faust-static@testing \
    faust-tools@testing \
    faust-vim@testing \
    llvm20 \
    llvm20-dev \
    llvm20-gtest \
    llvm20-libs \
    llvm20-linker-tools \
    llvm20-static \
    llvm20-test-utils \
    llvm20-test-utils-pyc \
    pipemixer@testing \
    pipemixer-doc@testing \
    pipewire \
    pipewire-alsa \
    pipewire-doc \
    pipewire-jack \
    pipewire-pulse \
    pipewire-spa-bluez \
    pipewire-tools \
    rtkit \
    rtkit-doc \
    wireplumber \
    wireplumber-doc \
    wireplumber-bash-completion \
    >> $LOGFILE 2>&1

echo ""
echo "....Setting up services for next reboot"
rc-update -U add pipewire console
rc-update -U add pipewire-pulse console
rc-update -U add wireplumber console
doas rc-update add bluetooth
doas rc-service bluetooth start

echo "....Listing Faust version"
faust --version > faust-version.txt
echo "" >> faust-version.txt
ls -1 /usr/bin/faust2* | sed 's;/usr/bin/;;' >> faust-version.txt

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
