#include "../chainhash_v3.h"
#include <stdio.h>
#include <stdlib.h>
#include <x86intrin.h>
static volatile uint64_t sink;
CHV3_T512 __attribute__((noinline)) static uint64_t extracts(const __m512i *p,size_t n) {
    __m128i sum=_mm_setzero_si128(); size_t i;
    for(i=0;i<n;i++) { __m512i a=_mm512_loadu_si512(p+i); __m256i b=_mm256_xor_si256(_mm512_castsi512_si256(a),_mm512_extracti64x4_epi64(a,1)); __m128i c=_mm_xor_si128(_mm256_castsi256_si128(b),_mm256_extracti128_si256(b,1)); sum=_mm_xor_si128(sum,c); __asm__("" : "+x"(sum)); }
    return (uint64_t)_mm_cvtsi128_si64(sum);
}
CHV3_T512 __attribute__((noinline)) static uint64_t butterfly(const __m512i *p,size_t n) {
    __m128i sum=_mm_setzero_si128(); size_t i;
    for(i=0;i<n;i++) { __m512i a=_mm512_loadu_si512(p+i); a=_mm512_xor_si512(a,_mm512_shuffle_i64x2(a,a,0x4e)); a=_mm512_xor_si512(a,_mm512_shuffle_i64x2(a,a,0xb1)); sum=_mm_xor_si128(sum,_mm512_castsi512_si128(a)); __asm__("" : "+x"(sum)); }
    return (uint64_t)_mm_cvtsi128_si64(sum);
}
static uint64_t tick(void) { _mm_lfence(); return __rdtsc(); }
int main(void) { size_t i,r; uint64_t data[4096]; const char *names[]={"two-extracts","two-shuffles"}; uint64_t (*fn[])(const __m512i *,size_t)={extracts,butterfly}; for(i=0;i<4096;i++) data[i]=i*12345; if(extracts((const __m512i *)data,512)!=butterfly((const __m512i *)data,512)) abort();
 puts("fold,run,tsc_per_four_lane_fold"); for(i=0;i<2;i++) for(r=0;r<3;r++) { size_t j; uint64_t start=tick(),v=0; for(j=0;j<10000;j++) v^=fn[i]((const __m512i *)data,512); uint64_t end=tick(); sink=v; printf("%s,%zu,%.6f\n",names[i],r+1,(double)(end-start)/(10000*512)); } return 0; }
