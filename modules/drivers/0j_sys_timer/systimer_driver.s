/*
First take inputs for the timer values which go into C0,1,2,3 register
Then check for timer matches in a loop




 */


 .org 0x24, 0x00
 D_SYSTIMER_BASE_ADDRESS: .word 0x3F003000


/*
reserved addresses for timers and stuff
 */
D_SYSTIMER_TIMER_0: .word 0x00000000
D_SYSTIMER_TIMER_1: .word 0x00000000
D_SYSTIMER_TIMER_2: .word 0x00000000
D_SYSTIMER_TIMER_3: .word 0x00000000
D_SYSTIMER_QTIMER_0: .word 0x00000000
D_SYSTIMER_QTIMER_1: .word 0x00000000
D_SYSTIMER_QTIMER_2: .word 0x00000000
D_SYSTIMER_QTIMER_3: .word 0x00000000
D_SYSTIMER_STORAGE: .word 0x00000000


/*
r0 = 0 for ORR purposes if 1 macro is done
r1 is current checked timer value, then the orr'd value of it with r0
r2 is address of timer we will set
r9 is output of open timer address
 */
.macro CHECK_TIMER_STORAGE
mov r0, #0x0
mov r1, #0x0
mov r2, #0x0
ldr r1, D_SYSTIMER_TIMER_0
orr r1, r1, r0
cmp r1, #0x0
ldreq r2, =D_SYSTIMER_TIMER_0
moveq r0, #0x1

mov r1, #0x0
ldr r1, D_SYSTIMER_TIMER_1
orr r1, r1, r0
cmp r1, #0x0
ldreq r2, =D_SYSTIMER_TIMER_1
moveq r0, #0x1

mov r1, #0x0
ldr r1, D_SYSTIMER_TIMER_2
orr r1, r1, r0
cmp r1, #0x0
ldreq r2, =D_SYSTIMER_TIMER_2
moveq r0, #0x1

mov r1, #0x0
ldr r1, D_SYSTIMER_TIMER_3
orr r1, r1, r0
cmp r1, #0x0
ldreq r2, =D_SYSTIMER_TIMER_3
moveq r0, #0x1

mov r1, #0x0
ldr r1, D_SYSTIMER_QTIMER_0
orr r1, r1, r0
cmp r1, #0x0
ldreq r2, =D_SYSTIMER_QTIMER_0
moveq r0, #0x1

mov r1, #0x0
str r1, D_SYSTIMER_QTIMER_1
orr r1, r1, r0
cmp r1, #0x0
ldreq r2, =D_SYSTIMER_QTIMER_1
moveq r0, #0x1

mov r1, #0x0
ldr r1, D_SYSTIMER_QTIMER_2
orr r1, r1, r0
cmp r1, #0x0
ldreq r2, =D_SYSTIMER_QTIMER_2
moveq r0, #0x1

mov r1, #0x0
ldr r1, D_SYSTIMER_QTIMER_3
orr r1, r1, r0
cmp r1, #0x0
ldreq r2, =D_SYSTIMER_QTIMER_3
moveq r0, #0x1

mov r9, #0x0
cmp r2, #0x0
movne r9, r2
moveq r9, #0x0
/* SET SOMETHING IN STORAGE FOR ERROR AND ADJUST HERE */

.endm

/*
loads value into timer
loads r8 into r9
 */
.macro PREP_TIMER
cmp r9, #0x0
beq STOP_PREP
strne r9, r8
STOP_PREP:
.endm

/*
pushes our stored timers to cpu timers
stores QTIMERS in TIMERS
Clears QTIMERS
offset is 0xc, 0x10, 0x14, 0x18 for timers 0-3 respectively
 */
.macro PUSH_TMR_CPU
str D_SYSTIMER_TIMER_0, [D_SYSTIMER_BASE_ADDRESS, #0xc]
str D_SYSTIMER_TIMER_1, [D_SYSTIMER_BASE_ADDRESS, #0x10]
str D_SYSTIMER_TIMER_2, [D_SYSTIMER_BASE_ADDRESS, #0x14]
str D_SYSTIMER_TIMER_3, [D_SYSTIMER_BASE_ADDRESS, #0x18]

str D_SYSTIMER_QTIMER_0, D_SYSTIMER_TIMER_0
str D_SYSTIMER_QTIMER_1, D_SYSTIMER_TIMER_1
str D_SYSTIMER_QTIMER_2, D_SYSTIMER_TIMER_2
str D_SYSTIMER_QTIMER_3, D_SYSTIMER_TIMER_3

str #0x0, D_SYSTIMER_QTIMER_0
str #0x0, D_SYSTIMER_QTIMER_1
str #0x0, D_SYSTIMER_QTIMER_2
str #0x0, D_SYSTIMER_QTIMER_3
.endm

/*
Input r4-7 - sys timer value 32 bits
Sets timer, if not full.
Will not set a timer if address (r9) is invalid

*/
 D_PREPARE_TIMERS:
    mov r8, #0x0
    mov r8, r4
    CHECK_TIMER_STORAGE
    PREP_TIMER
    mov r8, r5
    CHECK_TIMER_STORAGE
    PREP_TIMER
    mov r8, r6
    CHECK_TIMER_STORAGE
    PREP_TIMER
    mov r8, r7
    CHECK_TIMER_STORAGE
    PREP_TIMER

    PUSH_TMR_CPU
    

    

    

    