# RAM Usage

## Alpine base - two bash sessions

- Just the OS - wired:

    ❯ free -h
                  total        used        free      shared  buff/cache   available
    Mem:         415.7M       45.1M      108.9M      340.0K      261.7M      360.0M
    Swap:             0           0           0

- Podman hosting "alpine-edge-testing":

    ❯ free -h
                  total        used        free      shared  buff/cache   available
    Mem:         415.7M       72.1M       92.4M      356.0K      251.2M      333.0M
    Swap:             0           0           0

## Raspberry Pi OS Lite base - two bash sessions


- Just the OS - wired:

    $ free -h
                   total        used        free      shared  buff/cache   available
    Mem:           415Mi       152Mi        81Mi       2.5Mi       235Mi       262Mi
    Swap:          414Mi          0B       414Mi

- Podman hosting "alpine-edge-testing":

    $ free -h
                   total        used        free      shared  buff/cache   available
    Mem:           415Mi       178Mi       140Mi       884Ki       148Mi       236Mi
    Swap:          414Mi        20Mi       394Mi
