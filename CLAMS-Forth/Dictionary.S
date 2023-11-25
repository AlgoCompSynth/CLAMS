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

        @ We need to call our SDK wrappers with a BLX; they're too far away for BL.
        .macro _SDK_FUNC_CALL name
        .global \name
        LDR r3, =\name @ get the address
        BLX r3
        .endm

@ dictionary construction macros

@ dictionary header

@ wname = word name in dictionary - what the Forth system searches for

@ pronunciation = Forth specifies how to pronounce many words. We make labels
@ from these, substituting an underscore for each dash in the pronunciation.

@ flags = various bits about the word
.set _IMMEDIATE, 1
.set _COMPILE_ONLY, 2

        .macro _HEADER wname, pronunciation, flags=0

        @ define header label
        .balign _CELL, 0
        .set _name_field, .
        .set _link_field, _name_field + 32
        .set _flags_field, link_field + 2
        .set _code_field, flags_field + 2

        @ build name field
        .set _\pronunciation\()_name, . @ debugging symbol for name field
        .set _count, 1f - . - 1
        .byte _count
        .ascii "\wname"
1:

        @ build link field
        .set _padding, _link_field - .
        .if _padding > 0
          .rept _padding
          .byte 0
          .endr
        .endif

        .set _\pronunciation\()_link, . @ debugging symbol for link field
        .if .name_field == _system_dict_start
          .hword 0
        .else
          .hword _name_field - _previous_name_field
        .endif
        .set _previous_name_field, _name_field

        @ build flags field
        .set _\pronunciation\()_flags, . @ debugging symbol for flags field
        .hword \flags

        @ define call entry point to code field
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

        .macro _BINARY_ALU opcode
        LDM PT2ND!, {r0} @ pop left operand => r0
        \opcode\() PSTOP, r0, PSTOP @ PSTOP := left <OP> PSTOP
        .endm

@ same thing for comparisons!
        .macro _BINARY_CMP opcode
        LDM PT2ND!, {r0} @ pop left operand => r0
        CMP r0, PSTOP
        \opcode\() 1f @ branch if true
        MOV PSTOP, #0 @ false - set flag to zero
        B 2f
1:
        MOV PSTOP, #0
        MVN PSTOP, PSTOP @ set all-ones true flag
2:
        .endm

        @ terminate an inline word
        .macro _ITRM
        .hword 0xFFFF
        .endm

@ character codes
.set _BS, 8 @ backspace
.set _CR, 13 @ carriage return
.set _BL, 32 @ space
.set _DEL, 127 @ delete

@ the dictionary itself!
.data
.balign _CELL

        @ The first group of operators are simple enough that they can be copied
        @ inline to a colon word instead of called. This saves two cycles for
        @ each inlined word whenever the colon word is called.

        @ For readability, we have two forms of each in the dictionary. For
        @ example, "+" (plus) is the callable form and "+_" (plus_underscore) is the
        @ inline form.

        @ stack operators
        _HEADER "DROP", drop
        _DROP
        _EXIT
        _HEADER "DROP_", drop_underscore, _COMPILE_ONLY
        _DROP
        _ITRM

        _HEADER "DUP", dupe
        _DUP
        _EXIT
        _HEADER "DUP_", dupe_underscore, _COMPILE_ONLY
        _DUP
        _ITRM

        _HEADER "OVER", over
        _OVER
        _EXIT
        _HEADER "OVER_", over_underscore, _COMPILE_ONLY
        _OVER
        _ITRM

        _HEADER "ROT", rote
        _ROT
        _EXIT
        _HEADER "ROT_", rote_underscore, _COMPILE_ONLY
        _ROT
        _ITRM

        _HEADER "SWAP", swap
        _SWAP
        _EXIT
        _HEADER "SWAP_", swap_underscore, _COMPILE_ONLY
        _SWAP
        _ITRM

        _HEADER "@", fetch
        LDR PSTOP, [PSTOP]
        _EXIT
        _HEADER "@_", fetch_underscore, _COMPILE_ONLY
        LDR PSTOP, [PSTOP]
        _ITRM

        _HEADER "!", store
        LDM PT2ND!, {r0-r1}
        STR r0, [PSTOP]
        MOV PSTOP, r1
        _EXIT
        _HEADER "!_", store_underscore, _COMPILE_ONLY
        LDM PT2ND!, {r0-r1}
        STR r0, [PSTOP]
        MOV PSTOP, r1
        _ITRM

        _HEADER "+!", plus_store
        LDM PT2ND!, {r0-r1}
        LDR r2, [PSTOP]
        ADD r2, r0
        STR r2, [PSTOP]
        MOV PSTOP, r1
        _EXIT
        _HEADER "+!_", plus_store_underscore, _COMPILE_ONLY
        LDM PT2ND!, {r0-r1}
        LDR r2, [PSTOP]
        ADD r2, r0
        STR r2, [PSTOP]
        MOV PSTOP, r1
        _ITRM

        _HEADER "1+", one_plus
        ADD PSTOP, #1
        _EXIT
        _HEADER "1+_", one_plus_underscore, _COMPILE_ONLY
        ADD PSTOP, #1
        _ITRM

        _HEADER "1-", one_minus
        SUB PSTOP, #1
        _EXIT
        _HEADER "1-_", one_minus_underscore, _COMPILE_ONLY
        SUB PSTOP, #1
        _ITRM

        _HEADER "2*", two_star
        LSL PSTOP, #1
        _EXIT
        _HEADER "2*_", two_star_underscore, _COMPILE_ONLY
        LSL PSTOP, #1
        _ITRM

        _HEADER "2/", two_slash
        ASR PSTOP, #1
        _EXIT
        _HEADER "2/_", two_slash_underscore, _COMPILE_ONLY
        ASR PSTOP, #1
        _ITRM

        @ arithmetic operators
        _HEADER "+", plus
        _BINARY_ALU ADD
        _EXIT
        _HEADER "+_", plus_underscore, _COMPILE_ONLY
        _BINARY_ALU ADD
        _ITRM

        _HEADER "-", minus
        _BINARY_ALU SUB
        _EXIT
        _HEADER "-_", minus_underscore, _COMPILE_ONLY
        _BINARY_ALU SUB
        _ITRM

        _HEADER "*", star
        _BINARY_ALU MUL
        _EXIT
        _HEADER "*_", star_underscore, _COMPILE_ONLY
        _BINARY_ALU MUL
        _ITRM

        _HEADER "NEGATE", negate
        MVN PSTOP, PSTOP
        _EXIT
        _HEADER "NEGATE_", negate_underscore, _COMPILE_ONLY
        MVN PSTOP, PSTOP
        _ITRM

        @ boolean operators
        _HEADER "AND", and
        _BINARY_ALU AND
        _EXIT
        _HEADER "AND_", and_underscore, _COMPILE_ONLY
        _BINARY_ALU AND
        _ITRM

        _HEADER "OR", or
        _BINARY_ALU ORR
        _EXIT
        _HEADER "OR_", or_underscore, _COMPILE_ONLY
        _BINARY_ALU ORR
        _ITRM

        _HEADER "XOR", x_or
        _BINARY_ALU EOR
        _EXIT
        _HEADER "XOR_", x_or_underscore, _COMPILE_ONLY
        _BINARY_ALU EOR
        _ITRM

        _HEADER "INVERT", invert
        MVN PSTOP, PSTOP
        _EXIT
        _HEADER "INVERT_", invert_underscore, _COMPILE_ONLY
        MVN PSTOP, PSTOP
        _ITRM

        _HEADER "LSHIFT", l_shift
        LDM PT2ND!, {r0}
        LSL r0, PSTOP
        MOV PSTOP, r0
        _EXIT
        _HEADER "LSHIFT_", l_shift_underscore, _COMPILE_ONLY
        LDM PT2ND!, {r0}
        LSL r0, PSTOP
        MOV PSTOP, r0
        _ITRM

        _HEADER "RSHIFT", r_shift
        LDM PT2ND!, {r0}
        LSR r0, PSTOP
        MOV PSTOP, r0
        _EXIT
        _HEADER "RSHIFT_", r_shift_underscore, _COMPILE_ONLY
        LDM PT2ND!, {r0}
        LSR r0, PSTOP
        MOV PSTOP, r0
        _ITRM

        @ binary comparison operators
        _HEADER "<", less_than
        _BINARY_CMP BLT
        _EXIT

        _HEADER "<=", less_or_equals
        _BINARY_CMP BLE
        _EXIT

        _HEADER "=", equals
        _BINARY_CMP BEQ
        _EXIT

        _HEADER "<>", not_equals
        _BINARY_CMP BNE
        _EXIT

        _HEADER ">", greater_than
        _BINARY_CMP BGT
        _EXIT

        _HEADER ">=", greater_or_equals
        _BINARY_CMP BGE
        _EXIT

        _HEADER "U>", u_greater_than
        _BINARY_CMP BHI
        _EXIT

        _HEADER "U>=", u_greater_or_equals
        _BINARY_CMP BHS
        _EXIT

        _HEADER "U<", u_less_than
        _BINARY_CMP BLO
        _EXIT

        _HEADER "U<=", u_less_or_equals
        _BINARY_CMP BLS
        _EXIT

        @ division operators - use the SDK and hardware divider
        _HEADER "/MOD", slash_mod
        _NEST
        LDR r0, [PT2ND] @ dividend => r0
        MOV r1, PSTOP @ divisor => r1
        _SDK_FUNC_CALL sdk_slash_mod
        MOV PSTOP, r0 @ quotient => top of stack
        STR r1, [PT2ND] @ remainder => 2nd
        _UNNEST

        _HEADER "/", slash
        _NEST
        _SDK_FUNC_CALL sdk_slash_mod
        _SWAP
        _DROP
        _UNNEST

        _HEADER "MOD", mod
        _NEST
        _SDK_FUNC_CALL sdk_slash_mod
        _DROP
        _UNNEST

        @ terminal I/O words
        _HEADER "KEY", key
        _NEST
        _SDK_FUNC_CALL sdk_key
        _PUSHR0
        _UNNEST

        _HEADER "EMIT", emit
        _NEST
        MOV r0, PSTOP
        _SDK_FUNC_CALL sdk_emit
        _DROP
        _UNNEST

        _HEADER "ACCEPT", accept
        _NEST

        @ On entry, the top of the stack has the maximum allowed characters and
        @ the second has the address of the buffer. On exit, the address has
        @ been consumed and the actual count is on the top of the stack.
        MOV r11, PSTOP @ save maximum count in `r11`
        MOV PSTOP, #0 @ the actual count ends up here!
_accl:
        _SDK_FUNC_CALL sdk_key @ wait for character, which will show up in r0

        @ test for specific control characters
        CMP r0, #_BS
        BEQ _accb @ do the backspace
        CMP r0, #_CR
        BEQ _accz @ line finished - clean up stack and exit
        
        @ the rest are either standard printables or will be replaced by space
        CMP r0, #_BL
        BLE _accs @ emit and append a space
        CMP r0, #_DEL
        BGE _accs @ emit and append a space

        @ an ordinary printable character - echo it and append to buffer
_acce:
        LDR r3, [PT2ND] @ buffer address is in second of stack!
        STRB r0, [r3, PSTOP] @ append char to buffer
        _SDK_FUNC_CALL sdk_emit @ printable - send it out!

        @ count
        ADD PSTOP, #1 @ character count
        CMP PSTOP, r11 @ did we hit the limit?
        BEQ _accz @ early exit if limit hit!
	B _accl @ there's room - go back for more!

        @ space or unprintable
_accs:
        MOV r0, #_BL @ force a space and emit / store / count
        B _acce

        @ backspace - un-count previous character and erase it
_accb:
        CMP PSTOP, #0 @ is buffer empty?
        BEQ _accl @ ignore a backspace if buffer is empty

        @ un-count
        SUB PSTOP, #1 @ decrement char count

        @ erase previous character
        _SDK_FUNC_CALL sdk_emit @ emit the backspace we have
        MOV r0, #_BL
        _SDK_FUNC_CALL sdk_emit @ "erase" the character
        MOV r0, #_BS @ queue up another backspace
        _SDK_FUNC_CALL sdk_emit
        B _accl @ back for more!

        @ clean up and exit
_accz:
        @ stack top is correct - it has the count - but we need to fix `PT2ND`
        ADD PT2ND, #_CELL
        _UNNEST
        @ whew!

        _HEADER "TYPE", type
        _NEST
        @ count is in PSTOP
        CMP PSTOP, #0 @ check for early exit
        BLE typz
        LDR r3, [PT2ND] @ get the address into r11

typl:
        LDRB r0, [r3] @ get the character
        MOV r11, r3 @ save r3 before function call!
        _SDK_FUNC_CALL sdk_emit @ emit the character
        MOV r3, r11 @ restore r3
        ADD r3, #1 @ increment the address
        SUB PSTOP, #1 @ count down
        BGT typl @ continue if count not zero

typz:
        ADD PT2ND, #_CELL*2 @ we consumed two cells
        LDR PSTOP, [PT2ND, #_CELL] @ fix top of stack
        _UNNEST

        @ number input/output
        _HEADER "BASE", "base"
        _NEST
        _DUP
        BL _base_addr
        MOV PSTOP, r0
        _UNNEST

        @ parsing
        _HEADER ">IN", "to_in"
        _NEST
        _DUP
        BL _to_in_addr
        MOV PSTOP, r0
        _UNNEST

        _HEADER "SOURCE", "source"
        _NEST
        _DUP @ make room for two cells on the stack
        _DUP
        BL _tib_addr @ address of _tib => r0
        LDRB PSTOP, [r0] @ count => PSTOP
        ADD r0, #1 @ point to first non-count character
        STR r0, [PT2ND] @ address => 2nd
        _UNNEST

        _HEADER "PARSE-NAME", "parse_name"
        _NEST
        BL source @ buffer address in [PT2ND], count in PSTOP
        _DROP @ drop count - buffers are null-terminated
        _TO_INDX A @ pop address to INDXA
        BL to_in @ get address of input buffer count
        _TO_INDX B @ pop >IN address to INDXB
        LDR r3, [INDXB] @ >IN to r3

pn1:
        LDRB r2, [INDXA, r3] @ get a character
        CMP r2, #0 @ buffers are null-terminated
        BEQ pnz @ that's all, folks!
        CMP r2, #_BL @ is it a space?
        BNE pn2 @ first non-delimiter!
        ADD r3, #_CHAR
        B pn1 @ next character

pn2:
        ADD r0, INDXA, r3 @ we have the buffer address!
        _PUSHR0 @ push it to the stack
        MOV r1, #1 @ initial count

pn3:
        ADD r3, #_CHAR
        LDRB r2, [INDXA, r3]
        CMP r2, #0
        BEQ pnz
        CMP r2, #_BL
        BEQ pnz @ blank - finish up
        ADD r1, #1 @ count and go back for more
        B pn3

pnz:
        STR r3, [INDXB] @ first order of business - save new >IN value
        MOV r0, r1 @ push count and exit
        _PUSHR0
        _UNNEST 

@ finally, the text interpreter!!
        _HEADER "QUIT", quit

        @ we ***don't*** clear the return stack - that is a big hairy no-no!
        @ and we don't need _NEST / _UNNEST because we weren't called and won't
        @ return.
quil:
        @ push input buffer address and length to stack
        BL _tib_addr
        _PUSHR0
        BL _tib_maxl
        _PUSHR0

        @ get a line from user
        BL accept

        @ top of stack now has count
        BL _tib_addr
        _PUSHR0
        _SWAP

        @ and interpret
        BL evaluate

        @ repeat forever-ish
        B quil

        _HEADER "'", tick
        _NEST
        @ TBD
        _UNNEST

        _HEADER "EVALUATE", evaluate
        _NEST
        @ TBD
        _UNNEST
