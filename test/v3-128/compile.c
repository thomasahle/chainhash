#include "chainhash128_v3.h"
#include "chainhash3.h"  /* The three versioned APIs can coexist in one translation unit. */
#include "chainhash.h"
#include <stdio.h>
int main(void) {
    int ok = chainhash128_v3_selftest();
    printf("backend=%d selftest=%d block=%d\n", chainhash128_v3_backend(), ok, CHAINHASH128_V3_BLOCK_BYTES);
    return !ok;
}
