/* Throughput of the dispatched one-shot entry points on hot inputs.
 * Reports bytes per nanosecond (GB/s) from the monotonic clock and, on
 * x86-64, bytes per TSC reference tick. ARM has no unprivileged cycle
 * counter, so no cycle figure is printed there. Key setup is not timed. */
#define _POSIX_C_SOURCE 199309L
#include "chainhash.h"
#include "chainhash128.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#if defined(__x86_64__)
#include <x86intrin.h>
static uint64_t ticks(void) { return __rdtsc(); }
#else
static uint64_t ticks(void) { return 0; }
#endif
static double now(void) { struct timespec t; clock_gettime(CLOCK_MONOTONIC,&t); return (double)t.tv_sec*1e9+(double)t.tv_nsec; }
static chainhash_key key64; static chainhash128_key key128;
static uint64_t run64(const uint8_t *p,size_t n) { return chainhash(&key64,p,n); }
static uint64_t run128(const uint8_t *p,size_t n) { ch128_word h=chainhash128(&key128,p,n); return h.lo^h.hi; }
int main(void) {
    static const size_t sizes[]={64,256,1024,4096,65536,1048576};
    static const char *names[]={"ChainHash","ChainHash-128"};
    uint64_t (*fn[])(const uint8_t *,size_t)={run64,run128};
    size_t total=1<<26,i,s; unsigned f,trial; uint64_t sink=0;
    uint8_t *buf=(uint8_t *)malloc(sizes[5]); if(!buf) return 1;
    for(i=0;i<sizes[5];i++) buf[i]=(uint8_t)(i*131+17);
    key64=chainhash_key_from_seed(123); key128=chainhash128_key_from_seed(123);
    printf("backends: chainhash=%d chainhash128=%d (0 portable, 1 XMM, 2 YMM, 3 ZMM, 4 NEON)\n",chainhash_backend(),chainhash128_backend());
    printf("%-14s %10s %10s %10s\n","function","bytes","GB/s","B/tick");
    for(f=0;f<2;f++) for(s=0;s<6;s++) {
        size_t n=sizes[s],calls=total/n; double best=0; uint64_t bestticks=UINT64_MAX;
        for(trial=0;trial<5;trial++) {
            double t0=now(); uint64_t c0=ticks(); size_t c;
            for(c=0;c<calls;c++) { sink+=fn[f](buf,n); __asm__ __volatile__("":::"memory"); }
            { uint64_t c1=ticks(); double t1=now(); double gbs=(double)(calls*n)/(t1-t0); if(gbs>best) best=gbs; if(c1-c0<bestticks) bestticks=c1-c0; }
        }
        printf("%-14s %10zu %10.2f ",names[f],n,best);
        if(ticks()) printf("%10.2f\n",(double)(calls*n)/(double)bestticks); else printf("%10s\n","-");
    }
    free(buf); return (int)(sink==0);
}
