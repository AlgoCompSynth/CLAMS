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

@ stack / dictionary test code

.thumb_func
.global clear_stack
clear_stack:
        LDR psptr, =_stack_start
        _EXIT

.thumb_func
.global print_top3
print_top3:
        _NEST
        LDR r0, =_stack_format_a
        SUB psptr, #_cell*4
_ldm:   LDM psptr!, {r1-r3}
        BL printf
_unnest:
        _UNNEST

.thumb_func
.global push1
push1:
        STM psptr!, {r0}
        MOV tostk, r0 @ *copy* top of stack to tostk
        _EXIT

.thumb_func
.global push2
push2:
        STM psptr!, {r0-r1}
        MOV tostk, r0 @ *copy* top of stack to tostk
        _EXIT

.thumb_func
.global push3
push3:
        STM psptr!, {r0-r3}
        MOV tostk, r0 @ *copy* top of stack to tostk
        _EXIT

_stack_format_a: .asciz "stack data: %x, %x, %x\n"

.data
.balign _cell, 0

@ The parameter stack
.set _stack_cells, 64
_stack_start:
        .rept _stack_cells
        .word 0
        .endr
.set _stack_end, .
