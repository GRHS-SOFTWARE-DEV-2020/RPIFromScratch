
/*
    ARMTIMER DRIVER     v0.0.3
        api for the ARM Timer peripheral (on board the chip)
    
    API FUNCTIONS (subroutine address = addressStoredAt[(driver_start + subroutine_offset)]): R1 IS NOT GUARENTEED TO MAINTAIN ORIGINAL VALUE!

        (+0x00) D_ARMTIMER_is_timer_running         () : (r7[!0=true;0=false])   
        (+0x04) D_ARMTIMER_get_timer                () : (r7[value32])
        (+0x08) D_ARMTIMER_set_timer                (r7[value32]) : ()
        (+0x0C) D_ARMTIMER_set_timer_reload         (r7[value32]) : ()
        (+0x10) D_ARMTIMER_start_timer              () : ()
        (+0x14) D_ARMTIMER_stop_timer               () : ()
        (+0x18) D_ARMTIMER_set_timer_prescale       (r7[value10]) : ()
        (+0x1C) D_ARMTIMER_is_freecount_running     () : (r7[!0=true;0=false]) 
        (+0x20) D_ARMTIMER_get_freecount            () : (r7[value32])
        (+0x24) D_ARMTIMER_start_freecount          () : ()
        (+0x28) D_ARMTIMER_stop_freecount           () : ()
        (+0x2C) D_ARMTIMER_set_freecount_prescale   (r7[value8]) : ()
        (+0x30) D_ARMTIMER_enable_interrupt         () : ()
        (+0x34) D_ARMTIMER_disable_interrupt        () : ()
 */

// API Jump Table
.org 0x0
D_ARMTIMER_API_JUMPTABLE:
    b D_ARMTIMER_is_timer_running
    b D_ARMTIMER_get_timer
    b D_ARMTIMER_set_timer
    b D_ARMTIMER_set_timer_reload
    b D_ARMTIMER_start_timer
    b D_ARMTIMER_stop_timer
    b D_ARMTIMER_set_timer_prescale

    b D_ARMTIMER_is_freecount_running
    b D_ARMTIMER_get_freecount
    b D_ARMTIMER_start_freecount
    b D_ARMTIMER_stop_freecount
    b D_ARMTIMER_set_freecount_prescale

    b D_ARMTIMER_enable_interrupt
    b D_ARMTIMER_disable_interrupt


/*
    Macros used to define the actual functions. These are included on compile time based on the compile configurations listed above
    Multiple versions of the same subroutien can be implemented this way with the above .if block deciding which subroutine defintions 
    to use when compiling. I'm quite proud of this as this type of behavior is what you use C for, but I can do it here and much faster, 
    albiet at the cost of additional time spent writing device drivers. Macros can be reused 100% between different systems. That is why
    I choose this style of cross-platform compilation.
 */

.macro _D_ARMTIMER_is_timer_running_1_
D_ARMTIMER_is_timer_running:   
    ldr r0, =0x3F00B000     
    ldr r7, [r0, #0x408]
    and r7, r7, #0x80
    mov pc, lr
.endm

.macro _D_ARMTIMER_get_timer_1_
D_ARMTIMER_get_timer:   
    ldr r0, =0x3F00B000     
    ldr r7, [r0, #0x404]
    mov pc, lr
.endm

.macro _D_ARMTIMER_set_timer_1_
D_ARMTIMER_set_timer:
    ldr r0, =0x3F00B000
    str r7, [r0, #400]
    mov pc, lr
.endm

.macro _D_ARMTIMER_set_timer_reload_1_
D_ARMTIMER_set_timer_reload:
    ldr r0, =0x3F00B000
    str r7, [r0, #0x418]
    mov pc, lr
.endm

.macro _D_ARMTIMER_set_timer_prescale_1_
D_ARMTIMER_set_timer_prescale:
    ldr r0, =0x3F00B000
    mov r1, #0x3FF
    and r7, r7, r1
    str r7, [r0, #0x41C]
    mov pc, lr
.endm

.macro _D_ARMTIMER_start_timer_1_
D_ARMTIMER_start_timer:
    ldr r0, =0x3F00B000
    ldr r1, [r0, #0x408]
    orr r1, r1, #0x80
    str r1, [r0, #0x408]
    mov pc, lr
.endm

.macro _D_ARMTIMER_stop_timer_1_
D_ARMTIMER_stop_timer:
    ldr r0, =0x3F00B000
    ldr r1, [r0, #0x408]
    bic r1, r1, #0x80
    str r1, [r0, #0x408]
    mov pc, lr
.endm

.macro _D_ARMTIMER_is_freecount_running_1_
D_ARMTIMER_is_freecount_running:
    ldr r0, =0x3F00B000
    ldr r7, [r0, #0x408]
    and r7, r7, #0x200
    mov pc, lr
.endm

.macro _D_ARMTIMER_get_freecount_1_
D_ARMTIMER_get_freecount:
    ldr r0, =0x3F00B000
    ldr r7, [r0, #0x420]
    mov pc, lr
.endm

.macro _D_ARMTIMER_start_freecount_1_
D_ARMTIMER_start_freecount:
    ldr r0, =0x3F00B000
    ldr r1, [r0, #0x408]
    orr r1, r1, #0x200
    str r1, [r0, #0x408]
    mov pc, lr
.endm

.macro _D_ARMTIMER_stop_freecount_1_
D_ARMTIMER_stop_freecount:
    ldr r0, =0x3F00B000
    ldr r1, [r0, #0x408]
    bic r1, r1, #0x200
    str r1, [r0, #0x408]
    mov pc, lr
.endm

.macro _D_ARMTIMER_set_freecount_prescale_1_
D_ARMTIMER_set_freecount_prescale:
    ldr r0, =0x3F00B000
    and r7, r7, #0xFF
    lsl r7, r7, #16
    ldr r1, [r0, #0x408]
    orr r7, r7, r1
    str r7, [r0, #0x408]
    mov pc, lr
.endm

.macro _D_ARMTIMER_enable_interrupt_1_
D_ARMTIMER_enable_interrupt:
    ldr r0, =0x3F00B000
    ldr r1, [r0, #0x408]
    orr r1, r1, #0x20
    str r1, [r0, #0x408]
    mov pc, lr
.endm

.macro _D_ARMTIMER_disable_interrupt_1_
D_ARMTIMER_disable_interrupt:
    ldr r0, =0x3F00B000
    ldr r1, [r0, #0x408]
    bic r1, r1, #0x20
    str r1, [r0, #0x408]
    mov pc, lr
.endm
