.section .text
.globl _start
_start:
    li x1, 0xDEADBEEFCAFEC0DE
    li x2, 0x123456789ABCDEF0
    add x3, x1, x2
    sub x4, x1, x2
    addi x5, x1, 0x123
    slt x6, x1, x2
    sltu x7, x1, x2
    slti x8, x1, 0x123
    sltiu x9, x1, 0x123
    and x10, x1, x2
    or x11, x1, x2
    xor x12, x1, x2
    andi x13, x1, 0x123
    ori x14, x1, 0x123
    xori x15, x1, 0x123
    li x3, 8
    sll x16, x1, x3
    srl x17, x1, x3
    sra x18, x1, x3
    slli x19, x1, 4
    srli x20, x1, 4
    srai x21, x1, 4
    auipc x22, 0x1234
    sw x22, 8(x0)
    lw x23, 8(x0)
loop:
    j loop

# riscv64-unknown-elf-gcc -nostdlib -nostdinc -static -g -Ttext 0x0 -o RV64I.elf RV64I.asm -march=rv64i -mabi=lp64