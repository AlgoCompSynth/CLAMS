#! /usr/bin/env bash

set -e

echo "Updating package lists"
sudo apt-get update -qq
echo "Upgrading"
sudo apt-get upgrade -qqy > unminimize.log 2>&1
echo "Unminimizing"
sudo touch /etc/dpkg/dpkg.cfg.d/excludes
echo "Y" | sudo unminimize >> unminimize.log 2>&1
