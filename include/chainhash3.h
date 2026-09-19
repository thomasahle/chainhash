/* ChainHash v3 (Horner), Thomas Dybdahl Ahle, 2026. MIT.
 * C99/C++11. Canonical little endian. See docs/SPEC_v3.md for the definition and index map.
 * Explicit ISA entry points require chainhash_v3_has_backend().
 * AArch64: compile with -march=armv8-a+crypto (Apple: -march=native+crypto).
 * Define CHAINHASH_V3_PORTABLE to omit all hardware code.
 * Long-input loop structure inspired by Orson Peters's PolymurHash:
 * https://github.com/orlp/polymur-hash
 */
#ifndef CHAINHASH_V3_H
#define CHAINHASH_V3_H
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <assert.h>
#define CHAINHASH_V3_RANDOM_BYTES 64
#define CHAINHASH_V3_IDEAL_BYTES 312
/* ph[4C..4C+3] = kappa[4C], kappa[4C+2], kappa[4C+1], kappa[4C+3]. */
typedef struct { uint64_t ph[32], yp[9], yh[9], c[5], tau; } chainhash_v3_key;
typedef struct { uint64_t lo, hi; } chv3_raw;
enum { CHV3_PORTABLE=0, CHV3_XMM=1, CHV3_YMM=2, CHV3_ZMM=3, CHV3_NEON=4 };
static inline uint64_t chv3_word(const uint8_t *p,size_t n,size_t off) {
    uint64_t a=0; unsigned i;
    if(off>=n) return 0;
#if defined(__BYTE_ORDER__) && __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
    if(n-off>=8) { memcpy(&a,p+off,8); return a; }
#endif
    for(i=0;i<8 && i<n-off;i++) a|=(uint64_t)p[off+i]<<(8*i);
    return a;
}
static inline chv3_raw chv3_clmul(uint64_t a,uint64_t b) {
    chv3_raw r={0,0}; unsigned i;
    for(i=0;i<64;i++) { uint64_t m=0-((b>>i)&1); r.lo^=(a<<i)&m; if(i) r.hi^=(a>>(64-i))&m; }
    return r;
}
static inline uint64_t chv3_reduce(chv3_raw a) {
    uint64_t h=a.hi, q=(h>>63)^(h>>61)^(h>>60);
    return a.lo^h^(h<<1)^(h<<3)^(h<<4)^q^(q<<1)^(q<<3)^(q<<4);
}
static inline uint64_t chv3_mul(uint64_t a,uint64_t b) { return chv3_reduce(chv3_clmul(a,b)); }
static inline void chv3_schedule(chainhash_v3_key *k,uint64_t y) {
    unsigned i; k->yp[0]=1; k->yh[0]=27;
    for(i=1;i<=8;i++) { k->yp[i]=chv3_mul(k->yp[i-1],y); k->yh[i]=chv3_mul(27,k->yp[i]); }
}
static inline chainhash_v3_key chainhash_v3_key_from_words(const uint64_t w[39]) {
    chainhash_v3_key k; unsigned c;
    for(c=0;c<8;c++) { k.ph[4*c]=w[4*c]; k.ph[4*c+1]=w[4*c+2]; k.ph[4*c+2]=w[4*c+1]; k.ph[4*c+3]=w[4*c+3]; }
    chv3_schedule(&k,w[32]); for(c=0;c<5;c++) k.c[c]=w[33+c]; k.tau=w[38]; return k;
}
static inline chainhash_v3_key chainhash_v3_key_from_ideal_bytes(const uint8_t b[312]) {
    uint64_t w[39]; unsigned i; for(i=0;i<39;i++) w[i]=chv3_word(b,312,8*i); return chainhash_v3_key_from_words(w);
}
static inline chainhash_v3_key chainhash_v3_key_from_bytes(const uint8_t b[64]) {
    uint64_t w[39],s=chv3_word(b,64,0),v=s; unsigned i;
    for(i=0;i<32;i++) { w[i]=v; v=chv3_mul(v,s); }
    for(i=0;i<7;i++) w[32+i]=chv3_word(b,64,8*(i+1));
    return chainhash_v3_key_from_words(w);
}
/* Convenience benchmark seed expansion, not 64 bytes of independent entropy. */
static inline chainhash_v3_key chainhash_v3_key_from_seed(uint64_t seed) {
    uint8_t b[64]; unsigned i,j;
    for(i=0;i<8;i++) { uint64_t z=(seed+=UINT64_C(0x9e3779b97f4a7c15)); z=(z^(z>>30))*UINT64_C(0xbf58476d1ce4e5b9); z=(z^(z>>27))*UINT64_C(0x94d049bb133111eb); z^=z>>31; for(j=0;j<8;j++) b[8*i+j]=(uint8_t)(z>>(8*j)); }
    return chainhash_v3_key_from_bytes(b);
}
#if !defined(CHAINHASH_V3_PORTABLE) && (defined(__x86_64__) || defined(__i386__)) && (defined(__GNUC__) || defined(__clang__))
#define CHV3_X86 1
#include <immintrin.h>
#include <cpuid.h>
#define CHV3_T128 __attribute__((target("avx,pclmul")))
#define CHV3_T256 __attribute__((target("avx2,pclmul,vpclmulqdq")))
#define CHV3_T512 __attribute__((target("avx2,pclmul,avx512f,vpclmulqdq")))
static inline int chv3_detect(void) {
    unsigned a,b,c,d,l,h;
    if(!__get_cpuid(1,&a,&b,&c,&d) || (c&((1u<<1)|(1u<<27)|(1u<<28)))!=((1u<<1)|(1u<<27)|(1u<<28))) return 0;
    __asm__("xgetbv":"=a"(l),"=d"(h):"c"(0)); if((l&6)!=6) return 0;
    if(!__get_cpuid_count(7,0,&a,&b,&c,&d) || !(b&(1u<<5)) || !(c&(1u<<10))) return 1;
    return (l&0xe6)==0xe6 && (b&(1u<<16)) ? 3:2;
}
CHV3_T128 static inline chv3_raw chv3_hwprod(uint64_t a,uint64_t b) {
    chv3_raw r; __m128i v=_mm_clmulepi64_si128(_mm_set_epi64x(0,(long long)a),_mm_set_epi64x(0,(long long)b),0); _mm_storeu_si128((__m128i_u *)&r,v); return r;
}
#elif !defined(CHAINHASH_V3_PORTABLE) && defined(__aarch64__) && !defined(__AARCH64EB__) && (defined(__ARM_FEATURE_AES) || defined(__ARM_FEATURE_CRYPTO))
#define CHV3_ARM 1
#include <arm_neon.h>
static inline uint64x2_t chv3_ll(uint64x2_t a,uint64x2_t b) { uint64x2_t r; __asm__("pmull %0.1q, %1.1d, %2.1d":"=w"(r):"w"(a),"w"(b)); return r; }
static inline uint64x2_t chv3_hh(uint64x2_t a,uint64x2_t b) { uint64x2_t r; __asm__("pmull2 %0.1q, %1.2d, %2.2d":"=w"(r):"w"(a),"w"(b)); return r; }
static inline uint64x2_t chv3_xor3(uint64x2_t a,uint64x2_t b,uint64x2_t c) {
#if defined(__ARM_FEATURE_SHA3)
    return veor3q_u64(a,b,c);
#else
    return veorq_u64(a,veorq_u64(b,c));
#endif
}
static inline chv3_raw chv3_hwprod(uint64_t a,uint64_t b) { chv3_raw r; vst1q_u64(&r.lo,chv3_ll(vcombine_u64(vcreate_u64(a),vcreate_u64(0)),vcombine_u64(vcreate_u64(b),vcreate_u64(0)))); return r; }
#endif
static inline int chainhash_v3_backend(void) {
#ifdef CHV3_X86
    static int cache=-1; int v=__atomic_load_n(&cache,__ATOMIC_RELAXED); if(v<0) { v=chv3_detect(); __atomic_store_n(&cache,v,__ATOMIC_RELAXED); } return v;
#elif defined(CHV3_ARM)
    return CHV3_NEON;
#else
    return 0;
#endif
}
static inline int chainhash_v3_has_backend(int b) { int h=chainhash_v3_backend(); return b==0 || (h==4 ? b==4 : b>0 && b<=h); }
static inline chv3_raw chv3_prod(uint64_t a,uint64_t b,int backend) {
#if defined(CHV3_X86) || defined(CHV3_ARM)
    if(backend) return chv3_hwprod(a,b);
#else
    (void)backend;
#endif
    return chv3_clmul(a,b);
}
static inline uint64_t chv3_fmul(uint64_t a,uint64_t b,int backend) { return chv3_reduce(chv3_prod(a,b,backend)); }
static inline uint64_t chv3_pow(uint64_t a,uint64_t n,int backend) { uint64_t r=1; while(n) { if(n&1) r=chv3_fmul(r,a,backend); n>>=1; if(n) a=chv3_fmul(a,a,backend); } return r; }
#ifdef CHV3_X86
CHV3_T128 static inline __m128i chv3_vreduce(__m128i a) {
    const __m128i r=_mm_set1_epi64x(27);
    __m128i t=_mm_clmulepi64_si128(a,r,0x11),u=_mm_clmulepi64_si128(t,r,0x11);
    return _mm_xor_si128(a,_mm_xor_si128(t,u));
}
CHV3_T128 static uint64_t chv3_fastfinish(const chainhash_v3_key *k,uint64_t v) {
    __m128i x=_mm_set_epi64x(0,(long long)(v+k->tau)),q=chv3_vreduce(_mm_clmulepi64_si128(x,x,0));
    __m128i a=_mm_xor_si128(q,_mm_set_epi64x(0,(long long)k->c[0])),b=_mm_xor_si128(_mm_xor_si128(x,q),_mm_set_epi64x(0,(long long)k->c[1]));
    __m128i r=chv3_vreduce(_mm_clmulepi64_si128(a,b,0));
    r=chv3_vreduce(_mm_clmulepi64_si128(_mm_xor_si128(x,_mm_set_epi64x(0,(long long)k->c[2])),_mm_xor_si128(r,_mm_set_epi64x(0,(long long)k->c[3])),0));
    return (uint64_t)_mm_cvtsi128_si64(r)^k->c[4];
}
#elif defined(CHV3_ARM)
static inline uint64x2_t chv3_vreduce(uint64x2_t a) { const uint64x2_t r=vdupq_n_u64(27); uint64x2_t t=chv3_hh(a,r); return chv3_xor3(a,t,chv3_hh(t,r)); }
static inline uint64x2_t chv3_v64(uint64_t v) { return vcombine_u64(vcreate_u64(v),vcreate_u64(0)); }
static inline uint64x2_t chv3_ld(const uint8_t *p) { return vreinterpretq_u64_u8(vld1q_u8(p)); }
static inline uint64_t chv3_finish_neon_vec(const chainhash_v3_key *k,uint64x2_t v) {
    uint64x2_t x=vaddq_u64(v,chv3_v64(k->tau)),q=chv3_vreduce(chv3_ll(x,x));
    uint64x2_t a=veorq_u64(q,chv3_v64(k->c[0])),b=chv3_xor3(x,q,chv3_v64(k->c[1]));
    uint64x2_t r=chv3_vreduce(chv3_ll(a,b));
    r=chv3_vreduce(chv3_ll(veorq_u64(x,chv3_v64(k->c[2])),veorq_u64(r,chv3_v64(k->c[3]))));
    return vgetq_lane_u64(r,0)^k->c[4];
}
static inline uint64_t chv3_fastfinish(const chainhash_v3_key *k,uint64_t v) {
    return chv3_finish_neon_vec(k,chv3_v64(v));
}
/* Short and final partial regions retain raw products and the Horner fold
 * in SIMD registers. Only the final digest leaves lane 0. */
static uint64_t chv3_tail_neon(const chainhash_v3_key *k,const uint8_t *p,size_t n,uint64_t leading) {
    uint64x2_t u[4]={vdupq_n_u64(0),vdupq_n_u64(0),vdupq_n_u64(0),vdupq_n_u64(0)};
    unsigned c=0,j,lanes=n>48?4:n?(unsigned)((n-1)/16+1):1;
    size_t rem=n;
    while(rem) {
        uint8_t tmp[128]={0}; const uint8_t *q=p; size_t take=rem<128?rem:128;
        if(take<128) { memcpy(tmp,p,take); q=tmp; }
        uint64x2_t ka=vld1q_u64(k->ph+4*c),kb=vld1q_u64(k->ph+4*c+2);
        for(j=0;j<4;j++) if(16*j<take) {
            uint64x2_t a=veorq_u64(chv3_ld(q+16*j),ka);
            uint64x2_t b=veorq_u64(chv3_ld(q+64+16*j),kb);
            if(take<=16*j+8) { a=vsetq_lane_u64(0,a,1); b=vsetq_lane_u64(0,b,1); }
            u[j]=chv3_xor3(u[j],chv3_ll(a,b),chv3_hh(a,b));
        }
        rem-=take; p+=take; ++c;
    }
    uint64x2_t acc=chv3_ll(chv3_v64(leading),chv3_v64(k->yp[lanes]));
    for(j=0;j<lanes;j++) {
        unsigned e=lanes-1-j;
        if(!e) acc=veorq_u64(acc,u[j]);
        else { uint64x2_t pw=vcombine_u64(vcreate_u64(k->yp[e]),vcreate_u64(k->yh[e])); acc=chv3_xor3(acc,chv3_ll(u[j],pw),chv3_hh(u[j],pw)); }
    }
    return chv3_finish_neon_vec(k,chv3_vreduce(acc));
}
#endif
static inline uint64_t chv3_finish(const chainhash_v3_key *k,uint64_t v,int b) {
#if defined(CHV3_X86) || defined(CHV3_ARM)
    if(b) return chv3_fastfinish(k,v);
#endif
    uint64_t q,r; v+=k->tau; q=chv3_fmul(v,v,b); r=chv3_fmul(q^k->c[0],v^q^k->c[1],b); return chv3_fmul(v^k->c[2],r^k->c[3],b)^k->c[4]; }
static inline unsigned chv3_lanes(size_t n) { return n>48 ? 4 : n ? (unsigned)((n-1)/16+1) : 1; }
/* Partial region: a pair is active iff its FIRST word has a byte. */
static inline void chv3_region_scalar(const chainhash_v3_key *k,const uint8_t *p,size_t n,chv3_raw out[4],int b) {
    unsigned c,j,e; memset(out,0,4*sizeof(*out));
    for(c=0;c<8;c++) for(j=0;j<4;j++) for(e=0;e<2;e++) {
        size_t off=128*c+16*j+8*e;
        if(off<n) { chv3_raw v=chv3_prod(chv3_word(p,n,off)^k->ph[4*c+e],chv3_word(p,n,off+64)^k->ph[4*c+2+e],b); out[j].lo^=v.lo; out[j].hi^=v.hi; }
    }
}

#ifdef CHV3_X86
CHV3_T128 static inline void chv3_region128(const chainhash_v3_key *k,const uint8_t *p,chv3_raw out[4]) {
    unsigned j; for(j=0;j<4;j+=1) {
    __m128i a=_mm_setzero_si128();
    { __m128i x=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+0+16*j)),_mm_loadu_si128((const __m128i_u *)(k->ph+0))), y=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+64+16*j)),_mm_loadu_si128((const __m128i_u *)(k->ph+2))); a=_mm_xor_si128(a,_mm_xor_si128(_mm_clmulepi64_si128(x,y,0),_mm_clmulepi64_si128(x,y,0x11))); }
    { __m128i x=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+128+16*j)),_mm_loadu_si128((const __m128i_u *)(k->ph+4))), y=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+192+16*j)),_mm_loadu_si128((const __m128i_u *)(k->ph+6))); a=_mm_xor_si128(a,_mm_xor_si128(_mm_clmulepi64_si128(x,y,0),_mm_clmulepi64_si128(x,y,0x11))); }
    { __m128i x=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+256+16*j)),_mm_loadu_si128((const __m128i_u *)(k->ph+8))), y=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+320+16*j)),_mm_loadu_si128((const __m128i_u *)(k->ph+10))); a=_mm_xor_si128(a,_mm_xor_si128(_mm_clmulepi64_si128(x,y,0),_mm_clmulepi64_si128(x,y,0x11))); }
    { __m128i x=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+384+16*j)),_mm_loadu_si128((const __m128i_u *)(k->ph+12))), y=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+448+16*j)),_mm_loadu_si128((const __m128i_u *)(k->ph+14))); a=_mm_xor_si128(a,_mm_xor_si128(_mm_clmulepi64_si128(x,y,0),_mm_clmulepi64_si128(x,y,0x11))); }
    { __m128i x=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+512+16*j)),_mm_loadu_si128((const __m128i_u *)(k->ph+16))), y=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+576+16*j)),_mm_loadu_si128((const __m128i_u *)(k->ph+18))); a=_mm_xor_si128(a,_mm_xor_si128(_mm_clmulepi64_si128(x,y,0),_mm_clmulepi64_si128(x,y,0x11))); }
    { __m128i x=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+640+16*j)),_mm_loadu_si128((const __m128i_u *)(k->ph+20))), y=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+704+16*j)),_mm_loadu_si128((const __m128i_u *)(k->ph+22))); a=_mm_xor_si128(a,_mm_xor_si128(_mm_clmulepi64_si128(x,y,0),_mm_clmulepi64_si128(x,y,0x11))); }
    { __m128i x=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+768+16*j)),_mm_loadu_si128((const __m128i_u *)(k->ph+24))), y=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+832+16*j)),_mm_loadu_si128((const __m128i_u *)(k->ph+26))); a=_mm_xor_si128(a,_mm_xor_si128(_mm_clmulepi64_si128(x,y,0),_mm_clmulepi64_si128(x,y,0x11))); }
    { __m128i x=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+896+16*j)),_mm_loadu_si128((const __m128i_u *)(k->ph+28))), y=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+960+16*j)),_mm_loadu_si128((const __m128i_u *)(k->ph+30))); a=_mm_xor_si128(a,_mm_xor_si128(_mm_clmulepi64_si128(x,y,0),_mm_clmulepi64_si128(x,y,0x11))); }
    _mm_storeu_si128((__m128i_u *)(out+j),a); }
}
CHV3_T256 static inline void chv3_region256(const chainhash_v3_key *k,const uint8_t *p,chv3_raw out[4]) {
    unsigned j; for(j=0;j<4;j+=2) {
    __m256i a=_mm256_setzero_si256();
    { __m256i x=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+0+16*j)),_mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i_u *)(k->ph+0)))), y=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+64+16*j)),_mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i_u *)(k->ph+2)))); a=_mm256_xor_si256(a,_mm256_xor_si256(_mm256_clmulepi64_epi128(x,y,0),_mm256_clmulepi64_epi128(x,y,0x11))); }
    { __m256i x=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+128+16*j)),_mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i_u *)(k->ph+4)))), y=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+192+16*j)),_mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i_u *)(k->ph+6)))); a=_mm256_xor_si256(a,_mm256_xor_si256(_mm256_clmulepi64_epi128(x,y,0),_mm256_clmulepi64_epi128(x,y,0x11))); }
    { __m256i x=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+256+16*j)),_mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i_u *)(k->ph+8)))), y=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+320+16*j)),_mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i_u *)(k->ph+10)))); a=_mm256_xor_si256(a,_mm256_xor_si256(_mm256_clmulepi64_epi128(x,y,0),_mm256_clmulepi64_epi128(x,y,0x11))); }
    { __m256i x=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+384+16*j)),_mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i_u *)(k->ph+12)))), y=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+448+16*j)),_mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i_u *)(k->ph+14)))); a=_mm256_xor_si256(a,_mm256_xor_si256(_mm256_clmulepi64_epi128(x,y,0),_mm256_clmulepi64_epi128(x,y,0x11))); }
    { __m256i x=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+512+16*j)),_mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i_u *)(k->ph+16)))), y=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+576+16*j)),_mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i_u *)(k->ph+18)))); a=_mm256_xor_si256(a,_mm256_xor_si256(_mm256_clmulepi64_epi128(x,y,0),_mm256_clmulepi64_epi128(x,y,0x11))); }
    { __m256i x=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+640+16*j)),_mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i_u *)(k->ph+20)))), y=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+704+16*j)),_mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i_u *)(k->ph+22)))); a=_mm256_xor_si256(a,_mm256_xor_si256(_mm256_clmulepi64_epi128(x,y,0),_mm256_clmulepi64_epi128(x,y,0x11))); }
    { __m256i x=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+768+16*j)),_mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i_u *)(k->ph+24)))), y=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+832+16*j)),_mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i_u *)(k->ph+26)))); a=_mm256_xor_si256(a,_mm256_xor_si256(_mm256_clmulepi64_epi128(x,y,0),_mm256_clmulepi64_epi128(x,y,0x11))); }
    { __m256i x=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+896+16*j)),_mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i_u *)(k->ph+28)))), y=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+960+16*j)),_mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i_u *)(k->ph+30)))); a=_mm256_xor_si256(a,_mm256_xor_si256(_mm256_clmulepi64_epi128(x,y,0),_mm256_clmulepi64_epi128(x,y,0x11))); }
    _mm256_storeu_si256((__m256i_u *)(out+j),a); }
}
CHV3_T512 static inline void chv3_region512(const chainhash_v3_key *k,const uint8_t *p,chv3_raw out[4]) {
    unsigned j; for(j=0;j<4;j+=4) {
    __m512i a=_mm512_setzero_si512();
    { __m512i x=_mm512_xor_si512(_mm512_loadu_si512(p+0+16*j),_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+0)))), y=_mm512_xor_si512(_mm512_loadu_si512(p+64+16*j),_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+2)))); a=_mm512_xor_si512(a,_mm512_xor_si512(_mm512_clmulepi64_epi128(x,y,0),_mm512_clmulepi64_epi128(x,y,0x11))); }
    { __m512i x=_mm512_xor_si512(_mm512_loadu_si512(p+128+16*j),_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+4)))), y=_mm512_xor_si512(_mm512_loadu_si512(p+192+16*j),_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+6)))); a=_mm512_xor_si512(a,_mm512_xor_si512(_mm512_clmulepi64_epi128(x,y,0),_mm512_clmulepi64_epi128(x,y,0x11))); }
    { __m512i x=_mm512_xor_si512(_mm512_loadu_si512(p+256+16*j),_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+8)))), y=_mm512_xor_si512(_mm512_loadu_si512(p+320+16*j),_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+10)))); a=_mm512_xor_si512(a,_mm512_xor_si512(_mm512_clmulepi64_epi128(x,y,0),_mm512_clmulepi64_epi128(x,y,0x11))); }
    { __m512i x=_mm512_xor_si512(_mm512_loadu_si512(p+384+16*j),_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+12)))), y=_mm512_xor_si512(_mm512_loadu_si512(p+448+16*j),_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+14)))); a=_mm512_xor_si512(a,_mm512_xor_si512(_mm512_clmulepi64_epi128(x,y,0),_mm512_clmulepi64_epi128(x,y,0x11))); }
    { __m512i x=_mm512_xor_si512(_mm512_loadu_si512(p+512+16*j),_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+16)))), y=_mm512_xor_si512(_mm512_loadu_si512(p+576+16*j),_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+18)))); a=_mm512_xor_si512(a,_mm512_xor_si512(_mm512_clmulepi64_epi128(x,y,0),_mm512_clmulepi64_epi128(x,y,0x11))); }
    { __m512i x=_mm512_xor_si512(_mm512_loadu_si512(p+640+16*j),_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+20)))), y=_mm512_xor_si512(_mm512_loadu_si512(p+704+16*j),_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+22)))); a=_mm512_xor_si512(a,_mm512_xor_si512(_mm512_clmulepi64_epi128(x,y,0),_mm512_clmulepi64_epi128(x,y,0x11))); }
    { __m512i x=_mm512_xor_si512(_mm512_loadu_si512(p+768+16*j),_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+24)))), y=_mm512_xor_si512(_mm512_loadu_si512(p+832+16*j),_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+26)))); a=_mm512_xor_si512(a,_mm512_xor_si512(_mm512_clmulepi64_epi128(x,y,0),_mm512_clmulepi64_epi128(x,y,0x11))); }
    { __m512i x=_mm512_xor_si512(_mm512_loadu_si512(p+896+16*j),_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+28)))), y=_mm512_xor_si512(_mm512_loadu_si512(p+960+16*j),_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+30)))); a=_mm512_xor_si512(a,_mm512_xor_si512(_mm512_clmulepi64_epi128(x,y,0),_mm512_clmulepi64_epi128(x,y,0x11))); }
    _mm512_storeu_si512((out+j),a); }
}
/* Keep narrow live ranges bounded: the 16-register ISA cannot retain
 * sixteen PH keys, four raw states and four PH sums simultaneously. These
 * loads deliberately stay in the loop; each pattern serves all four lanes. */
CHV3_T128 static inline __m128i chv3_key128(const uint64_t *p) {
    __m128i r; __asm__ volatile("vmovdqu {%1, %0|%0, %1}" : "=x"(r) : "m"(*(const __m128i_u *)p)); return r;
}
CHV3_T256 static inline __m256i chv3_key256(const uint64_t *p) {
    __m256i r; __asm__ volatile("vbroadcasti128 {%1, %0|%0, %1}" : "=x"(r) : "m"(*(const __m128i_u *)p)); return r;
}
CHV3_T128 static inline __m128i chv3_xor128(__m128i a,__m128i b,__m128i c) {
    __m128i r=_mm_xor_si128(a,_mm_xor_si128(b,c)); __asm__("" : "+x"(r)); return r;
}
CHV3_T256 static inline __m256i chv3_xor256(__m256i a,__m256i b,__m256i c) {
    __m256i r=_mm256_xor_si256(a,_mm256_xor_si256(b,c)); __asm__("" : "+x"(r)); return r;
}
CHV3_T128 static uint64_t chv3_bulk128(const chainhash_v3_key *k,const uint8_t *p,size_t regions,size_t len) {
    __m128i s0=_mm_setzero_si128();
    __m128i s1=_mm_setzero_si128();
    __m128i s2=_mm_setzero_si128();
    __m128i s3=_mm_set_epi64x(0,(long long)len);
    const __m128i y=_mm_set_epi64x((long long)k->yh[4],(long long)k->yp[4]);
    do {
        __m128i u0=_mm_setzero_si128();
        __m128i u1=_mm_setzero_si128();
        __m128i u2=_mm_setzero_si128();
        __m128i u3=_mm_setzero_si128();
        { const __m128i ka=chv3_key128(k->ph+0), kb=chv3_key128(k->ph+2);
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+0)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+64)),kb); u0=chv3_xor128(u0,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+16)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+80)),kb); u1=chv3_xor128(u1,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+32)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+96)),kb); u2=chv3_xor128(u2,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+48)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+112)),kb); u3=chv3_xor128(u3,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
        }
        { const __m128i ka=chv3_key128(k->ph+4), kb=chv3_key128(k->ph+6);
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+128)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+192)),kb); u0=chv3_xor128(u0,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+144)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+208)),kb); u1=chv3_xor128(u1,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+160)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+224)),kb); u2=chv3_xor128(u2,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+176)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+240)),kb); u3=chv3_xor128(u3,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
        }
        { const __m128i ka=chv3_key128(k->ph+8), kb=chv3_key128(k->ph+10);
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+256)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+320)),kb); u0=chv3_xor128(u0,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+272)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+336)),kb); u1=chv3_xor128(u1,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+288)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+352)),kb); u2=chv3_xor128(u2,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+304)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+368)),kb); u3=chv3_xor128(u3,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
        }
        { const __m128i ka=chv3_key128(k->ph+12), kb=chv3_key128(k->ph+14);
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+384)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+448)),kb); u0=chv3_xor128(u0,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+400)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+464)),kb); u1=chv3_xor128(u1,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+416)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+480)),kb); u2=chv3_xor128(u2,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+432)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+496)),kb); u3=chv3_xor128(u3,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
        }
        { const __m128i ka=chv3_key128(k->ph+16), kb=chv3_key128(k->ph+18);
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+512)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+576)),kb); u0=chv3_xor128(u0,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+528)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+592)),kb); u1=chv3_xor128(u1,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+544)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+608)),kb); u2=chv3_xor128(u2,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+560)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+624)),kb); u3=chv3_xor128(u3,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
        }
        { const __m128i ka=chv3_key128(k->ph+20), kb=chv3_key128(k->ph+22);
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+640)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+704)),kb); u0=chv3_xor128(u0,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+656)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+720)),kb); u1=chv3_xor128(u1,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+672)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+736)),kb); u2=chv3_xor128(u2,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+688)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+752)),kb); u3=chv3_xor128(u3,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
        }
        { const __m128i ka=chv3_key128(k->ph+24), kb=chv3_key128(k->ph+26);
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+768)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+832)),kb); u0=chv3_xor128(u0,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+784)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+848)),kb); u1=chv3_xor128(u1,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+800)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+864)),kb); u2=chv3_xor128(u2,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+816)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+880)),kb); u3=chv3_xor128(u3,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
        }
        { const __m128i ka=chv3_key128(k->ph+28), kb=chv3_key128(k->ph+30);
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+896)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+960)),kb); u0=chv3_xor128(u0,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+912)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+976)),kb); u1=chv3_xor128(u1,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+928)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+992)),kb); u2=chv3_xor128(u2,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
          { __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+944)),ka), b=_mm_xor_si128(_mm_loadu_si128((const __m128i_u *)(p+1008)),kb); u3=chv3_xor128(u3,_mm_clmulepi64_si128(a,b,0),_mm_clmulepi64_si128(a,b,0x11)); }
        }
        s0=chv3_xor128(u0,_mm_clmulepi64_si128(s0,y,0),_mm_clmulepi64_si128(s0,y,0x11));
        s1=chv3_xor128(u1,_mm_clmulepi64_si128(s1,y,0),_mm_clmulepi64_si128(s1,y,0x11));
        s2=chv3_xor128(u2,_mm_clmulepi64_si128(s2,y,0),_mm_clmulepi64_si128(s2,y,0x11));
        s3=chv3_xor128(u3,_mm_clmulepi64_si128(s3,y,0),_mm_clmulepi64_si128(s3,y,0x11));
        p+=1024;
    } while(--regions);
    __m128i acc=_mm_setzero_si128(),pw;
    pw=_mm_set_epi64x((long long)k->yh[3],(long long)k->yp[3]);
    acc=_mm_xor_si128(acc,_mm_xor_si128(_mm_clmulepi64_si128(s0,pw,0),_mm_clmulepi64_si128(s0,pw,0x11)));
    pw=_mm_set_epi64x((long long)k->yh[2],(long long)k->yp[2]);
    acc=_mm_xor_si128(acc,_mm_xor_si128(_mm_clmulepi64_si128(s1,pw,0),_mm_clmulepi64_si128(s1,pw,0x11)));
    pw=_mm_set_epi64x((long long)k->yh[1],(long long)k->yp[1]);
    acc=_mm_xor_si128(acc,_mm_xor_si128(_mm_clmulepi64_si128(s2,pw,0),_mm_clmulepi64_si128(s2,pw,0x11)));
    pw=_mm_set_epi64x((long long)k->yh[0],(long long)k->yp[0]);
    acc=_mm_xor_si128(acc,_mm_xor_si128(_mm_clmulepi64_si128(s3,pw,0),_mm_clmulepi64_si128(s3,pw,0x11)));
    __m128i a=acc;
    return (uint64_t)_mm_cvtsi128_si64(chv3_vreduce(a));
}
CHV3_T256 static uint64_t chv3_bulk256(const chainhash_v3_key *k,const uint8_t *p,size_t regions,size_t len) {
    __m256i s0=_mm256_setzero_si256();
    __m256i s1=_mm256_set_epi64x(0,(long long)len,0,0);
    const __m256i y=_mm256_set_epi64x((long long)k->yh[4],(long long)k->yp[4],(long long)k->yh[4],(long long)k->yp[4]);
    do {
        __m256i u0=_mm256_setzero_si256();
        __m256i u1=_mm256_setzero_si256();
        { const __m256i ka=chv3_key256(k->ph+0), kb=chv3_key256(k->ph+2);
          { __m256i a=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+0)),ka), b=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+64)),kb); u0=chv3_xor256(u0,_mm256_clmulepi64_epi128(a,b,0),_mm256_clmulepi64_epi128(a,b,0x11)); }
          { __m256i a=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+32)),ka), b=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+96)),kb); u1=chv3_xor256(u1,_mm256_clmulepi64_epi128(a,b,0),_mm256_clmulepi64_epi128(a,b,0x11)); }
        }
        { const __m256i ka=chv3_key256(k->ph+4), kb=chv3_key256(k->ph+6);
          { __m256i a=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+128)),ka), b=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+192)),kb); u0=chv3_xor256(u0,_mm256_clmulepi64_epi128(a,b,0),_mm256_clmulepi64_epi128(a,b,0x11)); }
          { __m256i a=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+160)),ka), b=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+224)),kb); u1=chv3_xor256(u1,_mm256_clmulepi64_epi128(a,b,0),_mm256_clmulepi64_epi128(a,b,0x11)); }
        }
        { const __m256i ka=chv3_key256(k->ph+8), kb=chv3_key256(k->ph+10);
          { __m256i a=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+256)),ka), b=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+320)),kb); u0=chv3_xor256(u0,_mm256_clmulepi64_epi128(a,b,0),_mm256_clmulepi64_epi128(a,b,0x11)); }
          { __m256i a=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+288)),ka), b=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+352)),kb); u1=chv3_xor256(u1,_mm256_clmulepi64_epi128(a,b,0),_mm256_clmulepi64_epi128(a,b,0x11)); }
        }
        { const __m256i ka=chv3_key256(k->ph+12), kb=chv3_key256(k->ph+14);
          { __m256i a=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+384)),ka), b=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+448)),kb); u0=chv3_xor256(u0,_mm256_clmulepi64_epi128(a,b,0),_mm256_clmulepi64_epi128(a,b,0x11)); }
          { __m256i a=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+416)),ka), b=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+480)),kb); u1=chv3_xor256(u1,_mm256_clmulepi64_epi128(a,b,0),_mm256_clmulepi64_epi128(a,b,0x11)); }
        }
        { const __m256i ka=chv3_key256(k->ph+16), kb=chv3_key256(k->ph+18);
          { __m256i a=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+512)),ka), b=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+576)),kb); u0=chv3_xor256(u0,_mm256_clmulepi64_epi128(a,b,0),_mm256_clmulepi64_epi128(a,b,0x11)); }
          { __m256i a=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+544)),ka), b=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+608)),kb); u1=chv3_xor256(u1,_mm256_clmulepi64_epi128(a,b,0),_mm256_clmulepi64_epi128(a,b,0x11)); }
        }
        { const __m256i ka=chv3_key256(k->ph+20), kb=chv3_key256(k->ph+22);
          { __m256i a=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+640)),ka), b=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+704)),kb); u0=chv3_xor256(u0,_mm256_clmulepi64_epi128(a,b,0),_mm256_clmulepi64_epi128(a,b,0x11)); }
          { __m256i a=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+672)),ka), b=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+736)),kb); u1=chv3_xor256(u1,_mm256_clmulepi64_epi128(a,b,0),_mm256_clmulepi64_epi128(a,b,0x11)); }
        }
        { const __m256i ka=chv3_key256(k->ph+24), kb=chv3_key256(k->ph+26);
          { __m256i a=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+768)),ka), b=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+832)),kb); u0=chv3_xor256(u0,_mm256_clmulepi64_epi128(a,b,0),_mm256_clmulepi64_epi128(a,b,0x11)); }
          { __m256i a=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+800)),ka), b=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+864)),kb); u1=chv3_xor256(u1,_mm256_clmulepi64_epi128(a,b,0),_mm256_clmulepi64_epi128(a,b,0x11)); }
        }
        { const __m256i ka=chv3_key256(k->ph+28), kb=chv3_key256(k->ph+30);
          { __m256i a=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+896)),ka), b=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+960)),kb); u0=chv3_xor256(u0,_mm256_clmulepi64_epi128(a,b,0),_mm256_clmulepi64_epi128(a,b,0x11)); }
          { __m256i a=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+928)),ka), b=_mm256_xor_si256(_mm256_loadu_si256((const __m256i_u *)(p+992)),kb); u1=chv3_xor256(u1,_mm256_clmulepi64_epi128(a,b,0),_mm256_clmulepi64_epi128(a,b,0x11)); }
        }
        s0=chv3_xor256(u0,_mm256_clmulepi64_epi128(s0,y,0),_mm256_clmulepi64_epi128(s0,y,0x11));
        s1=chv3_xor256(u1,_mm256_clmulepi64_epi128(s1,y,0),_mm256_clmulepi64_epi128(s1,y,0x11));
        p+=1024;
    } while(--regions);
    __m256i acc=_mm256_setzero_si256(),pw;
    pw=_mm256_set_epi64x((long long)k->yh[2],(long long)k->yp[2],(long long)k->yh[3],(long long)k->yp[3]);
    acc=_mm256_xor_si256(acc,_mm256_xor_si256(_mm256_clmulepi64_epi128(s0,pw,0),_mm256_clmulepi64_epi128(s0,pw,0x11)));
    pw=_mm256_set_epi64x((long long)k->yh[0],(long long)k->yp[0],(long long)k->yh[1],(long long)k->yp[1]);
    acc=_mm256_xor_si256(acc,_mm256_xor_si256(_mm256_clmulepi64_epi128(s1,pw,0),_mm256_clmulepi64_epi128(s1,pw,0x11)));
    __m128i a=_mm_xor_si128(_mm256_castsi256_si128(acc),_mm256_extracti128_si256(acc,1));
    return (uint64_t)_mm_cvtsi128_si64(chv3_vreduce(a));
}
/* The only cross-lane fold is AFTER all complete regions. */
CHV3_T512 static inline uint64_t chv3_fold512(__m512i s,const chainhash_v3_key *k) {
    __m512i powers=_mm512_set_epi64((long long)k->yh[0],(long long)k->yp[0],(long long)k->yh[1],(long long)k->yp[1],(long long)k->yh[2],(long long)k->yp[2],(long long)k->yh[3],(long long)k->yp[3]);
    s=_mm512_xor_si512(_mm512_clmulepi64_epi128(s,powers,0),_mm512_clmulepi64_epi128(s,powers,0x11));
    __m256i h=_mm256_xor_si256(_mm512_castsi512_si256(s),_mm512_extracti64x4_epi64(s,1));
    __m128i q=_mm_xor_si128(_mm256_castsi256_si128(h),_mm256_extracti128_si256(h,1));
    chv3_raw r; _mm_storeu_si128((__m128i_u *)&r,q); return chv3_reduce(r);
}
/* Tail loads never cross the input object. A padded 128-byte chunk handles
 * the last partial word; both keyed multiplicands are masked by first-word
 * presence. Horner weights act on all four lanes in two vector products. */
CHV3_T512 static uint64_t chv3_tail512(const chainhash_v3_key *k,const uint8_t *p,size_t n,uint64_t leading) {
    __m512i acc=_mm512_setzero_si512(); unsigned c=0,j,lanes=chv3_lanes(n); size_t rem=n;
    uint64_t weights[8];
    while(rem) {
        __m512i a,b; size_t take=rem<128?rem:128;
        if(take==128) { a=_mm512_loadu_si512(p); b=_mm512_loadu_si512(p+64); }
        else { uint8_t tmp[128]={0}; memcpy(tmp,p,take); a=_mm512_loadu_si512(tmp); b=_mm512_loadu_si512(tmp+64); }
        a=_mm512_xor_si512(a,_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+4*c))));
        b=_mm512_xor_si512(b,_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+4*c+2))));
        if(take<64) { __mmask8 mask=(__mmask8)((1u<<((take+7)/8))-1); a=_mm512_maskz_mov_epi64(mask,a); b=_mm512_maskz_mov_epi64(mask,b); }
        acc=_mm512_ternarylogic_epi64(acc,_mm512_clmulepi64_epi128(a,b,0),_mm512_clmulepi64_epi128(a,b,0x11),0x96);
        rem-=take; p+=take; ++c;
    }
    for(j=0;j<4;j++) { unsigned e=j<lanes?lanes-1-j:0; weights[2*j]=k->yp[e]; weights[2*j+1]=k->yh[e]; }
    __m512i pw=_mm512_loadu_si512(weights);
    acc=_mm512_xor_si512(_mm512_clmulepi64_epi128(acc,pw,0),_mm512_clmulepi64_epi128(acc,pw,0x11));
    __m256i h=_mm256_xor_si256(_mm512_castsi512_si256(acc),_mm512_extracti64x4_epi64(acc,1));
    __m128i v=_mm_xor_si128(_mm256_castsi256_si128(h),_mm256_extracti128_si256(h,1));
    v=_mm_xor_si128(v,_mm_clmulepi64_si128(_mm_set_epi64x(0,(long long)leading),_mm_set_epi64x(0,(long long)k->yp[lanes]),0));
    return (uint64_t)_mm_cvtsi128_si64(chv3_vreduce(v));
}
CHV3_T512 static uint64_t chv3_bulk512(const chainhash_v3_key *k,const uint8_t *p,size_t regions,size_t len) {
    __m512i s=_mm512_set_epi64(0,(long long)len,0,0,0,0,0,0);
    const __m512i y=_mm512_broadcast_i32x4(_mm_set_epi64x((long long)k->yh[4],(long long)k->yp[4]));
    const __m512i a0=_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+0))), b0=_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+2)));
    const __m512i a1=_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+4))), b1=_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+6)));
    const __m512i a2=_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+8))), b2=_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+10)));
    const __m512i a3=_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+12))), b3=_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+14)));
    const __m512i a4=_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+16))), b4=_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+18)));
    const __m512i a5=_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+20))), b5=_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+22)));
    const __m512i a6=_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+24))), b6=_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+26)));
    const __m512i a7=_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+28))), b7=_mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)(k->ph+30)));
    do {
        __m512i u0,u1,u2,u3;
        { __m512i a=_mm512_xor_si512(_mm512_loadu_si512(p+0),a0), b=_mm512_xor_si512(_mm512_loadu_si512(p+64),b0);
          u0=_mm512_xor_si512(_mm512_clmulepi64_epi128(a,b,0),_mm512_clmulepi64_epi128(a,b,0x11)); }
        { __m512i a=_mm512_xor_si512(_mm512_loadu_si512(p+128),a1), b=_mm512_xor_si512(_mm512_loadu_si512(p+192),b1);
          u1=_mm512_xor_si512(_mm512_clmulepi64_epi128(a,b,0),_mm512_clmulepi64_epi128(a,b,0x11)); }
        { __m512i a=_mm512_xor_si512(_mm512_loadu_si512(p+256),a2), b=_mm512_xor_si512(_mm512_loadu_si512(p+320),b2);
          u2=_mm512_xor_si512(_mm512_clmulepi64_epi128(a,b,0),_mm512_clmulepi64_epi128(a,b,0x11)); }
        { __m512i a=_mm512_xor_si512(_mm512_loadu_si512(p+384),a3), b=_mm512_xor_si512(_mm512_loadu_si512(p+448),b3);
          u3=_mm512_xor_si512(_mm512_clmulepi64_epi128(a,b,0),_mm512_clmulepi64_epi128(a,b,0x11)); }
        { __m512i a=_mm512_xor_si512(_mm512_loadu_si512(p+512),a4), b=_mm512_xor_si512(_mm512_loadu_si512(p+576),b4);
          u0=_mm512_ternarylogic_epi64(u0,_mm512_clmulepi64_epi128(a,b,0),_mm512_clmulepi64_epi128(a,b,0x11),0x96); }
        { __m512i a=_mm512_xor_si512(_mm512_loadu_si512(p+640),a5), b=_mm512_xor_si512(_mm512_loadu_si512(p+704),b5);
          u1=_mm512_ternarylogic_epi64(u1,_mm512_clmulepi64_epi128(a,b,0),_mm512_clmulepi64_epi128(a,b,0x11),0x96); }
        { __m512i a=_mm512_xor_si512(_mm512_loadu_si512(p+768),a6), b=_mm512_xor_si512(_mm512_loadu_si512(p+832),b6);
          u2=_mm512_ternarylogic_epi64(u2,_mm512_clmulepi64_epi128(a,b,0),_mm512_clmulepi64_epi128(a,b,0x11),0x96); }
        { __m512i a=_mm512_xor_si512(_mm512_loadu_si512(p+896),a7), b=_mm512_xor_si512(_mm512_loadu_si512(p+960),b7);
          u3=_mm512_ternarylogic_epi64(u3,_mm512_clmulepi64_epi128(a,b,0),_mm512_clmulepi64_epi128(a,b,0x11),0x96); }
        s=_mm512_ternarylogic_epi64(_mm512_clmulepi64_epi128(s,y,0),_mm512_clmulepi64_epi128(s,y,0x11),_mm512_xor_si512(_mm512_ternarylogic_epi64(u0,u1,u2,0x96),u3),0x96);
        p+=1024;
    } while(--regions);
    return chv3_fold512(s,k);
}
#endif

#ifdef CHV3_ARM
static inline void chv3_region_neon(const chainhash_v3_key *k,const uint8_t *p,chv3_raw out[4]) {
    unsigned j; for(j=0;j<4;j++) { uint64x2_t s=vdupq_n_u64(0);
    { uint64x2_t a=veorq_u64(chv3_ld(p+0+16*j),vld1q_u64(k->ph+0)), b=veorq_u64(chv3_ld(p+64+16*j),vld1q_u64(k->ph+2)); s=chv3_xor3(s,chv3_ll(a,b),chv3_hh(a,b)); }
    { uint64x2_t a=veorq_u64(chv3_ld(p+128+16*j),vld1q_u64(k->ph+4)), b=veorq_u64(chv3_ld(p+192+16*j),vld1q_u64(k->ph+6)); s=chv3_xor3(s,chv3_ll(a,b),chv3_hh(a,b)); }
    { uint64x2_t a=veorq_u64(chv3_ld(p+256+16*j),vld1q_u64(k->ph+8)), b=veorq_u64(chv3_ld(p+320+16*j),vld1q_u64(k->ph+10)); s=chv3_xor3(s,chv3_ll(a,b),chv3_hh(a,b)); }
    { uint64x2_t a=veorq_u64(chv3_ld(p+384+16*j),vld1q_u64(k->ph+12)), b=veorq_u64(chv3_ld(p+448+16*j),vld1q_u64(k->ph+14)); s=chv3_xor3(s,chv3_ll(a,b),chv3_hh(a,b)); }
    { uint64x2_t a=veorq_u64(chv3_ld(p+512+16*j),vld1q_u64(k->ph+16)), b=veorq_u64(chv3_ld(p+576+16*j),vld1q_u64(k->ph+18)); s=chv3_xor3(s,chv3_ll(a,b),chv3_hh(a,b)); }
    { uint64x2_t a=veorq_u64(chv3_ld(p+640+16*j),vld1q_u64(k->ph+20)), b=veorq_u64(chv3_ld(p+704+16*j),vld1q_u64(k->ph+22)); s=chv3_xor3(s,chv3_ll(a,b),chv3_hh(a,b)); }
    { uint64x2_t a=veorq_u64(chv3_ld(p+768+16*j),vld1q_u64(k->ph+24)), b=veorq_u64(chv3_ld(p+832+16*j),vld1q_u64(k->ph+26)); s=chv3_xor3(s,chv3_ll(a,b),chv3_hh(a,b)); }
    { uint64x2_t a=veorq_u64(chv3_ld(p+896+16*j),vld1q_u64(k->ph+28)), b=veorq_u64(chv3_ld(p+960+16*j),vld1q_u64(k->ph+30)); s=chv3_xor3(s,chv3_ll(a,b),chv3_hh(a,b)); }
    vst1q_u64(&out[j].lo,s); }
}
static uint64_t chv3_bulk_neon(const chainhash_v3_key *k,const uint8_t *p,size_t regions,size_t len) {
    uint64x2_t s0=vdupq_n_u64(0),s1=s0,s2=s0,s3=vcombine_u64(vcreate_u64(len),vcreate_u64(0));
    const uint64x2_t y=vcombine_u64(vcreate_u64(k->yp[4]),vcreate_u64(k->yh[4]));
    const uint64x2_t a0=vld1q_u64(k->ph+0),b0=vld1q_u64(k->ph+2);
    const uint64x2_t a1=vld1q_u64(k->ph+4),b1=vld1q_u64(k->ph+6);
    const uint64x2_t a2=vld1q_u64(k->ph+8),b2=vld1q_u64(k->ph+10);
    const uint64x2_t a3=vld1q_u64(k->ph+12),b3=vld1q_u64(k->ph+14);
    const uint64x2_t a4=vld1q_u64(k->ph+16),b4=vld1q_u64(k->ph+18);
    const uint64x2_t a5=vld1q_u64(k->ph+20),b5=vld1q_u64(k->ph+22);
    const uint64x2_t a6=vld1q_u64(k->ph+24),b6=vld1q_u64(k->ph+26);
    const uint64x2_t a7=vld1q_u64(k->ph+28),b7=vld1q_u64(k->ph+30);
    do {
        uint64x2_t u0=vdupq_n_u64(0),u1=u0,u2=u0,u3=u0;
        { uint64x2_t a=veorq_u64(chv3_ld(p+0),a0), b=veorq_u64(chv3_ld(p+64),b0); u0=chv3_xor3(u0,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+16),a0), b=veorq_u64(chv3_ld(p+80),b0); u1=chv3_xor3(u1,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+32),a0), b=veorq_u64(chv3_ld(p+96),b0); u2=chv3_xor3(u2,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+48),a0), b=veorq_u64(chv3_ld(p+112),b0); u3=chv3_xor3(u3,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+128),a1), b=veorq_u64(chv3_ld(p+192),b1); u0=chv3_xor3(u0,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+144),a1), b=veorq_u64(chv3_ld(p+208),b1); u1=chv3_xor3(u1,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+160),a1), b=veorq_u64(chv3_ld(p+224),b1); u2=chv3_xor3(u2,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+176),a1), b=veorq_u64(chv3_ld(p+240),b1); u3=chv3_xor3(u3,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+256),a2), b=veorq_u64(chv3_ld(p+320),b2); u0=chv3_xor3(u0,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+272),a2), b=veorq_u64(chv3_ld(p+336),b2); u1=chv3_xor3(u1,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+288),a2), b=veorq_u64(chv3_ld(p+352),b2); u2=chv3_xor3(u2,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+304),a2), b=veorq_u64(chv3_ld(p+368),b2); u3=chv3_xor3(u3,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+384),a3), b=veorq_u64(chv3_ld(p+448),b3); u0=chv3_xor3(u0,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+400),a3), b=veorq_u64(chv3_ld(p+464),b3); u1=chv3_xor3(u1,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+416),a3), b=veorq_u64(chv3_ld(p+480),b3); u2=chv3_xor3(u2,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+432),a3), b=veorq_u64(chv3_ld(p+496),b3); u3=chv3_xor3(u3,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+512),a4), b=veorq_u64(chv3_ld(p+576),b4); u0=chv3_xor3(u0,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+528),a4), b=veorq_u64(chv3_ld(p+592),b4); u1=chv3_xor3(u1,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+544),a4), b=veorq_u64(chv3_ld(p+608),b4); u2=chv3_xor3(u2,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+560),a4), b=veorq_u64(chv3_ld(p+624),b4); u3=chv3_xor3(u3,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+640),a5), b=veorq_u64(chv3_ld(p+704),b5); u0=chv3_xor3(u0,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+656),a5), b=veorq_u64(chv3_ld(p+720),b5); u1=chv3_xor3(u1,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+672),a5), b=veorq_u64(chv3_ld(p+736),b5); u2=chv3_xor3(u2,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+688),a5), b=veorq_u64(chv3_ld(p+752),b5); u3=chv3_xor3(u3,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+768),a6), b=veorq_u64(chv3_ld(p+832),b6); u0=chv3_xor3(u0,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+784),a6), b=veorq_u64(chv3_ld(p+848),b6); u1=chv3_xor3(u1,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+800),a6), b=veorq_u64(chv3_ld(p+864),b6); u2=chv3_xor3(u2,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+816),a6), b=veorq_u64(chv3_ld(p+880),b6); u3=chv3_xor3(u3,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+896),a7), b=veorq_u64(chv3_ld(p+960),b7); u0=chv3_xor3(u0,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+912),a7), b=veorq_u64(chv3_ld(p+976),b7); u1=chv3_xor3(u1,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+928),a7), b=veorq_u64(chv3_ld(p+992),b7); u2=chv3_xor3(u2,chv3_ll(a,b),chv3_hh(a,b)); }
        { uint64x2_t a=veorq_u64(chv3_ld(p+944),a7), b=veorq_u64(chv3_ld(p+1008),b7); u3=chv3_xor3(u3,chv3_ll(a,b),chv3_hh(a,b)); }
        s0=chv3_xor3(u0,chv3_ll(s0,y),chv3_hh(s0,y));
        s1=chv3_xor3(u1,chv3_ll(s1,y),chv3_hh(s1,y));
        s2=chv3_xor3(u2,chv3_ll(s2,y),chv3_hh(s2,y));
        s3=chv3_xor3(u3,chv3_ll(s3,y),chv3_hh(s3,y));
        p+=1024;
    } while(--regions);
    uint64x2_t acc=vdupq_n_u64(0),pw;
    pw=vcombine_u64(vcreate_u64(k->yp[3]),vcreate_u64(k->yh[3])); acc=chv3_xor3(acc,chv3_ll(s0,pw),chv3_hh(s0,pw));
    pw=vcombine_u64(vcreate_u64(k->yp[2]),vcreate_u64(k->yh[2])); acc=chv3_xor3(acc,chv3_ll(s1,pw),chv3_hh(s1,pw));
    pw=vcombine_u64(vcreate_u64(k->yp[1]),vcreate_u64(k->yh[1])); acc=chv3_xor3(acc,chv3_ll(s2,pw),chv3_hh(s2,pw));
    pw=vcombine_u64(vcreate_u64(k->yp[0]),vcreate_u64(k->yh[0])); acc=chv3_xor3(acc,chv3_ll(s3,pw),chv3_hh(s3,pw));
    chv3_raw r; vst1q_u64(&r.lo,acc); return chv3_reduce(r);
}
#endif
static inline void chv3_region(const chainhash_v3_key *k,const uint8_t *p,size_t n,chv3_raw out[4],int b) {
    if(n==1024) {
#ifdef CHV3_X86
        if(b==3) { chv3_region512(k,p,out); return; }
        if(b==2) { chv3_region256(k,p,out); return; }
        if(b==1) { chv3_region128(k,p,out); return; }
#elif defined(CHV3_ARM)
        if(b==4) { chv3_region_neon(k,p,out); return; }
#endif
    }
    chv3_region_scalar(k,p,n,out,b);
}
/* Streaming keeps at most one incomplete region. len is supplied at final,
 * so any chunking (including empty updates) has identical semantics.
 * Backend is explicit for testing; use chainhash_v3_backend() in applications.
 * stride must be 1..8; lazy must be 0 or 1. key must outlive the stream.
 */
typedef struct {
    const chainhash_v3_key *key; chv3_raw state[8];
    uint64_t len, blocks; unsigned stride; int lazy, backend;
    size_t used; uint8_t buffer[1024];
} chainhash_v3_stream;
static inline void chainhash_v3_init(chainhash_v3_stream *s,const chainhash_v3_key *k,unsigned stride,int lazy,int backend) {
    assert(stride>=1 && stride<=8 && chainhash_v3_has_backend(backend));
    memset(s,0,sizeof(*s)); s->key=k; s->stride=stride; s->lazy=lazy; s->backend=backend;
}
static inline void chv3_absorb(chainhash_v3_stream *s,const uint8_t *p,size_t n) {
    chv3_raw c[4]; unsigned j,count=chv3_lanes(n); const chainhash_v3_key *k=s->key;
    chv3_region(k,p,n,c,s->backend);
    for(j=0;j<count;j++) {
        chv3_raw *r=&s->state[s->blocks%s->stride];
        if(s->lazy) { chv3_raw a=chv3_prod(r->lo,k->yp[s->stride],s->backend), b=chv3_prod(r->hi,k->yh[s->stride],s->backend); r->lo=a.lo^b.lo^c[j].lo; r->hi=a.hi^b.hi^c[j].hi; }
        else { r->lo=chv3_fmul(r->lo,k->yp[s->stride],s->backend)^chv3_reduce(c[j]); r->hi=0; }
        ++s->blocks;
    }
}
static inline void chainhash_v3_update(chainhash_v3_stream *s,const void *data,size_t n) {
    const uint8_t *p=(const uint8_t *)data; assert(n<=UINT64_MAX-s->len); s->len+=n;
    if(s->used) { size_t take=1024-s->used; if(take>n) take=n; if(take) { memcpy(s->buffer+s->used,p,take); p+=take; } s->used+=take; n-=take; if(s->used==1024) { chv3_absorb(s,s->buffer,1024); s->used=0; } }
    while(n>=1024) { chv3_absorb(s,p,1024); p+=1024; n-=1024; }
    if(n) { memcpy(s->buffer,p,n); s->used=n; }
}
/* Return the message polynomial without its leading length coefficient.
 * This is useful for region-aligned independent thread partitions. */
static inline uint64_t chainhash_v3_partial(chainhash_v3_stream *s) {
    uint64_t v=0; unsigned j;
    if(s->used || !s->blocks) { chv3_absorb(s,s->buffer,s->used); s->used=0; }
    for(j=0;j<s->stride && j<s->blocks;j++) { unsigned e=(unsigned)((s->blocks-1-j)%s->stride); v^=chv3_fmul(chv3_reduce(s->state[j]),s->key->yp[e],s->backend); }
    return v;
}
static inline uint64_t chainhash_v3_final(chainhash_v3_stream *s) {
    uint64_t v=chainhash_v3_partial(s);
    v^=chv3_fmul(s->len,chv3_pow(s->key->yp[1],s->blocks,s->backend),s->backend);
    return chv3_finish(s->key,v,s->backend);
}
/* Concatenate region-aligned chunks. right_blocks counts only actual right
 * blocks; an empty right chunk has zero blocks (not the empty-hash sentinel).
 * Inputs exclude length and finalizer. No inversion: y=0 works as well. */
static inline uint64_t chainhash_v3_join(const chainhash_v3_key *k,uint64_t left,uint64_t right,uint64_t right_blocks,int backend) {
    return chv3_fmul(left,chv3_pow(k->yp[1],right_blocks,backend),backend)^right;
}
static inline uint64_t chainhash_v3_evaluate(const chainhash_v3_key *k,const void *data,size_t len,unsigned stride,int lazy,int backend) {
    chainhash_v3_stream s; chainhash_v3_init(&s,k,stride,lazy,backend); chainhash_v3_update(&s,data,len); return chainhash_v3_final(&s);
}
/* Portable reference: serial eager Horner, length leading, no round robin. */
static inline uint64_t chainhash_v3_portable(const chainhash_v3_key *k,const void *data,size_t len) {
    const uint8_t *p=(const uint8_t *)data; size_t n=len; uint64_t v=len;
    do { chv3_raw c[4]; size_t take=n<1024?n:1024; unsigned j;
        chv3_region_scalar(k,p,take,c,0);
        for(j=0;j<chv3_lanes(take);j++) v=chv3_mul(v,k->yp[1])^chv3_reduce(c[j]);
        n-=take; if(!n) break; p+=take;
    } while(1);
    return chv3_finish(k,v,0);
}
static inline uint64_t chainhash_v3_with_backend(const chainhash_v3_key *k,const void *data,size_t len,int backend) {
    const uint8_t *p=(const uint8_t *)data; size_t full=len/1024,n=len%1024; uint64_t v=len;
    assert(chainhash_v3_has_backend(backend));
    if(full) {
#ifdef CHV3_X86
        if(backend==3) v=chv3_bulk512(k,p,full,len);
        else if(backend==2) v=chv3_bulk256(k,p,full,len);
        else if(backend==1) v=chv3_bulk128(k,p,full,len);
        else return chainhash_v3_evaluate(k,data,len,4,1,backend);
#elif defined(CHV3_ARM)
        if(backend==4) v=chv3_bulk_neon(k,p,full,len);
        else return chainhash_v3_evaluate(k,data,len,4,1,backend);
#else
        return chainhash_v3_evaluate(k,data,len,4,1,backend);
#endif
        p+=full*1024;
    }
    #ifdef CHV3_X86
    if(backend==3 && (n || !full)) return chv3_finish(k,chv3_tail512(k,p,n,v),backend);
#elif defined(CHV3_ARM)
    if(backend==4 && (n || !full)) return chv3_tail_neon(k,p,n,v);
#endif
    if(n || !full) { chv3_raw c[4]; unsigned j; chv3_region_scalar(k,p,n,c,backend); for(j=0;j<chv3_lanes(n);j++) v=chv3_fmul(v,k->yp[1],backend)^chv3_reduce(c[j]); }
    return chv3_finish(k,v,backend);
}
static inline uint64_t chainhash_v3(const chainhash_v3_key *k,const void *data,size_t len) { return chainhash_v3_with_backend(k,data,len,chainhash_v3_backend()); }
#ifdef CHV3_X86
static inline uint64_t chainhash_v3_xmm(const chainhash_v3_key *k,const void *p,size_t n) { return chainhash_v3_with_backend(k,p,n,CHV3_XMM); }
static inline uint64_t chainhash_v3_ymm(const chainhash_v3_key *k,const void *p,size_t n) { return chainhash_v3_with_backend(k,p,n,CHV3_YMM); }
static inline uint64_t chainhash_v3_zmm(const chainhash_v3_key *k,const void *p,size_t n) { return chainhash_v3_with_backend(k,p,n,CHV3_ZMM); }
#endif
#ifdef CHV3_ARM
static inline uint64_t chainhash_v3_neon(const chainhash_v3_key *k,const void *p,size_t n) { return chainhash_v3_with_backend(k,p,n,CHV3_NEON); }
#endif
static inline int chainhash_v3_selftest(void) {
    uint8_t m[2049]; chainhash_v3_key k=chainhash_v3_key_from_seed(123); size_t n; unsigned j;
    for(j=0;j<sizeof(m);j++) m[j]=(uint8_t)j;
    /* Constants generated by test/v3/vectors.c's independent memo evaluator. */
    if(chainhash_v3(&k,m,0)!=UINT64_C(0xede120e3ad6ec193) ||
       chainhash_v3(&k,m,17)!=UINT64_C(0x97c346f5999acee9) ||
       chainhash_v3(&k,m,1024)!=UINT64_C(0xf3897c02083c9f82)) return 0;
    for(n=0;n<sizeof(m);n=n<65?n+1:n+127) if(chainhash_v3(&k,m,n)!=chainhash_v3_portable(&k,m,n)) return 0;
    return 1;
}
#endif
