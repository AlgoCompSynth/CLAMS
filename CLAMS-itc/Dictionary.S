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

@ pronunciation = Forth specifies how to pronounce many words. We make labels
@ from these, substituting an underscore for each dash in the pronunciation.

@ flags = various bits about the word
.set _IMMEDIATE, 1 @ IMMEDIATE word
.set _COMPILE_ONLY, 2 @ COMPILE-ONLY word
.set _COMPLETE, 0x8000 @ word is complete - compiler sets this when done

        @ generic word header
        .macro _header wname, pronunciation, flags=0x8000

        @ build link field
        .balign _CELL, 0
        .set _link_field, .
        .set _\pronunciation\()_link, . @ debugging symbol for link field
        .if _link_field == _system_dict_start
          .hword 0
        .else
          .hword _link_field - _previous_link_field
        .endif
        .set _previous_link_field, _link_field

        @ build flags field
        .set _flags_field, .
        .set _\pronunciation\()_flags, . @ debugging symbol for flags field
        .hword \flags

        @ build name field
        .set _\pronunciation\()_name, . @ debugging symbol for name field
        .set _count, 1f - . - 1
        .byte _count
        .ascii "\wname\()"
1:

        @ define global address of code field
        .balign _CELL, 0
        .thumb_func
        .global \pronunciation
        .set \pronunciation, .

        .endm

        @ header for a CODE word
        .macro _code wname, pronunciation, flags=0x8000
        _header \wname\(), \pronunciation\(), flags\()
`
        @ The inner interpreter loads the CODE field into a register and does a BX
        @ to the register. So the CODE field must have the lowest bit set.
        .word . + _CELL | 1
        .endm

@ character codes
.set _BEL, 0x07 @ bell
.set _BS, 0x08 @ backspace
.set _LF, 0x0A @ line feed
.set _CR, 0x0D @ carriage return
.set _BL, 0x20 @ space
.set _O, 0x4B @ letter "K"
.set _O, 0x4F @ letter "O"
.set _DEL, 0x7F @ delete

@ the dictionary itself!

.balign _CELL
.global _system_dict_start
_system_dict_start: .word .

        @ code words for base VM

        _header "DUP", dupe, _COMPLETE
        LDR r0, [PSP]
        _push_from_reg r0
        _next

        _header "OVER", over, _COMPLETE
        LDR r0, [PSP, #_CELL]
        _push_from_reg r0
        _next

        _header "SWAP", swap, _COMPLETE
        LDM PSP!, {r1, r2} @ top => r1, 2nd => r2
        _push_from_reg r1
        _push_from_reg r2
        _next

        _header "DROP", drop, _COMPLETE
        _pop_to_reg r0
        _next

        _header "ROT", rote, _COMPLETE
        @ x1, x2, x3 -> x2, x3, x1
        LDM PSP!, {r1, r2, r3} @ x3 => r1, x2 => r2, x1 => r3
        _push_from_reg r2 @ push x2
        _push_from_reg r1 @ push x3
        _push_from_reg r3 @ push x1
        _next

.global _system_dict_end
_system_dict_end: .word .

.global _system_dict_bytes
_system_dict_bytes: .word _system_dict_end - _system_dict_start
