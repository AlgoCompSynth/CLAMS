#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ./SetEnvars.sh

echo ""
echo "Removing any existing distrobox container $DBX_CONTAINER_NAME"
distrobox rm --force $DBX_CONTAINER_NAME

echo "Removing any existing distrobox home directory $DBX_CONTAINER_DIRECTORY"
rm -rf $DBX_CONTAINER_DIRECTORY

echo "Pulling $DBX_CONTAINER_IMAGE"
podman pull $DBX_CONTAINER_IMAGE

echo "Creating distrobox $DBX_CONTAINER_NAME"
distrobox create \
  --image $DBX_CONTAINER_IMAGE \
  --name $DBX_CONTAINER_NAME \
  --hostname $DBX_CONTAINER_HOSTNAME \
  --pull \
  --home $DBX_CONTAINER_DIRECTORY \
  --additional-packages "systemd libpam-systemd" \
  --additional-packages "apt-file git-lfs lsb-release lynx pciutils plocate software-properties-common time tree vim-nox zsh" \
  --init

echo ""
echo "Entering $DBX_CONTAINER_NAME"
distrobox enter "$DBX_CONTAINER_NAME"
