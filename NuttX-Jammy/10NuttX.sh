#! /bin/bash

set -e

# https://nuttx.apache.org/docs/latest/quickstart/install.html
source set_pico_envars

echo "Installing NuttX dependencies"
sudo apt-get update -qq
sudo apt-get upgrade -qqy
sudo apt-get install -qqy \
  automake \
  binutils-dev \
  bison \
  build-essential \
  flex \
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

echo "Downloading NuttX version $NUTTX_VERSION"
rm -fr $NUTTX_PATH; mkdir $NUTTX_PATH; pushd $NUTTX_PATH

if [ "$NUTTX_VERSION" = "master" ]
then
  git clone --branch master https://github.com/apache/nuttx.git nuttx
  git clone --branch master https://github.com/apache/nuttx-apps.git apps
else
  git clone --branch nuttx-$NUTTX_VERSION https://github.com/apache/nuttx.git nuttx
  git clone --branch nuttx-$NUTTX_VERSION https://github.com/apache/nuttx-apps.git apps
fi

echo "Listing supported configurations onto $NUTTX_PATH/supported-configurations.txt"
cd nuttx
./tools/configure.sh -L | sort -u > $NUTTX_PATH/supported-configurations.txt
cd ..

popd

echo "Finished!!"
