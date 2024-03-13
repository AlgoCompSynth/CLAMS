#! /bin/bash -v

set -e

pushd nuttxspace/nuttx
for board in \
  raspberrypi-pico-w:nsh \
  esp32s3-generic:nsh \
  esp32c3-generic:nsh \
  teensy-4.x:nsh-4.1
do
  echo "Testing board $"
  make distclean
  ./tools/configure.sh -l $board
  make
  ls -l nuttx*
done
popd

echo "Finished!"
