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
mv /tmp/_arduino-cli.sh $ZSH_LOCAL_COMPLETIONS_PATH/_arduino-cli

echo "Finished"
