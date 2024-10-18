#! /usr/bin/env bash

set -e

rm --force *.log

for script in \
  uninstall_arduino_cli.sh \
  1_arduino_cli.sh \
  2_arduino_pico.sh \
  3_teensyduino.sh \
  4_daisyduino.sh \
  5_esp32.sh \
  6_adafruit_tinyusb_arduino_pico.sh \
  7_arduino_audio_tools.sh \
  boards_and_examples.sh
do
  ./$script
done
