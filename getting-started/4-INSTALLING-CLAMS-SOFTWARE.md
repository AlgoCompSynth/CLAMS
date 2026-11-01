# Installing the CLAMS Software

## First headless connection

From here on out, I'm going to assume the worst case - a Raspberry Pi
Zero 2 W with only a headless wireless connection. You probably have a
better setup and can skip the parts that don't apply.

When you first connected to the Pi, it was running software that
identified it as `alpine-headless.local`. The package that did that is
not on the system that `setup-alpine` created.

So unless you configured your network with known names and IP addresses
or your router is smart enough to do that for you, you will need to know
the IP address of your Raspberry Pi. For this exercise I'll use
`egret.local` which is at `192.168.1.15`.

```
❯ ssh 192.168.1.15
The authenticity of host '192.168.1.15 (192.168.1.15)' can't be established.
ED25519 key fingerprint is: SHA256:yXvqRcUrYCreaIjHskgFr4btqKwBhiHUTd/QRIS+2o8
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.1.15' (ED25519) to the list of known hosts.
znmeb@192.168.1.15's password: 
Welcome to Alpine!

The Alpine Wiki contains a large amount of how-to guides and general
information about administrating Alpine systems.
See <https://wiki.alpinelinux.org/>.

You can setup the system with the command: setup-alpine

You may change this message by editing /etc/motd.

egret:~$ 
```

## Installing `git` and cloning the repository

As I noted earlier, the first install is quite minimal. Not only does it
not identify itself on the LAN, it doesn't have some vital tools
installed. Like `git`!! So:

```
egret:~$ doas apk add --quiet git
doas (znmeb@egret.local) password: 
egret:~$ 
```

You'll probably want to fork this repository and set up a full development
environment, but for now just clone the repository and install the software.

```
egret:~$ mkdir -p Projects
egret:~$ cd Projects/
egret:~/Projects$ git clone --quiet https://github.com/AlgoCompSynth/CLAMS.git
egret:~/Projects$ cd CLAMS/alpine-setup
egret:~/Projects/CLAMS/alpine-setup$ 
```

## Updating and installing the command line

```
egret:~/Projects/CLAMS/alpine-setup$ ls
1-command-line.sh    README.md            nvim                 set-envars.sh        startup-code.sh
2-audio-plumbing.sh  bash-aliases.sh      profile              sizing-notes.md      tmux.conf
3-faust.sh           faust-version.txt    repositories         starship.toml
egret:~/Projects/CLAMS/alpine-setup$
```

The three scripts that install CLAMS are numbered. We start with
`./1-command-line.sh`:

```
egret:~/Projects/CLAMS/alpine-setup$ ./1-command-line.sh 
....Setting up home directories
....Creating logfile
....Switching to edge release with tagged @testing!
doas (znmeb@egret.local) password: 
```

Enter your password here.

```
....Upgrading if needed
....Adding packages
....Setting up udev
 * Caching service dependencies ...                                                                                                        [ ok ]
 * Starting udev ...                                                                                                                       [ ok ]
 * Generating a rule to create a /dev/root symlink ...                                                                                     [ ok ]
 * Populating /dev with existing devices through uevents ...                                                                               [ ok ]
 * Waiting for uevents to be processed ...                                                                                                 [ ok ]

....Setting up services for next reboot
 * service avahi-daemon added to runlevel default
 * /run/dbus: creating directory
 * /run/dbus: correcting owner
 * Starting System Message Bus ...                                                                                                         [ ok ]
 * Starting avahi-daemon ...                                                                                                               [ ok ]
 * service dbus added to runlevel default
 * WARNING: dbus has already been started

....Changing znmeb shell to /bin/bash
....Setting startup dotfiles
....Appending startup code to /home/znmeb/.profile
....Appending bash aliases to /home/znmeb/.bashrc
....Setting neovim configuration files
....Setting tmux configuration file
....Setting starship configuration file
....Appending starship init to /home/znmeb/.bashrc
....Indexing man pages
....Updating plocate database


....Command line setup complete - reboot!
....Finished

egret:~/Projects/CLAMS/alpine-setup$ 
```

Notes:
1. We have switched from the stable base Alpine repository to the `edge`
rolling release and added the `community` and `testing` packages.
2. I'm a big fan of including documentation on command-line systems. So
these scripts install `man` pages for everything they install that has
them.
3. The `avahi-daemon` is the missing package that identifies the system
as `egret.local`. That will work now.
4. The reboot is necessary because some low-level packages have been
upgraded and need to be restarted from a fresh boot.

```
egret:~/Projects/CLAMS/alpine-setup$ doas reboot
doas (znmeb@egret.local) password: 
egret:~/Projects/CLAMS/alpine-setup$ Connection to 192.168.1.15 closed by remote host.
Connection to 192.168.1.15 closed.
```


## Installing the audio plumbing
We start with `ssh egret,local`. As promised, the name works now!

```
❯ ssh egret.local
The authenticity of host 'egret.local (fe80::2ecf:67ff:fea8:9bb5%wlo1)' can't be established.
ED25519 key fingerprint is: SHA256:yXvqRcUrYCreaIjHskgFr4btqKwBhiHUTd/QRIS+2o8
This host key is known by the following other names/addresses:
    ~/.ssh/known_hosts:6: 192.168.1.15
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'egret.local' (ED25519) to the list of known hosts.
znmeb@egret.local's password: 
Welcome to Alpine!

The Alpine Wiki contains a large amount of how-to guides and general
information about administrating Alpine systems.
See <https://wiki.alpinelinux.org/>.

You can setup the system with the command: setup-alpine

You may change this message by editing /etc/motd.

 * Caching service dependencies ...                                                                                                        [ ok ]

znmeb in  egret in ~
```

That last line is what the Starship prompt generator and nerd fonts do
for you. You'll see more shortly.

Go back to the installers:

```
❯ cd Projects/CLAMS/alpine-setup/

znmeb in  egret in CLAMS/alpine-setup on  v0.7.5 
❯ 
```

You now know who you are, what machine you're in, what directory, that
you're in a `git` repository, and what branch you're on! Now the audio
plumbing:

```
❯ ./2-audio-plumbing.sh 
....Creating logfile
....Adding packages
doas (znmeb@egret.local) password: 

....Setting up services for next reboot
 * service pipewire added to runlevel console
 * service pipewire-pulse added to runlevel console
 * service wireplumber added to runlevel console
 * service bluetooth added to runlevel default
 * Caching service dependencies ...                                                                                                        [ ok ]
 * Starting Bluetooth ...                                                                                                                  [ ok ]

....Enabling ALSA sequencer
snd-seq
....Adding znmeb to the pipewire and rtkit groups
....Indexing man pages
....Updating plocate database
....Log out and back in again to start user services
....Finished
```
Log out and back in again:

```
❯ exit
logout
Connection to egret.local closed.

~ took 15m7s 
❯ ssh egret.local
znmeb@egret.local's password: 
Welcome to Alpine!

The Alpine Wiki contains a large amount of how-to guides and general
information about administrating Alpine systems.
See <https://wiki.alpinelinux.org/>.

You can setup the system with the command: setup-alpine

You may change this message by editing /etc/motd.

 * Caching service dependencies ...                                                                                                        [ ok ]
 * Starting Login Message Bus ...                                                                                                          [ ok ]
 * Starting wireplumber ...                                                                                                                [ ok ]
 * Starting pipewire ...                                                                                                                   [ ok ]
 * Starting pipewire-pulse ...                                                                                                             [ ok ]

```

## Installing Faust

```
znmeb in  egret in ~ 
❯ cd Projects/CLAMS/alpine-setup/

znmeb in  egret in CLAMS/alpine-setup on  v0.7.5 
❯ ./3-faust.sh 
....Creating logfile
....Adding packages
doas (znmeb@egret.local) password: 
....Listing Faust version
....Indexing man pages
....Updating plocate database
....Finished

```
