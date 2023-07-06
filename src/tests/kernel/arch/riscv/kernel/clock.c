// #include "printk.h"
// #include "sbi.h"

// unsigned long TIMECLOCK = 10000000;

// unsigned long get_cycles() {
//     unsigned long time;
//     asm volatile("rdtime %0" : "=r"(time));
//     // printk("get_cycles() get time: %lx \n", time);
//     return time;
// }

// void clock_set_next_event() {
//     uint64 current_time = get_cycles();
//     uint64 next = current_time + TIMECLOCK;
//     // printk("clock_set_next_event() current_time: %lx, next: %lx \n", current_time, next);
//     sbi_ecall(SBI_SET_TIMER, 0, next, 0, 0, 0, 0, 0);
//     return;
// }