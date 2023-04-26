test1:
    addi x1, x0, 1
    addi x2, x0, 1
    addi x4, x0, 5
fibonacci:
    add x3, x1, x2
    add x1, x2, x3
    add x2, x1, x3
    addi x4, x4, -1
    bne x0, x4, fibonacci
    addi x5, x0, 0x63D
    bne x2, x5, fail

test2:
    addi x1, x0, 5
    addi x2, x0, 0
    addi x3, x0, 0x100
    addi x5, x0, 4
memcpy:
    beq x1, x0, exit1 
    lw x4, 0(x2)
    sub x4, x4, x3
    sw x4, 0(x3)
    add x2, x2, x5
    add x3, x3, x5
    addi x1, x1, -1
    bne x1, x0, memcpy
exit1:
    addi x1, x0, 5
    addi x2, x0, 0
    addi x3, x0, 0x100
    addi x5, x0, 4
memcmp:
    beq x1, x0, test3
    lw x4, 0(x2)
    sub x4, x4, x3
    lw x6, 0(x3)
    add x2, x2, x5
    add x3, x3, x5
    addi x1, x1, -1
    bne x4, x6, fail
    j memcmp
    

test3:
    lui x1, 0xDEADB     # 0xDEADB000
    ori x2, x0, 0xEF    # 0x000000EF
    add x3, x1, x2      # 0xDEADB0EF
    sub x1, x2, x1      # 0x215250EF
    addi x2, x0, 1      # 0x00000001
    srl x4, x3, x2      # 0x6F56D877
    and x2, x1, x4      # 0x21525067
    lui x1, 0x21525     # 0x21525000
    addi x1, x1, 0x67   # 0x21525067
    bne x2, x1, fail
    addi x1, x0, 0xbc
    jalr x1, x1, 0
    addi x2, x0, 0xbc
    bne x1, x2, fail

pass:
    j pass


fail:
    j fail
