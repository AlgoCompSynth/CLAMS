#! /usr/bin/env bash

set -e

echo "Installing Linux dependencies"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get install -qqy --no-install-recommends \
  python3-dev \
  python3-pip \
  python3-tk \
  python3-venv

echo "Finished"
