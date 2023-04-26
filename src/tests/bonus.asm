.section .text
.globl _start
_start:
    addi    x1,     x0,     123     # x1 = 123    
    andi    x2,     x1,     456     # x2 = 72
    ori     x3,     x2,     789     # x3 = 861
    and     x4,     x3,     x1      # x4 = 89
    addi    x5,     x0,     234     # x5 = 234
    or      x5,     x4,     x5      # x5 = 251 (0xfb)
    sll     x6,     x5,     x2      # x6 = 64256 (0xFB00) 
    xori    x7,     x6,     123     # x7 = 64379 (0xFB7B)
    slli    x8,     x7,     4       # x8 = 1030064 (0xFB7B0)
    srli    x9,     x8,     8       # x9 = 4023 (0xFB7)
    srl     x10,    x8,     x2      # x10 = 4023 (0xFB7)
    auipc   x11,    0xFFF           # x11 = 0xFFF02C
    addi    x12,    x0,     -1      # x12 = -1
    sltu    x12,    x11,    x12     # x12 = 1
    jalr    x13,    63(x12)         # x13 = 60
    addi    x14,    x0,     1       # won't exec
Label:
    addi    x15,    x0,     1