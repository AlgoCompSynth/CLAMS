#! /bin/sh

set -eu

# https://wiki.alpinelinux.org/wiki/Eudev
echo "....Setting up udev"
setup-devd udev

echo "....Finished"
