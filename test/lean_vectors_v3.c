#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include "chainhash3.h"
int main(void) {
 fprintf(stderr,"Checked C backends:");
 for(int b=0;b<=4;b++) if(chainhash_v3_has_backend(b)) fprintf(stderr," %d",b);
 fprintf(stderr,"; strides 1..8; eager and lazy; dispatched one-shot\n");
 unsigned model; size_t n;
 while(scanf("%u %zu",&model,&n)==2) {
  uint64_t w[39]={0}; uint8_t b[64]; size_t count=model?8:39;
  for(size_t i=0;i<count;i++) if(scanf("%"SCNu64,&w[i])!=1) return 2;
  chainhash_v3_key k;
  if(model) { for(size_t i=0;i<8;i++) for(size_t j=0;j<8;j++) b[8*i+j]=(uint8_t)(w[i]>>(8*j)); k=chainhash_v3_key_from_bytes(b); }
  else k=chainhash_v3_key_from_words(w);
  uint8_t *m=malloc(n+1); for(size_t i=0;i<n;i++){ unsigned x; if(scanf("%u",&x)!=1)return 3; m[i]=(uint8_t)x; }
  uint64_t h=chainhash_v3_portable(&k,m,n);
  for(int backend=0;backend<=4;backend++) if(chainhash_v3_has_backend(backend))
   for(unsigned stride=1;stride<=8;stride++) for(int lazy=0;lazy<=1;lazy++)
    if(chainhash_v3_evaluate(&k,m,n,stride,lazy,backend)!=h) return 4;
  if(chainhash_v3(&k,m,n)!=h)return 5;
  printf("%"PRIu64"\n",h); free(m);
 }
 return 0;
}
