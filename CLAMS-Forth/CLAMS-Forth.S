
@ A Forth "Hello, World"

.thumb_func
.global main

main:
        @ initialize the hardware
	BL stdio_init_all

loop:
        @print "Ok"
	LDR R0, =Ok
	BL printf

        @ sleep for about 1/4 second
	@ MOV R0, #255
	@ BL sleep_ms

        @ loop forever
	B loop

.data
        .align 4
Ok:     .asciz "Ok\n"
