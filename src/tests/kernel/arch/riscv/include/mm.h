#ifndef __MM_H__
#define __MM_H__

#include "types.h"

struct run {
    struct run *next;
};

void mm_init();

uint64 kalloc();
void kfree(uint64);

#endif