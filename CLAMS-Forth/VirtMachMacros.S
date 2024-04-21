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

@ The CLAMS-Forth virtual machine is designed using GNU assembly macros. In theory,
@ one can port this to other Arm systems easily, and to other architectures with
@ some effort.

@ The return stack is the SDK's system stack and it is used *only* for maintaining
@ interpreter call / return addresses! I consider other uses of the return stack
@ footguns at best, and given that CLAMS-Forth shares it with the operating system,
@ it's just too risky.

@ The parameter stack is in RAM and is currently 64 cells. The top of the stack is
@ in register PSTOP and the stack pointer PT2ND points to the RAM address of the
@ *second* cell in the stack. So there is always one cell on the parameter stack in
@ PSTOP. The parameter stack grows downward in RAM addresses.

@ Most "CODE" words exist in two forms - as assembler macros defined in this file,
@ and as invocations of those macros in "Dictionary.S". This makes adding primitives
@ a two-step process, but the intent is to make an assembler easier to build. A
@ Forth assembler does not need to cover the whole assembly language of a machine,
@ just the primitive operations of the Forth virtual machine; its reason for
@ existence is primarily to eliminate the overhead of an interpretive subroutine
@ call to a two or three instruction operation.

@ The RP2040 is an Arm Cortex M0+ machine. The SDK operates in little-endian mode,
@ CLAMS-Forth does as well. As far as I know there are no dependencies on
@ little-endian addressing; if you find one, please open an issue.

@ Arithmetic and logical operations use two's complement 32-bit binary arithmetic.
@ 32 bits is nine+ decimal digits, so I haven't implemented most double-word
@ functions. They're vital on a 16-bit Forth but not for the intended application of
@ CLAMS-Forth.

@ A cell is 32 bits, which is four byte address units. I have also provided signed
@ halfword and byte fetch operations, since they are available in the RP2040
@ instruction set. Halfword store operations are also included.

        @ stack operations
        .macro _drop_
        @ ( x1 x2 -- x1 )
        LDM PT2ND!, {PSTOP}
        .endm

        .macro _dupe_
        @ ( x1 -- x1 x1 )
        SUB PT2ND, #_AU_CELL @ parameter stack grows downward
        STR PSTOP, [PT2ND]
        .endm

        .macro _swap_
        @ ( x1 x2 -- x2 x1 )
        LDR r0, [PT2ND] @ x1 => r0
        STR PSTOP, [PT2ND] @ x2 => 2nd of stack
        MOV PSTOP, r0 @ x1 => PSTOP
        .endm

        .macro _over_
        @ ( x1 x2 -- x1 x2 x1 )
        _dupe_
        LDR PSTOP, [PT2ND]
        .endm

        .macro _rote_
        @ ( x1  x2  x3 -- x2  x3  x1 )
        @ x3 is in PSTOP
        LDR r1, [PT2ND, #_AU_CELL] @ x1 => r1
        LDR r2, [PT2ND] @ x2 => r2
        STR r2, [PT2ND, #_AU_CELL] @ stash x2
        STR PSTOP, [PT2ND] @ stash x3
        MOV PSTOP, r1 @ x1 => PSTOP
        .endm

        @ templates
        .macro _u_fetch opcode:req @ unsigned fetches
        @ unsigned fetch
        @ ( addr -- x )
        \opcode\() PSTOP, [PSTOP]
        .endm

        .macro _s_fetch opcode:req @ signed fetches
        @ signed fetch
        @ ( addr -- x )
        @ signed fetches need an offset in a register on the Arm Cortex M0+
        MOV r0, #0
        \opcode\() PSTOP, [PSTOP, r0]
        .endm

        .macro _store opcode:req
        @ store
        @ ( data addr -- )
        LDR r0, [PT2ND] @ data cell => r0
        \opcode\() r0, [PSTOP] @ do the store
        LDR PSTOP, [PT2ND, #_AU_CELL] @ stack 3rd => PSTOP
        ADD PT2ND, #_AU_CELL*2 @ drop the consumed parameters
        .endm

        .macro _aligned address_units:req
        MOV r0, #\address_units\()
        NEG r0, r0 @ # bitmask => r0
        ADD PSTOP, #\address_units\()
        SUB PSTOP, #1 @ PSTOP + \address_units\() - 1 => PSTOP
        AND PSTOP, r0 @ PSTOP & bitmask => PSTOP
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
        LDR r0, [PT2ND] @ left operand => r0
        ADD PT2ND, #_AU_CELL @ point to new 2nd of stack
        \opcode\() r0, PSTOP @ r0 := left <OP> right
        MOV PSTOP, r0
        .endm

@ Common code for a word that compares the top two cells on the stack. Such words
@ have the stack effect
@
@    ( left right -- flag )
@
@ where `flag` = true (all ones) if `left <cmp> right` is true, and false (all
@ zeroes) if `left <cmp> right` is false.

        .macro _binary_cmp cmp:req
        LDM PT2ND!, {r0} @ pop left operand => r0
        CMP r0, PSTOP
        B\cmp\() 1f @ branch if true
        MOV PSTOP, #0 @ FALSE flag => PSTOP
        B 2f @ exit
1:
        MOV PSTOP, #0
        MVN PSTOP, PSTOP @ TRUE flag => PSTOP
2:
        .endm

@ Common code for unary operations

        .macro _unary_op instruction:req
        \instruction\() @ instruction must perform a unary operation on PSTOP
        .endm

@ Macro / word naming conventions: In the dictionary, a word has a Forth name and a
@ pronunciation. The symbol "_\pronunciation" is defined in the dictionary to be the
@ code field address of the word. In these macros, the symbol "_\pronunciation_"
@ is the name of the macro that implements the word.

@ In the following, "a-addr" is a cell-aligned address, "c-addr" is a character- /
@ byte-aligned address, and "h-addr" is a halfword-aligned address.

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
        @ ( c-addr -- signed_byte(c-addr) )
        _s_fetch LDRSB
        .endm

        .macro _s_h_fetch_
        @ ( h-addr -- signed_halfword(h-addr) )
        _s_fetch LDRSH
        .endm

        .macro _store_
        @ ( data a-addr -- )
        @ data cell => c-addr
        _store STR
        .endm

        .macro _c_store_
        @ ( data c-addr -- )
        @ lowest byte of data => c-addr
        _store STRB
        .endm

        .macro _h_store_
        @ ( data h-addr -- )
        @ lower halfword of data => h-addr
        _store STRH
        .endm

        .macro _plus_store_
        @ ( data a-addr -- )
        @ cell(a-addr) + data => cell(a-addr)
        LDR r0, [PT2ND] @ data => r0
        LDR r1, [PSTOP] @ cell(a-addr) => r1
        ADD r0, r1 @ do the addition
        STR r0, [PSTOP] @ do the store
        LDR PSTOP, [PT2ND, #_AU_CELL] @ stack 3rd => PSTOP
        ADD PT2ND, #_AU_CELL*2 @ drop the consumed parameters
        .endm

        .macro _zero_less_
        @ ( x -- flag(x < 0) )
        MOV r0, #0
        CMP PSTOP, r0
        BGE 1f @ skip if PSTOP >= 0
        MVN r0, r0 @ invert r0
1:
        MOV PSTOP, r0 @ set flag and exit
        .endm

        .macro _zero_equals_
        @ ( x -- flag(x = 0) )
        MOV r0, #0
        CMP PSTOP, r0
        BNE 1f @ skip if PSTOP != 0
        MVN r0, r0 @ invert r0
1:
        MOV PSTOP, r0 @ set flag and exit
        .endm

        .macro _zero_not_equals_
        @ ( x -- flag(x <> 0) )
        MOV r0, #0
        CMP PSTOP, r0
        BEQ 1f @ skip if PSTOP = 0
        MVN r0, r0 @ invert r0
1:
        MOV PSTOP, r0 @ set flag and exit
        .endm

        .macro _zero_greater_
        @ ( x -- flag(x > 0) )
        MOV r0, #0
        CMP PSTOP, r0
        BLE 1f @ skip if PSTOP <= 0
        MVN r0, r0 @ invert r0
1:
        MOV PSTOP, r0 @ set flag and exit
        .endm

        .macro _one_plus_
        @ ( x -- x + 1 )
        _unary_op "ADD PSTOP, #1"
        .endm

        .macro _one_minus_
        @ ( x -- x - 1 )
        _unary_op "SUB PSTOP, #1"
        .endm

        .macro _two_star_
        @ ( x -- x * 2 )
        _unary_op "LSL PSTOP, #1"
        .endm

        .macro _two_slash_
        @ ( x -- x / 2 )
        _unary_op "ASR PSTOP, #1"
        .endm

        .macro _cell_plus_
        @ (a-addr -- a-addr + 1 cell )
        _unary_op "ADD PSTOP, #_AU_CELL"
        .endm

        .macro _cell_minus_
        @ (a-addr -- a-addr - 1 cell )
        _unary_op "SUB PSTOP, #_AU_CELL"
        .endm

        .macro _cells_
        @ ( x -- x cells )
        _unary_op "LSL PSTOP, #_CELL_SHIFT"
        .endm

        .macro _char_plus_
        @ (c-addr -- c-addr + 1 char )
        _unary_op "ADD PSTOP, #_AU_CHAR"
        .endm

        .macro _char_minus_
        @ (c-addr -- c-addr - 1 char )
        _unary_op "SUB PSTOP, #_AU_CHAR"
        .endm

        .macro _chars_
        @ ( x -- x chars )
        .endm

        .macro _halfword_plus_
        @ (h-addr -- h-addr + 1 halfword )
        _unary_op "ADD PSTOP, #_AU_HALF"
        .endm

        .macro _halfword_minus_
        @ (h-addr -- h-addr - 1 halfword )
        _unary_op "SUB PSTOP, #_AU_HALF"
        .endm

        .macro _halfwords_
        @ ( x -- x halfwords )
        _unary_op "LSL PSTOP, #_HALF_SHIFT"
        .endm

        @ arithmetic operators
        @ ( x1 x2 -- x1 + x2 )
        .macro _plus_
        _binary_alu ADD
        .endm

        .macro _minus_
        @ ( x1 x2 -- x1 - x2 )
        _binary_alu SUB
        .endm

        .macro _star_
        @ ( x1 x2 -- x1 * x2 )
        _binary_alu MUL
        .endm

        .macro _negate_
        @ ( x -- -x )
        _unary_op "NEG PSTOP, PSTOP"
        .endm

        .macro _aligned_
        @ ( addr -- a-addr )
        _aligned _AU_CELL
        .endm

        .macro _h_aligned_
        @ ( addr -- h-addr )
        _aligned _AU_HALF
        .endm

        .macro _max_
        @ ( x1 x2 -- max(x1, x2)
        LDR r0, [PT2ND] @ x1 => r0
        CMP r0, PSTOP
        BLE 1f @ skip if PSTOP is maximum
        MOV PSTOP, r0

        @ exit
1:
        ADD PT2ND, #_AU_CELL @ drop the left operand
        .endm

        .macro _min_
        @ ( x1 x2 -- min(x1, x2)
        LDR r0, [PT2ND] @ x1 => r0
        CMP r0, PSTOP
        BGE 1f @ skip if PSTOP is minimum
        MOV PSTOP, r0

        @ exit
1:
        ADD PT2ND, #_AU_CELL @ drop the left operand
        .endm

        @ boolean operators
        .macro _and_
        @ ( x1 x2 -- x1 AND x2 )
        _binary_alu AND
        .endm

        .macro _or_
        @ ( x1 x2 -- x1 OR x2 )
        _binary_alu ORR
        .endm

        .macro _x_or_
        @ ( x1 x2 -- x1 XOR x2 )
        _binary_alu EOR
        .endm

        .macro _invert_
        @ ( x -- NOT x )
        _unary_op "MVN PSTOP, PSTOP"
        .endm

        .macro _l_shift_
        @ ( x1 x2 -- x1 logical shift left x2 )
        _binary_alu LSL
        .endm

        .macro _r_shift_
        @ ( x1 x2 -- x1 logical shift right x2 )
        _binary_alu LSR
        .endm

        @ binary comparison operators
        .macro _less_than_
        @ ( x1 x2 -- flag x1 < x2 )
        _binary_cmp LT
        .endm

        .macro _less_or_equal_
        @ ( x1 x2 -- flag x1 <= x2 )
        _binary_cmp LE
        .endm

        .macro _equals_
        @ ( x1 x2 -- flag x1 = x2 )
        _binary_cmp EQ
        .endm

        .macro _not_equals_
        @ ( x1 x2 -- flag x1 <> x2 )
        _binary_cmp NE
        .endm

        .macro _greater_than_
        @ ( x1 x2 -- flag x1 > x2 )
        _binary_cmp GT
        .endm

        .macro _greater_or_equal_
        @ ( x1 x2 -- flag x1 >= x2 )
        _binary_cmp GE
        .endm

        @ unsigned comparisons
        .macro _u_greater_than_
        @ (u1 u2 -- flag u1 > u2 )
        _binary_cmp HI
        .endm

        .macro _u_greater_or_equal_
        @ (u1 u2 -- flag u1 >= u2 )
        _binary_cmp HS
        .endm

        .macro _u_less_than_
        @ (u1 u2 -- flag u1 < u2 )
        _binary_cmp LO
        .endm

        .macro _u_less_or_equal_
        @ (u1 u2 -- flag u1 <= u2 )
        _binary_cmp LS
        .endm
