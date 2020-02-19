/*
cannon pierce
 */

 .org 0x2c, 0x00
 D_SYSTIMER_BASE_ADDRESS: .word 0x3F003000

 /*
 jump table
 API 0 - Input r4-7 - sys timer value 32 bits
Set to zero if not wanted
Sets timer, if not full.
Will not set a timer if address (r9) is invalid
API 1 - input r4 (address of subroutine) - What to run if timer n is matched
input r5 timer number (0,1,2,3), will be set to r0 for working with
store lr, just before branch, into allocated memory slot above
r2 used for left shifting to get to bit number, then contains true/false based on = or not = to zero
r3 used to store number for left shifting
r8 output if it worked - 1
  */
 D_SYSTIMER_API_0: .word D_START_TIMERS
 D_SYSTIMER_API_1: .word D_CHECK_TIMERS


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
D_SYSTIMER_FLAGS: .word 0x00000000
D_SYSTIMER_STORE_LR: .word 0x00000000

/*
D_SYSTIMER_FLAGS
bit 0      1 = full storage  0 - not full dont worry
bit 1      1 = Input not in range 0 = in range dont worry


 */


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
/* update error flahs */
ldreq r0, D_SYSTIMER_FLAGS
orreq r0, r0, #0x1
streq r0, D_SYSTIMER_FLAGS

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
Set to zero if not wanted
Sets timer, if not full.
Will not set a timer if address (r9) is invalid

*/
 D_START_TIMERS:
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
    

    mov pc, ldr



/*
input r4 (address of subroutine) - What to run if timer n is matched
input r5 timer number (0,1,2,3), will be set to r0 for working with
store lr, just before branch, into allocated memory slot above
r2 used for left shifting to get to bit number, then contains true/false based on = or not = to zero
r3 used to store number for left shifting
r8 output if it worked - 1
 */

D_CHECK_TIMERS:
   mov r0, r5
   cmp r0, #0x4
   /*updates the error flags, sets bit 1 to 1 */
   ldrpl r0, D_SYSTIMER_FLAGS
   orrpl r0, r0, #0x2
   strpl r0, D_SYSTIMER_FLAGS
   
   movpl pc, lr

   


   mul r3, r0, #0x1
   mov r2, #0x1
   lsl r2, r2, r3

   /*grab match register (base address) */
   ldr r3, D_SYSTIMER_BASE_ADDRESS

   /* and r3 with r2 to find if matched */
   and r3, r3, r2
   cmp r3, #0x0

   /* if equal then set lr and branch to subroutine */
   streq D_SYSTIMER_STORE_LR, lr
   beq r4
   streq lr, D_SYSTIMER_STORE_LR

   /*sets output to one so it can be checked if it worked */
   mov r8, #0x1


   mov pc, lr

    

    

    