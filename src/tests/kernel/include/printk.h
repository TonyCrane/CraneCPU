#pragma once

#include "stddef.h"

int printk(const char *, ...);

#define Log(format, ...) \
    printk("\33[1;35m[%s,%d,%s] " format "\33[0m\n", \
        __FILE__, __LINE__, __func__, ## __VA_ARGS__)
