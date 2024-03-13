#! /bin/bash

set -e

# https://nuttx.apache.org/docs/latest/quickstart/running.html
echo "Building openocd from source"
sudo rm -fr openocd
git clone git://git.code.sf.net/p/openocd/code openocd
cd openocd
./bootstrap
./configure --prefix=/usr/local/
sudo make install

echo "Finished!!"
