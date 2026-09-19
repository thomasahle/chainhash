#include "chainhash.h"
#include "chainhash128.h" /* Both headers coexist in one translation unit. */
int main(void) { return !chainhash_selftest(); }
