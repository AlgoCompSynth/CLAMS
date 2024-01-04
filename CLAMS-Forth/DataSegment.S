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

@ The CLAMS-Forth parameter stack grows from high addresses downwards. Register
@ `PSTOP` holds the top cell of the stack. The rest of the stack is in RAM, and
@ register `PT2ND` points to the second cell of the stack. CLAMS-Forth uses the
@ system stack for the return stack, so it uses PUSH and POP via the SP register.

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

@ the terminal buffer is a null-terminated string
.global _terminal_buffer
.set _terminal_buffer, .
        .rept _TERMBUF_MAX
        .byte 0
        .endr
.global _end_terminal_buffer
.set _end_terminal_buffer, .

@ the parsed word is a counted string
.global _parsed_word
.set _parsed_word, .
        .rept _WNAME_MAX + 1 @ reserve space for the count byte
        .byte 0
        .endr
.global _end_parsed_word
.set _end_parsed_word, .

@ user variables

@ current character index in parsing >IN
.global _input_cursor
.set _input_cursor, .
        .word 0

@ current number base
.global _number_base
.set _number_base, .
        .word 10

@ current source character address
.global _input_source
.set _input_source, .
        .word _terminal_buffer

@ current source character count
.global _input_source_chars
.set _input_source_chars, .
        .word 0

@ current source ID
.global _input_source_id
.set _input_source_id, .
        .word 0

@ current state
.global _input_state
.set _input_state, .
        .word 0

@ entry system stack pointer
@ This is SP upon entry at `CLAMS-Forth`. We use this to check for return stack
@ underflow before popping it, and for clearing the return stack.
.global _entry_system_stack_pointer
.set _entry_system_stack_pointer, .
        .word 0

@ user (writeable) dictionary
.global _user_dictionary_start
.set _user_dictionary_start, .
        .rept _USER_DICT_CELLS
        .word 0
        .endr
.global _user_dictionary_end
.set _user_dictionary_end, .

.global _end_data_space
.set _end_data_space, .

.global _data_space_bytes
.set _data_space_bytes, .
        .word _end_data_space - _start_data_space
