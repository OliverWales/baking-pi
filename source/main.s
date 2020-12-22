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
    bl SetGraphicsAddress

    /* Pi-casso */
    lastRandom .req r4
    x .req r5
    y .req r6
    colour .req r7
    lastX .req r8
    lastY .req r9

    mov lastRandom,#0
    mov colour,#0
    mov lastX,#0
    mov lastY,#0
    
    renderLoop$:
        /* Generate random x and y */
        mov r0, lastRandom
        bl Random
        mov x,r0
        bl Random
        mov y,r0
        mov lastRandom,r0

        /* Shift into range 0-1023 */
        lsr r2,x,#22
	    lsr r3,y,#22

        /* Re-select if out of y range */
        cmp r3,#768
	    bhs renderLoop$

        /* Set colour */
        mov r0,colour
        bl SetForegroundColour

        /* Draw line */
        mov r0,lastX
        mov r1,lastY
        bl DrawLine

        /* Update last position */
        mov lastX,r2
	    mov lastY,r3

        /* Update colour */
        add colour,#1
        lsl colour,#16
        lsr colour,#16

        b renderLoop$

        .unreq lastRandom
        .unreq lastX
        .unreq lastY
        .unreq x
        .unreq y
        .unreq colour
