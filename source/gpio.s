/*
* GetGpioBase returns the base address of the GPIO region as a physical address
* in register r0
*/
.globl GetGpioBase
GetGpioBase:
    ldr r0,=0x20200000
    mov pc,lr

/*
* SetGpioFunction sets the function of the GPIO register addressed by r0 to the
* low  3 bits of r1
*/
.globl SetGpioFunction
SetGpioFunction:
    pinNum .req r0
    pinFunc .req r1

    /* If pinNum or pinFunc out of range return */
    cmp pinNum,#53
    cmpls pinFunc,#7
    movhi pc,lr

    /* Push lr to stack, move pinNum to r2 and call GetGpioBase */
    push {lr}
    mov r2,pinNum
    .unreq pinNum
	pinNum .req r2
    bl GetGpioBase
    gpioAddr .req r0

    /* Pin function address = gpioAddress + 4 × (Pin Number ÷ 10) */
    functionLoop$:
        cmp pinNum,#9
        subhi pinNum,#10
        addhi gpioAddr,#4
        bhi functionLoop$

    /* Triple pinNum and shift pinFunc to this index */
    add pinNum, pinNum,lsl #1
	lsl pinFunc,pinNum

    /* Get mask of bits to modify */
    mask .req r3
    mov mask,#7
    lsl mask,pinNum
    .unreq pinNum
    mvn mask,mask

    /* Get previous function pins and mask out the bits to modify */
    oldFunc .req r2
    ldr oldFunc,[gpioAddr]
    and oldFunc,mask
    .unreq mask

    /* OR this value with the new pin function */
    orr pinFunc,oldFunc
    .unreq oldFunc  

    /* Set the Gpio function to the new value */
    str pinFunc,[gpioAddr]
	.unreq pinFunc
	.unreq gpioAddr

    /* Return lr to pc */
    pop {pc}

/*
* SetGpio sets the GPIO pin addressed by register r0 high if r1 != 0 and low
* otherwise
*/
.globl SetGpio
SetGpio:
    pinNum .req r0
    pinVal .req r1

    /* If pinNum out of range return */
    cmp pinNum,#53
    movhi pc,lr

    /* Push lr to stack, move pinNum to r2 and call GetGpioAddress */
    push {lr}
    mov r2,pinNum
    .unreq pinNum
    pinNum .req r2
    bl GetGpioAddress
    gpioAddr .req r0

    /* pinBank = gpioAddr + (pinNum / 32) * 4 */
    pinBank .req r3
    lsr pinBank,pinNum,#5
    lsl pinBank,#2
    add gpioAddr,pinBank
    .unreq pinBank

    /* Get the bit corresponding to this pin */
    and pinNum,#31
    setBit .req r3
    mov setBit,#1
    lsl setBit,pinNum
    .unreq pinNum

    /* Set the pin according to pinVal */
    teq pinVal,#0
    .unreq pinVal
    streq setBit,[gpioAddr,#40]
    strne setBit,[gpioAddr,#28]
    .unreq setBit
    .unreq gpioAddr
    pop {pc}

