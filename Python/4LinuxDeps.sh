#! /usr/bin/env bash

set -e

echo "Installing Linux dependencies"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get install -qqy --no-install-recommends \
  thonny

echo "Finished"
