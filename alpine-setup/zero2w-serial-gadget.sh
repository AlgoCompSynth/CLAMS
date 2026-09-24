#! /bin/sh

set -eu

# References:
# https://github.com/macmpi/xg_multi/wiki/Install

echo "....Setting up boot configuration"
echo "dtoverlay=dwc2,dr_mode=peripheral" | doas tee -a /boot/usercfg.txt
echo "ttyGS0::respawn:/sbin/getty -L 115200 ttyGS0 vt100" | doas tee -a /etc/inittab

echo "....Setting configuration files"
echo "....../etc/modules-load.d/gadget.conf"
doas cp gadget.conf /etc/modules-load.d/gadget.conf

echo "....Indexing man pages"
doas makewhatis

echo "....Updating plocate database"
doas updatedb

echo ""
echo ""
echo "....Setup complete - connect a host USB cable to the Zero 2 W USB port and reboot"
echo "....Console should be /dev/ttyGS0 on Zero 2 W and /dev/ttyACMn on a Linux host.
echo "....Baud rate is 112500."

echo "....Finished"
echo ""
