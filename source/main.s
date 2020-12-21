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

    /* Move frame buffer info address in r4 */
    noError$:
    frameBufferInfoAddr .req r4
    mov frameBufferInfoAddr,r0

    render$:
        /* Get address of frame buffer */
        frameBufferAddr .req r3
        ldr frameBufferAddr,[frameBufferInfoAddr,#32]

        colour .req r0
        y .req r1
        mov y,#768

        /* Loop over rows */
        drawRow$:
            x .req r2
            mov x,#1024

            /* Loop over columns */
            drawPixel$:
                /* Write pixel */
                strh colour,[frameBufferAddr]

                /* Increment frame buffer address */
                add frameBufferAddr,#2

                /* Decrement x */
                sub x,#1
                teq x,#0
                bne drawPixel$

            /* Decrement y */
            sub y,#1

            /* Increment colour */
            add colour,#1
            teq y,#0
            bne drawRow$

        /* Loop forever */
        b render$

        .unreq frameBufferAddr
        .unreq frameBufferInfoAddr

