#! /bin/bash -v

set -e

pushd nuttxspace/nuttx
cmake -B build -DBOARD_CONFIG=raspberrypi-pico-w:nsh -GNinja
ls -l build
popd
