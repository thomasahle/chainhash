#define _POSIX_C_SOURCE 200809L
#include "chainhash.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#if defined(__x86_64__)
#include <x86intrin.h>
#endif
static volatile uint64_t sink;
static uint64_t ns(void) {
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC,&t);
    return (uint64_t)t.tv_sec*UINT64_C(1000000000)+(uint64_t)t.tv_nsec;
}
#if defined(__aarch64__)
/* 64 dependent adds per iteration; best of five short calibrations.
 * This estimates cycles/ns, it does NOT read a hardware cycle counter. */
static double calibrate(void) {
    uint64_t best=UINT64_MAX;
    unsigned trial;
    for(trial=0;trial<5;++trial) {
        uint64_t x=0,start=ns(),elapsed;
        unsigned i;
        for(i=0;i<100000;++i)
            __asm__ volatile(".rept 64\n\tadd %0, %0, #1\n\t.endr" : "+r"(x));
        elapsed=ns()-start;
        sink=x;
        if(elapsed<best) best=elapsed;
    }
    return 6400000.0/(double)best;
}
#endif
static uint64_t ticks(void) {
#if defined(__x86_64__)
    unsigned aux;
    uint64_t t;
    _mm_lfence(); t=__rdtscp(&aux); _mm_lfence(); return t;
#else
    return ns();
#endif
}
#if defined(__GNUC__) || defined(__clang__)
__attribute__((noinline))
#endif
static uint64_t run_hash(const chainhash_key *k,const uint8_t *p,size_t n) {
    return chainhash(k,p,n);
}
int main(void) {
    const size_t lengths[]={256,4096,262144};
    uint8_t *data=(uint8_t *)malloc(262144);
    chainhash_key key=chainhash_key_from_splitmix64_legacy(42);
    double scale=1.0;
    unsigned si;
    size_t i;
    if(!data) return 1;
    for(i=0;i<262144;++i) data[i]=(uint8_t)(i*131+17);
    printf("backend=%s; 5 trials, 16 MiB/trial/size; hot reused buffer; key setup excluded\n",CHAINHASH_BACKEND);
#if defined(__aarch64__)
    scale=calibrate();
    printf("cycle basis: estimated ARM cycles, dependent-add calibration %.6f GHz\n",scale);
#elif defined(__x86_64__)
    puts("cycle basis: invariant TSC reference cycles (not variable-frequency core cycles)");
#else
    puts("cycle basis: nanoseconds; no cycle estimate on this architecture");
#endif
    puts("bytes,bytes_per_cycle,GB_per_second,median_ns_per_hash");
    for(si=0;si<3;++si) {
        size_t n=lengths[si],reps=(16*1024*1024)/n;
        double cp[5],nt[5];
        unsigned trial,j;
        for(i=0;i<32;++i) sink=run_hash(&key,data,n);
        for(trial=0;trial<5;++trial) {
            uint64_t sum=0,start_ns=ns(),start=ticks(),end,elapsed;
            for(i=0;i<reps;++i) {
                /* Force each call to observe memory; prevents hoisting. */
                __asm__ volatile("" ::: "memory");
                sum ^= run_hash(&key,data,n);
            }
            end=ticks(); elapsed=ns()-start_ns; sink=sum;
            cp[trial]=(double)(end-start)*scale/(double)reps;
            nt[trial]=(double)elapsed/(double)reps;
        }
        for(trial=0;trial<5;++trial) for(j=trial+1;j<5;++j) {
            if(cp[j]<cp[trial]) {double t=cp[j];cp[j]=cp[trial];cp[trial]=t;}
            if(nt[j]<nt[trial]) {double t=nt[j];nt[j]=nt[trial];nt[trial]=t;}
        }
        printf("%zu,%.4f,%.4f,%.4f\n",n,n/cp[2],n/nt[2],nt[2]);
    }
    free(data); return 0;
}
