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

*/

// C wrappers for Pico SDK functions

#include <stdio.h>
#include <stdbool.h>
#include "pico/stdlib.h"
#include "pico/stdio/driver.h"
#include "pico/stdio.h"
#include "pico/stdio_usb.h"
#include "pico/stdio_uart.h"
#include "hardware/divider.h"

// sleep for specified time in milliseconds
void sdk_sleep_ms(uint32_t ms) {
  sleep_ms(ms);
}

// terminal I/O
void sdk_enable_uart () {
  stdio_set_driver_enabled(&stdio_uart, true);
}

void sdk_disable_uart () {
  stdio_set_driver_enabled(&stdio_uart, false);
}

void sdk_enable_usb () {
  stdio_set_driver_enabled(&stdio_usb, true);
}

void sdk_disable_usb () {
  stdio_set_driver_enabled(&stdio_usb, false);
}

uint32_t timeout_us = 0xFFFFFFFF; // maximum timeout - about 71.6 minutes
int sdk_key () {
    int key = getchar_timeout_us(timeout_us) & 0x7F; // no funny stuff, SDK :-)
    return(key);
}

int sdk_emit(int character) {
    int code = putchar_raw(character);
    return(code);
}

// arithmetic
int32_t rem;
int32_t sdk_slash(int32_t dividend, int32_t divisor) {
    int32_t quotient = divmod_s32s32_rem (dividend, divisor, &rem)
    return(quotient)
}
int32_t sdk_mod(int32_t dividend, int32_t divisor) {
    int32_t quotient = divmod_s32s32_rem (dividend, divisor, &rem)
    return(rem)
}
