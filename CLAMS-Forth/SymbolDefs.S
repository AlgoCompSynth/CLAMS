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

@ coding conventions:

@ 1. Names intended to be internal to the CLAMS-Forth system have a leading
@ underscore and are restricted to the character set of Arm GNU assembler symbols.
@ Function names and variables use only lower-case letters, constants use only
@ upper case letters.

@ 2. Names intended to represent Forth words have the Forth syntax. Words that are 
@ defined in the Forth standard use only upper case letters and behave the same way
@ they do in the standard. Names created by the user can use any case and the
@ system is case-sensitive.

@ 3. Register usage: Pico SDK functions save registers r4 - r11, so we can use
@ them without saving. However, r8 - r11 have limited functionality - essentially
@ only source or destination of a MOV, one operand of a CMP or a computed branch.
@ Registers r0 - r3 are work registers and are used to interact with SDK functions.
@ They are not saved / restored. Although the SDK allows more than four parameters,
@ there are by design no CLAMS-Forth functions that do.

@ parameter stack registers
PT2ND .req r7 @ pointer to second parameter stack cell
PSTOP .req r6 @ top cell of parameter stack

@ see Pelc, Stephen, "Updating the Forth Virtual Machine", 
@ https://www.complang.tuwien.ac.at/anton/euroforth/ef08/papers/pelc.pdf,
@ accessed 2023-11-20

@ index-scratch registers
INDXA .req r4 @ index register a
INDXB .req r5 @ index register b

@ memory pointer / base + literal addressing registers
MPTRX .req r8
MPTRY .req r9

@ registers r12 - r15 are reserved for the SDK!
@ registers r10 - r11 are used without saving in the Forth VM
@ registers r0 - r3 are used without saving in the Forth VM and for parameter
@ and result passing by SDK functions.

@ symbols for addressing expressions
@ reference: Forth 2012 standard, section D2.2
@ For the Arm Cortex series, an address unit is 8 bits aka a byte
.set _CHAR, 1 @ address units per character
.set _CELL, 4 @ address units per cell
.set _CELL_SHIFT, 2 @ bits to shift for cell - address unit conversions

@ system-wide macros

        @ parameter stack macros
        .macro _dupe
        SUB PT2ND, #_CELL @ stack grows downward
        STR PSTOP, [PT2ND] @ save top to RAM
        .endm

        .macro _over
        _dupe
        LDR PSTOP, [PT2ND, #_CELL*2] @ replace top of stack with 3rd
        .endm

        .macro _swap
        LDR r0, [PT2ND]
        STR PSTOP, [PT2ND]
        MOV PSTOP, r0
        .endm

        .macro _drop
        LDR PSTOP, [PT2ND]
        ADD PT2ND, #_CELL
        .endm

        .macro _rote
        @ x1, x2, x3 -> x2, x3, x1
        LDR r0, [PT2ND] @ get x2
        STR PSTOP, [PT2ND] @ stash x3
        LDR PSTOP, [PT2ND, #_CELL] @ get x1
        STR r0, [PT2ND, #_CELL] @ stash x2
        .endm

        @ enhanced register macros
        @ to and from stack
        .macro _to_reg register=r0
        MOV \register, PSTOP
        _drop
        .endm
        .macro _reg_from register=r0
        _dupe
        MOV PSTOP, \register
        .endm

        @ index operations - only work for r0 - r7
        .macro _post_op register=r0, post_op=""
        .ifc \post_op\(), '+'
          ADD \register, #_CELL
        .endif
        .ifc \post_op\(), '-'
          SUB \register, #_CELL
        .endif
        .ifc \post_op\(), '+C'
          ADD \register, #_CHAR
        .endif
        .ifc \post_op\(), '-C'
          SUB \register, #_CHAR
        .endif
        .endm

        .macro _fetch_lo register=r0, post_op=""
        _dupe
        LDR PSTOP, [\register]
        _post_op \register, \post_op\()
        .endm
        .macro _store_lo register=r0, post_op=""
        STR PSTOP, [\register]
        _drop
        _post_op \register, \post_op\()=""
        .endm

        @ memory pointer operations
        @ these clobber r0!!!
        .macro _plus_offset register=r11
        MOV r0, \register
        ADD r0, PSTOP
        .endm
        .macro _fetch_hi register=r11
        _plus_offset \register
        LDR PSTOP, [r0]
        .endm
        .macro _store_hi register=r11
        _plus_offset \register
        _drop
        STR PSTOP, [r0]
        _drop
        .endm

        @ return to caller
        .macro _return
        BX LR
        .endm

        @ macros for nested calls
        .macro _nest
        PUSH {INDXA, INDXB, LR}
        MOV INDXA, MPTRX
        MOV INDXB, MPTRY
        PUSH {INDXA, INDXB}
        .endm

        .macro _unnest
        POP {INDXA, INDXB}
        MOV MPTRX, INDXA
        MOV MPTRY, INDXB
        POP {INDXA, INDXB, PC}
        .endm

        @ macro to call a function "locally" (within plus or minus 16 MiB)
        .macro _l_call func_name
        BL \func_name
        .endm

        @ We sometimes need to call functions in SRAM from flash and _vice versa_.
        @ macro to call a function anywhere
        .macro _x_call func_name
        LDR INDXA, _addr_\func_name @ get the address
        BLX INDXA
        .endm

        @ macro to create a "func_addr" word
        .macro _x_addr func_name
        .balign _CELL
        .set _addr_\func_name, .
        .word \func_name
        .endm

        @ crash with a message
        .macro _crash message:req
        LDR r0, _ADDR_MESSAGE
        _x_call printf
        _x_call abort

        .balign _CELL
        .set _ADDR_MESSAGE, .
        .word _MESSAGE
        .set _MESSAGE, .
        .asciz "\message\()"
        .endm

@ Common code for a word that uses a single instruction binary ALU operator on the
@ top two stack cells. Such words have the stack effect
@
@    ( left right -- result )
@
@ where `result` = `left <op> right`. That is, the postfix `left right <op>` has
@ the same `result` as the infix `left <op> right`.

        .macro _binary_alu opcode
        LDM PT2ND!, {r0} @ pop left operand => r0
        \opcode\() PSTOP, r0, PSTOP @ PSTOP := left <OP> PSTOP
        .endm

@ Common code for a word that compares the top two cells on the stack. Such words
@ have the stack effect
@
@    ( left right -- flag )
@
@ where `flag` = true (all ones) if `left <cmp> right` is true, and false (all
@ zeroes) if `left <cmp> right` is false.

        .macro _binary_cmp cmp
        LDM PT2ND!, {r0} @ pop left operand => r0
        CMP r0, PSTOP
        B\cmp\() 1f @ branch if true
        MOV PSTOP, #0 @ false - set flag to zero
        B 2f
1:
        MOV PSTOP, #0
        MVN PSTOP, PSTOP @ set all-ones true flag
2:
        .endm

        @ position-independent operations
        .macro _fetch
        LDR PSTOP, [PSTOP]
        .endm

        .macro _store
        LDM PT2ND!, {r0-r1}
        STR r0, [PSTOP]
        .endm

        .macro _plus_store
        LDM PT2ND!, {r0-r1}
        LDR r2, [PSTOP]
        ADD r2, r0
        STR r2, [PSTOP]
        MOV PSTOP, r1
        .endm

        .macro _one_plus
        ADD PSTOP, #1
        .endm

        .macro _one_minus
        SUB PSTOP, #1
        .endm

        .macro _two_star
        LSL PSTOP, #1
        .endm

        .macro _two_slash
        ASR PSTOP, #1
        .endm

        @ arithmetic operators
        .macro _plus
        _binary_alu ADD
        .endm

        .macro _minus
        _binary_alu SUB
        .endm

        .macro _star
        _binary_alu MUL
        .endm

        .macro _negate
        MVN PSTOP, PSTOP
        .endm

        @ boolean operators
        .macro _and
        _binary_alu AND
        .endm

        .macro _or
        _binary_alu ORR
        .endm

        .macro _x_or
        _binary_alu EOR
        .endm

        .macro _invert
        MVN PSTOP, PSTOP
        .endm

        .macro _l_shift
        LDM PT2ND!, {r0}
        LSL r0, PSTOP
        MOV PSTOP, r0
        .endm

        .macro _r_shift
        LDM PT2ND!, {r0}
        LSR r0, PSTOP
        MOV PSTOP, r0
        .endm

        @ binary comparison operators
        .macro _less_than
        _binary_cmp LT
        .endm

        .macro _less_or_equal
        _binary_cmp LE
        .endm

        .macro _equals
        _binary_cmp EQ
        .endm

        .macro _not_equal
        _binary_cmp NE
        .endm

        .macro _greater_than
        _binary_cmp GT
        .endm

        .macro _greater_or_equal
        _binary_cmp GE
        .endm

        .macro _u_greater_than
        _binary_cmp HI
        .endm

        .macro _u_greater_or_equal
        _binary_cmp HS
        .endm

        .macro _u_less_than
        _binary_cmp LO
        .endm

        .macro _u_less_or_equal
        _binary_cmp LS
        .endm
