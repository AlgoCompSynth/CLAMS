#! /usr/bin/env bash

set -e

echo "Setting install location"
export BINDIR=$ARDUINO_CLI_PATH
mkdir --parents $BINDIR

echo "Installing via 'curl'"
# https://arduino.github.io/arduino-cli/0.20/installation/
curl -fsSL $ARDUINO_CLI_URL | sh

echo "Creating fresh configuration file"
# https://arduino.github.io/arduino-cli/0.20/getting-started/
arduino-cli config init --overwrite

echo "Updating index"
arduino-cli core update-index

echo "Finished"
