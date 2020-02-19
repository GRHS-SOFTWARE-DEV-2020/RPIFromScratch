SECTIONS {
	.init 0x0 : {
		*(.init)
	}
		
	.data : {
		*(.data)
		*.c.o(*)
	}

	.text : {
		*.c.o(.text)
		*(.text)
	}
	
	/DISCARD/ : {
		*(*)
	}
}
