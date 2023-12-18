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

@ stack macros
@ stacks grow downwards and stack pointers point to top element

        @ pop from stack to register
        .macro _pop_from stack, regname
        LDM \stack\()P!, {\regname}
        .endm

        @ push to stack from register
        .macro _push_to stack regname
        SUB \stack\()P, #_AU_CELL
        STR \regname, [\stack\()P]
        .endm

        @ pop two elements to r0, r1
        .macro _pop_two stack
        LDM \stack\()P!, {r0, r1}
        .endm

        @ pop three elements to r0, r1, r2
        .macro _pop_three stack
        LDM \stack\()P!, {r0, r1, r2}
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
        .balign _AU_CELL, 0
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
        .balign _AU_CELL, 0
        .thumb_func
        .global _\pronunciation\()
        .set _\pronunciation\(), .
        .endm

        @ assemble code field for a machine code word
        @ For indirect threading, the code field address points to the next cell
        .macro _code_word
        .word . + _AU_CELL | 1
        .endm

        @ assemble code field for a colon definition
        .macro _colon_word
        .word _enter
        .endm

@ Common code for a word that uses a single instruction binary ALU operator on the
@ top two stack cells. Such words have the stack effect
@
@    ( left right -- result )
@
@ where `result` = `left <op> right`. That is, the postfix `left right <op>` has
@ the same `result` as the infix `left <op> right`.

        .macro _binary_alu opcode:req
        _pop_two PS @ pop left operand => r0, right operand => r1
        \opcode\() r0, r1 @ r0 := left <OP> right
        _push_to PS, r0
        .endm

@ Common code for a word that compares the top two cells on the stack. Such words
@ have the stack effect
@
@    ( left right -- flag )
@
@ where `flag` = true (all ones) if `left <cmp> right` is true, and false (all
@ zeroes) if `left <cmp> right` is false.

        .macro _binary_cmp cmp:req
        _pop_two PS @ pop left operand => r0, right operand => r1
        LDR r2, _TRUE_FLAG @ true flag => r2
        CMP r0, r1
        B\cmp\() 1f @ branch if true
        MVN r2, r2 @ "invert" the true flag
1:
        _push_to PS, r2 @ push flag to parameter stack
        .endm

@ Common code for unary operations

        .macro _unary_op instruction:req
        LDR r0, [PSP]
        \instruction\()
        STR r0, [PSP]
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
@ see _Moving Forth_ and _eForth Overview_

        @ "next" macro
        .macro _next
        LDR WRD, [INP] @ next code field address => WRD
        ADD INP, #_AU_CELL @ advance INP
        LDR XRG, [WRD] @ next branch target => XRG
        BX XRG @ jump to next code routine
        .endm

        @ unconditional branch macro
        .macro _ubranch target
        .word _branch
        .word \target\()
        .endm

        @ conditional branch macro
        .macro _qbranch target
        .word _question_branch
        .word \target\()
        .endm

.global _enter
.thumb_func
_enter:
        _push_to RS INP @ nest INP
	ADD WRD, #_AU_CELL @ point to first word of thread
        MOV INP, WRD @ "branch indirect" to INP
        _next

.global _dovar
.thumb_func
_dovar:
        ADD WRD, #_AU_CELL @ address of variable => WRD
        _push_to PS WRD @ push to parameter stack
        _next

.global _docon
.thumb_func
_docon:
        ADD WRD, #_AU_CELL @ address of constant => WRD
        LDR r0, [WRD] @ constant value => r0
        _push_to PS r0 @ push to parameter stack
        _next

@ the dictionary itself!

.balign _AU_CELL
.global _system_dict_start
_system_dict_start: .word .

        @ code words for base VM

        _header "EXIT", exit, _COMPLETE | _COMPILE_ONLY
        _code_word
        _pop_from RS, INP @ un-nest the return stack to INP
        _next

        _header "LITERAL", literal, _COMPLETE | _COMPILE_ONLY
        _code_word
        LDR r0, [INP] @ literal value => r0
        _push_to PS r0 @ push to parameter stack
        ADD INP, #_AU_CELL @ skip over the literal!
        _next

        _header "EXECUTE", execute, _COMPLETE
        _code_word
        _pop_from PS, r0 @ get execution token
        MOV XRG, #1 @ set thumb bit
        ORR XRG, r0 @ ready for BX
        BX XRG @ unconditional branch without link

        _header "branch", branch, _COMPLETE | _COMPILE_ONLY
        _code_word
        LDR INP, [INP]
        _next

        _header "?branch", question_branch, _COMPLETE | _COMPILE_ONLY
        _code_word
        _pop_from PS, r0 @ flag => r0
        CMP r0, #0
        BNE qbz @ branch if flag is TRUE
        LDR INP, [INP] @ flag is false - take the branch
        _next
qbz:
        ADD INP, #_AU_CELL @ flag is true - skip branch destination
        _next

        _header "DUP", dupe, _COMPLETE
        _code_word
        LDR r0, [PSP]
        _push_to PS, r0
        _next

        _header "OVER", over, _COMPLETE
        _code_word
        LDR r0, [PSP, #_AU_CELL] @ 2nd => r0
        _push_to PS, r0
        _next

        _header "SWAP", swap, _COMPLETE
        _code_word
        LDM PSP, {r0, r1, PSP} @ top => r0, 2nd => r1
        STR r1, [PSP]
        STR r0, [PSP, #_AU_CELL]
        _next

        _header "DROP", drop, _COMPLETE
        _code_word
        _pop_from PS, r0
        _next

        _header "ROT", rote, _COMPLETE
        _code_word
        @ x1, x2, x3 -> x2, x3, x1
        LDM PSP, {r0, r1, r2, PSP} @ x3 => r0, x2 => r1, x1 => r2
        STR r1, [PSP, #_AU_CELL*2] @ stash x2
        STR r0, [PSP, #_AU_CELL] @ stash x3
        STR r2, [PSP] @ stash x1
        _next

        @ position-independent operations
        _header "@", fetch, _COMPLETE
        _code_word
        LDR r0, [PSP] @ address => r0
        LDR r0, [r0] @ data => r0
        _push_to PS, r0
        _next

        _header "C@", c_fetch, _COMPLETE
        _code_word
        LDR r0, [PSP] @ address => r0
        LDRB r0, [r0] @ data => r0
        _push_to PS, r0
        _next

        _header "!", store, _COMPLETE
        _code_word
        _pop_two PS @ pop data => r0, address => r1
        STR r0, [r1]
        _next

        _header "C!", c_store, _COMPLETE
        _code_word
        _pop_two PS @ pop data => r0, address => r1
        STRB r0, [r1]
        _next

        _header ">R", to_r, _COMPLETE | _COMPILE_ONLY
        _code_word
        _pop_from PS, r0 @ pop parameter stack => r0
        _push_to RS, r0 @ push r0 => return stack
        _next

        _header "R>", r_from, _COMPLETE | _COMPILE_ONLY
        _code_word
        _pop_from RS, r0 @ pop return stack => r0
        _push_to PS, r0 @ push r0 => parameter stack
        _next

        _header "R@", r_fetch, _COMPLETE | _COMPILE_ONLY
        _code_word
        LDR r0, [RSP] @ top of return stack => r0
        _push_to PS, r0 @ push r0 => parameter stack
        _next

        _header "1+", one_plus, _COMPLETE
        _code_word
        _unary_op "ADD r0, #1"
        _next

        _header "1-", one_minus, _COMPLETE
        _code_word
        _unary_op "SUB r0, #1"
        _next

        _header "2*", two_star, _COMPLETE
        _code_word
        _unary_op "LSL r0, #1"
        _next

        _header "2/", two_slash, _COMPLETE
        _code_word
        _unary_op "ASR r0, #1"
        _next

        _header "CELL+", cell_plus, _COMPLETE
        _code_word
        _unary_op "ADD r0, #_AU_CELL"
        _next

        _header "CELL-", cell_minus, _COMPLETE
        _code_word
        _unary_op "SUB r0, #_AU_CELL"
        _next

        _header "CELLS", cells, _COMPLETE
        _code_word
        _unary_op "LSL r0, #_CELL_SHIFT"
        _next

        _header "CHAR+", char_plus, _COMPLETE
        _code_word
        _unary_op "ADD r0, #_AU_CHAR"
        _next

        _header "CHAR-", char_minus, _COMPLETE
        _code_word
        _unary_op "SUB r0, #_AU_CHAR"
        _next

        _header "CHARS", chars, _COMPLETE
        _code_word
        _next

        @ arithmetic operators
        _header "+", plus, _COMPLETE
        _code_word
        _binary_alu ADD
        _next

        _header "-", minus, _COMPLETE
        _code_word
        _binary_alu SUB
        _next

        _header "*", star, _COMPLETE
        _code_word
        _binary_alu MUL
        _next

        _header "NEGATE", negate, _COMPLETE
        _code_word
        _unary_op "NEG r0, r0"
        _next

        _header "ALIGNED", aligned, _COMPLETE
        _code_word
        LDR r0, [PSP]
        MOV r1, #_AU_CELL
        NEG r1, r1 @ # bitmask => r1
        ADD r0, #_AU_CELL
        SUB r0, #1
        AND r0, r1
        STR r0, [PSP]
        _next

        @ boolean operators
        _header "AND", and, _COMPLETE
        _code_word
        _binary_alu AND
        _next

        _header "OR", or, _COMPLETE
        _code_word
        _binary_alu ORR
        _next

        _header "XOR", x_or, _COMPLETE
        _code_word
        _binary_alu EOR
        _next

        _header "INVERT", invert, _COMPLETE
        _code_word
        MVN r0, r0
        _next

        _header "LSHIFT", l_shift, _COMPLETE
        _code_word
        _binary_alu LSL
        _next

        _header "RSHIFT", r_shift, _COMPLETE
        _code_word
        _binary_alu LSR
        _next

        @ binary comparison operators
        _header "<", less_than, _COMPLETE
        _code_word
        _binary_cmp LT
        _next

        _header "<=", less_or_equal, _COMPLETE
        _code_word
        _binary_cmp LE
        _next

        _header "=", equals, _COMPLETE
        _code_word
        _binary_cmp EQ
        _next

        _header "<>", not_equal, _COMPLETE
        _code_word
        _binary_cmp NE
        _next

        _header ">", greater_than, _COMPLETE
        _code_word
        _binary_cmp GT
        _next

        _header ">=", greater_or_equal, _COMPLETE
        _code_word
        _binary_cmp GE
        _next

        _header "U>", u_greater_than, _COMPLETE
        _code_word
        _binary_cmp HI
        _next

        _header "U>=", u_greater_or_equal, _COMPLETE
        _code_word
        _binary_cmp HS
        _next

        _header "U<", u_less_than, _COMPLETE
        _code_word
        _binary_cmp LO
        _next

        _header "U<=", u_less_or_equal, _COMPLETE
        _code_word
        _binary_cmp LS
        _next

.balign _AU_CELL, 0
_TRUE_FLAG: .word 0xFFFFFFFF

        @ division operators - use the SDK and hardware divider
        _header "/MOD", slash_mod, _COMPLETE
        @ ( dividend divisor –– remainder quotient )
        _code_word
        _pop_from PS, r1 @ divisor => r1
        _pop_from PS, r0 @ dividend => r0
        _x_call sdk_slash_mod
        _push_to PS, r1 @ push remainder
        _push_to PS, r0 @ push quotient
        _next

        _header "/", slash, _COMPLETE
        _code_word
        _pop_from PS, r1 @ divisor => r1
        _pop_from PS, r0 @ dividend => r0
        _x_call sdk_slash_mod
        _push_to PS, r0 @ push quotient
        _next

        _header "MOD", mod, _COMPLETE
        _code_word
        _pop_from PS, r1 @ divisor => r1
        _pop_from PS, r0 @ dividend => r0
        _x_call sdk_slash_mod
        _push_to PS, r1 @ push remainder
        _next

_x_addr sdk_slash_mod

        @ terminal I/O words
        _header "KEY", key, _COMPLETE
        _code_word
        _x_call sdk_key
        _push_to PS, r0
        _next

        _header "EMIT", emit, _COMPLETE
        _code_word
        _pop_from PS, r0
        _x_call sdk_emit
        _next

        @ stacks grow downwards - top of stack is the lowest address
        @ _param_stack_top is the lowest address that can legally contain a cell
        @ _param_stack_bottom is one cell *above* the highest address that can
        @ legally contain a cell!
        _header "clear_param_stack", clear_param_stack, _COMPLETE
        _code_word
        _x_load PSP, _param_stack_bottom
        _x_load r1, _param_stack_top
        LDR r0, _HAMBURGER
cps1:
        STR r0, [r1]
        ADD r1, #_AU_CELL
        CMP r1, PSP
        BLO cps1
        _next

_x_addr _param_stack_bottom
_x_addr _param_stack_top

        _header "clear_return_stack", clear_return_stack, _COMPLETE
        _code_word
        _x_load RSP, _return_stack_bottom
        _x_load r1, _return_stack_top
        LDR r0, _HAMBURGER
crs1:
        STR r0, [r1]
        ADD r1, #_AU_CELL
        CMP r1, RSP
        BLO crs1
        _next

_x_addr _return_stack_bottom
_x_addr _return_stack_top
.balign _AU_CELL, 0
_HAMBURGER: .word 0xDEADBEEF

        _header "param_top_3", param_top_3, _COMPLETE
        _code_word
        LDR r0, =_param_format
        LDM PSP, { r1, r2, r3, PSP}
        _x_call printf
        _next

        _header "return_top_3", return_top_3, _COMPLETE
        _code_word
        LDR r0, =_return_format
        LDM RSP, { r1, r2, r3, RSP}
        _x_call printf
        _next

_x_addr printf

        _header "colon-test", colon_test, _COMPLETE
        _colon_word
        .word _literal
        .word 2
        .word _literal
        .word 3
        .word _param_top_3
        .word _plus
        .word _param_top_3
        .word _exit

        _header "crash", crash, _COMPLETE
        _code_word
        LDR r0, =_CRASH_FMT_1
        BL printf @ dump r1, r2, r3

        MOV r1, INP
        MOV r2, WRD
        LDR r0, =_CRASH_FMT_2
        BL printf @ dump INP and WRD

        MOV r1, PSP
        MOV r2, RSP
        LDR r0, =_CRASH_FMT_3
        BL printf @ dump PSP and RSP

        LDR INP, _ABORT_CFA
        _next

_CRASH_FMT_1: .asciz "\nr1, r2, XRG: %x, %x, %x"
_CRASH_FMT_2: .asciz "\nINP, WRD: %x, %x"
_CRASH_FMT_3: .asciz "\nPSP, RSP: %x, %x\n"

.balign _AU_CELL, 0
_ABORT_CFA: .word _abort

        _header "ABORT", abort, _COMPLETE
        _colon_word
        .word _clear_param_stack
        .word _quit
        .word _exit @ this should never get executed because QUIT never exits

        _header "QUIT", quit, _COMPLETE
        _colon_word
        .word _clear_return_stack

quil:
        .word _accept
        .word _evaluate
        .word _oll_korrect
        _ubranch quil
        .word _exit @ this should never get executed

        _header "EVALUATE", evaluate, _COMPLETE
        _colon_word
        .word _exit

        _header "oll-korrect", oll_korrect, _COMPLETE
        _code_word
        LDR r0, =OllKorrect
        BL printf @ pretend to be Forth!
        _next

OllKorrect: .asciz " Ok\n"

        _header "FILL", fill, _COMPLETE
        @ ( c-addr u char –– )
        _code_word
        _pop_three PS @ char => r0, u => r1, c-addr => r2

fil1:
        CMP r1, #0 @ is count zero or less?
        BLE filz @ exit, stage left!
        STRB r0, [r2]
        ADD r2, #_AU_CHAR
        SUB r1, #1
        B fil1
filz:
        @ done
        _next

        _header "ACCEPT", accept, _COMPLETE
        @ ( c-addr +n1 –– +n2 )
        _code_word

        @ On entry, the top of the stack has the maximum allowed characters and
        @ the second has the address of the buffer. On exit, the address has
        @ been consumed and the actual count is on the top of the stack.

        _pop_from PS, r3 @ pop max count => r3
        _pop_from PS, r2 @ pop address => r2
        MOV r1, #0 @ character count => r1
_accl:
        PUSH {r1, r2, r3} @ save loop controls
        _x_call sdk_key @ wait for character, which will show up in r0
        POP {r1, r2, r3} @ restore loop controls

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

        @ a printable character - echo it and append to buffer
_acce:
        STRB r0, [r2, r1] @ append char to buffer
        ADD r1, #1 @ count the character

        PUSH {r1, r2, r3} @ save loop controls
        _x_call sdk_emit @ printable - send it out!
        POP {r1, r2, r3} @ restore loop controls

        @ check for buffer end
        CMP r1, r3 @ did we hit the limit?
        BEQ _accz @ early exit if limit hit!
	B _accl @ there's room - go back for more!

        @ space or unprintable
_accs:
        MOV r0, #_BL @ force a space and emit / store / count
        B _acce

        @ backspace - un-count previous character and erase it
_accb:
        CMP r1, #0 @ is buffer empty?
        BEQ _accl @ ignore a backspace if buffer is empty

        @ un-count
        SUB r1, #1 @ decrement char count

        @ erase previous character
        PUSH {r1, r2, r3} @ save loop controls
        _x_call sdk_emit @ emit the backspace we already have
        POP {r1, r2, r3} @ restore loop controls

        MOV r0, #_BL
        PUSH {r1, r2, r3} @ save loop controls
        _x_call sdk_emit @ "erase" the character at the cursor
        POP {r1, r2, r3} @ restore loop controls

        MOV r0, #_BS @ queue up another backspace
        PUSH {r1, r2, r3} @ save loop controls
        _x_call sdk_emit @ move cursor back
        POP {r1, r2, r3} @ restore loop controls

        B _accl @ back for more!

        @ clean up and exit
_accz:
        @ push count; exit
        _push_to PS, r1
        _next

        _header "TYPE", type, _COMPLETE
        @ ( c-addr u –– )
        _code_word

        _pop_from PS, r1 @ count => r1
        _pop_from PS, r2 @ address => r2

typl:
        CMP r1, #0 @ are we done?
        BLE typz @ exit!

        LDRB r0, [r2] @ character => r0
        CMP r0, #0 @ is it a null terminator?
        BEQ typz @ exit on null terminator

        PUSH {r1, r2} @ save loop controls
        _x_call sdk_emit @ emit the character
        PUSH {r1, r2} @ save loop controls

        ADD r2, #1 @ increment the address
        SUB r1, #1 @ count down
        B typl @ continue

typz:
        _next

_x_addr sdk_key
_x_addr sdk_emit

/*
        @ number input/output
        @_header "BASE", "base", _COMPLETE
        @_nest
        @_dupe
        @BL _addr_base_v
        @_unnest

        @ parsing
        @_header ">IN", "to_in", _COMPLETE
        @_nest
        @_dupe
        @BL _addr_to_in_v
        @_unnest

        _header "SOURCE", "source", _COMPLETE
        @_nest
        @BL _addr_term_buf
        @BL count
        @_unnest

        _header "STATE", "state", _COMPLETE
        @_nest
        @_dupe
        @BL _addr_state_v
        @_unnest

        @_header "COUNT", "count", _COMPLETE
        @LDRB r0, [r0] @ fetch count byte
        @ADD PSTOP, #1 @ fix address
        @_dupe
        @MOV PSTOP, r0
        @_return

        @_header "cs-match", "c_s_match", _COMPLETE
        @ (c-addr1 c-addr2 -- caddr1 flag)
        @ flag is true if strings are identical, false otherwise
        @_nest
        @_pop_to INDXA @ pop c-addr2 => INDXA
        @LDRB r1, [PSTOP] @ count of c-addr1 => r1
        @LDRB r2, [INDXA] @ count of c-addr2 => r2
        @CMP r1, r2
        @BNE csmf @ fail fast!

csml:
        @LDRB r0, [INDXA, r2]
        @LDRB r1, [PSTOP, r2]
        @BNE csmf @ fail a bit slower
        @SUB r2, #1 @ count down
        @BGT csml @ we already compared the counts

csms:
        @ success!
        @_dupe @ push c-addr1 back on stack
        @MOV PSTOP, #0
        @_invert @ true flag
        @_unnest

csmf:
        @ failure
        @_dupe @ push c-addr1 back on stack
        @MOV PSTOP, #0 @ false flag
        @_unnest

        @_header "FIND", "find", _COMPLETE
        @ ( c-addr –– c-addr 0 | xt 1 | xt -1 )
        @_nest 

        @ Outer loop - start with most recent link and walk backwards
        @LDR INDXA, _latest_link_field @ link addr => INDXA
@
fndl:
        @CMP INDXA, #0
        @BEQ fndz @ link is zero - we hit the end
        @@    compare name with target
        @MOV r0, INDXA
        @ADD r0, #_AU_CELL @ name field address => r0
        @_push_from r0 @ push name c-addr
        @BL c_s_match
        @CMP PSTOP, #0
        @BNE fndm @ it matched!

        @@ no match: INDXA - link offset => INDXA
        @_drop @ get rid of flag
        @LDRH r0, [INDXA] @ link field is a halfword offset to previous link!
        @SUB INDXA, r0 @ do the offset
        @B fndl
@
@fndm:
        @@ match: exit with xt and flag
        _drop @ flag
        _drop @ matched target c-addr
        _push_from INDXA @ push successful link addr
        ADD PSTOP, #_AU_CELL @ name field c-addr
        LDRB r0, [PSTOP] @ name field count byte
        ADD PSTOP, r0
        ADD PSTOP, #1 @ next available address => PSTOP
        _aligned @ now we have XT

        _dupe @ make room for flag
        MOV PSTOP, #1 @ assume it's immediate
        MOV r0, #_IMMEDIATE
        LDRH r1, [INDXA, #2] @ get the dictionary flags
        AND r0, r1
        BNE fnds @ successful exit
        _negate @ not immediate - change to -1

        @ success!
fnds: 
        _unnest
        
fndz:
        @ failed search - push a zero and return
        _dupe
        MOV PSTOP, #0
        _unnest

        _header "clear-buffer", "clear_buffer", _COMPLETE
        LDR r2, [PT2ND] @ second of stack has buffer address
        MOV r3, PSTOP @ top of stack has max chars.
        MOV r0, #0 @ zero => r0
cbuf:
        STRB r0, [r2, r3]
        SUB r3, #1 @ count down
        BGE cbuf @ go all the way to count byte!
        _return

        _header "clear-term_buf", "clear_term_buf", _COMPLETE
        _nest
        BL _addr_term_buf @ address of term_buf => PSTOP
        BL _maxc_term_buf @ max chars of term_buf => PSTOP
        BL clear_buffer
        _unnest

        @ _header "PARSE-NAME", "parse_name", _COMPLETE
        @ _nest
        @ BL source @ buffer address in [PT2ND], count in PSTOP
        @ _drop @ drop count - buffers are null-terminated
        @ _pop_to INDXA @ pop address to INDXA
        @ BL to_in @ get address of input buffer count
        @ _pop_to INDXB @ pop >IN address to INDXB
        @ LDR r3, [INDXB] @ >IN to r3

pn1:
        @ LDRB r2, [INDXA, r3] @ get a character
        @ CMP r2, #0 @ buffers are null-terminated
        @ BEQ pnz @ that's all, folks!
        @ CMP r2, #_BL @ is it a space?
        @ BNE pn2 @ first non-delimiter!
        @ ADD r3, #_AU_CHAR
        @ B pn1 @ next character

pn2:
        @ ADD r0, INDXA, r3 @ we have the buffer address!
        @ _push_from r0 @ push it to the stack
        @ MOV r1, #1 @ initial count

pn3:
        @ ADD r3, #_AU_CHAR
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
        @ _push_from r0
        @ _unnest 

        _header "'", tick, _COMPLETE
        _nest
        @ TBD
        _unnest

*/


_param_format: .asciz "parameter stack top, second, third => %x, %x, %x\n"
_return_format: .asciz "return stack top, second, third => %x, %x, %x\n"

.global _system_dict_end
_system_dict_end: .word .

.global _system_dict_bytes
_system_dict_bytes: .word _system_dict_end - _system_dict_start

.global _last_system_link
_last_system_link: .word _previous_link_field

/*

  Text interpreter pseudo-code

  EVALUATE: EVALUATE does the actual processing. It is usable by other processes
  besides QUIT, for example, a `BLOCK` loader or a WiFi server for a browser-based
  host tool.

  Initialize buffers and pointers / counts

  BEGIN

      Parse a token with `PARSE-NAME`

  WHILE parse token length is greater than zero

      Classify the token with `CLASSIFY-TOKEN`. `CLASSIFY-TOKEN` returns two or
      three cells on the stack. The stack top is the classification of the token:

          0: The token is garbage; it wasn't found in the dictionary and isn't a
             valid number. Abort with a message; processing should not continue!

          If we get here, the token is valid. Top of stack:

          -1: The token is a number. Second of stack has the number.
          -2: The token is a double-cell number. Second and third have the number.

          >0: The token is a name found in the dictionary. Second of stack has a
              "name token" as described in the "Programming-Tools" word set of the
              standard. The top of stack low-order bits are set to mean:

              0 Immediate
              1 Compile-only
              2 Can compile inline
              3-14 reserved for future use
              15 word is completed. If this isn't set the search will skip it.

          STATE = interpret:

            <0: The token is a number. It's already on the stack, just make sure
                the classifier flag has been taken off.
            >0: The token is a found name. If compile-only, abort with a message;
                processing should not continue. Otherwise get its execution token
                via `NAME>INTERPRET` and `EXECUTE`.

          STATE = compile:

            <0: The token is a number. Compile a literal.
            >0: The token is a found name.
                immediate: get its execution token and `EXECUTE`.
                inline: Copy its code into the current definition.
                other: `NAME>COMPILE` and `COMPILE,`: get the execution token and
                       compile either a BL or a BLX to its code, depending on how
                       far away the called routine is from where the call is being
                       stored in the dictionary.

  REPEAT

*/
