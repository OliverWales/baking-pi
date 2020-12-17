.section .init
.globl _start
_start:

/* 
* Address of GPIO region
*/
ldr r0,=0x20200000

/* 
* Set bits 18-20 of r1 to 001
*/
mov r1,#1
lsl r1,#18

/* 
* Set the GPIO function select
*/
str r1,[r0,#4]

/* 
* Set the 16th bit of r1
*/
mov r1,#1
lsl r1,#16

/* 
* Set GPIO 16 to low
*/
str r1,[r0,#40]

/*
* Loop forever
*/
loop$:
b loop$
