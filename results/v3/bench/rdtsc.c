#include "../chainhash_v3.h"
#include "../chainhash_x86.h"
#include "../chainhash_shipped.h"
#include <stdio.h>
#include <stdlib.h>
#include <x86intrin.h>
static chainhash_v3_key v3;
static chainhash_x86_key oldx;
static chainhash_key shipped;
__attribute__((noinline)) uint64_t v3z(const void *p,size_t n) { return chainhash_v3_with_backend(&v3,p,n,3); }
__attribute__((noinline)) uint64_t v3x(const void *p,size_t n) { return chainhash_v3_with_backend(&v3,p,n,1); }
__attribute__((noinline)) uint64_t v3y(const void *p,size_t n) { return chainhash_v3_with_backend(&v3,p,n,2); }
__attribute__((noinline)) uint64_t old(const void *p,size_t n) { return chainhash_x86(&oldx,p,n); }
__attribute__((noinline)) uint64_t ship(const void *p,size_t n) { return chainhash(&shipped,p,n); }
static uint64_t tick(void) { _mm_lfence(); return __rdtsc(); }
static volatile uint64_t sink;
static double sample(uint64_t (*f)(const void *,size_t),const void *p,size_t n,unsigned reps) {
    unsigned r; uint64_t v=0,t; for(r=0;r<16;r++) v^=f(p,n); t=tick(); for(r=0;r<reps;r++) v^=f(p,n); t=tick()-t; sink=v; return (double)t/reps;
}
static double med(double a,double b,double c) { return a>b ? (b>c?b:(a>c?c:a)) : (a>c?a:(b>c?c:b)); }
int main(void) {
    uint8_t *data=(uint8_t *)malloc(262144+64); unsigned i,a,h; const char *names[]={"v3-zmm","x86-shipped","shipped-256","v3-xmm","v3-ymm"}; uint64_t (*f[])(const void *,size_t)={v3z,old,ship,v3x,v3y};
    v3=chainhash_v3_key_from_seed(123); oldx=chainhash_x86_key_from_seed(123); shipped=chainhash_key_from_splitmix64_legacy(123);
    for(i=0;i<262144+64;i++) data[i]=(uint8_t)(i*17);
    puts("name,bytes,alignment,median_cycles,bytes_per_cycle");
    for(h=0;h<5;h++) for(a=0;a<8;a++) { double c[3]; for(i=0;i<3;i++) c[i]=sample(f[h],data+a,262144,512); double m=med(c[0],c[1],c[2]); printf("%s,262144,%u,%.3f,%.6f\n",names[h],a,m,262144/m); }
    for(h=0;h<3;h++) for(a=1;a<=256;a++) { double c[3]; for(i=0;i<3;i++) c[i]=sample(f[h],data+(a%8),a,2048); double m=med(c[0],c[1],c[2]); printf("%s,%u,%u,%.3f,%.6f\n",names[h],a,a%8,m,a/m); }
    free(data); return 0;
}
