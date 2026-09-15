#! /bin/sh

set -eu

echo "....Upgrading if needed"
apk update && apk upgrade

echo "....Adding packages"
apk add \
    avahi \
    avahi-doc \
    avahi-tools \
    bash \
    bash-doc \
    bash-completion \
    bash-completion-doc \
    checkbashisms \
    curl \
    dbus \
    dbus-doc \
    doas-sudo-shim \
    doas-sudo-shim-doc \
    file \
    git \
    fenneljit \
    fennel-doc \
    htop \
    lua5.1 \
    lua5.1-doc \
    luajit \
    luajit-doc \
    lynx \
    man-pages \
    mandoc \
    mandoc-doc \
    mandoc-apropos \
    mkrundir \
    neovim \
    neovim-doc \
    nerd-fonts-all \
    plocate \
    plocate-doc \
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

# https://wiki.alpinelinux.org/wiki/Eudev
echo "....Setting up udev"
setup-devd udev

echo "....Updating plocate database"
updatedb

echo "....Finished"
