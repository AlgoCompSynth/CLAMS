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

        @ stack operations
        .macro _drop_
        @ ( x1 x2 -- x1 )
        LDM PS2!, {TOS}
        .endm

        .macro _dupe_
        @ ( x1 -- x1 x1 )
        SUB PS2, #_AU_CELL
        STR TOS, [PS2]
        .endm

        .macro _swap_
        @ ( x1 x2 -- x2 x1 )
        LDR r0, [PS2]
        STR TOS, [PS2]
        MOV TOS, r0
        .endm

        .macro _over_
        @ ( x1 x2 -- x1 x2 x1 )
        _dupe_
        LDR TOS, [PS2]
        .endm

        .macro _rote_
        @ ( x1  x2  x3 -- x2  x3  x1 )
        @ x3 is in TOS
        LDR r1, [PS2, #_AU_CELL] @ x1 => r1
        LDR r2, [PS2] @ x2 => r2
        STR r2, [PS2, #_AU_CELL] @ stash x2
        STR TOS, [PS2] @ stash x3
        MOV TOS, r1 @ x1 => TOS
        .endm

        @ templates
        .macro _u_fetch opcode:req
        @ unsigned fetch
        @ ( a-addr -- x )
        \opcode\() TOS, [TOS]
        .endm

        .macro _s_fetch opcode:req
        @ signed fetch
        @ ( a-addr -- x )
        @ signed fetches need an offset in a register for M0+
        MOV r0, #0
        \opcode\() TOS, [TOS, r0]
        .endm

        .macro _store opcode:req
        @ store
        @ ( data a-addr -- )
        LDR r0, [PS2] @ data cell => r0
        \opcode\() r0, [TOS] @ do the store
        LDR TOS, [PS2, #_AU_CELL] @ stack 3rd => TOS
        ADD PS2, #_AU_CELL*2
        .endm

        .macro _aligned address_units:req
        MOV r0, #\address_units\()
        NEG r0, r0 @ # bitmask => r0
        ADD TOS, #\address_units\()
        SUB TOS, #1 @ TOS + \address_units\() - 1 => TOS
        AND TOS, r0 @ TOS & bitmask => TOS
        .endm

@ Common code for a word that uses a single instruction binary ALU operator on the
@ top two stack cells. Such words have the stack effect
@
@    ( left right -- result )
@
@ where `result` = `left <op> right`. That is, the postfix `left right <op>` has
@ the same `result` as the infix `left <op> right`.

        .macro _binary_alu opcode:req
        @ ( left right -- left OP right )
        LDR r0, [PS2] @ left operand => r0
        ADD PS2, #_AU_CELL @ point to new 2nd of stack
        \opcode\() r0, TOS @ r0 := left <OP> right
        MOV TOS, r0
        .endm

@ Common code for a word that compares the top two cells on the stack. Such words
@ have the stack effect
@
@    ( left right -- flag )
@
@ where `flag` = true (all ones) if `left <cmp> right` is true, and false (all
@ zeroes) if `left <cmp> right` is false.

        .macro _binary_cmp cmp:req
        LDR r0, [PS2] @ left operand => r0
        ADD PS2, #_AU_CELL @ point to new 2nd of stack
        CMP r0, TOS
        B\cmp\() 1f @ branch if true
        MOV TOS, #0 @ FALSE flag => TOS
        B 2f @ exit
1:
        MOV TOS, #0
        MVN TOS, TOS @ TRUE flag => TOS
2:
        .endm

@ Common code for unary operations

        .macro _unary_op instruction:req
        \instruction\() @ instruction must perform a unary operation on TOS
        .endm

        @ fetch operations
        .macro _fetch_
        @ ( a-addr -- cell(a-addr) )
        _u_fetch LDR
        .endm

        .macro _c_fetch_
        @ ( c-addr -- char(h-addr) )
        _u_fetch LDRB
        .endm

        .macro _h_fetch_
        @ ( h-addr -- unsigned_halfword(h-addr) )
        _u_fetch LDRH
        .endm

        .macro _s_b_fetch_
        @ ( b-addr -- signed_byte(b-addr) )
        _s_fetch LDRSB
        .endm

        .macro _s_h_fetch_
        @ ( h-addr -- signed_halfword(h-addr) )
        _s_fetch LDRSH
        .endm

        .macro _store_
        @ ( data a-addr -- )
        _store STR
        .endm

        .macro _c_store_
        @ ( data c-addr -- )
        _store STRB
        .endm

        .macro _h_store_
        @ ( data h-addr -- )
        _store STRH
        .endm

        .macro _one_plus_
        _unary_op "ADD TOS, #1"
        .endm

        .macro _one_minus_
        _unary_op "SUB TOS, #1"
        .endm

        .macro _two_star_
        _unary_op "LSL TOS, #1"
        .endm

        .macro _two_slash_
        _unary_op "ASR TOS, #1"
        .endm

        .macro _cell_plus_
        _unary_op "ADD TOS, #_AU_CELL"
        .endm

        .macro _cell_minus_
        _unary_op "SUB TOS, #_AU_CELL"
        .endm

        .macro _cells_
        _unary_op "LSL TOS, #_CELL_SHIFT"
        .endm

        .macro _char_plus_
        _unary_op "ADD TOS, #_AU_CHAR"
        .endm

        .macro _char_minus_
        _unary_op "SUB TOS, #_AU_CHAR"
        .endm

        .macro _chars_
        .endm

        .macro _halfword_plus_
        _unary_op "ADD TOS, #_AU_HALF"
        .endm

        .macro _halfword_minus_
        _unary_op "SUB TOS, #_AU_HALF"
        .endm

        .macro _halfwords_
        _unary_op "LSL TOS, #_HALF_SHIFT"
        .endm

        @ arithmetic operators
        .macro _plus_
        _binary_alu ADD
        .endm

        .macro _minus_
        _binary_alu SUB
        .endm

        .macro _star_
        _binary_alu MUL
        .endm

        .macro _negate_
        _unary_op "NEG TOS, TOS"
        .endm

        .macro _aligned_
        @ ( addr -- a-addr )
        _aligned _AU_CELL
        .endm

        .macro _h_aligned_
        @ ( addr -- h-addr )
        _aligned _AU_HALF
        .endm

        @ boolean operators
        .macro _and_
        _binary_alu AND
        .endm

        .macro _or_
        _binary_alu ORR
        .endm

        .macro _x_or_
        _binary_alu EOR
        .endm

        .macro _invert_
        _unary_op "MVN TOS, TOS"
        .endm

        .macro _l_shift_
        _binary_alu LSL
        .endm

        .macro _r_shift_
        _binary_alu LSR
        .endm

        @ binary comparison operators
        .macro _less_than_
        _binary_cmp LT
        .endm

        .macro _less_or_equal_
        _binary_cmp LE
        .endm

        .macro _equals_
        _binary_cmp EQ
        .endm

        .macro _not_equal_
        _binary_cmp NE
        .endm

        .macro _greater_than_
        _binary_cmp GT
        .endm

        .macro _greater_or_equal_
        _binary_cmp GE
        .endm

        .macro _u_greater_than_
        _binary_cmp HI
        .endm

        .macro _u_greater_or_equal_
        _binary_cmp HS
        .endm

        .macro _u_less_than_
        _binary_cmp LO
        .endm

        .macro _u_less_or_equal_
        _binary_cmp LS
        .endm
