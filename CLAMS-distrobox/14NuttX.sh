#! /bin/bash

set -e

# https://nuttx.apache.org/docs/latest/quickstart/install.html
echo "Updating package list"
sudo apt-get update -qq

echo "Installing NuttX dependencies"
sudo apt-get install -qqy \
  automake \
  binutils-dev \
  bison \
  build-essential \
  flex \
  gcc-multilib \
  g++-multilib \
  gettext \
  genromfs \
  gperf \
  libelf-dev \
  libexpat-dev \
  libgmp-dev \
  libisl-dev \
  libmpc-dev \
  libmpfr-dev \
  libncurses5-dev \
  libncursesw5-dev \
  libtool \
  picocom \
  pkg-config \
  texinfo \
  u-boot-tools \
  util-linux \
  xxd

echo "Installing KConfig tools"
sudo apt-get install -qqy \
  kconfig-frontends

echo "Installing Arm cross-build tools"
sudo apt-get install -qqy \
  binutils-arm-none-eabi \
  gcc-arm-none-eabi \
  gdb-multiarch \
  minicom

export NUTTX_VERSION="12.4.0"
echo "Downloading NuttX version $NUTTX_VERSION"
rm -fr nuttxspace; mkdir nuttxspace; cd nuttxspace
curl -L \
  https://www.apache.org/dyn/closer.lua/nuttx/$NUTTX_VERSION/apache-nuttx-$NUTTX_VERSION.tar.gz?action=download -o nuttx.tar.gz
curl -L \
  https://www.apache.org/dyn/closer.lua/nuttx/$NUTTX_VERSION/apache-nuttx-apps-$NUTTX_VERSION.tar.gz?action=download -o apps.tar.gz
tar zxf nuttx.tar.gz
tar zxf apps.tar.gz

echo "Finished!!"
