#! /bin/bash

set -e

# https://nuttx.apache.org/docs/latest/quickstart/install.html
echo ""; sleep 2
echo "Updating package cache"
sudo apt-get update -qq

echo ""; sleep 2
echo "Installing NuttX dependencies"
sudo apt-get install -qqy --no-install-recommends \
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

echo ""; sleep 2
echo "Installing KConfig tools"
sudo apt-get install -qqy \
  kconfig-frontends

echo ""; sleep 2
export NUTTX_VERSION="12.4.0"
echo "Downloading NuttX version $NUTTX_VERSION"
rm -fr nuttxspace; mkdir nuttxspace; cd nuttxspace
git clone --branch nuttx-$NUTTX_VERSION https://github.com/apache/nuttx.git nuttx
git clone --branch nuttx-$NUTTX_VERSION https://github.com/apache/nuttx-apps.git apps

echo ""; sleep 2
echo "Listing supported configurations"
cd nuttx
./tools/configure.sh -L > ../../supported-configurations.txt
cd ..

echo ""; sleep 2
echo "Finished!!"
