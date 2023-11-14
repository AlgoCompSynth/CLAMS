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

@ dictionary functions
.thumb_func
.global get_dict_start
get_dict_start:
        LDR r0, =_plus
        _EXIT

.thumb_func
.global get_dict_end
get_dict_end:
        LDR r0, =_dict_end
        _EXIT

.set _dict_start, .

        _BINARY_WORD "+", 1, _plus, plus, ADD, 0
        _BINARY_WORD "-", 1, _minus, minus, SUB, _plus
        _BINARY_WORD "*", 1, _star, star, MUL, _minus
        _BINARY_WORD "AND", 3, _and, and, AND, _star
        _BINARY_WORD "OR", 2, _or, or, ORR, _and
        _BINARY_WORD "XOR", 3, _x_or, x_or, EOR, _or

.set _dict_end, .
