#! /bin/bash

set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo ""
echo "Setting environment variables"
source ./set_pico_envars

# https://nuttx.apache.org/docs/latest/quickstart/install.html

echo ""
echo "Installing 'sim board' dependencies"
sudo apt-get install -qqy --no-install-recommends \
  libasound2-dev \
  libxext-dev \
  libmad0-dev \
  libmp3lame-dev \
  libx11-dev

echo "Finished!!"
