.section .init
.global _start
.global _undefined_instruction
.global _software_interrupt
.global _abort_prefetch
.global _abort_data
.global _irq
.global _fiq
.arm
.align


// major func jump address table
.org 0x0
_start:                     b startup_          // code actually enters from 0x8000, this is handled in the linker script
_undefined_instruction:     b final_
_software_interrupt:        b final_
_abort_prefetch:            b final_
_abort_data:                b final_
.org 0x18
_irq:                       b final_
_fiq:                       b final_


// mains startup function. handles running intialization subroutines and setting parameters
startup_:

    ldr sp, =0x00010000

    ldr r0, GPIO_DRIVER     // set ACT pin function to output
    ldr r1, [r0, #0x20]
    add r0, r0, r1
    mov r5, #29
    add lr, pc, #0x8
    mov pc, r0


    ldr r0, GPIO_DRIVER     // turn on LED
    ldr r1, [r0]
    add r0, r0, r1
    mov r5, #29
    add lr, pc, #0x8
    mov pc, r0

    



    final_:
    b final_



// Add the GPIO Driver
GPIO_DRIVER:
.incbin "../../../build/drivers/gpio/D_GPIO_0BA+_0.0.1_3B+_32.bin"

// Add the ARMTIMER Driver
ARMTIMER_DRIVER:
.incbin "../../../build/drivers/arm_timer/D_ARMTIMER_BCM_0.0.1_3B+_32.bin"

// Add the EMMC Driver
EMMC_DRIVER:
//.incbin "../../../build/drivers/emmc/D_EMMC_SD_0.0.1_3B+_32.bin"
