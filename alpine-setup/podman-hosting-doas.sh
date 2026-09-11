#! /bin/sh

set -eu

# https://wiki.alpinelinux.org/wiki/Podman
echo "....Adding packages"
apk add \
    iptables \
    podman \
    podman-bash-completion \
    podman-doc \
    podman-compose \
    podman-compose-bash-completion \
    podman-compose-doc \
    podman-openrc \
    podman-remote \
    podman-tui

echo "....Starting/enabling tun module"
modprobe tun
echo tun >> /etc/modules

echo "....Enabling/starting services"
rc-update add cgroups default
rc-service cgroups start
rc-update add podman default
rc-service podman start

echo "....Updating plocate database"
updatedb

echo "....Finished"
echo ""
