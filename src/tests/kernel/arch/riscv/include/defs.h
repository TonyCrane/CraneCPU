#ifndef _DEFS_H
#define _DEFS_H

#include "types.h"

#define PHY_START 0x0000000080000000
#define PHY_SIZE  4 * 1024 * 1024
#define PHY_END   (PHY_START + PHY_SIZE)

#define PGSIZE 0x1000 // 4KB
#define PGROUNDUP(addr) ((addr + PGSIZE - 1) & (~(PGSIZE - 1))) // 向上取整
#define PGROUNDDOWN(addr) (addr & (~(PGSIZE - 1))) // 向下取整

// #define DEBUG 1

#define csr_read(csr)                       \
({                                          \
    register uint64 __v;                    \
                                            \
    asm volatile ("csrr %0, " #csr          \
                    : "=r"(__v));           \
    __v;                                    \
})

#define csr_write(csr, val)                         \
({                                                  \
    uint64 __v = (uint64)(val);                     \
    asm volatile ("csrw " #csr ", %0"               \
                    :                               \
                    : "r" (__v)                     \
                    : "memory");                    \
})

#define OPENSBI_SIZE (0x200000)

#define VM_START (0xffffffe000000000)
#define VM_END   (0xffffffff00000000)
#define VM_SIZE  (VM_END - VM_START)

#define PA2VA_OFFSET (VM_START - PHY_START)

#define USER_START (0x0000000000000000)
#define USER_END   (0x0000004000000000)

#define PTE_V 0x001
#define PTE_R 0x002
#define PTE_W 0x004
#define PTE_X 0x008
#define PTE_U 0x010
#define PTE_G 0x020
#define PTE_A 0x040
#define PTE_D 0x080

#define SYS_write 64
#define SYS_getpid 172
#define SYS_yield 124

#endif