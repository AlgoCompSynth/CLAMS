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

@ inner interpreters

.global _enter
_enter:
        _push_to RS INP @ nest INP
	ADD WRD, #_AU_CELL @ point to first word of thread
        MOV INP, WRD @ "branch indirect" to INP
        _next

.global _do_var
_do_var:
        ADD WRD, #_AU_CELL @ address of variable => WRD
        _push_to PS WRD @ push to parameter stack
        _next

.global _do_const
_do_const:
        ADD WRD, #_AU_CELL @ address of constant => WRD
        LDR r0, [WRD] @ constant value => r0
        _push_to PS r0 @ push to parameter stack
        _next

@ Strings compiled with C" and strings compiled with S" are both stored as counted
@ strings. So we need two different inner interpreters.
.global _do_cq_string
_do_cq_string:
        ADD WRD, #_AU_CELL @ address of counted string => WRD
        _push_to PS WRD @ push to parameter stack
        _next

.global _do_sq_string
_do_sq_string:
        ADD WRD, #_AU_CELL @ address of counted string => WRD
        LDRB r0, [WRD] @ count => r0
        ADD WRD, #_AU_CHAR @ skip the count byte
        _push_to PS WRD @ push address to parameter stack
        _push_to PS r0 @ push count to parameter stack
        _next

@ the dictionary itself!

.balign _AU_CELL
.global _system_dict_start
_system_dict_start: .word .

        @ code words for base VM

        _header "EXIT", exit, _COMPILE_ONLY
        _code_word
        _pop_from RS, INP @ un-nest the return stack to INP
        _next

        _header "LITERAL", literal, _COMPILE_ONLY
        _code_word
        LDR r0, [INP] @ literal value => r0
        _push_to PS r0 @ push to parameter stack
        ADD INP, #_AU_CELL @ skip over the literal!
        _next

        _header "EXECUTE", execute
        _code_word
        _pop_from PS, WRD @ execution token => WRD
        MOV XRG, #1 @ set thumb bit
        ORR XRG, WRD @ ready for BX
        BX XRG @ unconditional branch without link

        _header "branch", branch, _COMPILE_ONLY
        _code_word
        LDR INP, [INP]
        _next

        _header "?branch", question_branch, _COMPILE_ONLY
        _code_word
        _pop_from PS, r0 @ flag => r0
        CMP r0, #0
        BNE qbz @ branch if flag is TRUE
        LDR INP, [INP] @ flag is false - take the branch
        _next
qbz:
        ADD INP, #_AU_CELL @ flag is true - skip branch destination
        _next

        _header "DUP", dupe
        _code_word
        LDR r0, [PSP]
        _push_to PS, r0
        _next

        _header "OVER", over
        _code_word
        LDR r0, [PSP, #_AU_CELL] @ 2nd => r0
        _push_to PS, r0
        _next

        _header "SWAP", swap
        _code_word
        LDM PSP, {r0, r1, PSP} @ top => r0, 2nd => r1
        STR r1, [PSP]
        STR r0, [PSP, #_AU_CELL]
        _next

        _header "DROP", drop
        _code_word
        _pop_from PS, r0
        _next

        _header "ROT", rote
        _code_word
        @ x1, x2, x3 -> x2, x3, x1
        LDM PSP, {r0, r1, r2, PSP} @ x3 => r0, x2 => r1, x1 => r2
        STR r1, [PSP, #_AU_CELL*2] @ stash x2
        STR r0, [PSP, #_AU_CELL] @ stash x3
        STR r2, [PSP] @ stash x1
        _next

        @ position-independent operations
        _header "@", fetch
        _code_word
        LDR r0, [PSP] @ address => r0
        LDR r0, [r0] @ data => r0
        _push_to PS, r0
        _next

        _header "C@", c_fetch
        _code_word
        LDR r0, [PSP] @ address => r0
        LDRB r0, [r0] @ data => r0
        _push_to PS, r0
        _next

        _header "!", store
        _code_word
        _pop_two PS @ pop data => r0, address => r1
        STR r0, [r1]
        _next

        _header "C!", c_store
        _code_word
        _pop_two PS @ pop data => r0, address => r1
        STRB r0, [r1]
        _next

        _header ">R", to_r, _COMPILE_ONLY
        _code_word
        _pop_from PS, r0 @ pop parameter stack => r0
        _push_to RS, r0 @ push r0 => return stack
        _next

        _header "R>", r_from, _COMPILE_ONLY
        _code_word
        _pop_from RS, r0 @ pop return stack => r0
        _push_to PS, r0 @ push r0 => parameter stack
        _next

        _header "R@", r_fetch, _COMPILE_ONLY
        _code_word
        LDR r0, [RSP] @ top of return stack => r0
        _push_to PS, r0 @ push r0 => parameter stack
        _next

        _header "1+", one_plus
        _code_word
        _unary_op "ADD r0, #1"
        _next

        _header "1-", one_minus
        _code_word
        _unary_op "SUB r0, #1"
        _next

        _header "2*", two_star
        _code_word
        _unary_op "LSL r0, #1"
        _next

        _header "2/", two_slash
        _code_word
        _unary_op "ASR r0, #1"
        _next

        _header "CELL+", cell_plus
        _code_word
        _unary_op "ADD r0, #_AU_CELL"
        _next

        _header "CELL-", cell_minus
        _code_word
        _unary_op "SUB r0, #_AU_CELL"
        _next

        _header "CELLS", cells
        _code_word
        _unary_op "LSL r0, #_CELL_SHIFT"
        _next

        _header "CHAR+", char_plus
        _code_word
        _unary_op "ADD r0, #_AU_CHAR"
        _next

        _header "CHAR-", char_minus
        _code_word
        _unary_op "SUB r0, #_AU_CHAR"
        _next

        _header "CHARS", chars
        _code_word
        _next

        @ arithmetic operators
        _header "+", plus
        _code_word
        _binary_alu ADD
        _next

        _header "-", minus
        _code_word
        _binary_alu SUB
        _next

        _header "*", star
        _code_word
        _binary_alu MUL
        _next

        _header "NEGATE", negate
        _code_word
        _unary_op "NEG r0, r0"
        _next

        _header "ALIGNED", aligned
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
        _header "AND", and
        _code_word
        _binary_alu AND
        _next

        _header "OR", or
        _code_word
        _binary_alu ORR
        _next

        _header "XOR", x_or
        _code_word
        _binary_alu EOR
        _next

        _header "INVERT", invert
        _code_word
        MVN r0, r0
        _next

        _header "LSHIFT", l_shift
        _code_word
        _binary_alu LSL
        _next

        _header "RSHIFT", r_shift
        _code_word
        _binary_alu LSR
        _next

        @ binary comparison operators
        _header "<", less_than
        _code_word
        _binary_cmp LT
        _next

        _header "<=", less_or_equal
        _code_word
        _binary_cmp LE
        _next

        _header "=", equals
        _code_word
        _binary_cmp EQ
        _next

        _header "<>", not_equal
        _code_word
        _binary_cmp NE
        _next

        _header ">", greater_than
        _code_word
        _binary_cmp GT
        _next

        _header ">=", greater_or_equal
        _code_word
        _binary_cmp GE
        _next

        _header "U>", u_greater_than
        _code_word
        _binary_cmp HI
        _next

        _header "U>=", u_greater_or_equal
        _code_word
        _binary_cmp HS
        _next

        _header "U<", u_less_than
        _code_word
        _binary_cmp LO
        _next

        _header "U<=", u_less_or_equal
        _code_word
        _binary_cmp LS
        _next

.balign _AU_CELL, 0
_TRUE_FLAG: .word 0xFFFFFFFF

        @ division operators - use the SDK and hardware divider
        _header "/MOD", slash_mod
        @ ( dividend divisor –– remainder quotient )
        _code_word
        _pop_from PS, r1 @ divisor => r1
        _pop_from PS, r0 @ dividend => r0
        _x_call sdk_slash_mod
        _push_to PS, r1 @ push remainder
        _push_to PS, r0 @ push quotient
        _next

        _header "/", slash
        _code_word
        _pop_from PS, r1 @ divisor => r1
        _pop_from PS, r0 @ dividend => r0
        _x_call sdk_slash_mod
        _push_to PS, r0 @ push quotient
        _next

        _header "MOD", mod
        _code_word
        _pop_from PS, r1 @ divisor => r1
        _pop_from PS, r0 @ dividend => r0
        _x_call sdk_slash_mod
        _push_to PS, r1 @ push remainder
        _next

_x_addr sdk_slash_mod

        @ terminal I/O words
        _header "KEY", key
        _code_word
        _x_call sdk_key
        _push_to PS, r0
        _next

        _header "EMIT", emit
        _code_word
        _pop_from PS, r0
        _x_call sdk_emit
        _next

        @ stacks grow downwards - top of stack is the lowest address
        @ _param_stack_top is the lowest address that can legally contain a cell
        @ _param_stack_bottom is one cell *above* the highest address that can
        @ legally contain a cell!
        _header "clear_param_stack", clear_param_stack
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

        _header "clear_return_stack", clear_return_stack
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

        _header "param_top_3", param_top_3
        _code_word
        LDR r0, =_param_format
        LDM PSP, { r1, r2, r3, PSP}
        _x_call printf
        _next

        _header "return_top_3", return_top_3
        _code_word
        LDR r0, =_return_format
        LDM RSP, { r1, r2, r3, RSP}
        _x_call printf
        _next

_x_addr printf

        _header "colon-test", colon_test
        _colon_word
        _code_literal 2
        _code_literal 3
        .word _param_top_3
        .word _plus
        .word _param_top_3
        .word _exit

        _header "crash", crash
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

        _header "ABORT", abort
        @ ( anything -- )
        _colon_word
        .word _clear_param_stack
        .word _quit
        .word _crash @ this should never get executed because QUIT never exits

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
        .word _evaluate @ EVALUATE is the text interpreter!
        .word _oll_korrect
        _ubranch quil
        .word _crash @ this should never get executed

        _header "EVALUATE", evaluate
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
        _x_load r0, _terminal_buffer
        _push_to PS, r0
        _next

_x_addr _terminal_buffer

        _header "FILL", fill
        @ ( c-addr u char –– )
        _code_word
        _pop_from PS, r0 @ char => r0,
        _pop_from PS, CNT @ u => CNT
        _pop_from PS, LOC @ c-addr => LOC

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

        _pop_from PS, XRG @ pop max count => XRG
        _pop_from PS, LOC @ pop address => LOC
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

        @ a printable character - echo it and append to buffer
_acce:
        STRB r0, [LOC, CNT] @ append char to buffer
        ADD CNT, #1 @ count the character

        _pushlctl
        _x_call sdk_emit @ printable - send it out!
        _poplctl

        @ check for buffer end
        CMP CNT, XRG @ did we hit the limit?
        BEQ _accz @ early exit if limit hit!
	B _accl @ there's room - go back for more!

        @ space or unprintable
_accs:
        MOV r0, #_BL @ force a space and emit / store / count
        B _acce

        @ backspace - un-count previous character and erase it
_accb:
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

        @ clean up and exit
_accz:
        @ push count; exit
        _push_to PS, CNT
        _next

        _header "TYPE", type
        @ ( c-addr u –– )
        _code_word

        _pop_from PS, XRG @ count => XRG
        _pop_from PS, LOC @ address => LOC
        MOV CNT, #0 @ count up

typl:
        CMP CNT, XRG @ are we done?
        BGE typz @ exit!

        LDRB r0, [LOC, CNT] @ character => r0
        CMP r0, #0 @ is it a null terminator?
        BEQ typz @ exit on null terminator

        _pushlctl
        _x_call sdk_emit @ emit the character
        _poplctl

        ADD CNT, #1 @ count up
        B typl @ continue

typz:
        _next

_x_addr sdk_key
_x_addr sdk_emit

        _header "COUNT", "count"
        @ ( c-addr1 –– c-addr2 u )
        _code_word
        _pop_from PS, r0 @ address => LOC
        LDRB r0, [LOC] @ count byte => r0
        ADD LOC, #_AU_CHAR @ fix address
        _push_to PS, LOC
        _push_to PS, r0
        _next

        @ counted string match
        _header "cs-match", "c_s_match"
        @ (c-addr1 c-addr2 -- c-addr1 flag)
        @ flag is true if strings are identical, false otherwise
        _code_word
        _pop_from PS, LOC @ pop addr2 => LOC
        LDRB CNT, [LOC] @ count of c-addr2 => CNT
        LDR XRG, [PSP] @ c-addr1 => XRG
        LDRB r0, [XRG] @ count of c-addr1 => r0
        CMP r0, CNT @ if the counts aren't equal, we are done!
        BNE csmf @ fail fast!

csml:
        @ main compare loop
        LDRB r0, [LOC, CNT]
        MOV TMP1, r0 @ char from addr2 => TMP1
        LDRB r0, [XRG, CNT] @ char from addr1 => r0
        CMP r0, TMP1 @ fail on first mismatch
        BNE csmf @ fail a bit slower
        SUB CNT, #1 @ count down
        BGT csml @ we already compared the counts

csms:
        @ success!
        MOV r0, #0
        MVN r0, r0 @ TRUE flag => r0
        _push_to PS, r0 @ push to parameter stack
        _next

csmf:
        @ failure
        MOV r0, #0
        _push_to PS, r0 @ push to parameter stack
        _next

/*

        _header "'", tick
        _nest
        @ TBD
        _unnest
        @_header "FIND", "find"
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
