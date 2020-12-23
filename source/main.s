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
    x .req r4
    y .req r5

    mov x,#0
    mov y,#0

    mov r0,#'H'
    mov r1,x
    mov r2,y
    bl DrawCharacter
    add x,r0
    
    mov r0,#'e'
    mov r1,x
    mov r2,y
    bl DrawCharacter
    add x,r0

    mov r0,#'l'
    mov r1,x
    mov r2,y
    bl DrawCharacter
    add x,r0

    mov r0,#'l'
    mov r1,x
    mov r2,y
    bl DrawCharacter
    add x,r0

    mov r0,#'o'
    mov r1,x
    mov r2,y
    bl DrawCharacter
    add x,r0

    mov r0,#','
    mov r1,x
    mov r2,y
    bl DrawCharacter
    add x,r0

    mov r0,#' '
    mov r1,x
    mov r2,y
    bl DrawCharacter
    add x,r0

    mov r0,#'W'
    mov r1,x
    mov r2,y
    bl DrawCharacter
    add x,r0

    mov r0,#'o'
    mov r1,x
    mov r2,y
    bl DrawCharacter
    add x,r0

    mov r0,#'r'
    mov r1,x
    mov r2,y
    bl DrawCharacter
    add x,r0

    mov r0,#'l'
    mov r1,x
    mov r2,y
    bl DrawCharacter
    add x,r0

    mov r0,#'d'
    mov r1,x
    mov r2,y
    bl DrawCharacter
    add x,r0

    mov r0,#'!'
    mov r1,x
    mov r2,y
    bl DrawCharacter

    /* Loop forever */
    loop$:
        b loop$
