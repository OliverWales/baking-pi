.section .data
/*
* Template request to the graphics processor for a frame buffer
*/
.align 4
.globl FrameBufferInfo
FrameBufferInfo:
    .int 1024   /* #00 Physical Width */
    .int 768    /* #04 Physical Height */
    .int 1024   /* #08 Virtual Width */
    .int 768    /* #12 Virtual Height */
    .int 0      /* #16 GPU - Pitch (bytes per row) */
    .int 16     /* #20 Bit Depth */
    .int 0      /* #24 X offset */
    .int 0      /* #28 Y offset */
    .int 0      /* #32 GPU - Pointer to frame buffer */
    .int 0      /* #36 GPU - Size of frame buffer */

.section .text
/*
* Initialise a frame buffer of the given width, height and colour depth
*/
.globl InitialiseFrameBuffer
InitialiseFrameBuffer:
    /* Check that arguements are in range */
    width .req r0
    height .req r1
    bitDepth .req r2
    cmp width,#4096
    cmpls height,#4096
    cmpls bitDepth,#32

    /* Return 0 if any out of range */
    result .req r0
    movhi result,#0
    movhi pc,lr

    /* Write arguments to frame buffer info */
    frameBufferInfoAddr .req r4
    ldr frameBufferInfoAddr,=FrameBufferInfo
    str width,[frameBufferInfoAddr,#0]
    str height,[frameBufferInfoAddr,#4]
    str width,[frameBufferInfoAddr,#8]
    str height,[frameBufferInfoAddr,#12]
    str bitDepth,[frameBufferInfoAddr,#20]
    .unreq width
    .unreq height
    .unreq bitDepth

    /* Write address of frame buffer info to channel 1 */
    mov r0,frameBufferInfoAddr
    add r0,#0x40000000 /* add 0x40000000 to instruct GPU to flush cache */
    mov r1,#1
    push {r4,lr}
    bl MailboxWrite

    /* Read channel 1 */
    mov r0,#1
    bl MailboxRead

    /* Return 0 if did not succeed */
    teq result,#0
    movne result,#0
    popne {r4,pc}

    /* Return the frame buffer info address*/
    mov result,frameBufferInfoAddr
    pop {r4,pc}
    .unreq result
    .unreq frameBufferInfoAddr
