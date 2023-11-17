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

@ The stack grows from low addresses upwards. Register `pt2nd` points to the
@ second element of the parameter stack. The top of the stack is stored in
@ register `pstop`.

.include "SymbolDefs.S"

.thumb_func
.global clear_stack
clear_stack:
        LDR pt2nd, =_stack_start
        _EXIT

.thumb_func
.global stkprint3
stkprint3:
        _NEST
        LDR r0, =_stack_format_3
        SUB r1, pt2nd, #_cell @ point to third
        LDR r1, [r1] @ get third
        LDR r2, [pt2nd] @ get second
        MOV r3, pstop @ get top
        BL printf
        _UNNEST

.thumb_func
.global stkprint2
stkprint2:
        _NEST
        LDR r0, =_stack_format_2
        LDR r1, [pt2nd] @ get second
        MOV r2, pstop @ get top
        BL printf
        _UNNEST

.thumb_func
.global stkprint1
stkprint1:
        _NEST
        LDR r0, =_stack_format_1
        MOV r1, pstop @ get top
        BL printf
        _UNNEST

.thumb_func
.global push1
push1:
        ADD pt2nd, #_cell @ pt2nd points to existing stack second!
        STM pt2nd!, {pstop} @ save old stack top

        MOV pstop, r0 @ new stack top
        _EXIT

.thumb_func
.global push2
push2:
        ADD pt2nd, #_cell @ pt2nd points to existing stack second!
        STM pt2nd!, {pstop} @ save old stack top

        STM pt2nd!, {r0} @ new stack second
        MOV pstop, r1 @ new stack top
        _EXIT

.thumb_func
.global push3
push3:
        ADD pt2nd, #_cell @ pt2nd points to existing stack second!
        STM pt2nd!, {pstop} @ save old stack top

        STM pt2nd!, {r0-r1} @ new stack third and second
        MOV pstop, r2 @ new stack top
        _EXIT

_stack_format_3: .asciz "stack data: %x, %x, %x\n"
_stack_format_2: .asciz "stack data: %x, %x\n"
_stack_format_1: .asciz "stack data: %x\n"

.data
.balign _cell, 0

@ The parameter stack
.set _stack_cells, 64
.global _stack_start
_stack_start:
        .rept _stack_cells
        .word 0
        .endr
.global _stack_end
.set _stack_end, .

@ User variables
        .macro _USER_VARIABLE name:req, default=0
        .global \name
        .set \name, .
        .word \default
        .endm

_USER_VARIABLE _BASE, 10 @ base for number I/O
_USER_VARIABLE _STATE, 0 @ true when compiling, false otherwise

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
