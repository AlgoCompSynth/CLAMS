# `alpine-setup Walkthrough

## Headless setup

You can skip this section if your Pi is connected to a monitor, keyboard
and mouse. Otherwise, I'm assuming your setup is like mind - connecting
to the Pi over a local area network from another computer. Skip to
"Running `setup-alpine`" below.

### Terminal emulators / "nerd fonts"

As of about a year ago, all of my systems are running Linux. If you're
on Windows, MacOS, a ChromeBook, tablet or phone, you may have to do
some research.

Linux desktops have one or more terminal emulators. In a terminal
emulator, you can usually choose the fonts that look best. But there is
a class of fonts called "nerd fonts" that have some extra features and
glyphs for programmers. The whole catalog can be found at
<https://www.nerdfonts.com>.

The CLAMS command line uses the [Starship](https://starship.rs/)
prompt generator. While it will work without a nerd font, some features
may be missing or look weird. The one I use is "CaskaydiaCove", which
includes ligatures. The CaskaydiaCove font will be installed on the
CLAMS system, so you can copy it over to your host computer.

### Booting up the Raspberry Pi

If the Pi has both a wired and wireless network interface, running
wired is probably the best option, but this will work if only wireless
is available. So connect to a wired port if you can.

Insert the SD card or USB drive in the Pi, connect a power supply and
boot it up. This example uses a Raspberry Pi Zero 2 W in an enclosure
with an added wired Ethernet port, and both are active, so you will
see the setup dialogs for them.

### Connecting via Secure Shell (ssh)

You will need a secure shell client to connect to the headless Alpine
system. This is probably already installed on your system.

In your terminal emulator, type `ssh root@alpine-headless.local`. You
should see something like this:

```
❯ ssh root@alpine-headless.local
The authenticity of host 'alpine-headless.local (fe80::2ecf:67ff:fea8:9bb5%wlo1)' can't be established.
ED25519 key fingerprint is: SHA256:CMgId+Y8zD5tFBSg82djiFFPojWV/Y4Od6FXYHIrIBE
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'alpine-headless.local' (ED25519) to the list of known hosts.

Alpine Linux headless bootstrap v2.0 by macmpi

You may want to delete/rename .apkovl file before reboot (remount partition rw!):
/media/mmcblk0p1/headless.apkovl.tar.gz
(can be done automatically with unattended script - see sample snippet)


Welcome to Alpine!

The Alpine Wiki contains a large amount of how-to guides and general
information about administrating Alpine systems.
See <https://wiki.alpinelinux.org/>.

You can setup the system with the command: setup-alpine

You may change this message by editing /etc/motd.

alpine-headless:~#
```

If that doesn't work, check your router's display of connected systems.
You should see `alpine-headless` or `ALPINE-HEADLESS` and an IP address
the router assigned it. If you do, do `ssh root@<the-ip-address>`.

For example, on my system, the wired interface is at `192.168.1.10` and
the wireless interface is at `192.168.1.15`. Either one will work. If
you can't connect by name and you can't connect by IP address, you will
need to set up a monitor, keyboard and mouse and set up networking first.

## Running `setup-alpine`

If you're connected to a monitor, keyboard and mouse, log in as `root`
with no password. You should see this:

```
Welcome to Alpine!

The Alpine Wiki contains a large amount of how-to guides and general
information about administrating Alpine systems.
See <https://wiki.alpinelinux.org/>.

You can setup the system with the command: setup-alpine

You may change this message by editing /etc/motd.

alpine-headless:~#
```

### Hostname

Enter `setup-alpine`.

```
alpine-headless:~# setup-alpine


 ALPINE LINUX INSTALL
----------------------

 Hostname
----------
Enter system hostname (fully qualified form, e.g. 'foo.example.org') [alpine-headless] egret.local
```

The system will be called `egret` on the `.local` domain. You can use
any name you want but the domain should be `.local`.

### Network interfaces

How you set these up will depend on your local area network
configuration. I have two interfaces and use DHCP for both IPV4 and
IPV6.

```
 Interface
-----------
Available interfaces are: eth0 wlan0.
Enter '?' for help on bridges, bonding and vlans.
Which one do you want to initialize? (or '?' or 'done') [eth0] 
IPv4 address for eth0? (or 'dhcp', 'none', '?') [192.168.1.10/24] dhcp
IPv6 address for eth0? (or 'auto', 'dhcp', 'none', '?') [fe80::9c82:80ff:fedb:2dcb/64] dhcp
Available interfaces are: wlan0.
Enter '?' for help on bridges, bonding and vlans.
Which one do you want to initialize? (or '?' or 'done') [wlan0] 
Available wireless networks (scanning):

. . .

12) xxxxxx

. . .

Type the wireless network name to connect to: 12
Type the "xxxxxx" network Pre-Shared Key (will not echo): 
 * WARNING: wpa_supplicant has already been started
IPv4 address for wlan0? (or 'dhcp', 'none', '?') [192.168.1.15/24] dhcp
IPv6 address for wlan0? (or 'auto', 'dhcp', 'none', '?') [fe80::2ecf:67ff:fea8:9bb5/64] dhcp
Do you want to do any manual network configuration? (y/n) [n] n

```

The wireless interface `wlan0` setup scanned and found my network as
number 12, so that's what I entered.

### Root password

```
 Root Password
---------------
Changing password for root
New password: 
Retype password: 
passwd: password for root changed by root
```

### Time zone

```
 Timezone
----------
Africa/            CST6CDT            Etc/               Greenwich          Kwajalein          PRC                UCT
America/           Canada/            Europe/            HST                Libya              PST8PDT            US/
Antarctica/        Chile/             Factory            Hongkong           MET                Pacific/           UTC
Arctic/            Cuba               GB                 Iceland            MST                Poland             Universal
Asia/              EET                GB-Eire            Indian/            MST7MDT            Portugal           W-SU
Atlantic/          EST                GMT                Iran               Mexico/            ROC                WET
Australia/         EST5EDT            GMT+0              Israel             NZ                 ROK                Zulu
Brazil/            Egypt              GMT-0              Jamaica            NZ-CHAT            Singapore          leap-seconds.list
CET                Eire               GMT0               Japan              Navajo             Turkey             posixrules

Which timezone are you in? (or '?' or 'none') [UTC] PST8PDT
```

I'm in USA Pacific, sometimes shown as `America/Los_Angeles`.

### Proxy

```
 Proxy
-------
HTTP/FTP proxy URL? (e.g. 'http://proxy:8080', or 'none') [none] none
```

Unless you have a reason to change this, use the default `none`.


### Network time protocal

```

 Network Time Protocol
-----------------------
Sun Jun 14 05:45:16 PDT 2026
Which NTP client to run? ('busybox', 'openntpd', 'chrony' or 'none') [busybox] 
```

The default, `busybox` is fine. Just `Enter` to accept the default.

### APK mirror

```
 APK Mirror
------------
 (f)    Find and use fastest mirror
 (s)    Show mirrorlist
 (r)    Use random mirror
 (e)    Edit /etc/apk/repositories with text editor
 (c)    Community repo enable
 (skip) Skip setting up apk repositories

Enter mirror number or URL: [1] 1
```

Just enter the default `1`. The CLAMS install scripts will change this.

### User and SSH server

```
 User
------
Setup a user? (enter a lower-case loginname, or 'no') [no] znmeb
Full name for user znmeb [znmeb] 
Changing password for znmeb
New password: 
Retype password: 
passwd: password for znmeb changed by root
Enter ssh key or URL for znmeb (or 'none') [none] 
(1/1) Installing doas (6.8.2-r8)
Executing busybox-1.37.0-r31.trigger
OK: 19.8 MiB in 36 packages
Which ssh server? ('openssh', 'dropbear' or 'none') [openssh]
```

You need to create an administrative user with `doas` privileges. `doas`
is Alpine's way of changing to the super-user; it's something like
`sudo` on other Linux systems.

The `openssh` server is fine; just `Enter` to accept the default.

### Disk and install

This last section can be tricky; you'll need to be a bit careful.

```
 Disk & Install
----------------
No disks available. Try boot media /media/mmcblk0p1? (y/n) [n] y
```
Note that the default is `n`. You need to enter `y` here or the system
will not be installed to the SD card. Note also that the name will be
different if you booted a USB drive!

```
 * WARNING: you are stopping a sysinit service
 * Caching service dependencies ...                                                                                                        [ ok ]
 * Unmounting /.modloop ...                                                                                                                [ ok ]
Available disks are:
  mmcblk0       (62.3 GB  )

Which disk(s) would you like to use? (or '?' for help or 'none') [none] mmcblk0
```

Again, the default is not what you want. Enter the name of the available
disk, which is `mmcblk0` in this case.

```
The following disk is selected:
  mmcblk0       (62.3 GB  )

How would you like to use it? ('sys', 'data', 'crypt', 'lvm' or '?' for help) [?] sys
```

Enter `sys` here. This will set up a standard bootable Alpine Linux
system on the SD card.

```
WARNING: opening /media/mmcblk0p1/apks/aarch64/APKINDEX.tar.gz: No such file or directory
* /usr/sbin/update-raspberrypi-bootloader: WARNING: no kernel found

WARNING: The following disk(s) will be erased:
  mmcblk0       (62.3 GB  )

WARNING: Erase the above disk(s) and continue? (y/n) [n] y
```

Yes, you want to erase the disk and install! Enter `y`.

```
Partition #1 contains a vfat signature.
Creating file systems...
mkfs.fat 4.2 (2021-01-31)
Installing system on /dev/mmcblk0p2:
WARNING: opening /media/mmcblk0p1/apks/aarch64/APKINDEX.tar.gz: No such file or directory
WARNING: opening /media/mmcblk0p1/apks/aarch64/APKINDEX.tar.gz: No such file or directory
* creating /boot/initramfs-rpi for 6.18.58-0-rpi
* /usr/sbin/update-raspberrypi-bootloader: INFO: replaced config.txt and saved config.txt.old, with following changes:
* --- /boot/config.txt.old
* +++ /boot/config.txt
* @@ -0,0 +1,9 @@
* +# do not modify this file as it will be overwritten on upgrade.
* +# create and/or modify usercfg.txt instead.
* +# https://www.raspberrypi.com/documentation/computers/config_txt.html
* +#
* +
* +kernel=vmlinuz-rpi
* +initramfs initramfs-rpi
* +arm_64bit=1
* +include usercfg.txt
* Configured kernel vmlinuz-rpi / initramfs-rpi

Installation is complete. Please reboot.
alpine-headless:~# 
```

Congratulations! You now have a minimal Alpine Linux system. As you will
see in the next part, it is really minimal. But the bulk of the typing
and decision points are done; scripts do most of the heavy lifting.
