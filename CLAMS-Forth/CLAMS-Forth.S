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

@ test harness for Forth VM

.include "MacroDefs.S"

.thumb_func
.global main

main:
	BL stdio_init_all

loop:
        LDR r0, =welcome
        BL printf
        LDR r0, =book
        BL printf
        LDR r0, =prompt
        BL printf

        BL CLAMS_Forth @ call CLAMS-Forth as a subroutine - 'BYE' returns!

        LDR r0, sleep_ms
        BL sdk_sleep_ms
        B loop

welcome: .asciz "\nWelcome to CLAMS-Forth!\n"
book: .asciz "https://algocompsynth.github.io/CLAMS/\n"
prompt: .asciz " Ok\n> "
.balign _AU_CELL, 0
sleep_ms: .word 1000
dupe: .word dupe @ link in the dictionary
