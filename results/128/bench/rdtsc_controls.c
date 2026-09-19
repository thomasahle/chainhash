#include "chainhash.h"
#include "../chainhash128.h" /* control-128: the control construction's header of the measurement lane, not include/chainhash128.h and not part of this repository */
#include <x86intrin.h>
/* Row labels in the archived evidence/rdtsc-controls-final.csv: "chainhash-128" is control-128, "chainhash-v3" the 64-bit ChainHash. */
#include <stdio.h>
#include <stdlib.h>
static volatile uint64_t sink;
__attribute__((noinline)) static uint64_t call(int f,const void *k,const void *p,size_t n) {if(f)return chainhash((const chainhash_key *)k,p,n);return chainhash128((const chainhash128_key *)k,p,n).lo;}
static uint64_t ticks(void){_mm_lfence();return __rdtsc();}
static double measure(int f,const void *k,const void *p,size_t n,int reps){int i;uint64_t t;for(i=0;i<16;i++)sink^=call(f,k,p,n);t=ticks();for(i=0;i<reps;i++)sink^=call(f,k,p,n);return (double)(ticks()-t)/reps;}
static double median(double a,double b,double c){if(a>b){double t=a;a=b;b=t;}if(b>c){double t=b;b=c;c=t;}return a>b?a:b;}
int main(void){chainhash_key k64=chainhash_key_from_seed(42);chainhash128_key k128=chainhash128_key_from_splitmix64(42);unsigned char *p=(unsigned char*)malloc(262208);int i,f,a;for(i=0;i<262208;i++)p[i]=(unsigned char)(137*i+17);puts("name,length,alignment,cycles,bytes_per_cycle");for(f=0;f<2;f++){const void *k=f?(const void *)&k64:(const void *)&k128;for(a=0;a<8;a++){double t=median(measure(f,k,p+a,262144,512),measure(f,k,p+a,262144,512),measure(f,k,p+a,262144,512));printf("%s,262144,%d,%.5f,%.6f\n",f?"chainhash-v3":"chainhash-128",a,t,262144/t);}for(i=1;i<=256;i++){double t=median(measure(f,k,p,i,2048),measure(f,k,p,i,2048),measure(f,k,p,i,2048));printf("%s,%d,0,%.5f,%.6f\n",f?"chainhash-v3":"chainhash-128",i,t,i/t);}}free(p);return 0;}
