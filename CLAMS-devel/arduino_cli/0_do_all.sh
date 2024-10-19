#! /usr/bin/env bash

set -e

rm --force *.log

for script in \
  uninstall_arduino_cli.sh \
  1_arduino_cli.sh \
  2_arduino_pico.sh \
  3_arduino_audio_tools.sh \
  4_adafruit_tinyusb_arduino_pico.sh \
  7_daisyduino.sh \
  8_teensyduino.sh \
  9_esp32.sh \
  list_boards_and_examples.sh
do
  ./$script
done
