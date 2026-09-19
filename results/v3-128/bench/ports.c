#include <immintrin.h>
#include <stdio.h>
#include <stdint.h>
#define CL "vpclmulqdq $0x00, %%zmm0, %%zmm1, %%zmm2\n\t" "vpclmulqdq $0x11, %%zmm0, %%zmm1, %%zmm3\n\t" "vpclmulqdq $0x00, %%zmm0, %%zmm1, %%zmm4\n\t"
#define SH "vpshufd $0x4e, %%zmm0, %%zmm5\n\t" "vpshufd $0x4e, %%zmm1, %%zmm6\n\t"
#define CLOB "zmm2","zmm3","zmm4","zmm5","zmm6"
__attribute__((target("avx512f,vpclmulqdq"))) static double bench(int mode) {
 unsigned i; uint64_t t; __asm__ volatile("vpxord %%zmm0,%%zmm0,%%zmm0;vpxord %%zmm1,%%zmm1,%%zmm1":::"zmm0","zmm1");
 _mm_lfence();t=__rdtsc();
 if(mode==0)for(i=0;i<1000000;i++)__asm__ volatile(CL CL CL CL:::CLOB);
 if(mode==1)for(i=0;i<1000000;i++)__asm__ volatile(SH SH SH SH:::CLOB);
 if(mode==2)for(i=0;i<1000000;i++)__asm__ volatile(CL SH CL SH CL SH CL SH:::CLOB);
 _mm_lfence();return (double)(__rdtsc()-t)/4000000;
}
int main(void){int m,i;puts("kind,repeat,tsc_per_group");for(m=0;m<3;m++)for(i=0;i<7;i++)printf("%s,%d,%.6f\n",m==0?"3clmul":m==1?"2shuffle":"3clmul_2shuffle",i,bench(m));return 0;}
