#! /bin/bash

set -e

mkdir --parents $HOME/.local/bin
distrobox rm --force CLAMS-Toolchain
distrobox create \
  --image quay.io/toolbx-images/ubuntu-toolbox:22.04 \
  --name CLAMS-Toolchain \
  --init \
  --additional-packages "systemd libpam-systemd libusb-dev git git-lfs time vim-nox pkg-config zsh-syntax-highlighting zsh-theme-powerlevel9k" \
  --nvidia
