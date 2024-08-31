#! /usr/bin/env bash

set -e

arduino-cli compile --fqbn rp2040:rp2040:rpipicow Temperature
arduino-cli upload --port $1 --fqbn rp2040:rp2040:rpipicow Temperature
arduino-cli monitor --port $1
