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
_start:                     b KR_KERNEL_START
_undefined_instruction:     b KR_KERNEL_UNDEFINED_INSTRUCTION
_software_interrupt:        b KR_KERNEL_SOFTWARE_INTERRUPT
_abort_prefetch:            b KR_KERNEL_ABORT_PREFETCH
_abort_data:                b KR_KERNEL_ABORT_DATA
.org 0x18
_irq:                       b KR_KERNEL_IRQ
_fiq:                       b KR_KERNEL_FRQ


/*
    On exception thrown jump table
*/

KERNEL_START_ADDRESS:                   .word startup_
KERNEL_UNDEFINED_INSTRUCTION_ADDRESS:   .word 0x00000000
KERNEL_SOFTWARE_INTERRUPT_ADDRESS:      .word 0x00000000
KERNEL_ABORT_PREFETCH_ADDRESS:          .word 0x00000000
KERNEL_ABORT_DATA_ADDRESS:              .word 0x00000000
KERNEL_IRQ_ADDRESS:                     .word 0x00000000
KERNEL_FRQ_ADDRESS:                     .word 0x00000000


/*
    Major routines happen here
*/

KR_KERNEL_START:
    ldr r0, KERNEL_START_ADDRESS
    mov pc, r0
KR_KERNEL_UNDEFINED_INSTRUCTION:
    ldr r0, KERNEL_UNDEFINED_INSTRUCTION_ADDRESS
    mov pc, r0
KR_KERNEL_SOFTWARE_INTERRUPT:
    ldr r0, KERNEL_SOFTWARE_INTERRUPT_ADDRESS
    mov pc, r0
KR_KERNEL_ABORT_PREFETCH:
    ldr r0, KERNEL_ABORT_PREFETCH_ADDRESS
    mov pc, r0
KR_KERNEL_ABORT_DATA:
    ldr r0, KERNEL_ABORT_DATA_ADDRESS
    mov pc, r0
KR_KERNEL_IRQ:
    ldr r0, KERNEL_IRQ_ADDRESS
    mov pc, r0
KR_KERNEL_FRQ:
    ldr r0, KERNEL_FRQ_ADDRESS
    mov pc, r0

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

// Macro for calling a driver subroutine, r0 should be the driver start address
.macro __D_CALL__ subroutine:req, offset:req
    ldr r1, [r0, #( ( \subroutine * 4 ) + \offset )]
    add r0, r0, r1
    mov lr, pc
    mov pc, r0
.endm

// Code enters here, run the boot load stage
startup_:

    // Set the GPIO base address
    ldr r0, =0x3F200000
    ldr r1, =GPIO_DRIVER
    str r0, [r1, #8]

    // set ACT led to output mode
    ldr r0, =GPIO_DRIVER
    mov r5, #29
    __D_CALL__ 8, 12

    // set ACT led to high
    ldr r0, =GPIO_DRIVER
    mov r5, #29
    __D_CALL__ 0, 12

    // Enter final wait for now
    b final_;


// Enter this function to go into busy wait mode forever. This is no beauno for general usage but
// a ghetto fix for now. Ideally this will instead enter a sleep mode and wait for interupt to continue
final_:
    b final_


// GPIO driver temp direct include
GPIO_DRIVER:
.align
.incbin "../../../build/drivers/0e_gpio/0e1000-32-gpio.bin"
.align
GPIO_DRIVER_END:

// UART driver temp direct include
UART_DRIVER:
.align
.incbin "../../../build/drivers/0m_uart/0m1000-32-uart.bin"
.align
UART_DRIVER_END:

