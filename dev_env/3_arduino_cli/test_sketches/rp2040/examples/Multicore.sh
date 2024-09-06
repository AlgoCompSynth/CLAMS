#! /usr/bin/env bash

set -e

export PORT="/dev/ttyACM0"
for fqbn in rp2040:rp2040:rpipico
do
  echo "Compiling $fqbn"
  arduino-cli compile --fqbn $fqbn Multicore
  echo "Uploading $fqbn to $PORT"
  arduino-cli upload --port $PORT --fqbn $fqbn Multicore
  echo ""
  echo ""
  echo "Monitoring $PORT"
  arduino-cli monitor --port $PORT
done
