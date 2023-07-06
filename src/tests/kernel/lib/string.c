#include "string.h"

void *memset(void *dst, int c, uint64 n) {
    char *cdst = (char *)dst;
    if (((uint64)cdst % 8 == 0) && (n % 8 == 0) && (c == 0)) {
        for (uint64 i = 0; i < n / 8; ++i)
            *((uint64 *)cdst + i) = 0LL;
    } else {
        for (uint64 i = 0; i < n; ++i)
            cdst[i] = c;
    }

    return dst;
}

void *memcpy(void *dst, const void *src, uint64 n) {
    char *cdst = (char *)dst;
    const char *csrc = (const char *)src;
    if (((uint64)cdst % 8 == 0) && ((uint64)csrc % 8 == 0) && (n % 8 == 0)) {
        for (uint64 i = 0; i < n / 8; ++i)
            *((uint64 *)cdst + i) = *((uint64 *)csrc + i);
    } else {
        for (uint64 i = 0; i < n; ++i)
            cdst[i] = csrc[i];
    }
    return dst;
}

// void *memset(void *dst, int c, uint64 n) {
//     char *cdst = (char *)dst;
//     for (uint64 i = 0; i < n; ++i)
//         cdst[i] = c;

//     return dst;
// }
