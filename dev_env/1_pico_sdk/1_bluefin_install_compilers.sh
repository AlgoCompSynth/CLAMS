#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars

./install_arm_compiler.sh*
./install_risc_v_compiler.sh*

echo "Finished"
