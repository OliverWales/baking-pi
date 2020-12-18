/*
* GetSystemTimerAddress returns the base address of the system timer as a physical
* address in register r0
*/
.globl GetSystemTimerAddress
GetSystemTimerAddress:
    ldr r0,=0x20003000
    mov pc,lr

/*
* GetSystemTimerValue returns the upper 4 bytes of the counter in r1 and the lower
* 4 bytes in r0
*/
.globl GetSystemTimerValue
GetTimeStamp:
    push {lr}
    bl GetSystemTimerAddress
    ldrd r0,r1,[r0,#4]
    pop {pc}

/*
* Wait the number of microseconds in r0 have elapsed and return
*/
.globl Wait
Wait:
    delay .req r2
    mov delay,r0

    /* Get initial value of timer */
    push {lr}
    bl GetTimeStamp
    start .req r3
    mov start,r0

    /* Wait until the requested number of milliseconds have elapsed */
    loop$:
        bl GetTimeStamp
        elapsed .req r1
        sub elapsed,r0,start
        cmp elapsed,delay
        .unreq elapsed
        bls loop$

    /* Return */
    .unreq delay
    .unreq start
    pop {pc}

