.section .init
.globl _start
_start:
    b main

.section .text
main:
    mov sp,#0x8000

    /* Set pin 16 high */
    pinNum .req r0
    pinFunc .req r1
    mov pinNum,#16
    mov pinFunc,#1
    bl SetGpioFunction
    .unreq pinNum
    .unreq pinFunc

    /* Wait */
    decr .req r0
    mov decr,#0x3F0000
    wait1$: 
        sub decr,#1
        teq decr,#0
        bne wait1$
    .unreq decr

    /* Set pin 16 low */
    pinNum .req r0
    pinVal .req r1
    mov pinNum,#16
    mov pinVal,#0
    bl SetGpio
    .unreq pinNum
    .unreq pinVal

    /* Wait */
    decr .req r0
    mov decr,#0x3F0000
    wait2$: 
        sub decr,#1
        teq decr,#0
        bne wait2$
    .unreq decr

    /* Loop forever */
    b main