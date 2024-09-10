#! /usr/bin/env bash

set -e

echo "Compiling"
arduino-cli compile --fqbn $FBQN PSRAMTest --log-level trace

echo "USB status before upload"
lsusb || true
echo "TTY status before upload"
ls -al /dev/ttyACM0 || true

echo "Capturing begin time for 'journalctl' filtering"
export SINCE=`date +%H:%M:%S`

echo "Sleeping 15 seconds for devices to settle"
sleep 15

echo "Uploading"
arduino-cli upload --port /dev/ttyACM0 --fqbn $FBQN PSRAMTest --log-level trace

echo "Sleeping 15 seconds for devices to settle"
sleep 15

echo "Capturing end time for 'journalctl' filtering"
export UNTIL=`date +%H:%M:%S`
echo "journalctl --dmesg --output=short-precise --since=$SINCE --until=$UNTIL" \
  > journalctl.sh


echo "USB status after upload"
lsusb || true
echo "TTY status after upload"
ls -al /dev/ttyACM0 || true

echo "Monitoring"
arduino-cli monitor --port /dev/ttyACM0 --config baudrate=115200 --log-level trace
