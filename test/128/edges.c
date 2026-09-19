#include "chainhash128.h"
#include "oracle.h"
#include <stdio.h>
#ifdef NDEBUG
#error "Tests must be compiled with assertions enabled"
#endif
int main(void){uint8_t p[8193];ch128_word w[CH128_W+7];unsigned i,mode;static const size_t lens[]={0,1,15,16,17,31,32,33,63,64,65,127,128,129,255,256,257,511,512,513,1023,1024,1025,2047,2048,2049,4095,4096,4097,8191,8192,8193};int b,z,k,l;
 for(i=0;i<sizeof(p);i++)p[i]=(uint8_t)(i*53+17);
 for(mode=0;mode<4;mode++){chainhash128_key key;for(i=0;i<CH128_W+7;i++)w[i]=mode==0?ch128_make(0,0):mode==1?ch128_make(1,0):mode==2?ch128_make(UINT64_MAX,UINT64_MAX):ch128_make(0,UINT64_C(1)<<63);key=chainhash128_key_from_words(w);
  for(i=0;i<sizeof(lens)/sizeof(*lens);i++){ch128_word ref=oracle(&key,p,lens[i]);for(b=0;b<=4;b++)if(chainhash128_has_backend(b))for(z=0;z<2;z++){assert(ch128_equal(ref,chainhash128_with_backend(&key,p,lens[i],b,z)));for(k=1;k<=8;k*=2)for(l=0;l<2;l++)assert(ch128_equal(ref,chainhash128_evaluate(&key,p,lens[i],k,l,b,z)));}}
 }puts("PASS zero/one/all-ones/high-bit keys, tails, and all evaluation choices");return 0;}
