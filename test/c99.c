#include "chainhash.h"
#include <stdio.h>
int main(void) {
    uint8_t bytes[CHAINHASH_RANDOM_BYTES] = {0};
    chainhash_key key = chainhash_key_from_bytes(bytes);
    if (sizeof(key) != 328 || chainhash(&key,NULL,0) != chainhash_portable(&key,NULL,0)) return 1;
    if (chainhash(&key,"hello",5) != chainhash_portable(&key,"hello",5)) return 1;
    puts("PASS C99 API");
    return 0;
}
