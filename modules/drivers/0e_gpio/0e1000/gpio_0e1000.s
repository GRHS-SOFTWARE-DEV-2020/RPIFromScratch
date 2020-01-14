/*
    GPIO DRIVER 0e1000    v0.0.3
        api for GPIO managment
    
    API FUNCTIONS (subroutine address = addressStoredAt[(driver_start + subroutine_offset)]):

        D_GPIO_set_pin (r5[value6]) : ()
        D_GPIO_clear_pin (r5[value6]) : ()
        D_GPIO_get_pin_value (r5[value6]) : (r8[=0:LOW;>0:HIGH])


            EVENTS: Interrupts from pins are handled as shown below. R5 is the pin number, R6 is a bit mask. Bit controls shown below:
                0 - HIGH DETECT
                1 - LOW DETECT
                2 - RISING EDGE DETECT
                3 - FALLING EDGE DETECT
                4 - ASYNC RISING EDGE DETECT
                5 - ASYNC FALLING EDGE DETECT

        D_GPIO_enable_event_detect (r5[value6], r6[value6]) : ()
        D_GPIO_disable_event_detect (r5[value6], r6[value6]) : ()
        D_GPIO_pin_event_status (r5[value6], r6[value6]) : (r8[=0:LOW;>0:HIGH (bits correspond to bits in r8)])

        D_GPIO_get_event_status_masks (r5[event bit mask]) : (r8[0:31],r9[32:65])


        D_GPIO_get_pin_function (r5[value6]) : (r8[=0:LOW;>0:HIGH])
        D_GPIO_set_pin_function_input (r5[value6]) : ()
        D_GPIO_set_pin_function_output (r5[value6]) : ()
        D_GPIO_set_pin_function_0 (r5[value6]) : ()
        D_GPIO_set_pin_function_1 (r5[value6]) : ()
        D_GPIO_set_pin_function_2 (r5[value6]) : ()
        D_GPIO_set_pin_function_3 (r5[value6]) : ()
        D_GPIO_set_pin_function_4 (r5[value6]) : ()
        D_GPIO_set_pin_function_5 (r5[value6]) : ()

        D_GPIO_reserve_pin (r5[value6]) : (r8[=0:FAIL;>0=PASS])

 */

// API Subroutine Jump Table
.org 0x0
D_GPIO_ID:  .word 0x000e1000
D_GPIO_END: .word D_GPIO_END
D_GPIO_BASE_ADDRESS: .word 0x00000000

D_GPIO_API_0: .word D_GPIO_set_pin
D_GPIO_API_1: .word D_GPIO_clear_pin

D_GPIO_API_2: .word D_GPIO_enable_event_detect
D_GPIO_API_3: .word D_GPIO_disable_event_detect
D_GPIO_API_4: .word D_GPIO_pin_event_status
D_GPIO_API_5: .word D_GPIO_get_event_status_masks

D_GPIO_API_6: .word D_GPIO_get_pin_function
D_GPIO_API_7: .word D_GPIO_set_pin_function_input
D_GPIO_API_8: .word D_GPIO_set_pin_function_output
D_GPIO_API_9: .word D_GPIO_set_pin_function_0
D_GPIO_API_10: .word D_GPIO_set_pin_function_1
D_GPIO_API_11: .word D_GPIO_set_pin_function_2
D_GPIO_API_12: .word D_GPIO_set_pin_function_3
D_GPIO_API_13: .word D_GPIO_set_pin_function_4
D_GPIO_API_14: .word D_GPIO_set_pin_function_5

D_GPIO_API_15: .word D_GPIO_reserve_pin


/*
    DWORD reserved for tracking which pins are currently 'checked out'
 */

D_GPIO_RESERVED_LOWER: .word 0x00000000
D_GPIO_RESERVED_UPPER: .word 0x00000000

/*
    API implementation options (if any)
*/

/*     
    D_GPIO_set_pin - 
    INPUTS:
    OUTPUTS:
 */
D_GPIO_set_pin:

    ldr r0, D_GPIO_BASE_ADDRESS

    and r2, r5, #0x3F       // adjust if needed + make pin mask
    cmp r2, #32
    subpl r2, r2, #32
    addpl r0, r0, #0x4   
    mov r1, #1
    lsl r1, r1, r2
    
    str r1, [r0, #0x1C]
    mov pc, lr

/*     
    D_GPIO_clear_pin - 
    INPUTS:
    OUTPUTS:
 */
D_GPIO_clear_pin:

    ldr r0, =0x3F200000
    mov r1, #1

    and r2, r5, #0x3F
    cmp r2, #32
    subpl r2, r2, #32
    addpl r0, r0, #0x4
    lsl r1, r1, r2

    str r1, [r0, #0x28]
    mov pc, lr

/*     
    D_GPIO_get_pin_value - 
    INPUTS:
    OUTPUTS:
 */
D_GPIO_get_pin_value:

    ldr r0, =0x3F200000
    mov r1, #1

    and r2, r5, #0x3F
    cmp r2, #32
    subpl r2, r2, #32
    addpl r0, r0, #0x4
    lsl r1, r1, r2

    ldr r2, [r0, #0x34]
    and r8, r2, r1
    mov pc, lr

/*
    EVENTS: Interrupts from pins are handled as shown below. R7 is the pin number, R8 is a bit mask. Bit controls shown below:
    R8:     b0 - HIGH DETECT
            b1 - LOW DETECT
            b2 - RISING EDGE DETECT
            b3 - FALLING EDGE DETECT
            b4 - ASYNC RISING EDGE DETECT
            b5 - ASYNC FALLING EDGE DETECT
 */

/*     
    D_GPIO_enable_event_detect - 
    INPUTS:
    OUTPUTS:
 */
D_GPIO_enable_event_detect:

    ldr r0, =0x3F200000     // set address offset if this is an upper level pin
    mov r1, #1
    and r2, r5, #0x3F
    cmp r2, #32
    addpl r0, r0, #0x4
    subpl r2, r2, #32
    lsl r1, r1, r2

    ldr r3, [r0, #0x64]     // high detect
    orr r3, r1, r3   
    and r2, r6, #0x1     
    cmp r2, #0x0
    strne r3, [r0, #0x64]

    ldr r3, [r0, #0x70]     // low detect
    orr r3, r1, r3   
    and r2, r6, #0x2
    cmp r2, #0x0
    strne r3, [r0, #0x70]

    ldr r3, [r0, #0x4C]     // rising edge detect
    orr r3, r1, r3   
    and r2, r6, #0x4
    cmp r2, #0x0
    strne r3, [r0, #0x4C]

    ldr r3, [r0, #0x58]     // falling edge detect
    orr r3, r1, r3   
    and r2, r6, #0x8
    cmp r2, #0x0
    strne r3, [r0, #0x58]

    ldr r3, [r0, #0x7C]     // async rising edge detect
    orr r3, r1, r3   
    and r2, r6, #0x10
    cmp r2, #0x0
    strne r3, [r0, #0x7C]

    ldr r3, [r0, #0x80]     // async falling edge detect
    orr r3, r1, r3   
    and r2, r6, #0x20
    cmp r2, #0x0
    strne r3, [r0, #0x80]

    mov pc, lr

/*     
    D_GPIO_disable_event_detect - 
    INPUTS:
    OUTPUTS:
 */
D_GPIO_disable_event_detect:

    ldr r0, =0x3F200000     // set address offset if this is an upper level pin
    mvn r1, #1
    and r2, r5, #0x3F
    cmp r2, #32
    addpl r0, r0, #0x4
    subpl r2, r2, #32
    lsl r1, r1, r2

    ldr r3, [r0, #0x64]     // high detect
    and r3, r1, r3   
    and r2, r6, #0x1     
    cmp r2, #0x0
    strne r3, [r0, #0x64]

    ldr r3, [r0, #0x70]     // low detect
    and r3, r1, r3   
    and r2, r6, #0x2
    cmp r2, #0x0
    strne r3, [r0, #0x70]

    ldr r3, [r0, #0x4C]     // rising edge detect
    and r3, r1, r3   
    and r2, r6, #0x4
    cmp r2, #0x0
    strne r3, [r0, #0x4C]

    ldr r3, [r0, #0x58]     // falling edge detect
    and r3, r1, r3   
    and r2, r6, #0x8
    cmp r2, #0x0
    strne r3, [r0, #0x58]

    ldr r3, [r0, #0x7C]     // async rising edge detect
    and r3, r1, r3   
    and r2, r6, #0x10
    cmp r2, #0x0
    strne r3, [r0, #0x7C]

    ldr r3, [r0, #0x80]     // async falling edge detect
    and r3, r1, r3   
    and r2, r6, #0x20
    cmp r2, #0x0
    strne r3, [r0, #0x80]

    mov pc, lr

/*     
    D_GPIO_pin_event_status - 
    INPUTS:
    OUTPUTS:
 */
D_GPIO_pin_event_status:

    ldr r0, =0x3F200000     // set address offset if this is an upper level pin
    mvn r1, #1
    and r2, r5, #0x3F
    cmp r2, #31
    addpl r0, r0, #0x4
    subpl r2, r2, #32
    lsl r1, r1, r2

    ldr r8, [r0, #0x40]
    and r8, r8, r1

    mov pc, lr

/*     
    D_GPIO_get_event_status_masks - 
    INPUTS:
    OUTPUTS:
 */
D_GPIO_get_event_status_masks:

    ldr r0, =0x3F200000
    ldr r8, [r0, #0x40]
    ldr r8, [r0, #0x44]
    mov pc, lr

/*     
    D_GPIO_get_pin_function - 
    INPUTS:
    OUTPUTS:
 */
D_GPIO_get_pin_function:    // r7[first 6 bits] = pin number

    ldr r0, =0x3F200000
    and r2, r5, #0x3F      

    cmp r2, #50             // handling for pins 50+
    subpl r2, r2, #50
    addpl r0, r0, #0x14
    bpl D_GPIO_get_pin_function_processing

    cmp r2, #40             // handling for pins 40:49
    subpl r2, r2, #40
    addpl r0, r0, #0x10
    bpl D_GPIO_get_pin_function_processing

    cmp r2, #30             // handling for pins 30:39
    subpl r2, r2, #30
    addpl r0, r0, #0x0C
    bpl D_GPIO_get_pin_function_processing

    cmp r2, #20             // handling for pins 20:29
    subpl r2, r2, #20
    addpl r0, r0, #0x08
    bpl D_GPIO_get_pin_function_processing

    cmp r2, #10             // handling for pins 10:19 (0:9 is done implicitly!)
    subpl r2, r2, #10
    addpl r0, r0, #0x04

    D_GPIO_get_pin_function_processing: // determine which pin to check now and do, each pin gets 3 bits that describe its function state

        lsl r1, r2, #1      // this + next line are essentially a multiply by 3 
        add r1, r1, r2
        mov r2, #0x7
        lsl r2, r2, r1      // shifts the 3 bits over until we are masking the correct bits
        ldr r8, [r0]
        and r8, r8, r2      // mask the select bits to grab the pin function value, return to caller
        mov pc, lr

/*     
    D_GPIO_set_pin_function_input - 
    INPUTS:
    OUTPUTS:
 */
D_GPIO_set_pin_function_input:

    ldr r0, =0x3F200000
    and r1, r5, #0x3F      

    cmp r1, #50             // handling for pins 50+
    subpl r1, r1, #50
    addpl r0, r0, #0x14
    bpl D_GPIO_set_pin_function_input_processing

    cmp r1, #40             // handling for pins 40:49
    subpl r1, r1, #40
    addpl r0, r0, #0x10
    bpl D_GPIO_set_pin_function_input_processing

    cmp r1, #30             // handling for pins 30:39
    subpl r1, r1, #30
    addpl r0, r0, #0x0C
    bpl D_GPIO_set_pin_function_input_processing

    cmp r1, #20             // handling for pins 20:29
    subpl r1, r1, #20
    addpl r0, r0, #0x08
    bpl D_GPIO_set_pin_function_input_processing

    cmp r1, #10             // handling for pins 10:19 (0:9 is done implicitly!)
    subpl r1, r1, #10
    addpl r0, r0, #0x04

    D_GPIO_set_pin_function_input_processing: 

        lsl r2, r1, #1      // form bit mask
        add r2, r2, r1
        mov r1, #0x7
        mov r3, #0x7
        lsl r3, r3, r2
        lsl r1, r1, r2
        mvn r1, r1          // flip the bits

        ldr r2, [r0]        // load use mask and store
        orr r2, r2, r3
        and r2, r2, r1
        str r2, [r0]

        mov pc, lr

/*     
    D_GPIO_set_pin_function_output - 
    INPUTS:
    OUTPUTS:
 */
D_GPIO_set_pin_function_output:

    ldr r0, =0x3F200000
    and r1, r5, #0x3F      

    cmp r1, #50             // handling for pins 50+
    subpl r1, r1, #50
    addpl r0, r0, #0x14
    bpl D_GPIO_set_pin_function_output_processing

    cmp r1, #40             // handling for pins 40:49
    subpl r1, r1, #40
    addpl r0, r0, #0x10
    bpl D_GPIO_set_pin_function_output_processing

    cmp r1, #30             // handling for pins 30:39
    subpl r1, r1, #30
    addpl r0, r0, #0x0C
    bpl D_GPIO_set_pin_function_output_processing

    cmp r1, #20             // handling for pins 20:29
    subpl r1, r1, #20
    addpl r0, r0, #0x08
    bpl D_GPIO_set_pin_function_output_processing

    cmp r1, #10             // handling for pins 10:19 (0:9 is done implicitly!)
    subpl r1, r1, #10
    addpl r0, r0, #0x04

    D_GPIO_set_pin_function_output_processing: 

        lsl r2, r1, #1      // form bit mask
        add r2, r2, r1
        mov r1, #0x6
        mov r3, #0x7
        lsl r3, r3, r2
        lsl r1, r1, r2
        mvn r1, r1          // flip the bits

        ldr r2, [r0]        // load use mask and store
        orr r2, r2, r3
        and r2, r2, r1
        str r2, [r0]

        mov pc, lr

/*     
    D_GPIO_set_pin_function_0 - 
    INPUTS:
    OUTPUTS:
 */
D_GPIO_set_pin_function_0:

    ldr r0, =0x3F200000
    and r1, r5, #0x3F      

    cmp r1, #50             // handling for pins 50+
    subpl r1, r1, #50
    addpl r0, r0, #0x14
    bpl D_GPIO_set_pin_function_0_processing

    cmp r1, #40             // handling for pins 40:49
    subpl r1, r1, #40
    addpl r0, r0, #0x10
    bpl D_GPIO_set_pin_function_0_processing

    cmp r1, #30             // handling for pins 30:39
    subpl r1, r1, #30
    addpl r0, r0, #0x0C
    bpl D_GPIO_set_pin_function_0_processing

    cmp r1, #20             // handling for pins 20:29
    subpl r1, r1, #20
    addpl r0, r0, #0x08
    bpl D_GPIO_set_pin_function_0_processing

    cmp r1, #10             // handling for pins 10:19 (0:9 is done implicitly!)
    subpl r1, r1, #10
    addpl r0, r0, #0x04

    D_GPIO_set_pin_function_0_processing: 

        lsl r2, r1, #1      // form bit mask
        add r2, r2, r1
        mov r1, #0x3
        mov r3, #0x7
        lsl r3, r3, r2
        lsl r1, r1, r2
        mvn r1, r1          // flip the bits

        ldr r2, [r0]        // load use mask and store
        orr r2, r2, r3
        and r2, r2, r1
        str r2, [r0]

        mov pc, lr

/*     
    D_GPIO_set_pin_function_1 - 
    INPUTS:
    OUTPUTS:
 */
D_GPIO_set_pin_function_1:

    ldr r0, =0x3F200000
    and r1, r5, #0x3F      

    cmp r1, #50             // handling for pins 50+
    subpl r1, r1, #50
    addpl r0, r0, #0x14
    bpl D_GPIO_set_pin_function_1_processing

    cmp r1, #40             // handling for pins 40:49
    subpl r1, r1, #40
    addpl r0, r0, #0x10
    bpl D_GPIO_set_pin_function_1_processing

    cmp r1, #30             // handling for pins 30:39
    subpl r1, r1, #30
    addpl r0, r0, #0x0C
    bpl D_GPIO_set_pin_function_1_processing

    cmp r1, #20             // handling for pins 20:29
    subpl r1, r1, #20
    addpl r0, r0, #0x08
    bpl D_GPIO_set_pin_function_1_processing

    cmp r1, #10             // handling for pins 10:19 (0:9 is done implicitly!)
    subpl r1, r1, #10
    addpl r0, r0, #0x04

    D_GPIO_set_pin_function_1_processing: 

        lsl r2, r1, #1      // form bit mask
        add r2, r2, r1
        mov r1, #0x2
        mov r3, #0x7
        lsl r3, r3, r2
        lsl r1, r1, r2
        mvn r1, r1          // flip the bits

        ldr r2, [r0]        // load use mask and store
        orr r2, r2, r3
        and r2, r2, r1
        str r2, [r0]

        mov pc, lr

/*     
    D_GPIO_set_pin_function_2 - 
    INPUTS:
    OUTPUTS:
 */
D_GPIO_set_pin_function_2:

    ldr r0, =0x3F200000
    and r1, r5, #0x3F      

    cmp r1, #50             // handling for pins 50+
    subpl r1, r1, #50
    addpl r0, r0, #0x14
    bpl D_GPIO_set_pin_function_2_processing

    cmp r1, #40             // handling for pins 40:49
    subpl r1, r1, #40
    addpl r0, r0, #0x10
    bpl D_GPIO_set_pin_function_2_processing

    cmp r1, #30             // handling for pins 30:39
    subpl r1, r1, #30
    addpl r0, r0, #0x0C
    bpl D_GPIO_set_pin_function_2_processing

    cmp r1, #20             // handling for pins 20:29
    subpl r1, r1, #20
    addpl r0, r0, #0x08
    bpl D_GPIO_set_pin_function_2_processing

    cmp r1, #10             // handling for pins 10:19 (0:9 is done implicitly!)
    subpl r1, r1, #10
    addpl r0, r0, #0x04

    D_GPIO_set_pin_function_2_processing: 

        lsl r2, r1, #1      // form bit mask
        add r2, r2, r1
        mov r1, #0x1
        mov r3, #0x7
        lsl r3, r3, r2
        lsl r1, r1, r2
        mvn r1, r1          // flip the bits

        ldr r2, [r0]        // load use mask and store
        orr r2, r2, r3
        and r2, r2, r1
        str r2, [r0]

        mov pc, lr

/*     
    D_GPIO_set_pin_function_3 - 
    INPUTS:
    OUTPUTS:
 */
D_GPIO_set_pin_function_3:

    ldr r0, =0x3F200000
    and r1, r5, #0x3F      

    cmp r1, #50             // handling for pins 50+
    subpl r1, r1, #50
    addpl r0, r0, #0x14
    bpl D_GPIO_set_pin_function_3_processing

    cmp r1, #40             // handling for pins 40:49
    subpl r1, r1, #40
    addpl r0, r0, #0x10
    bpl D_GPIO_set_pin_function_3_processing

    cmp r1, #30             // handling for pins 30:39
    subpl r1, r1, #30
    addpl r0, r0, #0x0C
    bpl D_GPIO_set_pin_function_3_processing

    cmp r1, #20             // handling for pins 20:29
    subpl r1, r1, #20
    addpl r0, r0, #0x08
    bpl D_GPIO_set_pin_function_3_processing

    cmp r1, #10             // handling for pins 10:19 (0:9 is done implicitly!)
    subpl r1, r1, #10
    addpl r0, r0, #0x04

    D_GPIO_set_pin_function_3_processing: 

        lsl r2, r1, #1      // form bit mask
        add r2, r2, r1
        mov r1, #0x0
        mov r3, #0x7
        lsl r3, r3, r2
        lsl r1, r1, r2
        mvn r1, r1          // flip the bits

        ldr r2, [r0]        // load use mask and store
        orr r2, r2, r3
        and r2, r2, r1
        str r2, [r0]

        mov pc, lr

/*     
    D_GPIO_set_pin_function_4 - 
    INPUTS:
    OUTPUTS:
 */
D_GPIO_set_pin_function_4:

    ldr r0, =0x3F200000
    and r1, r5, #0x3F      

    cmp r1, #50             // handling for pins 50+
    subpl r1, r1, #50
    addpl r0, r0, #0x14
    bpl D_GPIO_set_pin_function_4_processing

    cmp r1, #40             // handling for pins 40:49
    subpl r1, r1, #40
    addpl r0, r0, #0x10
    bpl D_GPIO_set_pin_function_4_processing

    cmp r1, #30             // handling for pins 30:39
    subpl r1, r1, #30
    addpl r0, r0, #0x0C
    bpl D_GPIO_set_pin_function_4_processing

    cmp r1, #20             // handling for pins 20:29
    subpl r1, r1, #20
    addpl r0, r0, #0x08
    bpl D_GPIO_set_pin_function_4_processing

    cmp r1, #10             // handling for pins 10:19 (0:9 is done implicitly!)
    subpl r1, r1, #10
    addpl r0, r0, #0x04

    D_GPIO_set_pin_function_4_processing: 

        lsl r2, r1, #1      // form bit mask
        add r2, r2, r1
        mov r1, #0x4
        mov r3, #0x7
        lsl r3, r3, r2
        lsl r1, r1, r2
        mvn r1, r1          // flip the bits

        ldr r2, [r0]        // load use mask and store
        orr r2, r2, r3
        and r2, r2, r1
        str r2, [r0]

        mov pc, lr

/*     
    D_GPIO_set_pin_function_5 - 
    INPUTS:
    OUTPUTS:
 */
D_GPIO_set_pin_function_5:

    ldr r0, =0x3F200000
    and r1, r5, #0x3F      

    cmp r1, #50             // handling for pins 50+
    subpl r1, r1, #50
    addpl r0, r0, #0x14
    bpl D_GPIO_set_pin_function_5_processing

    cmp r1, #40             // handling for pins 40:49
    subpl r1, r1, #40
    addpl r0, r0, #0x10
    bpl D_GPIO_set_pin_function_5_processing

    cmp r1, #30             // handling for pins 30:39
    subpl r1, r1, #30
    addpl r0, r0, #0x0C
    bpl D_GPIO_set_pin_function_5_processing

    cmp r1, #20             // handling for pins 20:29
    subpl r1, r1, #20
    addpl r0, r0, #0x08
    bpl D_GPIO_set_pin_function_5_processing

    cmp r1, #10             // handling for pins 10:19 (0:9 is done implicitly!)
    subpl r1, r1, #10
    addpl r0, r0, #0x04

    D_GPIO_set_pin_function_5_processing: 

        lsl r2, r1, #1      // form bit mask
        add r2, r2, r1
        mov r1, #0x5
        mov r3, #0x7
        lsl r3, r3, r2
        lsl r1, r1, r2
        mvn r1, r1          // flip the bits

        ldr r2, [r0]        // load use mask and store
        orr r2, r2, r3
        and r2, r2, r1
        str r2, [r0]

        mov pc, lr

/*     
    D_GPIO_reserve_pin - 
    INPUTS:
    OUTPUTS:
 */
D_GPIO_reserve_pin:
  
    and r2, r5, #0x3F
    cmp r2, #32
    subpl r4, r2, #32
    ldrpl r0, D_GPIO_RESERVED_UPPER
    ldrmi r0, D_GPIO_RESERVED_LOWER

    mov r1, #1
    lsl r1, r1, r4
    and r8, r0, r1
    eor r8, r8, r1
    cmp r8, #0
    moveq pc, lr

    orr r0, r0, r8
    cmp r2, #32
    strpl r0, D_GPIO_RESERVED_UPPER
    strmi r0, D_GPIO_RESERVED_LOWER

    mov pc, lr

# End label for storing the size of the driver
D_GPIO_END:
