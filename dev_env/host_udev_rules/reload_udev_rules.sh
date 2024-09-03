#! /usr/bin/env bash

set -e

echo "Reloading"
sudo udevadm control --reload-rules
sudo udevadm trigger
