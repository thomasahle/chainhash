#include "chainhash128_v3.h"
#include "oracle.h"
#include <stdio.h>
int main(void){uint8_t p[4097];unsigned i;size_t lengths[]={0,1,17,128,129,2048,2049,4096,4097};chainhash128_v3_key k=chainhash128_v3_key_from_seed(123);for(i=0;i<sizeof(p);i++)p[i]=(uint8_t)(i*137+29);for(i=0;i<sizeof(lengths)/sizeof(*lengths);i++){ch128v3_word v=oracle(&k,p,lengths[i]);printf("%d,%zu,%016llx%016llx\n",CHAINHASH128_V3_BLOCK_BYTES,lengths[i],(unsigned long long)v.hi,(unsigned long long)v.lo);}return 0;}
