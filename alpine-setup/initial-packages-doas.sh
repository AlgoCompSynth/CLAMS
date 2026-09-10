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
    bash \
    bash-doc \
    bash-completion \
    bash-completion-doc \
    checkbashisms \
    curl \
    dbus \
    dbus-doc \
    file \
    git \
    fennel5.5 \
    htop \
    lua5.5 \
    lynx \
    mandoc \
    mandoc-apropos \
    neovim \
    nerd-fonts-all \
    plocate \
    plocate-doc \
    raspberrypi-utils \
    ripgrep \
    shadow \
    starship \
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
