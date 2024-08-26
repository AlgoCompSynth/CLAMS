#! /usr/bin/env bash

set -e

echo "Installing via 'curl'"
# https://arduino.github.io/arduino-cli/0.20/installation/
curl -fsSL \
  https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh \
  | BINDIR=~/.local/bin sh

echo "Creating fresh configuration file"
# https://arduino.github.io/arduino-cli/0.20/getting-started/
arduino-cli config init --overwrite

echo "Updating index"
arduino-cli core update-index

echo "Installing bash completion file"
arduino-cli completion bash \
  | sudo tee /etc/bash_completion.d/ardunio-cli.sh

echo "Installing zsh completion file"
arduino-cli completion zsh \
  | sudo tee /usr/share/zsh/vendor-completions/_arduino-cli

echo "Finished"
