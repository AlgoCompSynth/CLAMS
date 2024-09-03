#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Installing via 'curl'"
# https://arduino.github.io/arduino-cli/0.20/installation/
/usr/bin/time curl -fsSL $ARDUINO_CLI_URL | BINDIR=$ARDUINO_CLI_PATH sh

echo "Creating fresh configuration file"
# https://arduino.github.io/arduino-cli/0.20/getting-started/
arduino-cli config init --overwrite

echo "Updating index"
arduino-cli core update-index

echo "Installing bash completion file"
arduino-cli completion bash > /tmp/ardunio-cli.sh
sudo mv /tmp/ardunio-cli.sh /etc/bash_completion.d/ardunio-cli.sh

echo "Installing zsh completion file"
arduino-cli completion zsh > /tmp/_arduino-cli.sh
sudo mv /tmp/_arduino-cli.sh /usr/share/zsh/vendor-completions/_arduino-cli

echo "Installing Arduino MBED RP2040 core"
arduino-cli core install arduino:mbed_rp2040

echo "Listing MBED RP2040 boards to mbed_rp2040_boards.log"
arduino-cli board listall | grep "arduino:mbed_rp2040" > mbed_rp2040_boards.log

echo "Listing MBED RP2040 examples to mbed_rp2040_examples.log"
find $HOME/.arduino15/packages/arduino/hardware/mbed_rp2040 -name 'examples' \
  | sort -u \
  > mbed_rp2040_examples.log

echo "Listing connected boards"
arduino-cli board list

echo "Finished"
