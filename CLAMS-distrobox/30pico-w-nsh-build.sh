#! /bin/bash -v

set -e

echo "Building nuttx"
pushd nuttxspace/nuttx
make distclean
./tools/configure.sh -l raspberrypi-pico-w:nsh
make
ls -l nuttx*
popd

echo "Finished!"
