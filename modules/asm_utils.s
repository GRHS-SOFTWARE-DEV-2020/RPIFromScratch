/*
    Regularly used programming utilities
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
    .equ __STACK_\stack_name\(), .
    .org . + (\size * 4)
.endm

// Pushes a single DWORD onto the stack at the stack pointer given
// Inputs:
//      r4 = data to push
// Ouputs:
//      none
.macro __STACK_PUSH__ stack_name:req
.endm

// POPs a single DWORD off of the stack at the stack pointer given
// Inputs: 
//      none
// Ouputs:
//      r8 = popped value
.macro __STACK_POP__ stack_name:req
.endm


/*
    HEAP - allows for allocation of data only accesible using a direct index value
*/

// Creates a new heap. This is for all intents and purposes a local heap, but could be used to create a global one.
// Inputs:
//      (macro_arg) name = name of this heap for accessing purposes
// Outputs:
//      (macro_arg) size = size of the heap in blocks of 32  4 byte wide words. ie: size = 1 allocates 128 bytes of space
.macro __HEAP__ name:req, size:req
    .equ __HEAP_TABLE_\name\(), .   // data table to simplify scanning of heap for available space to allocate
    .org . + (\size * 4)
    .equ __HEAP_\name\(), .         // actual heap starts here
    .org . + (\size * 128)
.endm

// Allocates memory on the heap and returns pointer to start of range
// Inputs:
//      heap_name = name of the heap to allocate memory on
// Outputs:
//      r8 = address of start of newly allocated memory
.macro __HEAP_ALLOCATE__ heap_name:req, dword_count:req

    // Grab heap start address and prepare for search

    

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
.macro __TABLE_AT__ name:req, index:vararg
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
.macro __TABLE_SET__ name:req, index:vararg
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
.macro __TABLE_GET__ name:req
__TABLE_AT__ \name
ldr r8, [r8]
.endm
