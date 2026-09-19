#include "chainhash128.h"
#include "oracle.h"
#include <stdio.h>
#ifdef NDEBUG
#error "Tests must be compiled with assertions enabled"
#endif
static uint64_t r=123;
static uint64_t rnd(void){r^=r<<13;r^=r>>7;r^=r<<17;return r;}
int main(void){uint8_t msg[160],bytes[ORACLE_IDEAL_BYTES];unsigned i,j;int b,z;uint64_t sum=0;
 for(i=0;i<20000;i++){size_t n=i%129;uint8_t *p=msg+i%32;chainhash128_key k;ch128_word expected;for(j=0;j<sizeof(msg);j++)msg[j]=(uint8_t)rnd();for(j=0;j<sizeof(bytes);j++)bytes[j]=(uint8_t)rnd();
  if(i%17==0)memset(bytes+16,0,16);
  if(i%19==0){memset(bytes+16,0,16);bytes[16]=1;}
  k=i&1?chainhash128_key_from_bytes(bytes):oracle_ideal_key(bytes);expected=oracle(&k,p,n);sum^=expected.lo^expected.hi;
  for(b=0;b<=4;b++)if(chainhash128_has_backend(b))for(z=0;z<2;z++)assert(ch128_equal(expected,chainhash128_with_backend(&k,p,n,b,z)));
 }
 printf("PASS 20000 short factorizations checksum=%016llx\n",(unsigned long long)sum);return 0;}
