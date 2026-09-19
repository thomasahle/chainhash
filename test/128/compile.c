#include "chainhash128.h"
#include "chainhash.h" /* Both headers coexist in one translation unit. */
#include <stdio.h>
int main(void) {
    int ok = chainhash128_selftest();
    printf("backend=%d selftest=%d block=%d\n", chainhash128_backend(), ok, CHAINHASH128_BLOCK_BYTES);
    return !ok;
}
