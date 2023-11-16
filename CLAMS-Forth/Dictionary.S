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

@ pronunciation = Forth specifies how to pronounce most words. We make labels
@ from these, substituting an underscore for each dash in the pronunciation.

@ b_offset = backwards offset to previous word = the number of bytes to go back
@ to find the previous word. A backwards offset of zero marks the end of the
@ dictionary!

        .macro _DICT_HEADER wname, n_bytes, pronunciation, b_offset=0

        @ define header label
        .balign _cell, 0
        .set _\pronunciation, .

        @ build name field
        .byte \n_bytes
        .ascii "\wname"

        @ build link field
        .balign _cell, 0
        .if \b_offset == 0
          .word 0
        .else
          .word . - \b_offset
        .endif

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
        LDR r0, [pt2nd] @ fetch left operand
        \opcode pstop, r0, pstop @ pstop := left <OP> pstop
        SUB pt2nd, #_cell @ "pop" the stack
        .endm

        @ build a dictionary entry for a binary word
        .macro _BINARY_WORD wname, n_bytes, pronunciation, opcode, b_offset=0
        _DICT_HEADER \wname, \n_bytes, \pronunciation, \b_offset
        _BINARY_OP \opcode
        _EXIT
        .endm

@ dictionary functions

.global _system_dict_start
.set _system_dict_start, .

        @ binary operators
        _BINARY_WORD "+", 1, plus, ADD, 0
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
        MOV pstop, r0
        BL sdk_emit
        _DROP
        _UNNEST
        
@ character codes
.set _bs, 8 @ backspace
.set _lf, 10 @ line feed
.set _cr, 13 @ carriage return
.set _space, 32 @ space
.set _del, 127 @ delete

        _DICT_HEADER "ACCEPT", 6, accept, _emit
        _NEST

        @ On entry, the top of the stack has the maximum allowed characters and
        @ the second has the address of the buffer. On exit, the address has
        @ been consumed and the actual count is on the top of the stack.
        MOV tmpra, pstop @ save maximum count in `tmpra`
        LDR indxa, [pt2nd] @ load the address to `indxa`
        MOV pstop, #0 @ the count ends up here!
_accl:
        BL sdk_key @ wait for character, which will show up in r0

        @ test for specific control characters
        CMP r0, #_bs
        BEQ _accb @ do the backspace
        CMP r0, #_cr
        BEQ _accz @ clean up stack and exit
        CMP r0, #_lf
        BEQ _accz @ clean up stack and exit
        
        @ the rest are either standard printables or will be replaced by space
        CMP r0, #_space
        BLT _accs @ emit a space
        CMP r0, #_del
        BGE _accs @ emit a space

        @ an ordinary printable character - echo it and append to buffer
_acce:
        BL sdk_emit @ printable - send it out!

        STR r0, [indxa] @ append to buffer and count
        ADD indxa, #1
        ADD pstop, #1

        @ did we hit the limit?
        CMP pstop, tmpra
        BEQ _accz @ early exit if limit hit

	B _accl @ go back for more!

        @ space or unprintable
_accs:
        MOV r0, #_space @ force a space and emit / store / count
        B _acce

        @ backspace - uncount previous character and erase it
_accb:
        CMP pstop, #0 @ is buffer empty?
        BEQ accl @ ignore a backspace if buffer is empty

        @ un-count
        SUB indxa, #1
        SUB pstop, #1

        @ erase previous character
        BL sdk_emit
        MOV r0, #_space
        BL sdk_emit
        MOV r0, #_bs
        B _acce

        @ clean up and exit
_accz:
        @ stack top is correct - it has the count - but we need to fix `pt2nd`
        SUB pt2nd, #_cell
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
        SUB pt2nd, #_cell*2 @ we consumed two cells
        LDR pstop, [pt2nd, #_cell] @ fix top of stack
        _UNNEST

.global _system_dict_end
.set _system_dict_end, .