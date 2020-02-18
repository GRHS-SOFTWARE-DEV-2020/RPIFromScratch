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
D_SYSTIMER_QIMER_2: .word 0x00000000
D_SYSTIMER_QTIMER_3: .word 0x00000000
D_SYSTIMER_STORAGE: .word 0x00000000


/*
r0 = 0 for ORR purposes if 1 macro is done
r1 is current checked timer value, then the orr'd value of it with r0
r2 is address of timer we will set
r3 is r5 input timer value
r9 is output of open timer address
 */
.macro CHECK_TIMER_STORAGE
clr r0
clr r1
clr r2
clr r3
mov r3, r5
str r1, D_SYSTIMER_TIMER_0
orr r1, r1, r0
cmp r1, #0x0
streq r2, =D_SYSTIMER_TIMER_0
moveq r0, #0x1

clr r1
str r1, D_SYSTIMER_TIMER_1
orr r1, r1, r0
cmp r1, #0x0
streq r2, =D_SYSTIMER_TIMER_1
moveq r0, #0x1

clr r1
str r1, D_SYSTIMER_TIMER_2
orr r1, r1, r0
cmp r1, #0x0
streq r2, =D_SYSTIMER_TIMER_2
moveq r0, #0x1

clr r1
str r1, D_SYSTIMER_TIMER_3
orr r1, r1, r0
cmp r1, #0x0
streq r2, =D_SYSTIMER_TIMER_3
moveq r0, #0x1

clr r1
str r1, D_SYSTIMER_QTIMER_0
orr r1, r1, r0
cmp r1, #0x0
streq r2, =D_SYSTIMER_QTIMER_0
moveq r0, #0x1

clr r1
str r1, D_SYSTIMER_QTIMER_1
orr r1, r1, r0
cmp r1, #0x0
streq r2, =D_SYSTIMER_QTIMER_1
moveq r0, #0x1

clr r1
str r1, D_SYSTIMER_QTIMER_2
orr r1, r1, r0
cmp r1, #0x0
streq r2, =D_SYSTIMER_QTIMER_2
moveq r0, #0x1

clr r1
str r1, D_SYSTIMER_QTIMER_3
orr r1, r1, r0
cmp r1, #0x0
streq r2, =D_SYSTIMER_QTIMER_3
moveq r0, #0x1

clr r9
cmp r2, #0x0
movne r9, r2
/* SET SOMETHING IN STORAGE FOR ERROR AND ADJUST HERE */

.endm


/*
Input r4 - address for subroutine to run
Input r5 - sys timer value 32 bits
Sets timer, if not full.
Then checks for match
If match then jump to subroutine

 */
 D_ON_SYSTIMER_MATCH:
    
    

    