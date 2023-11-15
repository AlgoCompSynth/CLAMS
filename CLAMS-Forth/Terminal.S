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

@ Terminal operations and testing

.include "SymbolDefs.S"

@ character codes
.set _bs, 8 @ backspace
.set _lf, 10 @ line feed
.set _cr, 13 @ carriage return
.set _space, 32 @ space
.set _del, 127 @ delete
.set _o, 111
.set _k, 107

.thumb_func
.global echo

echo:
        _NEST @ save link register
        MOV r4, #_del @ bit mask for AND

loop:
        BL sdk_key @ wait for character, which will show up in r0
        AND r0, r4 @ seven bits - party like it's 1968

        @ test for specific control characters
        CMP r0, #_bs
        BEQ backspace
        CMP r0, #_cr
        BEQ ok
        CMP r0, #_lf
        BEQ ok
        
        @ the rest are either standard printables or will be replaced by space
        CMP r0, #_space
        BLT space
        CMP r0, #_del
        BGE space

        @ printable - send it out!
emit:
        BL sdk_emit

        @ and go back for more!
	B loop

space:
        MOV r0, #_space
        B emit

backspace:
        BL sdk_emit
        MOV r0, #_space
        BL sdk_emit
        MOV r0, #_bs
        B emit

ok:
        MOV r0, #_space
        BL sdk_emit
        MOV r0, #_space
        BL sdk_emit
        MOV r0, #_o @ Starting to look like Forth :-)
        BL sdk_emit
        MOV r0, #_k
        BL sdk_emit
        MOV r0, #_space
        BL sdk_emit
        MOV r0, #_cr
        BL sdk_emit
        MOV r0, #_lf
        BL sdk_emit
        _UNNEST
