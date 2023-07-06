ENTRY(_start)

SECTIONS
{
    . = 0x0;
    _start = .;

    .text.init : { 
        *(.text.init) 
    }
    
    .text : { 
        *(.text, .text.*) 
    }
    
    .data : { 
        *(.data, .data.*) 
    }

    .rodata : { 
        *(.rodata, .rodata*) 
    }

    .bss : {
        *(.bss, .bss.*) 
    }

    .debug : {
        *(*) 
    }
}
