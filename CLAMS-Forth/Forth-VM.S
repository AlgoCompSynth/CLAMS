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

.include "Symbol-Defs.S"

@ dictionary functions
.thumb_func
.global get_dict_start
get_dict_start:
        LDR r0, =_plus
        _EXIT

.thumb_func
.global get_dict_end
get_dict_end:
        LDR r0, =_dict_end
        _EXIT

_plus:
        _DICT_HEADER 1, "+"
        _ENTRY plus
        _BINARY ADD
        _EXIT

_minus:
        _DICT_HEADER 1, "-", _plus
        _ENTRY minus
        _BINARY SUB
        _EXIT

_star:
        _DICT_HEADER 1, "-", _minus
        _ENTRY star
        _BINARY MUL
        _EXIT

.set _dict_end, .

.data
.balign _cell, 0

@ The parameter stack
.set _stack_cells, 64
_stack_bottom:
        .rept _stack_cells
        .word 0
        .endr
.set _stack_top, .
