#! /usr/bin/env bash

set -e

export FBQN="rp2040:rp2040:sparkfun_promicrorp2350"
arduino-cli compile --fqbn $FBQN PSRAMTest
arduino-cli upload --port /dev/ttyACM0 --fqbn $FBQN PSRAMTest
arduino-cli monitor --port /dev/ttyACM0
