
SECTIONS {

    .init 0x0 : {
        *(.init)
    }

    .text : {
        *.c.o(.text)
        *(.text)
    }

    .data : {
        *(.data)
        *.c.o(*)
    }

    /DISCARD/ : {
        *(*)
    }

}