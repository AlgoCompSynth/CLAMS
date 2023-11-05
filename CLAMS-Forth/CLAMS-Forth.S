/*

    ## License

    MIT License
    
    Copyright (c) 2023 M. Edward (Ed) Borasky
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.


    ## Requirements

    > "If you've seen one Forth, well, you've seen one Forth." ~ Unknown

    1. Compatibility with the Raspberry Pi Pico C/C++ SDK, drivers, and
    libraries: The ability to use the massive toolset the SDK and community
    open source projects provide is absolutely crucial to minimize developer
    time for complex projects. The USB and WiFi / Bluetooth stacks alone would
    take many months to duplicate in Forth. The primary reference for this
    is Stephen Smith's _RP2040 Assembly Language Programming_, and, of course
    the Raspberry Pi Pico C/C++ SDK documentation and GitHub example
    repositories.

    2. Optimized for speed: CLAMS-Forth will be written in RP2040 assembly
    and will provide an RP2040 assembler. CLAMS-Forth will use subroutine
    threading and will allow both calling and inlining `CODE` words
    written in assembly.

    3. Cooperative multitasking: The RP2040 has two cores, and each core has a
    divide coprocessor and two interpolators. In addition, the RP2040 has
    two programmable input / output (PIO) blocks. Cooperative multitasking
    is the Forth way to exploit this available concurrency and is
    well-supported by the SDK.

    4. An enhanced Forth virtual machine, providing registers for indexing and
    intermendiate results as defined in Stephen Pelc's "Updating the Forth
    virtual machine."

    5. A high-speed block floating point digital signal processing library.


    ## Desiderata

    1. Forth 2012 standard compatibility is a strong desire but not an absolute
    requirement. Most of the CORE word set and some of the CORE EXT word set
    will be implemented, but a few tricky or risky words will be omitted. The
    Search-Order and Programming-Tools word sets will be implemented.

    Custom word sets will be provided for cooperative multitasking, high-speed
    digital signal processing, and SDK / hardware access. ***All access to
    the hardware / system level operations will be performed via the SDK.***

    2. Portability to other boards with the RP2040 microcontroller is possible,
    but is not on the roadmap yet. As with CLAMS itself, the initial target is the
    Pimoroni PicoVision.

    3. Floating point support is desirable, but is a fairly low priority.
    Floating point arithmetic is convenient, and the RP2040 SDK provides
    optimized floating point libraries, but there's no hardware floating
    point arithmentic on the RP2040. So it's not obvious how useful
    this capability would be.


    ## Top-level design / architecture

    The top-level design / architecture are based on Dr. Chen-Hanson Ting's
    _eForth Overview_. A small number of primitive words are implemented
    in assembly, then the rest of the system is built in Forth on top of
    those words. 
*/

@ A Forth "Hello, World"

.thumb_func
.global main

main:
        @ initialize the hardware
	BL stdio_init_all

loop:
        @print "Ok"
	LDR R0, =Ok
	BL printf

        @ sleep for about 1/4 second
	@ MOV R0, #255
	@ BL sleep_ms

        @ loop forever
	B loop

.data
        .align 4
Ok:     .asciz "Ok\n"
