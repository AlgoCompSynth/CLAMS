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

@ Pico SDK functions save registers r4 - r11, so we can use them without saving.
@ However, r8 - r11 have limited functionality - essentially only source and
@ destination of a MOV and one operand of a CMP.

@ parameter stack registers
pt2nd .req r7 @ pointer to second parameter stack cell
pstop .req r6 @ top cell of parameter stack

@ see Pelc, Stephen, "Updating the Forth Virtual Machine", 
@ https://www.complang.tuwien.ac.at/anton/euroforth/ef08/papers/pelc.pdf,
@ accessed 2023-11-20

@ index-scratch registers
INDXA .req r5 @ index register a
INDXB .req r4 @ index register b

@ memory pointer - base + literal addressing
@ Pelc only calls for two of these but we have the registers to spare. These can
@ be used as a third, fourth, fifth and sixth hand to eliminate a lot of memory
@ traffic. The addressing operations Pelc assigns to these registers must be
@ done via a working register among r0-r3, which costs one cycle. We anticipate
@ such operations will be inlined in compiled words.
MPTRW .req r11
MPTRX .req r10
MPTRY .req r9
MPTRZ .req r8

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

        @ parameter stack macros
        .macro _DUP
        SUB pt2nd, #_cell @ stack grows downward
        STR pstop, [pt2nd] @ save top to RAM
        .endm

        .macro _PUSHR0
        _DUP
        MOV pstop, r0 @ save argument to `pstop`
        .endm

        .macro _OVER
        _DUP
        LDR pstop, [pt2nd, #_cell*2] @ replace top of stack with 3rd
        .endm

        .macro _SWAP
        LDR r0, [pt2nd]
        STR pstop, [pt2nd]
        MOV pstop, r0
        .endm

        .macro _DROP
        LDR pstop, [pt2nd]
        ADD pt2nd, #_cell
        .endm

        .macro _ROT
        @ x1, x2, x3 -> x2, x3, x1
        LDR r0, [pt2nd] @ get x2
        STR pstop, [pt2nd] @ stash x3
        LDR pstop, [pt2nd, #_cell] @ get x1
        STR r0, [pt2nd, #_cell] @ stash x2
        .endm

        @ enhanced register macros
        @ to and from stack
        .macro _TO_INDX register
        MOV INDX\register, pstop
        _DROP
        .endm
        .macro _INDX_FROM register
        _DUP
        MOV pstop, INDX\register
        .endm
        .macro _TO_MPTR register
        MOV MPTR\register, pstop
        _DROP
        .endm
        .macro _MPTR_FROM register
        _DUP
        MOV pstop, MPTR\register
        .endm

        @ index operations
        .macro _POST_OP post_op=""
        .if \post_op == "+"
          ADD INDX\register, #_cell
        .elseif \post_op == "-"
          SUB INDX\register, #_cell
        .elseif \post_op == "+C"
          ADD INDX\register, #1
        .elseif \post_op == "-C"
          SUB INDX\register, #1
        .endif
        .endm
        .macro _FETCH_INDX register, post_op=""
        _DUP
        LDR pstop, [INDX\register]
        _POST_OP \post_op
        .endm
        .macro _STORE_INDX register, post_op=""
        STR pstop, [INDX\register]
        _DROP
        _POST_OP \post_op=""
        .endm

        @ memory pointer operations
        @ these clobber r0!!!
        .macro _ADD_OFFSET register
        MOV r0, MPTR\register
        ADD r0, pstop
        .endm
        .macro _FETCH_MPTR register
        _ADD_OFFSET \register
        LDR pstop, [r0]
        .endm
        .macro _STORE_MPTR register
        _ADD_OFFSET \register
        _DROP
        STR pstop, [r0]
        .endm
