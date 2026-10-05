/* ChainHash-256: a keyed 256-bit hash for long inputs with a proven collision bound.
 * Copyright 2026 Thomas Dybdahl Ahle. MIT license. C99 (GCC/Clang), one header, no allocation in the hash.
 *
 * Key: 288 uniformly random bytes (CHAINHASH256_KEY_BYTES), chainhash256_key_from_bytes; the 128 block
 * masks are powers of the key element s, derived when the key is initialized.
 * chainhash256_key_from_seed expands a 64-bit seed; it is for benchmarks and tests.
 * The expanded key is initialized in place, at any 8-byte-aligned address (static, stack, malloc; the tables are
 * aligned inside the key). Do not copy it: a copy computes the same digests but may run the portable backend.
 * Hash: chainhash256(&key, data, len, out) writes 32 canonical little-endian bytes. Streaming:
 * chainhash256_init, chainhash256_update, chainhash256_final.
 * Backends (identical digests; chosen when the key is initialized): CH256_AVX512
 * (AVX-512 F/VL/BW/DQ/VBMI2 + VPCLMULQDQ + GFNI), CH256_PCLMUL (PCLMULQDQ + SSE4.1),
 * CH256_NEON (AArch64 PMULL; needs +crypto at compile time), CH256_PORTABLE.
 * x86: the kernels carry their own target attributes, so no -march flag is needed; gcc: build with -O3.
 * Bound: for two distinct messages fixed independently of the key, each of at most 8L bytes,
 * Pr[collision] <= N(L)/2^256 with N(L) <= 2L (score 255); see docs/THEOREM-256.md.
 * The definition: docs/SPEC-256.md; the family: docs/FAMILY.md.
 * Proof status: paper proof and machine-checked certificates (test/256); not yet in Lean.
 * Little-endian hosts. Define CHAINHASH256_PORTABLE to omit all hardware code.
 * Development name: PH-256 v2 (power key, 4 KiB blocks, two-level outer stage) with the v1.2 kernels.
 */
#ifndef CHAINHASH256_H
#define CHAINHASH256_H
#define PH_V2 1
#define PH256_V1_2 1
#if defined(PH_M) && PH_M != 64
#error "chainhash256.h is fixed at PH_M = 64 (4 KiB blocks)"
#endif
#ifndef PH_M
#define PH_M 64
#endif
/* Internal structure (names from the development tree): ph_* is the specification as C (bit-serial; ph2l_hash_ref
 * is the normative two-level definition), phx_* the AVX-512 kernels, phs_* the PCLMULQDQ + SSE4.1 kernels, phn_* the
 * NEON kernels, and ph256_* the run-time dispatch and streaming layer under the public API at the end of the file.
 * Streaming folds every full region into V (V <- V z + c) as soon as it is complete, and final folds the tail region
 * and adds n z^{m'}; before any region completes, final applies the one-shot function to the buffered bytes.
 * The backend tables are placed 64-byte aligned inside the key when it is initialized (ph256_key): do not copy an
 * initialized key. */
#ifndef PH256_H
#define PH256_H
/* The specification as C (bit-serial reference), docs/SPEC-256.md.
 *   field   L = GF(2)[x]/(f), f = x^256 + x^10 + x^5 + x^2 + 1 (irreducible: test/256/ph_field.py);
 *           element = 4 little-endian 64-bit limbs (limb 0 = coefficients x^0..x^63)
 *   block   PH_M pairs (x_i, y_i) of 32-byte elements; c = sum_i (x_i + k_i)(y_i + l_i) with the power-key masks
 *           k_i = s^(2i-1), l_i = s^(2i) (ph2_derive from the 288-byte raw key ph2_raw)
 *   layout  regions of 8 interleaved blocks and zero-padded tail blocks, as in docs/SPEC-256.md section 3
 *   outer   ph2l_hash_ref below (the two-level stage, normative); ph_hash_ref is the earlier outer stage (a Horner
 *           chain in Y over the block values), kept for comparisons and not used by the hash
 * The multiply here is schoolbook over limbs with ch_clmul64 (bit-serial unless CH256_HW_CLMUL) and a bit-level
 * reduction; it never uses the Karatsuba evaluation the kernels use. */
#ifndef PH_REF_H
#define PH_REF_H
#include <stdint.h>
#include <string.h>
/* 64x64 -> 128 carry-less product: bit-serial unless CH256_HW_CLMUL (then PMULL / PCLMULQDQ); same result */
#if defined(CH256_HW_CLMUL) && defined(__aarch64__) && (defined(__ARM_FEATURE_AES) || defined(__ARM_FEATURE_CRYPTO))
#include <arm_neon.h>
static inline void ch_clmul64(uint64_t a, uint64_t b, uint64_t *lo, uint64_t *hi){
    uint64x2_t v = vreinterpretq_u64_p128(vmull_p64((poly64_t)a,(poly64_t)b));
    *lo=vgetq_lane_u64(v,0); *hi=vgetq_lane_u64(v,1);
}
#elif defined(CH256_HW_CLMUL) && defined(__PCLMUL__)
#include <immintrin.h>
static inline void ch_clmul64(uint64_t a, uint64_t b, uint64_t *lo, uint64_t *hi){
    __m128i r=_mm_clmulepi64_si128(_mm_set_epi64x(0,a),_mm_set_epi64x(0,b),0x00);
    *lo=(uint64_t)_mm_cvtsi128_si64(r); *hi=(uint64_t)_mm_extract_epi64(r,1);
}
#else
static inline void ch_clmul64(uint64_t a, uint64_t b, uint64_t *lo, uint64_t *hi){
    uint64_t l=0,h=0;
    for(int i=0;i<64;i++){
        if((b>>i)&1u){
            if(i==0){ l^=a; }
            else { l^=a<<i; h^=a>>(64-i); }
        }
    }
    *lo=l; *hi=h;
}
#endif
static inline uint64_t ch_splitmix(uint64_t *st){
    uint64_t z=(*st += 0x9E3779B97F4A7C15ULL);
    z=(z^(z>>30))*0xBF58476D1CE4E5B9ULL;
    z=(z^(z>>27))*0x94D049BB133111EBULL;
    return z^(z>>31);
}
static inline uint64_t ch_ld64(const uint8_t *p){ uint64_t v; memcpy(&v,p,8); return v; }
#include <stdlib.h>
#ifndef PH_M
#define PH_M 16
#endif
#if PH_M % 8
#error "PH_M must be a multiple of 8"
#endif
#define PH_BLOCK (64*PH_M)
#define PH_REGION (8*PH_BLOCK)
typedef struct { uint64_t w[4]; } ph_el;
static inline ph_el ph_xor(ph_el a,ph_el b){ ph_el r; for(int i=0;i<4;i++) r.w[i]=a.w[i]^b.w[i]; return r; }
/* reduce a 512-bit product r[0..7] mod f, bit by bit from the top */
static inline ph_el ph_reduce512(const uint64_t r0[8]){
    uint64_t r[8]; memcpy(r,r0,sizeof r);
    for(int i=511;i>=256;i--) if((r[i>>6]>>(i&63))&1){ r[i>>6]^=1ULL<<(i&63);
        int t[4]={i-256+10,i-256+5,i-256+2,i-256}; for(int j=0;j<4;j++) r[t[j]>>6]^=1ULL<<(t[j]&63); }
    ph_el e; memcpy(e.w,r,32); return e; }
static inline ph_el ph_mul(ph_el a,ph_el b){
    uint64_t r[8]={0};
    for(int i=0;i<4;i++) for(int j=0;j<4;j++){ uint64_t lo,hi; ch_clmul64(a.w[i],b.w[j],&lo,&hi); r[i+j]^=lo; r[i+j+1]^=hi; }
    return ph_reduce512(r); }
static inline ph_el ph_addint(ph_el v,ph_el t){ ph_el r; unsigned __int128 c=0;
    for(int i=0;i<4;i++){ unsigned __int128 s=(unsigned __int128)v.w[i]+t.w[i]+c; r.w[i]=(uint64_t)s; c=s>>64; } return r; }
static inline ph_el ph_pow(ph_el b,uint64_t e){ ph_el r={{1,0,0,0}}; while(e){ if(e&1) r=ph_mul(r,b); b=ph_mul(b,b); e>>=1; } return r; }
typedef struct { ph_el k[PH_M], l[PH_M]; ph_el Y, c[5], tau; ph_el z; } ph_key;   /* z: two-level (2L) region-chain key */
static inline void ph_fill(ph_el*e,uint64_t*st){ for(int i=0;i<4;i++) e->w[i]=ch_splitmix(st); }
/* ---- PH-256 v2: POWER KEY.  Raw key = s | y | z | t | c0..c4 (9 elements, 288 bytes, each 32 bytes little-endian,
 * limb 0 first); the mask table is derived: k_j = s^(2j+1), l_j = s^(2j+2) for pair j = 0..PH_M-1 (pairs 1..m of the
 * spec: x_i masked by s^(2i-1), y_i by s^(2i)).  Y = y, tau = t.  All 9 elements independent and uniform. ---- */
typedef struct { ph_el s, y, z, t, c[5]; } ph2_raw;
static inline void ph2_derive_with(const ph2_raw*R,ph_key*K,ph_el (*mul)(ph_el,ph_el)){
    ph_el p=R->s;                                                          /* s^1 */
    for(int j=0;j<PH_M;j++){ K->k[j]=p; p=mul(p,R->s); K->l[j]=p; p=mul(p,R->s); }
    K->Y=R->y; K->z=R->z; K->tau=R->t; for(int i=0;i<5;i++) K->c[i]=R->c[i]; }
static inline ph_el ph_mul(ph_el a,ph_el b);
static inline void ph2_derive(const ph2_raw*R,ph_key*K){ ph2_derive_with(R,K,ph_mul); }
static inline void ph2_raw_from_bytes(const uint8_t b[288],ph2_raw*R){ ph_el*e=&R->s;
    for(int i=0;i<9;i++) for(int l=0;l<4;l++) e[i].w[l]=ch_ld64(b+32*i+8*l); }
static inline void ph2_raw_from_seed(ph2_raw*R,uint64_t seed){          /* tests/vectors only */
    uint64_t st=seed^0x5048323536763200ULL;                                /* "PH256v2" */
    ph_el*e=&R->s; for(int i=0;i<9;i++) ph_fill(&e[i],&st);
    if(!(R->y.w[0]|R->y.w[1]|R->y.w[2]|R->y.w[3])) R->y.w[0]=1; }
static inline void ph_key_from_seed(ph_key*K,uint64_t seed){        /* tests/benchmarks only */
#ifdef PH_V2
    ph2_raw R; ph2_raw_from_seed(&R,seed); ph2_derive(&R,K);
#else
        /* tests/benchmarks only */
    uint64_t st=seed^0x5048323536000000ULL^(uint64_t)PH_M;            /* "PH256" | m */
    for(int i=0;i<PH_M;i++){ ph_fill(&K->k[i],&st); ph_fill(&K->l[i],&st); }
    ph_fill(&K->Y,&st); for(int j=0;j<5;j++) ph_fill(&K->c[j],&st); ph_fill(&K->tau,&st);
    if(!(K->Y.w[0]|K->Y.w[1]|K->Y.w[2]|K->Y.w[3])) K->Y.w[0]=1;
    ph_fill(&K->z,&st);
#endif
    }

static inline ph_el ph_block(const ph_el*x,const ph_el*y,const ph_key*K){
    ph_el c={{0,0,0,0}}; for(int i=0;i<PH_M;i++) c=ph_xor(c,ph_mul(ph_xor(x[i],K->k[i]),ph_xor(y[i],K->l[i]))); return c; }
static inline ph_el ph_ldr(const uint8_t*p,size_t stride){ ph_el e; for(int l=0;l<4;l++) e.w[l]=ch_ld64(p+stride*l); return e; }
/* block b of region R / tail block blk (zero padded): the words of pair i */
static inline void ph_region_block(const uint8_t*R,int b,ph_el*x,ph_el*y){
    for(int i=0;i<PH_M;i++){ x[i]=ph_ldr(R+512*i+8*b,64); y[i]=ph_ldr(R+512*i+256+8*b,64); } }
static inline void ph_tail_block(const uint8_t*blk,ph_el*x,ph_el*y){
    for(int i=0;i<PH_M;i++){ x[i]=ph_ldr(blk+512*(i/8)+8*(i%8),64); y[i]=ph_ldr(blk+512*(i/8)+256+8*(i%8),64); } }
static inline size_t ph_nblocks(size_t n){ size_t rem=n%PH_REGION; return (n/PH_REGION)*8+(rem+PH_BLOCK-1)/PH_BLOCK; }
static inline ph_el ph_finish(ph_el v,const ph_key*K){
    ph_el X=ph_addint(v,K->tau), G=ph_mul(X,X);
    ph_el t=ph_mul(ph_xor(G,K->c[0]),ph_xor(ph_xor(X,G),K->c[1]));
    return ph_xor(ph_mul(ph_xor(X,K->c[2]),ph_xor(t,K->c[3])),K->c[4]); }
static inline void ph_store(ph_el d,uint8_t out[32]){ for(int i=0;i<4;i++) for(int b=0;b<8;b++) out[8*i+b]=(uint8_t)(d.w[i]>>(8*b)); }
static inline void ph_hash_ref(const ph_key*K,const uint8_t*m,size_t n,uint8_t out[32]){
    ph_el v={{(uint64_t)n,0,0,0}}, x[PH_M], y[PH_M]; size_t nfull=n/PH_REGION, rem=n-nfull*PH_REGION;
    for(size_t r=0;r<nfull;r++) for(int b=0;b<8;b++){ ph_region_block(m+r*PH_REGION,b,x,y); v=ph_xor(ph_mul(v,K->Y),ph_block(x,y,K)); }
    const uint8_t*T=m+nfull*PH_REGION;
    for(size_t b=0;b*PH_BLOCK<rem;b++){ uint8_t blk[PH_BLOCK]; size_t av=rem-b*PH_BLOCK; if(av>PH_BLOCK) av=PH_BLOCK;
        memcpy(blk,T+b*PH_BLOCK,av); memset(blk+av,0,PH_BLOCK-av); ph_tail_block(blk,x,y); v=ph_xor(ph_mul(v,K->Y),ph_block(x,y,K)); }
    ph_store(ph_finish(v,K),out); }
/* ======================= PH-256 v1: two-level (2L) outer stage — the NORMATIVE definition =======================
 * Block values b_1..b_m (level 1 as above) in message order: blocks 0..7 of each full region, then the tail blocks;
 * m = ph_nblocks(n), except n = 0: m = 1 and b_1 = 0.  Regions of R = 8 values; m' = ceil(m/8).
 * Region value (q values a_1..a_q, h = ceil(q/2), f = floor(q/2); y = K->Y):
 *     c = sum_{i=1}^{f} (a_i + y^(2i-1)) (a_{h+i} + y^(2i))  +  [q odd] a_h
 * Outer: V = n z^{m'} + sum_rho c_rho z^{m'-rho} (Horner in the independent key z, length leading);
 *     then X = V +_Z tau and the unchanged quintic (ph_finish).  For n <= one block: V = n z + b_1. */
static inline ph_el ph2l_region(const ph_el*a,int q,const ph_el*Y){
    int h=(q+1)/2, f=q/2; ph_el c={{0,0,0,0}}, yp[9]; yp[0]=(ph_el){{1,0,0,0}}; for(int e=1;e<=8;e++) yp[e]=ph_mul(yp[e-1],*Y);
    for(int i=1;i<=f;i++) c=ph_xor(c,ph_mul(ph_xor(a[i-1],yp[2*i-1]),ph_xor(a[h+i-1],yp[2*i])));
    if(q&1) c=ph_xor(c,a[h-1]);
    return c; }
/* all block values of the message (b[0..m-1]); returns m */
static inline size_t ph2l_blocks(const ph_key*K,const uint8_t*m,size_t n,ph_el*b){
    if(!n){ b[0]=(ph_el){{0,0,0,0}}; return 1; }
    ph_el x[PH_M], y[PH_M]; size_t nfull=n/PH_REGION, rem=n-nfull*PH_REGION, t=0;
    for(size_t r=0;r<nfull;r++) for(int bb=0;bb<8;bb++){ ph_region_block(m+r*PH_REGION,bb,x,y); b[t++]=ph_block(x,y,K); }
    const uint8_t*T=m+nfull*PH_REGION;
    for(size_t bb=0;bb*PH_BLOCK<rem;bb++){ uint8_t blk[PH_BLOCK]; size_t av=rem-bb*PH_BLOCK; if(av>PH_BLOCK) av=PH_BLOCK;
        memcpy(blk,T+bb*PH_BLOCK,av); memset(blk+av,0,PH_BLOCK-av); ph_tail_block(blk,x,y); b[t++]=ph_block(x,y,K); }
    return t; }
/* V from the block values (the outer stage by itself: used by the 2L certificate) */
static inline ph_el ph2l_outer(const ph_el*b,size_t m,uint64_t n,const ph_el*Y,const ph_el*z){
    size_t mp=(m+7)/8; ph_el V={{n,0,0,0}};
    for(size_t r=0;r<mp;r++){ int q=(int)((m-8*r)<8? m-8*r : 8); V=ph_xor(ph_mul(V,*z),ph2l_region(b+8*r,q,Y)); }
    return V; }
static inline void ph2l_hash_ref(const ph_key*K,const uint8_t*m,size_t n,uint8_t out[32]){
    size_t mmax=ph_nblocks(n)+1; ph_el*b=(ph_el*)malloc(mmax*sizeof(ph_el));
    size_t mb=ph2l_blocks(K,m,n,b); ph_el V=ph2l_outer(b,mb,(uint64_t)n,&K->Y,&K->z); free(b);
    ph_store(ph_finish(V,K),out); }
#endif

enum { PH256_PORTABLE=0, PH256_PCLMUL=1, PH256_AVX512=2, PH256_NEON=3 };
static const char *const PH256_BACKEND_NAME[4]={"portable","pclmul-sse4.1","avx512-vpclmulqdq","neon-pmull"};

#if !defined(CHAINHASH256_PORTABLE) && defined(__x86_64__) && (defined(__GNUC__) || defined(__clang__))
#include <immintrin.h>
#define PH256_X86 1
#if defined(__clang__)
#pragma clang attribute push (__attribute__((target("avx512f,avx512vl,avx512bw,avx512dq,avx512vbmi2,vpclmulqdq,gfni,pclmul,avx2,sse4.1,tune=icelake-server"))), apply_to=function)
#else
#pragma GCC push_options
#pragma GCC target("avx512f,avx512vl,avx512bw,avx512dq,avx512vbmi2,vpclmulqdq,gfni,pclmul,avx2,sse4.1,tune=icelake-server")
#endif
/* ph_x86.h -- PH-256 AVX-512 (VPCLMULQDQ + VBMI2) kernels.  Output = ph_hash_ref (ph_ref.h).
 *
 * Region (8 blocks, limb-major: a zmm row = limb l of 8 blocks): per pair, both operands are evaluated at the 9
 * Karatsuba^2 points (4 keyed limbs + 5 XORs); clmul 0x00 / 0x11 give the point products of the even / odd blocks;
 * 18 raw 128-bit point accumulators (9 points x E/O).  The stride-8 chain is ABSORBED: the chain state s (limb-major,
 * 4 zmm) is evaluated at the 9 points and multiplied by the points of Y^8, into the same accumulators.  Once per
 * region: unpack E/O into limb-major qwords (18 shuffles), interpolate vertically, reduce mod x^256+x^10+x^5+x^2+1
 * with VPSHLDQ shifts -> the new chain state s = s Y^8 + c_b per lane b.
 * Tail block: the same row shape with lanes = pairs; the lane sum of the point products gives the block's points.
 * Final: the 8 stride classes are recombined through points of Y^((p-1-b) mod 8) per lane, plus n Y^p. */
#ifndef PH_X86_H
#define PH_X86_H
#include <immintrin.h>
#if defined(__clang__)
#define PHX_UNROLL _Pragma("clang loop unroll(full)")
#define PHX_HPUNROLL _Pragma("clang loop unroll(full)")
#else
#define PHX_HPUNROLL
#define PHX_UNROLL _Pragma("GCC unroll 32")
#endif
/* ---- v1.2: Intel latency path on xmm (PCLMULQDQ xmm: latency 6, 1/cycle; the ymm/zmm forms: latency 8, one per 2
 * cycles), used for the finalizer and the <= 64-byte path when !zen.  Element = (a, b) = limbs (0,1), (2,3). ---- */
typedef struct { __m128i a, b; } phq;
#define PHQ_INL static inline __attribute__((always_inline))   /* phq values are 32-byte structs: out of line they return through memory (store-forward stall) */
#define PQ_T(a,b,c) _mm_ternarylogic_epi64(a,b,c,0x96)
#define PQ_CL(a,b,i) _mm_clmulepi64_si128(a,b,i)
PHQ_INL phq phq_ld(const ph_el*e){ phq r={_mm_loadu_si128((const __m128i*)&e->w[0]),_mm_loadu_si128((const __m128i*)&e->w[2])}; return r; }
PHQ_INL void phq_st(phq v,uint8_t out[32]){ _mm_storeu_si128((__m128i*)out,v.a); _mm_storeu_si128((__m128i*)(out+16),v.b); }
PHQ_INL phq phq_x(phq x,phq y){ phq r={_mm_xor_si128(x.a,y.a),_mm_xor_si128(x.b,y.b)}; return r; }
/* the 512-bit (R0..R3 = limbs (0,1)..(6,7)) mod f plus E (a free XOR: it enters the base term) */
PHQ_INL phq phq_red(__m128i R0,__m128i R1,__m128i R2,__m128i R3,phq E){
    __m128i P0=_mm_slli_si128(R2,8), P1=_mm_alignr_epi8(R3,R2,8), h3=_mm_srli_si128(R3,8);           /* [0,h0] [h1,h2] [h3,0] */
    __m128i ov=PQ_T(_mm_srli_epi64(h3,62),_mm_srli_epi64(h3,59),_mm_srli_epi64(h3,54));             /* bits >= 256 of H g */
    __m128i og=PQ_T(ov,_mm_slli_epi64(ov,2),_mm_slli_epi64(ov,5));
    __m128i s0=PQ_T(_mm_shldi_epi64(R2,P0,2),_mm_shldi_epi64(R2,P0,5),_mm_shldi_epi64(R2,P0,10));
    __m128i s1=PQ_T(_mm_shldi_epi64(R3,P1,2),_mm_shldi_epi64(R3,P1,5),_mm_shldi_epi64(R3,P1,10));
    phq r={PQ_T(PQ_T(R0,R2,E.a),s0,PQ_T(og,_mm_slli_epi64(ov,10),_mm_setzero_si128())),PQ_T(PQ_T(R1,R3,E.b),s1,_mm_setzero_si128())}; return r; }
/* the same reduction with two different free terms (two outputs, one shared shift network) */
PHQ_INL void phq_red2(__m128i R0,__m128i R1,__m128i R2,__m128i R3,phq E,phq F,phq*oe,phq*of){
    __m128i P0=_mm_slli_si128(R2,8), P1=_mm_alignr_epi8(R3,R2,8), h3=_mm_srli_si128(R3,8);
    __m128i ov=PQ_T(_mm_srli_epi64(h3,62),_mm_srli_epi64(h3,59),_mm_srli_epi64(h3,54));
    __m128i og=PQ_T(ov,_mm_slli_epi64(ov,2),_mm_slli_epi64(ov,5)), o10=_mm_slli_epi64(ov,10);
    __m128i s0=PQ_T(_mm_shldi_epi64(R2,P0,2),_mm_shldi_epi64(R2,P0,5),_mm_shldi_epi64(R2,P0,10));
    __m128i s1=PQ_T(_mm_shldi_epi64(R3,P1,2),_mm_shldi_epi64(R3,P1,5),_mm_shldi_epi64(R3,P1,10));
    __m128i r02=_mm_xor_si128(R0,R2), r13=_mm_xor_si128(R1,R3);
    oe->a=PQ_T(r02,s0,PQ_T(og,o10,E.a)); oe->b=PQ_T(r13,s1,E.b); of->a=PQ_T(r02,s0,PQ_T(og,o10,F.a)); of->b=PQ_T(r13,s1,F.b); }
/* 256 x 256 schoolbook (16 clmul, the high half's products issued first) -> R0..R3 */
PHQ_INL void phq_mulraw(phq x,phq y,__m128i*R0,__m128i*R1,__m128i*R2,__m128i*R3){
    __m128i a=x.a,b=x.b,c=y.a,d=y.b;
    __m128i bd11=PQ_CL(b,d,0x11), bd01=PQ_CL(b,d,0x01), bd10=PQ_CL(b,d,0x10), bd00=PQ_CL(b,d,0x00);
    __m128i ad11=PQ_CL(a,d,0x11), bc11=PQ_CL(b,c,0x11), ad01=PQ_CL(a,d,0x01), ad10=PQ_CL(a,d,0x10), bc01=PQ_CL(b,c,0x01), bc10=PQ_CL(b,c,0x10);
    __m128i ac11=PQ_CL(a,c,0x11), ad00=PQ_CL(a,d,0x00), bc00=PQ_CL(b,c,0x00), ac01=PQ_CL(a,c,0x01), ac10=PQ_CL(a,c,0x10), ac00=PQ_CL(a,c,0x00);
    __m128i M5=_mm_xor_si128(bd01,bd10), M3=PQ_T(PQ_T(ad01,ad10,bc01),bc10,_mm_setzero_si128()), M1=_mm_xor_si128(ac01,ac10);
    *R3=_mm_xor_si128(bd11,_mm_srli_si128(M5,8));
    *R2=PQ_T(PQ_T(ad11,bc11,bd00),_mm_srli_si128(M3,8),_mm_slli_si128(M5,8));
    *R1=PQ_T(PQ_T(ac11,ad00,bc00),_mm_srli_si128(M1,8),_mm_slli_si128(M3,8));
    *R0=_mm_xor_si128(ac00,_mm_slli_si128(M1,8)); }
/* X = v +_Z tau, branch-free: per-limb carry-out g_i (msb of v&t | (v|t)&~s) and propagate p_i = [v_i == ~t_i]
 * (exclusive), a 2-level lookahead over the 4 limbs; the masks are hidden from the compiler (no k-mask round trips) */
#define PQ_HIDE(x) __asm__("":"+v"(x))
PHQ_INL phq phq_addint(phq v,phq t,phq nt){
    __m128i sa=_mm_add_epi64(v.a,t.a), sb=_mm_add_epi64(v.b,t.b);
    __m128i ga=_mm_srai_epi64(_mm_ternarylogic_epi64(v.a,t.a,sa,0xD4),63), gb=_mm_srai_epi64(_mm_ternarylogic_epi64(v.b,t.b,sb,0xD4),63);
    __m128i pa=_mm_cmpeq_epi64(v.a,nt.a), pb=_mm_cmpeq_epi64(v.b,nt.b);
    PQ_HIDE(ga); PQ_HIDE(gb); PQ_HIDE(pa); PQ_HIDE(pb);
    __m128i Eg=_mm_alignr_epi8(gb,ga,8), Ep=_mm_alignr_epi8(pb,pa,8), G0=_mm_unpacklo_epi64(ga,ga);  /* [g1,g2] [p1,p2] [g0,g0] */
    __m128i H=_mm_ternarylogic_epi64(Ep,ga,Eg,0xEA), Q=_mm_and_si128(Ep,pa);                        /* Eg | Ep&ga;  [p1p0, p2p1] */
    __m128i Cb=_mm_ternarylogic_epi64(Q,G0,H,0xEA);                                                  /* carries into limbs 2, 3 */
    phq r={_mm_sub_epi64(sa,_mm_slli_si128(ga,8)),_mm_sub_epi64(sb,Cb)}; return r; }
/* finalizer key: tau, ~tau, c0..c4 */
typedef struct { phq tau, ntau, c[5]; } phq_fk;
static inline void phq_fk_init(phq_fk*k,const ph_key*K){ ph_el nt; for(int i=0;i<4;i++) nt.w[i]=~K->tau.w[i];
    k->tau=phq_ld(&K->tau); k->ntau=phq_ld(&nt); for(int j=0;j<5;j++) k->c[j]=phq_ld(&K->c[j]); }
/* X = v +_Z tau; G = X^2 -> U = G + c0 and W = G + X + c1 from one reduction; T = UW + c3; out = (X + c2) T + c4 */
PHQ_INL phq phq_final(phq v,const phq_fk*k){
    phq X=phq_addint(v,k->tau,k->ntau), U, W;
    __m128i S3=PQ_CL(X.b,X.b,0x11), S2=PQ_CL(X.b,X.b,0x00), S1=PQ_CL(X.a,X.a,0x11), S0=PQ_CL(X.a,X.a,0x00);
    phq_red2(S0,S1,S2,S3,k->c[0],phq_x(X,k->c[1]),&U,&W);
    __m128i R0,R1,R2,R3; phq_mulraw(U,W,&R0,&R1,&R2,&R3);
    phq T=phq_red(R0,R1,R2,R3,k->c[3]);
    phq_mulraw(phq_x(X,k->c[2]),T,&R0,&R1,&R2,&R3);
    return phq_red(R0,R1,R2,R3,k->c[4]); }
static inline __m128i pq_f(__m128i x){ return _mm_xor_si128(x,_mm_srli_si128(x,8)); }
/* 256 x 256 by 128-level Karatsuba (L = ac, H = bd, M = (a^b)(c^d)), each 128 x 128 by 3 clmul */
PHQ_INL void phq_mulraw_k9(phq x,phq y,__m128i*R0,__m128i*R1,__m128i*R2,__m128i*R3){
    __m128i a=x.a,b=x.b,c=y.a,d=y.b, e=_mm_xor_si128(a,b), f=_mm_xor_si128(c,d);
    __m128i H0=PQ_CL(b,d,0x00), H1=PQ_CL(b,d,0x11), L0=PQ_CL(a,c,0x00), L1=PQ_CL(a,c,0x11), M0=PQ_CL(e,f,0x00), M1=PQ_CL(e,f,0x11);
    __m128i Hm=PQ_CL(pq_f(b),pq_f(d),0x00), Lm=PQ_CL(pq_f(a),pq_f(c),0x00), Mm=PQ_CL(pq_f(e),pq_f(f),0x00);
    __m128i hm=PQ_T(Hm,H0,H1), lm=PQ_T(Lm,L0,L1), mm=PQ_T(Mm,M0,M1);
    __m128i s=PQ_T(mm,lm,hm), q0=PQ_T(M0,L0,H0), q1=PQ_T(M1,L1,H1);
    *R0=_mm_xor_si128(L0,_mm_slli_si128(lm,8));
    *R1=PQ_T(PQ_T(L1,q0,_mm_srli_si128(lm,8)),_mm_slli_si128(s,8),_mm_setzero_si128());
    *R2=PQ_T(PQ_T(H0,q1,_mm_slli_si128(hm,8)),_mm_srli_si128(s,8),_mm_setzero_si128());
    *R3=_mm_xor_si128(H1,_mm_srli_si128(hm,8)); }
/* Intel: the twist folded into the square (carry-select: X_i = s_i ^ (m_i & t_i), t_i = s_i ^ (s_i + 1), so
 * X_i^2 = s_i^2 ^ (m_i & t_i^2): the squares start right after the per-limb add, the carry lookahead runs beside them)
 * and Karatsuba multiplies (9 clmul).  Zen 4 prefers phq_final (clmul throughput, see README). */
PHQ_INL phq phq_final_i(phq v,const phq_fk*k){
    const __m128i one=_mm_set1_epi64x(1);
    __m128i sa=_mm_add_epi64(v.a,k->tau.a), sb=_mm_add_epi64(v.b,k->tau.b);
    __m128i ta=_mm_xor_si128(sa,_mm_add_epi64(sa,one)), tb=_mm_xor_si128(sb,_mm_add_epi64(sb,one));
    __m128i S0=PQ_CL(sa,sa,0x00), S1=PQ_CL(sa,sa,0x11), S2=PQ_CL(sb,sb,0x00), S3=PQ_CL(sb,sb,0x11);
    __m128i T1=PQ_CL(ta,ta,0x11), T2=PQ_CL(tb,tb,0x00), T3=PQ_CL(tb,tb,0x11);
    __m128i ga=_mm_srai_epi64(_mm_ternarylogic_epi64(v.a,k->tau.a,sa,0xD4),63), gb=_mm_srai_epi64(_mm_ternarylogic_epi64(v.b,k->tau.b,sb,0xD4),63);
    __m128i pa=_mm_cmpeq_epi64(v.a,k->ntau.a), pb=_mm_cmpeq_epi64(v.b,k->ntau.b);
    PQ_HIDE(ga); PQ_HIDE(gb); PQ_HIDE(pa); PQ_HIDE(pb);
    __m128i Eg=_mm_alignr_epi8(gb,ga,8), Ep=_mm_alignr_epi8(pb,pa,8), G0=_mm_unpacklo_epi64(ga,ga);
    __m128i H=_mm_ternarylogic_epi64(Ep,ga,Eg,0xEA), Q=_mm_and_si128(Ep,pa);
    __m128i Cb=_mm_ternarylogic_epi64(Q,G0,H,0xEA);
    __m128i m2=_mm_unpacklo_epi64(Cb,Cb), m3=_mm_unpackhi_epi64(Cb,Cb);
    __m128i R1=_mm_ternarylogic_epi64(S1,G0,T1,0x78), R2=_mm_ternarylogic_epi64(S2,m2,T2,0x78), R3=_mm_ternarylogic_epi64(S3,m3,T3,0x78);
    phq X={_mm_ternarylogic_epi64(sa,_mm_slli_si128(ga,8),ta,0x78),_mm_ternarylogic_epi64(sb,Cb,tb,0x78)}, U, W;
    phq_red2(S0,R1,R2,R3,k->c[0],phq_x(X,k->c[1]),&U,&W);
    __m128i P0,P1,P2,P3; phq_mulraw_k9(U,W,&P0,&P1,&P2,&P3);
    phq T=phq_red(P0,P1,P2,P3,k->c[3]);
    phq_mulraw_k9(phq_x(X,k->c[2]),T,&P0,&P1,&P2,&P3);
    return phq_red(P0,P1,P2,P3,k->c[4]); }
/* n <= 64 (one tail block, x limb 0 of pairs 0..7 only): V = C0 + n z + sum_{i<8} d_i l_i, d_i = the 8-byte word i;
 * per 16-byte chunk 8 clmul accumulated per limb offset, n z issued first (n is known before the data arrives) */
typedef struct { __m128i KL[4][4], Z[4]; phq C0; } phq_sk;          /* KL[j][l] = (l_2j limb l, l_2j+1 limb l); Z[l] = (z limb l, 0) */
static inline void phq_sk_init(phq_sk*s,const ph_key*K,const ph_el*C0){
    for(int j=0;j<4;j++) for(int l=0;l<4;l++) s->KL[j][l]=_mm_set_epi64x((long long)K->l[2*j+1].w[l],(long long)K->l[2*j].w[l]);
    for(int l=0;l<4;l++) s->Z[l]=_mm_set_epi64x(0,(long long)K->z.w[l]);
    s->C0=phq_ld(C0); }
PHQ_INL __m128i pq_mld(const uint8_t*p,size_t off,size_t n){ size_t k= n>off? n-off : 0; if(k>16) k=16;
    return _mm_maskz_loadu_epi8((__mmask16)((1u<<k)-1),(const void*)(p+off)); }
#define PQ_ACC4(Q,D,KL) do{ for(int l_=3;l_>=0;l_--) Q[l_]=PQ_T(Q[l_],PQ_CL(D,(KL)[l_],0x00),PQ_CL(D,(KL)[l_],0x11)); }while(0)   /* limb 3 first: it feeds the fold */
PHQ_INL phq phq_v64(const phq_sk*s,const uint8_t*p,size_t n){
    __m128i nv=_mm_cvtsi64_si128((long long)n), Q[4];
    for(int l=0;l<4;l++) Q[l]=PQ_CL(nv,s->Z[l],0x00);
    size_t w=(n+15)/16;
    __m128i D0=pq_mld(p,0,n); PQ_ACC4(Q,D0,s->KL[0]);
    if(w>1){ __m128i D1=pq_mld(p,16,n); PQ_ACC4(Q,D1,s->KL[1]); }
    if(w>2){ __m128i D2=pq_mld(p,32,n); PQ_ACC4(Q,D2,s->KL[2]); }
    if(w>3){ __m128i D3=pq_mld(p,48,n); PQ_ACC4(Q,D3,s->KL[3]); }
    /* Q_l = 128 bits at limb l: limbs (0,1) = Q0 + Q1<<64, (2,3) = Q2 + [Q1.hi, Q3.lo], limb 4 = Q3.hi -> folded by g */
    __m128i Hx=_mm_srli_si128(Q[3],8), Hp=_mm_and_si128(Q[3],_mm_set_epi64x(-1,0));                 /* [r4,0] [0,r4] */
    __m128i s0=PQ_T(_mm_shldi_epi64(Hx,Hp,2),_mm_shldi_epi64(Hx,Hp,5),_mm_shldi_epi64(Hx,Hp,10));
    phq r={PQ_T(PQ_T(Q[0],_mm_slli_si128(Q[1],8),s->C0.a),Hx,s0),PQ_T(Q[2],_mm_alignr_epi8(Q[3],Q[1],8),s->C0.b)}; return r; }
PHQ_INL phq phq_from_v(__m256i v){ phq r={_mm256_castsi256_si128(v),_mm256_extracti128_si256(v,1)}; return r; }
PHQ_INL __m256i phq_to_v(phq v){ return _mm256_inserti128_si256(_mm256_castsi128_si256(v.a),v.b,1); }
typedef struct { __m512i lo,hi; } phx_p;          /* a 128-bit value per block, limb-major (qword lane = block) */
typedef struct {
    ph_key K;
    __m512i YP8[9];                               /* points of Y^8, broadcast */
    __m512i PR[8][9];                             /* PR[pr][pt]: lane b = point pt of Y^((pr-1-b) mod 8) */
    __m512i KT[PH_M/8][8];                        /* tail keys: [group][limb (x: 0..3, y: 4..7)], lane t = pair 8g+t */
    __m512i SF[PH_M/8+1][18];                     /* tail suffix: raw point sums (E,O interleaved) of key-only groups >= g */
    __m512i SF9[PH_M/8+1][9];                     /* the same with E and O summed (the tail block sums them anyway) */
    __m512i KBc[PH_M][8];                         /* region keys broadcast: [pair][x limbs 0..3, y limbs 4..7] */
    uint64_t KS[PH_M][12];                        /* scalar keys: x limbs 0..3, y limbs 0..3, mixes x02, x13, y02, y13 */
    ph_el Y8, yp[9];
    __m256i C0;                                   /* key-only block value (an all-zero tail block): sum k_i l_i */
    __m512i YQ;                                   /* lane l: (Y limb l, 0) -- n Y as one clmul */
    __m512i ZQ;                                   /* lane l: (z limb l, 0) -- n z as one clmul (2L short path) */
    __m512i YO[4], YEZ[4];                        /* 2L: limb l; lanes 0..3 = y^1,y^3,y^5,y^7 | lanes 0..3 = y^2,y^4,y^6,y^8, lanes 4..7 = z */
    phq_fk QF; phq_sk QS;                         /* v1.2: Intel xmm finalizer / <= 64 B keys */
    int zen;                                      /* AMD (Zen 4): ymm-only multiply/square/reduction on the latency paths (same values) */
} phx_key;
/* 9 points of 4 limbs (any lane layout) */
#define PHX_EVAL(P,A0,A1,A2,A3) do{ (P)[0]=(A0); (P)[1]=(A1); (P)[2]=_mm512_xor_si512(A0,A1); (P)[3]=(A2); (P)[4]=(A3); \
        (P)[5]=_mm512_xor_si512(A2,A3); (P)[6]=_mm512_xor_si512(A0,A2); (P)[7]=_mm512_xor_si512(A1,A3); (P)[8]=_mm512_xor_si512((P)[2],(P)[5]); }while(0)
static inline void ph_eval9(const ph_el*a,uint64_t p[9]){ p[0]=a->w[0]; p[1]=a->w[1]; p[2]=a->w[0]^a->w[1]; p[3]=a->w[2]; p[4]=a->w[3];
    p[5]=a->w[2]^a->w[3]; p[6]=a->w[0]^a->w[2]; p[7]=a->w[1]^a->w[3]; p[8]=p[2]^p[5]; }
/* interpolate 9 point products (limb-major lo/hi) -> 8 limbs; reduce -> 4 limbs */
static inline void phx_interp_reduce(const phx_p Q[9],__m512i out[4]){
#define PHX_INNER(L,a,b,c) do{ __m512i ml=_mm512_ternarylogic_epi64((a).lo,(b).lo,(c).lo,0x96), mh=_mm512_ternarylogic_epi64((a).hi,(b).hi,(c).hi,0x96); \
        (L)[0]=(a).lo; (L)[1]=_mm512_xor_si512((a).hi,ml); (L)[2]=_mm512_xor_si512((b).lo,mh); (L)[3]=(b).hi; }while(0)
    __m512i LO[4],HI[4],MI[4],r[8];
    PHX_INNER(LO,Q[0],Q[1],Q[2]); PHX_INNER(HI,Q[3],Q[4],Q[5]); PHX_INNER(MI,Q[6],Q[7],Q[8]);
    for(int l=0;l<4;l++) MI[l]=_mm512_ternarylogic_epi64(MI[l],LO[l],HI[l],0x96);
    r[0]=LO[0]; r[1]=LO[1]; r[2]=_mm512_xor_si512(LO[2],MI[0]); r[3]=_mm512_xor_si512(LO[3],MI[1]);
    r[4]=_mm512_xor_si512(HI[0],MI[2]); r[5]=_mm512_xor_si512(HI[1],MI[3]); r[6]=HI[2]; r[7]=HI[3];
    /* r_lo + r_hi (1 + x^2 + x^5 + x^10) */
    const __m512i z=_mm512_setzero_si512(); __m512i h[5]={z,r[4],r[5],r[6],r[7]};
    for(int l=0;l<4;l++){ __m512i a=_mm512_shldi_epi64(h[l+1],h[l],2), b=_mm512_shldi_epi64(h[l+1],h[l],5), c=_mm512_shldi_epi64(h[l+1],h[l],10);
        out[l]=_mm512_ternarylogic_epi64(_mm512_ternarylogic_epi64(r[l],h[l+1],a,0x96),b,c,0x96); }
    __m512i ov=_mm512_ternarylogic_epi64(_mm512_srli_epi64(r[7],62),_mm512_srli_epi64(r[7],59),_mm512_srli_epi64(r[7],54),0x96);
    out[0]=_mm512_ternarylogic_epi64(_mm512_ternarylogic_epi64(out[0],ov,_mm512_slli_epi64(ov,2),0x96),_mm512_slli_epi64(ov,5),_mm512_slli_epi64(ov,10),0x96); }
/* E/O raw accumulators (128-bit lane k of E = block/lane 2k, of O = 2k+1) -> limb-major lo/hi */
static inline phx_p phx_unpack(__m512i E,__m512i O){ phx_p r; r.lo=_mm512_unpacklo_epi64(E,O); r.hi=_mm512_unpackhi_epi64(E,O); return r; }
/* ---- scalar field multiply with hardware clmul (key setup, tail/final glue) ---- */
static inline void phx_cl(uint64_t a,uint64_t b,uint64_t*lo,uint64_t*hi){ __m128i r=_mm_clmulepi64_si128(_mm_cvtsi64_si128((long long)a),_mm_cvtsi64_si128((long long)b),0);
    *lo=(uint64_t)_mm_cvtsi128_si64(r); *hi=(uint64_t)_mm_extract_epi64(r,1); }
static inline ph_el phx_red8(const uint64_t r[8]){
    uint64_t h[5]={0,r[4],r[5],r[6],r[7]}; ph_el o;
    for(int l=0;l<4;l++){ uint64_t a=(h[l+1]<<2)|(h[l]>>62), b=(h[l+1]<<5)|(h[l]>>59), c=(h[l+1]<<10)|(h[l]>>54); o.w[l]=r[l]^h[l+1]^a^b^c; }
    uint64_t ov=(r[7]>>62)^(r[7]>>59)^(r[7]>>54); o.w[0]^=ov^(ov<<2)^(ov<<5)^(ov<<10); return o; }
/* field multiply, 4 zmm clmul: lanes (a01 x b01, a01 x b23, a23 x b01, a23 x b23) give all 16 limb products */
static inline ph_el phx_mul(ph_el a,ph_el b){
    __m512i va=_mm512_set_epi64((long long)a.w[3],(long long)a.w[2],(long long)a.w[3],(long long)a.w[2],(long long)a.w[1],(long long)a.w[0],(long long)a.w[1],(long long)a.w[0]);
    __m512i vb=_mm512_set_epi64((long long)b.w[3],(long long)b.w[2],(long long)b.w[1],(long long)b.w[0],(long long)b.w[3],(long long)b.w[2],(long long)b.w[1],(long long)b.w[0]);
    __m512i ll=_mm512_clmulepi64_epi128(va,vb,0x00), hh=_mm512_clmulepi64_epi128(va,vb,0x11);
    __m512i md=_mm512_xor_si512(_mm512_clmulepi64_epi128(va,vb,0x01),_mm512_clmulepi64_epi128(va,vb,0x10));
    __m512i L=_mm512_xor_si512(ll,_mm512_bslli_epi128(md,8)), H=_mm512_xor_si512(hh,_mm512_bsrli_epi128(md,8));   /* lane k: 256-bit (L,H) */
    uint64_t l[8],h[8]; _mm512_storeu_si512(l,L); _mm512_storeu_si512(h,H);
    uint64_t r[8]; r[0]=l[0]; r[1]=l[1]; r[2]=h[0]^l[2]^l[4]; r[3]=h[1]^l[3]^l[5]; r[4]=h[2]^h[4]^l[6]; r[5]=h[3]^h[5]^l[7]; r[6]=h[6]; r[7]=h[7];
    return phx_red8(r); }
/* squaring is linear in characteristic 2: sum a_i^2 x^(128 i) */
static inline ph_el phx_sq(ph_el a){ uint64_t r[8];
    for(int i=0;i<4;i++) phx_cl(a.w[i],a.w[i],&r[2*i],&r[2*i+1]);
    return phx_red8(r); }
/* 64-bit integer (as a field element of degree < 64) times an element: 4 clmul */
static inline ph_el phx_mul64(uint64_t n,ph_el b){ uint64_t r[8]={0};
    for(int j=0;j<4;j++){ uint64_t lo,hi; phx_cl(n,b.w[j],&lo,&hi); r[j]^=lo; r[j+1]^=hi; } return phx_red8(r); }
static inline ph_el phx_final(ph_el v,const ph_key*K){
    ph_el X=ph_addint(v,K->tau), G=phx_sq(X), t=phx_mul(ph_xor(G,K->c[0]),ph_xor(ph_xor(X,G),K->c[1]));
    return ph_xor(phx_mul(ph_xor(X,K->c[2]),ph_xor(t,K->c[3])),K->c[4]); }
/* ---- in-register field elements (__m256i = 4 limbs) for the short path / glue ---- */
/* 512-bit r (zmm qwords 0..7) mod f -> ymm */
static inline __m256i phv_red(__m512i r){
    __m512i hv=_mm512_maskz_permutexvar_epi64(0x0F,_mm512_set_epi64(0,0,0,0,7,6,5,4),r);
    __m512i pv=_mm512_maskz_permutexvar_epi64(0x0E,_mm512_set_epi64(0,0,0,0,6,5,4,0),r);
    __m512i a=_mm512_shldi_epi64(hv,pv,2), b=_mm512_shldi_epi64(hv,pv,5), c=_mm512_shldi_epi64(hv,pv,10);
    __m512i o=_mm512_ternarylogic_epi64(_mm512_ternarylogic_epi64(r,hv,a,0x96),b,c,0x96);
    __m512i ov=_mm512_ternarylogic_epi64(_mm512_srli_epi64(hv,62),_mm512_srli_epi64(hv,59),_mm512_srli_epi64(hv,54),0x96);
    ov=_mm512_maskz_permutexvar_epi64(0x01,_mm512_set1_epi64(3),ov);
    o=_mm512_ternarylogic_epi64(_mm512_ternarylogic_epi64(o,ov,_mm512_slli_epi64(ov,2),0x96),_mm512_slli_epi64(ov,5),_mm512_slli_epi64(ov,10),0x96);
    return _mm512_castsi512_si256(o); }
/* low-latency multiply (measured 39 vs 46 ticks dependent): 3 two-source permutes assemble the 512-bit product;
 * the reduction overflow of the top limb is computed from r directly, off the hv permute path */
/* 512-bit r (qwords 0..7) mod f; overflow of the top limb computed from r directly (parallel to the hv permute) */
static inline __m256i phv_red2(__m512i r){
    __m512i hv=_mm512_maskz_permutexvar_epi64(0x0F,_mm512_set_epi64(0,0,0,0,7,6,5,4),r);
    __m512i pv=_mm512_maskz_permutexvar_epi64(0x0E,_mm512_set_epi64(0,0,0,0,6,5,4,0),r);
    __m512i o7=_mm512_ternarylogic_epi64(_mm512_srli_epi64(r,62),_mm512_srli_epi64(r,59),_mm512_srli_epi64(r,54),0x96);   /* lane 7 valid */
    __m512i ov=_mm512_maskz_permutexvar_epi64(0x01,_mm512_set1_epi64(7),o7);
    __m512i f=_mm512_ternarylogic_epi64(ov,_mm512_slli_epi64(ov,2),_mm512_slli_epi64(ov,5),0x96);
    f=_mm512_ternarylogic_epi64(f,_mm512_slli_epi64(ov,10),r,0x96);                           /* low limbs of r + fold of ov */
    __m512i a=_mm512_shldi_epi64(hv,pv,2), b=_mm512_shldi_epi64(hv,pv,5), c=_mm512_shldi_epi64(hv,pv,10);
    return _mm512_castsi512_si256(_mm512_ternarylogic_epi64(_mm512_ternarylogic_epi64(f,hv,a,0x96),b,c,0x96)); }
static inline __m256i phv_mul(__m256i a,__m256i b){
    __m512i va=_mm512_permutexvar_epi64(_mm512_set_epi64(3,2,3,2,1,0,1,0),_mm512_castsi256_si512(a));
    __m512i vb=_mm512_broadcast_i64x4(b);
    __m512i ll=_mm512_clmulepi64_epi128(va,vb,0x00), hh=_mm512_clmulepi64_epi128(va,vb,0x11);
    __m512i md=_mm512_xor_si512(_mm512_clmulepi64_epi128(va,vb,0x01),_mm512_clmulepi64_epi128(va,vb,0x10));
    __m512i L=_mm512_xor_si512(ll,_mm512_bslli_epi128(md,8)), H=_mm512_xor_si512(hh,_mm512_bsrli_epi128(md,8));
    /* lanes k: 0 = a01 b01 (limbs 0..3), 1 = a01 b23 (2..5), 2 = a23 b01 (2..5), 3 = a23 b23 (4..7)
     * R8 (128-bit lanes) = [L0, H0^L1^L2, H1^H2^L3, H3] = T1 ^ T2 ^ T3 */
    __m512i T1=_mm512_permutex2var_epi64(L,_mm512_set_epi64(15,14,7,6,3,2,1,0),H);      /* L0 L1 L3 H3 */
    __m512i T2=_mm512_maskz_permutex2var_epi64(0x3C,L,_mm512_set_epi64(0,0,11,10,5,4,0,0),H);   /* 0 L2 H1 0 */
    __m512i T3=_mm512_maskz_permutex2var_epi64(0x3C,L,_mm512_set_epi64(0,0,13,12,9,8,0,0),H);   /* 0 H0 H2 0 */
    return phv_red2(_mm512_ternarylogic_epi64(T1,T2,T3,0x96)); }
static inline __m256i phv_sq(__m256i a){
    __m512i va=_mm512_permutexvar_epi64(_mm512_set_epi64(3,3,2,2,1,1,0,0),_mm512_castsi256_si512(a));   /* a_i in both qwords of lane i */
    return phv_red2(_mm512_clmulepi64_epi128(va,va,0x00)); }

/* ---- Zen 4 latency variants (bit-identical; mulz.c: Zen 4 mul 35.5 -> 28.3, sq 20 -> 17.3 ticks; slower on Ice Lake) ---- */
/* (lo, hi) 512-bit -> reduced: lo + hi*g, g = 1 + x^2 + x^5 + x^10 (0x425), by clmul */
static inline __m256i phv_ry(__m256i lo,__m256i hi){
    const __m256i G=_mm256_set1_epi64x(0x425);
    __m256i pe=_mm256_clmulepi64_epi128(hi,G,0x00);                 /* [h0 g @ limb0, h2 g @ limb2] */
    __m256i po=_mm256_clmulepi64_epi128(hi,G,0x01);                 /* [h1 g @ limb1, h3 g @ limb3] (shifted by one limb) */
    __m256i pol=_mm256_bslli_epi128(po,8), poh=_mm256_bsrli_epi128(po,8);    /* in-lane: low parts; high parts (to the next lane) */
    __m256i up=_mm256_permute2x128_si256(poh,poh,0x08);            /* [0, h1g_hi] */
    __m256i ov=_mm256_permute2x128_si256(poh,poh,0x81);            /* [h3g_hi (limb 4: <= 10 bits), 0] */
    __m256i r=_mm256_ternarylogic_epi64(_mm256_ternarylogic_epi64(lo,pe,pol,0x96),up,_mm256_clmulepi64_epi128(ov,G,0x00),0x96);
    return r; }
static inline __m256i phv_muly(__m256i a,__m256i b){
    __m256i alo=_mm256_permute4x64_epi64(a,0x44), ahi=_mm256_permute4x64_epi64(a,0xEE);      /* [a0 a1 a0 a1], [a2 a3 a2 a3] */
    __m256i l1=_mm256_clmulepi64_epi128(alo,b,0x00), h1=_mm256_clmulepi64_epi128(alo,b,0x11), m1=_mm256_xor_si256(_mm256_clmulepi64_epi128(alo,b,0x01),_mm256_clmulepi64_epi128(alo,b,0x10));
    __m256i l2=_mm256_clmulepi64_epi128(ahi,b,0x00), h2=_mm256_clmulepi64_epi128(ahi,b,0x11), m2=_mm256_xor_si256(_mm256_clmulepi64_epi128(ahi,b,0x01),_mm256_clmulepi64_epi128(ahi,b,0x10));
    __m256i L1=_mm256_xor_si256(l1,_mm256_bslli_epi128(m1,8)), H1=_mm256_xor_si256(h1,_mm256_bsrli_epi128(m1,8));   /* lane k: 256-bit (L,H) of a_lo * b_k */
    __m256i L2=_mm256_xor_si256(l2,_mm256_bslli_epi128(m2,8)), H2=_mm256_xor_si256(h2,_mm256_bsrli_epi128(m2,8));
    __m256i U=_mm256_xor_si256(H1,L2);
    __m256i lo=_mm256_xor_si256(L1,_mm256_permute2x128_si256(U,U,0x08)), hi=_mm256_xor_si256(H2,_mm256_permute2x128_si256(U,U,0x81));
    return phv_ry(lo,hi); }
static inline __m256i phv_sqy(__m256i a){                             /* a_i^2 at limb 2i */
    __m256i s01=_mm256_permute4x64_epi64(a,0x50), s23=_mm256_permute4x64_epi64(a,0xFA);   /* [a0 a0 a1 a1], [a2 a2 a3 a3] */
    return phv_ry(_mm256_clmulepi64_epi128(s01,s01,0x00),_mm256_clmulepi64_epi128(s23,s23,0x00)); }
#ifndef PHX_IRED
#define PHX_IRED phv_red2
#endif
static inline __m256i phv_ld(ph_el e){ return _mm256_loadu_si256((const __m256i*)e.w); }
static inline ph_el phv_st(__m256i v){ ph_el e; _mm256_storeu_si256((__m256i*)e.w,v); return e; }
/* 256-bit integer add in registers (no scalar store -> vector load round trip: it cannot store-forward on Intel):
 * per-limb sums, generate G = (s < a), propagate P = (s == ~0); limbs receiving a carry = ((G<<1) + P) ^ P */
static inline __m256i phv_addint(__m256i a,__m256i b){
    __m256i s=_mm256_add_epi64(a,b);
    unsigned g=_mm256_cmplt_epu64_mask(s,a), pp=_mm256_cmpeq_epi64_mask(s,_mm256_set1_epi64x(-1));
    unsigned c=(((g<<1)+pp)^pp)&0xF;
    return _mm256_mask_add_epi64(s,(__mmask8)c,s,_mm256_set1_epi64x(1)); }
static inline __m256i phv_final_z(__m256i v,const ph_key*K);
static inline __m256i phv_final(__m256i v,const ph_key*K){
    __m256i X=phv_addint(v,phv_ld(K->tau)), G=phv_sq(X);
    __m256i t=phv_mul(_mm256_xor_si256(G,phv_ld(K->c[0])),_mm256_ternarylogic_epi64(X,G,phv_ld(K->c[1]),0x96));
    return _mm256_xor_si256(phv_mul(_mm256_xor_si256(X,phv_ld(K->c[2])),_mm256_xor_si256(t,phv_ld(K->c[3]))),phv_ld(K->c[4])); }
static inline __m256i phv_final_z(__m256i v,const ph_key*K){
    __m256i X=phv_addint(v,phv_ld(K->tau)), G=phv_sqy(X);
    __m256i t=phv_muly(_mm256_xor_si256(G,phv_ld(K->c[0])),_mm256_ternarylogic_epi64(X,G,phv_ld(K->c[1]),0x96));
    return _mm256_xor_si256(phv_muly(_mm256_xor_si256(X,phv_ld(K->c[2])),_mm256_xor_si256(t,phv_ld(K->c[3]))),phv_ld(K->c[4])); }
#define PHX_FINAL(x,v) ((x)->zen? phv_final_z(v,&(x)->K) : phv_final(v,&(x)->K))
/* v1.2: finalize and store (Intel: the xmm finalizer) */
/* v1.2: finalize (xmm) and store; Intel and Zen 4 variants (same values) */
PHQ_INL void phq_finst(const phx_key*x,phq V,uint8_t out[32]){ if(x->zen) phq_st(phq_final(V,&x->QF),out); else phq_st(phq_final_i(V,&x->QF),out); }
#define PHX_MUL(x,a,b) ((x)->zen? phv_muly(a,b) : phv_mul(a,b))
/* 9 point sums (128-bit each, xmm) -> element: interpolate into a 512-bit zmm, reduce */
static inline __m256i phv_interp_(const __m128i q[9],int zen){
    /* inner(a,b,c) = a + m x^64 + b x^128 (256-bit), m = a^b^c */
#define PHV_INNER(a,b,c) ({ __m128i m_=_mm_ternarylogic_epi64(a,b,c,0x96); __m256i ab_=_mm256_inserti128_si256(_mm256_castsi128_si256(a),b,1); \
        __m256i ms_=_mm256_maskz_permutexvar_epi64(0x6,_mm256_set_epi64x(0,1,0,0),_mm256_castsi128_si256(m_)); _mm256_xor_si256(ab_,ms_); })
    __m256i LO=PHV_INNER(q[0],q[1],q[2]), HI=PHV_INNER(q[3],q[4],q[5]), MI=PHV_INNER(q[6],q[7],q[8]);
    MI=_mm256_ternarylogic_epi64(MI,LO,HI,0x96);
    __m512i r=_mm512_inserti64x4(_mm512_castsi256_si512(LO),HI,1);
    __m512i mi=_mm512_maskz_permutexvar_epi64(0x3C,_mm512_set_epi64(0,0,3,2,1,0,0,0),_mm512_castsi256_si512(MI));
    __m512i rr=_mm512_xor_si512(r,mi); return zen? phv_ry(_mm512_castsi512_si256(rr),_mm512_extracti64x4_epi64(rr,1)) : PHX_IRED(rr); }
static inline __m256i phv_interp(const __m128i q[9]){ return phv_interp_(q,0); }
/* scalar point sums (9 x 128-bit) -> element */
static inline ph_el phx_interp_scalar(const uint64_t q[9][2]){
    uint64_t LO[4],HI[4],MI[4],r[8];
#define PHX_SINNER(L,a,b,c) do{ uint64_t ml=q[a][0]^q[b][0]^q[c][0], mh=q[a][1]^q[b][1]^q[c][1]; (L)[0]=q[a][0]; (L)[1]=q[a][1]^ml; (L)[2]=q[b][0]^mh; (L)[3]=q[b][1]; }while(0)
    PHX_SINNER(LO,0,1,2); PHX_SINNER(HI,3,4,5); PHX_SINNER(MI,6,7,8);
    for(int l=0;l<4;l++) MI[l]^=LO[l]^HI[l];
    r[0]=LO[0]; r[1]=LO[1]; r[2]=LO[2]^MI[0]; r[3]=LO[3]^MI[1]; r[4]=HI[0]^MI[2]; r[5]=HI[1]^MI[3]; r[6]=HI[2]; r[7]=HI[3];
    return phx_red8(r); }
/* region pair loop: accumulate the 9 points x E/O of pairs [0, PH_M) into A[18] (A[2p] = E, A[2p+1] = O) */
#define PHX_PAIR(A,XR,YR,KX,KY) do{ \
        __m512i x0=_mm512_xor_si512(_mm512_loadu_si512((const void*)((XR))),(KX)[0]), x1=_mm512_xor_si512(_mm512_loadu_si512((const void*)((XR)+64)),(KX)[1]); \
        __m512i x2=_mm512_xor_si512(_mm512_loadu_si512((const void*)((XR)+128)),(KX)[2]), x3=_mm512_xor_si512(_mm512_loadu_si512((const void*)((XR)+192)),(KX)[3]); \
        __m512i y0=_mm512_xor_si512(_mm512_loadu_si512((const void*)((YR))),(KY)[0]), y1=_mm512_xor_si512(_mm512_loadu_si512((const void*)((YR)+64)),(KY)[1]); \
        __m512i y2=_mm512_xor_si512(_mm512_loadu_si512((const void*)((YR)+128)),(KY)[2]), y3=_mm512_xor_si512(_mm512_loadu_si512((const void*)((YR)+192)),(KY)[3]); \
        __m512i X[9],Yv[9]; PHX_EVAL(X,x0,x1,x2,x3); PHX_EVAL(Yv,y0,y1,y2,y3); \
        for(int p_=0;p_<9;p_++){ (A)[2*p_]=_mm512_xor_si512((A)[2*p_],_mm512_clmulepi64_epi128(X[p_],Yv[p_],0x00)); \
                                 (A)[2*p_+1]=_mm512_xor_si512((A)[2*p_+1],_mm512_clmulepi64_epi128(X[p_],Yv[p_],0x11)); } }while(0)
static inline void phx_key_init0(phx_key*x,const ph_key*K){
    for(int i=0;i<PH_M;i++) for(int l=0;l<4;l++){ x->KBc[i][l]=_mm512_set1_epi64((long long)K->k[i].w[l]); x->KBc[i][4+l]=_mm512_set1_epi64((long long)K->l[i].w[l]); }
    for(int i=0;i<PH_M;i++){ for(int l=0;l<4;l++){ x->KS[i][l]=K->k[i].w[l]; x->KS[i][4+l]=K->l[i].w[l]; }
        x->KS[i][8]=K->k[i].w[0]^K->k[i].w[2]; x->KS[i][9]=K->k[i].w[1]^K->k[i].w[3]; x->KS[i][10]=K->l[i].w[0]^K->l[i].w[2]; x->KS[i][11]=K->l[i].w[1]^K->l[i].w[3]; }
    x->K=*K; x->yp[0]=(ph_el){{1,0,0,0}}; for(int i=1;i<=8;i++) x->yp[i]=phx_mul(x->yp[i-1],K->Y); x->Y8=x->yp[8];
    uint64_t p[9]; ph_eval9(&x->Y8,p); for(int t=0;t<9;t++) x->YP8[t]=_mm512_set1_epi64((long long)p[t]);
    for(int pr=0;pr<8;pr++){ uint64_t a[9][8]; for(int b=0;b<8;b++){ int e=((pr-1-b)%8+8)%8; uint64_t q[9]; ph_eval9(&x->yp[e],q); for(int t=0;t<9;t++) a[t][b]=q[t]; }
        for(int t=0;t<9;t++) x->PR[pr][t]=_mm512_loadu_si512(a[t]); }
    for(int g=0;g<PH_M/8;g++) for(int l=0;l<4;l++){ uint64_t a[8],b[8]; for(int t=0;t<8;t++){ a[t]=K->k[8*g+t].w[l]; b[t]=K->l[8*g+t].w[l]; }
        x->KT[g][l]=_mm512_loadu_si512(a); x->KT[g][4+l]=_mm512_loadu_si512(b); }
    /* suffix sums of key-only groups (x = y = 0 -> operands are the keys) */
    __m512i z=_mm512_setzero_si512(), A[18]; for(int t=0;t<18;t++){ A[t]=z; x->SF[PH_M/8][t]=z; }
    for(int g=PH_M/8-1;g>=0;g--){ __m512i X[9],Yv[9]; PHX_EVAL(X,x->KT[g][0],x->KT[g][1],x->KT[g][2],x->KT[g][3]); PHX_EVAL(Yv,x->KT[g][4],x->KT[g][5],x->KT[g][6],x->KT[g][7]);
        for(int t=0;t<9;t++){ A[2*t]=_mm512_xor_si512(A[2*t],_mm512_clmulepi64_epi128(X[t],Yv[t],0x00)); A[2*t+1]=_mm512_xor_si512(A[2*t+1],_mm512_clmulepi64_epi128(X[t],Yv[t],0x11)); }
        for(int t=0;t<18;t++) x->SF[g][t]=A[t]; }
    for(int g=0;g<=PH_M/8;g++) for(int t=0;t<9;t++) x->SF9[g][t]=_mm512_xor_si512(x->SF[g][2*t],x->SF[g][2*t+1]);
    x->ZQ=_mm512_set_epi64(0,(long long)K->z.w[3],0,(long long)K->z.w[2],0,(long long)K->z.w[1],0,(long long)K->z.w[0]);
    for(int l=0;l<4;l++){ uint64_t a[8]={0},b[8]; for(int c=0;c<4;c++){ a[c]=x->yp[2*c+1].w[l]; b[c]=x->yp[2*c+2].w[l]; b[4+c]=K->z.w[l]; }
        x->YO[l]=_mm512_loadu_si512(a); x->YEZ[l]=_mm512_loadu_si512(b); }
    x->YQ=_mm512_set_epi64(0,(long long)K->Y.w[3],0,(long long)K->Y.w[2],0,(long long)K->Y.w[1],0,(long long)K->Y.w[0]);
    x->C0=_mm256_setzero_si256();                 /* set after phx_tblkv is defined: phx_key_init_c0 */
}
/* two pairs per step, point-major: per point p the operands of both pairs, 4 clmul, 2 ternlog accumulates.
 * Mid points reuse the keyed hi limbs: X02 = X2' ^ k0 ^ x0 (x0 re-read from L1), so only ~6 operands are live. */
#define PHX_T3(a,b,c) _mm512_ternarylogic_epi64(a,b,c,0x96)
#define PHX_LD(p) _mm512_loadu_si512((const void*)(p))
#define PHX_ACC2(p,Xa,Ya,Xb,Yb) do{ A[2*(p)]=PHX_T3(A[2*(p)],_mm512_clmulepi64_epi128(Xa,Ya,0x00),_mm512_clmulepi64_epi128(Xb,Yb,0x00)); \
        A[2*(p)+1]=PHX_T3(A[2*(p)+1],_mm512_clmulepi64_epi128(Xa,Ya,0x11),_mm512_clmulepi64_epi128(Xb,Yb,0x11)); }while(0)
#define PHX_BAR() do{ __asm__ volatile("" : "+v"(A[0]),"+v"(A[1]),"+v"(A[2]),"+v"(A[3]),"+v"(A[4]),"+v"(A[5]),"+v"(A[6]),"+v"(A[7]),"+v"(A[8])); \
        __asm__ volatile("" : "+v"(A[9]),"+v"(A[10]),"+v"(A[11]),"+v"(A[12]),"+v"(A[13]),"+v"(A[14]),"+v"(A[15]),"+v"(A[16]),"+v"(A[17])); }while(0)
/* pairs at ra (x at ra, y at ra+256) and rb, keys KA[8], KB[8] (x limbs 0..3, y limbs 4..7) */
#define PHX_PAIR2(ra,rb,KA,KB) do{ \
        __m512i ax0=_mm512_xor_si512(PHX_LD(ra),(KA)[0]), ay0=_mm512_xor_si512(PHX_LD((ra)+256),(KA)[4]), bx0=_mm512_xor_si512(PHX_LD(rb),(KB)[0]), by0=_mm512_xor_si512(PHX_LD((rb)+256),(KB)[4]); \
        PHX_ACC2(0,ax0,ay0,bx0,by0); \
        __m512i ax1=_mm512_xor_si512(PHX_LD((ra)+64),(KA)[1]), ay1=_mm512_xor_si512(PHX_LD((ra)+320),(KA)[5]), bx1=_mm512_xor_si512(PHX_LD((rb)+64),(KB)[1]), by1=_mm512_xor_si512(PHX_LD((rb)+320),(KB)[5]); \
        PHX_ACC2(1,ax1,ay1,bx1,by1); \
        PHX_ACC2(2,_mm512_xor_si512(ax0,ax1),_mm512_xor_si512(ay0,ay1),_mm512_xor_si512(bx0,bx1),_mm512_xor_si512(by0,by1)); \
        __m512i ax2=_mm512_xor_si512(PHX_LD((ra)+128),(KA)[2]), ay2=_mm512_xor_si512(PHX_LD((ra)+384),(KA)[6]), bx2=_mm512_xor_si512(PHX_LD((rb)+128),(KB)[2]), by2=_mm512_xor_si512(PHX_LD((rb)+384),(KB)[6]); \
        PHX_ACC2(3,ax2,ay2,bx2,by2); \
        PHX_ACC2(6,_mm512_xor_si512(ax0,ax2),_mm512_xor_si512(ay0,ay2),_mm512_xor_si512(bx0,bx2),_mm512_xor_si512(by0,by2)); \
        __m512i ax3=_mm512_xor_si512(PHX_LD((ra)+192),(KA)[3]), ay3=_mm512_xor_si512(PHX_LD((ra)+448),(KA)[7]), bx3=_mm512_xor_si512(PHX_LD((rb)+192),(KB)[3]), by3=_mm512_xor_si512(PHX_LD((rb)+448),(KB)[7]); \
        PHX_ACC2(4,ax3,ay3,bx3,by3); \
        __m512i ax13=_mm512_xor_si512(ax1,ax3), ay13=_mm512_xor_si512(ay1,ay3), bx13=_mm512_xor_si512(bx1,bx3), by13=_mm512_xor_si512(by1,by3); \
        PHX_ACC2(7,ax13,ay13,bx13,by13); \
        __m512i ax23=_mm512_xor_si512(ax2,ax3), ay23=_mm512_xor_si512(ay2,ay3), bx23=_mm512_xor_si512(bx2,bx3), by23=_mm512_xor_si512(by2,by3); \
        PHX_ACC2(5,ax23,ay23,bx23,by23); \
        PHX_ACC2(8,PHX_T3(ax0,ax1,ax23),PHX_T3(ay0,ay1,ay23),PHX_T3(bx0,bx1,bx23),PHX_T3(by0,by1,by23)); \
        PHX_BAR(); }while(0)
/* one region: s (limb-major chain state) <- s Y^8 + c_b */
#define PHX_KB(i,j) _mm512_set1_epi64((long long)x->KS[i][j])       /* embedded-broadcast key operand */
#if !defined(PHX_1P) && !defined(PHX_3P) && PH_M>=64
#define PHX_3P 1                                   /* 4 KiB blocks: 3-pass (measured best on clang and gcc) */
#if !defined(PHX_SEG) && !defined(PHX_NOSEG)
#define PHX_SEG 16                                 /* v1.1: passes per 16-pair (8 KiB) segment + trickle prefetch of the next */
#endif
#endif
#ifdef PHX_3P
/* 3-pass split (PH-512 style): pass M = mix points 6,7,8 from m0 = x0^x2, m1 = x1^x3 (reads all limbs: pulls the
 * region into L1); pass L = points 0,1,2 from limbs 0,1; pass H = points 3,4,5 from limbs 2,3.  6 accumulators per
 * pass, two pairs per step (one ternlog per two products); no spills.  Same point sums as the single pass. */
#define PHX_P3STEP(PA,PB,PC,xa0,xa1,ya0,ya1,xb0,xb1,yb0,yb1) do{ \
        PHX_ACC2(PA,xa0,ya0,xb0,yb0); PHX_ACC2(PB,xa1,ya1,xb1,yb1); \
        PHX_ACC2(PC,_mm512_xor_si512(xa0,xa1),_mm512_xor_si512(ya0,ya1),_mm512_xor_si512(xb0,xb1),_mm512_xor_si512(yb0,yb1)); }while(0)
/* pass M (mix points 6,7,8) over pairs [i0, i1) */
#if (defined(__GNUC__) && !defined(__clang__) && !defined(PHX_INL))
#define PHX_PASSKW static __attribute__((noinline))   /* gcc: out of line (inlined into the region driver it spills); build with -O3 (Xeon: -O2 89%, -O3 95% of bound) */
#else
#define PHX_PASSKW static inline
#endif
#ifdef PHX_SEG
#define PHX_SGN PHX_SEG
#else
#define PHX_SGN PH_M
#endif
#undef PHX_KB
#define PHX_KB(i,j) _mm512_set1_epi64((long long)KSb[i][j])       /* embedded-broadcast key operand (segment-relative rows) */
PHX_PASSKW void phx_passM(const uint64_t (*KSb)[12],const uint8_t*R,__m512i A[18]){ enum { i0=0, i1=PHX_SGN };
    __m512i a12=A[12],a13=A[13],a14=A[14],a15=A[15],a16=A[16],a17=A[17];
    PHX_UNROLL
    for(int i=i0;i<i1;i+=2){ const uint8_t*ra=R+512*i, *rb=ra+512;
        __m512i xa0=PHX_T3(PHX_LD(ra),PHX_LD(ra+128),PHX_KB(i,8)), xa1=PHX_T3(PHX_LD(ra+64),PHX_LD(ra+192),PHX_KB(i,9));
        __m512i ya0=PHX_T3(PHX_LD(ra+256),PHX_LD(ra+384),PHX_KB(i,10)), ya1=PHX_T3(PHX_LD(ra+320),PHX_LD(ra+448),PHX_KB(i,11));
        __m512i xb0=PHX_T3(PHX_LD(rb),PHX_LD(rb+128),PHX_KB(i+1,8)), xb1=PHX_T3(PHX_LD(rb+64),PHX_LD(rb+192),PHX_KB(i+1,9));
        __m512i yb0=PHX_T3(PHX_LD(rb+256),PHX_LD(rb+384),PHX_KB(i+1,10)), yb1=PHX_T3(PHX_LD(rb+320),PHX_LD(rb+448),PHX_KB(i+1,11));
        a12=PHX_T3(a12,_mm512_clmulepi64_epi128(xa0,ya0,0x00),_mm512_clmulepi64_epi128(xb0,yb0,0x00)); a13=PHX_T3(a13,_mm512_clmulepi64_epi128(xa0,ya0,0x11),_mm512_clmulepi64_epi128(xb0,yb0,0x11));
        a14=PHX_T3(a14,_mm512_clmulepi64_epi128(xa1,ya1,0x00),_mm512_clmulepi64_epi128(xb1,yb1,0x00)); a15=PHX_T3(a15,_mm512_clmulepi64_epi128(xa1,ya1,0x11),_mm512_clmulepi64_epi128(xb1,yb1,0x11));
        __m512i xa=_mm512_xor_si512(xa0,xa1), ya=_mm512_xor_si512(ya0,ya1), xb=_mm512_xor_si512(xb0,xb1), yb=_mm512_xor_si512(yb0,yb1);
        a16=PHX_T3(a16,_mm512_clmulepi64_epi128(xa,ya,0x00),_mm512_clmulepi64_epi128(xb,yb,0x00)); a17=PHX_T3(a17,_mm512_clmulepi64_epi128(xa,ya,0x11),_mm512_clmulepi64_epi128(xb,yb,0x11));
        __asm__ volatile("" : "+v"(a12),"+v"(a13),"+v"(a14),"+v"(a15),"+v"(a16),"+v"(a17)); }
    A[12]=a12; A[13]=a13; A[14]=a14; A[15]=a15; A[16]=a16; A[17]=a17; }
/* passes L (limbs 0,1 -> points 0,1,2) and H (limbs 2,3 -> points 3,4,5) over pairs [i0, i1); if pf: trickle-prefetch
 * the next segment (nb bytes at pf) into L1, spread over the iterations of both passes */
PHX_PASSKW void phx_passLH(const uint64_t (*KSb)[12],const uint8_t*R,__m512i A[18],const uint8_t*pf,size_t nb){ enum { i0=0, i1=PHX_SGN };
    (void)nb;   /* the next segment (SGN*512 bytes = SGN*8 lines) is prefetched 8 lines per iteration: 2 passes x SGN/2 iterations */
    PHX_HPUNROLL                                  /* clang: unrolled (else 3P is 20% slower); gcc: kept as a loop (else 40% slower) */
    for(int hp=0;hp<2;hp++){ int o=128*hp, kb=2*hp, P=6*hp;
      __m512i a0=A[P],a1=A[P+1],a2=A[P+2],a3=A[P+3],a4=A[P+4],a5=A[P+5];
      PHX_UNROLL
      for(int i=i0;i<i1;i+=2){ const uint8_t*ra=R+512*i+o, *rb=ra+512;
#ifdef PHX_SEG
        if(pf){ const char*pp=(const char*)pf+512*(hp*(i1-i0)/2+(i-i0)/2);
            _mm_prefetch(pp,_MM_HINT_T0); _mm_prefetch(pp+64,_MM_HINT_T0); _mm_prefetch(pp+128,_MM_HINT_T0); _mm_prefetch(pp+192,_MM_HINT_T0);
            _mm_prefetch(pp+256,_MM_HINT_T0); _mm_prefetch(pp+320,_MM_HINT_T0); _mm_prefetch(pp+384,_MM_HINT_T0); _mm_prefetch(pp+448,_MM_HINT_T0); }
#endif
        __m512i xa0=_mm512_xor_si512(PHX_LD(ra),PHX_KB(i,kb)), xa1=_mm512_xor_si512(PHX_LD(ra+64),PHX_KB(i,kb+1)), ya0=_mm512_xor_si512(PHX_LD(ra+256),PHX_KB(i,4+kb)), ya1=_mm512_xor_si512(PHX_LD(ra+320),PHX_KB(i,5+kb));
        __m512i xb0=_mm512_xor_si512(PHX_LD(rb),PHX_KB(i+1,kb)), xb1=_mm512_xor_si512(PHX_LD(rb+64),PHX_KB(i+1,kb+1)), yb0=_mm512_xor_si512(PHX_LD(rb+256),PHX_KB(i+1,4+kb)), yb1=_mm512_xor_si512(PHX_LD(rb+320),PHX_KB(i+1,5+kb));
        a0=PHX_T3(a0,_mm512_clmulepi64_epi128(xa0,ya0,0x00),_mm512_clmulepi64_epi128(xb0,yb0,0x00)); a1=PHX_T3(a1,_mm512_clmulepi64_epi128(xa0,ya0,0x11),_mm512_clmulepi64_epi128(xb0,yb0,0x11));
        a2=PHX_T3(a2,_mm512_clmulepi64_epi128(xa1,ya1,0x00),_mm512_clmulepi64_epi128(xb1,yb1,0x00)); a3=PHX_T3(a3,_mm512_clmulepi64_epi128(xa1,ya1,0x11),_mm512_clmulepi64_epi128(xb1,yb1,0x11));
        __m512i xa=_mm512_xor_si512(xa0,xa1), ya=_mm512_xor_si512(ya0,ya1), xb=_mm512_xor_si512(xb0,xb1), yb=_mm512_xor_si512(yb0,yb1);
        a4=PHX_T3(a4,_mm512_clmulepi64_epi128(xa,ya,0x00),_mm512_clmulepi64_epi128(xb,yb,0x00)); a5=PHX_T3(a5,_mm512_clmulepi64_epi128(xa,ya,0x11),_mm512_clmulepi64_epi128(xb,yb,0x11));
        __asm__ volatile("" : "+v"(a0),"+v"(a1),"+v"(a2),"+v"(a3),"+v"(a4),"+v"(a5)); }
      A[P]=a0; A[P+1]=a1; A[P+2]=a2; A[P+3]=a3; A[P+4]=a4; A[P+5]=a5; }
    }
#undef PHX_KB
#define PHX_KB(i,j) _mm512_set1_epi64((long long)x->KS[i][j])
static inline void phx_region_acc(const phx_key*x,const uint8_t*R,__m512i A[18]){
    for(int i0=0;i0<PH_M;i0+=PHX_SGN){ phx_passM(x->KS+i0,R+512*i0,A); phx_passLH(x->KS+i0,R+512*i0,A,0,0); } }
#else
static inline void phx_region_acc(const phx_key*x,const uint8_t*R,__m512i A[18]){
#ifdef PHX_KB1
    PHX_UNROLL
    for(int i=0;i<PH_M;i+=2){ const uint8_t*r=R+512*i; __m512i KA[8],KB2[8]; for(int j=0;j<8;j++){ KA[j]=PHX_KB(i,j); KB2[j]=PHX_KB(i+1,j); } PHX_PAIR2(r,r+512,KA,KB2); }
#else
    const __m512i*KB=&x->KBc[0][0];
    PHX_UNROLL
    for(int i=0;i<PH_M;i+=2){ const uint8_t*r=R+512*i; PHX_PAIR2(r,r+512,KB+8*i,KB+8*(i+1)); }
#endif
    }
#endif
/* Horner (earlier outer stage) region: s (limb-major stride classes) <- s Y^8 + c_b -- kept for comparisons */
static inline void phx_region(const phx_key*x,const uint8_t*R,__m512i s[4]){
    __m512i A[18], S[9]; PHX_EVAL(S,s[0],s[1],s[2],s[3]);
    for(int t=0;t<9;t++){ A[2*t]=_mm512_clmulepi64_epi128(S[t],x->YP8[t],0x00); A[2*t+1]=_mm512_clmulepi64_epi128(S[t],x->YP8[t],0x11); }
    phx_region_acc(x,R,A);
    phx_p Q[9]; for(int t=0;t<9;t++) Q[t]=phx_unpack(A[2*t],A[2*t+1]);
    phx_interp_reduce(Q,s); }
/* 2L region: the 8 block values (limb-major, lane b = block b), then ONE packed 8-lane multiply:
 *   lanes 0..3: (b_c + y^(2c+1)) (b_{c+4} + y^(2c+2))   (the region's pair products)
 *   lanes 4..7: acc_c * z                               (the per-pair-lane z-chains)
 * and acc_c <- product_c + product_{c+4} (lanes 4..7).  V = sum of the 4 chain lanes at the end. */
static inline void phx_epi2l(const phx_key*x,const __m512i A[18],__m512i acc[4]){
    phx_p Q[9]; for(int t=0;t<9;t++) Q[t]=phx_unpack(A[2*t],A[2*t+1]);
    __m512i B[4]; phx_interp_reduce(Q,B);
    const __m512i up=_mm512_set_epi64(3,2,1,0,3,2,1,0), dn=_mm512_set_epi64(0,0,0,0,7,6,5,4);
    __m512i Xl[4],Yl[4];
    for(int l=0;l<4;l++){ Xl[l]=_mm512_mask_blend_epi64(0xF0,_mm512_xor_si512(B[l],x->YO[l]),acc[l]);
                          Yl[l]=_mm512_xor_si512(_mm512_maskz_permutexvar_epi64(0x0F,dn,B[l]),x->YEZ[l]); }
    __m512i Xp[9],Yp[9]; PHX_EVAL(Xp,Xl[0],Xl[1],Xl[2],Xl[3]); PHX_EVAL(Yp,Yl[0],Yl[1],Yl[2],Yl[3]);
    for(int t=0;t<9;t++) Q[t]=phx_unpack(_mm512_clmulepi64_epi128(Xp[t],Yp[t],0x00),_mm512_clmulepi64_epi128(Xp[t],Yp[t],0x11));
    __m512i P[4]; phx_interp_reduce(Q,P);
    for(int l=0;l<4;l++) acc[l]=_mm512_xor_si512(P[l],_mm512_permutexvar_epi64(up,P[l])); }
static inline void phx_region2l(const phx_key*x,const uint8_t*R,__m512i acc[4]){
    __m512i A[18]; for(int t=0;t<18;t++) A[t]=_mm512_setzero_si512();
    phx_region_acc(x,R,A); phx_epi2l(x,A,acc); }
/* nr full regions, schedule-only variants (same values):
 *   PHX_PIPE: the epilogue of region r (interpolate, reduce, pair multiply, chain) is issued after the first pass-M
 *             segment of region r+1, so its latency chain overlaps independent work;
 *   PHX_SEG=S: the three passes run per segment of S pairs (S*512 bytes stay in L1) and the next segment is
 *             trickle-prefetched during the L1-resident passes L/H. */
static inline void phx_regions2l(const phx_key*x,const uint8_t*msg,size_t nr,__m512i acc[4]){
#if defined(PHX_3P) && (defined(PHX_PIPE) || defined(PHX_SEG))
#ifdef PHX_SEG
    enum { SG=PHX_SEG };
#else
    enum { SG=PH_M };
#endif
    __m512i A[2][18]; int cur=0;
    for(size_t r=0;r<nr;r++){ const uint8_t*R=msg+r*PH_REGION; __m512i*Ac=A[cur];
        for(int t=0;t<18;t++) Ac[t]=_mm512_setzero_si512();
        for(int i0=0;i0<PH_M;i0+=SG){ int i1=i0+SG;
            phx_passM(x->KS+i0,R+512*i0,Ac);
#ifdef PHX_PIPE
            if(i0==0 && r) phx_epi2l(x,A[cur^1],acc);
#endif
            const uint8_t*pf= (i1<PH_M)? R+512*i1 : (r+1<nr? R+PH_REGION : 0);
            phx_passLH(x->KS+i0,R+512*i0,Ac,pf,(size_t)SG*512); }
#ifdef PHX_PIPE
        cur^=1; }
    if(nr) phx_epi2l(x,A[cur^1],acc);
#else
        phx_epi2l(x,Ac,acc); }
#endif
#else
    for(size_t r=0;r<nr;r++) phx_region2l(x,msg+r*PH_REGION,acc);
#endif
    }
/* one tail block (zero padded to the group containing the last byte; key-only groups from the suffix table) */
static inline __m512i phx_mld(const uint8_t*p,size_t off,size_t av){          /* 64 bytes at p+off, zero beyond av */
    if(off+64<=av) return _mm512_loadu_si512((const void*)(p+off));
    if(off>=av) return _mm512_setzero_si512();
    return _mm512_maskz_loadu_epi8((((__mmask64)1)<<(av-off))-1,(const void*)(p+off)); }
/* 4 zmm -> one zmm whose 128-bit lane l = XOR of the 4 lanes of S[l] (transposed fold: 6 lane shuffles, 3 XORs) */
static inline __m512i phx_fold4(__m512i S0,__m512i S1,__m512i S2,__m512i S3){
    __m512i X01=_mm512_xor_si512(_mm512_shuffle_i64x2(S0,S1,0x44),_mm512_shuffle_i64x2(S0,S1,0xEE));
    __m512i X23=_mm512_xor_si512(_mm512_shuffle_i64x2(S2,S3,0x44),_mm512_shuffle_i64x2(S2,S3,0xEE));
    return _mm512_xor_si512(_mm512_shuffle_i64x2(X01,X23,0x88),_mm512_shuffle_i64x2(X01,X23,0xDD)); }
/* tail block: lanes = pairs; E and O products of a point go into ONE accumulator (one ternlog per 2 products),
 * the 9 lane sums by a transposed fold */
#define PHX_TPAIR(A,XR,YR,KX,KY,LD) do{ \
        __m512i x0=_mm512_xor_si512(LD(XR,0),(KX)[0]), x1=_mm512_xor_si512(LD(XR,64),(KX)[1]), x2=_mm512_xor_si512(LD(XR,128),(KX)[2]), x3=_mm512_xor_si512(LD(XR,192),(KX)[3]); \
        __m512i y0=_mm512_xor_si512(LD(YR,0),(KY)[0]), y1=_mm512_xor_si512(LD(YR,64),(KY)[1]), y2=_mm512_xor_si512(LD(YR,128),(KY)[2]), y3=_mm512_xor_si512(LD(YR,192),(KY)[3]); \
        __m512i X[9],Yv[9]; PHX_EVAL(X,x0,x1,x2,x3); PHX_EVAL(Yv,y0,y1,y2,y3); \
        for(int t_=0;t_<9;t_++) (A)[t_]=PHX_T3((A)[t_],_mm512_clmulepi64_epi128(X[t_],Yv[t_],0x00),_mm512_clmulepi64_epi128(X[t_],Yv[t_],0x11)); }while(0)
#define PHX_LDF(P,o) _mm512_loadu_si512((const void*)((P)+(o)))
#if defined(PHX_TBLK_NOINL)
#define PHX_TBLKKW static __attribute__((noinline))
#else
#define PHX_TBLKKW static inline
#endif
PHX_TBLKKW __m256i phx_tblkv(const phx_key*x,const uint8_t*p,size_t av){
    int ng= av>=PH_BLOCK? PH_M/8 : (int)((av+511)/512), nf= av>=PH_BLOCK? PH_M/8 : (int)(av/512);  /* groups with data / full groups */
    __m512i A[9]; for(int t=0;t<9;t++) A[t]=x->SF9[ng][t];
    for(int g=0;g<nf;g++){ const uint8_t*r=p+512*g; PHX_TPAIR(A,r,r+256,x->KT[g],(x->KT[g]+4),PHX_LDF); }
    if(nf<ng){ int g=nf; size_t o=(size_t)512*g; const uint8_t*r=p;            /* the partial group: masked loads */
#define PHX_LDM(P,oo) phx_mld(r,(size_t)((P)-r)+(oo),av)
        PHX_TPAIR(A,p+o,p+o+256,x->KT[g],(x->KT[g]+4),PHX_LDM); }
    __m512i F0=phx_fold4(A[0],A[1],A[2],A[3]), F1=phx_fold4(A[4],A[5],A[6],A[7]);
    __m256i h=_mm256_xor_si256(_mm512_castsi512_si256(A[8]),_mm512_extracti64x4_epi64(A[8],1));
    __m128i q[9]={_mm512_castsi512_si128(F0),_mm512_extracti64x2_epi64(F0,1),_mm512_extracti64x2_epi64(F0,2),_mm512_extracti64x2_epi64(F0,3),
                  _mm512_castsi512_si128(F1),_mm512_extracti64x2_epi64(F1,1),_mm512_extracti64x2_epi64(F1,2),_mm512_extracti64x2_epi64(F1,3),
                  _mm_xor_si128(_mm256_castsi256_si128(h),_mm256_extracti128_si256(h,1))};
    return phv_interp_(q,x->zen); }
static inline ph_el phx_tblk(const phx_key*x,const uint8_t*p,size_t av){ return phv_st(phx_tblkv(x,p,av)); }
static inline uint64_t phx_hxor(__m512i v){ __m256i h=_mm256_xor_si256(_mm512_castsi512_si256(v),_mm512_extracti64x4_epi64(v,1));
    __m128i q=_mm_xor_si128(_mm256_castsi256_si128(h),_mm256_extracti128_si256(h,1)); return (uint64_t)_mm_cvtsi128_si64(q)^(uint64_t)_mm_extract_epi64(q,1); }
/* s <- s * (per-lane point constants P[9]) (+ C), lanes in m */
static inline void phx_mulpts(__m512i s[4],const __m512i P[9]){
    __m512i S[9]; PHX_EVAL(S,s[0],s[1],s[2],s[3]); phx_p Q[9];
    for(int t=0;t<9;t++) Q[t]=phx_unpack(_mm512_clmulepi64_epi128(S[t],P[t],0x00),_mm512_clmulepi64_epi128(S[t],P[t],0x11));
    phx_interp_reduce(Q,s); }
static inline void phx_key_init_c0(phx_key*x){ static const uint8_t z[1]={0}; x->C0=phx_tblkv(x,z,0); }
/* AMD (Zen 4) -> the ymm latency variants; -DPHX_ZEN=0/1 forces either path (tests run both paths on every host) */
static inline int phx_is_amd(void){ static int cached=-1; if(cached>=0) return cached; unsigned a,b,c,d; __asm__ volatile("cpuid":"=a"(a),"=b"(b),"=c"(c),"=d"(d):"a"(0),"c"(0)); cached= b==0x68747541u && d==0x69746e65u && c==0x444d4163u; return cached; }
static inline void phx_key_init(phx_key*x,const ph_key*K){
#ifdef PHX_ZEN
    x->zen=PHX_ZEN;
#else
    x->zen=phx_is_amd();
#endif
    phx_key_init0(x,K); phx_key_init_c0(x); phq_fk_init(&x->QF,K); ph_el c0=phv_st(x->C0); phq_sk_init(&x->QS,K,&c0); }
/* n <= 64: only x limb 0 of pairs 0..7 carries data (y = 0), so c = C0 + sum_{i<8} d_i l_i; with the length term,
 * v = c + n Y = C0 + sum_i d_i l_i + n Y: all 64 x 256 products, accumulated per limb offset and reduced once. */
static inline __m256i phx_v64(const phx_key*x,const uint8_t*p,size_t n,__m512i MQ){
    __m512i D=_mm512_maskz_loadu_epi8(n>=64? ~(__mmask64)0 : ((((__mmask64)1)<<n)-1),(const void*)p);
    __m512i S[4];
    for(int l=0;l<4;l++) S[l]=_mm512_xor_si512(_mm512_clmulepi64_epi128(D,x->KT[0][4+l],0x00),_mm512_clmulepi64_epi128(D,x->KT[0][4+l],0x11));
    __m512i R=_mm512_xor_si512(phx_fold4(S[0],S[1],S[2],S[3]),_mm512_clmulepi64_epi128(_mm512_set1_epi64((long long)n),MQ,0x00));   /* lane l: 128-bit at 64 l */
    __m512i lo=_mm512_maskz_permutexvar_epi64(0x0F,_mm512_set_epi64(0,0,0,0,6,4,2,0),R), hi=_mm512_maskz_permutexvar_epi64(0x1E,_mm512_set_epi64(0,0,0,7,5,3,1,0),R);
    return _mm256_xor_si256(phv_red2(_mm512_xor_si512(lo,hi)),x->C0); }
/* v = n Y^nb + sum_b c_b Y^(nb-1-b) for nb <= 8 tail blocks: independent products (power table yp), no Horner chain */
static inline __m256i phx_tails_pow_h(const phx_key*x,const uint8_t*T,size_t rem,size_t n){
    size_t nb=(rem+PH_BLOCK-1)/PH_BLOCK;
    if(!nb) return _mm256_set_epi64x(0,0,0,(long long)n);
    if(rem<=64) return phx_v64(x,T,rem,x->YQ);    /* rem == n here (no regions) */
    __m256i v=phv_mul(_mm256_set_epi64x(0,0,0,(long long)n),phv_ld(x->yp[nb]));     /* the length as a virtual block */
    for(size_t b=0;b<nb;b++){ __m256i c=phx_tblkv(x,T+b*PH_BLOCK,rem-b*PH_BLOCK);
        v=_mm256_xor_si256(v, b==nb-1? c : phv_mul(c,phv_ld(x->yp[nb-1-b]))); }
    return v; }
/* ---- streaming API: canonical state st[l][b] = limb l of stride class b (no length) ---- */
static inline void phx_regions_h(const phx_key*x,uint64_t st[4][8],const uint8_t*msg,size_t nr){
    __m512i s[4]; for(int l=0;l<4;l++) s[l]=_mm512_loadu_si512(st[l]);
    for(size_t r=0;r<nr;r++) phx_region(x,msg+r*PH_REGION,s);
    for(int l=0;l<4;l++) _mm512_storeu_si512(st[l],s[l]); }
/* s (limb-major classes) + rem tail bytes after nreg regions -> v = sum_b s_b Y^((p-1-b) mod 8) (classes only) */
static inline __m256i phx_classes_fin(const phx_key*x,__m512i s[4],const uint8_t*T,size_t rem,size_t nreg){
    size_t nb=(rem+PH_BLOCK-1)/PH_BLOCK;
    if(nb){ uint64_t c[4][8]; memset(c,0,sizeof c); __mmask8 m=0;
        for(size_t b=0;b<nb;b++){ ph_el e=phx_tblk(x,T+b*PH_BLOCK,rem-b*PH_BLOCK); for(int l=0;l<4;l++) c[l][b]=e.w[l]; m|=(__mmask8)(1u<<b); }
        __m512i t[4]={s[0],s[1],s[2],s[3]}; phx_mulpts(t,x->YP8);
        for(int l=0;l<4;l++) s[l]=_mm512_mask_xor_epi64(s[l],m,t[l],_mm512_loadu_si512(c[l])); }
    size_t pr=(8*nreg+nb)%8; phx_mulpts(s,x->PR[pr]);
    return _mm256_set_epi64x((long long)phx_hxor(s[3]),(long long)phx_hxor(s[2]),(long long)phx_hxor(s[1]),(long long)phx_hxor(s[0])); }
static inline void phx_tailfin_h(const phx_key*x,uint64_t st[4][8],const uint8_t*T,size_t rem,size_t n,size_t nreg,uint8_t out[32]){
    if(!nreg){ _mm256_storeu_si256((__m256i*)out,phv_final(phx_tails_pow_h(x,T,rem,n),&x->K)); return; }
    __m512i s[4]; for(int l=0;l<4;l++) s[l]=_mm512_loadu_si512(st[l]);
    __m256i v=phx_classes_fin(x,s,T,rem,nreg);
    size_t nb=(rem+PH_BLOCK-1)/PH_BLOCK; __m256i y8=phv_ld(x->Y8), r=phv_ld(x->yp[nb]); size_t e=nreg;   /* Y^p = (Y^8)^nreg Y^nb */
    while(e){ if(e&1) r=phv_mul(r,y8); e>>=1; if(e) y8=phv_sq(y8); }
    v=_mm256_xor_si256(v,phv_mul(_mm256_set_epi64x(0,0,0,(long long)n),r));
    _mm256_storeu_si256((__m256i*)out,phv_final(v,&x->K)); }
static inline void phx_hash_h(const phx_key*x,const uint8_t*msg,size_t n,uint8_t out[32]){
    size_t nfull=n/PH_REGION, rem=n-nfull*PH_REGION; const uint8_t*T=msg+nfull*PH_REGION;
    if(!nfull){ _mm256_storeu_si256((__m256i*)out,phv_final(phx_tails_pow_h(x,T,rem,n),&x->K)); return; }
    __m512i z=_mm512_setzero_si512(), s[4]={_mm512_mask_mov_epi64(z,0x80,_mm512_set1_epi64((long long)n)),z,z,z};   /* length in class 7 */
    for(size_t r=0;r<nfull;r++) phx_region(x,msg+r*PH_REGION,s);
    _mm256_storeu_si256((__m256i*)out,phv_final(phx_classes_fin(x,s,T,rem,nfull),&x->K)); }

/* ---- v1.2: the <= 1-region tail on xmm: 9 point sums -> interpolation and reduction without lane crossing ---- */
/* 9 Karatsuba^2 point sums (xmm, 128 bits each) -> raw 512-bit R0..R3: inner(a,b,c) = a + (a^b^c) x^64 + b x^128 */
PHQ_INL void phq_interp_raw(const __m128i q[9],__m128i*R0,__m128i*R1,__m128i*R2,__m128i*R3){
    __m128i mL=PQ_T(q[0],q[1],q[2]), mH=PQ_T(q[3],q[4],q[5]), mM=PQ_T(q[6],q[7],q[8]);
    __m128i L0=_mm_xor_si128(q[0],_mm_slli_si128(mL,8)), L1=_mm_xor_si128(q[1],_mm_srli_si128(mL,8));
    __m128i H0=_mm_xor_si128(q[3],_mm_slli_si128(mH,8)), H1=_mm_xor_si128(q[4],_mm_srli_si128(mH,8));
    __m128i M0=_mm_xor_si128(q[6],_mm_slli_si128(mM,8)), M1=_mm_xor_si128(q[7],_mm_srli_si128(mM,8));
    *R0=L0; *R1=PQ_T(L1,PQ_T(M0,L0,H0),_mm_setzero_si128()); *R2=PQ_T(H0,PQ_T(M1,L1,H1),_mm_setzero_si128()); *R3=H1; }
/* tail block value on xmm (the accumulation as phx_tblkv, lanes = pairs) */
PHQ_INL phq phx_tblkq(const phx_key*x,const uint8_t*p,size_t av){
    int ng= av>=PH_BLOCK? PH_M/8 : (int)((av+511)/512), nf= av>=PH_BLOCK? PH_M/8 : (int)(av/512);
    __m512i A[9]; for(int t=0;t<9;t++) A[t]=x->SF9[ng][t];
    for(int g=0;g<nf;g++){ const uint8_t*r=p+512*g; PHX_TPAIR(A,r,r+256,x->KT[g],(x->KT[g]+4),PHX_LDF); }
    if(nf<ng){ int g=nf; size_t o=(size_t)512*g; const uint8_t*r=p;
        PHX_TPAIR(A,p+o,p+o+256,x->KT[g],(x->KT[g]+4),PHX_LDM); }
    __m512i F0=phx_fold4(A[0],A[1],A[2],A[3]), F1=phx_fold4(A[4],A[5],A[6],A[7]);
    __m256i h=_mm256_xor_si256(_mm512_castsi512_si256(A[8]),_mm512_extracti64x4_epi64(A[8],1));
    __m128i q[9]={_mm512_castsi512_si128(F0),_mm512_extracti64x2_epi64(F0,1),_mm512_extracti64x2_epi64(F0,2),_mm512_extracti64x2_epi64(F0,3),
                  _mm512_castsi512_si128(F1),_mm512_extracti64x2_epi64(F1,1),_mm512_extracti64x2_epi64(F1,2),_mm512_extracti64x2_epi64(F1,3),
                  _mm_xor_si128(_mm256_castsi256_si128(h),_mm256_extracti128_si256(h,1))};
    __m128i R0,R1,R2,R3; phq_interp_raw(q,&R0,&R1,&R2,&R3); phq z={_mm_setzero_si128(),_mm_setzero_si128()};
    return phq_red(R0,R1,R2,R3,z); }
/* n (< 2^64) times z, reduced: 4 clmul + the limb-4 fold (off the data path: n is known at entry) */
PHQ_INL phq phq_nz(const phq_sk*s,size_t n){
    __m128i nv=_mm_cvtsi64_si128((long long)n), Q[4]; for(int l=0;l<4;l++) Q[l]=PQ_CL(nv,s->Z[l],0x00);
    __m128i Hx=_mm_srli_si128(Q[3],8), Hp=_mm_slli_si128(Hx,8);
    __m128i s0=PQ_T(_mm_shldi_epi64(Hx,Hp,2),_mm_shldi_epi64(Hx,Hp,5),_mm_shldi_epi64(Hx,Hp,10));
    phq r={PQ_T(PQ_T(Q[0],_mm_slli_si128(Q[1],8),Hx),s0,_mm_setzero_si128()),_mm_xor_si128(Q[2],_mm_alignr_epi8(Q[3],Q[1],8))}; return r; }
/* tail region of q = nb (1..8) blocks + A (reduced, added): pairs accumulated unreduced, one reduction */
PHQ_INL phq phq_tailregion(const phx_key*x,const uint8_t*T,size_t rem,phq A){
    int q=(int)((rem+PH_BLOCK-1)/PH_BLOCK), h=(q+1)/2, f=q/2; phq a[8];
    for(int b=0;b<q;b++) a[b]=phx_tblkq(x,T+(size_t)b*PH_BLOCK,rem-(size_t)b*PH_BLOCK);
    if(q&1) A=phq_x(A,a[h-1]);
    if(!f) return A;
    __m128i R0=_mm_setzero_si128(),R1=R0,R2=R0,R3=R0;
    for(int i=1;i<=f;i++){ __m128i S0,S1,S2,S3; phq_mulraw(phq_x(a[i-1],phq_ld(&x->yp[2*i-1])),phq_x(a[h+i-1],phq_ld(&x->yp[2*i])),&S0,&S1,&S2,&S3);
        R0=_mm_xor_si128(R0,S0); R1=_mm_xor_si128(R1,S1); R2=_mm_xor_si128(R2,S2); R3=_mm_xor_si128(R3,S3); }
    return phq_red(R0,R1,R2,R3,A); }
PHQ_INL phq phq_mulz(const phx_key*x,phq v){ __m128i R0,R1,R2,R3; phq_mulraw(v,phq_ld(&x->K.z),&R0,&R1,&R2,&R3); phq z={_mm_setzero_si128(),_mm_setzero_si128()}; return phq_red(R0,R1,R2,R3,z); }
/* no full region: V = n z + c(tail region); n <= 64: phq_v64; n = 0: V = 0 */
PHQ_INL phq phq_short2l(const phx_key*x,const uint8_t*T,size_t n){
    if(!n){ phq z={_mm_setzero_si128(),_mm_setzero_si128()}; return z; }
    if(n<=64) return phq_v64(&x->QS,T,n);
    return phq_tailregion(x,T,n,phq_nz(&x->QS,n)); }
/* =========================== PH-256 v1: two-level (2L) outer stage (= ph2l_hash_ref) =========================== */
/* the tail region: q = nb tail blocks (1..7): c = sum_{i<=f} (a_i + y^(2i-1)) (a_{h+i} + y^(2i)) + [q odd] a_h */
static inline __m256i phx_tailregion(const phx_key*x,const uint8_t*T,size_t rem){
    int q=(int)((rem+PH_BLOCK-1)/PH_BLOCK), h=(q+1)/2, f=q/2; __m256i a[8];
    for(int b=0;b<q;b++) a[b]=phx_tblkv(x,T+(size_t)b*PH_BLOCK,rem-(size_t)b*PH_BLOCK);
    __m256i c= (q&1)? a[h-1] : _mm256_setzero_si256();
    for(int i=1;i<=f;i++) c=_mm256_xor_si256(c,PHX_MUL(x,_mm256_xor_si256(a[i-1],phv_ld(x->yp[2*i-1])),_mm256_xor_si256(a[h+i-1],phv_ld(x->yp[2*i]))));
    return c; }
/* no full region: V = n z + c(tail region); n <= 64: V = n z + b_1 in one pass (phx_v64); n = 0: V = 0 */
static inline __m256i phx_short2l(const phx_key*x,const uint8_t*T,size_t n){
    if(!n) return _mm256_setzero_si256();
    if(n<=64) return phx_v64(x,T,n,x->ZQ);
    return _mm256_xor_si256(phv_mul(_mm256_set_epi64x(0,0,0,(long long)n),phv_ld(x->K.z)),phx_tailregion(x,T,n)); }
/* sum of the chain lanes 4..7 of acc (limb-major) -> element */
static inline __m256i phx_chainsum(const __m512i acc[4]){
    return _mm256_set_epi64x((long long)phx_hxor(_mm512_maskz_mov_epi64(0xF0,acc[3])),(long long)phx_hxor(_mm512_maskz_mov_epi64(0xF0,acc[2])),
                             (long long)phx_hxor(_mm512_maskz_mov_epi64(0xF0,acc[1])),(long long)phx_hxor(_mm512_maskz_mov_epi64(0xF0,acc[0]))); }
/* streaming: V <- V z^nr + ... for nr FULL regions (q = 8), V reduced, no length term */
static inline void phx_fold(const phx_key*x,ph_el*V,const uint8_t*msg,size_t nr){
    const __m512i z=_mm512_setzero_si512(); __m512i acc[4];
    for(int l=0;l<4;l++) acc[l]=_mm512_mask_mov_epi64(z,0x10,_mm512_set1_epi64((long long)V->w[l]));   /* chain lane 0 */
    phx_regions2l(x,msg,nr,acc);
    _mm256_storeu_si256((__m256i*)V->w,phx_chainsum(acc)); }
/* nreg full regions already folded into V: fold the tail region (if any), add n z^{m'}, finalize */
static inline void phx_final2l(const phx_key*x,ph_el V,size_t nreg,const uint8_t*T,size_t rem,size_t n,uint8_t out[32]){
    __m256i v=phv_ld(V), zz=phv_ld(x->K.z); size_t nb=(rem+PH_BLOCK-1)/PH_BLOCK, mp=nreg+(nb>0);
    phq Q;
    if(!nreg) Q=phq_short2l(x,T,n);
    else { if(nb) v=phq_to_v(phq_tailregion(x,T,rem,phq_mulz(x,phq_from_v(v))));
        __m256i r=_mm256_set_epi64x(0,0,0,1), b=zz; size_t e=mp;                /* z^{m'} */
        while(e){ if(e&1) r=phv_mul(r,b); e>>=1; if(e) b=phv_sq(b); }
        Q=phq_from_v(_mm256_xor_si256(v,phv_mul(_mm256_set_epi64x(0,0,0,(long long)n),r))); }
    phq_finst(x,Q,out); }
/* one-shot: the length is the chain's initial value (lane 4), so V = n z^{m'} + ... falls out of the Horner in z */
static inline void phx_hash(const phx_key*x,const uint8_t*msg,size_t n,uint8_t out[32]){
    size_t nfull=n/PH_REGION, rem=n-nfull*PH_REGION; const uint8_t*T=msg+nfull*PH_REGION;
    phq V;
    if(!nfull) V=phq_short2l(x,T,n);
    else { const __m512i z=_mm512_setzero_si512(); __m512i acc[4]={_mm512_mask_mov_epi64(z,0x10,_mm512_set1_epi64((long long)n)),z,z,z};
        phx_regions2l(x,msg,nfull,acc);
        V=phq_from_v(phx_chainsum(acc)); if(rem) V=phq_tailregion(x,T,rem,phq_mulz(x,V)); }
    phq_finst(x,V,out); }
#endif
#if defined(__clang__)
#pragma clang attribute pop
#pragma clang attribute push (__attribute__((target("pclmul,sse4.1"))), apply_to=function)
#else
#pragma GCC pop_options
#pragma GCC push_options
#pragma GCC target("pclmul,sse4.1")
#endif
/* ph_sse.h -- PH-256, PCLMULQDQ + SSE4.1 backend (x86 without AVX-512).  Output = ph_hash_ref (ph_ref.h).
 *
 * Region: blocks (2c, 2c+1) share an xmm row (limb l of pair i at R + 512 i + 64 l + 16 c); per pair the operands are
 * evaluated at the 9 Karatsuba^2 points; PCLMUL 0x00 / 0x11 give the point products of the two blocks (E / O).
 * 3-pass split (16 xmm registers): pass L = points 0,1,2 from limbs 0,1; pass H = points 3,4,5 from limbs 2,3;
 * pass M = points 6,7,8 from the mixes x0^x2, x1^x3 (keys pre-mixed).  6 accumulators per pass.
 * Per block: interpolate + reduce (scalar), s_b <- s_b Y^8 + c_b.
 * Tail block: lanes = pairs; E and O products summed in one accumulator; key-only groups from suffix sums.
 * Short inputs: v = n Y^nb + sum_b c_b Y^(nb-1-b) with a power table (independent products).
 * API (v1 = two-level outer stage, = ph2l_hash_ref): phs_key_init, phs_hash, phs_fold, phs_final2l.
 * The Horner (round-7) outer stage is kept for comparisons: phs_hash_h, phs_regions_h, phs_tailfin_h. */
#ifndef PH_SSE_H
#define PH_SSE_H
#include <immintrin.h>
typedef __m128i phs_q;
typedef struct {
    ph_key K;
    phs_q KR[PH_M][12];              /* region keys, both lanes: x limbs 0..3, y limbs 0..3, mixes x02, x13, y02, y13 */
    phs_q KT[PH_M/8][4][12];         /* tail keys [group][t]: lanes = pairs 8g+2t, 8g+2t+1; same 12 slots */
    phs_q SS[PH_M/8+1][9];           /* tail suffix: point sums (E+O) of the key-only groups >= g */
    ph_el yp[9], Y8;
} phs_key;
#define PHS_X(a,b) _mm_xor_si128(a,b)
#define PHS_CL(a,b,i) _mm_clmulepi64_si128(a,b,i)
static inline phs_q phs_ld(const uint8_t*p){ return _mm_loadu_si128((const __m128i*)p); }
/* ---- scalar field arithmetic with PCLMUL ---- */
static inline ph_el phs_red8(const uint64_t r[8]){
    uint64_t h[5]={0,r[4],r[5],r[6],r[7]}; ph_el o;
    for(int l=0;l<4;l++){ uint64_t a=(h[l+1]<<2)|(h[l]>>62), b=(h[l+1]<<5)|(h[l]>>59), c=(h[l+1]<<10)|(h[l]>>54); o.w[l]=r[l]^h[l+1]^a^b^c; }
    uint64_t ov=(r[7]>>62)^(r[7]>>59)^(r[7]>>54); o.w[0]^=ov^(ov<<2)^(ov<<5)^(ov<<10); return o; }
static inline ph_el phs_mul(ph_el a,ph_el b){
    phs_q a01=_mm_loadu_si128((const __m128i*)&a.w[0]), a23=_mm_loadu_si128((const __m128i*)&a.w[2]);
    phs_q b01=_mm_loadu_si128((const __m128i*)&b.w[0]), b23=_mm_loadu_si128((const __m128i*)&b.w[2]);
    /* 128x128 products (lo, mid, hi) for (a01,b01), (a01,b23)+(a23,b01), (a23,b23) */
#define PHS_M128(u,v,L,M,H) do{ L=PHS_CL(u,v,0x00); H=PHS_CL(u,v,0x11); M=PHS_X(PHS_CL(u,v,0x01),PHS_CL(u,v,0x10)); }while(0)
    phs_q l0,m0,h0,l1,m1,h1,l2,m2,h2,l3,m3,h3;
    PHS_M128(a01,b01,l0,m0,h0); PHS_M128(a01,b23,l1,m1,h1); PHS_M128(a23,b01,l2,m2,h2); PHS_M128(a23,b23,l3,m3,h3);
    phs_q L0=PHS_X(l0,_mm_slli_si128(m0,8)), H0=PHS_X(h0,_mm_srli_si128(m0,8));
    phs_q l12=PHS_X(l1,l2), m12=PHS_X(m1,m2), h12=PHS_X(h1,h2);
    phs_q L1=PHS_X(l12,_mm_slli_si128(m12,8)), H1=PHS_X(h12,_mm_srli_si128(m12,8));
    phs_q L3=PHS_X(l3,_mm_slli_si128(m3,8)), H3=PHS_X(h3,_mm_srli_si128(m3,8));
    uint64_t r[8]; _mm_storeu_si128((__m128i*)&r[0],L0); _mm_storeu_si128((__m128i*)&r[2],PHS_X(H0,L1)); _mm_storeu_si128((__m128i*)&r[4],PHS_X(H1,L3)); _mm_storeu_si128((__m128i*)&r[6],H3);
    return phs_red8(r); }
static inline ph_el phs_sq(ph_el a){ uint64_t r[8];                        /* linear in characteristic 2 */
    for(int i=0;i<4;i++){ phs_q v=_mm_cvtsi64_si128((long long)a.w[i]); _mm_storeu_si128((__m128i*)&r[2*i],PHS_CL(v,v,0x00)); } return phs_red8(r); }
static inline ph_el phs_mul64(uint64_t n,ph_el b){ uint64_t r[8]={0};      /* 64-bit n (degree < 64) times b */
    phs_q nv=_mm_cvtsi64_si128((long long)n), b01=_mm_loadu_si128((const __m128i*)&b.w[0]), b23=_mm_loadu_si128((const __m128i*)&b.w[2]);
    phs_q p0=PHS_CL(nv,b01,0x00), p1=PHS_CL(nv,b01,0x10), p2=PHS_CL(nv,b23,0x00), p3=PHS_CL(nv,b23,0x10);
    phs_q e=PHS_X(p0,_mm_slli_si128(p1,8)), f=PHS_X(PHS_X(p2,_mm_slli_si128(p3,8)),_mm_srli_si128(p1,8));
    _mm_storeu_si128((__m128i*)&r[0],e); _mm_storeu_si128((__m128i*)&r[2],f); r[4]=(uint64_t)_mm_extract_epi64(p3,1); return phs_red8(r); }
static inline ph_el phs_final(ph_el v,const ph_key*K){
    ph_el X=ph_addint(v,K->tau), G=phs_sq(X);
    ph_el t=phs_mul(ph_xor(G,K->c[0]),ph_xor(ph_xor(X,G),K->c[1]));
    return ph_xor(phs_mul(ph_xor(X,K->c[2]),ph_xor(t,K->c[3])),K->c[4]); }
/* 9 point sums (128-bit) -> element */
static inline ph_el phs_interp(const phs_q q[9]){
    uint64_t Q[9][2]; for(int t=0;t<9;t++) _mm_storeu_si128((__m128i*)Q[t],q[t]);
    uint64_t LO[4],HI[4],MI[4],r[8];
#define PHS_SINNER(L,a,b,c) do{ uint64_t ml=Q[a][0]^Q[b][0]^Q[c][0], mh=Q[a][1]^Q[b][1]^Q[c][1]; (L)[0]=Q[a][0]; (L)[1]=Q[a][1]^ml; (L)[2]=Q[b][0]^mh; (L)[3]=Q[b][1]; }while(0)
    PHS_SINNER(LO,0,1,2); PHS_SINNER(HI,3,4,5); PHS_SINNER(MI,6,7,8);
    for(int l=0;l<4;l++) MI[l]^=LO[l]^HI[l];
    r[0]=LO[0]; r[1]=LO[1]; r[2]=LO[2]^MI[0]; r[3]=LO[3]^MI[1]; r[4]=HI[0]^MI[2]; r[5]=HI[1]^MI[3]; r[6]=HI[2]; r[7]=HI[3];
    return phs_red8(r); }
/* ---- key ---- */
static inline void phs_tsuffix(phs_key*x);
static inline void phs_key_init(phs_key*x,const ph_key*K){
    x->K=*K;
    for(int i=0;i<PH_M;i++){ const uint64_t*k=K->k[i].w, *l=K->l[i].w;
        uint64_t v[12]={k[0],k[1],k[2],k[3],l[0],l[1],l[2],l[3],k[0]^k[2],k[1]^k[3],l[0]^l[2],l[1]^l[3]};
        for(int j=0;j<12;j++) x->KR[i][j]=_mm_set1_epi64x((long long)v[j]); }
    for(int g=0;g<PH_M/8;g++) for(int t=0;t<4;t++) for(int j=0;j<12;j++){
        uint64_t a=0,b=0; int p0=8*g+2*t, p1=p0+1;
        const uint64_t*k0=K->k[p0].w,*l0=K->l[p0].w,*k1=K->k[p1].w,*l1=K->l[p1].w;
        uint64_t v0[12]={k0[0],k0[1],k0[2],k0[3],l0[0],l0[1],l0[2],l0[3],k0[0]^k0[2],k0[1]^k0[3],l0[0]^l0[2],l0[1]^l0[3]};
        uint64_t v1[12]={k1[0],k1[1],k1[2],k1[3],l1[0],l1[1],l1[2],l1[3],k1[0]^k1[2],k1[1]^k1[3],l1[0]^l1[2],l1[1]^l1[3]};
        a=v0[j]; b=v1[j]; x->KT[g][t][j]=_mm_set_epi64x((long long)b,(long long)a); }
    x->yp[0]=(ph_el){{1,0,0,0}}; for(int i=1;i<=8;i++) x->yp[i]=phs_mul(x->yp[i-1],K->Y); x->Y8=x->yp[8];
    phs_tsuffix(x); }
/* ---- one pass of 6 accumulators over the pairs: rows at offsets o0 (limb a) and o1 (limb b) of x (y +256);
 *      MIX: operands are x_a ^ x_{a+2} (limb offsets o0, o0+128 / o1, o1+128) with pre-mixed keys ---- */
#define PHS_OPX(p,o,MIX) (MIX? PHS_X(phs_ld((p)+(o)),phs_ld((p)+(o)+128)) : phs_ld((p)+(o)))
/* region block pair c: point sums E (block 2c) / O (block 2c+1) -> c values */
static inline void phs_bpair(const phs_key*x,const uint8_t*R,int c,ph_el*ce,ph_el*co){
    phs_q E[9],O[9]; const phs_q z=_mm_setzero_si128();
    for(int pass=0;pass<3;pass++){ int mix=pass==2, o0= pass==1? 128:0, kx= pass==2? 8 : 2*pass, ky= pass==2? 10 : 4+2*pass;
        phs_q e0=z,e1=z,e2=z,o0a=z,o1a=z,o2a=z;
        for(int i=0;i<PH_M;i++){ const uint8_t*p=R+512*i+16*c; const phs_q*k=x->KR[i];
            phs_q xa=PHS_X(PHS_OPX(p,o0,mix),k[kx]), xb=PHS_X(PHS_OPX(p,o0+64,mix),k[kx+1]);
            phs_q ya=PHS_X(PHS_OPX(p+256,o0,mix),k[ky]), yb=PHS_X(PHS_OPX(p+256,o0+64,mix),k[ky+1]);
            phs_q xc=PHS_X(xa,xb), yc=PHS_X(ya,yb);
            e0=PHS_X(e0,PHS_CL(xa,ya,0x00)); o0a=PHS_X(o0a,PHS_CL(xa,ya,0x11));
            e1=PHS_X(e1,PHS_CL(xb,yb,0x00)); o1a=PHS_X(o1a,PHS_CL(xb,yb,0x11));
            e2=PHS_X(e2,PHS_CL(xc,yc,0x00)); o2a=PHS_X(o2a,PHS_CL(xc,yc,0x11)); }
        int P=3*pass; E[P]=e0; E[P+1]=e1; E[P+2]=e2; O[P]=o0a; O[P+1]=o1a; O[P+2]=o2a; }
    *ce=phs_interp(E); *co=phs_interp(O); }
/* tail group g of a block at p: 3 passes of 3 point accumulators, lanes = pairs, E+O summed */
static inline void phs_tgroup(const phs_key*x,const uint8_t*p,int g,phs_q A[9]){
    for(int pass=0;pass<3;pass++){ int mix=pass==2, o0= pass==1? 128:0, kx= pass==2? 8 : 2*pass, ky= pass==2? 10 : 4+2*pass;
        phs_q a0=A[3*pass],a1=A[3*pass+1],a2=A[3*pass+2];
        for(int t=0;t<4;t++){ const uint8_t*q=p+512*g+16*t; const phs_q*k=x->KT[g][t];
            phs_q xa=PHS_X(PHS_OPX(q,o0,mix),k[kx]), xb=PHS_X(PHS_OPX(q,o0+64,mix),k[kx+1]);
            phs_q ya=PHS_X(PHS_OPX(q+256,o0,mix),k[ky]), yb=PHS_X(PHS_OPX(q+256,o0+64,mix),k[ky+1]);
            phs_q xc=PHS_X(xa,xb), yc=PHS_X(ya,yb);
            a0=PHS_X(a0,PHS_X(PHS_CL(xa,ya,0x00),PHS_CL(xa,ya,0x11)));
            a1=PHS_X(a1,PHS_X(PHS_CL(xb,yb,0x00),PHS_CL(xb,yb,0x11)));
            a2=PHS_X(a2,PHS_X(PHS_CL(xc,yc,0x00),PHS_CL(xc,yc,0x11))); }
        A[3*pass]=a0; A[3*pass+1]=a1; A[3*pass+2]=a2; } }
static inline void phs_tsuffix(phs_key*x){
    static const uint8_t zb[PH_BLOCK] = {0};                /* key-only groups: data zero */
    phs_q A[9]; for(int t=0;t<9;t++){ A[t]=_mm_setzero_si128(); x->SS[PH_M/8][t]=A[t]; }
    for(int g=PH_M/8-1;g>=0;g--){ phs_tgroup(x,zb,g,A); for(int t=0;t<9;t++) x->SS[g][t]=A[t]; } }
/* tail block at p with av valid bytes (av >= PH_BLOCK: full) */
static inline ph_el phs_tblk(const phs_key*x,const uint8_t*p,size_t av){
    int ng= av>=PH_BLOCK? PH_M/8 : (int)((av+511)/512), nf= av>=PH_BLOCK? PH_M/8 : (int)(av/512);
    phs_q A[9]; for(int t=0;t<9;t++) A[t]=x->SS[ng][t];
    for(int g=0;g<nf;g++) phs_tgroup(x,p,g,A);
    if(nf<ng){ uint8_t buf[PH_BLOCK]; size_t o=(size_t)512*nf; memset(buf+o,0,512); memcpy(buf+o,p+o,av-o); phs_tgroup(x,buf,nf,A); }
    return phs_interp(A); }
/* ---- API ---- */
static inline void phs_regions_h(const phs_key*x,uint64_t st[4][8],const uint8_t*msg,size_t nr){
    for(size_t r=0;r<nr;r++){ const uint8_t*R=msg+r*PH_REGION;
        for(int c=0;c<4;c++){ ph_el ce,co; phs_bpair(x,R,c,&ce,&co);
            for(int h=0;h<2;h++){ int b=2*c+h; ph_el s; for(int l=0;l<4;l++) s.w[l]=st[l][b];
                s=ph_xor(phs_mul(s,x->Y8), h? co : ce); for(int l=0;l<4;l++) st[l][b]=s.w[l]; } } } }
static inline ph_el phs_tails_pow_h(const phs_key*x,const uint8_t*T,size_t rem,size_t n){
    size_t nb=(rem+PH_BLOCK-1)/PH_BLOCK; if(!nb){ ph_el v={{(uint64_t)n,0,0,0}}; return v; }
    ph_el v=phs_mul64((uint64_t)n,x->yp[nb]);
    for(size_t b=0;b<nb;b++){ ph_el c=phs_tblk(x,T+b*PH_BLOCK,rem-b*PH_BLOCK); v=ph_xor(v, b==nb-1? c : phs_mul(c,x->yp[nb-1-b])); }
    return v; }
static inline void phs_tailfin_h(const phs_key*x,uint64_t st[4][8],const uint8_t*T,size_t rem,size_t n,size_t nreg,uint8_t out[32]){
    if(!nreg){ ph_store(phs_final(phs_tails_pow_h(x,T,rem,n),&x->K),out); return; }
    size_t nb=(rem+PH_BLOCK-1)/PH_BLOCK; ph_el s[8];
    for(int b=0;b<8;b++) for(int l=0;l<4;l++) s[b].w[l]=st[l][b];
    for(size_t b=0;b<nb;b++) s[b]=ph_xor(phs_mul(s[b],x->Y8),phs_tblk(x,T+b*PH_BLOCK,rem-b*PH_BLOCK));
    size_t p=8*nreg+nb; ph_el v={{0,0,0,0}};
    for(int b=0;b<8;b++){ size_t e=(p-1-(size_t)b)%8; v=ph_xor(v, e? phs_mul(s[b],x->yp[e]) : s[b]); }
    ph_el r=x->yp[nb], y8=x->Y8; size_t e=nreg;                        /* Y^p = (Y^8)^nreg Y^nb */
    while(e){ if(e&1) r=phs_mul(r,y8); e>>=1; if(e) y8=phs_sq(y8); }
    v=ph_xor(v,phs_mul64((uint64_t)n,r));
    ph_store(phs_final(v,&x->K),out); }
static inline void phs_hash_h(const phs_key*x,const uint8_t*msg,size_t n,uint8_t out[32]){
    size_t nr=n/PH_REGION; uint64_t st[4][8]; memset(st,0,sizeof st);
    phs_regions_h(x,st,msg,nr); phs_tailfin_h(x,st,msg+nr*PH_REGION,n-nr*PH_REGION,n,nr,out); }

/* =========================== PH-256 v1: two-level (2L) outer stage (= ph2l_hash_ref) =========================== */
static inline ph_el phs_region2l(const phs_key*x,const uint8_t*R){        /* c of a full region (q = 8) */
    ph_el a[8]; for(int c=0;c<4;c++) phs_bpair(x,R,c,&a[2*c],&a[2*c+1]);
    ph_el v={{0,0,0,0}}; for(int i=1;i<=4;i++) v=ph_xor(v,phs_mul(ph_xor(a[i-1],x->yp[2*i-1]),ph_xor(a[3+i],x->yp[2*i]))); return v; }
static inline ph_el phs_tailregion(const phs_key*x,const uint8_t*T,size_t rem){
    int q=(int)((rem+PH_BLOCK-1)/PH_BLOCK), h=(q+1)/2, f=q/2; ph_el a[8];
    for(int b=0;b<q;b++) a[b]=phs_tblk(x,T+(size_t)b*PH_BLOCK,rem-(size_t)b*PH_BLOCK);
    ph_el c= (q&1)? a[h-1] : (ph_el){{0,0,0,0}};
    for(int i=1;i<=f;i++) c=ph_xor(c,phs_mul(ph_xor(a[i-1],x->yp[2*i-1]),ph_xor(a[h+i-1],x->yp[2*i])));
    return c; }
static inline void phs_fold(const phs_key*x,ph_el*V,const uint8_t*msg,size_t nr){
    for(size_t r=0;r<nr;r++) *V=ph_xor(phs_mul(*V,x->K.z),phs_region2l(x,msg+r*PH_REGION)); }
static inline void phs_final2l(const phs_key*x,ph_el V,size_t nreg,const uint8_t*T,size_t rem,size_t n,uint8_t out[32]){
    size_t nb=(rem+PH_BLOCK-1)/PH_BLOCK, mp=nreg+(nb>0);
    if(!nreg){ ph_el v={{0,0,0,0}}; if(n) v=ph_xor(phs_mul64((uint64_t)n,x->K.z),phs_tailregion(x,T,n)); ph_store(phs_final(v,&x->K),out); return; }
    if(nb) V=ph_xor(phs_mul(V,x->K.z),phs_tailregion(x,T,rem));
    ph_el r={{1,0,0,0}}, b=x->K.z; size_t e=mp; while(e){ if(e&1) r=phs_mul(r,b); e>>=1; if(e) b=phs_sq(b); }
    V=ph_xor(V,phs_mul64((uint64_t)n,r)); ph_store(phs_final(V,&x->K),out); }
static inline void phs_hash(const phs_key*x,const uint8_t*msg,size_t n,uint8_t out[32]){
    size_t nr=n/PH_REGION; ph_el V={{(uint64_t)n,0,0,0}};                  /* length = the z-chain's initial value */
    if(!nr){ phs_final2l(x,V,0,msg,n,n,out); return; }
    phs_fold(x,&V,msg,nr);
    size_t rem=n-nr*PH_REGION; if(rem) V=ph_xor(phs_mul(V,x->K.z),phs_tailregion(x,msg+nr*PH_REGION,rem));
    ph_store(phs_final(V,&x->K),out); }
#endif
#if defined(__clang__)
#pragma clang attribute pop
#else
#pragma GCC pop_options
#endif
static inline uint64_t ph256_xgetbv0(void){ uint32_t a,d; __asm__ volatile("xgetbv":"=a"(a),"=d"(d):"c"(0)); return ((uint64_t)d<<32)|a; }
static inline int ph256_backend_detect(void);
/* cached: CPUID traps to the hypervisor on VMs (microseconds per call); a racing first call stores the same value */
static inline int ph256_backend(void){ static int cached=-1; int v=cached; if(v<0){ v=ph256_backend_detect(); cached=v; } return v; }
static inline void ph256_cpuid(unsigned leaf,unsigned sub,unsigned r[4]){
    __asm__ __volatile__("cpuid":"=a"(r[0]),"=b"(r[1]),"=c"(r[2]),"=d"(r[3]):"a"(leaf),"c"(sub)); }
static inline int ph256_backend_detect(void){
    unsigned r[4],a,b,c,d,maxleaf; ph256_cpuid(0,0,r); maxleaf=r[0];
    if(maxleaf<1) return PH256_PORTABLE;
    ph256_cpuid(1,0,r); a=r[0]; b=r[1]; c=r[2]; d=r[3]; (void)a; (void)b; (void)d;
    int pclmul=(c>>1)&1, sse41=(c>>19)&1, osxsave=(c>>27)&1;
    int best=(pclmul&&sse41)? PH256_PCLMUL : PH256_PORTABLE;
    if(!osxsave || maxleaf<7) return best;
    if((ph256_xgetbv0()&0xE6)!=0xE6) return best;
    ph256_cpuid(7,0,r); b=r[1]; c=r[2];
    int f=(b>>16)&1, dq=(b>>17)&1, bw=(b>>30)&1, vl=(b>>31)&1, vpcl=(c>>10)&1, vbmi2=(c>>6)&1, gfni=(c>>8)&1;
    if(f&&dq&&bw&&vl&&vpcl&&vbmi2&&gfni&&pclmul) return PH256_AVX512;
    return best; }
#elif !defined(CHAINHASH256_PORTABLE) && defined(__aarch64__) && !defined(__AARCH64EB__) && defined(__ARM_FEATURE_CRYPTO)
#define PH256_ARM 1
/* ph_neon.h -- PH-256 v1 (two-level outer stage) NEON (PMULL) kernels.  Output = ph2l_hash_ref (ph_ref.h), PH_M = 16/32/64.
 * Region: a q register holds limb l of blocks (2c, 2c+1) (16 bytes at row + 16 c).  Per block pair c and pair i:
 * 8 keyed limbs (pinned plain EOR), 9 Karatsuba^2 points per operand, fused PMULL/PMULL2+EOR into 18 raw point
 * accumulators; ZIP, vertical interpolation, reduction -> the two block values.  2L fold per region: blocks (0,1) x
 * (4,5) and (2,3) x (6,7) are lane-wise pairings with masks (y^1,y^3)(y^2,y^4), (y^5,y^7)(y^6,y^8); both lanes add
 * into the same 9 point sums together with points(V) x points(z); one interpolation + reduction per region.
 * Short path (n < REGION): tail block values register-resident (x-only partial groups: c = sum x_i l_i + CKS[g];
 * zero-filled chunk loads), V = n z + c(b_1..b_q) with all products unreduced and one reduction; finalizer with
 * squaring and the early operand pre-swapped.  API: phn_key_init, phn_hash, phn_fold, phn_final2l. */
#ifndef PH_NEON_H
#define PH_NEON_H
#include <arm_neon.h>
typedef uint64x2_t pq;
#define PQX(a,b) veorq_u64(a,b)
#if defined(__ARM_FEATURE_SHA3)
#define PQX3(a,b,c) veor3q_u64(a,b,c)
#else
#define PQX3(a,b,c) veorq_u64(veorq_u64(a,b),c)
#endif
#define PM1(a,b) vreinterpretq_u64_p128(vmull_p64(vgetq_lane_p64(vreinterpretq_p64_u64(a),0),vgetq_lane_p64(vreinterpretq_p64_u64(b),0)))
#define PM2(a,b) vreinterpretq_u64_p128(vmull_high_p64(vreinterpretq_p64_u64(a),vreinterpretq_p64_u64(b)))
/* fused multiply-accumulate (Apple fuses PMULL + EOR on the same destination when adjacent) */
#if defined(PH_NOASM)
#define PH_MACL(acc,a,b) (acc)=PQX(acc,PM1(a,b))
#define PH_MACH(acc,a,b) (acc)=PQX(acc,PM2(a,b))
#else
/* the fusable form: pmull vT, a, b ; eor vT, vT, vAcc  (the EOR writes the PMULL destination) */
#define PH_MACL(acc,a,b) do{ pq t_; __asm__("pmull %0.1q, %1.1d, %2.1d\n\teor %0.16b, %0.16b, %3.16b" : "=&w"(t_) : "w"(a),"w"(b),"w"(acc)); (acc)=t_; }while(0)
#define PH_MACH(acc,a,b) do{ pq t_; __asm__("pmull2 %0.1q, %1.2d, %2.2d\n\teor %0.16b, %0.16b, %3.16b" : "=&w"(t_) : "w"(a),"w"(b),"w"(acc)); (acc)=t_; }while(0)
#endif
/* pinned plain EOR: clang otherwise merges chains into EOR3 (lower issue rate on the M2) */
#if defined(PH_NOPIN)
#define PHE(a,b) PQX(a,b)
#else
static inline pq PHE(pq a,pq b){ pq r; __asm__("eor %0.16b, %1.16b, %2.16b" : "=w"(r) : "w"(a),"w"(b)); return r; }
#endif
#ifndef PH_NPASS
#define PH_NPASS 1
#endif
typedef struct { pq tau[2], ntau[2], c[5][2], Gd; ph_el tau_e; } phw_fk;   /* v1.2 NEON finalizer key: tau, ~tau, c0..c4 as (limbs 0,1),(2,3); g dup; tau */
typedef struct { pq KL[4][4], Z[4], C0[2]; } phw_sk;          /* v1.2 NEON <= 64 B: (l_2j, l_2j+1) limb l; z limb l (dup); C0 */
typedef struct {
    ph_key K;
    pq KM[PH_M][4];                 /* key mixes (dup): x: k0^k2, k1^k3; y: l0^l2, l1^l3 */
    pq KQ[PH_M][8];                 /* region keys (dup): [pair][x limbs 0..3, y limbs 4..7] */
    pq YA[2][4], YB[2][4];          /* 2L pair masks, limb-major: YA[0] = (y^1, y^3), YA[1] = (y^5, y^7); YB[0] = (y^2, y^4), YB[1] = (y^6, y^8) */
    pq ZP[9];                       /* Karatsuba points of z (dup) */
    pq ZV[2], ZVS[2];               /* z as (limbs 0,1), (2,3) and limb-swapped */
    pq KT[PH_M/8][4][8];            /* tail keys [group][t][limb]: lanes = pairs 8g+2t, 8g+2t+1 */
    pq SF[PH_M/8+1][18];            /* tail suffix raw sums */
    pq SF9[PH_M/8+1][9];            /* same, E/O folded (9 point sums) */
    ph_el CKS[PH_M/8+1];            /* x-only groups: sum_{i in g} k_i l_i + all key-only groups > g, as an element */
    pq YPW[9][2];                   /* Y^e (e = 0..8) as (limbs 0,1), (2,3) */
    pq LP[PH_M/8][4][9];            /* Karatsuba points of l_i: [group][t][point], lanes = pairs 8g+2t, 8g+2t+1 */
    ph_el yp[9];
    phw_fk WF; phw_sk WS;           /* v1.2 latency path */
} phn_key;
/* ---- scalar field arithmetic with PMULL ---- */
static inline void phn_cl(uint64_t a,uint64_t b,uint64_t*lo,uint64_t*hi){ pq r=vreinterpretq_u64_p128(vmull_p64((poly64_t)a,(poly64_t)b)); *lo=vgetq_lane_u64(r,0); *hi=vgetq_lane_u64(r,1); }
static inline ph_el phn_red8(const uint64_t r[8]){
    uint64_t h[5]={0,r[4],r[5],r[6],r[7]}; ph_el o;
    for(int l=0;l<4;l++){ uint64_t a=(h[l+1]<<2)|(h[l]>>62), b=(h[l+1]<<5)|(h[l]>>59), c=(h[l+1]<<10)|(h[l]>>54); o.w[l]=r[l]^h[l+1]^a^b^c; }
    uint64_t ov=(r[7]>>62)^(r[7]>>59)^(r[7]>>54); o.w[0]^=ov^(ov<<2)^(ov<<5)^(ov<<10); return o; }
static inline ph_el phn_mul(ph_el a,ph_el b){ uint64_t r[8]={0};
    for(int i=0;i<4;i++) for(int j=0;j<4;j++){ uint64_t lo,hi; phn_cl(a.w[i],b.w[j],&lo,&hi); r[i+j]^=lo; r[i+j+1]^=hi; }
    return phn_red8(r); }
static inline void phn_eval9(const ph_el*a,uint64_t p[9]){ p[0]=a->w[0]; p[1]=a->w[1]; p[2]=a->w[0]^a->w[1]; p[3]=a->w[2]; p[4]=a->w[3];
    p[5]=a->w[2]^a->w[3]; p[6]=a->w[0]^a->w[2]; p[7]=a->w[1]^a->w[3]; p[8]=p[2]^p[5]; }
static inline pq phn_pair(uint64_t a,uint64_t b){ return vcombine_u64(vcreate_u64(a),vcreate_u64(b)); }
/* interpolate (lanes = 2 blocks, limb-major lo/hi) and reduce */
typedef struct { pq lo,hi; } phn_p;
static inline void phn_reduce8(const pq r[8],pq out[4]){
    pq z=vdupq_n_u64(0), h[5]={z,r[4],r[5],r[6],r[7]};
    for(int l=0;l<4;l++){
        pq a=vsriq_n_u64(vshlq_n_u64(h[l+1],2),h[l],62), b=vsriq_n_u64(vshlq_n_u64(h[l+1],5),h[l],59), c=vsriq_n_u64(vshlq_n_u64(h[l+1],10),h[l],54);
        out[l]=PQX3(PQX3(r[l],h[l+1],a),b,c); }
    pq ov=PQX3(vshrq_n_u64(r[7],62),vshrq_n_u64(r[7],59),vshrq_n_u64(r[7],54));
    out[0]=PQX3(PQX3(out[0],ov,vshlq_n_u64(ov,2)),vshlq_n_u64(ov,5),vshlq_n_u64(ov,10)); }
static inline void phn_interp_reduce(const phn_p Q[9],pq out[4]){
#define PHN_INNER(L,a,b,c) do{ pq ml=PQX3((a).lo,(b).lo,(c).lo), mh=PQX3((a).hi,(b).hi,(c).hi); (L)[0]=(a).lo; (L)[1]=PQX((a).hi,ml); (L)[2]=PQX((b).lo,mh); (L)[3]=(b).hi; }while(0)
    pq LO[4],HI[4],MI[4],r[8];
    PHN_INNER(LO,Q[0],Q[1],Q[2]); PHN_INNER(HI,Q[3],Q[4],Q[5]); PHN_INNER(MI,Q[6],Q[7],Q[8]);
    for(int l=0;l<4;l++) MI[l]=PQX3(MI[l],LO[l],HI[l]);
    r[0]=LO[0]; r[1]=LO[1]; r[2]=PQX(LO[2],MI[0]); r[3]=PQX(LO[3],MI[1]); r[4]=PQX(HI[0],MI[2]); r[5]=PQX(HI[1],MI[3]); r[6]=HI[2]; r[7]=HI[3];
    phn_reduce8(r,out); }
static inline phn_p phn_unpack(pq E,pq O){ phn_p r; r.lo=vzip1q_u64(E,O); r.hi=vzip2q_u64(E,O); return r; }
static inline void phn_suffix_init(phn_key*x);
static inline void phn_key_init(phn_key*x,const ph_key*K){
    x->K=*K; x->yp[0]=(ph_el){{1,0,0,0}}; for(int i=1;i<=8;i++) x->yp[i]=phn_mul(x->yp[i-1],K->Y);
    for(int i=0;i<PH_M;i++) for(int l=0;l<4;l++){ x->KQ[i][l]=vdupq_n_u64(K->k[i].w[l]); x->KQ[i][4+l]=vdupq_n_u64(K->l[i].w[l]); }
    for(int i=0;i<PH_M;i++){ x->KM[i][0]=vdupq_n_u64(K->k[i].w[0]^K->k[i].w[2]); x->KM[i][1]=vdupq_n_u64(K->k[i].w[1]^K->k[i].w[3]);
        x->KM[i][2]=vdupq_n_u64(K->l[i].w[0]^K->l[i].w[2]); x->KM[i][3]=vdupq_n_u64(K->l[i].w[1]^K->l[i].w[3]); }
    for(int l=0;l<4;l++){ x->YA[0][l]=phn_pair(x->yp[1].w[l],x->yp[3].w[l]); x->YA[1][l]=phn_pair(x->yp[5].w[l],x->yp[7].w[l]);
        x->YB[0][l]=phn_pair(x->yp[2].w[l],x->yp[4].w[l]); x->YB[1][l]=phn_pair(x->yp[6].w[l],x->yp[8].w[l]); }
    { uint64_t p[9]; phn_eval9(&K->z,p); for(int t=0;t<9;t++) x->ZP[t]=vdupq_n_u64(p[t]); }
    x->ZV[0]=vld1q_u64(&K->z.w[0]); x->ZV[1]=vld1q_u64(&K->z.w[2]); x->ZVS[0]=vextq_u64(x->ZV[0],x->ZV[0],1); x->ZVS[1]=vextq_u64(x->ZV[1],x->ZV[1],1);
    for(int g=0;g<PH_M/8;g++) for(int t=0;t<4;t++) for(int l=0;l<4;l++){
        x->KT[g][t][l]=phn_pair(K->k[8*g+2*t].w[l],K->k[8*g+2*t+1].w[l]); x->KT[g][t][4+l]=phn_pair(K->l[8*g+2*t].w[l],K->l[8*g+2*t+1].w[l]); }
    phn_suffix_init(x);
}
/* ---------- Karatsuba^2 pair step: 8 keyed limbs -> 18 accumulates ---------- */
#define PHN_KSTEP(A,x0,x1,x2,x3,y0,y1,y2,y3) do{ \
        PH_MACL((A)[0],x0,y0); PH_MACH((A)[1],x0,y0); PH_MACL((A)[2],x1,y1); PH_MACH((A)[3],x1,y1); \
        { pq u=PQX(x0,x1), v=PQX(y0,y1); PH_MACL((A)[4],u,v); PH_MACH((A)[5],u,v); \
          PH_MACL((A)[6],x2,y2); PH_MACH((A)[7],x2,y2); PH_MACL((A)[8],x3,y3); PH_MACH((A)[9],x3,y3); \
          pq u2=PQX(x2,x3), v2=PQX(y2,y3); PH_MACL((A)[10],u2,v2); PH_MACH((A)[11],u2,v2); \
          pq u3=PQX(x0,x2), v3=PQX(y0,y2); PH_MACL((A)[12],u3,v3); PH_MACH((A)[13],u3,v3); \
          pq u4=PQX(x1,x3), v4=PQX(y1,y3); PH_MACL((A)[14],u4,v4); PH_MACH((A)[15],u4,v4); \
          pq u5=PQX(u,u2), v5=PQX(v,v2); PH_MACL((A)[16],u5,v5); PH_MACH((A)[17],u5,v5); } }while(0)
/* ---------- schoolbook-by-diagonal pair step: 16 products -> 7 diagonals x E/O (D[2d], D[2d+1]) ---------- */
#define PHN_SSTEP(D,x0,x1,x2,x3,y0,y1,y2,y3) do{ const pq xs_[4]={x0,x1,x2,x3}, ys_[4]={y0,y1,y2,y3}; \
        for(int i_=0;i_<4;i_++) for(int j_=0;j_<4;j_++){ PH_MACL((D)[2*(i_+j_)],xs_[i_],ys_[j_]); PH_MACH((D)[2*(i_+j_)+1],xs_[i_],ys_[j_]); } }while(0)
#define PHN_LD(p) vld1q_u64((const uint64_t*)(p))
/* block pair c of region R: s (lanes = blocks 2c, 2c+1, limbs 0..3) <- the two block values */
#if !defined(PHN_NONPF) && !defined(AF_NPF)
#define AF_NPF 1                 /* A-floor lane: trickle prefetch of the next 32 KiB region, 2 lines per pair step (M2 flat 79-82 cyc/KiB) */
#endif
static inline void phn_bvals(const phn_key*x,const uint8_t*R,int c,pq s[4],const uint8_t*Rn){
    const uint8_t*Rc=R+16*c;
    pq A[18]; for(int t=0;t<18;t++) A[t]=vdupq_n_u64(0);
#if PH_NPASS==1
    _Pragma("clang loop unroll(full)")
    for(int i=0;i<PH_M;i++){ const uint8_t*r=Rc+512*i;
#if defined(AF_NPF)
        if(Rn){ const uint8_t*pf=Rn+128*(PH_M*c+i); __builtin_prefetch(pf,0,3); __builtin_prefetch(pf+64,0,3); }   /* next region, 2 lines per step */
#else
        (void)Rn;
#endif
        const pq*k=x->KQ[i];
        pq x0=PHE(PHN_LD(r),k[0]),x1=PHE(PHN_LD(r+64),k[1]),x2=PHE(PHN_LD(r+128),k[2]),x3=PHE(PHN_LD(r+192),k[3]);
        pq y0=PHE(PHN_LD(r+256),k[4]),y1=PHE(PHN_LD(r+320),k[5]),y2=PHE(PHN_LD(r+384),k[6]),y3=PHE(PHN_LD(r+448),k[7]);
        PH_MACL(A[0],x0,y0); PH_MACH(A[1],x0,y0); PH_MACL(A[2],x1,y1); PH_MACH(A[3],x1,y1);
        { pq u=PHE(x0,x1), v=PHE(y0,y1); PH_MACL(A[4],u,v); PH_MACH(A[5],u,v);
          PH_MACL(A[6],x2,y2); PH_MACH(A[7],x2,y2); PH_MACL(A[8],x3,y3); PH_MACH(A[9],x3,y3);
          pq u2=PHE(x2,x3), v2=PHE(y2,y3); PH_MACL(A[10],u2,v2); PH_MACH(A[11],u2,v2);
          pq u3=PHE(x0,x2), v3=PHE(y0,y2); PH_MACL(A[12],u3,v3); PH_MACH(A[13],u3,v3);
          pq u4=PHE(x1,x3), v4=PHE(y1,y3); PH_MACL(A[14],u4,v4); PH_MACH(A[15],u4,v4);
          pq u5=PHE(u,u2), v5=PHE(v,v2); PH_MACL(A[16],u5,v5); PH_MACH(A[17],u5,v5); } }
#else
    /* pass split: pass 1 = points 0..5 (limbs, lo/hi halves; 12 accumulators), pass 2 = points 6..8 (mixes m0 = L0+L2+k02,
     * m1 = L1+L3+k13, m0+m1; 6 accumulators).  PH_NPASS==3 splits pass 1 into points 0..2 and 3..5. */
#if PH_NPASS==3
    _Pragma("clang loop unroll(full)")
    for(int h=0;h<2;h++){
    _Pragma("clang loop unroll(full)")
    for(int i=0;i<PH_M;i++){ const uint8_t*r=Rc+512*i+128*h; const pq*k=x->KQ[i]+2*h; pq*B=A+6*h;
        pq x0=PHE(PHN_LD(r),k[0]),x1=PHE(PHN_LD(r+64),k[1]), y0=PHE(PHN_LD(r+256),k[4]),y1=PHE(PHN_LD(r+320),k[5]);
        PH_MACL(B[0],x0,y0); PH_MACH(B[1],x0,y0); PH_MACL(B[2],x1,y1); PH_MACH(B[3],x1,y1);
        pq u=PHE(x0,x1), v=PHE(y0,y1); PH_MACL(B[4],u,v); PH_MACH(B[5],u,v); } }
#else
    _Pragma("clang loop unroll(full)")
    for(int i=0;i<PH_M;i++){ const uint8_t*r=Rc+512*i;
#if defined(AF_NPF)
        if(Rn){ const uint8_t*pf=Rn+128*(PH_M*c+i); __builtin_prefetch(pf,0,3); __builtin_prefetch(pf+64,0,3); }   /* next region, 2 lines per step */
#else
        (void)Rn;
#endif
        const pq*k=x->KQ[i];
        pq x0=PHE(PHN_LD(r),k[0]),x1=PHE(PHN_LD(r+64),k[1]),x2=PHE(PHN_LD(r+128),k[2]),x3=PHE(PHN_LD(r+192),k[3]);
        pq y0=PHE(PHN_LD(r+256),k[4]),y1=PHE(PHN_LD(r+320),k[5]),y2=PHE(PHN_LD(r+384),k[6]),y3=PHE(PHN_LD(r+448),k[7]);
        PH_MACL(A[0],x0,y0); PH_MACH(A[1],x0,y0); PH_MACL(A[2],x1,y1); PH_MACH(A[3],x1,y1);
        pq u=PHE(x0,x1), v=PHE(y0,y1); PH_MACL(A[4],u,v); PH_MACH(A[5],u,v);
        PH_MACL(A[6],x2,y2); PH_MACH(A[7],x2,y2); PH_MACL(A[8],x3,y3); PH_MACH(A[9],x3,y3);
        pq u2=PHE(x2,x3), v2=PHE(y2,y3); PH_MACL(A[10],u2,v2); PH_MACH(A[11],u2,v2); }
#endif
    _Pragma("clang loop unroll(full)")
    for(int i=0;i<PH_M;i++){ const uint8_t*r=Rc+512*i; const pq*km=x->KM[i];
        pq m0=PHE(PHE(PHN_LD(r),PHN_LD(r+128)),km[0]), m1=PHE(PHE(PHN_LD(r+64),PHN_LD(r+192)),km[1]);
        pq n0=PHE(PHE(PHN_LD(r+256),PHN_LD(r+384)),km[2]), n1=PHE(PHE(PHN_LD(r+320),PHN_LD(r+448)),km[3]);
        PH_MACL(A[12],m0,n0); PH_MACH(A[13],m0,n0); PH_MACL(A[14],m1,n1); PH_MACH(A[15],m1,n1);
        pq m2=PHE(m0,m1), n2=PHE(n0,n1); PH_MACL(A[16],m2,n2); PH_MACH(A[17],m2,n2); }
#endif
    phn_p Q[9]; for(int t=0;t<9;t++) Q[t]=phn_unpack(A[2*t],A[2*t+1]);
    phn_interp_reduce(Q,s);
}
/* ---- in-register elements: (q01, q23) = limbs (0,1), (2,3) ---- */
typedef struct { pq a,b; } phv;
static inline phv phv_ld(ph_el e){ phv r={vld1q_u64(&e.w[0]),vld1q_u64(&e.w[2])}; return r; }
static inline ph_el phv_st(phv v){ ph_el e; vst1q_u64(&e.w[0],v.a); vst1q_u64(&e.w[2],v.b); return e; }
static inline phv phv_xor(phv x,phv y){ phv r={PQX(x.a,y.a),PQX(x.b,y.b)}; return r; }
/* 128x128 -> 256 (lo, hi q) */
static inline void phv_m128(pq u,pq v,pq*lo,pq*hi){
    pq ll=PM1(u,v), hh=PM2(u,v), vs=vextq_u64(v,v,1), md=PQX(PM1(u,vs),PM2(u,vs)), z=vdupq_n_u64(0);
    *lo=PQX(ll,vextq_u64(z,md,1)); *hi=PQX(hh,vextq_u64(md,z,1)); }
/* 512-bit (r0 = limbs 0,1 .. r3 = limbs 6,7) mod f: lo + H (1 + x^2 + x^5 + x^10), H = (r2, r3); flat XOR tree */
static inline phv phv_red(pq r0,pq r1,pq r2,pq r3){
    pq z=vdupq_n_u64(0);
#if defined(PH_REDSEQ)
    pq o0=PQX(r0,r2), o1=PQX(r1,r3), ov=z;
#define PHV_SH(k) do{ pq c0=vshrq_n_u64(r2,64-(k)), c1=vshrq_n_u64(r3,64-(k)); \
        o0=PQX3(o0,vshlq_n_u64(r2,k),vextq_u64(z,c0,1)); o1=PQX3(o1,vshlq_n_u64(r3,k),vextq_u64(c0,c1,1)); ov=PQX(ov,vextq_u64(c1,z,1)); }while(0)
    PHV_SH(2); PHV_SH(5); PHV_SH(10);
#else
    /* carries: c_k = H >> (64-k) per limb; lane moves via EXT */
    pq c20=vshrq_n_u64(r2,62), c21=vshrq_n_u64(r3,62), c50=vshrq_n_u64(r2,59), c51=vshrq_n_u64(r3,59), c100=vshrq_n_u64(r2,54), c101=vshrq_n_u64(r3,54);
    pq s0=PQX3(vshlq_n_u64(r2,2),vshlq_n_u64(r2,5),vshlq_n_u64(r2,10)), s1=PQX3(vshlq_n_u64(r3,2),vshlq_n_u64(r3,5),vshlq_n_u64(r3,10));
    pq k0=PQX3(c20,c50,c100), k1=PQX3(c21,c51,c101);              /* carry words: lane0 -> lane1 of the same q, lane1 -> next q */
    pq o0=PQX3(PQX3(r0,r2,s0),vextq_u64(z,k0,1),z), o1=PQX3(PQX3(r1,r3,s1),vextq_u64(k0,k1,1),z), ov=vextq_u64(k1,z,1);
#endif
    o0=PQX3(PQX3(o0,ov,vshlq_n_u64(ov,2)),vshlq_n_u64(ov,5),vshlq_n_u64(ov,10));     /* ov < 2^10 in lane 0 */
    phv r={o0,o1}; return r; }
/* 256x256: even limb positions land in their q directly; the odd positions (1, 3, 5) are summed, then realigned by
 * one EXT level.  ys = y with the limbs of each q swapped (pass the operand that is ready first as y). */
static inline phv phv_mul_s(phv x,phv y,phv ys){
    pq z=vdupq_n_u64(0);
    pq p0=PM1(x.a,y.a), p2=PQX3(PM2(x.a,y.a),PM1(x.a,y.b),PM1(x.b,y.a)), p4=PQX3(PM2(x.a,y.b),PM2(x.b,y.a),PM1(x.b,y.b)), p6=PM2(x.b,y.b);
    pq p1=PQX(PM1(x.a,ys.a),PM2(x.a,ys.a)), p3=PQX(PQX(PM1(x.a,ys.b),PM2(x.a,ys.b)),PQX(PM1(x.b,ys.a),PM2(x.b,ys.a))), p5=PQX(PM1(x.b,ys.b),PM2(x.b,ys.b));
    return phv_red(PQX(p0,vextq_u64(z,p1,1)),PQX3(p2,vextq_u64(p1,p3,1),z),PQX3(p4,vextq_u64(p3,p5,1),z),PQX(p6,vextq_u64(p5,z,1))); }
static inline phv phv_swp(phv y){ phv r={vextq_u64(y.a,y.a,1),vextq_u64(y.b,y.b,1)}; return r; }
static inline phv phv_mul(phv x,phv y){ return phv_mul_s(x,y,phv_swp(y)); }
static inline phv phv_sq(phv x){ pq r0=PM1(x.a,x.a), r1=PM2(x.a,x.a), r2=PM1(x.b,x.b), r3=PM2(x.b,x.b); return phv_red(r0,r1,r2,r3); }
/* 9 point sums (q) -> element */
static inline phv phv_interp(const pq q[9]){ pq z=vdupq_n_u64(0);
#define PHV_INNER(LOq,HIq,a,b,c) do{ pq m_=PQX3(a,b,c); LOq=PQX(a,vextq_u64(z,m_,1)); HIq=PQX(b,vextq_u64(m_,z,1)); }while(0)
    pq Ll,Lh,Hl,Hh,Ml,Mh; PHV_INNER(Ll,Lh,q[0],q[1],q[2]); PHV_INNER(Hl,Hh,q[3],q[4],q[5]); PHV_INNER(Ml,Mh,q[6],q[7],q[8]);
    Ml=PQX3(Ml,Ll,Hl); Mh=PQX3(Mh,Lh,Hh);
    return phv_red(Ll,PQX(Lh,Ml),PQX(Hl,Mh),Hh); }
static inline void phn_suffix_init(phn_key*x){
    pq A[18]; for(int t=0;t<18;t++){ A[t]=vdupq_n_u64(0); x->SF[PH_M/8][t]=A[t]; }
    for(int g=PH_M/8-1;g>=0;g--){ for(int t=0;t<4;t++){ const pq*k=x->KT[g][t]; pq A2[18]; for(int u=0;u<18;u++) A2[u]=A[u];
            PHN_KSTEP(A2,k[0],k[1],k[2],k[3],k[4],k[5],k[6],k[7]); for(int u=0;u<18;u++) A[u]=A2[u]; }
        for(int u=0;u<18;u++) x->SF[g][u]=A[u]; }
    for(int g=0;g<=PH_M/8;g++) for(int t=0;t<9;t++) x->SF9[g][t]=PQX(x->SF[g][2*t],x->SF[g][2*t+1]);
    /* CKS[g] = sum_{i in group g} k_i l_i + sum_{groups > g} (k_i)(l_i) */
    ph_el acc={{0,0,0,0}}; x->CKS[PH_M/8]=acc;
    for(int g=PH_M/8-1;g>=0;g--){ ph_el own={{0,0,0,0}}; for(int i=8*g;i<8*g+8;i++) own=ph_xor(own,phn_mul(x->K.k[i],x->K.l[i]));
        x->CKS[g]=ph_xor(own,acc); acc=ph_xor(acc,own); }
    for(int e=0;e<=8;e++){ x->YPW[e][0]=vld1q_u64(&x->yp[e].w[0]); x->YPW[e][1]=vld1q_u64(&x->yp[e].w[2]); }
    for(int g=0;g<PH_M/8;g++) for(int t=0;t<4;t++){ uint64_t p0[9],p1[9]; phn_eval9(&x->K.l[8*g+2*t],p0); phn_eval9(&x->K.l[8*g+2*t+1],p1);
        for(int q=0;q<9;q++) x->LP[g][t][q]=phn_pair(p0[q],p1[q]); } }
/* ---- short path ---- */
/* one 9-accumulator Karatsuba step on a group row pair (PMULL and PMULL2 = two pairs of the same block -> same sum) */
#define PHN_K9(A,x0,x1,x2,x3,y0,y1,y2,y3) do{ \
        PH_MACL((A)[0],x0,y0); PH_MACH((A)[0],x0,y0); PH_MACL((A)[1],x1,y1); PH_MACH((A)[1],x1,y1); \
        { pq u=PHE(x0,x1), v=PHE(y0,y1); PH_MACL((A)[2],u,v); PH_MACH((A)[2],u,v); \
          PH_MACL((A)[3],x2,y2); PH_MACH((A)[3],x2,y2); PH_MACL((A)[4],x3,y3); PH_MACH((A)[4],x3,y3); \
          pq u2=PHE(x2,x3), v2=PHE(y2,y3); PH_MACL((A)[5],u2,v2); PH_MACH((A)[5],u2,v2); \
          pq u3=PHE(x0,x2), v3=PHE(y0,y2); PH_MACL((A)[6],u3,v3); PH_MACH((A)[6],u3,v3); \
          pq u4=PHE(x1,x3), v4=PHE(y1,y3); PH_MACL((A)[7],u4,v4); PH_MACH((A)[7],u4,v4); \
          pq u5=PHE(u,u2), v5=PHE(v,v2); PH_MACL((A)[8],u5,v5); PH_MACH((A)[8],u5,v5); } }while(0)
static inline void phn_grp(const phn_key*x,const uint8_t*r0,int g,pq A[9]){
    _Pragma("clang loop unroll(full)")
    for(int t=0;t<4;t++){ const uint8_t*r=r0+16*t; const pq*k=x->KT[g][t];
        pq x0=PHE(PHN_LD(r),k[0]),x1=PHE(PHN_LD(r+64),k[1]),x2=PHE(PHN_LD(r+128),k[2]),x3=PHE(PHN_LD(r+192),k[3]);
        pq y0=PHE(PHN_LD(r+256),k[4]),y1=PHE(PHN_LD(r+320),k[5]),y2=PHE(PHN_LD(r+384),k[6]),y3=PHE(PHN_LD(r+448),k[7]);
        PHN_K9(A,x0,x1,x2,x3,y0,y1,y2,y3); } }
/* 16 bytes at p+off with the bytes at or beyond av zeroed (no read past av) */
static inline pq phn_ldz(const uint8_t*p,size_t off,size_t av){
    if(off+16<=av) return PHN_LD(p+off);
    if(off>=av) return vdupq_n_u64(0);
    uint8_t t[16]={0}; size_t k=av-off; memcpy(t,p+off,k); return PHN_LD(t); }
/* partial group (ag < 512 data bytes): the same step with zero-filled loads, no buffer copy */
static inline void phn_grpz(const phn_key*x,const uint8_t*r0,size_t ag,int g,pq A[9]){
    _Pragma("clang loop unroll(full)")
    for(int t=0;t<4;t++){ const pq*k=x->KT[g][t]; size_t o=16*(size_t)t;
        pq x0=PHE(phn_ldz(r0,o,ag),k[0]),x1=PHE(phn_ldz(r0,o+64,ag),k[1]),x2=PHE(phn_ldz(r0,o+128,ag),k[2]),x3=PHE(phn_ldz(r0,o+192,ag),k[3]);
        pq y0=PHE(phn_ldz(r0,o+256,ag),k[4]),y1=PHE(phn_ldz(r0,o+320,ag),k[5]),y2=PHE(phn_ldz(r0,o+384,ag),k[6]),y3=PHE(phn_ldz(r0,o+448,ag),k[7]);
        PHN_K9(A,x0,x1,x2,x3,y0,y1,y2,y3); } }
/* x-only group (the y rows are all padding): sum_i x_i l_i over the RX data rows (x limbs 0..RX-1), schoolbook by
 * diagonal (d = limb + key limb), PMULL / PMULL2 = pairs 2t / 2t+1 into the same diagonal */
static inline __attribute__((always_inline)) phv phn_xonly(const phn_key*x,const uint8_t*r0,size_t ag,int g,const int RX){
    pq z=vdupq_n_u64(0), D[7], D1[7], D2[7], D3[7];     /* 4 chains per diagonal: (t parity) x (PMULL, PMULL2) */
    for(int d=0;d<7;d++){ D[d]=z; D1[d]=z; D2[d]=z; D3[d]=z; }
    _Pragma("clang loop unroll(full)")
    for(int t=0;t<4;t++){ const pq*k=x->KT[g][t]+4; pq*Da=(t&1)? D2 : D; pq*Db=(t&1)? D3 : D1;
        _Pragma("clang loop unroll(full)")
        for(int l=0;l<RX;l++){ pq xv=phn_ldz(r0,(size_t)(64*l+16*t),ag);
            _Pragma("clang loop unroll(full)")
            for(int j=0;j<4;j++){ PH_MACL(Da[l+j],xv,k[j]); PH_MACH(Db[l+j],xv,k[j]); } } }
    for(int d=0;d<7;d++) D[d]=PQX(PQX(D[d],D1[d]),PQX(D2[d],D3[d]));
    /* D_d (128-bit at limb d) -> 512-bit (r0 = limbs 0,1 .. r3 = limbs 6,7) */
    pq q0=PQX(D[0],vextq_u64(z,D[1],1)), q1=PQX3(vextq_u64(D[1],z,1),D[2],vextq_u64(z,D[3],1)), q2=PQX3(vextq_u64(D[3],z,1),D[4],vextq_u64(z,D[5],1)), q3=PQX(vextq_u64(D[5],z,1),D[6]);
    return phv_red(q0,q1,q2,q3); }
/* x-only group, Karatsuba against the precomputed points of l (for 3..4 data rows) */
static inline phv phn_xonly_k(const phn_key*x,const uint8_t*r0,size_t ag,int g){
    pq z=vdupq_n_u64(0), A[9]={z,z,z,z,z,z,z,z,z}, B[9]={z,z,z,z,z,z,z,z,z};
    _Pragma("clang loop unroll(full)")
    for(int t=0;t<4;t++){ const pq*L=x->LP[g][t]; size_t o=16*(size_t)t; pq*C=(t&1)? B : A;
        pq x0=phn_ldz(r0,o,ag), x1=phn_ldz(r0,o+64,ag), x2=phn_ldz(r0,o+128,ag), x3=phn_ldz(r0,o+192,ag);
        pq u=PHE(x0,x1), u2=PHE(x2,x3), u3=PHE(x0,x2), u4=PHE(x1,x3), u5=PHE(u,u2);
        PH_MACL(C[0],x0,L[0]); PH_MACH(C[0],x0,L[0]); PH_MACL(C[1],x1,L[1]); PH_MACH(C[1],x1,L[1]); PH_MACL(C[2],u,L[2]); PH_MACH(C[2],u,L[2]);
        PH_MACL(C[3],x2,L[3]); PH_MACH(C[3],x2,L[3]); PH_MACL(C[4],x3,L[4]); PH_MACH(C[4],x3,L[4]); PH_MACL(C[5],u2,L[5]); PH_MACH(C[5],u2,L[5]);
        PH_MACL(C[6],u3,L[6]); PH_MACH(C[6],u3,L[6]); PH_MACL(C[7],u4,L[7]); PH_MACH(C[7],u4,L[7]); PH_MACL(C[8],u5,L[8]); PH_MACH(C[8],u5,L[8]); }
    for(int t=0;t<9;t++) A[t]=PQX(A[t],B[t]);
    return phv_interp(A); }
/* tail block value: full groups by Karatsuba (9 point sums), the partial group x-only when its data <= 256 bytes */
static inline phv phn_tblkv(const phn_key*x,const uint8_t*p,size_t av){
    if(av>=PH_BLOCK){ pq A[9], B[9]; for(int t=0;t<9;t++){ A[t]=x->SF9[PH_M/8][t]; B[t]=vdupq_n_u64(0); }
        _Pragma("clang loop unroll(full)")
        for(int g=0;g<PH_M/8;g+=2){ phn_grp(x,p+512*g,g,A); phn_grp(x,p+512*(g+1),g+1,B); }   /* two chains */
        for(int t=0;t<9;t++) A[t]=PQX(A[t],B[t]);
        return phv_interp(A); }
    int gf=(int)(av/512); size_t ag=av-512*(size_t)gf;          /* full groups gf, partial group gf with ag bytes (0 = none) */
    if(ag==0 || ag>256){ pq A[9]; int ng=gf+(ag?1:0); for(int t=0;t<9;t++) A[t]=x->SF9[ng][t];
        for(int g=0;g<gf;g++) phn_grp(x,p+512*g,g,A);
        if(ag) phn_grpz(x,p+512*gf,ag,gf,A);
        return phv_interp(A); }
    int RX=(int)((ag+63)/64); const uint8_t*pg=p+512*gf;
    phv xo = RX==1? phn_xonly(x,pg,ag,gf,1) : RX==2? phn_xonly(x,pg,ag,gf,2) : phn_xonly_k(x,pg,ag,gf);
    phv c=phv_xor(xo,phv_ld(x->CKS[gf]));
    if(gf){ pq A[9]; for(int t=0;t<9;t++) A[t]=vdupq_n_u64(0); for(int g=0;g<gf;g++) phn_grp(x,p+512*g,g,A); c=phv_xor(c,phv_interp(A)); }
    return c; }
/* n (< 2^64) times an element: 4 PMULL */
static inline phv phv_mul64(uint64_t n,phv y){ pq nq=vdupq_n_u64(n), z=vdupq_n_u64(0);
    pq a0=PM1(nq,y.a), a1=PM2(nq,y.a), b0=PM1(nq,y.b), b1=PM2(nq,y.b);          /* n*y0, n*y1, n*y2, n*y3 */
    pq r0=PQX(a0,vextq_u64(z,a1,1)), r1=PQX3(vextq_u64(a1,z,1),b0,vextq_u64(z,b1,1)), r2=vextq_u64(b1,z,1);
    return phv_red(r0,r1,r2,z); }
/* X = v + tau as 256-bit integers */
static inline phv phv_addint(phv v,const ph_el*t){
    uint64_t a0=vgetq_lane_u64(v.a,0),a1=vgetq_lane_u64(v.a,1),a2=vgetq_lane_u64(v.b,0),a3=vgetq_lane_u64(v.b,1), c;
    uint64_t s0=__builtin_addcll(a0,t->w[0],0,&c), s1=__builtin_addcll(a1,t->w[1],c,&c), s2=__builtin_addcll(a2,t->w[2],c,&c), s3=__builtin_addcll(a3,t->w[3],c,&c);
    phv r={vcombine_u64(vcreate_u64(s0),vcreate_u64(s1)),vcombine_u64(vcreate_u64(s2),vcreate_u64(s3))}; return r; }
static inline phv phv_final2(const phn_key*x,phv v){
    phv X=phv_addint(v,&x->K.tau), G=phv_sq(X), X2=phv_xor(X,phv_ld(x->K.c[2]));
    phv t=phv_mul(phv_xor(G,phv_ld(x->K.c[0])),phv_xor(phv_xor(X,G),phv_ld(x->K.c[1])));
    return phv_xor(phv_mul_s(phv_xor(t,phv_ld(x->K.c[3])),X2,phv_swp(X2)),phv_ld(x->K.c[4])); }   /* X + c2 is ready early: swap it */
static inline void phn_out(phv v,uint8_t out[32]){ vst1q_u8(out,vreinterpretq_u8_u64(v.a)); vst1q_u8(out+16,vreinterpretq_u8_u64(v.b)); }
/* ---- v1.2: NEON latency path (finalizer and <= 64 B).  The reduction H g mod f is done by PMULL against g = x^10 +
 * x^5 + x^2 + 1 applied to the UNALIGNED product pieces (PMULL is linear), so the 64-bit realignment (EXT) happens
 * once, after the reduction; the overflow (bits >= 256 of H g) is folded by one more PMULL. ---- */
/* 256 x 256 -> reduced + E: x (a,b) = limbs (0,1),(2,3); ys = y with the limbs of each q swapped */
static inline phv phw_mul_e(phv x,phv y,phv ys,pq Gd,phv E){
    pq z=vdupq_n_u64(0);
    pq p0=PM1(x.a,y.a), p2=PQX3(PM2(x.a,y.a),PM1(x.a,y.b),PM1(x.b,y.a)), p4=PQX3(PM2(x.a,y.b),PM2(x.b,y.a),PM1(x.b,y.b)), p6=PM2(x.b,y.b);
    pq p1=PQX(PM1(x.a,ys.a),PM2(x.a,ys.a)), p3=PQX(PQX(PM1(x.a,ys.b),PM2(x.a,ys.b)),PQX(PM1(x.b,ys.a),PM2(x.b,ys.a))), p5=PQX(PM1(x.b,ys.b),PM2(x.b,ys.b));
    /* h_l = limb 4+l of the product: h0 = p4.lo+p3.hi, h1 = p4.hi+p5.lo, h2 = p6.lo+p5.hi, h3 = p6.hi */
    pq h0g=PQX(PM1(p4,Gd),PM2(p3,Gd)), h1g=PQX(PM2(p4,Gd),PM1(p5,Gd)), h2g=PQX(PM1(p6,Gd),PM2(p5,Gd)), h3g=PM2(p6,Gd), og=PM2(h3g,Gd);
    pq D1=PQX(p1,h1g), D3=PQX(p3,h3g);                                   /* 128-bit sums at limb offsets 1 and 3 */
    phv r={PQX3(PQX3(p0,h0g,og),vextq_u64(z,D1,1),E.a),PQX3(PQX3(p2,h2g,E.b),vextq_u64(D1,D3,1),z)}; return r; }
static inline phv phw_sq_e(phv x,pq Gd,phv E){
    pq z=vdupq_n_u64(0);
    pq p0=PM1(x.a,x.a), p2=PM2(x.a,x.a), p4=PM1(x.b,x.b), p6=PM2(x.b,x.b);
    pq h0g=PM1(p4,Gd), h1g=PM2(p4,Gd), h2g=PM1(p6,Gd), h3g=PM2(p6,Gd), og=PM2(h3g,Gd);
    phv r={PQX3(PQX3(p0,h0g,og),vextq_u64(z,h1g,1),E.a),PQX3(PQX3(p2,h2g,E.b),vextq_u64(h1g,h3g,1),z)}; return r; }
/* X = v +_Z tau in vector registers (the GPR round trip costs ~12 cycles on M2): generate g_i = [v_i > ~t_i],
 * propagate p_i = [v_i == ~t_i] (exclusive, so OR = XOR), a 2-level lookahead; BCAX (a ^ (b & ~c)) instead of BSL,
 * whose mask operand is also its destination (a register move when the data arrives last). */
#if defined(__ARM_FEATURE_SHA3)
#define PW_BCAX(a,b,c) vbcaxq_u64(a,b,c)
#else
#define PW_BCAX(a,b,c) veorq_u64(a,vbicq_u64(b,c))
#endif
static inline phv phw_addint(phv v,phv t,phv nt){
    pq z=vdupq_n_u64(0);
    pq sa=vaddq_u64(v.a,t.a), sb=vaddq_u64(v.b,t.b);
    pq ga=vcgtq_u64(v.a,nt.a), gb=vcgtq_u64(v.b,nt.b), na=vcgeq_u64(nt.a,v.a), pa=vceqq_u64(v.a,nt.a), pb=vceqq_u64(v.b,nt.b);
    pq Eg=vextq_u64(ga,gb,1), Ep=vextq_u64(pa,pb,1), nm1=vdupq_laneq_u64(na,0);       /* [g1,g2] [p1,p2] [~g0,~g0] */
    pq H=PW_BCAX(Eg,Ep,na), Q=vandq_u64(Ep,pa);                                      /* [g1 ^ p1 g0, g2 ^ p2 g1], [p1p0, p2p1] */
    pq Cb=PW_BCAX(H,Q,nm1);                                                          /* carries into limbs 2, 3 */
    phv r={vsubq_u64(sa,vextq_u64(z,ga,1)),vsubq_u64(sb,Cb)}; return r; }
/* one squaring, two outputs: X^2 + E and X^2 + F */
static inline void phw_sq2(phv x,pq Gd,phv E,phv F,phv*oe,phv*of){
    pq z=vdupq_n_u64(0);
    pq p0=PM1(x.a,x.a), p2=PM2(x.a,x.a), p4=PM1(x.b,x.b), p6=PM2(x.b,x.b);
    pq h0g=PM1(p4,Gd), h1g=PM2(p4,Gd), h2g=PM1(p6,Gd), h3g=PM2(p6,Gd), og=PM2(h3g,Gd);
    pq l0=vextq_u64(z,h1g,1), l1=vextq_u64(h1g,h3g,1), a=PQX3(p0,h0g,og), b=PQX(p2,h2g);
    oe->a=PQX3(a,l0,E.a); oe->b=PQX3(b,l1,E.b); of->a=PQX3(a,l0,F.a); of->b=PQX3(b,l1,F.b); }
static inline phv phw_swp(phv y){ phv r={vextq_u64(y.a,y.a,1),vextq_u64(y.b,y.b,1)}; return r; }
#define PW_V(p) ((phv){(p)[0],(p)[1]})
static inline void pw_set(pq d[2],ph_el e){ d[0]=vld1q_u64(&e.w[0]); d[1]=vld1q_u64(&e.w[2]); }
static inline void phw_fk_init(phw_fk*k,const ph_key*K){ ph_el nt; for(int i=0;i<4;i++) nt.w[i]=~K->tau.w[i];
    pw_set(k->tau,K->tau); pw_set(k->ntau,nt); for(int j=0;j<5;j++) pw_set(k->c[j],K->c[j]); k->Gd=vdupq_n_u64(0x425); k->tau_e=K->tau; }
/* X = v +_Z tau; G = X^2 (U = G + c0 and W = G + X + c1 share it); T = U W + c3; out = (X + c2) T + c4 */
static inline phv phw_final(phv v,const phw_fk*k){
    phv X=phv_addint(v,&k->tau_e);          /* GPR add/adc chain: in this chain ~2 cycles ahead of phw_addint on M2 */
    phv U,W; phw_sq2(X,k->Gd,PW_V(k->c[0]),phv_xor(X,PW_V(k->c[1])),&U,&W);          /* U = G + c0, W = G + X + c1 */
    phv T=phw_mul_e(U,W,phw_swp(W),k->Gd,PW_V(k->c[3]));
    phv X2=phv_xor(X,PW_V(k->c[2]));
    return phw_mul_e(T,X2,phw_swp(X2),k->Gd,PW_V(k->c[4])); }
/* n <= 64: V = C0 + n z + sum_{i<8} d_i l_i (d_i = the 8-byte word i): per 16-byte chunk 8 PMULL into the 4 limb-offset
 * sums; limb 4 (Q3.hi) folded by one PMULL2 against g. */
static inline void phw_sk_init(phw_sk*s,const ph_key*K,const ph_el*C0){
    for(int j=0;j<4;j++) for(int l=0;l<4;l++) s->KL[j][l]=phn_pair(K->l[2*j].w[l],K->l[2*j+1].w[l]);
    for(int l=0;l<4;l++) s->Z[l]=vdupq_n_u64(K->z.w[l]);
    pw_set(s->C0,*C0); }
/* 16-byte chunk with k (1..16) valid bytes, zero-filled, no read past p+k */
static inline pq phw_chunk(const uint8_t*p,size_t k){
    if(k>=16) return vld1q_u64((const uint64_t*)p);
    if(k>=8){ uint64x1_t lo=vld1_u64((const uint64_t*)p), hi=vdup_n_u64(0);           /* vector loads: no GPR -> SIMD move */
        if(k>8) hi=vshl_u64(vld1_u64((const uint64_t*)(p+k-8)),vdup_n_s64(-(int64_t)(8*(16-k))));
        return vcombine_u64(lo,hi); }
    uint64_t lo;
    if(k>=4){ uint32_t a,b; memcpy(&a,p,4); memcpy(&b,p+k-4,4); lo=(uint64_t)a|((uint64_t)b<<(8*(k-4))); }
    else { lo=(uint64_t)p[0]|((uint64_t)p[k>>1]<<(8*(k>>1)))|((uint64_t)p[k-1]<<(8*(k-1))); }
    return vcombine_u64(vcreate_u64(lo),vdup_n_u64(0)); }
#define PW_ACC4(Q,D,KL) do{ for(int l_=3;l_>=0;l_--) Q[l_]=PQX3(Q[l_],PM1(D,(KL)[l_]),PM2(D,(KL)[l_])); }while(0)   /* limb 3 first: it feeds the fold */
static inline phv phw_v64(const phw_sk*s,pq Gd,const uint8_t*p,size_t n){
    pq nv=vdupq_n_u64((uint64_t)n), z=vdupq_n_u64(0), Q[4];
    for(int l=0;l<4;l++) Q[l]=PM1(nv,s->Z[l]);
    size_t w=(n+15)/16, last=n-16*(w-1);
    pq D0=phw_chunk(p,w>1? 16 : last); PW_ACC4(Q,D0,s->KL[0]);
    if(w>1){ pq D1=phw_chunk(p+16,w>2? 16 : last); PW_ACC4(Q,D1,s->KL[1]); }
    if(w>2){ pq D2=phw_chunk(p+32,w>3? 16 : last); PW_ACC4(Q,D2,s->KL[2]); }
    if(w>3){ pq D3=phw_chunk(p+48,last); PW_ACC4(Q,D3,s->KL[3]); }
    phv r={PQX3(PQX3(Q[0],vextq_u64(z,Q[1],1),s->C0[0]),PM2(Q[3],Gd),z),PQX3(Q[2],vextq_u64(Q[1],Q[3],1),s->C0[1])}; return r; }
static inline void phw_key_init(phn_key*x){ phw_fk_init(&x->WF,&x->K); phw_sk_init(&x->WS,&x->K,&x->CKS[0]); }

/* ---- two-level (2L) outer stage ---- */
/* unreduced 256x256 product accumulated into r[0..3] (r0 = limbs 0,1 .. r3 = limbs 6,7) */
static inline void phv_mac_u(pq r[4],phv x,phv y,phv ys){
    pq z=vdupq_n_u64(0);
    pq p0=PM1(x.a,y.a), p2=PQX3(PM2(x.a,y.a),PM1(x.a,y.b),PM1(x.b,y.a)), p4=PQX3(PM2(x.a,y.b),PM2(x.b,y.a),PM1(x.b,y.b)), p6=PM2(x.b,y.b);
    pq p1=PQX(PM1(x.a,ys.a),PM2(x.a,ys.a)), p3=PQX(PQX(PM1(x.a,ys.b),PM2(x.a,ys.b)),PQX(PM1(x.b,ys.a),PM2(x.b,ys.a))), p5=PQX(PM1(x.b,ys.b),PM2(x.b,ys.b));
    r[0]=PQX3(r[0],p0,vextq_u64(z,p1,1)); r[1]=PQX3(r[1],p2,vextq_u64(p1,p3,1)); r[2]=PQX3(r[2],p4,vextq_u64(p3,p5,1)); r[3]=PQX3(r[3],p6,vextq_u64(p5,z,1)); }
/* n (< 2^64) times y, unreduced, accumulated */
static inline void phv_mac64_u(pq r[4],uint64_t n,phv y){ pq nq=vdupq_n_u64(n), z=vdupq_n_u64(0);
    pq a0=PM1(nq,y.a), a1=PM2(nq,y.a), b0=PM1(nq,y.b), b1=PM2(nq,y.b);
    r[0]=PQX3(r[0],a0,vextq_u64(z,a1,1)); r[1]=PQX3(r[1],vextq_u64(a1,z,1),PQX(b0,vextq_u64(z,b1,1))); r[2]=PQX(r[2],vextq_u64(b1,z,1)); }
static inline phv phn_ym(const phn_key*x,int e){ phv r={x->YPW[e][0],x->YPW[e][1]}; return r; }
/* region value of q (1..8) reduced block values e[] plus the unreduced accumulator r (e.g. V z or n z): one reduction */
static inline __attribute__((always_inline)) phv phn_cq_c(const phn_key*x,pq r[4],const phv*e,const int q){
    const int h=(q+1)/2, f=q/2;
    _Pragma("clang loop unroll(full)")
    for(int i=1;i<=f;i++){ phv u=phv_xor(e[i-1],phn_ym(x,2*i-1)), w=phv_xor(e[h+i-1],phn_ym(x,2*i)); phv_mac_u(r,u,w,phv_swp(w)); }
    phv v=phv_red(r[0],r[1],r[2],r[3]);
    return (q&1)? phv_xor(v,e[h-1]) : v; }
/* switch on q: fully unrolled pairing */
static inline phv phn_cq(const phn_key*x,pq r[4],const phv*e,int q){
    switch(q){ case 1: return phn_cq_c(x,r,e,1); case 2: return phn_cq_c(x,r,e,2); case 3: return phn_cq_c(x,r,e,3); case 4: return phn_cq_c(x,r,e,4);
               case 5: return phn_cq_c(x,r,e,5); case 6: return phn_cq_c(x,r,e,6); case 7: return phn_cq_c(x,r,e,7); default: return phn_cq_c(x,r,e,8); } }
/* one full region (q = 8): V <- V z + sum_{i=1..4} (b_i + y^{2i-1})(b_{4+i} + y^{2i}).  Block pairs 0 x 2 and 1 x 3 are
 * lane-wise pairings (lanes = blocks 2c, 2c+1), equal weight -> PMULL and PMULL2 into the same 9 point sums, plus the
 * points of V (lane 0) times the points of z; one interpolation + reduction per region. */
static inline phv phn_region2l(const phn_key*x,phv V,const uint8_t*R,const uint8_t*Rn){
    pq s[4][4];
    for(int c=0;c<4;c++) phn_bvals(x,R,c,s[c],Rn);
    pq U[2][4], W[2][4];
    for(int l=0;l<4;l++){ U[0][l]=PQX(s[0][l],x->YA[0][l]); W[0][l]=PQX(s[2][l],x->YB[0][l]); U[1][l]=PQX(s[1][l],x->YA[1][l]); W[1][l]=PQX(s[3][l],x->YB[1][l]); }
    pq v0=V.a, v1=vextq_u64(V.a,V.a,1), v2=V.b, v3=vextq_u64(V.b,V.b,1);   /* lane 0 = limb l (lane 1 unused: PMULL only) */
#define PHN_PTS(P,a0,a1,a2,a3) pq P[9]; P[0]=a0; P[1]=a1; P[2]=PQX(a0,a1); P[3]=a2; P[4]=a3; P[5]=PQX(a2,a3); P[6]=PQX(a0,a2); P[7]=PQX(a1,a3); P[8]=PQX(P[2],P[5])
    PHN_PTS(PU0,U[0][0],U[0][1],U[0][2],U[0][3]); PHN_PTS(PW0,W[0][0],W[0][1],W[0][2],W[0][3]);
    PHN_PTS(PU1,U[1][0],U[1][1],U[1][2],U[1][3]); PHN_PTS(PW1,W[1][0],W[1][1],W[1][2],W[1][3]);
    PHN_PTS(PV,v0,v1,v2,v3);
    pq q[9];
    for(int t=0;t<9;t++) q[t]=PQX(PQX3(PM1(PU0[t],PW0[t]),PM2(PU0[t],PW0[t]),PM1(PU1[t],PW1[t])),PQX(PM2(PU1[t],PW1[t]),PM1(PV[t],x->ZP[t])));
    return phv_interp(q); }
/* tail of nb (1..8) blocks as the last region: V <- V z + c(tail) (V may be the length n, as an element) */
static inline phv phn_tailfold(const phn_key*x,phv V,const uint8_t*T,size_t rem){
    int nb=(int)((rem+PH_BLOCK-1)/PH_BLOCK); phv e[8];
    for(int b=0;b<nb;b++) e[b]=phn_tblkv(x,T+(size_t)b*PH_BLOCK,rem-(size_t)b*PH_BLOCK);
    pq z=vdupq_n_u64(0), r[4]={z,z,z,z}; phv Z={x->ZV[0],x->ZV[1]}, Zs={x->ZVS[0],x->ZVS[1]};
    phv_mac_u(r,V,Z,Zs);
    return phn_cq(x,r,e,nb); }
/* ---- v1.2 NEON one-block tail (64 < n <= 4096): every piece summed unreduced (the reduction is linear), n z included,
 * one PMULL-based reduction; the group accumulators alternate between two chains (one chain = 8 dependent MACs per group). */
static inline void phw_interp_raw(const pq q[9],pq r[4]){ pq z=vdupq_n_u64(0);
    pq mL=PQX3(q[0],q[1],q[2]), mH=PQX3(q[3],q[4],q[5]), mM=PQX3(q[6],q[7],q[8]);
    pq Ll=PQX(q[0],vextq_u64(z,mL,1)), Lh=PQX(q[1],vextq_u64(mL,z,1)), Hl=PQX(q[3],vextq_u64(z,mH,1)), Hh=PQX(q[4],vextq_u64(mH,z,1));
    pq Ml=PQX(q[6],vextq_u64(z,mM,1)), Mh=PQX(q[7],vextq_u64(mM,z,1));
    r[0]=Ll; r[1]=PQX3(Lh,Ml,PQX(Ll,Hl)); r[2]=PQX3(Hl,Mh,PQX(Lh,Hh)); r[3]=Hh; }
static inline phv phw_red_raw(const pq r[4],pq Gd,phv E){ pq z=vdupq_n_u64(0);
    pq h0g=PM1(r[2],Gd), h1g=PM2(r[2],Gd), h2g=PM1(r[3],Gd), h3g=PM2(r[3],Gd), og=PM2(h3g,Gd);
    phv o={PQX3(PQX3(r[0],h0g,og),vextq_u64(z,h1g,1),E.a),PQX3(PQX3(r[1],h2g,E.b),vextq_u64(h1g,h3g,1),z)}; return o; }
static inline __attribute__((always_inline)) void phw_xonly_raw(const phn_key*x,const uint8_t*r0,size_t ag,int g,const int RX,pq r[4]){
    pq z=vdupq_n_u64(0), D[7], D1[7], D2[7], D3[7];
    for(int d=0;d<7;d++){ D[d]=z; D1[d]=z; D2[d]=z; D3[d]=z; }
    _Pragma("clang loop unroll(full)")
    for(int t=0;t<4;t++){ const pq*k=x->KT[g][t]+4; pq*Da=(t&1)? D2 : D; pq*Db=(t&1)? D3 : D1;
        _Pragma("clang loop unroll(full)")
        for(int l=0;l<RX;l++){ pq xv= l<RX-1? PHN_LD(r0+64*l+16*t) : phn_ldz(r0,(size_t)(64*l+16*t),ag);   /* rows < RX-1 are complete */
            _Pragma("clang loop unroll(full)")
            for(int j=0;j<4;j++){ PH_MACL(Da[l+j],xv,k[j]); PH_MACH(Db[l+j],xv,k[j]); } } }
    for(int d=0;d<7;d++) D[d]=PQX(PQX(D[d],D1[d]),PQX(D2[d],D3[d]));
    r[0]=PQX(D[0],vextq_u64(z,D[1],1)); r[1]=PQX3(vextq_u64(D[1],z,1),D[2],vextq_u64(z,D[3],1));
    r[2]=PQX3(vextq_u64(D[3],z,1),D[4],vextq_u64(z,D[5],1)); r[3]=PQX(vextq_u64(D[5],z,1),D[6]); }
static inline __attribute__((always_inline)) void phw_xonly_k_raw_(const phn_key*x,const uint8_t*r0,size_t ag,int g,pq r[4],const int FULL){
    pq z=vdupq_n_u64(0), A[9]={z,z,z,z,z,z,z,z,z}, B[9]={z,z,z,z,z,z,z,z,z};
    _Pragma("clang loop unroll(full)")
    for(int t=0;t<4;t++){ const pq*L=x->LP[g][t]; size_t o=16*(size_t)t; pq*C=(t&1)? B : A;
        pq x0=PHN_LD(r0+o), x1=PHN_LD(r0+o+64);                       /* ag > 128: rows 0, 1 are complete */
        pq x2=(FULL||ag>=192)? PHN_LD(r0+o+128) : phn_ldz(r0,o+128,ag), x3=FULL? PHN_LD(r0+o+192) : phn_ldz(r0,o+192,ag);
        pq u=PHE(x0,x1), u2=PHE(x2,x3), u3=PHE(x0,x2), u4=PHE(x1,x3), u5=PHE(u,u2);
        PH_MACL(C[0],x0,L[0]); PH_MACH(C[0],x0,L[0]); PH_MACL(C[1],x1,L[1]); PH_MACH(C[1],x1,L[1]); PH_MACL(C[2],u,L[2]); PH_MACH(C[2],u,L[2]);
        PH_MACL(C[3],x2,L[3]); PH_MACH(C[3],x2,L[3]); PH_MACL(C[4],x3,L[4]); PH_MACH(C[4],x3,L[4]); PH_MACL(C[5],u2,L[5]); PH_MACH(C[5],u2,L[5]);
        PH_MACL(C[6],u3,L[6]); PH_MACH(C[6],u3,L[6]); PH_MACL(C[7],u4,L[7]); PH_MACH(C[7],u4,L[7]); PH_MACL(C[8],u5,L[8]); PH_MACH(C[8],u5,L[8]); }
    for(int t=0;t<9;t++) A[t]=PQX(A[t],B[t]);
    phw_interp_raw(A,r); }
static inline void phw_xonly_k_raw(const phn_key*x,const uint8_t*r0,size_t ag,int g,pq r[4]){   /* the 4 x rows complete: no per-load bounds */
    if(ag>=256) phw_xonly_k_raw_(x,r0,ag,g,r,1); else phw_xonly_k_raw_(x,r0,ag,g,r,0); }
/* the partial group with 256 < ag < 512 bytes: the x rows are complete (direct loads), the y rows zero-filled */
static inline void phw_grpz(const phn_key*x,const uint8_t*r0,size_t ag,int g,pq A[9]){
    _Pragma("clang loop unroll(full)")
    for(int t=0;t<4;t++){ const pq*k=x->KT[g][t]; size_t o=16*(size_t)t;
        pq x0=PHE(PHN_LD(r0+o),k[0]),x1=PHE(PHN_LD(r0+o+64),k[1]),x2=PHE(PHN_LD(r0+o+128),k[2]),x3=PHE(PHN_LD(r0+o+192),k[3]);
        pq y0=PHE(phn_ldz(r0,o+256,ag),k[4]),y1=PHE(phn_ldz(r0,o+320,ag),k[5]),y2=PHE(phn_ldz(r0,o+384,ag),k[6]),y3=PHE(phn_ldz(r0,o+448,ag),k[7]);
        PHN_K9(A,x0,x1,x2,x3,y0,y1,y2,y3); } }
/* the full groups g < gf (+ the partial group gf with ag bytes if any), two accumulator chains, raw */
static inline void phw_groups_raw(const phn_key*x,const uint8_t*p,int gf,size_t ag,const pq*init,pq r[4]){
    pq z=vdupq_n_u64(0), A[9], B[9]; for(int t=0;t<9;t++){ A[t]=init? init[t] : z; B[t]=z; }
    for(int g=0;g<gf;g++) phn_grp(x,p+512*g,g,(g&1)? B : A);
    if(ag) phw_grpz(x,p+512*gf,ag,gf,(gf&1)? B : A);           /* called with ag == 0 or ag > 256 */
    for(int t=0;t<9;t++) A[t]=PQX(A[t],B[t]);
    phw_interp_raw(A,r); }
/* V = n z + b_1 for 64 < n <= PH_BLOCK (one tail block) */
static inline phv phw_tail(const phn_key*x,const uint8_t*p,size_t n){
    pq z=vdupq_n_u64(0), r[4]; phv E={z,z};
    int gf=(int)(n/512); size_t ag=n-512*(size_t)gf;
    if(n>=PH_BLOCK){ pq A[9], B[9]; for(int t=0;t<9;t++){ A[t]=x->SF9[PH_M/8][t]; B[t]=z; }
        _Pragma("clang loop unroll(full)")
        for(int g=0;g<PH_M/8;g+=2){ phn_grp(x,p+512*g,g,A); phn_grp(x,p+512*(g+1),g+1,B); }
        for(int t=0;t<9;t++) A[t]=PQX(A[t],B[t]);
        phw_interp_raw(A,r); }
    else if(ag==0 || ag>256) phw_groups_raw(x,p,gf,ag,x->SF9[gf+(ag?1:0)],r);
    else { int RX=(int)((ag+63)/64); const uint8_t*pg=p+512*gf;
        if(RX==1) phw_xonly_raw(x,pg,ag,gf,1,r); else if(RX==2) phw_xonly_raw(x,pg,ag,gf,2,r); else phw_xonly_k_raw(x,pg,ag,gf,r);
        E=phv_ld(x->CKS[gf]);
        if(gf){ pq s[4]; phw_groups_raw(x,p,gf,0,0,s); for(int i=0;i<4;i++) r[i]=PQX(r[i],s[i]); } }
    pq nq=vdupq_n_u64((uint64_t)n), a0=PM1(nq,x->ZV[0]), a1=PM2(nq,x->ZV[0]), b0=PM1(nq,x->ZV[1]), b1=PM2(nq,x->ZV[1]);   /* n z, raw */
    r[0]=PQX3(r[0],a0,vextq_u64(z,a1,1)); r[1]=PQX3(r[1],PQX(vextq_u64(a1,z,1),b0),vextq_u64(z,b1,1)); r[2]=PQX(r[2],vextq_u64(b1,z,1));
    return phw_red_raw(r,x->WF.Gd,E); }
/* n < REGION (one region, q = nb): V = n z + c(b_1..b_q); n = 0: V = 0 */
static inline void phn_short(const phn_key*x,const uint8_t*T,size_t n,uint8_t out[32]){
    pq z=vdupq_n_u64(0); phv V={z,z};
    if(n && n<=64) V=phw_v64(&x->WS,x->WF.Gd,T,n);                                               /* v1.2: n z + b_1, one pass */
    else if(n && n<=PH_BLOCK) V=phw_tail(x,T,n);                                                    /* <= 1 block: n z + b_1 */
    else if(n){ int nb=(int)((n+PH_BLOCK-1)/PH_BLOCK); phv e[8];
        for(int b=0;b<nb;b++) e[b]=phn_tblkv(x,T+(size_t)b*PH_BLOCK,n-(size_t)b*PH_BLOCK);
        pq r[4]={z,z,z,z}; phv Z={x->ZV[0],x->ZV[1]}; phv_mac64_u(r,(uint64_t)n,Z);
        V=phn_cq(x,r,e,nb); }
    phn_out(phw_final(V,&x->WF),out); }
static inline void phn_hash(const phn_key*x,const uint8_t*msg,size_t n,uint8_t out[32]){
    size_t nfull=n/PH_REGION, rem=n-nfull*PH_REGION;
    if(!nfull){ phn_short(x,msg,n,out); return; }
    pq z=vdupq_n_u64(0); phv V={vsetq_lane_u64((uint64_t)n,z,0),z};     /* length-leading Horner in z */
    for(size_t r=0;r<nfull;r++) V=phn_region2l(x,V,msg+r*PH_REGION,r+1<nfull? msg+(r+1)*PH_REGION : 0);
    if(rem) V=phn_tailfold(x,V,msg+nfull*PH_REGION,rem);
    phn_out(phw_final(V,&x->WF),out); }
/* ---- streaming API: V (reduced, no length term) ---- */
static inline void phn_fold(const phn_key*x,ph_el*V,const uint8_t*msg,size_t nr){
    phv v=phv_ld(*V); for(size_t r=0;r<nr;r++) v=phn_region2l(x,v,msg+r*PH_REGION,r+1<nr? msg+(r+1)*PH_REGION : 0); *V=phv_st(v); }
static inline void phn_final2l(const phn_key*x,ph_el V,size_t nreg,const uint8_t*T,size_t rem,size_t n,uint8_t out[32]){
    if(!nreg){ phn_hash(x,T,n,out); return; }                     /* no region folded: the buffer is the whole message (rem = n) */
    phv v=phv_ld(V); size_t mp=nreg;
    if(rem){ v=phn_tailfold(x,v,T,rem); mp++; }
    phv Z={x->ZV[0],x->ZV[1]}, zp=Z; size_t e=mp-1;               /* z^{m'} by square-and-multiply */
    while(e){ if(e&1) zp=phv_mul(zp,Z); e>>=1; if(e) Z=phv_sq(Z); }
    pq zz=vdupq_n_u64(0), r[4]={zz,zz,zz,zz}; phv_mac64_u(r,(uint64_t)n,zp);
    v=phv_xor(v,phv_red(r[0],r[1],r[2],r[3]));
    phn_out(phw_final(v,&x->WF),out); }
#endif
static inline int ph256_backend(void){ return PH256_NEON; }
#else
static inline int ph256_backend(void){ return PH256_PORTABLE; }
#endif

/* ---- portable pieces (reference arithmetic) ---- */
static inline void ph256p_fold(const ph_key*K,ph_el*V,const uint8_t*msg,size_t nr){
    ph_el x[PH_M],y[PH_M],b[8];
    for(size_t r=0;r<nr;r++){ for(int bb=0;bb<8;bb++){ ph_region_block(msg+r*PH_REGION,bb,x,y); b[bb]=ph_block(x,y,K); }
        *V=ph_xor(ph_mul(*V,K->z),ph2l_region(b,8,&K->Y)); } }
static inline void ph256p_final2l(const ph_key*K,ph_el V,size_t nreg,const uint8_t*T,size_t rem,size_t n,uint8_t out[32]){
    ph_el x[PH_M],y[PH_M],b[8]; size_t nb=(rem+PH_BLOCK-1)/PH_BLOCK;
    for(size_t bb=0;bb<nb;bb++){ uint8_t blk[PH_BLOCK]; size_t av=rem-bb*PH_BLOCK; if(av>PH_BLOCK) av=PH_BLOCK;
        memcpy(blk,T+bb*PH_BLOCK,av); memset(blk+av,0,PH_BLOCK-av); ph_tail_block(blk,x,y); b[bb]=ph_block(x,y,K); }
    if(nb) V=ph_xor(ph_mul(V,K->z),ph2l_region(b,(int)nb,&K->Y));
    V=ph_xor(V,ph_mul((ph_el){{(uint64_t)n,0,0,0}},ph_pow(K->z,(uint64_t)(nreg+(nb>0)))));
    ph_store(ph_finish(V,K),out); }

/* the portable paths out of line: inlined into the dispatcher, the reference's 4 KiB block buffers give ph256() a large
 * frame, and with stack-clash protection (default in RHEL's gcc) every call -- also the fast backends' -- probes it
 * (Zen 4, gcc 11: 128 B 260 -> 183 ticks) */
static __attribute__((noinline)) void ph256p_hash(const ph_key*K,const uint8_t*m,size_t n,uint8_t out[32]){ ph2l_hash_ref(K,m,n,out); }
static __attribute__((noinline)) void ph256p_fold_(const ph_key*K,ph_el*V,const uint8_t*msg,size_t nr){ ph256p_fold(K,V,msg,nr); }
static __attribute__((noinline)) void ph256p_final2l_(const ph_key*K,ph_el V,size_t nreg,const uint8_t*T,size_t rem,size_t n,uint8_t out[32]){ ph256p_final2l(K,V,nreg,T,rem,n,out); }
/* The backend's expanded key (phx_key, phs_key or phn_key) lives at tstore + toff, 64-byte aligned at the address
 * where the key was initialized: a key in place at any 8-byte-aligned address (malloc, new, the stack, static
 * storage) has aligned tables.  The tables are typed for that alignment, so a key that was copied is not run on
 * them unless they are still 64-byte aligned: otherwise it runs the portable backend (same digests, much slower). */
#if defined(PH256_X86)
#define PH256_TSIZE (sizeof(phx_key) > sizeof(phs_key) ? sizeof(phx_key) : sizeof(phs_key))
#elif defined(PH256_ARM)
#define PH256_TSIZE sizeof(phn_key)
#endif
typedef struct {
    ph_key k; int backend;
#ifdef PH256_TSIZE
    unsigned toff; unsigned char tstore[PH256_TSIZE + 64];
#endif
} ph256_key;
#ifdef PH256_TSIZE
#define PH256_TAB(K) ((void*)((K)->tstore+(K)->toff))
static inline int ph256_be(const ph256_key*K){ return ((uintptr_t)PH256_TAB(K)&63) ? PH256_PORTABLE : K->backend; }
#else
static inline int ph256_be(const ph256_key*K){ return K->backend; }
#endif
#if defined(PH256_X86)
#define PH256_XK(K) ((const phx_key*)PH256_TAB(K))
#define PH256_SK(K) ((const phs_key*)PH256_TAB(K))
#elif defined(PH256_ARM)
#define PH256_NK(K) ((const phn_key*)PH256_TAB(K))
#endif
static inline void ph256_init_key(ph256_key*K,const ph_key*raw,int backend){
    K->k=*raw; int best=ph256_backend();
    int ok= backend==PH256_PORTABLE || backend==best || (best==PH256_AVX512 && backend==PH256_PCLMUL);
    if(backend<0 || !ok) backend=best;
    K->backend=backend;
#ifdef PH256_TSIZE
    K->toff=(unsigned)((64-((uintptr_t)K->tstore&63))&63);
#endif
#if defined(PH256_X86)
    if(backend==PH256_AVX512) phx_key_init((phx_key*)PH256_TAB(K),&K->k);
    if(backend==PH256_PCLMUL) phs_key_init((phs_key*)PH256_TAB(K),&K->k);
#elif defined(PH256_ARM)
    if(backend==PH256_NEON){ phn_key_init((phn_key*)PH256_TAB(K),&K->k); phw_key_init((phn_key*)PH256_TAB(K)); }
#endif
}
#ifdef PH_V2
/* v2 (power key): raw key = s | y | z | t | c0..c4 (288 bytes); the 2*PH_M mask powers are computed here with the
 * fastest field multiply the backend has (the kernels read the table exactly as in v1) */
#if defined(PH256_X86)
#if defined(__clang__)
#pragma clang attribute push (__attribute__((target("avx512f,avx512vl,avx512bw,avx512dq,avx512vbmi2,vpclmulqdq,gfni,pclmul,avx2,sse4.1"))), apply_to=function)
#else
#pragma GCC push_options
#pragma GCC target("avx512f,avx512vl,avx512bw,avx512dq,avx512vbmi2,vpclmulqdq,gfni,pclmul,avx2,sse4.1")
#endif
/* register-resident powers s^1..s^(2m) as 4 interleaved chains stepping by s^4 (latency ~ 2m/4 + 3 multiplies instead
 * of 2m); the ymm multiply on AMD, the zmm one on Intel (identical values) */
#define PH2_MUL(a,b) (zen? phv_muly(a,b) : phv_mul(a,b))
static inline void ph2_derive_x(const ph2_raw*R,ph_key*K,int zen){
    __m256i s1=phv_ld(R->s), s2=PH2_MUL(s1,s1), s3=PH2_MUL(s2,s1), s4=PH2_MUL(s2,s2), c[4]={s1,s2,s3,s4};
    for(int e=1;e<=2*PH_M;e+=4){                                   /* exponents e..e+3 */
        for(int r=0;r<4;r++){ int ex=e+r; ph_el v=phv_st(c[r]); if(ex&1) K->k[(ex-1)/2]=v; else K->l[ex/2-1]=v; }
        for(int r=0;r<4;r++) c[r]=PH2_MUL(c[r],s4); }
    K->Y=R->y; K->z=R->z; K->tau=R->t; for(int i=0;i<5;i++) K->c[i]=R->c[i]; }
#if defined(__clang__)
#pragma clang attribute pop
#else
#pragma GCC pop_options
#endif
#endif
static inline void ph256_derive_(const ph2_raw*R,ph_key*K,int be){
    (void)be;
#if defined(PH256_X86)
    if(be==PH256_AVX512){ ph2_derive_x(R,K,phx_is_amd()); return; }
    if(be==PH256_PCLMUL){ ph2_derive_with(R,K,phs_mul); return; }
#elif defined(PH256_ARM)
    if(be==PH256_NEON){ ph2_derive_with(R,K,phn_mul); return; }
#endif
    ph2_derive(R,K); }
static inline void ph256_init_raw2(ph256_key*K,const ph2_raw*R,int backend){
    int best=ph256_backend(); int ok= backend==PH256_PORTABLE || backend==best || (best==PH256_AVX512 && backend==PH256_PCLMUL);
    if(backend<0 || !ok) backend=best;
    ph_key k; ph256_derive_(R,&k,backend); ph256_init_key(K,&k,backend); }
/* the key as 288 bytes: s, y, z, t, c0..c4, each 32 bytes little-endian (limb 0 first) */
static inline void ph256_init_raw(ph256_key*K,const uint8_t key[288],int backend){ ph2_raw R; ph2_raw_from_bytes(key,&R); ph256_init_raw2(K,&R,backend); }
static inline void ph256_init_backend(ph256_key*K,uint64_t seed,int backend){ ph2_raw R; ph2_raw_from_seed(&R,seed); ph256_init_raw2(K,&R,backend); }
#else
static inline void ph256_init_backend(ph256_key*K,uint64_t seed,int backend){ ph_key raw; ph_key_from_seed(&raw,seed); ph256_init_key(K,&raw,backend); }
#endif
static inline void ph256_init(ph256_key*K,uint64_t seed){ ph256_init_backend(K,seed,-1); }
static inline void ph256(const ph256_key*K,const void*msg,size_t n,uint8_t out[32]){
    const uint8_t*m=(const uint8_t*)msg;
    switch(ph256_be(K)){
#if defined(PH256_X86)
    case PH256_AVX512: phx_hash(PH256_XK(K),m,n,out); return;
    case PH256_PCLMUL: phs_hash(PH256_SK(K),m,n,out); return;
#elif defined(PH256_ARM)
    case PH256_NEON:   phn_hash(PH256_NK(K),m,n,out); return;
#endif
    default: ph256p_hash(&K->k,m,n,out); return; } }

/* ---------------- streaming (2L: every full region is folded as soon as it is complete) ---------------- */
typedef struct { const ph256_key*K; ph_el V; size_t total, nreg, blen; uint8_t buf[PH_REGION]; } ph256_stream;
static inline void ph256_stream_init(ph256_stream*s,const ph256_key*K){ memset(&s->V,0,sizeof s->V); s->K=K; s->total=s->nreg=s->blen=0; }
static inline void ph256_fold_(const ph256_key*K,ph_el*V,const uint8_t*p,size_t nr){
    switch(ph256_be(K)){
#if defined(PH256_X86)
    case PH256_AVX512: phx_fold(PH256_XK(K),V,p,nr); return;
    case PH256_PCLMUL: phs_fold(PH256_SK(K),V,p,nr); return;
#elif defined(PH256_ARM)
    case PH256_NEON: phn_fold(PH256_NK(K),V,p,nr); return;
#endif
    default: ph256p_fold_(&K->k,V,p,nr); return; } }
static inline void ph256_update(ph256_stream*s,const void*data,size_t len){
    const uint8_t*p=(const uint8_t*)data; s->total+=len;
    if(s->blen){ size_t t=PH_REGION-s->blen; if(t>len) t=len; memcpy(s->buf+s->blen,p,t); s->blen+=t; p+=t; len-=t;
        if(s->blen==PH_REGION){ ph256_fold_(s->K,&s->V,s->buf,1); s->nreg++; s->blen=0; } }
    size_t nr=len/PH_REGION;
    if(nr){ ph256_fold_(s->K,&s->V,p,nr); s->nreg+=nr; p+=nr*PH_REGION; len-=nr*PH_REGION; }
    if(len){ memcpy(s->buf,p,len); s->blen=len; } }
static inline void ph256_final(ph256_stream*s,uint8_t out[32]){
    const ph256_key*K=s->K; size_t n=s->total;
    if(!s->nreg){ ph256(K,s->buf,s->blen,out); return; }                 /* every byte is still buffered: one-shot */
    switch(ph256_be(K)){
#if defined(PH256_X86)
    case PH256_AVX512: phx_final2l(PH256_XK(K),s->V,s->nreg,s->buf,s->blen,n,out); return;
    case PH256_PCLMUL: phs_final2l(PH256_SK(K),s->V,s->nreg,s->buf,s->blen,n,out); return;
#elif defined(PH256_ARM)
    case PH256_NEON: phn_final2l(PH256_NK(K),s->V,s->nreg,s->buf,s->blen,n,out); return;
#endif
    default: ph256p_final2l_(&K->k,s->V,s->nreg,s->buf,s->blen,n,out); return; } }
#endif

/* ================= public API ================= */
#define CHAINHASH256_KEY_BYTES 288
#define CHAINHASH256_KEY_WORDS (CHAINHASH256_KEY_BYTES/8)
enum { CH256_PORTABLE=PH256_PORTABLE, CH256_PCLMUL=PH256_PCLMUL, CH256_AVX512=PH256_AVX512, CH256_NEON=PH256_NEON };
typedef ph256_key chainhash256_key;
typedef ph256_stream chainhash256_stream;
static inline int chainhash256_backend(void) { return ph256_backend(); }
static inline int chainhash256_has_backend(int b) { int h=ph256_backend(); return b==PH256_PORTABLE || b==h || (h==PH256_AVX512 && b==PH256_PCLMUL); }
/* key = s, y, z, t, c_0..c_4: 9 elements of 32 bytes, each four little-endian 64-bit limbs, limb 0 first
 * (docs/SPEC-256.md section 2). No key is rejected. The masks s^1..s^128 are derived here.
 * The backend is fixed here (-1: the best one available; an unavailable backend falls back to it). */
static inline void chainhash256_key_from_bytes_with_backend(chainhash256_key *k, const uint8_t p[CHAINHASH256_KEY_BYTES], int b) { ph256_init_raw(k,p,b); }
static inline void chainhash256_key_from_bytes(chainhash256_key *k, const uint8_t p[CHAINHASH256_KEY_BYTES]) { ph256_init_raw(k,p,-1); }
/* the same 288 bytes as 36 little-endian 64-bit words */
static inline void chainhash256_key_from_words_with_backend(chainhash256_key *k, const uint64_t w[CHAINHASH256_KEY_WORDS], int b) {
    uint8_t p[CHAINHASH256_KEY_BYTES]; int i, j;
    for(i=0;i<CHAINHASH256_KEY_WORDS;i++) for(j=0;j<8;j++) p[8*i+j]=(uint8_t)(w[i]>>(8*j));
    ph256_init_raw(k,p,b);
}
static inline void chainhash256_key_from_words(chainhash256_key *k, const uint64_t w[CHAINHASH256_KEY_WORDS]) { chainhash256_key_from_words_with_backend(k,w,-1); }
/* SplitMix64 expansion of a seed (the vectors' seed keys; a zero y becomes 1): for benchmarks and tests,
 * not covered by the bound */
static inline void chainhash256_key_from_seed_with_backend(chainhash256_key *k, uint64_t seed, int b) { ph256_init_backend(k,seed,b); }
static inline void chainhash256_key_from_seed(chainhash256_key *k, uint64_t seed) { ph256_init(k,seed); }
static inline int chainhash256_key_backend(const chainhash256_key *k) { return ph256_be(k); }
static inline void chainhash256(const chainhash256_key *k, const void *data, size_t len, uint8_t out[32]) { ph256(k,data,len,out); }
/* the definition, literally (bit-serial); for tests */
static inline void chainhash256_reference(const chainhash256_key *k, const void *data, size_t len, uint8_t out[32]) { ph2l_hash_ref(&k->k,(const uint8_t*)data,len,out); }
static inline void chainhash256_init(chainhash256_stream *s, const chainhash256_key *k) { ph256_stream_init(s,k); }
static inline void chainhash256_update(chainhash256_stream *s, const void *data, size_t len) { ph256_update(s,data,len); }
static inline void chainhash256_final(chainhash256_stream *s, uint8_t out[32]) { ph256_final(s,out); }

#endif /* CHAINHASH256_H */
