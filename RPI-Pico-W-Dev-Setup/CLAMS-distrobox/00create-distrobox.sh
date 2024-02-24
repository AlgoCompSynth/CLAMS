#! /bin/bash

set -e

rm -fr $HOME/CLAMS-distrobox
distrobox rm -f CLAMS || true
distrobox create \
  --image docker.io/library/debian:bookworm-backports \
  --name CLAMS \
  --home $HOME/CLAMS-distrobox \
  --init \
  --additional-packages \
    "systemd libpam-systemd apt-file build-essential cmake git git-lfs mlocate ninja-build python3-venv time tree vim-nox"
cp -rp $HOME/.ssh $HOME/CLAMS-distrobox

distrobox list
