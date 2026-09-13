#! /bin/sh

set -eu

# https://wiki.alpinelinux.org/wiki/Podman
echo "....Adding packages"
apk add \
    buildah \
    buildah-doc \
    iptables \
    podman \
    podman-bash-completion \
    podman-doc \
    podman-compose \
    podman-compose-bash-completion \
    podman-compose-doc \
    skopeo \
    skopeo-bash-completion \
    skopeo-doc

echo "....Starting/enabling tun module"
modprobe tun
echo tun >> /etc/modules

echo "....Enabling/starting services"
rc-update add cgroups default
rc-service cgroups start

echo "....Updating plocate database"
updatedb

echo "....Finished"
echo ""
