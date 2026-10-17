#! /bin/sh

set -eu

# References:
# https://wiki.alpinelinux.org/wiki/Repositories#Upgrading_to_edge

echo "....Setting up home directories"
mkdir --parents $HOME/.local/bin $HOME/Logfiles $HOME/Projects $HOME/.config/rc/runlevels/console

echo "....Switching to edge release with tagged @testing!"
diff repositories /etc/apk/repositories || true
doas cp repositories /etc/apk/repositories

echo "....Upgrading if needed"
doas apk upgrade

echo "....Edge upgrade complete - reboot!"

echo "....Finished"
echo ""
