.section .init
.globl _start
_start:
    b main

.section .data
hello:
    .asciz "Hello, World!" /* .asciz adds null */

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

    /* Print "Hello, World!" */
    ldr r0,=hello
    mov r1,#0
    mov r2,#0
    bl DrawString

    /* Loop forever */
    loop$:
        b loop$
