#! /bin/bash

set -e

source set_pico_envars

# https://docs.espressif.com/projects/esp-idf/en/latest/esp32s3/get-started/linux-macos-setup.html

echo "Installing Linux dependencies"
sudo apt-get install -qqy \
  git \
  wget \
  flex \
  bison \
  gperf \
  python3 \
  python3-pip \
  python3-venv \
  cmake \
  ninja-build \
  ccache \
  libffi-dev \
  libssl-dev \
  dfu-util \
  libusb-1.0-0

echo "Cloning repository"
mkdir --parents $NUTTX_ESP32_TOOLS
cd $NUTTX_ESP32_TOOLS
git clone --recursive https://github.com/espressif/esp-idf.git

echo "Installing"
cd esp-idf
./install.sh all

echo "Finisehd!"
