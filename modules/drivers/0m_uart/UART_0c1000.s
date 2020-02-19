
/*
Cannon Pierce
 */





/*
	IBRD + FBRD = Hz/(16 * baud rate) i think
	Need to set baud rate, frame rate, enable transmit/receive, set interrupt
	UART base address 0x3F20100
	Offset 0x24 0x28 IBRD, FBRD
	FBRD = 0.052083 * (2^6)
	IBRD = 0
	IMSC - interruptset all to high except is specified zero(not sure about any of this) bit 10-4 = 1, 0x38
	Clear transmit FIFO, repogram Control register before re enabling
	
	DONT CHANGE ANYTHING WHILE UART ENABLED!!
	
	Control Register 0x30
	To enable transmission, the TXE bit and UARTEN bit must be set to 1
	to enable reception, the RXE bit and UARTEN bit, must be set to 1
	Bits to set to 1 - TXE 8, RXE 9, UARTEN 0(set 0 to disable UART, 1 to enable)
	Frame format
	Data bits - LCRH reg 0x2c, bits 6,5 set to 11 for 8 data bits
	Parity bits are error checking bits based on even or odd 1's in data bits
	Default Odd parity enabled. bit 1 is parity enable and 2 is even/odd
	LCRH bits 7-0, 6 and 5-1, 4-0, 3-1, 2-0, 1-0, 0-0.
	
	Not sure about send/receive subroutines yet
	
	No inputs or outputs yet
*/


/* Jump table stuff */
.org 0x0
D_UART_ID:  .word 0x000d1000
D_UART_END: .word =D_UART_END
D_UART_BASE_ADDRESS: .word 0x3F20100


/* 
API 0 - Enables UART (After flushing FIFO to rid errors) with send and receive with no current inputs or outputs, handles settings
API 1 - Disables UART main but not the actual function (still cant do anything) no inputs or outputs, Then flushes FIFO to rid erros
API 2 - Handles Receiving - Outputs to r8 - 8 bits
API 3 - Handles Sending - Input is r4 - 8 bits
API 4 - Used for checking if Uart, Send, And/Or Receive is enabled, outputs to r7, 3 bits with 1 meaning enabled 0 disabled, bit 0 - receive bit 1 - send bit 2 - UART
 */

D_UART_API_0: .word =D_UART_ENABLE
D_UART_API_1: .word =D_UART_DISABLE
D_UART_API_2: .word =D_UART_RECEIVE
D_UART_API_3: .word =D_UART_SEND
D_UART_API_4: .word =D_UART_CHECKENABLED

/* Reserved DWORDs for memory */
D_UART_RESERVED_LOWER: .word 0x00000000
D_UART_RESERVED_UPPER: .word 0x00000000


// Enables UART
D_UART_ENABLE:
	/* UART base address */
	
	mov r0, #0x0
	mov r0, =D_UART_BASE_ADDRESS
	
	/* clear FIFo transmitter to avoid errors, LCRH pin 4 FEN */
	mov r1, #0x0
	mov r1, #0x3F
	and r1, r1, [r0, #0x2c]
	str r1, [r0, #0x2c]
	

	/* set FBRD then IBRD */
	mov r1, #0x0
	mov r1, #0x3
	str r1, [r0, #0x28]
	mov r1, #0x0
	str r1, [r0, #0x24]
	
	/* setting interrupt stuff all as one where it can be for now, */
	mov r1, #0x3F0
	str r1, [r0, #0x38]
	
	/*setting LCRH stuff from way above */
	mov r1, #0x0
	mov r1, #0x68
	str r1, [r0, #0x2c]
	
	/*enable UART, transmit, receive - bit 1, 8, 9 are set to 1 rest 0 */
	mov r1, #0x0
	mov r1, #0x301
	str r1, [r0, #0x30]
	mov r1, #0x0
	
	
	mov pc, lr
	
	
/* 
	diasble the UART, keeps all settings except FIFO(LCRH bit 4) set to 0/disabled
	No inputs or outputs yet
*/
D_UART_DISABLE:
	/* base address for UART */
	
	mov r0, #0x0
	mov r0, =D_UART_BASE_ADDRESS
	
	/* disable UART */
	mov r1, #0x0
	mov r1, #0xCB80
	and r1, r1, [r0, #0x30]
	str r1, [r0, #0x30]
	
	/* clear FIFo transmitter to avoid errors, LCRH pin 4 FEN */
	mov r1, #0x0
	mov r1, #0x3F
	and r1, r1, [r0, #0x2c]
	str r1, [r0, #0x2c]
	
	
	
	mov pc, lr
	
/* 
Subroutine for received data
Doc says send/receive are same bits, not sure if it auto sends/receives
Output is r8
No inputs yet
offset is 0x0
*/
D_UART_RECEIVE:
	/* UART base address */
	
	mov r0, #0x0
	mov r0, =D_UART_BASE_ADDRESS
	
	/* Grab received data in register, and AND it with something to get only the data bits
	Data Register offeset 0x0*/
	mov r1, #0x0
	mov r1, #0xFF
	mov r8, #0x0
	mov r2, #0x0
	mov r2, [r0, #0x0]
	and r8, r1, r2
	
	
	mov pc, lr
	
/*
Sends data to uart device
No outputs yet
Input is r4
offset is 0x0
*/
D_UART_SEND:
	/* UART base address */
	
	mov r0, #0x0
	mov r0, =D_UART_BASE_ADDRESS
	
	/* AND to remove the data bits then add result with our input and push to Data Register */
	mov r1, #0x0
	mov r1, #0xF00
	mov r2, #0x0
	and r2, r1, r0
	mov r1, #0x0
	mov r1, r4
	add r2, r2, r1
	str r2, [r0, #0x0]
	
	
	mov pc, lr

	
	
/*
Checks to see if UART, send, and receive(in that order) are enabled
0 = disabled
1 = enabled
No input
Output - 3 bits - r7
bit 0 - receive
bit 1 - send
bit 2 - UART
*/
D_UART_CHECKENABLED:
	/* UART base address */
	
	mov r0, #0x0
	mov r0, =D_UART_BASE_ADDRESS
	
	/* clear output reg for use later */
	mov r7, #0x0
	
	/* grab UART Control Registry */
	mov r1, #0x0
	mov r1, [r0, #0x30]
	
	/* Check UART - AND with 1 and compare to see relation to zero, then push to output */
	mov r2, #0x0
	and r2, r1, #0x1
	cmp r2, #0x0
	orrne r7, r7, #0x4
	
	/* Check Send - Same as above */
	mov r2, #0x0
	and r2, r1, #0x100
	cmp r2, #0x0
	orrne r7, r7 #0x2
	
	/* Check receive - same as above */
	mov r2, #0x0
	and r2, r1, #0x200
	cmp r2, #0x0
	orrne r7, r7 #0x1
	
	
	mov pc, lr


D_UART_END:



	