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

    /* Test setting some pixels */
    x .req r0
    y .req r1

    mov x,#1
    mov y,#0
    bl SetPixel

    mov x,#3
    mov y,#0
    bl SetPixel

    mov x,#0
    mov y,#2
    bl SetPixel

    mov x,#4
    mov y,#2
    bl SetPixel

    mov x,#1
    mov y,#3
    bl SetPixel

    mov x,#2
    mov y,#3
    bl SetPixel

    mov x,#3
    mov y,#3
    bl SetPixel

    /* Loop forever */
    loop$:
        b loop$

