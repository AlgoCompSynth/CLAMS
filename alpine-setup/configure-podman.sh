#! /bin/sh

set -eu

echo "....Configuring cgroups for $USER"
echo $USER:100000:65536 | doas tee /etc/subuid
echo $USER:100000:65536 | doas tee /etc/subgid

echo "....Finished"
echo ""
