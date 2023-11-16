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

        @ terminal I/O

.global _system_dict_end
.set _system_dict_end, .
