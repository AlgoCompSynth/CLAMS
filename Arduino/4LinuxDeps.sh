#! /usr/bin/env bash

set -e

echo "Installing base packages"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get install -qqy --no-install-recommends \
  libasound2 \
  libatk-bridge2.0-0 \
  libgtk-3-0 \
  libnss3 \
  libsecret-1-0

./install-arduino-ide.sh

echo "Finished"
