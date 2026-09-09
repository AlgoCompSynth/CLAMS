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
    neovim \
    ripgrep \
    time \
    tree \
    wget

echo "....Finished"
echo ""
