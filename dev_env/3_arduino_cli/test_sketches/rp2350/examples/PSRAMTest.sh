#! /usr/bin/env bash

set -e

echo "Compiling"
arduino-cli compile --fqbn $FBQN PSRAMTest

echo "USB and TTY status before upload"
lsusb || true
ls -al /dev/ttyACM0 || true

echo "Capturing begin time for 'journalctl' filtering"
echo "begin `date +%s`" > datestamps.log

echo "Sleeping 15 seconds for devices to settle"
sleep 15

echo "Uploading"
arduino-cli upload --port /dev/ttyACM0 --fqbn $FBQN PSRAMTest

echo "Sleeping 15 seconds for devices to settle"
sleep 15

echo "Capturing end time for 'journalctl' filtering"
echo "end `date +%s`" >> datestamps.log

echo "USB and TTY status after upload"
lsusb || true
ls -al /dev/ttyACM0 || true

echo "Monitoring"
arduino-cli monitor --port /dev/ttyACM0
