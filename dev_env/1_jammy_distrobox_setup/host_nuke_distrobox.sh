#! /usr/bin/env bash

set -e

export DBX_NAME="CLAMS_dev_jammy"
echo "Run this script on the Distrobox host to force-remove the"
echo "Distrobox container"
echo ""
echo "    $DBX_NAME"
echo ""
echo "and its home directory"
echo ""
echo "    $HOME/dbx-homes/$DBX_NAME."
echo ""
echo ""
echo "Sleeping 20 seconds - use CTL-C if you change your mind!"
sleep 20

echo "Removing Distrobox container $DBX_NAME"
distrobox rm --force $DBX_NAME

echo "Removing $HOME/dbx-homes/$DBX_NAME"
rm --force --recursive $HOME/dbx-homes/$DBX_NAME

echo "Finished"
