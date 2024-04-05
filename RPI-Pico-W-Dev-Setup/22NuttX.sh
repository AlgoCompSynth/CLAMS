#! /bin/bash

set -e

# https://nuttx.apache.org/docs/latest/quickstart/install.html
source set_pico_envars

echo ""; sleep 2
echo "Installing NuttX dependencies"
if [ `uname -m` == "x86_64" ]
then
  sudo apt-get install -qqy \
    gcc-multilib \
    g++-multilib
fi
sudo apt-get install -qqy \
  automake \
  binutils-dev \
  bison \
  build-essential \
  flex \
  gcc-riscv64-unknown-elf \
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
echo "Downloading NuttX version $NUTTX_VERSION"
rm -fr $NUTTX_PATH; mkdir $NUTTX_PATH; pushd $NUTTX_PATH

#git clone --branch nuttx-$NUTTX_VERSION https://github.com/apache/nuttx.git nuttx
git clone --branch fix-rp2040-defconfigs https://github.com/masayuki2009/incubator-nuttx.git nuttx
git clone --branch nuttx-$NUTTX_VERSION https://github.com/apache/nuttx-apps.git apps

echo ""; sleep 2
echo "Listing supported configurations onto $NUTTX_PATH/supported-configurations.txt"
cd nuttx
./tools/configure.sh -L > $NUTTX_PATH/supported-configurations.txt
cd ..

popd

echo ""; sleep 2
echo "Finished!!"
