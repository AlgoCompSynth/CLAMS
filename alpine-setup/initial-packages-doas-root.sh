#! /bin/sh

set -eu

echo "....Upgrading if needed"
apk update && apk upgrade

echo "....Adding packages"
apk add \
    checkbashisms \
    curl \
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

echo "....Updating plocate database"
updatedb

echo "....Finished"
echo ""
