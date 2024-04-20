#! /bin/bash

set -e

rm -fr $HOME/CLAMS-Distrobox
distrobox rm --force CLAMS || true
distrobox create \
  --image quay.io/toolbx-images/ubuntu-toolbox:22.04 \
  --name CLAMS \
  --home $HOME/CLAMS-Distrobox \
  --init \
  --additional-packages \
    "systemd libpam-systemd"
cp -rp $HOME/.ssh $HOME/CLAMS-Distrobox

distrobox list

echo ""
echo ""
echo "Type 'distrobox enter CLAMS' to use the CLAMS Ubuntu 22.04 LTS tools."
