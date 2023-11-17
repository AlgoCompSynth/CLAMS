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

@ dictionary construction macros

@ dictionary header

@ wname = word name in dictionary - what the Forth system searches for

@ n_bytes = how many bytes in name

@ pronunciation = Forth specifies how to pronounce many words. We make labels
@ from these, substituting an underscore for each dash in the pronunciation.

@ b_offset = backwards offset to previous word = the number of bytes to go back
@ to find the previous word. A backwards offset of zero marks the end of the
@ dictionary!

        .macro _DICT_HEADER wname, n_bytes, pronunciation, b_offset=0

        @ define header label
        .balign _cell, 0
        .set _\pronunciation, .
        .set _last_offset, . - _system_dict_start

        @ build link field
        .if \b_offset == 0
          .word 0
        .else
          .word . - \b_offset
        .endif

        @ build name field
        .byte \n_bytes
        .ascii "\wname"
        .balign _cell, 0

        @ define test entry point
        .thumb_func
        .global \pronunciation
        .set \pronunciation, .

        .endm

@ Common code for a word that uses a single instruction binary operator on the
@ top two stack cells. Such words have the stack effect
@
@    ( left right -- result )
@
@ where `result` = `left <op> right`. That is, the postfix `left right <op>` has
@ the same `result` as the infix `left <op> right`.

        .macro _BINARY_OP opcode
        LDM pt2nd, {r0, pt2nd} @ pop left operand
        \opcode pstop, r0, pstop @ pstop := left <OP> pstop
        .endm

        @ build a dictionary entry for a binary word
        .macro _BINARY_WORD wname, n_bytes, pronunciation, opcode, b_offset=0
        _DICT_HEADER \wname, \n_bytes, \pronunciation, \b_offset
        _BINARY_OP \opcode
        _EXIT
        .endm

@ dictionary functions

.data
.balign _cell
.global _system_dict_start
.set _system_dict_start, .

        @ stack operators
        _DICT_HEADER "DROP", 4, drop, 0
        _DROP
        _EXIT

        _DICT_HEADER "DUP", 3, dupe, _drop
        _DUP
        _EXIT

        _DICT_HEADER "ROT", 3, rote, _dupe
        _ROT
        _EXIT

        _DICT_HEADER "SWAP", 4, swap, _rote
        _SWAP
        _EXIT

        _DICT_HEADER "!", 1, store, _swap
        LDM pt2nd!, {r0-r1}
        STR r0, [pstop]
        MOV pstop, r1
        _EXIT

        _DICT_HEADER "+!", 2, plus_store, _store
        LDM pt2nd!, {r0-r1}
        LDR r2, [pstop]
        ADD r2, r0
        STR r2, [pstop]
        MOV pstop, r1
        _EXIT

        _DICT_HEADER "0<", 2, zero_less, _plus_store
        CMP pstop, #0
        BLT _c1
        MOV pstop, #0
        _EXIT
_c1:
        LDR pstop, _true
        _EXIT

        _DICT_HEADER "0=", 2, zero_equals, _zero_less
        CMP pstop, #0
        BEQ _c2
        MOV pstop, #0
        _EXIT
_c2:
        LDR pstop, _true
        _EXIT

        _DICT_HEADER "1+", 2, one_plus, _zero_equals
        ADD pstop, #1
        _EXIT

        _DICT_HEADER "1-", 2, one_minus, _one_plus
        SUB pstop, #1
        _EXIT

        _DICT_HEADER "2*", 2, two_star, _one_minus
        LSL pstop, #1
        _EXIT

        _DICT_HEADER "2/", 2, two_slash, _two_star
        ASR pstop, #1
        _EXIT

@ next up <
        @ binary operators
        _BINARY_WORD "+", 1, plus, ADD, _two_slash
        _BINARY_WORD "-", 1, minus, SUB, _plus
        _BINARY_WORD "*", 1, star, MUL, _minus
        _BINARY_WORD "AND", 3, and, AND, _star
        _BINARY_WORD "OR", 2, or, ORR, _and
        _BINARY_WORD "XOR", 3, x_or, EOR, _or

        @ terminal I/O words
        _DICT_HEADER "KEY", 3, key, _x_or
        _NEST
        BL sdk_key
        _PUSHR0
        _UNNEST

        _DICT_HEADER "EMIT", 4, emit, _key
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

        _DICT_HEADER "ACCEPT", 6, accept, _emit
        _NEST

        @ On entry, the top of the stack has the maximum allowed characters and
        @ the second has the address of the buffer. On exit, the address has
        @ been consumed and the actual count is on the top of the stack.
        MOV tmpra, pstop @ save maximum count in `tmpra`
        LDR indxa, [pt2nd] @ load the address to `indxa`
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
        STR r0, [indxa] @ append to buffer
        BL sdk_emit @ printable - send it out!

        @ count
        ADD indxa, #1
        ADD pstop, #1
        CMP pstop, tmpra @ did we hit the limit?
        BEQ _accz @ early exit if limit hit
	B _accl @ go back for more!

        @ space or unprintable
_accs:
        MOV r0, #_bl @ force a space and emit / store / count
        B _acce

        @ backspace - uncount previous character and erase it
_accb:
        CMP pstop, #0 @ is buffer empty?
        BEQ accl @ ignore a backspace if buffer is empty

        @ un-count
        SUB indxa, #1
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

        _DICT_HEADER "TYPE", 4, type, _accept
        _NEST
        CMP pstop, #0 @ check for early exit
        BLE typz

        LDR indxa, [pt2nd] @ get the address

typl:
        LDR r0, [indxa]
        BL sdk_emit @ emit the character
        ADD indxa, #1 @ next in buffer
        SUB pstop, #1 @ count down
        BNE typl @ continue if count not zero

typz:
        ADD pt2nd, #_cell*2 @ we consumed two cells
        LDR pstop, [pt2nd, #_cell] @ fix top of stack
        _UNNEST

@ finally, the text interpreter!!
        _DICT_HEADER "QUIT", 4, quit, _accept

        @ we ***don't*** clear the return stack - that is a big hairy no-no!
        @ and we don't need _NEST / _UNNEST because we weren't called and won't
        @ return.
quil:
        @ push input buffer address and length to stack
        BL _inbuf_addr
        _PUSHR0
        BL _inbuf_max
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

        _DICT_HEADER "EVALUATE", 8, evaluate, _quit
        _NEST
        @ TBD
        _UNNEST

.global _system_dict_end
.set _system_dict_end, .

.global _system_last_offset
.set _system_last_offset, .
        .word _last_offset

_true:   .word 0xFFFFFFFF
