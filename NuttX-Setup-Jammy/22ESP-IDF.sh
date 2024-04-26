#! /bin/bash

set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo "Setting environment variables"
source ./set_pico_envars

# https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/linux-macos-setup.html#get-started-prerequisites
echo "Linux prerequisites"
sudo apt-get install -qqy --no-install-recommends \
  bison \
  ccache \
  cmake \
  dfu-util \
  flex \
  git \
  gperf \
  libffi-dev \
  libssl-dev \
  libusb-1.0-0 \
  ninja-build \
  python3 \
  python3-pip \
  python3-venv \
  wget

echo "Installing esptool and imgtool"
source $NUTTX_VENV/bin/activate
pip install --upgrade esptool imgtool
deactivate

echo "Finished!"
