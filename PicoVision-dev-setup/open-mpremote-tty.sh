#! /bin/bash

set -e

export DEVICE=`mpremote connect list | sed 's/ .*$//'`
echo $DEVICE
ls -al $DEVICE
echo "sudo chmod a+rw $DEVICE || true"
echo "in teo seconds"
sleep 10
sudo chmod a+rw $DEVICE || true
ls -al $DEVICE
