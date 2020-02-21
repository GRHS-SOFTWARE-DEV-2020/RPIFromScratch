/*
    Jonathan Cline
    Regularly used programming utilities put together with macros to ease the burden of more complex programming tasks. 
    Most of the utilities provided are memory related.
*/


/*

    STACK - creates a region of memory only accessible through PUSH and POP instructions

*/

// Creates a stack inplace
// Inputs:
//      size = size of stack in DWORDS
// Outputs:
//      none
.macro __STACK__ stack_name:req, size:req
    __STACK_POINTER_\stack_name\(): .word . + 0x4
    __STACK_\stack_name\():
    .org . + (\size * 4)
.endm


// Swaps the current SP with the SP of the referenced stack. Should be used prior and after multiple Q operations for maximum effectiveness
// INPUTS:
//      (macro_arg) stack_name = name of the stack this is referencing
// OUTPUTS:
//      sp = value of the stack pointer at 
.macro __STACK_SWAP_SP__ stack_name:req
    mov r0, sp
    ldr sp, __STACK_POINTER_\stack_name\()
    str r0, __STACK_POINTER_\stack_name\()
.endm


// Pushes one or more registers onto the stack given. This will maintain the current SP value but is slow.
// Inputs:
//      (macro_arg) stack_name = name of the stack this is pushing to
//      (macro_arg) reglist = one or more registers to use, these are added by additional arguements each with a register name. pushed left to right
// Ouputs:
//      none
.macro __STACK_PUSH__ stack_name:req, reglist:vararg
    __STACK_PUSH_SP_STORE_\@: .word 0x00000000
    str sp, __STACK_PUSH_SP_STORE_\@
    ldr sp, __STACK_POINTER_\stack_name\()
    .irp reg_p, \reglist
        str \reg_p\(), [sp], #0x4
    .endr
    str sp, __STACK_POINTER_\stack_name\()
    ldr sp, __STACK_PUSH_SP_STORE_\@
.endm

// Same as above but does not offer safety for the SP value, make sure you are using the correct value!
.macro __STACK_QPUSH__ stack_name:req, reglist:vararg
    .irp reg_p, \reglist
        str \reg_p\(), [sp], #0x4
    .endr
.endm


// POPs a single DWORD off of the stack at the stack given. This will maintain the current SP value but is slow.
// Inputs: 
//      (macro_arg) stack_name = name of the stack this is referencing
//      (marco_arg) reglist = 
// Ouputs:
//      / outputs are dependent on reglist /
.macro __STACK_POP__ stack_name:req, reglist:vararg
    __STACK_POP_SP_STORE_\@: .word 0x00000000
    str sp, __STACK_POP_SP_STORE_\@
    ldr sp, __STACK_POINTER_\stack_name\()
    .irp reg_p, \reglist
        ldr \reg_p\(), [sp, #-0x4]!
    .endr
    str sp, __STACK_POINTER_\stack_name\()
    ldr sp, __STACK_POP_SP_STORE_\@
.endm

// Same as above but does not offer safety for the SP value, make sure you are using the correct value!
.macro __STACK_QPOP__ stack_name:req, reglist:vararg
    .irp reg_p, \reglist
        ldr \reg_p\(), [sp, #-0x4]!
    .endr
.endm


/*

    TABLE - creates a table inplace that can be accessed by outside functions. Allocated on the spot

*/

/*
    Creates an inplace table that can be accessed using the first arguement (string)
    INPUTS:
        (macro_arg) name = name of the table, used to refer to this particular table
        (macro_arg) size = size of the table in words (32 bits). IE: size = 4 creates a table 16 bytes wide
    OUTPUTS:
        none
*/
.macro __TABLE__ name:req, size:req
    .equ __TABLE_\name\(), .
    .org . + ( \size * 4 )
.endm

/*
    Gets the address of the inplace table value at requested index
    INPUTS: 
        r4 = index value (first value in inplace table is index = 0, second is index = 1, etc...)
        (macro_arg) name = name of the inplace table this is referencing
        (macro_arg)[optional] index = same as r4. If this is specified, the address will be calculated on compile time.
    OUTPUTS:
        r8 = address of table value
*/
.macro __TABLE_AT__ name:req, index
    .ifndef __TABLE_\name       // throws error on undefined table
        .print "\n\n !!! '__TABLE_AT__' macro failed as requested table is undefined !!! \n\n"
        .err
        .exitm
    .endif
    .ifb \index                 // if index is blank, this is a run time computed address
        lsl r8, r4, #2
        add r8, r8, #__TABLE_\name
    .else                       // if index value is given, this is a compile time computed address
        mov r8, #(__TABLE_\name + (\index * 4))
    .endif
.endm

/*
    Sets a value (word) in the requested inplace table to the provided value
    INPUTS:
        r4 = index value (same as __TABLE_IP_AT__)
        r5 = set value to
        (macro_arg) name = name of the inplace table this is referencing
    OUTPUTS:
        none
*/
.macro __TABLE_SET__ name:req, index
    .ifb \index
        __TABLE_AT__ \name
        str r5, [r8]
    .else
        __TABLE_AT__ \name, \index
        str r5, [r8]
    .endif
.endm

/*
    Gets a value (word) in the requested inplace table to the provided value
    INPUTS:
        r4 = index value (same as __TABLE_IP_AT__)
        (macro_arg) name = name of the inplace table this is referencing
    OUTPUTS:
        r8 = inplace table value at index
*/
.macro __TABLE_GET__ name:req, index
    .ifb \index
        __TABLE_AT__ \name
        ldr r8, [r8]
    .else
        __TABLE_AT__ \name, \index
        ldr r8, [r8]
    .endif
.endm



/*

    HEAP - allows for allocation of data only accesible using a direct index value

*/

// Creates a new heap. This is for all intents and purposes a local heap, but could be used to create a global one. Each heap entry has an additional 1st word denoting size in bytes
// Inputs:
//      (macro_arg) heap_name = name of this heap for accessing purposes
// Outputs:
//      (macro_arg) size = size of the heap in blocks of 32  4 byte wide words. ie: size = 1 allocates 128 bytes of space
.macro __HEAP__ heap_name:req, size:req
    __HEAP_\heap_name\(): .word . + 0x4              // label for referencing the start of the heap
    .org . + (\size * 128)
.endm

// Allocates memory on the heap and returns pointer to start of range
// Inputs:
//      (macro_arg) heap_name = name of the heap to allocate memory on
//      (macro_arg) words = width of allocation in words
// Outputs:
//      r8 = address of start of newly allocated memory
.macro __HEAP_ALLOCATE__ heap_name:req, words:req

    // Prepare for heap search
    ldr r8, __HEAP_\heap_name\()
    mov r0, #0x0

    // Loop through heap until enough space is found for the allocatation request.
    __HEAP_ALLOCATE_SEARCH_LOOPBACK_\@:

    // Grab the byte and see if it holds a size value
    ldr r1, [r8]
    cmp r1, #0x0

    // If this holds a size, reset the r2 counter and increment the r8 address pointer by size
    movne r0, #0x0
    addne r8, r8, r1
    bne __HEAP_ALLOCATE_SEARCH_LOOPBACK_\@

    // If this is an empty word, increment the r0 counter, and check if we have found enough space yet
    add r0, r0, #0x4
    add r8, r8, #0x4
    cmp r0, #((\words + 1) * 4)

    // If we haven't found enough space, keep looping
    bmi __HEAP_ALLOCATE_SEARCH_LOOPBACK_\@

    // We have found enough space, set r8 to 0th address
    sub r8, r8, r0
    
    // Set size value and post increment r8 heap address pointer to return to correct address
    mov r1, #(\words * 4)
    str r1, [r8], #0x4

.endm

/*
    Deallocates some memory off of the heap
    INPUTS:
        r4 = start address of heap chunk (this is returned from __HEAP_ALLOCATE__ in r8)
        (macro_arg) heap_name = name of the heap this is referencing
        (macro_arg) words = number of words including the first referenced by r4 to clear
    OUTPUTS:
        none
*/
.macro __HEAP_FREE__ heap_name:req, words:req
    mov r0, r4
    mov r1, #0x0
    str r1, [r0, #-0x4]
    .rept \words
        str r1, [r0], #0x4
    .endr
.endm


/*
    Helper functions!
*/


/*
    POPs some values off of a stack and allocates heap space for these values. Orignal SP value is preserved. ! values in stack are in last (POP to retrieve last) to first order !
    INPUTS:
        (macro_arg) stack_name = name of the stack this is referencing
        (macro_arg) heap_name = name of the heap this is referencing
        (macro_arg) words = number of words to pop from the stack and give to the heap
    OUTPUTS:
        r8 = first address of allocated heap space
*/
.macro __STACK_TO_HEAP__ stack_name:req, heap_name:req, words:req
    __STACK_SWAP_SP__ \stack_name
    __HEAP_ALLOCATE__ \heap_name , \words
    add r8, r8, #(\words * 0x4)
    .rept (\words\() / 4)
        __STACK_QPOP__ \stack_name , r0, r1, r2, r3
        stmdb r8!, {r0, r1, r2, r3}
    .endr
    .if (\words\() % 4) == 3
        __STACK_QPOP__ \stack_name , r0, r1, r2
        stmdb r8!, {r0, r1, r2}
    .elseif (\words\() % 4) == 2
        __STACK_QPOP__ \stack_name , r0, r1
        stmdb r8!, {r0, r1}
    .elseif (\words\() % 4) == 1
        __STACK_QPOP__ \stack_name , r0
        str r0, [r8, #-0x4]!
    .endif
    __STACK_SWAP_SP__ \stack_name
.endm

/*
    PUSHs some values onto a stack as a copy of values from within a heap. Original SP value is preserved. ! values in stack are in last (POP to retrieve last) to first order !
    INPUTS:
        r4 = first address of region of heap to copy. Same as value returned by any heap allocating macro.
        (macro_arg) stack_name = name of the stack this is referencing
        (macro_arg) words = number of words to pop from the stack and give to the heap
    OUTPUTS:
        none
*/
.macro __HEAP_TO_STACK_COPY__ stack_name:req, words:req
    __STACK_SWAP_SP__ \stack_name
    mov r0, r4
    .rept (\words / 3)
        ldmia r0!, {r1, r2, r3}
        __STACK_QPUSH__ \stack_name , r1, r2, r3
    .endr
    .if (\words % 3) == 2
        ldmia r0!, {r1, r2}
        __STACK_QPUSH__ \stack_nane , r1, r2
    .elseif (\words % 3) == 1
        ldr r1, [r0], #0x4
        __STACK_QPUSH__ \stack_name , r1
    .endif
    __STACK_SWAP_SP__ \stack_name
.endm

/*
    Same as __HEAP_TO_STACK_COPY__ but free's the memory from the heap after the transfer ! values in stack are in last (POP to retrieve last) to first order !
    ADDITIONAL INPUTS:
        (macro_arg) heap_name = name of the heap to free memory from
*/
.macro __HEAP_TO_STACK_MOVE__ heap_name:req, stack_name:req, words:req
    __HEAP_TO_STACK_COPY__ \stack_name , \words
    __HEAP_FREE__ \heap_name , \words
.endm

