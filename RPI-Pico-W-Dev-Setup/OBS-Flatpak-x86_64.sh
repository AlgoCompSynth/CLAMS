#! /bin/bash

set -e

echo "Installing Flatpak"
sudo apt-get update -qq
sudo apt-get install -qqy --no-install-recommends \
  flatpak \
  flatpak-xdg-utils
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo ""; sleep 2
echo "Installing OBS Studio"
flatpak install flathub com.obsproject.Studio

echo ""; sleep 2
echo "Finished!"
