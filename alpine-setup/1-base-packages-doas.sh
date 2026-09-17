#! /bin/sh

set -eu

echo "....Upgrading if needed"
apk update && apk upgrade

echo "....Adding packages"
apk add \
    bash \
    bash-doc \
    bash-completion \
    bash-completion-doc \
    build-base \
    ccache \
    ccache-doc \
    checkbashisms \
    cmake \
    cmake-doc \
    cmake-vim \
    curl \
    curl-doc \
    dbus \
    dbus-doc \
    doas-doc \
    doas-sudo-shim \
    doas-sudo-shim-doc \
    extra-cmake-modules \
    file \
    git \
    git-doc \
    fenneljit \
    fennel-doc \
    htop \
    htop-doc \
    lua5.1 \
    lua5.1-doc \
    luajit \
    luajit-doc \
    lynx \
    lynx-doc \
    man-pages \
    mandoc \
    mandoc-doc \
    mandoc-apropos \
    mkrundir \
    neovim \
    neovim-doc \
    nerd-fonts-all \
    openssh-doc \
    openssl-doc \
    plocate \
    plocate-doc \
    raspberrypi-bootloader-doc \
    ripgrep \
    ripgrep-doc \
    shadow \
    shadow-doc \
    starship \
    time \
    time-doc \
    tree \
    tree-doc \
    wget \
    wget-doc \
    xdg-utils \
    xdg-utils-doc

echo ""
echo "....Enabling/starting services"
rc-update add dbus
rc-service dbus start

# https://wiki.alpinelinux.org/wiki/Eudev
echo "....Setting up udev"
setup-devd udev

echo "....Updating plocate database"
updatedb

echo "....Finished"
