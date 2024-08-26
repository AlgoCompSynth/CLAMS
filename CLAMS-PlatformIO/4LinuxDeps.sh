#! /usr/bin/env bash

set -e

echo "Installing Linux dependencies"
export DEBIAN_FRONTEND=noninteractive
/usr/bin/time sudo apt-get install -qqy --no-install-recommends \
  > 4LinuxDeps.log 2>&1

./Installers/install-arduino-cli.sh*

echo "Finished"
