#! /bin/bash

set -e

openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 5000" &
