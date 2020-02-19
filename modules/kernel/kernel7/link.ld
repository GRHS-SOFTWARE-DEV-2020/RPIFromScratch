
SECTIONS {

    .init 0x8000 : {
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