#! /bin/bash

set -e

source set_pico_envars

echo "Adding OBS Studio PPA"
sudo add-apt-repository -y ppa:obsproject/obs-studio
sudo apt-get update -qq

echo ""; sleep 2
echo "Installing OBS Studio"
sudo apt-get install -qqy --no-install-recommends \
  obs-studio

echo "Finished!"
