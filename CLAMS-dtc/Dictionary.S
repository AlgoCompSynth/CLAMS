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

@ parameter stack macros
@ stacks grow downwards and stack pointers point to top element

        @ pop to register from stack
        .macro _pop_to regname, stack
        LDM \stack\()P!, {\regname}
        .endm

        @ push to stack from register
        .macro _push_to stack regname
        SUB \stack\()P, #_CELL
        STR \regname, [\stack\()P]
        .endm

@ macros for external function calls

        @ nest
        .macro _x_nest
        PUSH {LR}
        .endm

        @ SDK unnest
        .macro _x_unnest
        POP {PC}
        .endm

        @ macro to create a "func_addr" word
        .macro _x_addr func_name
        .balign _CELL
        .set _addr_\func_name, .
        .word \func_name
        .endm

        @ macro to call a function via XRG
        .macro _x_call func_name
        LDR r0, _addr_\func_name @ get the address
        MOV XRG, #1 @ force the thumb bit before branching!
        ORR XRG, r0
        _x_nest
        BLX XRG
        _x_unnest
        .endm

@ dictionary construction macros

@ dictionary header

@ wname = word name in dictionary - what the Forth system searches for

@ pronunciation = Forth specifies how to pronounce many words. We make labels
@ from these, substituting an underscore for each dash in the pronunciation.

        @ generic word header
        .macro _header wname, pronunciation, flags=0x80

        @ build link field
        @ The CLAMS link field holds the distance in bytes to the previous link
        @ field
        .balign _CELL, 0
        .set _link_field, .
        .set _\pronunciation\()_link, . @ debugging symbol for link field
        .if _link_field == _system_dict_start
          .word 0
        .else
          .word _link_field - _previous_link_field
        .endif
        .set _previous_link_field, _link_field

        @ build name field
        .set _name_field, .
        .set _\pronunciation\()_name, . @ debugging symbol for name field

        @ The "count" field is eight bits, but we only need five bits for a 31
        @ character name. So we can use the upper 3 bits for flags:
        @ 0x80: definition is complete. Dictionary searches skip incomplete words.
        @ 0x40: definition is compile-only. The text interpreter throws an error on
        @       compile-only words.
        @ 0x20: definition is immediate. The compiler will execute it rather than
        @       compile it into the definition.
        .set _count, 1f - . - 1 | \flags\()
        .byte _count
        .ascii "\wname\()"
1:

        @ define global symbol for debugging / testing / internal reference.
        .balign _CELL, 0
        .thumb_func
        .global _\pronunciation\()
        .set _\pronunciation\(), .
        .endm

        @ assemble code field for a machine code word
        @ In direct threading, the code field has the first instruction(s) of the
        @ code, so this is empty.
        .macro _code_word
        .endm

        @ assemble code field for a colon definition
        .macro _colon_word
        .word _doLIST
        .endm

        @ "next" macro
        .macro _next
        LDR WRD, [INP] @ get next address
        ADD INP, #_CELL @ advance INP
        BX WRD @ jump to next code routine
        .endm

@ character codes
.set _NUL, 0x00 @ null / string terminator
.set _BEL, 0x07 @ bell
.set _BS, 0x08 @ backspace
.set _LF, 0x0A @ line feed
.set _CR, 0x0D @ carriage return
.set _BL, 0x20 @ space
.set _O, 0x4B @ letter "K"
.set _O, 0x4F @ letter "O"
.set _DEL, 0x7F @ delete / rubout

@ flags = various bits about the word
.set _COMPLETE, 0x80 @ word is complete - compiler sets this when done
.set _COMPILE_ONLY, 0x40 @ COMPILE-ONLY word
.set _IMMEDIATE, 0x20 @ IMMEDIATE word

@ inner interpreters
@ see F83
.global _doLIST
.thumb_func
_doLIST:
	ADD WRD, #_CELL @ point to first word of thread
        _push_to RS INP @ nest INP
        MOV INP, WRD @ "branch indirect" to INP
        _next

.global _doLIT
.thumb_func
_doLIT:
        ADD WRD, #_CELL @ point to constant
        LDR r0, [WRD]
        _push_to PS r0 @ push the constant
        _next

@ the dictionary itself!

.balign _CELL
.global _system_dict_start
_system_dict_start: .word .

        @ code words for base VM

        _header "DUP", dupe, _COMPLETE
        _code_word
        LDR r0, [PSP]
        _push_to PS, r0
        _next

        _header "OVER", over, _COMPLETE
        _code_word
        LDR r0, [PSP, #_CELL]
        _push_to PS, r0
        _next

        _header "SWAP", swap, _COMPLETE
        _code_word
        LDM PSP!, {r1, r2} @ top => r1, 2nd => r2
        _push_to PS, r1
        _push_to PS, r2
        _next

        _header "DROP", drop, _COMPLETE
        _code_word
        _pop_to r0, PS
        _next

        _header "ROT", rote, _COMPLETE
        _code_word
        @ x1, x2, x3 -> x2, x3, x1
        LDM PSP!, {r1, r2, r3} @ x3 => r1, x2 => r2, x1 => r3
        _push_to PS, r2 @ push x2
        _push_to PS, r1 @ push x3
        _push_to PS, r3 @ push x1
        _next

        @ terminal I/O words
        _header "KEY", key, _COMPLETE
        _code_word
        _x_call sdk_key
        _push_to PS, r0
        _next

        _header "EMIT", emit, _COMPLETE
        _code_word
        _pop_to r0, PS
        _x_call sdk_emit
        _next

        _header "EXECUTE", execute, _COMPLETE
        _code_word
        _pop_to r0, PS @ get execution token
        MOV XRG, #1 @ set thumb bit
        ORR XRG, r0 @ ready for BX
        BX XRG

        _header "param_top_3", param_top_3, _COMPLETE
        _code_word
        _x_nest
        LDR r0, =_param_format
        LDM PSP, { r1, r2, r3, PSP}
        _x_call printf
        _x_unnest

        _header "return_top_3", return_top_3, _COMPLETE
        _code_word
        _x_nest
        LDR r0, =_return_format
        LDR r0, =_stack_format_3
        LDM RSP, { r1, r2, r3, RSP}
        _x_call printf
        _x_unnest

_param_format: .asciz "parameter stack top, second, third => %x, %x, %x\n"
_return_format: .asciz "return stack top, second, third => %x, %x, %x\n"

@ BLX call vector table
_x_addr sdk_key
_x_addr sdk_emit
_x_addr printf

.global _system_dict_end
_system_dict_end: .word .

.global _system_dict_bytes
_system_dict_bytes: .word _system_dict_end - _system_dict_start

.global _last_system_link
_last_system_link: .word _previous_link_field
