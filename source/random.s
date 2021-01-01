/*
* Return a pseudorandom number seeded by the value in r0
*/
.globl Random
Random:
    xnm .req r0
    a .req r1

    mov a,#0xef00
    mul a,xnm
    mul a,xnm
    add a,xnm
    .unreq xnm
    add r0,a,#73

    .unreq a
    mov pc,lr
