# Media Preparation

## Raspberry Pi Imager

1. Download the latest Raspberry Pi GUI imager at
<https://www.raspberrypi.com/software/>.

2. Go through the menus. First, choose your board. On the next page,
"Choose operating system", select "Other general-purpose OS". On the
next page, select "Alpine Linux". On the next page, if you have a
choice, select 64-bit. Some of the packages CLAMS requires are not
present in 32-bit Alpine Linux.

3. Select your storage device, either an SD card or USB drive,
depending on your Pi system setup.

4. Write image.

If you Pi is connected to a keyboard, monitor and mouse you can proceed
to [./3-ALPINE-SETUP-WALKTHROUGH.md](./3-ALPINE-SETUP-WALKTHROUGH.md).
Otherwise, continue with the next steps below.

## Headless

1. Go to the [Headless Alpine Linux bootstrapping
scripts](https://github.com/macmpi/alpine-linux-headless-bootstrap)
GitHub repository.

2. Download the most recent `headless.apkovl.tar.gz` tarball. ***Do
not unpack it!***

3. Download the [`wpa_supplicant` wireless connection
file](https://github.com/macmpi/alpine-linux-headless-bootstrap/blob/main/contribs/wpa_supplicant.conf).

4. Edit this file for your network. You will need to set the `country`,
`ssid` and `psk` values for your router.

5. When you flashed Alpine Linux to the SD card or USB drive, the last
`Finish` step unmounted the written device. You will need to remount it
in read/write mode. The easiest way to do this is with your desktop's
file manager. There will be a partition labelled `PIBOOT`. That's the
one you want to mount.

6. Copy `headless.apkovl.tar.gz` and the edited `wpa_supplicant.conf`
to `PIBOOT` and unmount `PIBOOT`. You can now remove the SD card or
USB drive and plug it into your Raspberry Pi and proceed to
[./3-ALPINE-SETUP-WALKTHROUGH.md](./3-ALPINE-SETUP-WALKTHROUGH.md).
