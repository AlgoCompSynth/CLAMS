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

pt2nd .req r7 @ pointer to second parameter stack cell
pstop .req r6 @ top cell of parameter stack

@ symbols for addressing expressions
.set _byte, 1 @ bytes
.set _cell, 4 @ bytes per cell

@ dictionary construction macros

        @ dictionary header

        @ name = word name in dictionary - what the Forth system searches for
        @ w_bytes = how many bytes in name
        @ h_label = label in the code for the header. By convention, this is
        @    the standard pronunciation for the word with an underscore
        @    prepended and dashes replaced by underscores.
        @ te_label = label in the code for the test entry point. By convention
        @    this is the standard pronunciation for the word with dashes
        @    replaced by underscores.
        @ h_link = backwards offset to previous word = the number of bytes to
        @    go back to find the previous word. Zero marks the end of the
        @    dictionary!

        .macro _DICT_HEADER name, w_bytes, h_label, te_label, h_link=0

        @ define header label
        .balign _cell, 0
        .set \h_label, .

        @ build name field
        .byte \w_bytes
        .ascii "\name"

        @ build link field
        .balign _cell, 0
        .if \h_link == 0
          .word 0
        .else
          .word . - \h_link
        .endif

        @ define test entry point
        .thumb_func
        .global \te_label
        .set \te_label, .

        .endm


        @ Common code for a word that uses a single instruction binary op on the
        @ top two stack cells. Such words have the stack effect
        @
        @    ( left right -- result )
        @
        @ For example, the postfix `left right <op>` has the same `result` as
        @ the infix `left <op> right`.
        .macro _BINARY_OP opcode
        LDR r0, [pt2nd] @ fetch left operand
        \opcode pstop, r0, pstop @ pstop := left <OP> pstop
        SUB pt2nd, #_cell @ "pop" the stack
        .endm

        @ return to caller
        .macro _EXIT
        BX LR
        .endm

        @ build a dictionary entry for a binary word
        .macro _BINARY_WORD word, w_bytes, h_label, te_label, opcode, h_link=0
        _DICT_HEADER \word, \w_bytes, \h_label, \te_label, \h_link
        _BINARY_OP \opcode
        _EXIT
        .endm

        @ macros for nested calls
        .macro _NEST
        PUSH {LR}
        .endm

        .macro _UNNEST
        POP {PC}
        .endm
