#! /usr/bin/env bash

set -e

export DBX_NAME="CLAMS-PlatformIO"
echo "Usage: run this script on the Distrobox host"
echo "to force-remove the distrobox $DBX_NAME"
echo "and it's home directory $HOME/dbx-homes/$DBX_NAME."
echo ""
echo "Sleeping 20 seconds - use CTL-C if you change your mind!"
sleep 20

echo "Removing distrobox $DBX_NAME"
distrobox rm --force $DBX_NAME

echo "Removing $HOME/dbx-homes/$DBX_NAME"
rm --force --recursive $HOME/dbx-homes/$DBX_NAME

echo "Finished"
