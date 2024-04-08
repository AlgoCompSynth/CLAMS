#! /bin/bash

set -e

rm -fr $HOME/CLAMS-distrobox
distrobox rm -f CLAMS || true
distrobox create \
  --image quay.io/toolbx-images/ubuntu-toolbox:22.04 \
  --name CLAMS \
  --home $HOME/CLAMS-distrobox \
  --init \
  --additional-packages \
    "systemd libpam-systemd"
cp -rp $HOME/.ssh $HOME/CLAMS-distrobox

distrobox list
distrobox enter CLAMS
