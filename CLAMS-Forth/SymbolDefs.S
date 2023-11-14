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

@ parameter stack coding

@ 1. The stack grows from low to high memory addresses. This makes things easy
@    when we want to push / pull multiple cells.

@ 2. The top of the stack is in the `tos` register. It is *not* saved in RAM.

@ 3. The parameter stack pointer `psp` points to where the top of the stack
@    would be if it was in RAM.

psp .req r7 @ parameter stack pointer
tos .req r6 @ top of stack value

@ symbols for addressing expressions
.set _byte, 1 @ bytes
.set _cell, 4 @ bytes per cell

@ dictionary construction macros

        @ dictionary header

        @ name = word name in dictionary - what the Forth system searches for
        @ w_bytes = how many bytes in name
        @ h_label = label in the code for the header. By convention, this is
        @           the standard pronunciation for the word with an underscore
        @           prepended and dashes replaced by underscores.
        @ te_label = label in the code for the test entry point. By convention
        @            this is the standard pronunciation for the word with an
        @            dashes replaced by underscores.
        @ h_link = backwards offset to previous word = the number of bytes to
        @          go back to find the previous word. Zero marks the end of the
        @          dictionary!

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


        @ code for word using single instruction binary op on top 2 stack cells
        .macro _BINARY_OP opcode
        SUB psp, psp, #_cell @ decrement stack pointer first
        LDR r0, [psp] @ get second cell to r0
        \opcode tos, r0, tos @ second cell <OP> top cell
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
