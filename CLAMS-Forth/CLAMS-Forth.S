
@
@ UART echo server using the Pico SDK.
@ Reference: _RP2040 Assembly Language Programming_, Stephen Smith, Chapter 14
@
@ R0 - first parameter to printf
@ R1 - second parameter to printer
@ R7 - index counter
@

.thumb_func
.global main

main:

        @initialize UART0
loop:
        @wait for input character

        @for backspace, echo and emit a space

        @for CR, echo and emit a newline

        @for CTL-D, exit

        B loop
