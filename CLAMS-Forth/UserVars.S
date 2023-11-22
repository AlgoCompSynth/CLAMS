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

@ User variables

        .macro _USER_VARIABLE name:req, value=0

        @ make the variable
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

@ String buffers
        .macro _STRING_BUF name:req, length=128

        @ make the buffer
        .set \name, .
        .rept \length
        .byte 0
        .endr

        @ functions to get address and length
        .global \name\()_addr
        .thumb_func
        .set \name\()_addr, .
        LDR r0, =\name
        _EXIT
        .global \name\()_length
        .thumb_func
        .set \name\()_length, .
        LDR r0, =\length
        _EXIT
        .endm

_STRING_BUF _inbuf @ terminal input read here
