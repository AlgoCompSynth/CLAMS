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

/*

  ## Introduction

  In building CLAMS-Forth, I've been using the following as my guidelines for using
  the Forth 2012 standard:

  1. CLAMS-Forth is an extended subset of the standard. I'm not even implementing
     all of the CORE word set, just those words that I'm using for the intended
     application, live coded audio-visual performance. But I am implementing some
     words from optional word sets and some enchancements of my own.

  2. When I do implement and use a word from any of the Forth 2012 word sets, it
     will behave exactly the way the standard says it is supposed to behave.

  CLAMS-Forth is a subroutine-threaded Forth that can inline some words into colon
  definitions. It is written mostly in Arm Cortex M0+ macro assembler, with some
  operations written in C for the Raspberry Pi Pico SDK.

  The Arm Cortex M0+ instruction set is quite constrained, especially for operations
  common in Forth implementations, like randomly accessing the entire memory space.
  One place where this is a major impediment is in building the text interpreter.

  I've spent about a week trying to come up with a way to build the text interpreter
  in Forth, just using the words provided in the standard, and haven't made much
  progress. So I've come up with a different design, described below.

  One final introductory note: CLAMS-Forth by design does ***not*** use transient
  memory buffers. The only variable-sized construct in CLAMS-Forth is the
  dictionary, and the only reason for that exception is that the compiler has to be
  able to compile new words into it. All other memory areas - user variables,
  stacks, and buffers - are of fixed size and accessed only via getter and setter
  routines or standard words such as "BASE", "SOURCE" and ">IN".

  ## Pseudo-code

  1. QUIT: QUIT is the word that initially manages interaction between the user and
      Forth. It looks like this:

         Reset everything that needs resetting

         BEGIN

           Read a line from the user using `ACCEPT`
           Call `EVALUATE` to interpret / compile the line
           Acknowledge processing (" Ok") using `TYPE`

         AGAIN

  2. EVALUATE: EVALUATE does the actual processing. It is usable by other processes
     besides QUIT, for example, a `BLOCK` loader or a WiFi server for a
     browser-based host tool.

         Initialize buffers and pointers / counts

         BEGIN

             Parse a token with `PARSE-NAME`

         WHILE parse token length is greater than zero

             Classify the token with `CLASSIFY-TOKEN`. `CLASSIFY-TOKEN` returns
             two or three cells on the stack. The stack top is the classification
             of the token:

             0: The token is garbage; it wasn't found in the dictionary and isn't a
                valid number. Abort with a message; processing should not continue!

             If we get here, the token is valid. Top of stack:

             -1: The token is a number. Second of stack has the number.
             -2: The token is a double-cell number. Second and third have the
                number.
             >0: The token is a name found in the dictionary. Second of stack has
                 a "name token" as described in the "Programming-Tools" word set of
                 the standard. The top of stack low-order bits are set to mean:

                0 Immediate
                1 Compile-only
                2 Compile inline
                3-14 reserved for future use
                15 always set

              STATE = interpret:
                  token is a number? It's already on the stack, just make sure the
                  classifier flag has been taken off.

                  token is a found name?  If compile-only, abort with a message;
                  processing should not continue. Otherwise get its execution token
                  `NAME>INTERPRET` and `EXECUTE`.

              STATE = compile:
                  token is a number? compile literal

                  token is a found name? if immediate, get its execution token and
                  `EXECUTE`. If inline, copy its code into the current definition.
                  Otherwise, `NAME>COMPILE` and `COMPILE,`: get the execution token
                  and compile either a short BL or a BLX using register r0 to its
                  code, depending on how far away the called routine is from where
                  the call is stored in the dictionary.

         REPEAT
  
*/
