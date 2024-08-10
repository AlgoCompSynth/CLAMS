#! /usr/bin/env bash

set -e

export LOGFILE=$PWD/Logs/2_upgrade_gforth.log

./gforth-git-prep.sh \
  >> $LOGFILE 2>&1
./gforth-git-make.sh \
  >> $LOGFILE 2>&1

echo "Finished"
