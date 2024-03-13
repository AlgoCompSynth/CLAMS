#! /bin/bash -v

set -e

source ./set_pico_envars
pushd nuttxspace/nuttx
for board in \
  "raspberrypi-pico-w:nsh" \
  "teensy-4.x:nsh-4.1"
do
  echo "Testing board $board"
  make distclean || true
  ./tools/configure.sh -l $board
  make
  ln -s nuttx nuttx.elf
  arm-none-eabi-objdump -d nuttx.elf > nuttx.dis
  ls -l nuttx*
done
popd

echo "Finished!"
