#! /usr/bin/env bash

set -e

echo "Installing via 'curl'"
# https://arduino.github.io/arduino-cli/0.20/installation/
/usr/bin/time curl -fsSL \
  https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh \
  | BINDIR=~/.local/bin sh

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

echo "Listing RP2040 boards to arduino-boards.log"
arduino-cli board search mbed_rp2040 > mbed-rp2040-boards.log

echo "Listing connected boards"
arduino-cli board list

echo "Finished"
