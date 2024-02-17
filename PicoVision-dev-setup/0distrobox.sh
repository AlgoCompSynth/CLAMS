#! /bin/bash

set -e

distrobox rm -f CLAMS-development
distrobox create \
  --clone Jammy \
  --name CLAMS-development \
  --init \
  --additional-packages "systemd libpam-systemd git git-lfs time tree vim-nox zsh zsh-autosuggestions zsh-syntax-highlighting" \
  --nvidia
