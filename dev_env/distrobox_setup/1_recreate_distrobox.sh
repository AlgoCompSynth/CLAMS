#! /usr/bin/env bash

set -e

echo "Creating distrobox"
distrobox assemble create --replace

echo "Entering CLAMS_dev_env - you do *not* have to type the above command!"
echo "This will take some time - it is downloading and installing basic packages."
distrobox enter CLAMS_dev_env
