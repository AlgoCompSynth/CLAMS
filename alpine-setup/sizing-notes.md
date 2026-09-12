# RAM Usage

## Alpine base - two bash sessions

- Just the OS - wired: 

    ❯ free -h
              total        used        free      shared  buff/cache   available
    Mem:         415.7M       45.1M      108.9M      340.0K      261.7M      360.0M
    Swap:             0           0           0

- Podman hosting "alpine-edge-testing"

    ❯ free -h
              total        used        free      shared  buff/cache   available
    Mem:         415.7M       72.1M       92.4M      356.0K      251.2M      333.0M
    Swap:             0           0           0
