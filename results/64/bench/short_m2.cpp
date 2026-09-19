#include "Platform.h"
#include "Timing.h"
#include "chainhash.h"
#include "../chainhash_shipped.h"
#include <cstdio>
double cycle_timer_mult=1;
static volatile uint64_t sink;
static chainhash_key k;
static chainhash_key old;
__attribute__((noinline)) static uint64_t hash(const void *p,size_t n) { return chainhash(&k,p,n); }
__attribute__((noinline)) static uint64_t shipped(const void *p,size_t n) { return chainhash(&old,p,n); }
static double med(double a,double b,double c) { return a>b?(b>c?b:(a>c?c:a)):(a>c?a:(b>c?c:b)); }
int main(void) { uint8_t m[320];unsigned i,n,h,r; uint64_t (*fn[])(const void *,size_t)={hash,shipped}; const char *names[]={"chainhash-v3","shipped-256"}; /* row labels of the archived out/M2Pro/short.run*.csv: ChainHash and the control */ k=chainhash_key_from_seed(123);old=chainhash_key_from_splitmix64_legacy(123);for(i=0;i<320;i++) m[i]=(uint8_t)i;
 cycle_timer_init();printf("# calibrated_cycles_per_ns=%.9f\n",cycle_timer_mult);puts("name,bytes,median_cycles,median_ns");
 for(h=0;h<2;h++) for(n=1;n<=256;n++) {double c[3];for(r=0;r<3;r++) {uint64_t sum=0,t=cycle_timer_start();for(i=0;i<10000;i++) {sum^=fn[h](m+(i&7),n);asm volatile("" : "+r"(sum));}c[r]=(cycle_timer_end()-t)/10000.0;sink=sum;}double v=med(c[0],c[1],c[2]);printf("%s,%u,%.6f,%.6f\n",names[h],n,v,v/cycle_timer_mult);}
}
