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

@ stack test code

@ parameter stack logic:

@ 1. The stack grows from low addresses upwards. Register `spnxt` points to the
@    next available cell. This allows pushing and fetching multiple cells with
@    `STM` and `LDM`.

@ 2. The whole stack, including the top cell, is stored in RAM. A *copy* of the
@    top cell is kept in register `tscpy`, and words that affect the stack must
@    make sure both RAM and the stack control registers have the correct values.

@ 3. Stack error checking will be implemented, but isn't at present. Life is too
@    short for a stack-based language to allow undetected stack errors! 

.include "SymbolDefs.S"

.thumb_func
.global clear_stack
clear_stack:
        LDR spnxt, =_stack_start
        _EXIT

.thumb_func
.global stkprint3
stkprint3:
        _NEST
        LDR r0, =_stack_format_3
        SUB spnxt, #_cell*3
        LDM spnxt!, {r1-r3}
        BL printf
        _UNNEST

.thumb_func
.global stkprint2
stkprint2:
        _NEST
        LDR r0, =_stack_format_2
        SUB spnxt, #_cell*2
        LDM spnxt!, {r1-r2}
        BL printf
        _UNNEST

.thumb_func
.global stkprint1
stkprint1:
        _NEST
        LDR r0, =_stack_format_1
        SUB spnxt, #_cell
        LDM spnxt!, {r1}
        BL printf
        _UNNEST

.thumb_func
.global push1
push1:
        STM spnxt!, {r0}
        MOV tscpy, r0 @ *copy* top of stack to tscpy
        _EXIT

.thumb_func
.global push2
push2:
        STM spnxt!, {r0-r1}
        MOV tscpy, r1 @ *copy* top of stack to tscpy
        _EXIT

.thumb_func
.global push3
push3:
        STM spnxt!, {r0-r2}
        MOV tscpy, r2 @ *copy* top of stack to tscpy
        _EXIT

_stack_format_3: .asciz "stack data: %x, %x, %x\n"
_stack_format_2: .asciz "stack data: %x, %x\n"
_stack_format_1: .asciz "stack data: %x\n"

.data
.balign _cell, 0

@ The parameter stack
.set _stack_cells, 64
_stack_start:
        .rept _stack_cells
        .word 0
        .endr
.set _stack_end, .
