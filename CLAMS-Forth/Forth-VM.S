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

.include "Symbol-Defs.S"

.thumb_func

.global get_dict_start
get_dict_start:
        LDR r0, =_plus
        BX LR

.global get_dict_end
get_dict_end:
        LDR r0, =_dict_end
        BX LR

.data
.align _cell

_plus:
        .align _cell
        .byte 1
        .ascii "+"
        .align _cell
        .word 0
        SUB psp, psp, #_cell
        LDR r0, [psp]
        ADD tos, r0, tos
        _EXIT

_minus:
        .align _cell
        .byte 1
        .ascii "-"
        .align _cell
        .word . - _plus
        SUB psp, psp, #_cell
        LDR r0, [psp]
        SUB tos, r0, tos
        _EXIT
        
_star:
        .align _cell
        .byte 1
        .ascii "*"
        .align _cell
        .word . - _minus
        SUB psp, psp, #_cell
        LDR r0, [psp]
        MUL tos, r0, tos
        _EXIT

.set _dict_end, .
