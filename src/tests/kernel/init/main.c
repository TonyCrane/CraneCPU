#include "printk.h"
#include "types.h"
#include "sbi.h"

extern void test();
extern void schedule();

int start_kernel(uint64 input) {

    printk("2023 ZJU Computer System III\n");

    schedule();

    test(); // DO NOT DELETE !!!

	return 0;
}
