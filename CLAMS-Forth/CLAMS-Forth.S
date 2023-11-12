
@ test harness for Forth VM

.include "Symbol-Defs.S"

.thumb_func
.global main

main:
	BL stdio_init_all @ initialize standard I/O
        MOV R0, #1
        BL .push1
        MOV R1, #2
        BL .push2
        MOV R2, #3
        BL .push3
        MOV R3, #4
        BL .push4

	.align cell

five:
	.word 5
seven:
        .word 7

format:
        .asciz "\npsp, tos = %x, %x\n"
