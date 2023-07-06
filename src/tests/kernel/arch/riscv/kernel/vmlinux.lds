/* 目标架构 */
OUTPUT_ARCH( "riscv" )

/* 程序入口 */
ENTRY( _start )

MEMORY {
    ram (wxa!ri): ORIGIN = 0x0000000080000000 + (0x200000), LENGTH = 128 * 1024 * 1024 - (0x200000)
    ramv (wxa!ri): ORIGIN = (0xffffffe000000000) + (0x200000), LENGTH = ((0xffffffff00000000) - (0xffffffe000000000)) - (0x200000)
}

/* kernel代码起始位置 */
BASE_ADDR = (0xffffffe000000000) + (0x200000);

SECTIONS
{
	/* . 代表当前地址 */
    . = BASE_ADDR;

    /* 记录kernel代码的起始地址 */
    _start = .;

    /* ALIGN(0x1000) 表示4KB对齐 */
    /* _stext, _etext 分别记录了text段的起始与结束地址 */
    .text : ALIGN(0x1000){
        _stext = .;

        *(.text.init)
        *(.text.entry)
        *(.text .text.*)

        _etext = .;
    } >ramv AT>ram

    .rodata : ALIGN(0x1000){
        _srodata = .;

        *(.srodata .srodata.*)
        *(.rodata .rodata.*)

        _erodata = .;
    } >ramv AT>ram

    .data : ALIGN(0x1000){
        _sdata = .;

        *(.sdata .sdata*)
        *(.data .data.*)

        _edata = .;

        . = ALIGN(0x1000);
        uapp_start = .;
        *(.uapp .uapp*)
        uapp_end = .;
        . = ALIGN(0x1000);
    } >ramv AT>ram

    .bss : ALIGN(0x1000){
        _sbss = .;

        *(.bss.stack)
        *(.sbss .sbss.*)
        *(.bss .bss.*)

        _ebss = .;
    } >ramv AT>ram
    /* 记录kernel代码的结束地址 */
    . = ALIGN(0x1000);
    _end = .;
    . = ALIGN(0x4000);
    _stack = .;
}