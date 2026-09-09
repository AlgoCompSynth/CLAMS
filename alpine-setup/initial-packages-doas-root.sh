#! /bin/sh

set -eu

echo "....Upgrading if needed"
apk update && apk upgrade

echo "....Adding packages"
apk add \
    avahi \
    avahi-doc \
    avahi-openrc \
    avahi-tools \
    checkbashisms \
    curl \
    dbus \
    dbus-doc \
    file \
    git \
    fennel \
    htop \
    lua \
    mandoc \
    mandoc-apropos \
    neovim \
    plocate \
    plocate-doc \
    ripgrep \
    time \
    tree \
    wget \
    xdg-utils

echo ""
echo "....Enabling/starting services"
rc-update add avahi-daemon
rc-service avahi-daemon start
rc-update add dbus
rc-service dbus start

echo "....Updating plocate database"
updatedb

echo "....Finished"
