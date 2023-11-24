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
@ However, r8 - r11 have limited functionality - essentially only source or
@ destination of a MOV and one operand of a CMP.

@ parameter stack registers
PT2ND .req r7 @ pointer to second parameter stack cell
PSTOP .req r6 @ top cell of parameter stack

@ see Pelc, Stephen, "Updating the Forth Virtual Machine", 
@ https://www.complang.tuwien.ac.at/anton/euroforth/ef08/papers/pelc.pdf,
@ accessed 2023-11-20

@ index-scratch registers
INDXA .req r5 @ index register a
INDXB .req r4 @ index register b

@ memory pointer - base + literal addressing
MPTRX .req r9
MPTRY .req r8

@ registers r12 - r15 are reserved for the SDK!
@ registers r10 - r11 are used without saving in the Forth VM
@ registers r0 - r3 are used without saving in the Forth VM and for parameter
@ and result passing by SDK functions.

@ symbols for addressing expressions
.set _BYTE, 1 @ address units per byte
.set _CHAR, 1 @ address units per character
.set _CELL, 4 @ address units per cell
.set _CELL_SHIFT, 2 @ bits to shift for cell - address unit conversions

@ system-wide macros

        @ parameter stack macros
        .macro _DUP
        SUB PT2ND, #_CELL @ stack grows downward
        STR PSTOP, [PT2ND] @ save top to RAM
        .endm

        .macro _PUSHR0
        _DUP
        MOV PSTOP, r0 @ save argument to `PSTOP`
        .endm

        .macro _OVER
        _DUP
        LDR PSTOP, [PT2ND, #_CELL*2] @ replace top of stack with 3rd
        .endm

        .macro _SWAP
        LDR r0, [PT2ND]
        STR PSTOP, [PT2ND]
        MOV PSTOP, r0
        .endm

        .macro _DROP
        LDR PSTOP, [PT2ND]
        ADD PT2ND, #_CELL
        .endm

        .macro _ROT
        @ x1, x2, x3 -> x2, x3, x1
        LDR r0, [PT2ND] @ get x2
        STR PSTOP, [PT2ND] @ stash x3
        LDR PSTOP, [PT2ND, #_CELL] @ get x1
        STR r0, [PT2ND, #_CELL] @ stash x2
        .endm

        @ enhanced register macros
        @ to and from stack
        .macro _TO_INDX register
        MOV INDX\register, PSTOP
        _DROP
        .endm
        .macro _INDX_FROM register
        _DUP
        MOV PSTOP, INDX\register
        .endm
        .macro _TO_MPTR register
        MOV MPTR\register, PSTOP
        _DROP
        .endm
        .macro _MPTR_FROM register
        _DUP
        MOV PSTOP, MPTR\register
        .endm

        @ index operations
        .macro _POST_OP register, post_op=""
        .if \post_op == "+"
          ADD INDX\register, #_CELL
        .elseif \post_op == "-"
          SUB INDX\register, #_CELL
        .elseif \post_op == "+C"
          ADD INDX\register, #_CHAR
        .elseif \post_op == "-C"
          SUB INDX\register, #_CHAR
        .endif
        .endm
        .macro _FETCH_INDX register, post_op=""
        _DUP
        LDR PSTOP, [INDX\register]
        _POST_OP \register, \post_op
        .endm
        .macro _STORE_INDX register, post_op=""
        STR PSTOP, [INDX\register]
        _DROP
        _POST_OP \register, \post_op=""
        .endm

        @ memory pointer operations
        @ these clobber r0!!!
        .macro _ADD_OFFSET register
        MOV r0, MPTR\register
        ADD r0, PSTOP
        .endm
        .macro _FETCH_MPTR register
        _ADD_OFFSET \register
        LDR PSTOP, [r0]
        .endm
        .macro _STORE_MPTR register
        _ADD_OFFSET \register
        _DROP
        STR PSTOP, [r0]
        .endm

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
