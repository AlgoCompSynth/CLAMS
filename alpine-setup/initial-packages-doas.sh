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
    fennel5.5 \
    htop \
    lua5.5 \
    lynx \
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

echo "....Updating plocate database"
updatedb

echo "....Finished"
