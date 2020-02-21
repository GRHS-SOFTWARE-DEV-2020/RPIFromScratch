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

// Include our utilities toolkit
.include "../../asm_utils.s"


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


// Create a table for storing address of loaded drivers
__TABLE__ "drivers", 12


// Macro for calling a driver subroutine, r0 should be the driver start address
.macro __D_CALL__ subroutine:req, offset:req
    ldr r1, [r0, #( ( \subroutine * 4 ) + \offset )]
    add r0, r0, r1
    mov lr, pc
    mov pc, r0
.endm


// Create a table for testing
__TABLE__ "test_table", 12

// Create a stack for testing
__STACK__ "test_stack", 8

// Create a heap for testing
__HEAP__ "test_heap", 2

// Code enters here, run the boot load stage
startup_:

    // Try the __TABLE_SET__ macro using a runtime address evaluation
    TABLE_SET_TEST:
        mov r4, #4
        mov r5, #0x2C
        __TABLE_SET__ "test_table"
    
    // Try the __TABLE_SET__ macro using a constexpr address evaluation
    TABLE_CONSTEXPR_SET_TEST:
        mov r5, #0x59
        __TABLE_SET__ "test_table", 4

    STACK_SP_SWAP_TEST:
        __STACK_SWAP_SP__ "test_stack"
    
    STACK_QPUSH_TEST:
        mov r0, #0xA
        mov r1, #0x5
        mov r7, #0xCB2
        __STACK_QPUSH__ "test_stack", r0, r1, r7

    STACK_QPOP_TEST:
        __STACK_QPOP__ "test_stack", r4, r5, r6

    STACK_SP_UNSWAP_TEST:
        __STACK_SWAP_SP__ "test_stack"

    STACK_PUSH_TEST:
        mov r0, #0xA
        mov r1, #0x5
        mov r7, #0xCB2
        __STACK_PUSH__ "test_stack", r0, r1, r7

    STACK_TO_HEAP_TEST:
        __STACK_TO_HEAP__ "test_stack", "test_heap", 3

    HEAP_TO_STACK_MOVE_TEST:
        __HEAP_TO_STACK_MOVE__ "test_heap", "test_stack", 3
        


    END_OF_UTILS_TESTING:

    // Register GPIO driver
    ldr r4, GPIO_DRIVER
    __TABLE_SET__ "drivers", 0
    ldr r1, =0x3F200000
    str r1, [r4, #8]

    // Register UART driver
    ldr r4, UART_DRIVER
    __TABLE_SET__ "drivers", 1
    ldr r1, =0x3F201000
    str r1, [r4, #8]

    // Set ACT led to output mode
    __TABLE_GET__ "drivers", 0
    mov r0, r4
    mov r5, #29
    __D_CALL__ 8, 12

    // Set ACT led to high to turn on the indicator LED
    __TABLE_GET__ "drivers", 0
    mov r0, r4
    mov r5, #29
    __D_CALL__ 0, 12

    // Set pin 14 and pin 15 to mode alternate function 0 (enables UART on those pins)
    __TABLE_GET__ "drivers", 0
    mov r0, r4
    mov r5, #14
    __D_CALL__ 9, 12
    __TABLE_GET__ "drivers", 0
    mov r0, r4
    mov r5, #15
    __D_CALL__ 9, 12

    // Enable the UART driver
    __TABLE_GET__ "drivers", 1
    mov r0, r4
    __D_CALL__ 0, 12

    // Try and send across a single byte = (0x4C)
    __TABLE_GET__ "drivers", 1
    mov r0, r4
    mov r4, #0x4C
    __D_CALL__ 3, 12

    // Enter final wait for now
    b final_;


// Enter this function to go into busy wait mode forever. This is no beauno for general usage but
// a ghetto fix for now. Ideally this will instead enter a sleep mode and wait for interupt to continue
final_:
    b final_


// GPIO driver temp direct include
.align
GPIO_DRIVER: .word .
.incbin "../../../build/drivers/0e_gpio/0e1000-32-gpio.bin"

// UART driver temp direct include
.align
UART_DRIVER: .word .
.incbin "../../../build/drivers/0m_uart/0m1000-32-uart.bin"

.align

DRIVER_INCLUDES_END:
