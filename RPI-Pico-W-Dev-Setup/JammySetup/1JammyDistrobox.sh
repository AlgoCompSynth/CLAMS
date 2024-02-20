#! /bin/bash

set -e

distrobox rm -f Jammy
distrobox create \
  --image docker.io/library/ubuntu:22.04 \
  --name Jammy \
  --home $HOME/JammyDistrobox \
  --additional-packages \
    "apt-file binutils-arm-none-eabi cmake gcc-arm-none-eabi gcc-arm-none-eabi-source gdb-multiarch git git-lfs mlocate ninja-build python3-venv time tree vim-nox zsh zsh-autosuggestions zsh-syntax-highlighting" \
  --nvidia
ln -sf $HOME/Projects $HOME/JammyDistrobox
cp -rp $HOME/.ssh $HOME/JammyDistrobox

distrobox list
