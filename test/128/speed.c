/* Length profile derived from test/speed.c. Compile with -O3 -DNDEBUG and
 * the same ISA flags as the library. Optional argument: backend 1/2/3/4.
 * Three samples per length, after warmup; report their median and flag
 * (max-min)/median > 15%. Key setup is outside the timed region.
 * Throughput of the one-shot entry point on hot inputs.
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
static int backend;
static uint64_t run128(const uint8_t *p,size_t n) { ch128_word h=chainhash128_with_backend(&key128,p,n,backend,backend==1 || backend==3 || backend==4); return h.lo^h.hi; }
int main(int argc,char **argv) {
    static const size_t sizes[]={16,31,64,128,256,512,1024,2048,4095,4096,8192,65536};
    uint64_t (*fn[])(const uint8_t *,size_t)={run64,run128};
    size_t total=1<<25,i,s; unsigned f,trial; uint64_t sink=0;
    uint8_t *buf=(uint8_t *)malloc(sizes[11]); if(!buf) return 1;
    for(i=0;i<sizes[11];i++) buf[i]=(uint8_t)(i*131+17);
    backend=argc>1?atoi(argv[1]):chainhash128_backend(); if(!chainhash128_has_backend(backend)) return 2;
    key64=chainhash_key_from_seed(123); key128=chainhash128_key_from_seed(123);
    { double until=now()+3e7; while(now()<until) {sink+=run128(buf,1024); __asm__ __volatile__("":::"memory");} }
    printf("backends: chainhash=%d chainhash128=%d (0 portable, 1 XMM, 2 YMM, 3 ZMM, 4 NEON)\n",chainhash_backend(),backend);
    for(f=1;f<2;f++) for(s=0;s<12;s++) {
        size_t n=sizes[s],calls=total/n;
        for(trial=0;trial<3;trial++) {
            double t0=now(); uint64_t c0=ticks(); size_t c;
            for(c=0;c<calls;c++) { sink+=fn[f](buf,n); __asm__ __volatile__("":::"memory"); }
            { uint64_t c1=ticks(); double t1=now(); double gbs=(double)(calls*n)/(t1-t0); printf("sample backend=%d bytes=%zu trial=%u GBps=%.6f ns=%.6f ticks=%.6f\n",backend,n,trial+1,gbs,(t1-t0)/calls,(double)(c1-c0)/calls); }
        }

    }
    free(buf); return (int)(sink==0);
}
