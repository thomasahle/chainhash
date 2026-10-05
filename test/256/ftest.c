/* ftest.c -- the ChainHash-256 fast finalizers against the reference finisher ph_finish on CRAFTED chain values: every combination of
 * limbs V_i in {~tau_i, ~tau_i + 1, ~tau_i - 1, 0, ~0, random} (6^4 = 1296 per key) -- the carry patterns of the
 * integer twist X = V +_Z tau that end-to-end tests cannot reach (V is a hash state: a propagating limb has
 * probability 2^-64) -- plus random V; random keys with tau limbs forced to 0, 1, ~0.  x86: both the Intel and the
 * Zen 4 finalizer on every host; NEON: the NEON finalizer.  Uses the header's internal names (test only). */
#include <stdio.h>
#include "chainhash256.h"
static uint64_t rs=0x5eed; static uint64_t rnd(void){ return ch_splitmix(&rs); }
static uint64_t edge(void){ switch(rnd()%6){ case 0: return 0; case 1: return ~0ULL; case 2: return 1; case 3: return 1ULL<<63; default: return rnd(); } }
#if defined(PH256_X86)
#if defined(__clang__)
#pragma clang attribute push (__attribute__((target("avx512f,avx512vl,avx512bw,avx512dq,avx512vbmi2,vpclmulqdq,gfni,pclmul,avx2,sse4.1"))), apply_to=function)
#else
#pragma GCC push_options
#pragma GCC target("avx512f,avx512vl,avx512bw,avx512dq,avx512vbmi2,vpclmulqdq,gfni,pclmul,avx2,sse4.1")
#endif
static void fin_all(const ph256_key*H,ph_el v,uint8_t o1[32],uint8_t o2[32]){ phq q=phq_ld(&v); phq_st(phq_final(q,&PH256_XK(H)->QF),o1); phq_st(phq_final_i(q,&PH256_XK(H)->QF),o2); }
#elif defined(PH256_ARM)
static void fin_all(const ph256_key*H,ph_el v,uint8_t o1[32],uint8_t o2[32]){ ph_el r=phv_st(phw_final(phv_ld(v),&PH256_NK(H)->WF)); memcpy(o1,r.w,32); memcpy(o2,r.w,32); }
#endif
int main(void){ static ph256_key H; static ph_key K; long bad=0, cnt=0;
    if(ph256_backend()==PH256_PORTABLE){ printf("[ftest] no fast backend: skipped\n"); return 0; }
    for(int kk=0;kk<24;kk++){ ph2_raw R; ph2_raw_from_seed(&R,rnd()); for(int l=0;l<4;l++) if(kk&1) R.t.w[l]=edge(); ph2_derive(&R,&K); ph256_init_raw2(&H,&R,-1);
        for(int c=0;c<1296+2000;c++){ ph_el v; int cc=c;
            for(int l=0;l<4;l++){ uint64_t t=K.tau.w[l], x; int m= c<1296? cc%6 : 5; cc/=6;
                switch(m){ case 0: x=~t; break; case 1: x=~t+1; break; case 2: x=~t-1; break; case 3: x=0; break; case 4: x=~0ULL; break; default: x=rnd(); }
                v.w[l]=x; }
            uint8_t r[32],o1[32],o2[32]; ph_store(ph_finish(v,&K),r); fin_all(&H,v,o1,o2); cnt++;
            if(memcmp(r,o1,32)||memcmp(r,o2,32)){ if(bad++<5) printf("  finalizer mismatch key %d case %d\n",kk,c); } } }
    printf("[ftest] %s finalizer(s) on %ld crafted/random chain values vs ph_finish: %s\n",PH256_BACKEND_NAME[ph256_backend()],cnt,bad?"FAIL":"PASS"); return bad!=0; }
#if defined(PH256_X86)
#if defined(__clang__)
#pragma clang attribute pop
#else
#pragma GCC pop_options
#endif
#endif
