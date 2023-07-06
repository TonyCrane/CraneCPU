#include "printk.h"
#include "clock.h"
#include "proc.h"
#include "defs.h"

extern struct task_struct* current;        
extern struct task_struct* task[NR_TASKS];
extern void schedule();

struct pt_regs {
    uint64 x[32];
    uint64 sepc;
};

void syscall(struct pt_regs* regs) {
    if (regs->x[17] == SYS_write) {
        if (regs->x[10] == 1) {
            char* buf = (char*)regs->x[11];
            for (int i = 0; i < regs->x[12]; i++) {
                printk("%c", buf[i]);
            }
            regs->x[10] = regs->x[12];
        } else {
            printk("not support fd = %d\n", regs->x[10]);
            regs->x[10] = -1;
        }
    } else if (regs->x[17] == SYS_getpid) {
        regs->x[10] = current->pid;
    } else if (regs->x[17] == SYS_yield) {
        current->counter = 0;
        schedule();
    } else {
        printk("not support syscall id = %d\n", regs->x[17]);
    }
    regs->sepc += 4;
}

void trap_handler(unsigned long scause, unsigned long sepc, struct pt_regs* regs) {
    if ((scause >> 63) && (scause & 0x7FFFFFFFFFFFFFFF) == 5) {
        Log("Supervisor Mode Timer Interrupt\n");
    } else {
        if (scause == 8) {
            syscall(regs);
            return;
        }
    }
    Log("Unhandled trap: scause: %lx, sepc: %lx \n", scause, sepc);
}