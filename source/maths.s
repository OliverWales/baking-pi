/*
* Divide r0 by r1 and return the result in r0 and remainder in r1
*/
.globl IntDiv
IntDiv:
    result .req r0
    remainder .req r1
    shift .req r2
    current .req r3

    clz shift,r1
    clz r3,r0
    subs shift,r3
    lsl current,r1,shift
    mov remainder,r0
    mov result,#0

    /* Return dividend if dividend is shorter than divisor */
    blt intDivLoopReturn$

    intDivLoop$:
        cmp remainder,current
        blt intDivLoopContinue$

        add result,result,#1
        subs remainder,current

        /* Return result if remainder reaches zero */
        lsleq result,shift
        beq intDivLoopReturn$

        intDivLoopContinue$:
        subs shift,#1
        lsrge current,#1
        lslge result,#1
        /* Return when shift <= 0 */
        bge intDivLoop$

    intDivLoopReturn$:
    mov pc,lr

    .unreq result
    .unreq remainder
    .unreq shift
    .unreq current
