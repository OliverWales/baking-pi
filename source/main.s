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
    px .req r0
    px .req r1

    mov px,#1
    mov py,#0
    bl SetPixel

    mov px,#3
    mov py,#0
    bl SetPixel

    mov px,#0
    mov py,#2
    bl SetPixel

    mov px,#4
    mov py,#2
    bl SetPixel

    mov px,#1
    mov py,#3
    bl SetPixel

    mov px,#2
    mov py,#3
    bl SetPixel

    mov px,#3
    mov py,#3
    bl SetPixel

    /* Loop forever */
    loop$:
        b loop$
