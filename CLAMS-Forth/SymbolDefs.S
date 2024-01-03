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

@ Inner interpreter registers
@ These are the conventional indirect threading registers - see "Moving Forth".
@ SDK functions save these if they are used.
PT2ND .req r7 @ Pointer to second cell of parameter stack
WORDR .req r6 @ "Word" register
INTPR .req r6 @ Interpreter pointer - the Forth VM's program counter
PSTOP .req r4 @ Top cell of the parameter stack

@ Working registers in code words
@ SDK functions do not save them and neither do CLAMS-Forth words.
CTMAX .req r3 @ used in character loops
ADDRS .req r2 @ used in character loops
COUNT .req r1 @ used in character loops

@ Temporary storage registers
@ SDK functions save these if they use them. They're less useful than r0 - r7,
@ but they're faster than going to RAM. CLAMS-Forth words do *not* save them.
TEMP1 .req r8
TEMP2 .req r9
TEMP3 .req r10
TEMP4 .req r11

@ symbols for addressing expressions
@ reference: Forth 2012 standard, section D2.2
@ For the RP2040 SDK, an address unit is 8 bits aka a byte, and addressing is
@ little-endian. We use "character" and "byte" interchangeably at times without any
@ apologies.
.set _AU_CHAR, 1 @ address units per character
.set _AU_HALF, 2 @ address units per halfword
.set _AU_CELL, 4 @ address units per cell
.set _AU_CELL_CHAR, 5 @ address units cell plus a character
.set _CELL_SHIFT, 2 @ bits to shift for cell - address unit conversions
.set _HALF_SHIFT, 1 @ bits to shift for halfword - address unit conversions
.set _STACK_CELLS, 64 @ number of cells in a stack
.set _CSTRING_MAX, 255 @ maximum number of characters in a counted string
.set _WNAME_MAX, 31 @ maximum number of characters in a word name
.set _TERMBUF_MAX, 84 @ maximum number of characters in a terminal buffer line
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
