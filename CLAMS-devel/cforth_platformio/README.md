# Building `cforth` with PlatformIO

1. Run './1_setup.sh`. This will

    a. Removing the PlatformIO cache `$HOME/.platformio`.

    b. Create and activate a fresh virtual environment `$HOME/platformio_venv`.

    c. Install PlatformIO core in the environment with `pip`.

    d. List the supported boards to `board_list.txt`.

    e. Make a fresh clone of <https://github.com/MitchBradley/cforth.git> to
`$HOME/Projects/cforth`.

    f. Append `testing_platformio.ini` to `$HOME/Projects/cforth/platformio.ini`.

    g. Build the host `cforth`.

    h. Deactivate the virtual environment.

2.  Connect your board and put it in `BOOTSEL` mode. You should only
    have one board connected at a time.

    I have had intermittent issues with boards when connected by a USB
    hub or one of those USB-A to micro or USB-C adapters. If you have
    problems, connect with a known good USB cable directly to the host
    computer.

3.  Run the test with the script `./test_board.sh`. The parameters are

    a.  `PIO_ENVIRONMENT`: The environment from `platformio.ini` to
        use. The default is a Raspberry Pi Pico, `rpipico`.

    b.  `BOARD_TAG`: An optional board tag. The default is the empty
        string. The test script uses the name
        `${PIO_ENVIRONMENT}${BOARD_TAG}` for the `.log` and `.elf`
        files.

    For example, when I first tested the [Pimoroni Pico Plus
    2](https://shop.pimoroni.com/products/pimoroni-pico-plus-2?variant=42092668289107),
    which wasn't in the Arduino framework board list at the time, I used the
    command:

    ```
    ./test_board.sh generic_rp2350 "-pimoroni_pico_plus_2"
    ```

    which generated

    ```
    generic_rp2350-pimoroni_pico_plus_2.elf
    generic_rp2350-pimoroni_pico_plus_2.log
    ```

## What the `test_board.sh` script does

Aside from logging information possibly useful in troubleshooting, the
script does a `pio run` with the specified environment to build and
upload the `cforth` firmware to the board. It then fetches the firmware
`.elf` file from the build environment.

Finally, it lists the active "/dev/ttyACM*" and "/dev/ttyUSB*" TTYs.
This is almost always just `/dev/ttyACM0`, unless you have more than
one board connected or a board with a UART-to-USB bridge. If
all went well you can do `screen /dev/ttyACM0 115200`, do an `Enter`,
and receive the `cforth` `ok` prompt. I have not tested `cforth` itself
extensively yet, but `2 3 + . Enter` behaves as expected.
