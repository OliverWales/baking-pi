/*
* GetMailboxBase returns the base address of the mailbox as a physical address
* in register r0
*/
.globl GetMailboxBase
GetMailboxBase:
    ldr r0,=0x2000B880
    mov pc,lr

/*
* MailboxWrite writes the value given in the top 28 bits of r0 to the channel
* given in the low 4 bits of r1
*/
.globl MailboxWrite
MailboxWrite:
    /* Check that lower 4 bits of value are 0 */
    tst r0,#0b1111
    movne pc,lr

    /* Check that channel is less than or equal to 15 */
    cmp r1,#15
    movhi pc,lr

    channel .req r1
    value .req r2
    mov value,r0
    push {lr}

    /* Get mailbox base address */
    bl GetMailboxBase
    mailbox .req r0

    /* Combine value with channel */
    add value,channel
    .unreq channel

    /* Wait for top bit of status to be 0 */
    wait1$:
        status .req r3
        ldr status,[mailbox,#0x18]
        tst status,#0x80000000
        .unreq status
        bne wait1$

    /* Write value to mailbox and return */
    str value,[mailbox,#0x20]
    .unreq value
    .unreq mailbox
    pop {pc}

/*
* MailboxRead returns the current value in the mailbox addressed to a channel
* given in the low 4 bits of r0, as the top 28 bits of r0
*/
.globl MailboxRead
MailboxRead:
    /* Check that channel is less than or equal to 15 */
    cmp r0,#15
    movhi pc,lr

    /* Move channel to r1 and put mailbox base in r0 */
    channel .req r1
    mov channel,r0
    push {lr}
    bl GetMailboxBase
    mailbox .req r0

    /* Wait for 30th bit of status to be 0 */
    wait2$:
        status .req r2
        ldr status,[mailbox,#0x18]
        tst status,#0x40000000
        .unreq status
        bne wait2$

    /* Read next item from mailbox */
    mail .req r2
    ldr mail,[mailbox,#0]

    /* Check if it was for the channel that we are interested in */
    inchannel .req r3
    and inchannel,mail,#0b1111
    teq inchannel,channel
    .unreq inchannel
    bne wait2$
    .unreq mailbox
    .unreq channel

    /* If so, remove the channel and return the value */
    and r0,mail,#0xfffffff0
    .unreq mail
    pop {pc}
