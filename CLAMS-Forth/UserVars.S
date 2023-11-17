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
        .macro _USER_VARIABLE name:req, default=0
        .global \name
        .set \name, .
        .word \default
        .endm

@ String buffers
        .macro _STRING_BUF name:req

        @ make the buffer
        .global \name
        .set \name, .
        .rept 256
        .byte 0
        .endr

        @ routines to get address and length
        .set \name\()_addr, .
        .global \name\()_addr
        .thumb_func
        LDR r0, =\name
        _EXIT
        .set \name\()_max, .
        .global \name\()_max
        .thumb_func
        MOV r0, #255
        _EXIT
        .endm

_STRING_BUF _inbuf @ terminal input read here
