#! /usr/bin/env bash

set -e

echo "Setting install location"
export BINDIR=$HOME/.local/bin
mkdir --parents $BINDIR

echo "Installing via 'curl'"
# https://arduino.github.io/arduino-cli/0.20/installation/
curl -fsSL \
  https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh \
  | sh

echo "Creating fresh configuration file"
# https://arduino.github.io/arduino-cli/0.20/getting-started/
arduino-cli config init --overwrite

echo "Updating index"
arduino-cli core update-index

echo "Finished"
