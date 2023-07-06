//arch/riscv/kernel/proc.c

#include "printk.h"
#include "mm.h"
#include "proc.h"
#include "rand.h"
#include "defs.h"

extern void do_timer(void);
extern void schedule(void);
extern void __dummy();
extern void __switch_to(struct task_struct* prev, struct task_struct* next);
extern void set_priority();

struct task_struct* idle;           // idle process
struct task_struct* current;        // 指向当前运行线程的 `task_struct`
struct task_struct* task[NR_TASKS]; // 线程数组，所有的线程都保存在此

extern unsigned long swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));
extern void create_mapping(uint64 *root_pgtbl, uint64 va, uint64 pa, uint64 sz, int perm);
extern char uapp_start[], uapp_end[];

void task_init() {
    Log("proc_init start");

    idle = (struct task_struct*)kalloc();
    idle->state = TASK_RUNNING;
    idle->counter = 0;
    idle->priority = 0;
    idle->pid = 0;
    idle->thread.sp = (uint64)idle + PGSIZE;
    current = idle;
    task[0] = idle;

    for (int i = 1; i < NR_TASKS; i++) {
        task[i] = (struct task_struct*)kalloc();
        task[i]->state = TASK_RUNNING;
        task[i]->counter = 0;
        task[i]->priority = rand();
        task[i]->pid = i;
    }

    for (int i = 1; i < NR_TASKS; i++) {
        task[i]->thread.ra = (uint64)__dummy;
        task[i]->thread.sp = (uint64)task[i] + PGSIZE;
        task[i]->kernel_sp = (uint64)task[i] + PGSIZE;
        task[i]->user_sp = kalloc();
        uint64 *pgtbl = (uint64*)kalloc();
        memcpy(pgtbl, swapper_pg_dir, PGSIZE);
        uint64 va = USER_START;
        uint64 pa = (uint64)(uapp_start) - PA2VA_OFFSET;
        create_mapping(pgtbl, va, pa, uapp_end - uapp_start, PTE_R | PTE_W | PTE_X | PTE_U | PTE_V);
        va = USER_END - PGSIZE;
        pa = (uint64)(task[i]->user_sp) - PA2VA_OFFSET;
        create_mapping(pgtbl, va, pa, PGSIZE, PTE_R | PTE_W | PTE_U | PTE_V);
        uint64 satp = csr_read(satp);
        satp = (satp >> 44) << 44;
        satp |= ((uint64)(pgtbl) - PA2VA_OFFSET) >> 12;
        task[i]->satp = satp;

        task[i]->thread.sepc = USER_START;
        uint64 sstatus = csr_read(sstatus);
        sstatus &= ~(1 << 8);
        sstatus |= (1 << 5);
        sstatus |= (1 << 18);
        task[i]->thread.sstatus = sstatus;
        task[i]->thread.sscratch = USER_END;
    }
    Log("proc_init done");

    set_priority();

    return;
}

void dummy() {
    uint64 MOD = 1000000007;
    uint64 auto_inc_local_var = 0;
    int last_counter = -1; // 记录上一个counter
    int last_last_counter = -1; // 记录上上个counter
    while(1) {
        if (last_counter == -1 || current->counter != last_counter) {
            last_last_counter = last_counter;
            last_counter = current->counter;
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
            printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid, auto_inc_local_var); 
            printk("Thread space begin at %lx\n", current);
        } else if((last_last_counter == 0 || last_last_counter == -1) && last_counter == 1) { // counter恒为1的情况
            // 这里比较 tricky，不要求理解。
            last_counter = 0; 
            current->counter = 0;
        }
        #ifdef DEBUG
        for (int i = 0; i < 100000000; i++);
        #else
        for (int i = 0; i < 1000; ++i);
        #endif
        do_timer();
    }
}

// 更新当前线程的 counter，查看是否需要进行 schedule
void do_timer(void) {
    if (current->counter > 0) {
        current->counter--;
    }else{
        schedule();
        for (int i = 0; i < NR_TASKS; i++) {
            if (current == task[i]) {
                asm("addi gp, %0, 0x100" :: "r"(i));
            }
        }
    }
}

// 选择优先级最高的线程进行调度
void schedule(void) {
    uint64 min_priority = -1;
    int min_priority_index = -1;
    int all_zero = 1;
    for (int i = 1; i < NR_TASKS; i++) { // 遍历 task 数组
        if (task[i]->counter > 0 && task[i]->priority < min_priority) {
            all_zero = 0;
            min_priority = task[i]->priority;
            min_priority_index = i;
        }
    }
    if (all_zero) {
        for (int i = 1; i < NR_TASKS; i++) {
            task[i]->counter = task[i]->priority;
        }
        for (int i = 1; i < NR_TASKS; i++) {
            if (i == 1) printk("\n");
            Log("SET [PID = %lu, PRIORITY = %lu]", task[i]->pid, task[i]->priority, task[i]->counter);
            if (task[i]->priority < min_priority) {
                min_priority = task[i]->priority;
                min_priority_index = i;
            }
        }
    }else{
    }
    switch_to(task[min_priority_index]);
}

// 切换到 next 线程
void switch_to(struct task_struct* next) {
    Log("switch to [PID = %lu, PRIORITY = %lu]", next->pid, next->priority, next->counter);
    if (current->pid != next->pid) {
        //copy
        struct task_struct* temp = current;
        current = next;
        __switch_to(temp, next);
    }
    return;
}

void set_priority() {
    task[1]->priority = 1;
    task[2]->priority = 2;
    task[3]->priority = 3;
    Log("set_priority done");
}