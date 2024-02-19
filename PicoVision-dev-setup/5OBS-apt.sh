#! /bin/bash

set -e

source set_pico_envars

# https://raspberrytips.com/install-obs-studio-raspberry-pi/

sudo apt-get update
sudo apt-get install -qqy --no-install-recommends \
  libfdk-aac-dev \
  obs-studio

echo "Finished!"
