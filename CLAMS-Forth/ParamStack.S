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

@ parameter stack logic:

@ The stack grows from high addresses downwards. Register `pt2nd` points to the
@ second element of the parameter stack. The top of the stack is stored in
@ register `pstop`.

.include "SymbolDefs.S"

.thumb_func
.global clear_stack
clear_stack:
        LDR pt2nd, =_stack_bottom
        _EXIT

.thumb_func
.global stkprint3
stkprint3:
        _NEST
        LDR r0, =_stack_format_3
        MOV r1, pstop
        LDM pt2nd, {r2, r3, pt2nd}
        BL printf
        _UNNEST

.thumb_func
.global stkprint2
stkprint2:
        _NEST
        LDR r0, =_stack_format_2
        MOV r1, pstop
        LDR r2, [pt2nd]
        BL printf
        _UNNEST

.thumb_func
.global stkprint1
stkprint1:
        _NEST
        LDR r0, =_stack_format_1
        MOV r1, pstop
        BL printf
        _UNNEST

_stack_format_3: .asciz "stack top => %x, %x, %x\n"
_stack_format_2: .asciz "stack top => %x, %x\n"
_stack_format_1: .asciz "stack top => %x\n"

@ The parameter stack itself
.data
.balign _cell, 0
.set _stack_cells, 64
_stack_start:
        .rept _stack_cells
        .word 0
        .endr
.set _stack_bottom, .
