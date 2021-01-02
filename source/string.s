/* 
* Get the length of the null-terminated string at location r0 
*/
.globl StringLength
StringLength:
    addr .req r0
    len .req r1
    char .req r2
    mov len,#0

    lengthLoop$:
        /* While char != '\0' */
        ldrb char,[addr]
        teq char,#0
        beq lengthLoopEnd$

        /* Increment length and address */
        add len,#1
        add addr,#1
        b lengthLoop$
    
    lengthLoopEnd$:
    mov r0,len
    mov pc,lr

    .unreq addr
    .unreq len
    .unreq char

/* 
* Reverse the null-terminated string at location r0 (in place)
*/
.globl ReverseString
ReverseString:
    addr .req r2
    mov addr,r0

    start .req r1
    end .req r0

    push {lr}
    bl StringLength

    /* Start = addr */
    mov start,addr

    /* End = addr + length - 1 */
    add end,addr
    sub end,#1

    .unreq addr
    temp1 .req r2
    temp2 .req r3

    reverseLoop$:
    /* While start < end */
        cmp end,start
        bge reverseLoopEnd$

        /* Swap chars */
        ldrb temp1,[start]
        ldrb temp2,[end]

        strb temp1,[end]
        strb temp2,[start]

        /* Update pointers */
        add start,#1
        sub end,#1
        b reverseLoop$

    reverseLoopEnd$:
    pop {lr}
    
    .unreq start
    .unreq end
    .unreq temp1
    .unreq temp2

/*
* TODO: void StringCopy(src, addr) 
*/
