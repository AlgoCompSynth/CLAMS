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

@ coding conventions:

@ 1. Names internal to the CLAMS system have a leading underscore and are restricted
@ to the character set of Arm GNU assembler symbols. Function names and variables
@ use only lower-case letters, constants use only upper case letters.

@ 2. Names intended to represent Forth words have the Forth syntax. Words that are 
@ defined in the Forth standard use only upper case letters and behave the same way
@ they do in the standard. Names created by the user can use either case and the
@ system is case-sensitive. Sorry, but if you want "DUP", you won't be able to type
@ "dup".

@ 3. Register usage: Pico SDK functions save registers r4 - r11, so we can use
@ them without saving. However, r8 - r11 have limited functionality - essentially
@ only source or destination of a MOV, one operand of an ADD or CMP, or to hold a
@ branch target.
@
@ Registers r0 - r3 are work registers and are used to interact with SDK functions.
@ They are not saved / restored by default, either by the SDK or by Forth words.
@ Although the SDK allows more than four parameters, there are by design no CLAMS
@ functions that do.
@
@ Inner interpreter registers
@ These are the conventional indirect threading registers - see "Moving Forth".
WRD .req r7 @ "Word" register
INP .req r6 @ Interpreter pointer - the Forth VM's program counter
PSP .req r5 @ Parameter stack pointer
TOS .req r4 @ Cached copy of the top cell of the parameter stack

@ working registers in code words
MAX .req r3 @ used in character loops
LOC .req r2 @ used in character loops
CNT .req r1 @ used in character loops

@ Temporary storage registers
@ The SDK routines save these if they use them. They're less useful than r0 - r7,
@ but they're faster than going to RAM.
TMP1 .req r8
TMP2 .req r9
TMP3 .req r10
TMP4 .req r11

@ symbols for addressing expressions
@ reference: Forth 2012 standard, section D2.2
@ For the RP2040 SDK, an address unit is 8 bits aka a byte, and addressing is
@ little-endian.
.set _AU_CHAR, 1 @ address units per character
.set _AU_HALF, 2 @ address units per halfword
.set _AU_CELL, 4 @ address units per cell
.set _CELL_SHIFT, 2 @ bits to shift for cell - address unit conversions
.set _HALF_SHIFT, 1 @ bits to shift for cell - address unit conversions
.set _STACK_CELLS, 64 @ number of cells in a stack
.set _MAX_CSTRING, 255 @ maximum number of characters in a counted string
.set _MAX_WNAME, 31 @ maximum number of characters in a word name
.set _MAX_TERMBUF, 84 @ maximum number of characters in a terminal buffer line
.set _USER_DICT_CELLS, 32768 @ about half of the RP2040 RAM!

@ character codes
.set _NUL, 0x00 @ null / string terminator
.set _BEL, 0x07 @ bell
.set _BS, 0x08 @ backspace
.set _LF, 0x0A @ line feed
.set _CR, 0x0D @ carriage return
.set _BL, 0x20 @ space
.set _K, 0x4B @ letter "K"
.set _O, 0x4F @ letter "O"
.set _DEL, 0x7F @ delete / rubout

@ flags = various bits about a dictionary word
.set _COMPILE_ONLY, 0x1 @ COMPILE-ONLY word
.set _IMMEDIATE, 0x2 @ IMMEDIATE word

@ macros for external addressing and function calls

@ We sometimes need to address across the flash - SRAM boundary. To do this, we
@ create a nearby cell containing the address and load it into a register as needed.
@
@ If we are going to use that address as the target of a BX or BLX address, it needs
@ to have the "thumb bit" set via the assembler or at run time, or the RP2040 will
@ hang with a hardware fault!!

        @ macro to create a cell containing an external address
        .macro _x_addr name
        .balign _AU_CELL
        .set _addr_\name\(), .
        .word \name\()
        .endm

        @ macro to load an "x_addr" word into a register
        .macro _x_load reg, name
        LDR \reg\(), _addr_\name\() @ get the address
        .endm

        @ macro to call an external function via WRD
        @ we use WRD because function parameters can be in r0 - r3
        .macro _x_call name
        PUSH {WRD} @ save WRD!!!
        _x_load WRD, \name\() @ fetch the external function's address
        BLX WRD @ call the function
        POP {WRD} @ restore WRD
        .endm

@ stack macros - stacks grow downwards and stack pointers point to top element

        @ pop from parameter stack to register
        .macro _pop_from_ps regname
        LDM PSP!, {\regname\()}
        .endm

        @ push to parameter stack from register
        .macro _push_to_ps regname
        SUB PSP, #_AU_CELL
        STR \regname\(), [PSP]
        .endm

        @ pop two elements to r0, r1
        .macro _pop_two
        LDM PSP!, {r0, r1}
        .endm

        @ pop three elements to r0, r1, r2
        .macro _pop_three
        LDM PSP!, {r0, r1, r2}
        .endm

        @ macro for padded counted strings
        .macro _padded_counted_string string
        .set _count, 1f - . - 1
        .byte _count
        .ascii "\string\()"
1:      .balign _AU_CELL, 0
        .endm

@ dictionary construction macros

@ dictionary header

@ wname = word name in dictionary - what the Forth system searches for

@ pronunciation = Forth specifies how to pronounce many words. We make labels
@ from these, substituting an underscore for each dash in the pronunciation.

        @ generic word header
        .macro _header wname, pronunciation, flags=0

        @ build link field
        @ The CLAMS link field holds the distance in bytes to the previous link
        @ field. That way, we can determine the values during the assembly and
        @ link stages instead of having to make them all global symbols.
        @ Since link addresses are word-aligned, we can store the two flag bits in
        @ bits 0 and 1 and mask them off when we need to follow a link!
        .balign _AU_CELL, 0
        .set _link_field, .
        .set _\pronunciation\()_link, . @ debugging symbol for link field
        .if _link_field == _system_dict_start
          .word 0
        .else
          .word (_link_field - _previous_link_field) | \flags\()
        .endif
        .set _previous_link_field, _link_field

        @ build name field
        .set _name_field, .
        .set _\pronunciation\()_name, . @ debugging symbol for name field
        .set _count, 1f - . - 1
        .byte _count
        .ascii "\wname\()"
1:      .balign _AU_CELL, 0

        @ define global symbol for debugging / testing / internal reference. This is
        @ the code field address for the dictionary word! Note that we do *not* set
        @ the "thumb bit" here!
        .global _\pronunciation\()
        .set _\pronunciation\(), .
        .endm

        @ assemble code field for a machine code word
        @ For indirect threading, the code field address points to the next cell
        .macro _code_word
        .word . + _AU_CELL | 0x1 @ set thumb bit for BX through register
        .endm

        @ assemble code field for a colon definition
        .macro _colon_word
        .word _enter
        .endm

        @ assemble code field for a C-quote string
        .macro _cq_word
        .word _do_cq_string
        .endm

        @ assemble code field for an S-quote string
        .macro _sq_word
        .word _do_sq_string
        .endm

        @ assemble code field for a constant
        .macro _const_word
        .word _do_const
        .endm

        @ assemble code field for a variable
        .macro _var_word
        .word _do_var
        .endm

@ Common code for a word that uses a single instruction binary ALU operator on the
@ top two stack cells. Such words have the stack effect
@
@    ( left right -- result )
@
@ where `result` = `left <op> right`. That is, the postfix `left right <op>` has
@ the same `result` as the infix `left <op> right`.

        .macro _binary_alu opcode:req
        @ ( left right -- left OP right )
        ADD PSP, #_AU_CELL @ point to 2nd of stack
        LDR r0, [PSP] @ left operand => r0
        \opcode\() r0, TOS @ r0 := left <OP> right
        MOV TOS, r0
        STR TOS, [PSP] @ "push" result to parameter stack
        .endm

@ Common code for a word that compares the top two cells on the stack. Such words
@ have the stack effect
@
@    ( left right -- flag )
@
@ where `flag` = true (all ones) if `left <cmp> right` is true, and false (all
@ zeroes) if `left <cmp> right` is false.

        .macro _binary_cmp cmp:req
        ADD PSP, #_AU_CELL @ point to 2nd of stack
        LDR r0, [PSP] @ left operand => r0
        CMP r0, TOS
        B\cmp\() 1f @ branch if true
        MOV TOS, #0 @ FALSE flag => TOS
        B 2f @ exit
1:
        MOV TOS, #0
        MVN TOS, TOS @ TRUE flag => TOS
2:
        STR TOS, [PSP] @ "push" flag to parameter stack
        .endm

@ Common code for unary operations

        .macro _unary_op instruction:req
        \instruction\() @ instruction must perform a unary operation on TOS
        STR TOS, [PSP] @ save TOS to RAM
        .endm

        @ "next" macro
        @ We follow the Forth 83 model of indirect addressing. In this model, an
        @ execution token is the code field address of a word in the dictionary.
        @ See "F83 Overview", section 4.3
        .macro _next
        LDR WRD, [INP] @ next code field address => WRD
        ADD INP, #_AU_CELL @ advance INP
        LDR r0, [WRD] @ next branch target => r0
        BX r0 @ jump to next code routine
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

        @ literal coder macro
        .macro _code_literal value
        .word _literal
        .word \value\()
        .endm

        @ loop control register save / restore macros
        @ used before and after function calls
        .macro _pushlctl @ push loop control registers
        PUSH {CNT, LOC, MAX}
        .endm
        .macro _poplctl @ pop loop control registers
        POP {CNT, LOC, MAX}
        .endm
