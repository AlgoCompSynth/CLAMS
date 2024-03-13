#! /bin/bash -v

set -e

source ./set_pico_envars
pushd nuttxspace/nuttx
for board in \
  "esp32c3-devkit:nsh" \
  "esp32s3-devkit:nsh" \
  "raspberrypi-pico-w:nsh" \
  "teensy-4.x:nsh-4.1"
do
  echo "Testing board $board"
  make distclean || true
  ./tools/configure.sh -l $board
  make
  ls -l nuttx*
done
popd

echo "Finished!"
