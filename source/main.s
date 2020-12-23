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

    /* Print "Hello, World!" */
    c .req r0
    x .req r1
    y .req r2

    mov x,#0
    mov y,#0
    mov c,#'H'
    bl DrawCharacter

    add x,r0
    mov c,#'e'
    bl DrawCharacter

    add x,r0
    mov c,#'l'
    bl DrawCharacter

    add x,r0
    mov c,#'l'
    bl DrawCharacter

    add x,r0
    mov c,#'o'
    bl DrawCharacter

    add x,r0
    mov c,#','
    bl DrawCharacter

    add x,r0
    mov c,#' '
    bl DrawCharacter

    add x,r0
    mov c,#'W'
    bl DrawCharacter

    add x,r0
    mov c,#'o'
    bl DrawCharacter

    add x,r0
    mov c,#'r'
    bl DrawCharacter

    add x,r0
    mov c,#'l'
    bl DrawCharacter

    add x,r0
    mov c,#'d'
    bl DrawCharacter

    add x,r0
    mov c,#'!'
    bl DrawCharacter

    /* Loop forever */
    loop$:
        b loop$
