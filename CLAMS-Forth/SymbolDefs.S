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

@ Registers r4 - r11 are saved by SDK functions, so we can use them without
@ saving. However, r8 - r11 have limited functionality, so we reserve them for
@ temporary storage.

tmpra .req r8
tmprb .req r9
tmprc .req r10
tmprd .req r11

@ parameter stack registers
pt2nd .req r7 @ pointer to second parameter stack cell
pstop .req r6 @ top cell of parameter stack

@ general-purpose address / count registers for loops
indxa .req r5 @ index register a
indxb .req r4 @ index register b

@ symbols for addressing expressions
.set _byte, 1 @ bytes
.set _cell, 4 @ bytes per cell
.set _cell_shift, 2 @ bits to shift for cell - byte conversions

@ system-wide macros

        @ return to caller
        .macro _EXIT
        BX LR
        .endm

        @ macros for nested calls
        .macro _NEST
        PUSH {LR}
        .endm

        .macro _UNNEST
        POP {PC}
        .endm

        .macro _PUSHR0
        STM pt2nd!, {pstop} @ push current top onto stack
        MOV pstop, r0
        .endm

        .macro _SWAP
        LDR r0, [pt2nd]
        STR pstop, [pt2nd]
        MOV pstop, r0
        .endm

        .macro _DROP
        LDR pstop, [pt2nd]
        SUB pt2nd, #_cell
        .endm

        .macro _DUP
        MOV r0, pstop
        _PUSHR0
        .endm

        .macro _ROT
        LDR r2, [pt2nd] @ get 2nd
        SUB r0, pt2nd, #_cell @ address of 3rd
        LDR r3, [r0] @ get 3rd

        STR r2, [r0] @ new 3rd
        STR pstop, [pt2nd] @ new 2nd
        MOV pstop, r3 @ new top
        .endm
