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

@ We put all of the data space into a single file, so we can manage it at assembly
@ time and know how much space it takes up. Unlike many Forths, CLAMS has ***no***
@ transient areas - all flash and RAM areas are allocated ahead of time with global
@ names the linker knows about. The only variable-sized data structure in CLAMS is
@ the data space portion of the dictionary - the part created by the user at run
@ time. And it has a pre-defined maximum size.

.include "MacroDefs.S"

.data
.balign _AU_CELL, 0

.global _start_data_space
.set _start_data_space, .

@ Stack logic:

@ The stacks grow from high addresses downwards. Register `PSP` points to the
@ top element of the parameter stack, and register `RSP` points to the top of the
@ return stack.


@ The stacks

@ parameter stack
.global _param_stack_top
.set _param_stack_top, .
        .rept _STACK_CELLS
        .word 0xdeadbeef
        .endr
.global _param_stack_bottom
.set _param_stack_bottom, .

        @ guard words
        .word 0xdeadbeef
        .word 0xdeadbeef
        .word 0xdeadbeef

@ return stack
.global _return_stack_top
.set _return_stack_top, .
        .rept _STACK_CELLS
        .word 0xdeadbeef
        .endr
.global _return_stack_bottom
.set _return_stack_bottom, .

        @ guard words
        .word 0xdeadbeef
        .word 0xdeadbeef
        .word 0xdeadbeef

@ the terminal buffer is a counted string
.global _terminal_buffer
.set _terminal_buffer, .
        .rept _MAX_TERMBUF + 1 @ reserve space for the count byte
        .byte 0
        .endr
.global _end_terminal_buffer
.set _end_terminal_buffer, .

@ the parsed word is a counted string
.global _parsed_word
.set _parsed_word, .
        .rept _MAX_WNAME + 1 @ reserve space for the count byte
        .byte 0
        .endr
.global _end_parsed_word
.set _end_parsed_word, .

.global _end_data_space
.set _end_data_space, .

.global _data_space_bytes
.set _data_space_bytes, _end_data_space - _start_data_space
