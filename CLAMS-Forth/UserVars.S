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

.include "SymbolDefs.S"

@ data segment!
.data

@ User variables

        .macro _USER_VARIABLE name:req, value=0

        @ make the variable
        .balign _CELL
        .set \name, .
        .word \value

        @ address getter function
        .global \name\()_addr
        .thumb_func
        .set \name\()_addr, .
        LDR r0, =\name
        _EXIT
        .endm

_USER_VARIABLE _base, 10 @ base for numeric input/output
_USER_VARIABLE _to_in, 0 @ parsing pointer

@ String buffers

@ String buffers store counted strings. The first byte is the count, second and 
@ succeeding characters are data, and buffers are initialized with zeroes. String
@ buffers have four methods:

@ an `_addr` method, which returns the address of the first (count) byte of the
@ buffer,

@ a `_maxl` method, which returns the length of @ the buffer minus 1,

@ a `_count` method, which sets the count byte to the correct count of the rest
@ of the buffer,

@ and an `_init` method, which sets the whole buffer to zeroes.

        .macro _STRING_BUF name:req, maxl=255

        @ make the buffer
        .balign _CELL
        .set \name, .
        .rept \maxl + 1
        .byte 0
        .endr

        @ getter / setter functions
        .global \name\()_addr
        .thumb_func
        .set \name\()_addr, .
        LDR r0, =\name
        _EXIT

        .global \name\()_maxl
        .thumb_func
        .set \name\()_maxl, .
        MOV r0, #\maxl
        _EXIT

        .global \name\()_init
        .thumb_func
        .set \name\()_init, .
        MOV r3, #0 @ count
        LDR r2, =\name @ address
        MOV r0, #0 @ and a zero to store

1:
        STRB r0, [r2, r3]
        ADD r3, #1
        CMP r3, #\maxl
        BLE 1b
        _EXIT

        .global \name\()_count
        .thumb_func
        .set \name\()_count, .
        MOV r3, #0 @ count
        LDR r2, =\name @ address
        ADD r2, #1

1:
        LDRB r0, [r2, r3] @ get the character
        CMP r0, #0
        BEQ 2f @ we're done if it's zero
        ADD r3, #1 @ count the character
        CMP r3, #\maxl @ have we hit the end?
        BLT 1b @ not at end - keep going

2:
        LDR r2, =\name @ get the buffer address back
        STRB r3, [r2] @ save the count
        _EXIT

        .endm

_STRING_BUF _tib @ terminal input read here
_STRING_BUF _searching_for @ the word we're trying to find in the dictionary
