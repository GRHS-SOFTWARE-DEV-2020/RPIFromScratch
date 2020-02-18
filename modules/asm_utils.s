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
.set \stack_name\()_SP, ( . + 0x4 )
.org . + (\size * 4)
.endm

// Pushes a single DWORD onto the stack at the stack pointer given
// Inputs:
//      r4 = data to push
// Ouputs:
//      none
.macro __STACK_PUSH__ stack_name:req
str r5, [\stack_name\()_SP]
.set \stack_name\()_SP, \stack_name\()_SP + 0x4
.endm

// POPs a single DWORD off of the stack at the stack pointer given
// Inputs: 
//      none
// Ouputs:
//      r8 = popped value
.macro __STACK_POP__ stack_name:req
ldr r8, [\stack_name\()_SP]
.set \stack_name\()_SP, \stack_name\()_SP - 0x4
.endm


/*
    HEAP - allows for allocation of data only accesible using a direct index value
*/

// Creates a new heap
// Inputs:
//      heap_name = name of this heap for accessing purposes
// Outputs:
//      size = size of the heap in DWORDs
.macro __HEAP__ heap_name:req, size:req
.equ \heap_name\()_HEAP_START, .
/*
    Heap entries are formatted like this, size is given for easy heap search:
    struct Heap_Entry 
    {
        uint32_t size_of_entry_;        // in bytes
        // the rest is user defined 
    }
 */
.org . + (\size * 4)
.endm

// Allocates memory on the heap and returns pointer to start of range
// Inputs:
//      heap_name = name of the heap to allocate memory on
// Outputs:
//      r8 = address of start of newly allocated memory
.macro __HEAP_ALLOCATE__ heap_name:req, dword_count:req

// Grab heap start address and prepare for search
mov r8, \heap_name\()_HEAP_START
mov r1, #0x0

// Loop until a suitable space is found
HEAP_ALLOCATE_SEARCH_LOOP_\@: 
add r8, r8, #0x4
ldr r0, [r8]

// Check if this is a size entry, skip to end of entry if it is
cmp r0, #0x0
addne r8, r8, r0
bne HEAP_ALLOCATE_SEARCH_LOOP_\@

// Add empty space to counter and see if we finally have enough space to allocate mem
addeq r1, r1, #0x4
cmp r1, (\dword_count + 4)
bmi HEAP_ALLOCATE_SEARCH_LOOP_\@

// There is enough space, allocate now, r8 will hold the start of the entry data 
sub r8, r8, (\dword_count * 4)
add r8, r8, #0x1
mov r0, (\dword_count * 4)
ldr r0, [r8], #0x4

.endm


/*
    ARRAY - creates a region of memory with set size. no variables related to this container are held.
*/

// Creates an array inplace. Most simple container imaginable.
// Inputs:
//      count = number of elements to allocate space for
//      element_width = width in DWORDS of each element
// Outputs:
//      r8 = array start address
.macro __MAKE_ARRAY__ count:req, element_width:req
mov r8, pc
.org . + (\count * \element_width * 4)
.endm


// Adds an element to the array starting at address given offset and with
// Inputs:
//      r4 = the array start address
//      r5 = the index
// Outputs:
//      r8 = element start address
.macro __IP_ARRAY_AT__ element_width:req
mul r8, r5, \element_width
add r8, r8, r4
.endm










