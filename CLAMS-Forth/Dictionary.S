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

.include "MacroDefs.S"

@ main entry point
.global CLAMS_Forth
.thumb_func
CLAMS_Forth:
        PUSH {LR} @ save link register
        _x_load LOC, _entry_system_stack_pointer
        MOV r0, SP @ save system stack pointer
        STR r0, [LOC]

        _x_load INP, _abort @ start with an ABORT
        _next

_x_addr _abort

@ inner interpreters

.global _enter
.thumb_func
_enter:
        PUSH {INP} @ nest INP
	ADD WRD, #_AU_CELL @ point to first word of thread
        MOV INP, WRD @ "branch indirect" to INP
        _next

.global _do_var
.thumb_func
_do_var:
        ADD WRD, #_AU_CELL @ address of variable => WRD
        MOV TOS, WRD
        _next

.global _do_const
.thumb_func
_do_const:
        ADD WRD, #_AU_CELL @ address of constant => WRD
        LDR TOS, [WRD] @ constant value => TOS
        _next

@ Strings compiled with C" and strings compiled with S" are both *stored* as counted
@ strings. So we need two different inner interpreters.
.global _do_cq_string
.thumb_func
_do_cq_string:
        ADD WRD, #_AU_CELL @ address of counted string => WRD
        MOV TOS, WRD
        _next

.global _do_sq_string
.thumb_func
_do_sq_string:
        ADD WRD, #_AU_CELL @ address of counted string => WRD
        LDRB CNT, [WRD] @ count => CNT
        ADD TOS, WRD, #_AU_CHAR @ skip the count byte
        _dupe_ @ push address to parameter stack
        MOV TOS, CNT @ push count to parameter stack
        _next

@ return stack checker
@ we *never* want to allow the return stack to get popped below where it
@ was when CLAMS_Forth was called!! Any word that pops a return stack cell it didn't
@ push should call this before doing so!
.thumb_func
_rstack_check:
        _x_load MAX, _entry_system_stack_pointer @ highest address SP should be
        MOV LOC, SP @ actual stack pointer
        SUB CNT, MAX, LOC @ difference in address units
        CMP CNT, #_AU_CELL
        BLT rscz @ we don't have enough on the stack to pop a cell!
        BX LR @ we have enough - return
rscz:
        @ sorry, Charlie!
        _x_load INP, _RS_UNDER @ address of crash message
        _x_load r0, _crash @ CFA of CRASH
        BX r0 @ and crash!

_RS_UNDER: .asciz "\nReturn stack underflow!\n"
_x_addr _RS_UNDER

@ the dictionary itself!

.balign _AU_CELL
.global _system_dict_start
_system_dict_start: .word .

        @ code words for base VM

        _header "clear-return-stack", clear_return_stack, _COMPILE_ONLY
        _code_word
        _x_load r0, _entry_system_stack_pointer
        MOV SP, r0
        _next

        _header "EXIT", exit, _COMPILE_ONLY
        _code_word
        BL _rstack_check @ do we have enough return stack cells?
        POP {INP} @ return stack is OK - un-nest the return stack to INP
        _next

_x_addr _entry_system_stack_pointer
_x_addr _crash

        _header "crash", crash
        _code_word
        @ if we get here, Forth has gotten into big trouble and we just want to
        @ dump as much info as we can and ABORT.
        _x_load r0, _CRASH_FMT_1
        BL printf @ dump CNT, LOC, MAX

        MOV r1, INP
        MOV r2, WRD
        _x_load r0, _CRASH_FMT_2
        BL printf @ dump INP and WRD

        MOV r1, PS2
        MOV r2, TOS
        _x_load r0, _CRASH_FMT_3
        BL printf @ dump PS2 and TOS

        _x_load r0, _PARAM_FORMAT
        MOV r1, TOS @ get top of stack
        LDM PS2, { r2, r3, PS2} @ second and third
        BL printf @ top of parameter stack

        @ INP should be pointing to the cell after the "crash" invocation that got
        @ us here. Assume there's a null-terminated string there and printf it.
        MOV r0, INP
        BL printf

        @ restart Forth via ABORT
        LDR INP, _ABORT_CFA
        _next

_CRASH_FMT_1: .asciz "\nCNT, LOC, MAX: %x, %x, %x\n"
_CRASH_FMT_2: .asciz "INP, WRD: %x, %x\n"
_CRASH_FMT_3: .asciz "PS2, TOS: %x, %x\n"
_PARAM_FORMAT: .asciz "Parameter stack top, second, third => %x, %x, %x\n"
_x_addr _CRASH_FMT_1
_x_addr _CRASH_FMT_2
_x_addr _CRASH_FMT_3
_x_addr _PARAM_FORMAT
_ABORT_CFA: .word _abort

        _header "LITERAL", literal, _COMPILE_ONLY
        _code_word
        _dupe_ @ make space on stack
        LDR TOS, [INP] @ literal value => TOS
        ADD INP, #_AU_CELL @ skip over the literal!
        _next

        _header "EXECUTE", execute
        _code_word
        MOV WRD, TOS @ execution token => WRD
        _drop_ @ we're done with the token
        BX WRD @ unconditional branch without link

        _header "branch", branch, _COMPILE_ONLY
        _code_word
        LDR INP, [INP]
        _next

        _header "?branch", question_branch, _COMPILE_ONLY
        _code_word
        CMP TOS, #0
        BNE qbz @ branch if flag is TRUE
        LDR INP, [INP] @ flag is false - take the branch
        _drop_
        _next
qbz:
        ADD INP, #_AU_CELL @ flag is true - skip branch destination
        _drop_
        _next

@ "_expand" words
@ These words are generated from macros in "DictMacros.S", and can be generated with
@ a single line of code!
        .macro _expand wname, pronunciation
        _header "\wname\()", \pronunciation\()
        _code_word
        _\pronunciation\()_
        _next
        .endm

        @ stack operations
        _expand "DROP", drop
        _expand "DUP", dupe
        _expand "SWAP", swap
        _expand "OVER", over
        _expand "ROT", rote

        @ fetch and store operations
        _expand "@", fetch
        _expand "C@", c_fetch
        _expand "H@", h_fetch
        _expand "SB@", s_b_fetch
        _expand "SH@", s_h_fetch
        _expand "!", store
        _expand "C!", c_store
        _expand "H!", h_store

        @ addressing conveniences
        _expand "1+", one_plus
        _expand "1-", one_minus
        _expand "2*", two_star
        _expand "2/", two_slash
        _expand "CELL+", cell_plus
        _expand "CELL-", cell_minus
        _expand "CELLS", cells
        _expand "CHAR+", char_plus
        _expand "CHAR-", char_minus
        _expand "CHARS", chars
        _expand "HALFWORD+", halfword_plus
        _expand "HALFWORD-", halfword_minus
        _expand "HALFWORDS", halfwords

        @ arithmetic operators
        _expand "+", plus
        _expand "-", minus
        _expand "*", star
        _expand "NEGATE", negate
        _expand "ALIGNED", aligned
        _expand "H-ALIGNED", h_aligned

        @ boolean operators
        _expand "AND", and
        _expand "OR", or
        _expand "XOR", x_or
        _expand "INVERT", invert
        _expand "LSHIFT", l_shift
        _expand "RSHIFT", r_shift

        @ binary comparison operators
        _expand "<", less_than
        _expand "<=", less_or_equal
        _expand "=", equals
        _expand "<>", not_equal
        _expand ">", greater_than
        _expand ">=", greater_or_equal
        _expand "U>", u_greater_than
        _expand "U>=", u_greater_or_equal
        _expand "U<", u_less_than
        _expand "U<=", u_less_or_equal

        @ stacks grow downwards - top of stack is the lowest address
        @ _param_stack_top is the lowest address that can legally contain a cell
        @ _param_stack_bottom is one cell *above* the highest address that can
        @ legally contain a cell!
        _header "clear-param-stack", clear_param_stack
        _code_word
        _x_load PS2, _param_stack_bottom @ one cell above highest address
        _x_load LOC, _param_stack_top @ lowest address
        LDR TOS, _HAMBURGER
cps1:
        STR TOS, [LOC]
        ADD LOC, #_AU_CELL
        CMP LOC, PS2
        BLO cps1 @ unsigned strictly less
        _next
_x_addr _param_stack_bottom
_x_addr _param_stack_top

.balign _AU_CELL, 0
_HAMBURGER: .word 0xDEADBEEF

        @ division operators - use the SDK and hardware divider
        _header "/MOD", slash_mod
        @ ( dividend divisor –– remainder quotient )
        _code_word
        MOV r1, TOS @ divisor => r1
        LDR r0, [PS2] @ dividend => r0
        _x_call sdk_slash_mod
        STR r1, [PS2] @ stash remainder
        MOV TOS, r0 @ stash quotient
        _next

_x_addr sdk_slash_mod

        _header "/", slash
        _colon_word
        .word _slash_mod
        .word _swap
        .word _drop
        .word _exit

        _header "MOD", mod
        _colon_word
        .word _slash_mod
        .word _drop
        .word _exit

        @ terminal I/O / interpreter control words
        _header "KEY", key
        _code_word
        _dupe_
        _x_call sdk_key
        MOV TOS, r0
        _next

        _header "EMIT", emit
        _code_word
        MOV r0, TOS
        _x_call sdk_emit
        _drop_
        _next

        @ "user variables"
        @ >IN, BASE, BLK, SCR, SOURCE, SOURCE-ID, STATE

        _header ">IN", to_in
        _code_word
        _dupe_
        _x_load TOS, _input_cursor
        _next
_x_addr _input_cursor

        _header "BASE", base
        _code_word
        _dupe_
        _x_load TOS, _number_base
        _next
_x_addr _number_base

        _header "SOURCE", source
        _code_word
        _dupe_
        _x_load TOS, _input_source
        _dupe_
        _x_load TOS, _input_source_chars
        _next
_x_addr _input_source
_x_addr _input_source_chars

        _header "SOURCE-ID", source_id
        _code_word
        _dupe_
        _x_load TOS, _input_source_id
        _next
_x_addr _input_source_id

        _header "STATE", state
        _code_word
        _dupe_
        _x_load TOS, _input_state
        _next
_x_addr _input_state

        _header "ABORT", abort
        @ ( anything -- )
        _colon_word
        .word _clear_param_stack
        .word _quit

        _header "BYE", bye
        @ ( anything -- )
        _colon_word
        .word _clear_return_stack
        .word _return_to_main

        _header "return-to-main", return_to_main
        _code_word
        POP {PC} @ return to main program!

        _header "QUIT", quit
        @ (R: anything -- )
        @ clear-return-stack
        @ BEGIN
        @    term-buf
        @    DUP
        @    max-termbuf
        @    NUL
        @    FILL
        @    ACCEPT
        @    term-buf
        @    SWAP
        @    EVALUATE
        @    oll_korrect
        @ AGAIN

        _colon_word
        .word _clear_return_stack

quil:
        .word _term_buf @ push terminal buffer address => parameter stack

        @ set the buffer to NULs
        .word _dupe
        _code_literal _MAX_TERMBUF
        _code_literal _NUL
        .word _fill

        _code_literal _MAX_TERMBUF @ push max character count => parameter stack
        .word _accept @ get a line

        @ stack has actual character count
        .word _term_buf @ get terminal buffer address back on stack
        .word _swap
        .word _interpret @ INTERPRET is the text interpreter!
        .word _oll_korrect
        _ubranch quil

        _header "INTERPRET", interpret
        _colon_word
        .word _exit

        _header "oll-korrect", oll_korrect
        _code_word
        LDR r0, =OllKorrect
        BL printf @ pretend to be Forth!
        _next

OllKorrect: .asciz " Ok\n"

        _header "term-buf", term_buf
        @ ( -- c-addr )
        @ c-addr is the address of _terminal_buffer
        _code_word
        _dupe_
        _x_load TOS, _terminal_buffer
        _next
_x_addr _terminal_buffer

        _header "FILL", fill
        @ ( c-addr u char –– )
        _code_word
        MOV r0, TOS @ char => r0,
        _drop_
        MOV CNT, TOS @ u => CNT
        _drop_
        MOV LOC, TOS @ c-addr => LOC
        _drop_

fil1:
        SUB CNT, #_AU_CHAR @ count down
        BLT filz @ exit, stage left!
        STRB r0, [LOC, CNT]
        B fil1
filz:
        @ done
        _next

        _header "ACCEPT", accept
        @ ( c-addr +n1 –– +n2 )
        _code_word

        @ On entry, the top of the stack has the maximum allowed characters and
        @ the second has the address of the buffer. On exit, the address has
        @ been consumed and the actual count is on the top of the stack.

        MOV MAX, TOS @ max count => MAX
        _drop_ @ TOS now has c-addr
        MOV CNT, #0 @ initialize CNT

_accl:
        _pushlctl
        _x_call sdk_key @ wait for character, which will show up in r0
        _poplctl

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

_acce:
        @ a printable character - echo it and append to buffer
        STRB r0, [TOS, CNT] @ append char to buffer
        ADD CNT, #1 @ count the character

        _pushlctl
        _x_call sdk_emit @ printable - send it out!
        _poplctl

        @ check for buffer end
        CMP CNT, MAX @ did we hit the limit?
        BEQ _accz @ early exit if limit hit!
	B _accl @ there's room - go back for more!

_accs:
        @ space or unprintable
        MOV r0, #_BL @ force a space and emit / store / count
        B _acce

_accb:
        @ backspace - un-count previous character and erase it
        CMP CNT, #0 @ is buffer empty?
        BEQ _accl @ ignore a backspace if buffer is empty

        @ un-count
        SUB CNT, #1 @ decrement char count

        @ erase previous character
        _pushlctl
        _x_call sdk_emit @ emit the backspace we already have
        _poplctl

        MOV r0, #_BL
        _pushlctl
        _x_call sdk_emit @ "erase" the character at the cursor
        _poplctl

        MOV r0, #_BS @ queue up another backspace
        _pushlctl
        _x_call sdk_emit @ move cursor back
        _poplctl

        B _accl @ back for more!

_accz:
        @ clean up and exit
        MOV TOS, CNT @ replace address with count in TOS
        _next
_x_addr sdk_key

        _header "TYPE", type
        @ ( c-addr u –– )
        _code_word

        MOV MAX, TOS @ count => MAX
        _drop_ @ address is now in TOS
        MOV CNT, #0 @ count up

typl:
        CMP CNT, MAX @ are we done?
        BGE typz @ exit!

        LDRB r0, [TOS, CNT] @ character => r0
        CMP r0, #0 @ is it a null terminator?
        BEQ typz @ exit on null terminator

        _pushlctl
        _x_call sdk_emit @ emit the character
        _poplctl

        ADD CNT, #1 @ count up
        B typl @ continue

typz:
        _drop_ @ drop address
        _next

_x_addr sdk_emit

        _header "COUNT", "count"
        @ ( c-addr1 –– c-addr2 u )
        _code_word
        LDRB CNT, [TOS] @ count byte => CNT
        ADD TOS, #_AU_CHAR @ fix address
        _dupe_ @ push address
        MOV TOS, CNT @ count => TOS
        _next

        @ counted string match
        _header "cs-match", "c_s_match"
        @ (c-addr1 c-addr2 -- c-addr1 flag)
        @ flag is true if strings are identical, false otherwise
        _code_word
        LDRB CNT, [TOS] @ count of c-addr2 => CNT
        ADD TOS, #_AU_CHAR @ point TOS to first character of c-addr2
        LDR r0, [PS2] @ c-addr1 => r0
        LDRB r0, [r0] @ count of c-addr1 => r0
        CMP r0, CNT @ if the counts aren't equal, we are done!
        BNE csmf @ fail fast!

        LDR LOC, [PS2] @ c-addr1 => LOC
        ADD LOC, #_AU_CHAR @ point LOC to first character of c-addr1

        @ main compare loop
csml:
        LDRB r0, [LOC, CNT]
        LDRB MAX, [TOS, CNT] @ char from c-addr2 => MAX
        CMP r0, MAX @ fail on first mismatch
        BNE csmf @ fail a bit slower
        SUB CNT, #1 @ count down
        BGT csml @ we already compared the counts

        @ success!
csms:
        MOV TOS, #0
        MVN TOS, TOS @ TRUE flag => TOS
        _next

csmf:
        @ failure
        MOV TOS, #0
        _next

.global _system_dict_end
_system_dict_end: .word .

.global _system_dict_bytes
_system_dict_bytes: .word _system_dict_end - _system_dict_start

.global _last_system_link
_last_system_link: .word _previous_link_field

/*

  Text interpreter pseudo-code

  INTERPRET: INTERPRET does the actual processing. It is usable by other processes
  besides QUIT, for example, a `BLOCK` loader or a WiFi server for a browser-based
  host tool.

  Initialize buffers and pointers / counts

  BEGIN

      Parse a token with `WORD`

  WHILE parse token length is greater than zero

      Classify the token with `CLASSIFY-TOKEN`. `CLASSIFY-TOKEN` returns two cells
      on the stack. The stack top is the classification of the token:

          0: The token is garbage; it wasn't found in the dictionary and isn't a
             valid number. Abort with a message; processing should not continue!

          If we get here, the token is valid. Top of stack:

          -1: The token is a number. Second of stack has the number.

          >0: The token is a name found in the dictionary. Second of stack has a
              "name token" as described in the "Programming-Tools" word set of the
              standard. The top of stack low-order bits are set to mean:

              0 Immediate
              1 Compile-only
              2-30 reserved for future use

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
                other: `NAME>COMPILE` and `COMPILE,`: get the execution token and
                       compile into the dictionary.

  REPEAT

  : CLASSIFY-TOKEN

      word length <= max name size IF
          search with FIND
          exit with success if found
      THEN

      parse number successful? IF
          exit with success
      THEN

      exit with failure
  ;

*/
