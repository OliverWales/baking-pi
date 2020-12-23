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
/*
* Font
*/
.align 4
font:
    .incbin "font.bin"

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

    drawPixels$:
        /* If x0 = x1 or y0 = y1 return */
        teq x0,x1
        teqne y0,y1
        popeq {r4,r5,r6,r7,r8,r9,r10,r11,r12,pc}

        /* Set pixel (x0, y0) */
        mov r0,x0
        mov r1,y0
        bl DrawPixel

        /* If 2*error <= -dy, er += (-dy), x0 += sx */
        cmp dy,er,lsl #1
        addle er,dy
        addle x0,sx

        /* If 2*error >= dx, er += dx, y0 += sy */
        cmp dx,er,lsl #1
        addge er,dx
        addge y0,sy

        b drawPixels$

	.unreq x0
	.unreq x1
	.unreq y0
	.unreq y1
	.unreq dx
	.unreq dy
	.unreq sx
	.unreq sy
	.unreq er

/*
* Draw character in r0 at position (r1, r2), return width and height drawn
*/
.globl DrawCharacter
DrawCharacter:
    /* Validate character */
    cmp r0,#127
    movhi r0,#0
    movhi r1,#0
    movhi pc,lr

    push {r4,r5,r6,r7,r8,lr}
    x .req r4
    y .req r5
    charAddr .req r6
    
    /* Copy position */
    mov x,r1
    mov y,r2

    /* Set char address to font + character << 4 */
    ldr charAddr,=font
    add charAddr, r0,lsl #4

    /* Loop over rows */
    rowLoop$:
        /* Get next byte of character */
        mask .req r7
        ldrb mask,[charAddr]

        /* Highest bit is leftmost pixel */
        col .req r8
        mov col,#8

        /* While col > 0 */
        columnLoop$:
            /* Decrement col */
            subs col,#1
            blt columnLoopEnd$

            /* Check mask */
            lsl mask,#1
            tst mask,#0x100

            /* If 0, continue */
            beq columnLoop$

            /* Else, draw pixel */
            add r0,x,col
            mov r1,y
            bl DrawPixel

            b columnLoop$

        columnLoopEnd$:
        .unreq col
        .unreq mask
        
        /* Increment y position */
        add y,#1

        /* Increment char address  */
        add charAddr,#1

        /* Check if more rows to draw */
        tst charAddr,#0b1111
        bne rowLoop$

    .unreq charAddr
    .unreq x
    .unreq y

    /* Return pixels drawn */
    mov r0,#8
    mov r1,#16
    pop {r4,r5,r6,r7,r8,pc}

/*
* Draw string at address in r0 at position (r1, r2), return final position of cursor
* NB: Assumes string is null-terminated
*/
.globl DrawString
DrawString:
    push {r4,r5,r6,r7,lr}
    charAddr .req r4
    x0 .req r5
    x .req r6
    y .req r7

    mov charAddr,r0
    mov x0,r1
    mov x,r1
    mov y,r2

    stringLoop$:
        /* Load next char */
        char .req r0
        ldrb char,[charAddr]
        add charAddr,#1

        /* Handle null terminator */
        teq char,#0
        beq stringLoopEnd$

        /* Handle line feed */
        teq char,#'\n'
        moveq x,x0
        addeq y,#16
        beq stringLoop$

        /* Handle tab */
        teq char,#'\t'
        tabs .req r0
        subeq tabs,x,x0	/* Get relative x position */
        lsreq tabs,#5   /* Divide by 32 (truncated) */
        addeq tabs,#1   /* Add 1 */
        lsleq tabs,#5   /* Multiply by 32 */
        addeq x,x0,tabs /* Update x position */
        .unreq tabs
        beq stringLoop$

        /* Draw character */
        mov r1,x
        mov r2,y
        bl DrawCharacter
        add x,r0

        .unreq char
        b stringLoop$

    stringLoopEnd$:

    /* Return width and height drawn */
    mov r0,x
    mov r1,y

    pop {r4,r5,r6,r7,pc}
    .unreq charAddr
    .unreq x0
    .unreq x
    .unreq y
