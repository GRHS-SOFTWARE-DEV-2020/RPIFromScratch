
/*
    EMMC DRIVER     v0.0.3
        api for mass media storage interactions

        needs to -
            read from card
            write to card
            report sucecss / fail
            configure for card
            configure delay value
            enable / disable transfer finished interupt
    
    API FUNCTIONS (subroutine address = addressStoredAt[(driver_start + subroutine_offset)]):



 */

// API Subroutine Jump Table
.org 0x0
D_EMMC_1:   .word D_EMMC_read
D_EMMC_2:   .word D_EMMC_write



/*
    API implementation options
 */


.macro D_EMMC_read_1_:
D_EMMC_read:

    ldr r0, =0x3F300000


    mov pc, lr

.endm

.macro D_EMMC_write_1_:
D_EMMC_write:

    ldr r0, =0x3F300000


    mov pc, lr

.endm
