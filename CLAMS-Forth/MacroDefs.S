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
@ Registers r0 - r3 are work registers and are used for SDK function parameters.
@ They are not saved / restored by default, either by the SDK or between CLAMS-Forth
@ words. Although the SDK allows functions with more than four parameters, there are
@ by design no CLAMS-Forth functions that do so.

@ get definitions
.include "SymbolDefs.S" @ symbol definitions
.include "VirtMachMacros.S" @ virtual machine macros
.include "DictMacros.S" @ dictionary construction macros
