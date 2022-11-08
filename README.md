Command Line Algorithmic Music System (CLAMS)
================
M. Edward (Ed) Borasky

> “I’ve never seen a happy clam. In fact, most of them were really
> steamed.” \~ M. Edward (Ed) Borasky

## What is this?

CLAMS is an interactive environment for composing and performing music
on a [Raspberry Pi Pico WH microcontroller
board](https://sbcshop.myshopify.com/products/raspberry-pi-pico-wh?variant=40047914090579).
This board costs about \$9US and includes soldered male headers, a
debugging connector, and a 2.4 GHz WiFi transceiver. CLAMS can be ported
to other boards that use the RP2040 microcontroller but I have no plans
to do so. To hear or record the music, you will need a [Pimoroni Pico
Audio
Pack](https://shop.pimoroni.com/products/pico-audio-pack?variant=32369490853971).

## How does it work?

CLAMS is a domain-specific language built on a Forth compiler /
interpreter. The user connects to the board, either by USB or a wireless
connection, and enters CLAMS / Forth code interactively.
