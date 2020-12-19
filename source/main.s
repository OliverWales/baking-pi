.section .init
.globl _start
_start:
    b main

.section .text
main:
    mov sp,#0x8000

    /* Set pin 16 function */
    pinNum .req r0
    pinFunc .req r1
    mov pinNum,#16
    mov pinFunc,#1
    bl SetGpioFunction
    .unreq pinNum
    .unreq pinFunc

    /* Load pattern into r4 */
    ptrn .req r4
    ldr ptrn,=pattern
    ldr ptrn,[ptrn]

    /* Index into pattern stored in r5 */
    seq .req r5
    mov seq,#0

    loop:
        /* Get current value in pattern */
        pinVal .req r1
        mov r1,#1
        lsl r1,seq
        and r1,ptrn

        /* Set pin 16 to that value */
        pinNum .req r0
        mov pinNum,#16
        mov pinVal,#0
        bl SetGpio
        .unreq pinNum
        .unreq pinVal

        /* Wait 0.25 seconds */
        duration .req r0
        ldr duration,=250000
        bl Wait
        .unreq duration

        /* Increment index and reset if >= 32 */
        add seq,#1
        and seq,#0b11111

        /* Loop forever */
        b loop

.section .data
.align 2
pattern:
    .int 0b11111111101010100010001000101010
