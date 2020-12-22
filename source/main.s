.section .init
.globl _start
_start:
    b main

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
    frameBufferInfoAddr .req r4
    mov frameBufferInfoAddr,r0
    bl SetGraphicsAddress

    /* Test drawing some lines */
    x0 .req r0
    y0 .req r1
    x1 .req r2
    y1 .req r3

    mov x0,#0
    mov y0,#0
    mov x1,#200
    mov y1,#400
    bl DrawLine

    mov x0,#200
    mov y0,#400
    mov x1,#200
    mov y1,#0
    bl DrawLine

    /* Loop forever */
    loop$:
        b loop$
