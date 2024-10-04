#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Listing boards to board-listall.txt"
arduino-cli board listall > board-listall.txt

echo "Listing examples to examples.txt"
find $HOME/.arduino15/packages -name 'examples' \
  | sort -u \
  > examples.txt

echo "Finished"
