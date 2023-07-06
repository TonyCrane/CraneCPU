#include "syscall.h"
#include "stdio.h"


static inline long getpid() {
    long ret;
    asm volatile ("li a7, %1\n"
                  "ecall\n"
                  "mv %0, a0\n"
                : "+r" (ret) 
                : "i" (SYS_GETPID));
    return ret;
}

static inline long yield() {
    asm volatile ("li a7, %0\n"
                  "ecall\n"
                : : "i" (SYS_YIELD));
}

int main() {
    register unsigned long current_sp __asm__("sp");
    while (1) {
        printf("[U-MODE] pid: %ld, sp is %lx\n", getpid(), current_sp);
    #ifdef DEBUG
        for (unsigned int i = 0; i < 100000000; i++);
    #else
        for (unsigned int i = 0; i < 1000; i++);
    #endif
        yield();
    }

    return 0;
}
