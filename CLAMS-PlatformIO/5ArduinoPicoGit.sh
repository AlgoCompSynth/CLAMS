#! /usr/bin/env bash

set -e

echo "Defining LOGFILE"
export LOGFILE="$PWD/5ArduinoCLI.log"
echo "Removing any existing $HOME/Arduino"
rm -fr $HOME/Arduino

echo "Installing via 'curl'"
# https://arduino.github.io/arduino-cli/0.20/installation/
/usr/bin/time curl -fsSL \
  https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh \
  | BINDIR=~/.local/bin sh \
  > $LOGFILE 2>&1

echo "Creating fresh configuration file"
# https://arduino.github.io/arduino-cli/0.20/getting-started/
arduino-cli config init --overwrite

echo "Updating index"
arduino-cli core update-index

echo "Listing connected boards"
arduino-cli board list

echo "Installing bash completion file"
arduino-cli completion bash > /tmp/ardunio-cli.sh
sudo mv /tmp/ardunio-cli.sh /etc/bash_completion.d/ardunio-cli.sh

echo "Installing zsh completion file"
arduino-cli completion zsh > /tmp/_arduino-cli.sh
sudo mv /tmp/_arduino-cli.sh /usr/share/zsh/vendor-completions/_arduino-cli

echo "Installing Arduino MBED RP2040 core"
arduino-cli core install arduino:mbed_rp2040

# https://arduino-pico.readthedocs.io/en/latest/install.html#installing-via-git
echo "Installing Arduino Pico from GitHub"
mkdir -p ~/Arduino/hardware/pico
/usr/bin/time git clone https://github.com/earlephilhower/arduino-pico.git ~/Arduino/hardware/pico/rp2040 \
  >> $LOGFILE 2>&1

pushd ~/Arduino/hardware/pico/rp2040
  /usr/bin/time git submodule update --init \
    >> $LOGFILE 2>&1
  cd pico-sdk
  /usr/bin/time git submodule update --init \
    >> $LOGFILE 2>&1
  cd ../tools
  /usr/bin/time python3 ./get.py \
    >> $LOGFILE 2>&1
popd

echo "Listing RP2040 / RP2350 boards to arduino-boards.log"
arduino-cli board search rp2040 > arduino-boards.log

echo "Finished"
