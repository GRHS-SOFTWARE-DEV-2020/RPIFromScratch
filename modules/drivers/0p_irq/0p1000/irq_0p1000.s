/*
    IRQ DRIVER 0p1000    v0.0.1
        api for interrupt managment and handling
    
    API FUNCTIONS (subroutine address = addressStoredAt[(driver_start + subroutine_offset)]):



 */

.org 0x0

// IRQ Driver data block
D_IRQ_ID: .word 0x00101000
D_IRQ_END: D_IRQ_DRIVER_END

// IRQ driver subroutine jump table
D_IRQ_DT_START:
D_IRQ_API_0: D_IRQ_HANDLE_INTERRUPT





// IRQ Handler subroutine
D_IRQ_HANDLE_INTERRUPT:






    






D_IRQ_DRIVER_END