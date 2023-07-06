    .section .text.entry
    .align 2
    .globl _traps 
_traps:
    csrr t0, sscratch
    beq t0, x0, _ignore_switch
    csrw sscratch, sp
    mv sp, t0
_ignore_switch:
    # 1. save 32 registers and sepc to stack
    addi sp, sp, -32*8
    sd x2, 8(sp)
    sd x1, 0(sp)
    sd x3, 16(sp)
    sd x4, 24(sp)
    sd x5, 32(sp)
    sd x6, 40(sp)
    sd x7, 48(sp)
    sd x8, 56(sp)
    sd x9, 64(sp)
    sd x10, 72(sp)
    sd x11, 80(sp)
    sd x12, 88(sp)
    sd x13, 96(sp)
    sd x14, 104(sp)
    sd x15, 112(sp)
    sd x16, 120(sp)
    sd x17, 128(sp)
    sd x18, 136(sp)
    sd x19, 144(sp)
    sd x20, 152(sp)
    sd x21, 160(sp)
    sd x22, 168(sp)
    sd x23, 176(sp)
    sd x24, 184(sp)
    sd x25, 192(sp) 
    sd x26, 200(sp)
    sd x27, 208(sp)
    sd x28, 216(sp)
    sd x29, 224(sp)
    sd x30, 232(sp)
    sd x31, 240(sp)
    csrr t0, sepc
    sd t0, 248(sp)

    # 2. call trap_handler
    csrr a0, scause
    csrr a1, sepc
    addi a2, sp, -8
    jal trap_handler

    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack
    ld t0, 248(sp)
    csrw sepc, t0
    ld x31, 240(sp)
    ld x30, 232(sp)
    ld x29, 224(sp)
    ld x28, 216(sp)
    ld x27, 208(sp)
    ld x26, 200(sp)
    ld x25, 192(sp)
    ld x24, 184(sp)
    ld x23, 176(sp)
    ld x22, 168(sp)
    ld x21, 160(sp)
    ld x20, 152(sp)
    ld x19, 144(sp)
    ld x18, 136(sp)
    ld x17, 128(sp)
    ld x16, 120(sp)
    ld x15, 112(sp)
    ld x14, 104(sp)
    ld x13, 96(sp)
    ld x12, 88(sp)
    ld x11, 80(sp)
    ld x10, 72(sp)
    ld x9, 64(sp)
    ld x8, 56(sp)
    ld x7, 48(sp)
    ld x6, 40(sp)
    ld x5, 32(sp)
    ld x4, 24(sp)
    ld x3, 16(sp)
    ld x1, 0(sp)
    ld x2, 8(sp)
    addi sp, sp, 32*8

    csrr t0, sscratch
    beq t0, x0, _traps_sret
    csrw sscratch, sp
    mv sp, t0
_traps_sret:
    # 4. return from trap
    sret

    .global __dummy
__dummy:
    # 将 sepc 设置为 dummy() 的地址, 并使用 sret 从中断中返回。
    # la t0, dummy
    # # csrw sepc, t0
    # # sret
    # mv ra, t0
    # ret
    csrr t0, sscratch
    csrw sscratch, sp
    mv sp, t0
    csrw sepc, x0
    sret

    .globl __switch_to
__switch_to:
    # __switch_to接受两个 task_struct 指针作为参数
    # 保存当前线程的ra, sp, s0~s11到当前线程的 thread_struct 中
    # 将下一个线程的 thread_struct 中的相关数据载入到ra, sp, s0~s11中。

    # save state to prev process，注意 a0 是 task_struct, 而要存储的地方是 thread_struct
    sd ra, 40(a0)
    sd sp, 48(a0)
    sd s0, 56(a0)
    sd s1, 64(a0)
    sd s2, 72(a0)
    sd s3, 80(a0)
    sd s4, 88(a0)
    sd s5, 96(a0)
    sd s6, 104(a0)
    sd s7, 112(a0)
    sd s8, 120(a0)
    sd s9, 128(a0)
    sd s10, 136(a0)
    sd s11, 144(a0)
    csrr t1, sepc
    sd t1, 152(a0)
    csrr t1, sstatus
    sd t1, 160(a0)
    csrr t1, sscratch
    sd t1, 168(a0)
    csrr t1, satp
    sd t1, 176(a0)
    
    # restore state from next process
    ld ra, 40(a1)
    ld sp, 48(a1)
    ld s0, 56(a1)
    ld s1, 64(a1)
    ld s2, 72(a1)
    ld s3, 80(a1)
    ld s4, 88(a1)
    ld s5, 96(a1)
    ld s6, 104(a1)
    ld s7, 112(a1)
    ld s8, 120(a1)
    ld s9, 128(a1)
    ld s10, 136(a1)
    ld s11, 144(a1)
    ld t1, 152(a1)
    csrw sepc, t1
    ld t1, 160(a1)
    csrw sstatus, t1
    ld t1, 168(a1)
    csrw sscratch, t1
    ld t1, 176(a1)
    csrw satp, t1
    sfence.vma zero, zero

    # return from trap
    ret