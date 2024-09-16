# Building `cforth` for an RP2040 / RP2350 Board

1. Clone the `cforth` repository:

    ```
    ./1_clone_cforth.sh
    ```

    This will remove any existing `$HOME/Projects/cforth` and clone
    <https://github.com/MitchBradley/cforth.git>/ to
    `$HOME/Projects/cforth`. Note that this is the *container's* `$HOME`,
    not the host!

    Then the script will append the testing board definitions to
    `$HOME/Projects/cforth/platformio.ini`. This will provide
    definitions for the RP2350 boards that are not in the `cforth`
    source yet. Note that I currently only have definitions for
    boards that I actually own. Once some upstream releases are done
    I will add the other RP2350 boards to my definitions.

2. Build `cforth` for the host:

    ```
    ./1_host.sh
    ```

    This will remove all the cached files from `$HOME/.platformio` and
    `$HOME/Projects/cforth/.pio`, then build the required host Forth
    components. You only need to run this once unless you want to clear
    the caches again and start over.

3.  Connect your board and put it in `BOOTSEL` mode. You should only
    have one board connected at a time.

    I have had intermittent issues with boards when connected by a USB
    hub or one of those USB-A to micro or USB-C adapters. If you have
    problems, connect with a known good USB cable directly to the host
    computer.

4.  Look up your board in `raspberrypi-platform-boards.txt`. I have only
    included boards I have actually tested in `platformio.ini`, but if
    you have RP2040 / RP2350 boards that I don't have and want to test
    them, feel free to add an environment, or open an issue and I'll add
    it.

5.  Run the test with the script `./test_board.sh`. The parameters are

    a.  `PIO_ENVIRONMENT`: The environment from `platformio.ini` to
        use. The default is a Raspberry Pi Pico, `rpipico`.

    b.  `BOARD_TAG`: An optional board tag. The default is the empty
        string. The test script uses the name
        `${PIO_ENVIRONMENT}${BOARD_TAG}` for the `.log`, `.elf`, `.uf2`
        and `.dis` files.

    For example, when I first tested the [Pimoroni Pico Plus
    2](https://shop.pimoroni.com/products/pimoroni-pico-plus-2?variant=42092668289107),
    which wasn't in the Arduino framework board list at the time, I used the
    command:

    ```
    ./test_board.sh generic_rp2350 "-pimoroni_pico_plus_2"
    ```

## What the `test_board.sh` script does

Aside from logging information possibly useful in troubleshooting, the
script does a `pio run` with the specified environment to build and
upload the `cforth` firmware to the board. It then fetches the firmware
files from the build environment and creates a disassembly listing.

Finally, it lists the active `/dev/ttyACM*` TTYs. This is almost always
just `/dev/ttyACM0`, unless you have more than one board connected. If
all went well you can do `screen /dev/ttyACM0 115200`, do an `Enter`,
and receive the `cforth` `ok` prompt. I have not tested `cforth` itself
extensively yet, but `2 3 + . Enter` behaves as expected.

## Status / next steps

The current tests are using a pre-release platform,
<https://github.com/maxgerhardt/platform-raspberrypi.git>. This in turn
uses the ***released*** Arduino Pico framework,
<https://github.com/earlephilhower/arduino-pico/releases/tag/4.0.2>.
So this should all be considered alpha / expermental until the
PlatformIO `raspberrypi` platform is released with RP2350 support.

I have a fork of `cforth` with most of this code in a more complex
form. Once the upstream releases happen, I'm planning to submit a
pull request to get the new enviornment definitions in `cforth`,
plus the testing framework if they want it.
