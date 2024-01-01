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

@ coding conventions:

@ 1. Names internal to the CLAMS system have a leading underscore and are restricted
@ to the character set of Arm GNU assembler symbols. Function names and variables
@ use only lower-case letters, constants use only upper case letters.

@ 2. Names intended to represent Forth words have the Forth syntax. Words that are 
@ defined in the Forth standard use only upper case letters and behave the same way
@ they do in the standard. Names created by the user can use either case and the
@ system is case-sensitive. Sorry, but if you want "DUP", you won't be able to type
@ "dup".

@ 3. Register usage: Pico SDK functions save registers r4 - r11, so we can use
@ them without saving. However, r8 - r11 have limited functionality - essentially
@ only source or destination of a MOV, one operand of an ADD or CMP, or to hold a
@ branch target.
@
@ Registers r0 - r3 are work registers and are used for SDK function parameters.
@ They are not saved / restored by default, either by the SDK or between CLAMS-Forth
@ words. Although the SDK allows more than four parameters, there are by design no
@ CLAMS-Forth functions that do so.
@
@ Inner interpreter registers
@ These are the conventional indirect threading registers - see "Moving Forth".
PS2 .req r7 @ Pointer to second cell of parameter stack
WRD .req r6 @ "Word" register
INP .req r6 @ Interpreter pointer - the Forth VM's program counter
TOS .req r4 @ Cached copy of the top cell of the parameter stack

@ working registers in code words
MAX .req r3 @ used in character loops
LOC .req r2 @ used in character loops
CNT .req r1 @ used in character loops

@ Temporary storage registers
@ SDK functions save these if they use them. They're less useful than r0 - r7,
@ but they're faster than going to RAM. CLAMS-Forth words do not save them.
TMP1 .req r8
TMP2 .req r9
TMP3 .req r10
TMP4 .req r11

@ symbols for addressing expressions
@ reference: Forth 2012 standard, section D2.2
@ For the RP2040 SDK, an address unit is 8 bits aka a byte, and addressing is
@ little-endian. We use "character" and "byte" interchangeably sometimes without any
@ apologies.
.set _AU_CHAR, 1 @ address units per character
.set _AU_HALF, 2 @ address units per halfword
.set _AU_CELL, 4 @ address units per cell
.set _CELL_SHIFT, 2 @ bits to shift for cell - address unit conversions
.set _HALF_SHIFT, 1 @ bits to shift for cell - address unit conversions
.set _STACK_CELLS, 64 @ number of cells in a stack
.set _MAX_CSTRING, 255 @ maximum number of characters in a counted string
.set _MAX_WNAME, 31 @ maximum number of characters in a word name
.set _MAX_TERMBUF, 84 @ maximum number of characters in a terminal buffer line
.set _USER_DICT_CELLS, 32768 @ about half of the RP2040 RAM!

@ character codes
.set _NUL, 0x00 @ null / string terminator
.set _BEL, 0x07 @ bell
.set _BS, 0x08 @ backspace
.set _LF, 0x0A @ line feed
.set _CR, 0x0D @ carriage return
.set _BL, 0x20 @ space
.set _K, 0x4B @ letter "K"
.set _O, 0x4F @ letter "O"
.set _DEL, 0x7F @ delete / rubout

@ flags = various bits about a dictionary word
.set _COMPILE_ONLY, 0x1 @ COMPILE-ONLY word
.set _IMMEDIATE, 0x2 @ IMMEDIATE word

@ get macro definitions
.include "DictMacros.S" @ dictionary construction macros
.include "VirtMachMacros.S" @ virtual machine macros
