#! /usr/bin/env bash

set -e

echo "Updating packages"
rpm-ostree upgrade \
  2>&1 | tee 3_upgrades.log

echo "Updating locate database"
sudo updatedb > /dev/null 2>&1

echo "Updating manual database"
sudo mandb > /dev/null 2>&1

echo "Finished"
