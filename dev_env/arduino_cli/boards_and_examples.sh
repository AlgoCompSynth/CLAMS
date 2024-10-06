#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Updating indexes"
arduino-cli update

echo "Listing cores to cores.txt"
arduino-cli core list --no-color > cores.txt

echo "Listing boards to boards.txt"
arduino-cli board listall --no-color > boards.txt

echo "Listing libraries to libraries.txt"
arduino-cli lib list --no-color > libraries.txt

echo "Listing examples to examples.txt"
arduino-cli lib examples --no-color > examples.txt

echo "Finished"
