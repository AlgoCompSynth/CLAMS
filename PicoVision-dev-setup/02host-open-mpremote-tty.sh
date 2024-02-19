#! /bin/bash

set -e

echo "This script must be run in host!!!"
source mpremote/bin/activate
echo "mpremote device list"
mpremote connect list
export DEVICE=`mpremote connect list | sed 's/ .*$//'`
echo "Choosing device $DEVICE"
ls -al $DEVICE
echo "Executing 'sudo chmod a+rw $DEVICE || true' in ten seconds!"
sleep 10
sudo chmod a+rw $DEVICE || true
ls -al $DEVICE
