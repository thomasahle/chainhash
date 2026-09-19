#define _GNU_SOURCE
#include "chainhash128_v3.h"
#include <sys/mman.h>
#include <unistd.h>
#include <stdio.h>
int main(void){size_t page=(size_t)sysconf(_SC_PAGESIZE),size=((CH128V3_REGION+page)/page+1)*page,n;uint8_t *p=(uint8_t *)mmap(NULL,size+page,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANON,-1,0);chainhash128_v3_key k=chainhash128_v3_key_from_seed(17);int b,z;assert(p!=MAP_FAILED);assert(!mprotect(p+size,page,PROT_NONE));
 for(n=0;n<size;n++)p[n]=(uint8_t)(137*n+17);
 for(n=0;n<=CH128V3_REGION+1;n++){ch128v3_word ref=chainhash128_v3_portable(&k,p+size-n,n);for(b=0;b<=4;b++)if(chainhash128_v3_has_backend(b))for(z=0;z<2;z++)assert(ch128v3_equal(ref,chainhash128_v3_with_backend(&k,p+size-n,n,b,z)));}
 assert(ch128v3_equal(chainhash128_v3(&k,NULL,0),chainhash128_v3_portable(&k,NULL,0)));assert(!munmap(p,size+page));puts("PASS protected-page tails and NULL empty");return 0;}

#ifdef NDEBUG
#error "Tests must be compiled with assertions enabled"
#endif
