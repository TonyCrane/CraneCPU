.extern start_kernel
.extern _traps
.extern mm_init
.extern task_init

    .section .text.init
    .globl _start
_start:
    lla sp, _stack
    call setup_vm
    call relocate
    call mm_init
    call setup_vm_final
    call task_init
    
    la x1, _traps
    csrrw x0, stvec, x1
    
    addi x1, x0, 0x2
    csrrs x0, sstatus, x1

    lla sp, _stack
    j start_kernel

relocate:

    li t1, 0xffffffe000000000; # VM_START
    li t2, 0x0000000080000000 ; # PHY_START
    sub t1, t1, t2 ; # t1 =  PA2VA_OFFSET = VM_START - PHY_START

    add ra, ra, t1 ; # set ra = ra + PA2VA_OFFSET
    add sp, sp, t1 ; # set sp = sp + PA2VA_OFFSET

    # set satp with _early_pgtbl
    lla t3,  early_pgtbl
    li t4, 0x0FFFFFFF
    and t3, t3, t4
    li t4, 0x80000000
    or t3, t3, t4
    srli t3, t3, 12; # PPN = PA >>  12
    li t1,  0x8000000000000000;
    or t3, t1, t3;
    csrw satp, t3;
    # flush tlb
    sfence.vma zero, zero

    ret

