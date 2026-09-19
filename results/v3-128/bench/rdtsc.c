#include "../chainhash128_v3.h"
#include "../chainhash3.h"
#include <stdio.h>
#include <stdlib.h>
#include <x86intrin.h>
static volatile uint64_t sink;
__attribute__((noinline)) static ch128v3_word call(const chainhash128_v3_key *k,const void *p,size_t n,int b,int school,int stride,int lazy) {
    return stride?chainhash128_v3_evaluate(k,p,n,stride,lazy,b,school):chainhash128_v3_with_backend(k,p,n,b,school);
}
static uint64_t ticks(void) { _mm_lfence(); return __rdtsc(); }
static double sample(const chainhash128_v3_key *k,const void *p,size_t n,int b,int school,int stride,int lazy,int reps) {
    uint64_t t; int i; ch128v3_word v; for(i=0;i<16;i++) { v=call(k,p,n,b,school,stride,lazy); sink^=v.lo; }
    t=ticks(); for(i=0;i<reps;i++) { v=call(k,p,n,b,school,stride,lazy); sink^=v.lo; } return (double)(ticks()-t)/reps;
}
static double med(double a,double b,double c) { if(a>b){double t=a;a=b;b=t;} if(b>c){double t=b;b=c;c=t;} return a>b?a:b; }
int main(int argc,char **argv) {
    chainhash128_v3_key k=chainhash128_v3_key_from_seed(42); unsigned char *p=(unsigned char *)malloc(262144+64); int b,school,a,i,small=argc>1; (void)argv;
    for(i=0;i<262144+64;i++) p[i]=(unsigned char)(i*137+17);
    puts("block,backend,school,stride,lazy,length,alignment,cycles,bytes_per_cycle");
    for(b=1;b<=3;b++) if(chainhash128_v3_has_backend(b)) for(school=0;school<2;school++) {
      for(a=0;a<8;a++) { double t=med(sample(&k,p+a,262144,b,school,0,1,512),sample(&k,p+a,262144,b,school,0,1,512),sample(&k,p+a,262144,b,school,0,1,512)); printf("%d,%d,%d,0,1,262144,%d,%.5f,%.6f\n",CHAINHASH128_V3_BLOCK_BYTES,b,school,a,t,262144/t); }
      if(small) for(i=1;i<=256;i++) { double t=med(sample(&k,p,i,b,school,0,1,2048),sample(&k,p,i,b,school,0,1,2048),sample(&k,p,i,b,school,0,1,2048)); printf("%d,%d,%d,0,1,%d,0,%.5f,%.6f\n",CHAINHASH128_V3_BLOCK_BYTES,b,school,i,t,i/t); }
    }
    if(small) for(i=1;i<=8;i*=2) for(a=0;a<2;a++) {double t=med(sample(&k,p,262144,3,0,i,a,128),sample(&k,p,262144,3,0,i,a,128),sample(&k,p,262144,3,0,i,a,128)); printf("%d,3,0,%d,%d,262144,0,%.5f,%.6f\n",CHAINHASH128_V3_BLOCK_BYTES,i,a,t,262144/t); }
    free(p); return 0;
}
