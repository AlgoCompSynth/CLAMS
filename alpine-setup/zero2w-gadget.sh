#! /bin/sh

set -eu

# References:
# https://github.com/macmpi/xg_multi/wiki/Install

echo "....Creating logfile"
export LOGFILE=$HOME/Logfiles/zero2w-gadget.log
echo "" > $LOGFILE

echo "....Adding packages"
doas apk add -vv \
    xg_multi \
    xg_multi-doc \

echo "....Configuring usb0 network interface"
grep " lo " /etc/network/interfaces > /tmp/interfaces
cat usb0.iface >> /tmp/interfaces
grep -v " lo " /etc/network/interfaces >> /tmp/interfaces
diff /tmp/interfaces /etc/network/interfaces || true
doas cp /tmp/interfaces /etc/network/interfaces

echo "....Setting up boot configuration"
echo "dtoverlay=dwc2,dr_mode=peripheral" | doas tee -a /boot/usercfg.txt
echo "ttyGS0::respawn:/sbin/getty -L 115200 ttyGS0 vt100" | doas tee -a /etc/inittab

echo "....Setting configuration files"
echo "....../etc/conf.d/xg_multi"
diff xg_multi /etc/conf.d/xg_multi || true
doas cp xg_multi /etc/conf.d/xg_multi

echo "....../etc/modules-load.d/gadget.conf"
#doas cp gadget.conf /etc/modules-load.d/gadget.conf

echo ""
echo "....Setting up service for next reboot"
doas rc-update add xg_multi boot
echo ""


echo "....Indexing man pages"
doas makewhatis

echo "....Updating plocate database"
doas updatedb

echo ""
echo ""
echo "....Setup complete - connect a host USB cable to the Zero 2 W USB port and reboot"

echo "....Finished"
echo ""
