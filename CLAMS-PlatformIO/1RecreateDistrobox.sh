#! /usr/bin/env bash

set -e

echo "Creating distrobox"
distrobox assemble create --replace

echo "Finished"
