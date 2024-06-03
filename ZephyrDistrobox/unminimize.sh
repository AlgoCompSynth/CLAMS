#! /usr/bin/env bash

set -e

sudo apt-get update -qq
sudo apt-get upgrade -qqy
sudo touch /etc/dpkg/dpkg.cfg.d/excludes
echo "Y" | sudo unminimize 2>&1 | tee unminimize.log
