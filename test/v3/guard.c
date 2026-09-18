#define _GNU_SOURCE
#include "chainhash3.h"
#include <sys/mman.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
int main(void) {
    size_t page=(size_t)sysconf(_SC_PAGESIZE),n; int b; uint8_t *base=(uint8_t *)mmap(NULL,page*3,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANON,-1,0);
    chainhash_v3_key key=chainhash_v3_key_from_seed(876);
    if(base==MAP_FAILED || mprotect(base+page*2,page,PROT_NONE)) return 2;
    memset(base,137,page*2);
    for(n=0;n<=4096;n++) { uint8_t *p=base+2*page-n; uint64_t h=chainhash_v3_portable(&key,p,n); for(b=0;b<=4;b++) if(chainhash_v3_has_backend(b) && chainhash_v3_with_backend(&key,p,n,b)!=h) abort(); }
    if(chainhash_v3(&key,NULL,0)!=chainhash_v3_portable(&key,NULL,0)) abort();
    puts("PASS guarded tails 0..4096; NULL empty"); munmap(base,page*3); return 0;
}
