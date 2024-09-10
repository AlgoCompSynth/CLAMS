# Instructions

1. Connect an RP2350 device and put it in BOOTSEL mode.
2. Do an `lsusb`. You should see something like

```
Bus bbb Device aaa: ID 2e8a:000f Raspberry Pi RP2350 Boot
```

    The RP2350 device you are testing must be the only
    RP2xxx device on the system.

3. `source` the fully-qualified board name file for your
board. For example

```
source ./sparkfun_promicrorp2350.fqbn
```

4. Run `./PSRAMTest.sh`.
