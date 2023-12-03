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

@ Stack logic:

@ The stacks grow from high addresses downwards. Register `PSP` points to the
@ top element of the parameter stack, and register `RSP` points to the top of the
@ return stack.

.include "SymbolDefs.S"

@ print top three cells of the parameter stack
.thumb_func
.global param_top3
param_top3:
        _sdk_nest
        LDR r0, =_param_format
        LDM PSP, { r1, r2, r3, PSP}
        BL printf
        _sdk_unnest

@ print top three cells of the return stack
.thumb_func
.global return_top3
return_top3:
        _sdk_nest
        LDR r0, =_return_format
        LDR r0, =_stack_format_3
        LDM RSP, { r1, r2, r3, RSP}
        BL printf
        _sdk_unnest

_param_format: .asciz "parameter stack top, second, third => %x, %x, %x\n"
_return_format: .asciz "return stack top, second, third => %x, %x, %x\n"

@ The stacks
.data
.balign _CELL, 0

@ parameter stack
.global _param_stack_top
.set _param_stack_top, .
        .rept _STACK_CELLS
        .word 0xdeadbeef
        .endr
.global _param_stack_bottom
.set _param_stack_bottom, .

        @ guard words
        .word 0xdeadbeef
        .word 0xdeadbeef

@ return stack
.global _return_stack_top
.set _return_stack_top, .
        .rept _STACK_CELLS
        .word 0xdeadbeef
        .endr
.global _return_stack_bottom
.set _return_stack_bottom, .

        @ guard words
        .word 0xdeadbeef
        .word 0xdeadbeef
