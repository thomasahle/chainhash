#include "chainhash3.h"
#include "chainhash.h" /* The versioned APIs can coexist in one translation unit. */
int main(void) { return !chainhash_v3_selftest(); }
