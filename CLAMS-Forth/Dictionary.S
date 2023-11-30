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
.set _INLINE, 4 @ word can be inlined
.set _COMPLETE, 0x8000 @ word is complete - compiler sets this when done

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

        @ define call entry point to code field
        .balign _CELL, 0
        .thumb_func
        .global \pronunciation
        .set \pronunciation, .

        .endm

@ character codes
.set _BS, 8 @ backspace
.set _CR, 13 @ carriage return
.set _BL, 32 @ space
.set _DEL, 127 @ delete

@ the dictionary itself!

.balign _CELL
.global _system_dict_start
_system_dict_start: .word .

        @ The first group of operators are simple enough that they can be copied
        @ inline to a colon word instead of called. This saves two cycles for
        @ each inlined word whenever the colon word is called. These are all
        @ defined as macros in SymbolDefs.S, so we can define a macro that creates
        @ them with a single line each.

        .macro _wrapm name, pronunciation
        _header "\name\()", \pronunciation\(), _COMPLETE + _INLINE
        _\pronunciation\()
        _return
        .endm

        @ stack operators
        _wrapm "DROP", drop
        _wrapm "DUP", dupe
        _wrapm "OVER", over
        _wrapm "ROT", rote
        _wrapm "SWAP", swap
        _wrapm "@", fetch
        _wrapm "!", store
        _wrapm "+!", plus_store
        _wrapm "1+", one_plus
        _wrapm "1-", one_minus
        _wrapm "2*", two_star
        _wrapm "2/", two_slash

        @ arithmetic operators
        _wrapm "+", plus
        _wrapm "-", minus
        _wrapm "*", star
        _wrapm "NEGATE", negate

        @ boolean operators
        _wrapm "AND", and
        _wrapm "OR", or
        _wrapm "XOR", x_or
        _wrapm "INVERT", invert
        _wrapm "LSHIFT", l_shift
        _wrapm "RSHIFT", r_shift

        @ binary comparison operators
        _wrapm "<", less_than
        _wrapm "<=", less_or_equal
        _wrapm "=", equals
        _wrapm "<>", not_equal
        _wrapm ">", greater_than
        _wrapm ">=", greater_or_equal
        _wrapm "U>", u_greater_than
        _wrapm "U>=", u_greater_or_equal
        _wrapm "U<", u_less_than
        _wrapm "U<=", u_less_or_equal

        @ character / string words
        _header "FILL", fill, _COMPLETE
        MOV r0, PSTOP @ character => r0
        _drop
        MOV r3, PSTOP @ count => r3
        _drop @ address now in PSTOP

fil1:
        CMP r3, #0 @ is count zero or less?
        BLE filz @ exit, stage left!
        STRB r0, [PSTOP]
        ADD PSTOP, #_CHAR
        SUB r3, #1
        B fil1
filz:
        @ done - one last _drop
        _drop
        _return

        _header "_clear_tib", _clear_tib, _COMPLETE
        _nest
        @_x_call _tib_init
        BL _tib_init
        _unnest

        _header "ACCEPT", accept, _COMPLETE
        _nest

        @ On entry, the top of the stack has the maximum allowed characters and
        @ the second has the address of the buffer. On exit, the address has
        @ been consumed and the actual count is on the top of the stack.
        _to_reg MPTRX @ pop max count to MPTRX
        _to_reg INDXA @ pop address to INDXA
        MOV INDXB, #0 @ 0 to counter
_accl:
        BL key @ wait for character, which will show up in PSTOP

        @ test for specific control characters
        CMP PSTOP, #_BS
        BEQ _accb @ do the backspace
        CMP PSTOP, #_CR
        BEQ _accz @ line finished - clean up stack and exit
        
        @ the rest are either standard printables or will be replaced by space
        CMP PSTOP, #_BL
        BLE _accs @ emit and append a space
        CMP PSTOP, #_DEL
        BGE _accs @ emit and append a space

        @ an ordinary printable character - echo it and append to buffer
_acce:
        STRB PSTOP, [INDXA, INDXB] @ append char to buffer
        BL emit @ printable - send it out!

        @ count
        ADD INDXB, #1 @ character count
        CMP INDXB, MPTRX @ did we hit the limit?
        BEQ _accz @ early exit if limit hit!
	B _accl @ there's room - go back for more!

        @ space or unprintable
_accs:
        MOV PSTOP, #_BL @ force a space and emit / store / count
        B _acce

        @ backspace - un-count previous character and erase it
_accb:
        CMP INDXB, #0 @ is buffer empty?
        BEQ _accl @ ignore a backspace if buffer is empty

        @ un-count
        SUB INDXB, #1 @ decrement char count

        @ erase previous character
        BL emit @ emit the backspace we have
        MOV r0, #_BL
        _reg_from r0
        BL emit @ "erase" the character
        MOV r0, #_BS @ queue up another backspace
        _reg_from r0
        BL emit
        B _accl @ back for more!

        @ clean up and exit
_accz:
        @ push count and exit
        _reg_from INDXB
        _unnest
        @ whew!

        _header "TYPE", type, _COMPLETE
        _nest
        _to_reg INDXB @ count to INDXB
        _to_reg INDXA @ address to INDXA

typl:
        CMP INDXB, #0 @ are we done?
        BLE typz @ exit!

        LDRB r0, [INDXA] @ get the character
        CMP r0, #0 @ is it a null terminator?
        BEQ typz @ exit on null terminator
        _reg_from r0
        BL emit @ emit the character
        ADD INDXA, #1 @ increment the address
        SUB INDXB, #1 @ count down
        BGT typl @ continue

typz:
        _unnest

        @ number input/output
        _header "BASE", "base", _COMPLETE
        _nest
        _dupe
        BL _base_addr
        MOV PSTOP, r0
        _unnest

        @ parsing
        _header ">IN", "to_in", _COMPLETE
        _nest
        _dupe
        BL _to_in_addr
        MOV PSTOP, r0
        _unnest

        @ _header "SOURCE", "source", _COMPLETE
        @ _nest
        @ _dupe @ make room for two cells on the stack
        @ _dupe
        @ BL _tib_addr @ address of _tib => r0
        @ LDRB PSTOP, [r0] @ count => PSTOP
        @ ADD r0, #1 @ point to first non-count character
        @ STR r0, [PT2ND] @ address => 2nd
        @ _unnest

        @ _header "PARSE-NAME", "parse_name", _COMPLETE
        @ _nest
        @ BL source @ buffer address in [PT2ND], count in PSTOP
        @ _drop @ drop count - buffers are null-terminated
        @ _to_reg INDXA @ pop address to INDXA
        @ BL to_in @ get address of input buffer count
        @ _to_reg INDXB @ pop >IN address to INDXB
        @ LDR r3, [INDXB] @ >IN to r3

pn1:
        @ LDRB r2, [INDXA, r3] @ get a character
        @ CMP r2, #0 @ buffers are null-terminated
        @ BEQ pnz @ that's all, folks!
        @ CMP r2, #_BL @ is it a space?
        @ BNE pn2 @ first non-delimiter!
        @ ADD r3, #_CHAR
        @ B pn1 @ next character

pn2:
        @ ADD r0, INDXA, r3 @ we have the buffer address!
        @ _reg_from r0 @ push it to the stack
        @ MOV r1, #1 @ initial count

pn3:
        @ ADD r3, #_CHAR
        @ LDRB r2, [INDXA, r3]
        @ CMP r2, #0
        @ BEQ pnz
        @ CMP r2, #_BL
        @ BEQ pnz @ blank - finish up
        @ ADD r1, #1 @ count and go back for more
        @ B pn3

pnz:
        @ STR r3, [INDXB] @ first order of business - save new >IN value
        @ MOV r0, r1 @ push count and exit
        @ _reg_from r0
        @ _unnest 

@ finally, the text interpreter!!
        @ _header "QUIT", quit, _COMPLETE

        @ we ***don't*** clear the return stack - that is a big hairy no-no!
        @ and we don't need _nest / _unnest because we weren't called and won't
        @ return.
quil:
        @ push input buffer address and length to stack
        @ BL _tib_addr
        @ _reg_from r0
        @ BL _tib_maxl
        @ _reg_from r0

        @ get a line from user
        @ BL accept

        @ top of stack now has count
        @ BL _tib_addr
        @ _reg_from r0
        @ _SWAP

        @ and interpret
        @ BL evaluate

        @ repeat forever-ish
        @ B quil

        _header "'", tick, _COMPLETE
        _nest
        @ TBD
        _unnest

        _header "EVALUATE", evaluate, _COMPLETE
        _nest
        @ TBD
        _unnest

        @ division operators - use the SDK and hardware divider
        _header "/MOD", slash_mod, _COMPLETE
        _nest
        LDR r0, [PT2ND] @ dividend => r0
        MOV r1, PSTOP @ divisor => r1
        _x_call sdk_slash_mod
        MOV PSTOP, r0 @ quotient => top of stack
        STR r1, [PT2ND] @ remainder => 2nd
        _unnest

        _header "/", slash, _COMPLETE
        _nest
        _x_call sdk_slash_mod
        _SWAP
        _drop
        _unnest

        _header "MOD", mod, _COMPLETE
        _nest
        _x_call sdk_slash_mod
        _drop
        _unnest

        @ terminal I/O words
        _header "KEY", key, _COMPLETE
        _nest
        _x_call sdk_key
        _reg_from r0
        _unnest

        _header "EMIT", emit, _COMPLETE
        _nest
        MOV r0, PSTOP
        _x_call sdk_emit
        _drop
        _unnest

        @ _header "ABORT", abort, _COMPLETE
        @ _x_call clear_stack @ this is the standard behavior
        @ B quit @ quit never returns

        @ text interpreter calls this if it finds a token that's neither a name
        @ found in the dictionary nor a valid number
        _header "GARBAGE-TOKEN", garbage_token, _COMPLETE
        _CRASH "garbage token"

.balign _CELL

@ BLX call vector table
_x_addr sdk_slash_mod
_x_addr sdk_key
_x_addr sdk_emit
_x_addr printf
_x_addr abort
_x_addr clear_stack
_x_addr _tib_init

.global _system_dict_end
_system_dict_end: .word .

.global _system_dict_bytes
_system_dict_bytes: .word _system_dict_end - _system_dict_start
