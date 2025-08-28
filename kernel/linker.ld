ENTRY(_start)

SECTIONS
{
    . = 0x2000;  /* kernel loads at 0x2000 in boot2.asm */

    .text : {
        *(.text)
    }

    .rodata :{
        *(.rodata)
    }

    .data : {
        *(.data)
    }

    .bss : {
        *(.bss)
    }
}