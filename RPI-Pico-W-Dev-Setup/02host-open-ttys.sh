#! /bin/bash

set -e

echo "This script must be run in host!!!"
export DEVICE="/dev/ttyA*"
echo "Choosing device $DEVICE"
ls -al $DEVICE
echo "Executing 'sudo chmod a+rw $DEVICE || true' in ten seconds!"
sleep 10
sudo chmod a+rw $DEVICE || true
ls -al $DEVICE
