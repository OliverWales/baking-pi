.section .init
.globl _start
_start:
    b main

.section .data
hello:
    .asciz "TAB TEST\n========\n|...|...|...|...|...|\n1\t2\t3\t4\t5\t6\n\t2\t\t4\t\t6\n1\t11\t111\t1111\t1" /* .asciz adds null */

.section .text
main:
    mov sp,#0x8000

    /* Initialise frame buffer */
    mov r0,#1024
    mov r1,#768
    mov r2,#16
    bl InitialiseFrameBuffer

    teq r0,#0
    bne noError$

    /* Turn on LED and loop if error */
    mov r0,#16
    mov r1,#1
    bl SetGpioFunction
    mov r0,#16
    mov r1,#0
    bl SetGpio

    error$:
        b error$

    /* Set graphics address */
    noError$:
    bl SetGraphicsAddress

    /* Print "Hello, World!" at (0, 0) */
    ldr r0,=hello
    mov r1,#0
    mov r2,#0
    bl DrawString

    /* Loop forever */
    loop$:
        b loop$
