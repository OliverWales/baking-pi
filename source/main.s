.section .init
.globl _start
_start:
    b main

.section .data
.align 1
hello:
    .string "Hello, World!" /* .string adds null */
.align 1
dash:
    .string "-" /* .string adds null */

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


    ldr r0,=hello
    mov r1,#0
    mov r2,#0
    bl DrawString

    /* Test string length function */
    ldr r0,=hello
    bl StringLength
    mov r0,r4

    /* While r4 > 0 */
    lenLoop$:
        /* New line */
        add r2,r1,#16 /* y = lastY + 16 */
        mov r1,#0 /* x = 0 */

        /* Print '-' */
        ldr r0,=dash
        bl DrawString

        /*  */
        sub r4,#1
        cmp r4,#0
        bgt lenLoop$

    /* Test reverse string function */
    ldr r0,=hello
    bl ReverseString

    /* New line */
    add r2,r1,#16 /* y = lastY + 16 */
    mov r1,#0 /* x = 0 */

    /* Print "Hello, World!" reversed */
    ldr r0,=hello
    bl DrawString

    loop$:
        b loop$
