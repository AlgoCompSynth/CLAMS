#! /bin/bash

set -e

# https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/get-started/linux-macos-setup.html
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

echo "Cloning tool repository"
pushd $HOME/Projects
rm -fr esp-idf
git clone -b v5.2.1 --recursive https://github.com/espressif/esp-idf.git

echo "Installing tools"
cd esp-idf
./install.sh all

popd

echo "Finished!"
