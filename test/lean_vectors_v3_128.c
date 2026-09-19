#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include "chainhash128_v3.h"
int main(void) {
 if(!chainhash128_v3_selftest()) { fprintf(stderr,"selftest FAILED\n"); return 6; }
 fprintf(stderr,"selftest PASS; checked C backends:");
 for(int b=0;b<=4;b++) if(chainhash128_v3_has_backend(b)) fprintf(stderr," %d",b);
 fprintf(stderr,"; strides 1..8; eager and lazy; schoolbook and Karatsuba; dispatched one-shot\n");
 unsigned model; size_t n;
 while(scanf("%u %zu",&model,&n)==2) {
  ch128v3_word w[39]; uint8_t b[128]; size_t count=model?8:39;
  for(size_t i=0;i<count;i++) { uint64_t lo,hi; if(scanf("%"SCNu64" %"SCNu64,&lo,&hi)!=2) return 2; w[i]=ch128v3_make(lo,hi); }
  chainhash128_v3_key k;
  if(model) { for(size_t i=0;i<8;i++) chainhash128_v3_store(b+16*i,w[i]); k=chainhash128_v3_key_from_bytes(b); }
  else k=chainhash128_v3_key_from_words(w);
  uint8_t *m=malloc(n+1); for(size_t i=0;i<n;i++){ unsigned x; if(scanf("%u",&x)!=1)return 3; m[i]=(uint8_t)x; }
  ch128v3_word h=chainhash128_v3_portable(&k,m,n);
  for(int backend=0;backend<=4;backend++) if(chainhash128_v3_has_backend(backend))
   for(unsigned stride=1;stride<=8;stride++) for(int lazy=0;lazy<=1;lazy++) for(int school=0;school<=1;school++)
    if(!ch128v3_equal(chainhash128_v3_evaluate(&k,m,n,stride,lazy,backend,school),h)) return 4;
  for(int backend=0;backend<=4;backend++) if(chainhash128_v3_has_backend(backend)) for(int school=0;school<=1;school++)
   if(!ch128v3_equal(chainhash128_v3_with_backend(&k,m,n,backend,school),h)) return 7;
  if(!ch128v3_equal(chainhash128_v3(&k,m,n),h))return 5;
  printf("%"PRIu64" %"PRIu64"\n",h.lo,h.hi); free(m);
 }
 return 0;
}
