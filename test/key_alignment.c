#include "chainhash.h"
#include <stdlib.h>
#include <stdio.h>
int main(void) { uint8_t *mem=(uint8_t *)malloc(sizeof(chainhash_key)+32),msg[4096]={0}; chainhash_key *k=(chainhash_key *)(mem+8); int b; uint64_t want; *k=chainhash_key_from_seed(111); want=chainhash_portable(k,msg,sizeof(msg)); for(b=0;b<=4;b++) if(chainhash_has_backend(b)&&chainhash_with_backend(k,msg,sizeof(msg),b)!=want) abort(); free(mem); puts("PASS key with only 8-byte alignment"); }
