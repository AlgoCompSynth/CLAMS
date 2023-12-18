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
@ system is case-sensitive.

@ 3. Register usage: Pico SDK functions save registers r4 - r11, so we can use
@ them without saving. However, r8 - r11 have limited functionality - essentially
@ only source or destination of a MOV, one operand of an ADD or CMP, or as a branch
@ target.
@
@ Registers r0 - r3 are work registers and are used to interact with SDK functions.
@ They are not saved / restored, either by the SDK or by Forth words. Although the
@ SDK allows more than four parameters, there are by design no CLAMS functions
@ that do.
@
@ Register r3 is also called XRG and is used to contain the address of code to be
@ executed, either with a BX (unconditional branch with exchange) or a BLX (branch
@ and link with exchange).

@ Inner interpreter registers
@ These are the conventional direct threading registers - see "Moving Forth".
WRD .req r7 @ "Word" register
INP .req r6 @ Interpreter pointer - the Forth VM's program counter
PSP .req r5 @ Parameter stack pointer
RSP .req r4 @ Return stack pointer
XRG .req r3 @ "eXecute" register - used for branching and calling code functions

@ symbols for addressing expressions
@ reference: Forth 2012 standard, section D2.2
@ For the RP2040 SDK, an address unit is 8 bits aka a byte, and addressing is
@ little-endian.
.set _AU_CHAR, 1 @ address units per character
.set _AU_CELL, 4 @ address units per cell
.set _CELL_SHIFT, 2 @ bits to shift for cell - address unit conversions
.set _STACK_CELLS, 64 @ number of cells in a stack

@ macros for external addressing and function calls

        @ external nest
        .macro _x_nest
        PUSH {r0-r3, LR}
        .endm

        @ external unnest
        .macro _x_unnest
        POP {r0-r3, PC}
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
        _x_nest
        _x_load r0, \name\()
        MOV XRG, #1 @ force the thumb bit before branching!
        ORR XRG, r0
        BLX XRG
        _x_unnest
        .endm
