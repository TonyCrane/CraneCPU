test1:
    lui x1, 0xDEADB     # 0xDEADB000
    ori x2, x0, 0xEF    # 0x000000EF
    addi x3, x0, 1      # 0x00000001
    nop
    nop
    add x4, x1, x2      # 0xDEADB0EF
    sub x5, x2, x1      # 0x215250EF
    nop
    nop
    srl x6, x4, x3      # 0x6F56D877
    nop
    nop
    nop
    and x7, x5, x6      # 0x21525067
    lui x8, 0x21525     # 0x21525000
    nop
    nop
    nop
    addi x9, x8, 0x67   # 0x21525067
    nop
    nop
    nop
    bne x7, x9, fail
    nop
    nop
    nop
    nop
    nop

test2:
    sw x4, 0(x0)        # mem[0] = 0xDEADB0EF
    lw x5, 0(x0)        # 0xDEADB0EF
    lui x6, 0x1ADB      # 0x01ADB000
    srli x7, x4, 12     # 0x000DEADB
    nop
    nop
    addi x8, x5, -0xEF  # 0xDEADB000
    slli x7, x7, 12     # 0xDEADB000
    nop
    nop
    nop
    bne x8, x7, fail
    nop
    nop
    nop
    nop
    nop

test3:
    addi x1, x0, 0xf4   # 0x000000f4
    nop
    nop
    nop
    jalr x1, x1, 0      # 0x000000c8
    nop
    nop
    nop
    nop
    nop

fail:
    j fail              # 20th ins from 0
    nop
    nop
    nop
    nop
    nop
    addi x2, x0, 0xc8   # 0x000000c8
    nop
    nop
    nop
    bne x1, x2, fail
    nop
    nop
    nop
    nop
    nop

pass:
    j pass
    nop
    nop
    nop
    nop
    nop
