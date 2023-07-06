// arch/riscv/kernel/vm.c

extern unsigned long _stext;
extern unsigned long _srodata;
extern unsigned long _sdata;
extern unsigned long _sbsss;

#include "defs.h"
#include <string.h>
#include <stddef.h>
#include "mm.h"
#include "printk.h"
#include "types.h"

/* early_pgtbl: 用于 setup_vm 进行 1GB 的 映射。 */
unsigned long early_pgtbl[512] __attribute__((__aligned__(0x1000)));

void setup_vm(void) {
    unsigned long* phy_early_pgtbl = ((unsigned long)early_pgtbl & 0x3FFFFFFF) + PHY_START;
    phy_early_pgtbl[384] = ((unsigned long)(0x1 << 29)) | 0x000000000000000f;
    phy_early_pgtbl[2] = ((unsigned long)(0x1 << 29)) | 0x000000000000000f;
}

unsigned long *get_the_PTE_addr(unsigned long *root, unsigned long va) {
    unsigned long *cur_ptes_page_addr = root;
    unsigned long *cur_pte_addr;
    for (int level = 2; level > 0; level--) {
        if (level == 2)
            cur_pte_addr = &cur_ptes_page_addr[(va >> 30) & 0x1ff];
        else if (level == 1)
            cur_pte_addr = &cur_ptes_page_addr[(va >> 21) & 0x1ff];
        if ((*cur_pte_addr) & 0x1)
            cur_ptes_page_addr = (unsigned long *)((((*cur_pte_addr) >> 10) << 12) + PA2VA_OFFSET);
        else {
            if ((cur_ptes_page_addr = (uint64 *)kalloc()) == NULL) {
                Log("No space!");
                return NULL;
            }
            *cur_pte_addr = ((unsigned long)(*(cur_pte_addr)) & 0xffc0000000000000) | ((unsigned long)(((unsigned long)cur_ptes_page_addr - PA2VA_OFFSET) >> 12) << 10) | ((unsigned long)(0) | (unsigned long)(1));
        }
    }
    return &cur_ptes_page_addr[(va >> 12) & 0x1ff];
}

/* 创建多级页表映射关系 */
void create_mapping(uint64 *pgtbl, uint64 va, uint64 pa, uint64 sz, int perm) {
    Log("root: %lx, [%lx, %lx) -> [%lx, %lx), perm: %x", pgtbl, pa, pa+sz, va, va+sz, perm);
    unsigned long va_now = va;
    unsigned long pa_now = pa;
    for (va_now = va; va_now < va + sz; pa_now += PGSIZE, va_now += PGSIZE) {
        unsigned long *PTE_addr = get_the_PTE_addr(pgtbl, va_now);
        *PTE_addr = ((unsigned long)(*(PTE_addr)) & 0xffc0000000000000) | ((unsigned long)(((unsigned long)pa_now) >> 12) << 10) | ((unsigned long)(perm) | (unsigned long)(1));
    }
}

unsigned long swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

void setup_vm_final(void) {
    memset(swapper_pg_dir, 0x0, PGSIZE);
    unsigned long *pgtbl = swapper_pg_dir;

    // No OpenSBI mapping required
    unsigned long va = VM_START + OPENSBI_SIZE, pa = PHY_START + OPENSBI_SIZE;
    // mapping kernel text X|-|R|V
    unsigned long text_length = (unsigned long)(&(_srodata)) - (unsigned long)(&(_stext));
    create_mapping(pgtbl, va, pa, text_length, 0b1011);
    va += text_length;
    pa += text_length;

    // mapping kernel rodata -|-|R|V
    unsigned long rodata_length = (unsigned long)(&(_sdata)) - (unsigned long)(&(_srodata));
    create_mapping(pgtbl, va, pa, rodata_length, 0b0011);

    va += rodata_length;
    pa += rodata_length;

    // mapping other memory -|W|R|V
    unsigned long left_length = PHY_SIZE - rodata_length - text_length - OPENSBI_SIZE; // 128 MB - rodata - text
    create_mapping(pgtbl, va, pa, left_length, 0b0111);

    // set satp with swapper_pg_dir
    unsigned long temp = ((unsigned long)pgtbl) - PA2VA_OFFSET;
    temp = ((unsigned long)temp) >> 12;
    temp = (0x000fffffffffff & temp) | 0x8000000000000000;

    csr_write(satp, temp);
    Log("set satp to %lx", temp);
    // flush TLB
    asm volatile("sfence.vma zero, zero");

    return;
}
