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


startup_:
    
    final_:
    b final_
