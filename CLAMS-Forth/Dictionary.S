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

@ address getters
.thumb_func
.global get_dict_addrs
get_dict_addrs:
        LDR r1, =_system_dict_start
        LDR r2, =_system_dict_end
        _EXIT

@ dictionary construction macros

@ dictionary header

@ wname = word name in dictionary - what the Forth system searches for

@ n_bytes = how many bytes in name

@ pronunciation = Forth specifies how to pronounce many words. We make labels
@ from these, substituting an underscore for each dash in the pronunciation.

@ b_offset = backwards offset to previous word = the number of bytes to go back
@ to find the previous word. A backwards offset of zero marks the end of the
@ dictionary!

        .macro _HEADER wname, pronunciation, flags=0
        .set _IMMEDIATE, 1 @ immediate word
        .set _COMPILE_ONLY, 2 @ compile-only word
        .set _INLINE, 4 @ copy this word into a definition rather than call it

        @ define header label
        .balign _cell, 0
        .set _\pronunciation, .

        @ build link field
        .if . == _system_dict_start
          .hword 0
        .else
          .hword . - _previous_link_address
        .endif
        .set _previous_link_address, . - 2

        @ build flags field
        .hword \flags

        @ build name field
        .set _count, 1f - . - 1
        .byte _count
        .ascii "\wname"
1:
        .balign _cell, 0

        @ define test entry point
        .thumb_func
        .global \pronunciation
        .set \pronunciation, .

        .endm

        _HEADER "MUDDY22", muddy22
        _HEADER "DUMMY1", dummy1, _INLINE + _IMMEDIATE + _COMPILE_ONLY

@ Common code for a word that uses a single instruction binary operator on the
@ top two stack cells. Such words have the stack effect
@
@    ( left right -- result )
@
@ where `result` = `left <op> right`. That is, the postfix `left right <op>` has
@ the same `result` as the infix `left <op> right`.

        .macro _BINARY_OP opcode
        LDM pt2nd!, {r0} @ pop left operand => r0
        \opcode\() pstop, r0, pstop @ pstop := left <OP> pstop
        _EXIT
        .endm

        @ build a dictionary entry for a binary word
        .macro _BINARY_WORD wname, pronunciation, opcode, flags
        _HEADER \wname, \pronunciation, \flags
        _BINARY_OP \opcode
        .endm

@ same thing for comparisons!
        .macro _BINARY_CP opcode
        LDM pt2nd!, {r0} @ pop left operand => r0
        CMP r0, pstop
        \opcode\() 1f @ branch if true
        MOV pstop, #0 @ false - set flag to zero
        _EXIT
1:
        LDR pstop, _true @ set all-ones true flag
        _EXIT
        .endm

        @ build a dictionary entry for a binary compare
        .macro _BINARY_COMPARE wname, pronunciation, opcode, flags
        _HEADER \wname, \pronunciation, \flags
        _BINARY_CP \opcode
        .endm

@ dictionary functions

.balign _cell
.global _system_dict_start
.set _system_dict_start, .

        @ stack operators
        _HEADER "DROP", drop, _INLINE
        _DROP
        _EXIT

        _HEADER "DUP", dupe, _INLINE
        _DUP
        _EXIT

        _HEADER "OVER", over, _INLINE
        _DUP
        _EXIT

        _HEADER "ROT", rote, _INLINE
        _ROT
        _EXIT

        _HEADER "SWAP", swap, _INLINE
        _SWAP
        _EXIT

        _HEADER "@", fetch, _INLINE
        LDR pstop, [pstop]
        _EXIT

        _HEADER "!", store, _INLINE
        LDM pt2nd!, {r0-r1}
        STR r0, [pstop]
        MOV pstop, r1
        _EXIT

        _HEADER "+!", plus_store, _INLINE
        LDM pt2nd!, {r0-r1}
        LDR r2, [pstop]
        ADD r2, r0
        STR r2, [pstop]
        MOV pstop, r1
        _EXIT

        _HEADER "1+", one_plus, _INLINE
        ADD pstop, #1
        _EXIT

        _HEADER "1-", one_minus, _INLINE
        SUB pstop, #1
        _EXIT

        _HEADER "2*", two_star, _INLINE
        LSL pstop, #1
        _EXIT

        _HEADER "2/", two_slash, _INLINE
        ASR pstop, #1
        _EXIT

        @ binary comparison operators
        _BINARY_COMPARE "<", less_than, BLT, _INLINE

        @ The "as" macro processor chokes with mysterious errors if the equal
        @ sign in the following invocation is enclosed in double quotes rather
        @ than single quotes. Maybe I'll develop a reprex and file an issue.
        @ Maybe I won't.
        _BINARY_COMPARE '=', equals, BEQ, _INLINE
        _BINARY_COMPARE ">", greater_than, BGT, _INLINE
        _BINARY_COMPARE "U>", u_greater_than, BHI, _INLINE
        _BINARY_COMPARE "U<", u_less_than, BLO, _INLINE

        @ arithmetic operators
        _BINARY_WORD "+", plus, ADD, _INLINE
        _BINARY_WORD "-", minus, SUB, _INLINE
        _BINARY_WORD "*", star, MUL, _INLINE

        _HEADER "/MOD", slash_mod
        _NEST
        LDR r0, [pt2nd] @ dividend => r0
        MOV r1, pstop @ divisor => r1
        BL sdk_slash_mod
        MOV pstop, r0 @ quotient => top of stack
        STR r1, [pt2nd] @ remainder => 2nd
        _UNNEST

        _HEADER "/", slash
        _NEST
        BL slash_mod
        _SWAP
        _DROP
        _UNNEST

        _HEADER "MOD", mod
        _NEST
        BL slash_mod
        _DROP
        _UNNEST

        _HEADER "NEGATE", negate, _INLINE
        MVN pstop, pstop
        _EXIT

        @ boolean operators
        _BINARY_WORD "AND", and, AND, _INLINE
        _BINARY_WORD "OR", or, ORR, _INLINE
        _BINARY_WORD "XOR", x_or, EOR, _INLINE

        _HEADER "INVERT", invert, _INLINE
        MVN pstop, pstop
        _EXIT

        _HEADER "LSHIFT", l_shift, _INLINE
        LDM pt2nd!, {r0}
        LSL r0, pstop
        MOV pstop, r0
        _EXIT

        _HEADER "RSHIFT", r_shift, _INLINE
        LDM pt2nd!, {r0}
        LSR r0, pstop
        MOV pstop, r0
        _EXIT

        @ terminal I/O words
        _HEADER "KEY", key
        _NEST
        BL sdk_key
        _PUSHR0
        _UNNEST

        _HEADER "EMIT", emit
        _NEST
        MOV r0, pstop
        BL sdk_emit
        _DROP
        _UNNEST
        
@ character codes
.set _bs, 8 @ backspace
.set _cr, 13 @ carriage return
.set _bl, 32 @ space
.set _del, 127 @ delete

        _HEADER "ACCEPT", accept
        _NEST

        @ On entry, the top of the stack has the maximum allowed characters and
        @ the second has the address of the buffer. On exit, the address has
        @ been consumed and the actual count is on the top of the stack.
        MOV MPTRW, pstop @ save maximum count in `MPTRW`
        LDR INDXA, [pt2nd] @ load the address to `INDXA`
        MOV pstop, #0 @ the actual count ends up here!
_accl:
        BL sdk_key @ wait for character, which will show up in r0

        @ test for specific control characters
        CMP r0, #_bs
        BEQ _accb @ do the backspace
        CMP r0, #_cr
        BEQ _accz @ line finished - clean up stack and exit
        
        @ the rest are either standard printables or will be replaced by space
        CMP r0, #_bl
        BLE _accs @ emit and append a space
        CMP r0, #_del
        BGE _accs @ emit and append a space

        @ an ordinary printable character - echo it and append to buffer
_acce:
        STR r0, [INDXA] @ append to buffer
        BL sdk_emit @ printable - send it out!

        @ count
        ADD INDXA, #1
        ADD pstop, #1
        CMP pstop, MPTRW @ did we hit the limit?
        BEQ _accz @ early exit if limit hit
	B _accl @ go back for more!

        @ space or unprintable
_accs:
        MOV r0, #_bl @ force a space and emit / store / count
        B _acce

        @ backspace - uncount previous character and erase it
_accb:
        CMP pstop, #0 @ is buffer empty?
        BEQ _accl @ ignore a backspace if buffer is empty

        @ un-count
        SUB INDXA, #1
        SUB pstop, #1

        @ erase previous character
        BL sdk_emit @ emit the backspace we have
        MOV r0, #_bl
        BL sdk_emit @ "erase" the character
        MOV r0, #_bs @ queue up another backspace
        BL sdk_emit
        B _accl @ back for more!

        @ clean up and exit
_accz:
        @ stack top is correct - it has the count - but we need to fix `pt2nd`
        ADD pt2nd, #_cell
        _UNNEST
        @ whew!

        _HEADER "TYPE", type
        _NEST
        CMP pstop, #0 @ check for early exit
        BLE typz

        LDR INDXA, [pt2nd] @ get the address

typl:
        LDR r0, [INDXA]
        BL sdk_emit @ emit the character
        ADD INDXA, #1 @ next in buffer
        SUB pstop, #1 @ count down
        BNE typl @ continue if count not zero

typz:
        ADD pt2nd, #_cell*2 @ we consumed two cells
        LDR pstop, [pt2nd, #_cell] @ fix top of stack
        _UNNEST

        @ number input/output
        _HEADER "BASE", "base"
        _NEST
        MOV r0, pstop
        _PUSHR0
        BL _base_addr
        MOV pstop, r0
        _UNNEST


@ finally, the text interpreter!!
        _HEADER "QUIT", quit

        @ we ***don't*** clear the return stack - that is a big hairy no-no!
        @ and we don't need _NEST / _UNNEST because we weren't called and won't
        @ return.
quil:
        @ push input buffer address and length to stack
        BL _inbuf_addr
        _PUSHR0
        BL _inbuf_length
        _PUSHR0

        @ get a line from user
        BL accept

        @ top of stack now has count
        BL _inbuf_addr
        _PUSHR0
        _SWAP

        @ and interpret
        BL evaluate

        @ repeat forever-ish
        B quil

        _HEADER "'", tick
        _NEST
        @ TBD
        _UNNEST

        _HEADER "EVALUATE", evaluate
        _NEST
        @ TBD
        _UNNEST

.global _system_dict_end
.set _system_dict_end, .

.global _system_last_link
.set _system_last_link, .
        .word _previous_link_address

_true:  .word 0xFFFFFFFF
