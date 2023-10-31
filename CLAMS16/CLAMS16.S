@
@ CLAMS16 main program
@ Reference: Stephen Smith, _RP2040 Assembly Language Programming, Chapter 2
@
@ R0 - first parameter to printf
@

.thumb_func
.global main

main:
	BL	stdio_init_all	@ initialize uart or usb
loop:
	LDR	R0, =OllKorrect	@ load address of 'Ok' string
	BL	printf		@ Call pico_printf
	B	loop		@ loop forever
		
.data
	       .align  4	@ necessary alignment
OllKorrect: .asciz   "2 3 + .\n5 OK\n\n"
