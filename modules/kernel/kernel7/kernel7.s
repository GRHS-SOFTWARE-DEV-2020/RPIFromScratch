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

/*
    Major func jump address table
*/
.org 0x0
_start:                     b startup_          // code actually enters from 0x8000, this is handled in the linker script
_undefined_instruction:     b final_
_software_interrupt:        b final_
_abort_prefetch:            b final_
_abort_data:                b final_
.org 0x18
_irq:                       b final_
_fiq:                       b final_


/*
    A small set of variables used for the kernel's bootloader stage
*/
DT_START:       .word 0x00000000    // start address of the DT block
DRIVER_STATE:   .word 0x00000000    // bit high when loaded, 0 when not. bit # corresponds to position in below table:
D_ARM_TIMER:    .word 0x00000000    // 0
D_BSC_START:    .word 0x00000000    // 1
D_DMA_START:    .word 0x00000000    // 2
D_EMMC_START:   .word 0x00000000    // .....
D_GPIO_START:   .word 0x00000000
D_PCM_START:    .word 0x00000000
D_MEM_START:    .word 0x00000000
D_PWM_START:    .word 0x00000000
D_SYS_TIMER:    .word 0x00000000
D_SPI_START:    .word 0x00000000
D_UART_START:   .word 0x00000000
D_USB_START:    .word 0x00000000

    /*

        TEMP HOLDING SPOT FOR CODE TO READ THE DEVICE TREE

        // r3 is our current working address pointer and holds the memory value of the DVT we are working with
        // we will use the stack pointer to load up the drivers and such following the end of the DVT
        // the value table defined above this routine is what needs to be worked the most. Kernel will have barebones 
        // functionality for IO with the SD card for loading in these drivers but that is all.

        // set SP to after the block and save the start address
        ldr r3, DT_START
        mov sp, r3
        ldr r2, [r3, #0x4]
        add sp, sp, r2

        // start reading the DT block
        add r3, r3, #0x8
    */

// Code enters here, run the boot load stage
startup_:
  







// Enter this function to go into busy wait mode forever. This is no beauno for general usage but
// a ghetto fix for now. Ideally this will instead enter a sleep mode and wait for interupt to continue
final_:
    b final_




// Registers drivers subroutine





.incbin 



