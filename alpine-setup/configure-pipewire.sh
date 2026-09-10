#! /bin/sh

set -eu

# https://wiki.alpinelinux.org/wiki/PipeWire#User_service
# https://wiki.alpinelinux.org/wiki/OpenRC_User_Services#User_runlevels
# https://wiki.alpinelinux.org/wiki/PipeWire#Configuration
echo "....Enabling/starting services"
mkdir -p ~/.config/rc/runlevels/console
rc-update -U add pipewire console
rc-update -U add pipewire-pulse console
rc-update -U add wireplumber console

echo "....Configuring groups"
doas adduser $USER pipewire
doas adduser $USER rtkit

echo "....Finished"
echo ""
