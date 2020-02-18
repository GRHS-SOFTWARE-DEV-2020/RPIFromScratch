/*
    IRQ DRIVER 0p1000    v0.0.1
        api for interrupt managment and handling
    
    API FUNCTIONS (subroutine address = addressStoredAt[(driver_start + subroutine_offset)]):



 */

 // The paranoia is real
.org 0x0

/*
    IRQ Driver data block
*/
D_IRQ_ID: .word 0x00101000
D_IRQ_END: .word =D_IRQ_DRIVER_END


/*  
    IRQ driver subroutine jump table
*/
D_IRQ_API_0: .word =D_IRQ_INTERUPT_HANDLER
D_IRQ_API_1: .word =D_IRQ_ENABLE_INTERUPTS
D_IRQ_API_2: .word =D_IRQ_DISABLE_INTERUPTS
D_IRQ_API_3: .word =D_IRQ_ADD_INTERUPT
D_IRQ_API_4: .word =D_IRQ_REMOVE_INTERUPT


/*
    Interupt entry table for adding interupts from outside sources. First label also stores the current size
*/

INTERUPT_TABLE_ENTRY_COUNTER: .word 0x00000000
INTERUPT_TABLE: .word 0x0000004
/*

    Stores data in the following structure (c code mockup):

    struct Interupt_Table_Entry 
    {
        uint32_t interupt_status_register_address;      // stores the address of the status flag register for this interrupt
        uint16_t r5_set_to_offset;                      // r5 will get set to the value held at (interupt_status_register_address + r5_set_to_offset), set to 0 to return masked status flags
        uint15_t entry_id;                              // used internally for referencing this
        bool     deferred_handling;                     // true = interupt is put into a queue for the kernel to handle. false = run immediatly (for a semi-frq interrup)
        uint32_t interupt_status_register_mask;         // mask is AND(ed) with the value held in interupt_status_register_address
        uint32_t on_interupt_run_subroutine;            // subroutine is run if the mask + status register value returns >= 0.
    };
    sizeof(Interupt_Table_Entry) = 16 Bytes = 4 Words = 2 Dwords

 */
.org . + 0x100
END_OF_INTERUPT_TABLE:



/*
    Deffered handling queue. First label holds the current size of the table.
*/
DEFFERED_QUEUE:    .word 0x00000000

/*
    Stores deffered interupts for later handling by the kernel

    struct Deffered_Interupt_Entry
    {
        uint16_t entry_ID;
    };
    sizoef(Deffered_Interupt_Entry) = 2 Bytes = 1 Word

*/

.org . + 0x10
END_OF_DEFFERED_QUEUE:


/*
    Interupt stack. First label holds the stack pointer
*/
IRQ_STACK: .word . + 0x4
.org . + 0x100
IRQ_STACK_END:


// Inputs:
//      r0 - dword of data to push onto the stack
// Ouputs: none
.macro __PUSH_REG__
    str r0, [sp], #0x4
.endm

// Inputs: none
// Outputs:
//      r0 = popped value
.macro __POP_REG__
    ldr r0, [sp, #-0x4]!
.endm



/*
    ------------------------------------

        Beginning of API subroutines

    ------------------------------------
*/

/*
    Disables interupts
    Inputs:
        n/a
    Ouputs:
        n/a
*/
D_IRQ_INTERUPT_HANDLER:

    // Load the IRQ stack pointer value
    ldr sp, IRQ_STACK

    // Sub 4 from the LR to adjust properly for return to interuptted code
    sub lr, lr, #0x4
    
    // PUSH r0:r4 so that we have some room to work
    __PUSH_REG__
    mov r0, r1
    __PUSH_REG__
    mov r0, r2
    __PUSH_REG__
    mov r0, r3
    __PUSH_REG__
    mov r0, r4
    __PUSH_REG__



    /*
        Interupt handling goes here!
    */

    // 1. Loop through interupt entry table
        // a. Grab status flag register and mask to see if any are set
    
    // 2a. If the interupt cannot be found, this is bad news and should have some sort of error thrown. Exit.
    // 2b. If the interupt is found, grab the deffered_handling bit and check
    
    // 3b. If the bit is set to 1, add the event to the deffered_handling queue
    // 3b. If the bit is set to 0, run the subroutine given immediatly



    // POP r4:r8 back off the stack
    __POP_REG__
    mov r4, r0
    __POP_REG__
    mov r3, r0
    __POP_REG__
    mov r2, r0
    __POP_REG__
    mov r1, r0
    __POP_REG__

    // Store the IRQ stack pointer value before returning
    str sp, IRQ_STACK

    // Return to the interupted code
    movs pc, lr


/*
    Enables interupts
    Inputs:
        n/a
    Ouputs:
        n/a
*/
D_IRQ_ENABLE_INTERUPTS:

    // Enable interupt handling bit
    mrs r0, cpsr
    bic r0, r0, #0x80
    msr cpsr, r0

    // Return to caller
    mov pc, lr


/*
    Disables interupts
    Inputs:
        n/a
    Ouputs:
        n/a
*/
D_IRQ_DISABLE_INTERUPTS:

    // Disable interupt handling bit
    mrs r0, cpsr
    orr r0, r0, #0x80
    msr cpsr, r0

    // Return to caller
    mov pc, lr


/*
    Adds an interupt to the table for handling
        r4 = status register address
        r5 = status register mask
        r6 = on interupt subroutine address
        r7 = [b0:b15 = r5 set to offset], [b16 = deffered_handling (bool)]
    Ouputs:
        r8 = [b0 = success/fail (bool)]
        r9 = entry ID
 */
D_IRQ_ADD_INTERUPT:

    // Check that there is space for the new entry in the table
    ldr r0, =INTERUPT_TABLE         // grabs table start address
    ldr r1, INTERUPT_TABLE          // grabs offset of next available entry address
    add r0, r0, r1                  // add the offset to the table address to get next available spot
    add r0, r0, #16                 // add 16 bytes as each entry is 16 bytes wide
    ldr r1, =END_OF_INTERUPT_TABLE  // grab the first address that cannot be written to

    // Exit early if not enough space available, set r8 to 0 to show failure
    cmp r1, r0                      // [max address] - [next entry start address]
    movmi r8, #0x0                  // clear r8 if we cannot add a new entry
    movmi pc, lr                    // exit the macro early if we cannot add a new entry

    // If we made it here, then we are adding a new entry, increment counter
    ldr r1, INTERUPT_TABLE_ENTRY_COUNTER
    add r1, r1, #0x1
    str r1, INTERUPT_TABLE_ENTRY_COUNTER
    
    // Reset r0 to hold new entry start address by reversing the increment
    sub r0, r0, #16
    
    // Add the status register address into the table for the new entry, post increment
    str r4, [r0], #0x4

    // Grab the ID for this entry, clear most significant bit as it is overflow
    ldr r1, INTERUPT_TABLE_ENTRY_COUNTER
    lsl r1, r1, #15
    bic r1, #15
    mov r9, r1                      // copy the ID into r9 to be returned to the caller

    // Add the deffered handling bool to the most significant bit of the dword
    mov r2, r7
    lsr r2, r2, #16                 // makes the bool be the least significant bit
    and r2, r2, #0x1                // toss the rest of the dword as its not required
    lsl r2, r2, #31                 // shift the bool into position for addition
    orr r1, r1, r2                  // OR r2 in to add the bool to the dword

    // Add the [r5 = offset] value
    mov r2, #0xFFFF                 // prepare the shifter operand as the shifter cannot take 16 bit values
    and r2, r2, r7                  // toss the bool, only grab the offset from the dword
    orr r1, r1, r2                  // OR r2 in to add the offset value

    // Add the finalized dword into the entry
    str r1, [r0], #0x4

    // Add the status register mask
    str r5, [r0], #0x4

    // Add the on_interupt_subroutine address
    str r6, [r0], #0x4

    // Set the new next table entry value for the table
    str r0, INTERUPT_TABLE

    // Return to caller
    mov pc, lr

/*
    Removes an interupt entry from the table with the provided ID (r4)
        r4 = ID of the entry to be removed
    Ouputs:
        r8 = [b0 = success/fail (bool)]
 */
D_IRQ_REMOVE_INTERUPT:

    // Try to find the interupt







    // Found interupt label
    D_IRQ_REMOVE_INTERUPT_FOUND_ENTRY:





    // Return to caller
    mov pc, lr








D_IRQ_DRIVER_END:
