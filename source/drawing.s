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
.globl DrawPixel
DrawPixel:
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

/*
* Draw a line from (x0,y0) to (x1,y1)
*/
.globl DrawLine
DrawLine:
    /* Push old register values to stack */
    push {r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}

    x0 .req r4
    y0 .req r5
    x1 .req r6
    y1 .req r7

    mov x0,r0
    mov y0,r1
    mov x1,r2
    mov y1,r3

    dx .req r8
    dy .req r9
    sx .req r10
    sy .req r11
    er .req r12

    /* If x1 > x0, set dx to x0 - x1 and sx to -1*/
    cmp x0,x1
    subgt dx,x0,x1
    movgt sx,#-1

    /* Else, set dx to x1 - x0 and sx to 1 */
    suble dx,x1,x0
    movle sx,#1

    /* If y1 > y0, set -dy to y1 - y0 and sy to -1*/
    cmp y0,y1
    subgt dy,y1,y0
    movgt sy,#-1

    /* Else, set -dy to y0 - y1 and sy to 1 */
    suble dy,y0,y1
    movle sy,#1

    /* 	Set e to dx + (-dy) */
    add er,dx,dy

    add x1,sx
    add y1,sy

    drawPixels:
        /* If x0 = x1 or y0 = y1 return */
        teq x0,x1
        teqne y0,y1
        popeq {r4,r5,r6,r7,r8,r9,r10,r11,r12,pc}

        /* Set pixel (x0, y0) */
        mov r0,x0
        mov r1,y0
        bl DrawPixel

        /* If 2*error >= -dy, x0 += sx, er += (-dy) */
        cmp dy,er,lsl #1
        addge er,dy
        addge x0,sx

        /* If 2*error <= dx, y0 += sy, er += dx */
        cmp dx,er,lsl #1
        addle er,dx
        addle y0,sy

        b drawPixels

	.unreq x0
	.unreq x1
	.unreq y0
	.unreq y1
	.unreq dx
	.unreq dy
	.unreq sx
	.unreq sy
	.unreq er
