
/*
    GPIO DRIVER     v0.0.3
        api for GPIO managment
    
    API FUNCTIONS (subroutine address = addressStoredAt[(driver_start + subroutine_offset)]): R1 IS NOT GUARENTEED TO MAINTAIN ORIGINAL VALUE!

        D_GPIO_set_pin (r7[value6]) : ()
        D_GPIO_clear_pin (r7[value6]) : ()
        D_GPIO_get_pin_value (r7[value6]) : (r8[=0:LOW;>0:HIGH])


            EVENTS: Interrupts from pins are handled as shown below. R7 is the pin number, R8 is a bit mask. Bit controls shown below:
                0 - HIGH DETECT
                1 - LOW DETECT
                2 - RISING EDGE DETECT
                3 - FALLING EDGE DETECT
                4 - ASYNC RISING EDGE DETECT
                5 - ASYNC FALLING EDGE DETECT

        D_GPIO_enable_event_detect (r7[value6], r8[value6]) : ()
        D_GPIO_disable_event_detect (r7[value6], r8[value6]) : ()
        D_GPIO_pin_event_status (r7[value6], r8[value6]) : (r9[=0:LOW;>0:HIGH (bits correspond to bits in r8)])

        D_GPIO_get_event_status_masks (r7[event bit mask]) : (r7[0:15],r8[16:31],r9[32:47],r10[48:63])


        D_GPIO_get_pin_function (r7[value6]) : (r8[=0:LOW;>0:HIGH])
        D_GPIO_set_pin_function_input (r7[value6]) : ()
        D_GPIO_set_pin_function_output (r7[value6]) : ()
        D_GPIO_set_pin_function_0 (r7[value6]) : ()
        D_GPIO_set_pin_function_1 (r7[value6]) : ()
        D_GPIO_set_pin_function_2 (r7[value6]) : ()
        D_GPIO_set_pin_function_3 (r7[value6]) : ()
        D_GPIO_set_pin_function_4 (r7[value6]) : ()
        D_GPIO_set_pin_function_5 (r7[value6]) : ()

        D_GPIO_reserve_pin (r7[value6]) : ()
        D_GPIO_get_pin_status (r7[value6]) : (r8[=0:OPEN;>0=RESERVED])

 */

// API Subroutine Jump Table
.org 0x0
D_ARMTIMER_API_JUMPTABLE:

    b D_GPIO_set_pin
    b D_GPIO_clear_pin
    b D_GPIO_get_pin_value

    b D_GPIO_enable_event_detect
    b D_GPIO_disable_event_detect
    b D_GPIO_pin_event_status
    b D_GPIO_get_event_status_masks

    b D_GPIO_get_pin_function
    b D_GPIO_set_pin_function_input
    b D_GPIO_set_pin_function_output
    b D_GPIO_set_pin_function_0
    b D_GPIO_set_pin_function_1
    b D_GPIO_set_pin_function_2
    b D_GPIO_set_pin_function_3
    b D_GPIO_set_pin_function_4
    b D_GPIO_set_pin_function_5

    b D_GPIO_reserve_pin
    b D_GPIO_get_pin_status


/*
    API implementation options
 */

.macro _D_GPIO_set_pin_1_
D_GPIO_set_pin:
    ldr r0, =0x3F200000
    mov r1, #1
    and r7, r7, #0x3F
    lsl r1, r1, r7
    cmp r7, #31
    addpl r0, r0, #0x4
    str r1, [r0, #0x1C]
    mov pc, lr
.endm

.macro _D_GPIO_clear_pin_1_
D_GPIO_clear_pin:
    ldr r0, =0x3F200000
    mov r1, #1
    and r7, r7, #0x3F
    lsl r1, r1, r7
    cmp r7, #31
    addpl r0, r0, #0x4
    str r1, [r0, #0x28]
    mov pc, lr
.endm

.macro _D_GPIO_get_pin_value_1_
D_GPIO_get_pin_value:
    ldr r0, =0x3F200000
    mov r8, #0
    mov r1, #1
    and r7, r7, #0x3F
    lsl r1, r1, r7
    cmp r7, #31
    addpl r0, r0, #0x4
    ldr r2, [r0, #0x34]
    and r2, r2, r1
    cmp r2, #0
    moveq r8, #1
    mov pc, lr
.endm

/*
    EVENTS: Interrupts from pins are handled as shown below. R7 is the pin number, R8 is a bit mask. Bit controls shown below:
    R8:     b0 - HIGH DETECT
            b1 - LOW DETECT
            b2 - RISING EDGE DETECT
            b3 - FALLING EDGE DETECT
            b4 - ASYNC RISING EDGE DETECT
            b5 - ASYNC FALLING EDGE DETECT
 */

.macro _D_GPIO_enable_event_detect_1_
D_GPIO_enable_event_detect:

    ldr r0, =0x3F200000     // set address offset if this is an upper level pin
    mov r1, #1
    and r2, r7, #0x3F
    cmp r7, #31
    addpl r0, r0, #0x4
    subpl r2, r2, #32
    lsl r1, r1, r2

    ldr r3, [r0, #0x64]     // high detect
    orr r3, r1, r3   
    and r2, r8, #0x1     
    cmp r2, #0x0
    strne r3, [r0, #0x64]

    ldr r3, [r0, #0x70]     // low detect
    orr r3, r1, r3   
    and r2, r8, #0x2
    cmp r2, #0x0
    strne r3, [r0, #0x70]

    ldr r3, [r0, #0x4C]     // rising edge detect
    orr r3, r1, r3   
    and r2, r8, #0x4
    cmp r2, #0x0
    strne r3, [r0, #0x4C]

    ldr r3, [r0, #0x58]     // falling edge detect
    orr r3, r1, r3   
    and r2, r8, #0x8
    cmp r2, #0x0
    strne r3, [r0, #0x58]

    ldr r3, [r0, #0x7C]     // async rising edge detect
    orr r3, r1, r3   
    and r2, r8, #0x10
    cmp r2, #0x0
    strne r3, [r0, #0x7C]

    ldr r3, [r0, #0x80]     // async falling edge detect
    orr r3, r1, r3   
    and r2, r8, #0x20
    cmp r2, #0x0
    strne r3, [r0, #0x80]

    mov pc, lr
.endm

.macro _D_GPIO_disable_event_detect_1_
D_GPIO_disable_event_detect:

    ldr r0, =0x3F200000     // set address offset if this is an upper level pin
    mvn r1, #1
    and r2, r7, #0x3F
    cmp r7, #31
    addpl r0, r0, #0x4
    subpl r2, r2, #32
    lsl r1, r1, r2

    ldr r3, [r0, #0x64]     // high detect
    and r3, r1, r3   
    and r2, r8, #0x1     
    cmp r2, #0x0
    strne r3, [r0, #0x64]

    ldr r3, [r0, #0x70]     // low detect
    and r3, r1, r3   
    and r2, r8, #0x2
    cmp r2, #0x0
    strne r3, [r0, #0x70]

    ldr r3, [r0, #0x4C]     // rising edge detect
    and r3, r1, r3   
    and r2, r8, #0x4
    cmp r2, #0x0
    strne r3, [r0, #0x4C]

    ldr r3, [r0, #0x58]     // falling edge detect
    and r3, r1, r3   
    and r2, r8, #0x8
    cmp r2, #0x0
    strne r3, [r0, #0x58]

    ldr r3, [r0, #0x7C]     // async rising edge detect
    and r3, r1, r3   
    and r2, r8, #0x10
    cmp r2, #0x0
    strne r3, [r0, #0x7C]

    ldr r3, [r0, #0x80]     // async falling edge detect
    and r3, r1, r3   
    and r2, r8, #0x20
    cmp r2, #0x0
    strne r3, [r0, #0x80]

    mov pc, lr
.endm

.macro _D_GPIO_pin_event_status_1_
D_GPIO_pin_event_status:
    mov pc, lr
.endm

.macro _D_GPIO_get_event_status_masks_1_
D_GPIO_get_event_status_masks:
    mov pc, lr
.endm

.macro _D_GPIO_get_pin_function_1_
D_GPIO_get_pin_function:
    mov pc, lr
.endm

.macro _D_GPIO_set_pin_function_input_1_
D_GPIO_set_pin_function_input:
    mov pc, lr
.endm

.macro _D_GPIO_set_pin_function_output_1_
D_GPIO_set_pin_function_output:
    mov pc, lr
.endm

.macro _D_GPIO_set_pin_function_0_1_
D_GPIO_set_pin_function_0:
    mov pc, lr
.endm

.macro _D_GPIO_set_pin_function_1_1_
D_GPIO_set_pin_function_1:
    mov pc, lr
.endm

.macro _D_GPIO_set_pin_function_2_1_
D_GPIO_set_pin_function_2:
    mov pc, lr
.endm

.macro _D_GPIO_set_pin_function_3_1_
D_GPIO_set_pin_function_3:
    mov pc, lr
.endm

.macro _D_GPIO_set_pin_function_4_1_
D_GPIO_set_pin_function_4:
    mov pc, lr
.endm

.macro _D_GPIO_set_pin_function_5_1_
D_GPIO_set_pin_function_5:
    mov pc, lr
.endm

.macro _D_GPIO_reserve_pin_1_
D_GPIO_reserve_pin:
    mov pc, lr
.endm

.macro _D_GPIO_get_pin_status_1_
D_GPIO_get_pin_status:
    mov pc, lr
.endm
