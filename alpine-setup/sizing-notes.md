# RAM Usage

## Alpine base - Raspberry Pi Zero 2 W

- OS + Avahi + WiFi + Bluetooth + PipeWire + WirePlumber + rtkit

    ❯ free -h
                  total        used        free      shared  buff/cache   available
    Mem:         415.6M       65.1M      288.1M      640.0K       62.4M      339.6M
    Swap:             0           0           0

## Raspberry Pi OS Lite base - Raspberry Pi Zero 2 W


- OS + mDNS + NetworkManager

    $ free -h
                   total        used        free      shared  buff/cache   available
    Mem:           415Mi       152Mi        81Mi       2.5Mi       235Mi       262Mi
    Swap:          414Mi          0B       414Mi

## Armbian Forky minimal 

- OS + git + mDNS + NetworkManager

    $ free -h
                   total        used        free      shared  buff/cache   available
    Mem:           413Mi       149Mi       142Mi       1.8Mi       175Mi       264Mi
    Swap:          206Mi          0B       206Mi

## DietPi trixie

- OS + git + mDNS

    $ free -h
                   total        used        free      shared  buff/cache   available
    Mem:           462Mi        62Mi       161Mi       1.9Mi       250Mi       399Mi
    Swap:          1.5Gi          0B       1.5Gi
