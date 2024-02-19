#! /bin/bash

set -e

distrobox rm -f CLAMS-Dev
distrobox create \
  --image docker.io/library/ubuntu:22.04 \
  --name CLAMS-Dev \
  --home $HOME/CLAMS-DevDistrobox \
  --additional-packages \
    "git git-lfs python3-venv time tree vim-nox" \
  --nvidia
ln -sf $HOME/Projects $HOME/CLAMS-DevDistrobox
cp -rp $HOME/.ssh $HOME/CLAMS-DevDistrobox

distrobox list
