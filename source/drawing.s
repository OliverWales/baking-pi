.section .data
.align 1
/* 
* Current foreground colour
*/
foregroundColour:
    .hword 0xFFFF

.align 2
/*
* Current framebuffer info address
*/
graphicsAddress:
    .int 0

.section .text
/*
* Set foreground colour
*/
.globl SetForegroundColour
SetForegroundColour:
    cmp r0,#0x10000
    movhs pc,lr
    ldr r1,=foregroundColour
    strh r0,[r1]
    mov pc,lr

/*
* Set address of framebuffer info
*/
.globl SetGraphicsAddress
SetGraphicsAddress:
    ldr r1,=graphicsAddress
    str r0,[r1]
    mov pc,lr

/*
* Set pixel at given (px, py) in current framebuffer to current foreground colour
*/
.globl SetPixel
SetPixel:
    px .req r0
    py .req r1
    addr .req r2
    ldr addr,=graphicsAddress
    ldr addr,[addr]

    /* Validate py */
    height .req r3
    ldr height,[addr,#4]
    sub height,#1
    cmp py,height
    movhi pc,lr
    .unreq height

    /* Validate px */
    width .req r3
    ldr width,[addr,#0]
    sub width,#1
    cmp px,width
    movhi pc,lr
    add width,#1

    /* Get framebuffer */
    ldr addr,[addr,#32]

    /* Get pixel position in frame buffer */
    mla px,py,width,px /* px = (py * width) + px */
    .unreq width
    .unreq py

    /* Get address of pixel */
    add addr, px,lsl #1 /* Hardcoded bit depth */
    .unreq px

    /* Get foreground colour */
    fore .req r3
    ldr fore,=foregroundColour
    ldrh fore,[fore]

    /* Set pixel and return */
    strh fore,[addr]
    .unreq fore
    .unreq addr
    mov pc,lr
