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

        @ "next" macro
        @ We follow the Forth 83 model of indirect addressing. In this model, an
        @ execution token is the code field address of a word in the dictionary.
        @ See "F83 Overview", section 4.3. Note that since we are using a BX through
        @ a register, the code field address MUST have the low-order "thumb" bit set
        @ to 1!
        .macro _next
        LDR WORDR, [INTPR] @ next code field address => WORDR
        ADD INTPR, #_AU_CELL @ advance INTPR
        LDR r0, [WORDR] @ next branch target => r0
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
        PUSH {COUNT, ADDRS, CTMAX}
        .endm
        .macro _poplctl @ pop loop control registers
        POP {COUNT, ADDRS, CTMAX}
        .endm

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

        @ macro to call an external function via WORDR
        @ we use WORDR because function parameters can be in r0 - r3
        .macro _x_call name
        PUSH {WORDR} @ save WORDR!!!
        _x_load WORDR, \name\() @ fetch the external function's address
        BLX WORDR @ call the function
        POP {WORDR} @ restore WORDR
        .endm

@ "_expand" macro
@ Many words are generated from macros in "VirtMachMacros.S", and can be generated
@ with @ a single line of code! This is the macro that does the expansion.

        .macro _expand wname, pronunciation
        _header "\wname\()", \pronunciation\()
        _code_word
        _\pronunciation\()_
        _next
        .endm
