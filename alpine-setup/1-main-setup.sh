#! /bin/sh

set -eu

# References:
# https://wiki.alpinelinux.org/wiki/Eudev
# https://wiki.alpinelinux.org/wiki/How_to_get_regular_stuff_working 
# https://wiki.alpinelinux.org/wiki/MDNS
# https://wiki.alpinelinux.org/wiki/NetworkManager
# https://wiki.alpinelinux.org/wiki/OpenRC_User_Services#User_runlevels
# https://wiki.alpinelinux.org/wiki/Raspberry_Pi
# https://wiki.alpinelinux.org/wiki/Repositories
# https://wiki.alpinelinux.org/wiki/Shell_management

echo "....Setting up home directories"
mkdir --parents $HOME/.local/bin $HOME/Logfiles $HOME/Projects $HOME/.config/rc/runlevels/console

echo "....Creating logfile"
export LOGFILE=$HOME/Logfiles/command-line-base.log
echo "" > $LOGFILE

echo "....Switching to edge release with tagged @testing!"
diff repositories /etc/apk/repositories || true
doas cp repositories /etc/apk/repositories

echo "....Upgrading if needed"
doas apk upgrade

echo "....Adding packages"
doas apk add -vv \
    avahi \
    avahi-doc \
    avahi-tools \
    avahi2dns@testing \
    bash \
    bash-doc \
    bash-completion \
    bash-completion-doc \
    checkbashisms \
    curl \
    curl-doc \
    dbus \
    dbus-doc \
    doas-doc \
    doas-sudo-shim \
    doas-sudo-shim-doc \
    drill \
    file \
    git \
    git-doc \
    fenneljit \
    fennel-doc \
    htop \
    htop-doc \
    lua5.1 \
    lua5.1-doc \
    luajit \
    luajit-doc \
    lynx \
    lynx-doc \
    man-pages \
    mandoc \
    mandoc-doc \
    mandoc-apropos \
    mkrundir \
    neovim \
    neovim-doc \
    nerd-fonts-all \
    networkmanager \
    networkmanager-cli \
    networkmanager-dnsmasq \
    networkmanager-doc \
    networkmanager-tui \
    networkmanager-wifi \
    openssh-doc \
    openssl-doc \
    plocate \
    plocate-doc \
    raspberrypi-bootloader-doc \
    ripgrep \
    ripgrep-doc \
    shadow \
    shadow-doc \
    starship \
    time \
    time-doc \
    tree \
    tree-doc \
    wget \
    wget-doc \
    xdg-utils \
    xdg-utils-doc \
    >> $LOGFILE 2>&1

echo "....Setting up udev"
doas setup-devd udev

echo "....Setting configuration files"
echo "......NetworkManager.conf"
doas mkdir -p /etc/NetworkManager/
diff NetworkManager.conf /etc/NetworkManager/NetworkManager.conf || true
doas cp NetworkManager.conf /etc/NetworkManager/NetworkManager.conf

echo "......mdns.conf"
doas mkdir -p /etc/NetworkManager/dnsmasq.d/
diff mdns.conf /etc/NetworkManager/dnsmasq.d/mdns.conf || true
doas cp mdns.conf /etc/NetworkManager/dnsmasq.d/mdns.conf

echo "......resolvconf"
doas mkdir -p /etc/udhcpc/post-bound/resolvconf
diff resolvconf /etc/udhcpc/post-bound/resolvconf || true
doas cp resolvconf /etc/udhcpc/post-bound/resolvconf

echo ""
echo "....Setting up services for next reboot"
doas rc-update add avahi-daemon
doas rc-update add avahi2dns
doas rc-update add dbus
doas rc-update add networkmanager default
doas rc-update del networking boot || true
doas rc-update del wpa_supplicant boot || true
echo ""

echo "....Changing $USER shell to /bin/bash"
doas chsh --shell "/bin/bash" $USER

echo "....Adding $USER to the plugdev group"
doas adduser $USER plugdev

echo "....Setting startup dotfiles"
if [ "$(grep 'end startup code' $HOME/.profile 2> /dev/null | wc -l)" = "0" ]
then
    echo "....Appending startup code to $HOME/.profile"
    cat startup-code.sh >> $HOME/.profile

fi

if [ "$(grep 'end bash aliases' $HOME/.bashrc 2> /dev/null | wc -l)" = "0" ]
then
    echo "....Appending bash aliases to $HOME/.bashrc"
    cat bash-aliases.sh >> $HOME/.bashrc

fi

echo "....Setting neovim configuration files"
mkdir --parents $HOME/.config
cp -rp nvim $HOME/.config

echo "....Setting starship configuration file"
cp starship.toml $HOME/.config/

if [ "$(grep starship $HOME/.bashrc | wc -l)" = "0" ]
then
  echo "....Appending starship init to $HOME/.bashrc"
  echo "" >> $HOME/.bashrc
  echo 'eval "$(starship init bash)"' >> $HOME/.bashrc

fi

echo "....Updating plocate database"
doas updatedb

echo ""
echo ""
echo "....Setup complete - reboot"
echo "....WARNING! You will have to configure and enable wireless from a *wired* connection"

echo "....Finished"
echo ""
