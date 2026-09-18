#include "chainhash.h"
#include <stdio.h>
int main(void) {
    uint8_t bytes[328] = {0};
    chainhash_key key = chainhash_key_from_328_bytes(bytes);
    if (sizeof(key) != 328 || chainhash(&key,NULL,0) != chainhash_portable(&key,NULL,0)) return 1;
    key = chainhash_key_from_splitmix64_legacy(0);
    if (chainhash(&key,"hello",5) != chainhash_portable(&key,"hello",5)) return 1;
    puts("PASS C99 API");
    return 0;
}
