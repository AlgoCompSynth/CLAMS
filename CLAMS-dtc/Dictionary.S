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

@ macros for external addressing and function calls

        @ nest
        .macro _x_nest
        PUSH {LR}
        .endm

        @ SDK unnest
        .macro _x_unnest
        POP {PC}
        .endm

        @ macro to create an "x_addr" word
        .macro _x_addr name
        .balign _AU_CELL
        .set _addr_\name\(), .
        .word \name
        .endm

        @ macro to load an "x_addr" word
        .macro _x_load reg, name
        LDR \reg, _addr_\name\() @ get the address
        .endm

        @ macro to call a function via XRG
        .macro _x_call name
        @LDR r0, _addr_\name\() @ get the address
        _x_load r0, \name\()
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
        ADD INP, #_AU_CELL @ advance INP
        BX WRD @ jump to next code routine
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
@ see F83
.global _doLIST
.thumb_func
_doLIST:
	ADD WRD, #_AU_CELL @ point to first word of thread
        _push_to RS INP @ nest INP
        MOV INP, WRD @ "branch indirect" to INP
        _next

.global _doLIT
.thumb_func
_doLIT:
        ADD WRD, #_AU_CELL @ point to constant
        LDR r0, [WRD]
        _push_to PS r0 @ push the constant
        _next

@ the dictionary itself!

.balign _AU_CELL
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

        _header "!", store, _COMPLETE
        _code_word
        _pop_two PS @ pop data => r0, address => r1
        STR r0, [r1]
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
        _x_nest
        _pop_from PS, r1 @ divisor => r1
        _pop_from PS, r0 @ dividend => r0
        _x_call sdk_slash_mod
        _push_to PS, r1 @ push remainder
        _push_to PS, r0 @ push quotient
        _x_unnest
        _next

        _header "/", slash, _COMPLETE
        _code_word
        _x_nest
        _pop_from PS, r1 @ divisor => r1
        _pop_from PS, r0 @ dividend => r0
        _x_call sdk_slash_mod
        _push_to PS, r0 @ push quotient
        _x_unnest
        _next

        _header "MOD", mod, _COMPLETE
        _code_word
        _x_nest
        _pop_from PS, r1 @ divisor => r1
        _pop_from PS, r0 @ dividend => r0
        _x_call sdk_slash_mod
        _push_to PS, r1 @ push remainder
        _x_unnest
        _next

_x_addr sdk_slash_mod

        @ terminal I/O words
        _header "KEY", key, _COMPLETE
        _code_word
        _x_nest
        _x_call sdk_key
        _push_to PS, r0
        _x_unnest
        _next

_x_addr sdk_key

        _header "EMIT", emit, _COMPLETE
        _code_word
        _x_nest
        _pop_from PS, r0
        _x_call sdk_emit
        _x_unnest
        _next

_x_addr sdk_emit

        _header "EXECUTE", execute, _COMPLETE
        _code_word
        _pop_from PS, r0 @ get execution token
        MOV XRG, #1 @ set thumb bit
        ORR XRG, r0 @ ready for BX
        BX XRG @ unconditional branch without link

        @ stacks grow downwards - top of stack is the lowest address
        @ _param_stack_top is the lowest address that can legally contain a cell
        @ _param_stack_bottom is one cell *above* the highest address that can
        @ legally contain a cell!
        _header "clear_param_stack", clear_param_stack, _COMPLETE
        _code_word
        _x_load PSP, _param_stack_bottom
        _x_load r1, _param_stack_top
        LDR r0, _hamburger
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
        LDR r0, _hamburger
crs1:
        STR r0, [r1]
        ADD r1, #_AU_CELL
        CMP r1, RSP
        BLO crs1
        _next

_x_addr _return_stack_bottom
_x_addr _return_stack_top
.balign _AU_CELL, 0
_hamburger: .word 0xDEADBEEF

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

_x_addr printf

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
