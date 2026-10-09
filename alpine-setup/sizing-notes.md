# RAM Usage

## Alpine base - Raspberry Pi Zero 2 W

- OS + mDNS + NetworkManager + PipeWire + WirePlumber + rtkit

    ❯ free -h
                  total        used        free      shared  buff/cache   available
    Mem:         415.7M       61.6M      143.9M      648.0K      210.2M      343.1M
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


