#! /bin/bash

set -e

echo "Removing old Distrobox home directory"
rm -fr $HOME/CLAMS-Distrobox
distrobox rm --force CLAMS || true

echo ""
echo "Creating CLAMS Distrobox"
distrobox create \
  --image quay.io/toolbx-images/ubuntu-toolbox:22.04 \
  --name CLAMS \
  --home $HOME/CLAMS-Distrobox \
  --init \
  --additional-packages \
    "systemd libpam-systemd"

echo ""
echo "Copying $HOME/.ssh into Distrobox home directory"
cp -rp $HOME/.ssh $HOME/CLAMS-Distrobox

echo ""
echo "Distrobox containers"
distrobox list

echo ""
echo "Finished!"
