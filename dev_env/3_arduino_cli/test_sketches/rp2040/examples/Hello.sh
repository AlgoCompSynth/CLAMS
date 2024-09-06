#! /usr/bin/env bash

set -e

export PORT="/dev/ttyACM0"
echo "PORT: $PORT"

for fqbn in arduino:mbed_rp2040:pico rp2040:rp2040:rpipico
do

  echo ""
  echo ""
  echo ""
  echo "fqbn: $fqbn"

  for pass in 0 1 2 3 4
  do
    echo ""
    echo ""
    echo "pass: $pass"
    echo "Compiling"
    arduino-cli compile --fqbn $fqbn Hello
    echo "Uploading"
    arduino-cli upload --port $PORT --fqbn $fqbn Hello
    echo "Monitoring"
    arduino-cli monitor --port $PORT
  done

done
