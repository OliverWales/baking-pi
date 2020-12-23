.section .data
tag_core: .int 0
tag_mem: .int 0
tag_videotext: .int 0
tag_ramdisk: .int 0
tag_initrd2: .int 0
tag_serial: .int 0
tag_revision: .int 0
tag_videolfb: .int 0
tag_cmdline: .int 0

/*
* Returns address of tag in r0
*/
.globl FindTag
FindTag:
    tag .req r0

    /* Check tag in range 1-8 */
    sub tag,#1
    cmp tag,#8
    movhi tag,#0
    movhi pc,lr

    tagList .req r1
    tagAddr .req r2

    /* Tag list starts at core tag */
    ldr tagList,=tag_core
    tagReturn$:

    /* Remaining tags are stored 0x100 apart from this address */
    add tagAddr,tagList, tag,lsl #2
    ldr tagAddr,[tagAddr]

    /* Return tag address if found */
    teq tagAddr,#0
    movne r0,tagAddr
    movne pc,lr

    /* If no core tag return 0 */
    ldr tagAddr,[tagList]
    teq tagAddr,#0
    movne r0,#0
    movne pc,lr

    /* Set tagAddr to 0x100 */
    mov tagAddr,#0x100

    push {r4}
    tagIndex .req r3
    oldAddr .req r4

    tagLoop$:
        /* tagIndex = [tagAddr + 4] */
        ldrh tagIndex,[tagAddr,#4]

        /* Decrement tag and jump if <0 */
        subs tagIndex,#1
        poplt {r4}
        blt tagReturn$

        /* tagIndex = tagList + tagIndex * 4 */
        add tagIndex,tagList, tagIndex,lsl #2
        ldr oldAddr,[tagIndex]

        /* If zero, store */
        teq oldAddr,#0
        .unreq oldAddr
        streq tagAddr,[tagIndex]

        ldr tagIndex,[tagAddr]

        /* tagAddr += tagIndex * 4 */
        add tagAddr, tagIndex,lsl #2
    b tagLoop$

    .unreq tag
    .unreq tagList
    .unreq tagAddr
    .unreq tagIndex
