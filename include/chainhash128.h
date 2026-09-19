/* ChainHash-128: a keyed 128-bit hash for long inputs with a proven collision bound.
 * Copyright 2026 Thomas Dybdahl Ahle. MIT license. C99/C++11, one header, no allocation.
 *
 * Key: 128 uniformly random bytes (CHAINHASH128_KEY_BYTES), chainhash128_key_from_bytes.
 * chainhash128_key_from_seed expands a 64-bit seed; it is for benchmarks and tests.
 * Hash: chainhash128(&key, data, len) returns a ch128_word (two uint64_t limbs);
 * chainhash128_store writes its 16 canonical little-endian bytes. Streaming:
 * chainhash128_init, chainhash128_update, chainhash128_final. Region-aligned parallel
 * evaluation: chainhash128_partial and chainhash128_join. Portable C, x86 XMM/YMM/ZMM
 * and ARM NEON backends, every stride, reduction schedule, product method and
 * chunking compute the same digest.
 * Bound: for two distinct messages fixed independently of the key, each of at most
 * 8L bytes, Pr[collision] <= (p(L)+d(L))/2^128, where p is the block count and
 * d <= 32; see docs/THEOREM-128.md. The definition and index map: docs/SPEC-128.md.
 * Little-endian bytes; no alignment or padding required. Explicit backend calls
 * require chainhash128_has_backend(). AArch64: -march=armv8-a+crypto
 * (Apple: -march=native+crypto). Define CHAINHASH128_PORTABLE to omit all hardware code.
 */
#ifndef CHAINHASH128_H
#define CHAINHASH128_H
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <assert.h>
#define CHAINHASH128_BLOCK_BYTES 512
#define CH128_W (CHAINHASH128_BLOCK_BYTES/16)
#define CH128_CHUNKS (CH128_W/2)
#define CH128_REGION (8*CHAINHASH128_BLOCK_BYTES)
#define CHAINHASH128_KEY_BYTES 128
typedef struct { uint64_t lo,hi; } ch128_word;
typedef struct { ch128_word lo,hi; } ch128_raw;
typedef struct { ch128_word ph[CH128_W],yp[9],yh[9],c[5],tau; } chainhash128_key;
enum { CH128_PORTABLE=0,CH128_XMM=1,CH128_YMM=2,CH128_ZMM=3,CH128_NEON=4 };
static inline ch128_word ch128_make(uint64_t lo, uint64_t hi) { ch128_word r; r.lo=lo; r.hi=hi; return r; }
static inline ch128_word ch128_xor(ch128_word a, ch128_word b) { return ch128_make(a.lo^b.lo,a.hi^b.hi); }
static inline int ch128_equal(ch128_word a, ch128_word b) { return a.lo==b.lo && a.hi==b.hi; }
static inline ch128_word ch128_addint(ch128_word a, ch128_word b) {
    uint64_t lo=a.lo+b.lo; return ch128_make(lo,a.hi+b.hi+(lo<a.lo));
}
static inline uint64_t ch128_load64(const uint8_t *p) {
    uint64_t r=0; unsigned i; for(i=0;i<8;i++) r|=(uint64_t)p[i]<<(8*i); return r;
}
static inline ch128_word ch128_load(const uint8_t *p) { return ch128_make(ch128_load64(p),ch128_load64(p+8)); }
static inline void chainhash128_store(void *out, ch128_word v) {
    uint8_t *p=(uint8_t *)out; unsigned i;
    for(i=0;i<8;i++) { p[i]=(uint8_t)(v.lo>>(8*i)); p[i+8]=(uint8_t)(v.hi>>(8*i)); }
}
/* Independent bit-serial oracle, including the UNREDUCED 256-bit product. */
static inline ch128_raw ch128_clmul_ref(ch128_word a, ch128_word b) {
    uint64_t x0=a.lo,x1=a.hi,x2=0,x3=0,r0=0,r1=0,r2=0,r3=0; unsigned i;
    ch128_raw r;
    for(i=0;i<128;i++) {
        uint64_t mask=UINT64_C(0)-(b.lo&1);
        r0^=x0&mask; r1^=x1&mask; r2^=x2&mask; r3^=x3&mask;
        x3=(x3<<1)|(x2>>63); x2=(x2<<1)|(x1>>63);
        x1=(x1<<1)|(x0>>63); x0<<=1;
        b.lo=(b.lo>>1)|(b.hi<<63); b.hi>>=1;
    }
    r.lo=ch128_make(r0,r1); r.hi=ch128_make(r2,r3); return r;
}
/* Bit-serial field multiplication, X^128 = 0x87. */
static inline ch128_word ch128_mul_ref(ch128_word a, ch128_word b) {
    ch128_word r=ch128_make(0,0); unsigned i;
    for(i=0;i<128;i++) {
        uint64_t mask=UINT64_C(0)-(b.lo&1), top=a.hi>>63;
        r.lo^=a.lo&mask; r.hi^=a.hi&mask;
        a.hi=(a.hi<<1)|(a.lo>>63); a.lo=(a.lo<<1)^(UINT64_C(0x87)&(UINT64_C(0)-top));
        b.lo=(b.lo>>1)|(b.hi<<63); b.hi>>=1;
    }
    return r;
}
static inline ch128_word ch128_partial(const uint8_t *p, size_t n, size_t off) {
    uint8_t buf[16]={0};
    if(off<n && n-off>=16) return ch128_load(p+off);
    if(off<n) { size_t count=n-off; if(count>16) count=16; memcpy(buf,p+off,count); }
    return ch128_load(buf);
}

static inline ch128_raw ch128_rxor(ch128_raw a,ch128_raw b) { a.lo=ch128_xor(a.lo,b.lo); a.hi=ch128_xor(a.hi,b.hi); return a; }
/* Fold X^128=0x87 twice, including all 256-bit representatives. */
static inline ch128_word ch128_reduce(ch128_raw a) {
    uint64_t l=a.hi.lo,h=a.hi.hi,t=(h>>63)^(h>>62)^(h>>57);
    return ch128_make(a.lo.lo^l^(l<<1)^(l<<2)^(l<<7)^t^(t<<1)^(t<<2)^(t<<7),
                       a.lo.hi^h^(h<<1)^(h<<2)^(h<<7)^(l>>63)^(l>>62)^(l>>57));
}
#if !defined(CHAINHASH128_PORTABLE) && (defined(__x86_64__) || defined(__i386__)) && (defined(__GNUC__) || defined(__clang__))
#define CH128_X86 1
#include <immintrin.h>
#include <cpuid.h>
#define CH128_T128 __attribute__((target("avx,pclmul")))
#define CH128_T256 __attribute__((target("avx2,pclmul,vpclmulqdq")))
#define CH128_T512 __attribute__((target("avx2,pclmul,avx512f,vpclmulqdq")))
static inline int ch128_detect(void) {
    unsigned a,b,c,d,l,h;
    if(!__get_cpuid(1,&a,&b,&c,&d) || (c&((1u<<1)|(1u<<27)|(1u<<28)))!=((1u<<1)|(1u<<27)|(1u<<28))) return 0;
    __asm__("xgetbv":"=a"(l),"=d"(h):"c"(0)); if((l&6)!=6) return 0;
    if(!__get_cpuid_count(7,0,&a,&b,&c,&d) || !(b&(1u<<5)) || !(c&(1u<<10))) return 1;
    return (l&0xe6)==0xe6 && (b&(1u<<16)) ? 3:2;
}
#elif !defined(CHAINHASH128_PORTABLE) && defined(__aarch64__) && !defined(__AARCH64EB__) && (defined(__ARM_FEATURE_AES) || defined(__ARM_FEATURE_CRYPTO))
#define CH128_ARM 1
#include <arm_neon.h>
#endif
static inline int chainhash128_backend(void) {
#ifdef CH128_X86
    static int cache=-1; int v=__atomic_load_n(&cache,__ATOMIC_RELAXED); if(v<0) { v=ch128_detect(); __atomic_store_n(&cache,v,__ATOMIC_RELAXED); } return v;
#elif defined(CH128_ARM)
    return CH128_NEON;
#else
    return 0;
#endif
}
static inline int chainhash128_has_backend(int b) { int h=chainhash128_backend(); return b==0 || (h==4 ? b==4 : b>0 && b<=h); }

#ifdef CH128_X86
CH128_T128 static inline __m128i ch128_128_ll(__m128i a,__m128i b) { return _mm_clmulepi64_si128(a,b,0); }
CH128_T128 static inline __m128i ch128_128_hh(__m128i a,__m128i b) { return _mm_clmulepi64_si128(a,b,0x11); }
CH128_T128 static inline __m128i ch128_128_lh(__m128i a,__m128i b) { return _mm_clmulepi64_si128(a,b,0x10); }
CH128_T128 static inline __m128i ch128_128_hl(__m128i a,__m128i b) { return _mm_clmulepi64_si128(a,b,0x01); }
CH128_T128 static inline __m128i ch128_128_zero(void) { return _mm_setzero_si128(); }
CH128_T128 static inline __m128i ch128_128_load(const void *p) { return _mm_loadu_si128((const __m128i_u *)p); }
CH128_T128 static inline __m128i ch128_128_xor(__m128i a,__m128i b) { return _mm_xor_si128(a,b); }
CH128_T128 static inline __m128i ch128_128_swap(__m128i a) { return _mm_shuffle_epi32(a,0x4e); }
CH128_T128 static inline __m128i ch128_128_left(__m128i a) { return _mm_slli_si128(a,8); }
CH128_T128 static inline __m128i ch128_128_right(__m128i a) { return _mm_srli_si128(a,8); }
CH128_T128 static inline void ch128_128_store(void *p,__m128i a) { _mm_storeu_si128((__m128i_u *)p,a); }
CH128_T128 static inline __m128i ch128_128_bc(const void *p) { return _mm_loadu_si128((const __m128i_u *)p); }
typedef struct { __m128i l,h,m; } ch128_128_acc;
typedef struct { __m128i lo,hi; } ch128_128_raw;
CH128_T128 static inline ch128_128_acc ch128_128_azero(void) { ch128_128_acc r; r.l=r.h=r.m=ch128_128_zero(); return r; }
CH128_T128 static inline ch128_128_acc ch128_128_accum(ch128_128_acc r,__m128i a,__m128i b,int school) {
    __m128i l=ch128_128_ll(a,b),h=ch128_128_hh(a,b),m;
    if(school) m=ch128_128_xor(ch128_128_lh(a,b),ch128_128_hl(a,b));
    else m=ch128_128_ll(ch128_128_xor(a,ch128_128_swap(a)),ch128_128_xor(b,ch128_128_swap(b)));
    r.l=ch128_128_xor(r.l,l); r.h=ch128_128_xor(r.h,h); r.m=ch128_128_xor(r.m,m); __asm__("" : "+x"(r.l), "+x"(r.h), "+x"(r.m)); return r;
}
CH128_T128 static inline ch128_128_raw ch128_128_pack(ch128_128_acc a,int school) {
    ch128_128_raw r; if(!school) a.m=ch128_128_xor(a.m,ch128_128_xor(a.l,a.h));
    r.lo=ch128_128_xor(a.l,ch128_128_left(a.m)); r.hi=ch128_128_xor(a.h,ch128_128_right(a.m)); return r;
}
CH128_T128 static inline ch128_128_raw ch128_128_prod(__m128i a,__m128i b,int school) { return ch128_128_pack(ch128_128_accum(ch128_128_azero(),a,b,school),school); }
CH128_T128 static inline ch128_raw ch128_128_wordprod(ch128_word a,ch128_word b,int school) {
    ch128_raw r; ch128_128_raw v=ch128_128_prod(ch128_128_load(&a),ch128_128_load(&b),school); ch128_128_store(&r.lo,v.lo); ch128_128_store(&r.hi,v.hi); return r;
}
#endif

#ifdef CH128_X86
CH128_T256 static inline __m256i ch128_256_ll(__m256i a,__m256i b) { return _mm256_clmulepi64_epi128(a,b,0); }
CH128_T256 static inline __m256i ch128_256_hh(__m256i a,__m256i b) { return _mm256_clmulepi64_epi128(a,b,0x11); }
CH128_T256 static inline __m256i ch128_256_lh(__m256i a,__m256i b) { return _mm256_clmulepi64_epi128(a,b,0x10); }
CH128_T256 static inline __m256i ch128_256_hl(__m256i a,__m256i b) { return _mm256_clmulepi64_epi128(a,b,0x01); }
CH128_T256 static inline __m256i ch128_256_zero(void) { return _mm256_setzero_si256(); }
CH128_T256 static inline __m256i ch128_256_load(const void *p) { return _mm256_loadu_si256((const __m256i_u *)p); }
CH128_T256 static inline __m256i ch128_256_xor(__m256i a,__m256i b) { return _mm256_xor_si256(a,b); }
CH128_T256 static inline __m256i ch128_256_swap(__m256i a) { return _mm256_shuffle_epi32(a,0x4e); }
CH128_T256 static inline __m256i ch128_256_left(__m256i a) { return _mm256_bslli_epi128(a,8); }
CH128_T256 static inline __m256i ch128_256_right(__m256i a) { return _mm256_bsrli_epi128(a,8); }
CH128_T256 static inline void ch128_256_store(void *p,__m256i a) { _mm256_storeu_si256((__m256i_u *)p,a); }
CH128_T256 static inline __m256i ch128_256_bc(const void *p) { return _mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i_u *)p)); }
typedef struct { __m256i l,h,m; } ch128_256_acc;
typedef struct { __m256i lo,hi; } ch128_256_raw;
CH128_T256 static inline ch128_256_acc ch128_256_azero(void) { ch128_256_acc r; r.l=r.h=r.m=ch128_256_zero(); return r; }
CH128_T256 static inline ch128_256_acc ch128_256_accum(ch128_256_acc r,__m256i a,__m256i b,int school) {
    __m256i l=ch128_256_ll(a,b),h=ch128_256_hh(a,b),m;
    if(school) m=ch128_256_xor(ch128_256_lh(a,b),ch128_256_hl(a,b));
    else m=ch128_256_ll(ch128_256_xor(a,ch128_256_swap(a)),ch128_256_xor(b,ch128_256_swap(b)));
    r.l=ch128_256_xor(r.l,l); r.h=ch128_256_xor(r.h,h); r.m=ch128_256_xor(r.m,m); __asm__("" : "+x"(r.l), "+x"(r.h), "+x"(r.m)); return r;
}
CH128_T256 static inline ch128_256_raw ch128_256_pack(ch128_256_acc a,int school) {
    ch128_256_raw r; if(!school) a.m=ch128_256_xor(a.m,ch128_256_xor(a.l,a.h));
    r.lo=ch128_256_xor(a.l,ch128_256_left(a.m)); r.hi=ch128_256_xor(a.h,ch128_256_right(a.m)); return r;
}
CH128_T256 static inline ch128_256_raw ch128_256_prod(__m256i a,__m256i b,int school) { return ch128_256_pack(ch128_256_accum(ch128_256_azero(),a,b,school),school); }
#endif

#ifdef CH128_X86
CH128_T512 static inline __m512i ch128_512_ll(__m512i a,__m512i b) { return _mm512_clmulepi64_epi128(a,b,0); }
CH128_T512 static inline __m512i ch128_512_hh(__m512i a,__m512i b) { return _mm512_clmulepi64_epi128(a,b,0x11); }
CH128_T512 static inline __m512i ch128_512_lh(__m512i a,__m512i b) { return _mm512_clmulepi64_epi128(a,b,0x10); }
CH128_T512 static inline __m512i ch128_512_hl(__m512i a,__m512i b) { return _mm512_clmulepi64_epi128(a,b,0x01); }
CH128_T512 static inline __m512i ch128_512_zero(void) { return _mm512_setzero_si512(); }
CH128_T512 static inline __m512i ch128_512_load(const void *p) { return _mm512_loadu_si512(p); }
CH128_T512 static inline __m512i ch128_512_xor(__m512i a,__m512i b) { return _mm512_xor_si512(a,b); }
CH128_T512 static inline __m512i ch128_512_swap(__m512i a) { return _mm512_shuffle_epi32(a,(_MM_PERM_ENUM)0x4e); }
CH128_T512 static inline __m512i ch128_512_left(__m512i a) { return _mm512_maskz_shuffle_epi32(0xcccc, a, (_MM_PERM_ENUM)0x4e); }
CH128_T512 static inline __m512i ch128_512_right(__m512i a) { return _mm512_maskz_shuffle_epi32(0x3333, a, (_MM_PERM_ENUM)0x4e); }
CH128_T512 static inline void ch128_512_store(void *p,__m512i a) { _mm512_storeu_si512(p,a); }
CH128_T512 static inline __m512i ch128_512_bc(const void *p) { return _mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i_u *)p)); }
typedef struct { __m512i l,h,m; } ch128_512_acc;
typedef struct { __m512i lo,hi; } ch128_512_raw;
CH128_T512 static inline ch128_512_acc ch128_512_azero(void) { ch128_512_acc r; r.l=r.h=r.m=ch128_512_zero(); return r; }
CH128_T512 static inline ch128_512_acc ch128_512_accum(ch128_512_acc r,__m512i a,__m512i b,int school) {
    __m512i l=ch128_512_ll(a,b),h=ch128_512_hh(a,b),m;
    if(school) m=_mm512_ternarylogic_epi64(r.m,ch128_512_lh(a,b),ch128_512_hl(a,b),0x96);
    else m=ch128_512_ll(ch128_512_xor(a,ch128_512_swap(a)),ch128_512_xor(b,ch128_512_swap(b)));
    r.l=ch128_512_xor(r.l,l); r.h=ch128_512_xor(r.h,h); r.m=school?m:ch128_512_xor(r.m,m); __asm__("" : "+v"(r.l), "+v"(r.h), "+v"(r.m)); return r;
}
CH128_T512 static inline ch128_512_raw ch128_512_pack(ch128_512_acc a,int school) {
    ch128_512_raw r; if(!school) a.m=ch128_512_xor(a.m,ch128_512_xor(a.l,a.h));
    r.lo=ch128_512_xor(a.l,ch128_512_left(a.m)); r.hi=ch128_512_xor(a.h,ch128_512_right(a.m)); return r;
}
CH128_T512 static inline ch128_512_raw ch128_512_prod(__m512i a,__m512i b,int school) { return ch128_512_pack(ch128_512_accum(ch128_512_azero(),a,b,school),school); }
#endif

#ifdef CH128_ARM
static inline uint64x2_t ch128_nld(const void *p) { uint64x2_t a; __asm__("ld1 {%0.2d}, [%1]":"=w"(a):"r"(p),"m"(*(const uint8_t (*)[16])p)); return a; }
static inline uint64x2_t ch128_n_ll(uint64x2_t a,uint64x2_t b) { uint64x2_t r; __asm__("pmull %0.1q, %1.1d, %2.1d":"=w"(r):"w"(a),"w"(b)); return r; }
static inline uint64x2_t ch128_n_hh(uint64x2_t a,uint64x2_t b) { uint64x2_t r; __asm__("pmull2 %0.1q, %1.2d, %2.2d":"=w"(r):"w"(a),"w"(b)); return r; }
static inline uint64x2_t ch128_n_lh(uint64x2_t a,uint64x2_t b) { return ch128_n_ll(a,vextq_u64(b,b,1)); }
static inline uint64x2_t ch128_n_hl(uint64x2_t a,uint64x2_t b) { return ch128_n_ll(vextq_u64(a,a,1),b); }
static inline uint64x2_t ch128_n_zero(void) { return vdupq_n_u64(0); }
static inline uint64x2_t ch128_n_load(const void *p) { return ch128_nld(p); }
static inline uint64x2_t ch128_n_xor(uint64x2_t a,uint64x2_t b) { return veorq_u64(a,b); }
static inline uint64x2_t ch128_n_swap(uint64x2_t a) { return vextq_u64(a,a,1); }
static inline uint64x2_t ch128_n_left(uint64x2_t a) { return vextq_u64(vdupq_n_u64(0),a,1); }
static inline uint64x2_t ch128_n_right(uint64x2_t a) { return vextq_u64(a,vdupq_n_u64(0),1); }
static inline void ch128_n_store(void *p,uint64x2_t a) { vst1q_u8((uint8_t *)p,vreinterpretq_u8_u64(a)); }
static inline uint64x2_t ch128_n_bc(const void *p) { return vld1q_u64((const uint64_t *)p); }
typedef struct { uint64x2_t l,h,m; } ch128_n_acc;
typedef struct { uint64x2_t lo,hi; } ch128_n_raw;
static inline ch128_n_acc ch128_n_azero(void) { ch128_n_acc r; r.l=r.h=r.m=ch128_n_zero(); return r; }
static inline ch128_n_acc ch128_n_accum(ch128_n_acc r,uint64x2_t a,uint64x2_t b,int school) {
    uint64x2_t l=ch128_n_ll(a,b),h=ch128_n_hh(a,b),m;
    if(school) m=ch128_n_xor(ch128_n_lh(a,b),ch128_n_hl(a,b));
    else m=ch128_n_ll(ch128_n_xor(a,ch128_n_swap(a)),ch128_n_xor(b,ch128_n_swap(b)));
    r.l=ch128_n_xor(r.l,l); r.h=ch128_n_xor(r.h,h); r.m=ch128_n_xor(r.m,m); __asm__("" : "+w"(r.l), "+w"(r.h), "+w"(r.m)); return r;
}
static inline ch128_n_raw ch128_n_pack(ch128_n_acc a,int school) {
    ch128_n_raw r; if(!school) a.m=ch128_n_xor(a.m,ch128_n_xor(a.l,a.h));
    r.lo=ch128_n_xor(a.l,ch128_n_left(a.m)); r.hi=ch128_n_xor(a.h,ch128_n_right(a.m)); return r;
}
static inline ch128_n_raw ch128_n_prod(uint64x2_t a,uint64x2_t b,int school) { return ch128_n_pack(ch128_n_accum(ch128_n_azero(),a,b,school),school); }
static inline ch128_raw ch128_n_wordprod(ch128_word a,ch128_word b,int school) {
    ch128_raw r; ch128_n_raw v=ch128_n_prod(ch128_n_load(&a),ch128_n_load(&b),school); ch128_n_store(&r.lo,v.lo); ch128_n_store(&r.hi,v.hi); return r;
}
#endif

static inline ch128_raw ch128_prod(ch128_word a,ch128_word b,int backend,int school) {
#ifdef CH128_X86
    if(backend) return ch128_128_wordprod(a,b,school);
#elif defined(CH128_ARM)
    if(backend) return ch128_n_wordprod(a,b,school);
#else
    (void)backend; (void)school;
#endif
    return ch128_clmul_ref(a,b);
}
static inline ch128_word ch128_mul(ch128_word a,ch128_word b,int backend) { return ch128_reduce(ch128_prod(a,b,backend,0)); }
static inline ch128_word ch128_pow(ch128_word a,uint64_t n,int b) {
    ch128_word r=ch128_make(1,0); while(n) { if(n&1) r=ch128_mul(r,a,b); n>>=1; if(n) a=ch128_mul(a,a,b); } return r;
}
static inline chainhash128_key chainhash128_key_from_words(const ch128_word *w) {
    chainhash128_key k; unsigned i; memcpy(k.ph,w,sizeof(k.ph));
    k.yp[0]=ch128_make(1,0); k.yh[0]=ch128_make(0x87,0);
    for(i=1;i<=8;i++) { k.yp[i]=ch128_mul_ref(k.yp[i-1],w[CH128_W]); k.yh[i]=ch128_mul_ref(k.yp[i],k.yh[0]); }
    for(i=0;i<5;i++) k.c[i]=w[CH128_W+1+i];
    k.tau=w[CH128_W+6]; return k;
}
static inline chainhash128_key chainhash128_key_from_bytes(const uint8_t p[128]) {
    ch128_word w[CH128_W+7],s=ch128_load(p),v=s; unsigned i;
    for(i=0;i<CH128_W;i++) { w[i]=v; v=ch128_mul_ref(v,s); }
    for(i=0;i<7;i++) w[CH128_W+i]=ch128_load(p+16*(i+1));
    return chainhash128_key_from_words(w);
}
/* Benchmark convenience: 64 bits of seed entropy, not 128 independent random bytes. */
static inline chainhash128_key chainhash128_key_from_seed(uint64_t seed) {
    uint8_t p[128]; unsigned i,j; for(i=0;i<16;i++) { uint64_t z=(seed+=UINT64_C(0x9e3779b97f4a7c15)); z=(z^(z>>30))*UINT64_C(0xbf58476d1ce4e5b9); z=(z^(z>>27))*UINT64_C(0x94d049bb133111eb); z^=z>>31; for(j=0;j<8;j++) p[8*i+j]=(uint8_t)(z>>(8*j)); } return chainhash128_key_from_bytes(p);
}
#ifdef CH128_X86
CH128_T128 static inline __m128i ch128_128_reduce(ch128_128_raw p) {
    const ch128_word rw={0x87,0}; __m128i r=ch128_128_load(&rw);
    __m128i a=ch128_128_ll(p.hi,r),b=ch128_128_hl(p.hi,r);
    __m128i t=ch128_128_right(ch128_128_xor(_mm_srli_epi64(p.hi,63),ch128_128_xor(_mm_srli_epi64(p.hi,62),_mm_srli_epi64(p.hi,57))));
    __m128i fold=ch128_128_xor(t,ch128_128_xor(_mm_slli_epi64(t,1),ch128_128_xor(_mm_slli_epi64(t,2),_mm_slli_epi64(t,7))));
    return ch128_128_xor(p.lo,ch128_128_xor(a,ch128_128_xor(ch128_128_left(b),fold)));
}
CH128_T128 static inline __m128i ch128_128_mul(__m128i a,__m128i b) { return ch128_128_reduce(ch128_128_prod(a,b,0)); }
CH128_T128 static inline ch128_word ch128_128_finish(const chainhash128_key *k,__m128i vv) {
    ch128_word v; __m128i x,q,r; ch128_128_raw sq;
    ch128_128_store(&v,vv);v=ch128_addint(v,k->tau);x=ch128_128_load(&v);
    sq.lo=ch128_128_ll(x,x);sq.hi=ch128_128_hh(x,x);q=ch128_128_reduce(sq);
    r=ch128_128_mul(ch128_128_xor(q,ch128_128_load(k->c)),ch128_128_xor(ch128_128_xor(x,q),ch128_128_load(k->c+1)));
    r=ch128_128_xor(ch128_128_mul(ch128_128_xor(x,ch128_128_load(k->c+2)),ch128_128_xor(r,ch128_128_load(k->c+3))),ch128_128_load(k->c+4));
    ch128_128_store(&v,r);return v;
}
/* For n<=128 every comb partner is absent. Factor its common key kb:
 * V = n*y^p + kb * Horner_y(w0+ka,...,w_(p-1)+ka). */
/* All partner words are absent through 128 bytes. Factor their common key
 * out of the Horner polynomial; the result is identical to separate blocks. */
CH128_T128 static inline ch128_word ch128_128_short(const chainhash128_key *k,const uint8_t *p,size_t n) {
    unsigned j,count=n?(unsigned)((n+15)/16):0; __m128i state=ch128_128_zero();
    if(count) {
        ch128_word w=ch128_partial(p,n,0),length={n,n};
        __m128i ka=ch128_128_load(k->ph),y=ch128_128_load(k->yp+1),yp,lv,l,m; ch128_128_acc a;
        state=ch128_128_xor(ch128_128_load(&w),ka);
        for(j=1;j<count;j++) {w=ch128_partial(p,n,16*j);state=ch128_128_xor(ch128_128_mul(state,y),ch128_128_xor(ch128_128_load(&w),ka));}
        a=ch128_128_accum(ch128_128_azero(),state,ch128_128_load(k->ph+1),0);
        yp=ch128_128_load(k->yp+count);lv=ch128_128_load(&length);
        l=ch128_128_ll(yp,lv);m=ch128_128_hh(yp,lv);
        a.l=ch128_128_xor(a.l,l);a.m=ch128_128_xor(a.m,ch128_128_xor(l,m));
        state=ch128_128_reduce(ch128_128_pack(a,0));
    }return ch128_128_finish(k,state);
}
#endif
#ifdef CH128_ARM
static inline uint64x2_t ch128_n_reduce(ch128_n_raw p) {
    const ch128_word rw={0x87,0}; uint64x2_t r=ch128_n_load(&rw);
    uint64x2_t a=ch128_n_ll(p.hi,r),b=ch128_n_hl(p.hi,r);
    uint64x2_t t=ch128_n_right(ch128_n_xor(vshrq_n_u64(p.hi,63),ch128_n_xor(vshrq_n_u64(p.hi,62),vshrq_n_u64(p.hi,57))));
    uint64x2_t fold=ch128_n_xor(t,ch128_n_xor(vshlq_n_u64(t,1),ch128_n_xor(vshlq_n_u64(t,2),vshlq_n_u64(t,7))));
    return ch128_n_xor(p.lo,ch128_n_xor(a,ch128_n_xor(ch128_n_left(b),fold)));
}
static inline uint64x2_t ch128_n_mul(uint64x2_t a,uint64x2_t b) { return ch128_n_reduce(ch128_n_prod(a,b,0)); }
static inline ch128_word ch128_n_finish(const chainhash128_key *k,uint64x2_t vv) {
    ch128_word v; uint64x2_t x,q,r; ch128_n_raw sq;
    ch128_n_store(&v,vv);v=ch128_addint(v,k->tau);x=ch128_n_load(&v);
    sq.lo=ch128_n_ll(x,x);sq.hi=ch128_n_hh(x,x);q=ch128_n_reduce(sq);
    r=ch128_n_mul(ch128_n_xor(q,ch128_n_load(k->c)),ch128_n_xor(ch128_n_xor(x,q),ch128_n_load(k->c+1)));
    r=ch128_n_xor(ch128_n_mul(ch128_n_xor(x,ch128_n_load(k->c+2)),ch128_n_xor(r,ch128_n_load(k->c+3))),ch128_n_load(k->c+4));
    ch128_n_store(&v,r);return v;
}
/* For n<=128 every comb partner is absent. Factor its common key kb:
 * V = n*y^p + kb * Horner_y(w0+ka,...,w_(p-1)+ka). */
static inline ch128_word ch128_n_short(const chainhash128_key *k,const uint8_t *p,size_t n) {
    unsigned j,count=n?(unsigned)((n+15)/16):0; uint64x2_t state=ch128_n_zero();
    if(count) {
        ch128_word w=ch128_partial(p,n,0),length={n,n};
        uint64x2_t ka=ch128_n_load(k->ph),y=ch128_n_load(k->yp+1),yp,lv,l,m; ch128_n_acc a;
        state=ch128_n_xor(ch128_n_load(&w),ka);
        for(j=1;j<count;j++) {w=ch128_partial(p,n,16*j);state=ch128_n_xor(ch128_n_mul(state,y),ch128_n_xor(ch128_n_load(&w),ka));}
        a=ch128_n_accum(ch128_n_azero(),state,ch128_n_load(k->ph+1),0);
        yp=ch128_n_load(k->yp+count);lv=ch128_n_load(&length);
        l=ch128_n_ll(yp,lv);m=ch128_n_hh(yp,lv);
        a.l=ch128_n_xor(a.l,l);a.m=ch128_n_xor(a.m,ch128_n_xor(l,m));
        state=ch128_n_reduce(ch128_n_pack(a,0));
    }return ch128_n_finish(k,state);
}
#endif
#ifdef CH128_X86
CH128_T128 static inline ch128_word ch128_128_finish_word(const chainhash128_key *k,ch128_word v) { return ch128_128_finish(k,ch128_128_load(&v)); }
#endif
static inline ch128_word ch128_finish(const chainhash128_key *k,ch128_word v,int b) {
#ifdef CH128_X86
    if(b) return ch128_128_finish_word(k,v);
#elif defined(CH128_ARM)
    if(b) return ch128_n_finish(k,ch128_n_load(&v));
#endif
    ch128_word q,r; v=ch128_addint(v,k->tau); q=ch128_mul(v,v,b);
    r=ch128_mul(ch128_xor(q,k->c[0]),ch128_xor(ch128_xor(v,q),k->c[1]),b);
    return ch128_xor(ch128_mul(ch128_xor(v,k->c[2]),ch128_xor(r,k->c[3]),b),k->c[4]);
}
static inline unsigned ch128_lanes(size_t n) { return n>112 ? 8 : n ? (unsigned)((n-1)/16+1) : 1; }
static inline void ch128_region_scalar(const chainhash128_key *k,const uint8_t *p,size_t n,ch128_raw out[8],int b,int school) {
    unsigned c,j; memset(out,0,8*sizeof(*out));
    for(c=0;c<CH128_CHUNKS && 256*c<n;c++) for(j=0;j<8 && 256*c+16*j<n;j++) { size_t off=256*c+16*j;
        if(off<n) out[j]=ch128_rxor(out[j],ch128_prod(ch128_xor(ch128_partial(p,n,off),k->ph[2*c]),ch128_xor(ch128_partial(p,n,off+128),k->ph[2*c+1]),b,school));
    }
}

#ifdef CH128_X86
CH128_T128 static void ch128_128_region(const chainhash128_key *k,const uint8_t *p,ch128_raw out[8],int school) {
    unsigned j,c; for(j=0;j<8;j+=1) { ch128_128_acc a=ch128_128_azero(); ch128_128_raw r;
        for(c=0;c<CH128_CHUNKS;c++) a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+256*c+16*j),ch128_128_bc(k->ph+2*c)),ch128_128_xor(ch128_128_load(p+256*c+16*j+128),ch128_128_bc(k->ph+2*c+1)),school);
        r=ch128_128_pack(a,school); { ch128_word lo[1],hi[1]; unsigned t; ch128_128_store(lo,r.lo); ch128_128_store(hi,r.hi); for(t=0;t<1;t++) { out[j+t].lo=lo[t]; out[j+t].hi=hi[t]; } }
    }
}
CH128_T128 static ch128_word ch128_128_bulk0(const chainhash128_key *k,const uint8_t *p,size_t regions,size_t len) {
    const __m128i y=ch128_128_bc(k->yp+8),h=ch128_128_bc(k->yh+8);
    ch128_128_raw s0; s0.lo=s0.hi=ch128_128_zero();
    ch128_128_raw s1; s1.lo=s1.hi=ch128_128_zero();
    ch128_128_raw s2; s2.lo=s2.hi=ch128_128_zero();
    ch128_128_raw s3; s3.lo=s3.hi=ch128_128_zero();
    ch128_128_raw s4; s4.lo=s4.hi=ch128_128_zero();
    ch128_128_raw s5; s5.lo=s5.hi=ch128_128_zero();
    ch128_128_raw s6; s6.lo=s6.hi=ch128_128_zero();
    ch128_128_raw s7; s7.lo=s7.hi=ch128_128_zero();
    { ch128_word init[1]={ {0,0} }; init[0].lo=len; s7.lo=ch128_128_load(init); }
    do {
        { ch128_128_acc a=ch128_128_azero();
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+0),ch128_128_bc(k->ph+0)),ch128_128_xor(ch128_128_load(p+128),ch128_128_bc(k->ph+1)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+256),ch128_128_bc(k->ph+2)),ch128_128_xor(ch128_128_load(p+384),ch128_128_bc(k->ph+3)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+512),ch128_128_bc(k->ph+4)),ch128_128_xor(ch128_128_load(p+640),ch128_128_bc(k->ph+5)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+768),ch128_128_bc(k->ph+6)),ch128_128_xor(ch128_128_load(p+896),ch128_128_bc(k->ph+7)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1024),ch128_128_bc(k->ph+8)),ch128_128_xor(ch128_128_load(p+1152),ch128_128_bc(k->ph+9)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1280),ch128_128_bc(k->ph+10)),ch128_128_xor(ch128_128_load(p+1408),ch128_128_bc(k->ph+11)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1536),ch128_128_bc(k->ph+12)),ch128_128_xor(ch128_128_load(p+1664),ch128_128_bc(k->ph+13)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1792),ch128_128_bc(k->ph+14)),ch128_128_xor(ch128_128_load(p+1920),ch128_128_bc(k->ph+15)),0);
#if CHAINHASH128_BLOCK_BYTES == 512
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2048),ch128_128_bc(k->ph+16)),ch128_128_xor(ch128_128_load(p+2176),ch128_128_bc(k->ph+17)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2304),ch128_128_bc(k->ph+18)),ch128_128_xor(ch128_128_load(p+2432),ch128_128_bc(k->ph+19)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2560),ch128_128_bc(k->ph+20)),ch128_128_xor(ch128_128_load(p+2688),ch128_128_bc(k->ph+21)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2816),ch128_128_bc(k->ph+22)),ch128_128_xor(ch128_128_load(p+2944),ch128_128_bc(k->ph+23)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3072),ch128_128_bc(k->ph+24)),ch128_128_xor(ch128_128_load(p+3200),ch128_128_bc(k->ph+25)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3328),ch128_128_bc(k->ph+26)),ch128_128_xor(ch128_128_load(p+3456),ch128_128_bc(k->ph+27)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3584),ch128_128_bc(k->ph+28)),ch128_128_xor(ch128_128_load(p+3712),ch128_128_bc(k->ph+29)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3840),ch128_128_bc(k->ph+30)),ch128_128_xor(ch128_128_load(p+3968),ch128_128_bc(k->ph+31)),0);
#endif
          a=ch128_128_accum(a,s0.lo,y,0); a=ch128_128_accum(a,s0.hi,h,0); s0=ch128_128_pack(a,0); }
        { ch128_128_acc a=ch128_128_azero();
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+16),ch128_128_bc(k->ph+0)),ch128_128_xor(ch128_128_load(p+144),ch128_128_bc(k->ph+1)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+272),ch128_128_bc(k->ph+2)),ch128_128_xor(ch128_128_load(p+400),ch128_128_bc(k->ph+3)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+528),ch128_128_bc(k->ph+4)),ch128_128_xor(ch128_128_load(p+656),ch128_128_bc(k->ph+5)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+784),ch128_128_bc(k->ph+6)),ch128_128_xor(ch128_128_load(p+912),ch128_128_bc(k->ph+7)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1040),ch128_128_bc(k->ph+8)),ch128_128_xor(ch128_128_load(p+1168),ch128_128_bc(k->ph+9)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1296),ch128_128_bc(k->ph+10)),ch128_128_xor(ch128_128_load(p+1424),ch128_128_bc(k->ph+11)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1552),ch128_128_bc(k->ph+12)),ch128_128_xor(ch128_128_load(p+1680),ch128_128_bc(k->ph+13)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1808),ch128_128_bc(k->ph+14)),ch128_128_xor(ch128_128_load(p+1936),ch128_128_bc(k->ph+15)),0);
#if CHAINHASH128_BLOCK_BYTES == 512
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2064),ch128_128_bc(k->ph+16)),ch128_128_xor(ch128_128_load(p+2192),ch128_128_bc(k->ph+17)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2320),ch128_128_bc(k->ph+18)),ch128_128_xor(ch128_128_load(p+2448),ch128_128_bc(k->ph+19)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2576),ch128_128_bc(k->ph+20)),ch128_128_xor(ch128_128_load(p+2704),ch128_128_bc(k->ph+21)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2832),ch128_128_bc(k->ph+22)),ch128_128_xor(ch128_128_load(p+2960),ch128_128_bc(k->ph+23)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3088),ch128_128_bc(k->ph+24)),ch128_128_xor(ch128_128_load(p+3216),ch128_128_bc(k->ph+25)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3344),ch128_128_bc(k->ph+26)),ch128_128_xor(ch128_128_load(p+3472),ch128_128_bc(k->ph+27)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3600),ch128_128_bc(k->ph+28)),ch128_128_xor(ch128_128_load(p+3728),ch128_128_bc(k->ph+29)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3856),ch128_128_bc(k->ph+30)),ch128_128_xor(ch128_128_load(p+3984),ch128_128_bc(k->ph+31)),0);
#endif
          a=ch128_128_accum(a,s1.lo,y,0); a=ch128_128_accum(a,s1.hi,h,0); s1=ch128_128_pack(a,0); }
        { ch128_128_acc a=ch128_128_azero();
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+32),ch128_128_bc(k->ph+0)),ch128_128_xor(ch128_128_load(p+160),ch128_128_bc(k->ph+1)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+288),ch128_128_bc(k->ph+2)),ch128_128_xor(ch128_128_load(p+416),ch128_128_bc(k->ph+3)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+544),ch128_128_bc(k->ph+4)),ch128_128_xor(ch128_128_load(p+672),ch128_128_bc(k->ph+5)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+800),ch128_128_bc(k->ph+6)),ch128_128_xor(ch128_128_load(p+928),ch128_128_bc(k->ph+7)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1056),ch128_128_bc(k->ph+8)),ch128_128_xor(ch128_128_load(p+1184),ch128_128_bc(k->ph+9)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1312),ch128_128_bc(k->ph+10)),ch128_128_xor(ch128_128_load(p+1440),ch128_128_bc(k->ph+11)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1568),ch128_128_bc(k->ph+12)),ch128_128_xor(ch128_128_load(p+1696),ch128_128_bc(k->ph+13)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1824),ch128_128_bc(k->ph+14)),ch128_128_xor(ch128_128_load(p+1952),ch128_128_bc(k->ph+15)),0);
#if CHAINHASH128_BLOCK_BYTES == 512
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2080),ch128_128_bc(k->ph+16)),ch128_128_xor(ch128_128_load(p+2208),ch128_128_bc(k->ph+17)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2336),ch128_128_bc(k->ph+18)),ch128_128_xor(ch128_128_load(p+2464),ch128_128_bc(k->ph+19)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2592),ch128_128_bc(k->ph+20)),ch128_128_xor(ch128_128_load(p+2720),ch128_128_bc(k->ph+21)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2848),ch128_128_bc(k->ph+22)),ch128_128_xor(ch128_128_load(p+2976),ch128_128_bc(k->ph+23)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3104),ch128_128_bc(k->ph+24)),ch128_128_xor(ch128_128_load(p+3232),ch128_128_bc(k->ph+25)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3360),ch128_128_bc(k->ph+26)),ch128_128_xor(ch128_128_load(p+3488),ch128_128_bc(k->ph+27)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3616),ch128_128_bc(k->ph+28)),ch128_128_xor(ch128_128_load(p+3744),ch128_128_bc(k->ph+29)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3872),ch128_128_bc(k->ph+30)),ch128_128_xor(ch128_128_load(p+4000),ch128_128_bc(k->ph+31)),0);
#endif
          a=ch128_128_accum(a,s2.lo,y,0); a=ch128_128_accum(a,s2.hi,h,0); s2=ch128_128_pack(a,0); }
        { ch128_128_acc a=ch128_128_azero();
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+48),ch128_128_bc(k->ph+0)),ch128_128_xor(ch128_128_load(p+176),ch128_128_bc(k->ph+1)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+304),ch128_128_bc(k->ph+2)),ch128_128_xor(ch128_128_load(p+432),ch128_128_bc(k->ph+3)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+560),ch128_128_bc(k->ph+4)),ch128_128_xor(ch128_128_load(p+688),ch128_128_bc(k->ph+5)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+816),ch128_128_bc(k->ph+6)),ch128_128_xor(ch128_128_load(p+944),ch128_128_bc(k->ph+7)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1072),ch128_128_bc(k->ph+8)),ch128_128_xor(ch128_128_load(p+1200),ch128_128_bc(k->ph+9)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1328),ch128_128_bc(k->ph+10)),ch128_128_xor(ch128_128_load(p+1456),ch128_128_bc(k->ph+11)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1584),ch128_128_bc(k->ph+12)),ch128_128_xor(ch128_128_load(p+1712),ch128_128_bc(k->ph+13)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1840),ch128_128_bc(k->ph+14)),ch128_128_xor(ch128_128_load(p+1968),ch128_128_bc(k->ph+15)),0);
#if CHAINHASH128_BLOCK_BYTES == 512
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2096),ch128_128_bc(k->ph+16)),ch128_128_xor(ch128_128_load(p+2224),ch128_128_bc(k->ph+17)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2352),ch128_128_bc(k->ph+18)),ch128_128_xor(ch128_128_load(p+2480),ch128_128_bc(k->ph+19)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2608),ch128_128_bc(k->ph+20)),ch128_128_xor(ch128_128_load(p+2736),ch128_128_bc(k->ph+21)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2864),ch128_128_bc(k->ph+22)),ch128_128_xor(ch128_128_load(p+2992),ch128_128_bc(k->ph+23)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3120),ch128_128_bc(k->ph+24)),ch128_128_xor(ch128_128_load(p+3248),ch128_128_bc(k->ph+25)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3376),ch128_128_bc(k->ph+26)),ch128_128_xor(ch128_128_load(p+3504),ch128_128_bc(k->ph+27)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3632),ch128_128_bc(k->ph+28)),ch128_128_xor(ch128_128_load(p+3760),ch128_128_bc(k->ph+29)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3888),ch128_128_bc(k->ph+30)),ch128_128_xor(ch128_128_load(p+4016),ch128_128_bc(k->ph+31)),0);
#endif
          a=ch128_128_accum(a,s3.lo,y,0); a=ch128_128_accum(a,s3.hi,h,0); s3=ch128_128_pack(a,0); }
        { ch128_128_acc a=ch128_128_azero();
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+64),ch128_128_bc(k->ph+0)),ch128_128_xor(ch128_128_load(p+192),ch128_128_bc(k->ph+1)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+320),ch128_128_bc(k->ph+2)),ch128_128_xor(ch128_128_load(p+448),ch128_128_bc(k->ph+3)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+576),ch128_128_bc(k->ph+4)),ch128_128_xor(ch128_128_load(p+704),ch128_128_bc(k->ph+5)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+832),ch128_128_bc(k->ph+6)),ch128_128_xor(ch128_128_load(p+960),ch128_128_bc(k->ph+7)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1088),ch128_128_bc(k->ph+8)),ch128_128_xor(ch128_128_load(p+1216),ch128_128_bc(k->ph+9)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1344),ch128_128_bc(k->ph+10)),ch128_128_xor(ch128_128_load(p+1472),ch128_128_bc(k->ph+11)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1600),ch128_128_bc(k->ph+12)),ch128_128_xor(ch128_128_load(p+1728),ch128_128_bc(k->ph+13)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1856),ch128_128_bc(k->ph+14)),ch128_128_xor(ch128_128_load(p+1984),ch128_128_bc(k->ph+15)),0);
#if CHAINHASH128_BLOCK_BYTES == 512
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2112),ch128_128_bc(k->ph+16)),ch128_128_xor(ch128_128_load(p+2240),ch128_128_bc(k->ph+17)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2368),ch128_128_bc(k->ph+18)),ch128_128_xor(ch128_128_load(p+2496),ch128_128_bc(k->ph+19)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2624),ch128_128_bc(k->ph+20)),ch128_128_xor(ch128_128_load(p+2752),ch128_128_bc(k->ph+21)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2880),ch128_128_bc(k->ph+22)),ch128_128_xor(ch128_128_load(p+3008),ch128_128_bc(k->ph+23)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3136),ch128_128_bc(k->ph+24)),ch128_128_xor(ch128_128_load(p+3264),ch128_128_bc(k->ph+25)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3392),ch128_128_bc(k->ph+26)),ch128_128_xor(ch128_128_load(p+3520),ch128_128_bc(k->ph+27)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3648),ch128_128_bc(k->ph+28)),ch128_128_xor(ch128_128_load(p+3776),ch128_128_bc(k->ph+29)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3904),ch128_128_bc(k->ph+30)),ch128_128_xor(ch128_128_load(p+4032),ch128_128_bc(k->ph+31)),0);
#endif
          a=ch128_128_accum(a,s4.lo,y,0); a=ch128_128_accum(a,s4.hi,h,0); s4=ch128_128_pack(a,0); }
        { ch128_128_acc a=ch128_128_azero();
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+80),ch128_128_bc(k->ph+0)),ch128_128_xor(ch128_128_load(p+208),ch128_128_bc(k->ph+1)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+336),ch128_128_bc(k->ph+2)),ch128_128_xor(ch128_128_load(p+464),ch128_128_bc(k->ph+3)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+592),ch128_128_bc(k->ph+4)),ch128_128_xor(ch128_128_load(p+720),ch128_128_bc(k->ph+5)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+848),ch128_128_bc(k->ph+6)),ch128_128_xor(ch128_128_load(p+976),ch128_128_bc(k->ph+7)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1104),ch128_128_bc(k->ph+8)),ch128_128_xor(ch128_128_load(p+1232),ch128_128_bc(k->ph+9)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1360),ch128_128_bc(k->ph+10)),ch128_128_xor(ch128_128_load(p+1488),ch128_128_bc(k->ph+11)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1616),ch128_128_bc(k->ph+12)),ch128_128_xor(ch128_128_load(p+1744),ch128_128_bc(k->ph+13)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1872),ch128_128_bc(k->ph+14)),ch128_128_xor(ch128_128_load(p+2000),ch128_128_bc(k->ph+15)),0);
#if CHAINHASH128_BLOCK_BYTES == 512
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2128),ch128_128_bc(k->ph+16)),ch128_128_xor(ch128_128_load(p+2256),ch128_128_bc(k->ph+17)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2384),ch128_128_bc(k->ph+18)),ch128_128_xor(ch128_128_load(p+2512),ch128_128_bc(k->ph+19)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2640),ch128_128_bc(k->ph+20)),ch128_128_xor(ch128_128_load(p+2768),ch128_128_bc(k->ph+21)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2896),ch128_128_bc(k->ph+22)),ch128_128_xor(ch128_128_load(p+3024),ch128_128_bc(k->ph+23)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3152),ch128_128_bc(k->ph+24)),ch128_128_xor(ch128_128_load(p+3280),ch128_128_bc(k->ph+25)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3408),ch128_128_bc(k->ph+26)),ch128_128_xor(ch128_128_load(p+3536),ch128_128_bc(k->ph+27)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3664),ch128_128_bc(k->ph+28)),ch128_128_xor(ch128_128_load(p+3792),ch128_128_bc(k->ph+29)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3920),ch128_128_bc(k->ph+30)),ch128_128_xor(ch128_128_load(p+4048),ch128_128_bc(k->ph+31)),0);
#endif
          a=ch128_128_accum(a,s5.lo,y,0); a=ch128_128_accum(a,s5.hi,h,0); s5=ch128_128_pack(a,0); }
        { ch128_128_acc a=ch128_128_azero();
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+96),ch128_128_bc(k->ph+0)),ch128_128_xor(ch128_128_load(p+224),ch128_128_bc(k->ph+1)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+352),ch128_128_bc(k->ph+2)),ch128_128_xor(ch128_128_load(p+480),ch128_128_bc(k->ph+3)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+608),ch128_128_bc(k->ph+4)),ch128_128_xor(ch128_128_load(p+736),ch128_128_bc(k->ph+5)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+864),ch128_128_bc(k->ph+6)),ch128_128_xor(ch128_128_load(p+992),ch128_128_bc(k->ph+7)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1120),ch128_128_bc(k->ph+8)),ch128_128_xor(ch128_128_load(p+1248),ch128_128_bc(k->ph+9)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1376),ch128_128_bc(k->ph+10)),ch128_128_xor(ch128_128_load(p+1504),ch128_128_bc(k->ph+11)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1632),ch128_128_bc(k->ph+12)),ch128_128_xor(ch128_128_load(p+1760),ch128_128_bc(k->ph+13)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1888),ch128_128_bc(k->ph+14)),ch128_128_xor(ch128_128_load(p+2016),ch128_128_bc(k->ph+15)),0);
#if CHAINHASH128_BLOCK_BYTES == 512
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2144),ch128_128_bc(k->ph+16)),ch128_128_xor(ch128_128_load(p+2272),ch128_128_bc(k->ph+17)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2400),ch128_128_bc(k->ph+18)),ch128_128_xor(ch128_128_load(p+2528),ch128_128_bc(k->ph+19)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2656),ch128_128_bc(k->ph+20)),ch128_128_xor(ch128_128_load(p+2784),ch128_128_bc(k->ph+21)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2912),ch128_128_bc(k->ph+22)),ch128_128_xor(ch128_128_load(p+3040),ch128_128_bc(k->ph+23)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3168),ch128_128_bc(k->ph+24)),ch128_128_xor(ch128_128_load(p+3296),ch128_128_bc(k->ph+25)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3424),ch128_128_bc(k->ph+26)),ch128_128_xor(ch128_128_load(p+3552),ch128_128_bc(k->ph+27)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3680),ch128_128_bc(k->ph+28)),ch128_128_xor(ch128_128_load(p+3808),ch128_128_bc(k->ph+29)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3936),ch128_128_bc(k->ph+30)),ch128_128_xor(ch128_128_load(p+4064),ch128_128_bc(k->ph+31)),0);
#endif
          a=ch128_128_accum(a,s6.lo,y,0); a=ch128_128_accum(a,s6.hi,h,0); s6=ch128_128_pack(a,0); }
        { ch128_128_acc a=ch128_128_azero();
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+112),ch128_128_bc(k->ph+0)),ch128_128_xor(ch128_128_load(p+240),ch128_128_bc(k->ph+1)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+368),ch128_128_bc(k->ph+2)),ch128_128_xor(ch128_128_load(p+496),ch128_128_bc(k->ph+3)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+624),ch128_128_bc(k->ph+4)),ch128_128_xor(ch128_128_load(p+752),ch128_128_bc(k->ph+5)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+880),ch128_128_bc(k->ph+6)),ch128_128_xor(ch128_128_load(p+1008),ch128_128_bc(k->ph+7)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1136),ch128_128_bc(k->ph+8)),ch128_128_xor(ch128_128_load(p+1264),ch128_128_bc(k->ph+9)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1392),ch128_128_bc(k->ph+10)),ch128_128_xor(ch128_128_load(p+1520),ch128_128_bc(k->ph+11)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1648),ch128_128_bc(k->ph+12)),ch128_128_xor(ch128_128_load(p+1776),ch128_128_bc(k->ph+13)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1904),ch128_128_bc(k->ph+14)),ch128_128_xor(ch128_128_load(p+2032),ch128_128_bc(k->ph+15)),0);
#if CHAINHASH128_BLOCK_BYTES == 512
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2160),ch128_128_bc(k->ph+16)),ch128_128_xor(ch128_128_load(p+2288),ch128_128_bc(k->ph+17)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2416),ch128_128_bc(k->ph+18)),ch128_128_xor(ch128_128_load(p+2544),ch128_128_bc(k->ph+19)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2672),ch128_128_bc(k->ph+20)),ch128_128_xor(ch128_128_load(p+2800),ch128_128_bc(k->ph+21)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2928),ch128_128_bc(k->ph+22)),ch128_128_xor(ch128_128_load(p+3056),ch128_128_bc(k->ph+23)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3184),ch128_128_bc(k->ph+24)),ch128_128_xor(ch128_128_load(p+3312),ch128_128_bc(k->ph+25)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3440),ch128_128_bc(k->ph+26)),ch128_128_xor(ch128_128_load(p+3568),ch128_128_bc(k->ph+27)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3696),ch128_128_bc(k->ph+28)),ch128_128_xor(ch128_128_load(p+3824),ch128_128_bc(k->ph+29)),0);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3952),ch128_128_bc(k->ph+30)),ch128_128_xor(ch128_128_load(p+4080),ch128_128_bc(k->ph+31)),0);
#endif
          a=ch128_128_accum(a,s7.lo,y,0); a=ch128_128_accum(a,s7.hi,h,0); s7=ch128_128_pack(a,0); }
        p+=CH128_REGION;
    } while(--regions);
    { ch128_raw acc={{0,0},{0,0}}; ch128_word lo[8],hi[8]; unsigned j;
      ch128_128_store(lo+0,s0.lo); ch128_128_store(hi+0,s0.hi);
      ch128_128_store(lo+1,s1.lo); ch128_128_store(hi+1,s1.hi);
      ch128_128_store(lo+2,s2.lo); ch128_128_store(hi+2,s2.hi);
      ch128_128_store(lo+3,s3.lo); ch128_128_store(hi+3,s3.hi);
      ch128_128_store(lo+4,s4.lo); ch128_128_store(hi+4,s4.hi);
      ch128_128_store(lo+5,s5.lo); ch128_128_store(hi+5,s5.hi);
      ch128_128_store(lo+6,s6.lo); ch128_128_store(hi+6,s6.hi);
      ch128_128_store(lo+7,s7.lo); ch128_128_store(hi+7,s7.hi);
      for(j=0;j<8;j++) { acc=ch128_rxor(acc,ch128_prod(lo[j],k->yp[7-j],1,0)); acc=ch128_rxor(acc,ch128_prod(hi[j],k->yh[7-j],1,0)); }
      return ch128_reduce(acc); }
}
CH128_T128 static ch128_word ch128_128_bulk1(const chainhash128_key *k,const uint8_t *p,size_t regions,size_t len) {
    const __m128i y=ch128_128_bc(k->yp+8),h=ch128_128_bc(k->yh+8);
    ch128_128_raw s0; s0.lo=s0.hi=ch128_128_zero();
    ch128_128_raw s1; s1.lo=s1.hi=ch128_128_zero();
    ch128_128_raw s2; s2.lo=s2.hi=ch128_128_zero();
    ch128_128_raw s3; s3.lo=s3.hi=ch128_128_zero();
    ch128_128_raw s4; s4.lo=s4.hi=ch128_128_zero();
    ch128_128_raw s5; s5.lo=s5.hi=ch128_128_zero();
    ch128_128_raw s6; s6.lo=s6.hi=ch128_128_zero();
    ch128_128_raw s7; s7.lo=s7.hi=ch128_128_zero();
    { ch128_word init[1]={ {0,0} }; init[0].lo=len; s7.lo=ch128_128_load(init); }
    do {
        { ch128_128_acc a=ch128_128_azero();
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+0),ch128_128_bc(k->ph+0)),ch128_128_xor(ch128_128_load(p+128),ch128_128_bc(k->ph+1)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+256),ch128_128_bc(k->ph+2)),ch128_128_xor(ch128_128_load(p+384),ch128_128_bc(k->ph+3)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+512),ch128_128_bc(k->ph+4)),ch128_128_xor(ch128_128_load(p+640),ch128_128_bc(k->ph+5)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+768),ch128_128_bc(k->ph+6)),ch128_128_xor(ch128_128_load(p+896),ch128_128_bc(k->ph+7)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1024),ch128_128_bc(k->ph+8)),ch128_128_xor(ch128_128_load(p+1152),ch128_128_bc(k->ph+9)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1280),ch128_128_bc(k->ph+10)),ch128_128_xor(ch128_128_load(p+1408),ch128_128_bc(k->ph+11)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1536),ch128_128_bc(k->ph+12)),ch128_128_xor(ch128_128_load(p+1664),ch128_128_bc(k->ph+13)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1792),ch128_128_bc(k->ph+14)),ch128_128_xor(ch128_128_load(p+1920),ch128_128_bc(k->ph+15)),1);
#if CHAINHASH128_BLOCK_BYTES == 512
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2048),ch128_128_bc(k->ph+16)),ch128_128_xor(ch128_128_load(p+2176),ch128_128_bc(k->ph+17)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2304),ch128_128_bc(k->ph+18)),ch128_128_xor(ch128_128_load(p+2432),ch128_128_bc(k->ph+19)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2560),ch128_128_bc(k->ph+20)),ch128_128_xor(ch128_128_load(p+2688),ch128_128_bc(k->ph+21)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2816),ch128_128_bc(k->ph+22)),ch128_128_xor(ch128_128_load(p+2944),ch128_128_bc(k->ph+23)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3072),ch128_128_bc(k->ph+24)),ch128_128_xor(ch128_128_load(p+3200),ch128_128_bc(k->ph+25)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3328),ch128_128_bc(k->ph+26)),ch128_128_xor(ch128_128_load(p+3456),ch128_128_bc(k->ph+27)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3584),ch128_128_bc(k->ph+28)),ch128_128_xor(ch128_128_load(p+3712),ch128_128_bc(k->ph+29)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3840),ch128_128_bc(k->ph+30)),ch128_128_xor(ch128_128_load(p+3968),ch128_128_bc(k->ph+31)),1);
#endif
          a=ch128_128_accum(a,s0.lo,y,1); a=ch128_128_accum(a,s0.hi,h,1); s0=ch128_128_pack(a,1); }
        { ch128_128_acc a=ch128_128_azero();
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+16),ch128_128_bc(k->ph+0)),ch128_128_xor(ch128_128_load(p+144),ch128_128_bc(k->ph+1)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+272),ch128_128_bc(k->ph+2)),ch128_128_xor(ch128_128_load(p+400),ch128_128_bc(k->ph+3)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+528),ch128_128_bc(k->ph+4)),ch128_128_xor(ch128_128_load(p+656),ch128_128_bc(k->ph+5)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+784),ch128_128_bc(k->ph+6)),ch128_128_xor(ch128_128_load(p+912),ch128_128_bc(k->ph+7)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1040),ch128_128_bc(k->ph+8)),ch128_128_xor(ch128_128_load(p+1168),ch128_128_bc(k->ph+9)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1296),ch128_128_bc(k->ph+10)),ch128_128_xor(ch128_128_load(p+1424),ch128_128_bc(k->ph+11)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1552),ch128_128_bc(k->ph+12)),ch128_128_xor(ch128_128_load(p+1680),ch128_128_bc(k->ph+13)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1808),ch128_128_bc(k->ph+14)),ch128_128_xor(ch128_128_load(p+1936),ch128_128_bc(k->ph+15)),1);
#if CHAINHASH128_BLOCK_BYTES == 512
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2064),ch128_128_bc(k->ph+16)),ch128_128_xor(ch128_128_load(p+2192),ch128_128_bc(k->ph+17)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2320),ch128_128_bc(k->ph+18)),ch128_128_xor(ch128_128_load(p+2448),ch128_128_bc(k->ph+19)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2576),ch128_128_bc(k->ph+20)),ch128_128_xor(ch128_128_load(p+2704),ch128_128_bc(k->ph+21)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2832),ch128_128_bc(k->ph+22)),ch128_128_xor(ch128_128_load(p+2960),ch128_128_bc(k->ph+23)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3088),ch128_128_bc(k->ph+24)),ch128_128_xor(ch128_128_load(p+3216),ch128_128_bc(k->ph+25)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3344),ch128_128_bc(k->ph+26)),ch128_128_xor(ch128_128_load(p+3472),ch128_128_bc(k->ph+27)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3600),ch128_128_bc(k->ph+28)),ch128_128_xor(ch128_128_load(p+3728),ch128_128_bc(k->ph+29)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3856),ch128_128_bc(k->ph+30)),ch128_128_xor(ch128_128_load(p+3984),ch128_128_bc(k->ph+31)),1);
#endif
          a=ch128_128_accum(a,s1.lo,y,1); a=ch128_128_accum(a,s1.hi,h,1); s1=ch128_128_pack(a,1); }
        { ch128_128_acc a=ch128_128_azero();
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+32),ch128_128_bc(k->ph+0)),ch128_128_xor(ch128_128_load(p+160),ch128_128_bc(k->ph+1)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+288),ch128_128_bc(k->ph+2)),ch128_128_xor(ch128_128_load(p+416),ch128_128_bc(k->ph+3)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+544),ch128_128_bc(k->ph+4)),ch128_128_xor(ch128_128_load(p+672),ch128_128_bc(k->ph+5)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+800),ch128_128_bc(k->ph+6)),ch128_128_xor(ch128_128_load(p+928),ch128_128_bc(k->ph+7)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1056),ch128_128_bc(k->ph+8)),ch128_128_xor(ch128_128_load(p+1184),ch128_128_bc(k->ph+9)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1312),ch128_128_bc(k->ph+10)),ch128_128_xor(ch128_128_load(p+1440),ch128_128_bc(k->ph+11)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1568),ch128_128_bc(k->ph+12)),ch128_128_xor(ch128_128_load(p+1696),ch128_128_bc(k->ph+13)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1824),ch128_128_bc(k->ph+14)),ch128_128_xor(ch128_128_load(p+1952),ch128_128_bc(k->ph+15)),1);
#if CHAINHASH128_BLOCK_BYTES == 512
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2080),ch128_128_bc(k->ph+16)),ch128_128_xor(ch128_128_load(p+2208),ch128_128_bc(k->ph+17)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2336),ch128_128_bc(k->ph+18)),ch128_128_xor(ch128_128_load(p+2464),ch128_128_bc(k->ph+19)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2592),ch128_128_bc(k->ph+20)),ch128_128_xor(ch128_128_load(p+2720),ch128_128_bc(k->ph+21)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2848),ch128_128_bc(k->ph+22)),ch128_128_xor(ch128_128_load(p+2976),ch128_128_bc(k->ph+23)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3104),ch128_128_bc(k->ph+24)),ch128_128_xor(ch128_128_load(p+3232),ch128_128_bc(k->ph+25)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3360),ch128_128_bc(k->ph+26)),ch128_128_xor(ch128_128_load(p+3488),ch128_128_bc(k->ph+27)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3616),ch128_128_bc(k->ph+28)),ch128_128_xor(ch128_128_load(p+3744),ch128_128_bc(k->ph+29)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3872),ch128_128_bc(k->ph+30)),ch128_128_xor(ch128_128_load(p+4000),ch128_128_bc(k->ph+31)),1);
#endif
          a=ch128_128_accum(a,s2.lo,y,1); a=ch128_128_accum(a,s2.hi,h,1); s2=ch128_128_pack(a,1); }
        { ch128_128_acc a=ch128_128_azero();
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+48),ch128_128_bc(k->ph+0)),ch128_128_xor(ch128_128_load(p+176),ch128_128_bc(k->ph+1)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+304),ch128_128_bc(k->ph+2)),ch128_128_xor(ch128_128_load(p+432),ch128_128_bc(k->ph+3)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+560),ch128_128_bc(k->ph+4)),ch128_128_xor(ch128_128_load(p+688),ch128_128_bc(k->ph+5)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+816),ch128_128_bc(k->ph+6)),ch128_128_xor(ch128_128_load(p+944),ch128_128_bc(k->ph+7)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1072),ch128_128_bc(k->ph+8)),ch128_128_xor(ch128_128_load(p+1200),ch128_128_bc(k->ph+9)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1328),ch128_128_bc(k->ph+10)),ch128_128_xor(ch128_128_load(p+1456),ch128_128_bc(k->ph+11)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1584),ch128_128_bc(k->ph+12)),ch128_128_xor(ch128_128_load(p+1712),ch128_128_bc(k->ph+13)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1840),ch128_128_bc(k->ph+14)),ch128_128_xor(ch128_128_load(p+1968),ch128_128_bc(k->ph+15)),1);
#if CHAINHASH128_BLOCK_BYTES == 512
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2096),ch128_128_bc(k->ph+16)),ch128_128_xor(ch128_128_load(p+2224),ch128_128_bc(k->ph+17)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2352),ch128_128_bc(k->ph+18)),ch128_128_xor(ch128_128_load(p+2480),ch128_128_bc(k->ph+19)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2608),ch128_128_bc(k->ph+20)),ch128_128_xor(ch128_128_load(p+2736),ch128_128_bc(k->ph+21)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2864),ch128_128_bc(k->ph+22)),ch128_128_xor(ch128_128_load(p+2992),ch128_128_bc(k->ph+23)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3120),ch128_128_bc(k->ph+24)),ch128_128_xor(ch128_128_load(p+3248),ch128_128_bc(k->ph+25)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3376),ch128_128_bc(k->ph+26)),ch128_128_xor(ch128_128_load(p+3504),ch128_128_bc(k->ph+27)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3632),ch128_128_bc(k->ph+28)),ch128_128_xor(ch128_128_load(p+3760),ch128_128_bc(k->ph+29)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3888),ch128_128_bc(k->ph+30)),ch128_128_xor(ch128_128_load(p+4016),ch128_128_bc(k->ph+31)),1);
#endif
          a=ch128_128_accum(a,s3.lo,y,1); a=ch128_128_accum(a,s3.hi,h,1); s3=ch128_128_pack(a,1); }
        { ch128_128_acc a=ch128_128_azero();
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+64),ch128_128_bc(k->ph+0)),ch128_128_xor(ch128_128_load(p+192),ch128_128_bc(k->ph+1)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+320),ch128_128_bc(k->ph+2)),ch128_128_xor(ch128_128_load(p+448),ch128_128_bc(k->ph+3)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+576),ch128_128_bc(k->ph+4)),ch128_128_xor(ch128_128_load(p+704),ch128_128_bc(k->ph+5)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+832),ch128_128_bc(k->ph+6)),ch128_128_xor(ch128_128_load(p+960),ch128_128_bc(k->ph+7)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1088),ch128_128_bc(k->ph+8)),ch128_128_xor(ch128_128_load(p+1216),ch128_128_bc(k->ph+9)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1344),ch128_128_bc(k->ph+10)),ch128_128_xor(ch128_128_load(p+1472),ch128_128_bc(k->ph+11)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1600),ch128_128_bc(k->ph+12)),ch128_128_xor(ch128_128_load(p+1728),ch128_128_bc(k->ph+13)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1856),ch128_128_bc(k->ph+14)),ch128_128_xor(ch128_128_load(p+1984),ch128_128_bc(k->ph+15)),1);
#if CHAINHASH128_BLOCK_BYTES == 512
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2112),ch128_128_bc(k->ph+16)),ch128_128_xor(ch128_128_load(p+2240),ch128_128_bc(k->ph+17)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2368),ch128_128_bc(k->ph+18)),ch128_128_xor(ch128_128_load(p+2496),ch128_128_bc(k->ph+19)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2624),ch128_128_bc(k->ph+20)),ch128_128_xor(ch128_128_load(p+2752),ch128_128_bc(k->ph+21)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2880),ch128_128_bc(k->ph+22)),ch128_128_xor(ch128_128_load(p+3008),ch128_128_bc(k->ph+23)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3136),ch128_128_bc(k->ph+24)),ch128_128_xor(ch128_128_load(p+3264),ch128_128_bc(k->ph+25)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3392),ch128_128_bc(k->ph+26)),ch128_128_xor(ch128_128_load(p+3520),ch128_128_bc(k->ph+27)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3648),ch128_128_bc(k->ph+28)),ch128_128_xor(ch128_128_load(p+3776),ch128_128_bc(k->ph+29)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3904),ch128_128_bc(k->ph+30)),ch128_128_xor(ch128_128_load(p+4032),ch128_128_bc(k->ph+31)),1);
#endif
          a=ch128_128_accum(a,s4.lo,y,1); a=ch128_128_accum(a,s4.hi,h,1); s4=ch128_128_pack(a,1); }
        { ch128_128_acc a=ch128_128_azero();
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+80),ch128_128_bc(k->ph+0)),ch128_128_xor(ch128_128_load(p+208),ch128_128_bc(k->ph+1)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+336),ch128_128_bc(k->ph+2)),ch128_128_xor(ch128_128_load(p+464),ch128_128_bc(k->ph+3)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+592),ch128_128_bc(k->ph+4)),ch128_128_xor(ch128_128_load(p+720),ch128_128_bc(k->ph+5)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+848),ch128_128_bc(k->ph+6)),ch128_128_xor(ch128_128_load(p+976),ch128_128_bc(k->ph+7)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1104),ch128_128_bc(k->ph+8)),ch128_128_xor(ch128_128_load(p+1232),ch128_128_bc(k->ph+9)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1360),ch128_128_bc(k->ph+10)),ch128_128_xor(ch128_128_load(p+1488),ch128_128_bc(k->ph+11)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1616),ch128_128_bc(k->ph+12)),ch128_128_xor(ch128_128_load(p+1744),ch128_128_bc(k->ph+13)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1872),ch128_128_bc(k->ph+14)),ch128_128_xor(ch128_128_load(p+2000),ch128_128_bc(k->ph+15)),1);
#if CHAINHASH128_BLOCK_BYTES == 512
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2128),ch128_128_bc(k->ph+16)),ch128_128_xor(ch128_128_load(p+2256),ch128_128_bc(k->ph+17)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2384),ch128_128_bc(k->ph+18)),ch128_128_xor(ch128_128_load(p+2512),ch128_128_bc(k->ph+19)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2640),ch128_128_bc(k->ph+20)),ch128_128_xor(ch128_128_load(p+2768),ch128_128_bc(k->ph+21)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2896),ch128_128_bc(k->ph+22)),ch128_128_xor(ch128_128_load(p+3024),ch128_128_bc(k->ph+23)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3152),ch128_128_bc(k->ph+24)),ch128_128_xor(ch128_128_load(p+3280),ch128_128_bc(k->ph+25)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3408),ch128_128_bc(k->ph+26)),ch128_128_xor(ch128_128_load(p+3536),ch128_128_bc(k->ph+27)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3664),ch128_128_bc(k->ph+28)),ch128_128_xor(ch128_128_load(p+3792),ch128_128_bc(k->ph+29)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3920),ch128_128_bc(k->ph+30)),ch128_128_xor(ch128_128_load(p+4048),ch128_128_bc(k->ph+31)),1);
#endif
          a=ch128_128_accum(a,s5.lo,y,1); a=ch128_128_accum(a,s5.hi,h,1); s5=ch128_128_pack(a,1); }
        { ch128_128_acc a=ch128_128_azero();
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+96),ch128_128_bc(k->ph+0)),ch128_128_xor(ch128_128_load(p+224),ch128_128_bc(k->ph+1)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+352),ch128_128_bc(k->ph+2)),ch128_128_xor(ch128_128_load(p+480),ch128_128_bc(k->ph+3)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+608),ch128_128_bc(k->ph+4)),ch128_128_xor(ch128_128_load(p+736),ch128_128_bc(k->ph+5)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+864),ch128_128_bc(k->ph+6)),ch128_128_xor(ch128_128_load(p+992),ch128_128_bc(k->ph+7)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1120),ch128_128_bc(k->ph+8)),ch128_128_xor(ch128_128_load(p+1248),ch128_128_bc(k->ph+9)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1376),ch128_128_bc(k->ph+10)),ch128_128_xor(ch128_128_load(p+1504),ch128_128_bc(k->ph+11)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1632),ch128_128_bc(k->ph+12)),ch128_128_xor(ch128_128_load(p+1760),ch128_128_bc(k->ph+13)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1888),ch128_128_bc(k->ph+14)),ch128_128_xor(ch128_128_load(p+2016),ch128_128_bc(k->ph+15)),1);
#if CHAINHASH128_BLOCK_BYTES == 512
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2144),ch128_128_bc(k->ph+16)),ch128_128_xor(ch128_128_load(p+2272),ch128_128_bc(k->ph+17)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2400),ch128_128_bc(k->ph+18)),ch128_128_xor(ch128_128_load(p+2528),ch128_128_bc(k->ph+19)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2656),ch128_128_bc(k->ph+20)),ch128_128_xor(ch128_128_load(p+2784),ch128_128_bc(k->ph+21)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2912),ch128_128_bc(k->ph+22)),ch128_128_xor(ch128_128_load(p+3040),ch128_128_bc(k->ph+23)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3168),ch128_128_bc(k->ph+24)),ch128_128_xor(ch128_128_load(p+3296),ch128_128_bc(k->ph+25)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3424),ch128_128_bc(k->ph+26)),ch128_128_xor(ch128_128_load(p+3552),ch128_128_bc(k->ph+27)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3680),ch128_128_bc(k->ph+28)),ch128_128_xor(ch128_128_load(p+3808),ch128_128_bc(k->ph+29)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3936),ch128_128_bc(k->ph+30)),ch128_128_xor(ch128_128_load(p+4064),ch128_128_bc(k->ph+31)),1);
#endif
          a=ch128_128_accum(a,s6.lo,y,1); a=ch128_128_accum(a,s6.hi,h,1); s6=ch128_128_pack(a,1); }
        { ch128_128_acc a=ch128_128_azero();
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+112),ch128_128_bc(k->ph+0)),ch128_128_xor(ch128_128_load(p+240),ch128_128_bc(k->ph+1)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+368),ch128_128_bc(k->ph+2)),ch128_128_xor(ch128_128_load(p+496),ch128_128_bc(k->ph+3)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+624),ch128_128_bc(k->ph+4)),ch128_128_xor(ch128_128_load(p+752),ch128_128_bc(k->ph+5)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+880),ch128_128_bc(k->ph+6)),ch128_128_xor(ch128_128_load(p+1008),ch128_128_bc(k->ph+7)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1136),ch128_128_bc(k->ph+8)),ch128_128_xor(ch128_128_load(p+1264),ch128_128_bc(k->ph+9)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1392),ch128_128_bc(k->ph+10)),ch128_128_xor(ch128_128_load(p+1520),ch128_128_bc(k->ph+11)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1648),ch128_128_bc(k->ph+12)),ch128_128_xor(ch128_128_load(p+1776),ch128_128_bc(k->ph+13)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+1904),ch128_128_bc(k->ph+14)),ch128_128_xor(ch128_128_load(p+2032),ch128_128_bc(k->ph+15)),1);
#if CHAINHASH128_BLOCK_BYTES == 512
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2160),ch128_128_bc(k->ph+16)),ch128_128_xor(ch128_128_load(p+2288),ch128_128_bc(k->ph+17)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2416),ch128_128_bc(k->ph+18)),ch128_128_xor(ch128_128_load(p+2544),ch128_128_bc(k->ph+19)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2672),ch128_128_bc(k->ph+20)),ch128_128_xor(ch128_128_load(p+2800),ch128_128_bc(k->ph+21)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+2928),ch128_128_bc(k->ph+22)),ch128_128_xor(ch128_128_load(p+3056),ch128_128_bc(k->ph+23)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3184),ch128_128_bc(k->ph+24)),ch128_128_xor(ch128_128_load(p+3312),ch128_128_bc(k->ph+25)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3440),ch128_128_bc(k->ph+26)),ch128_128_xor(ch128_128_load(p+3568),ch128_128_bc(k->ph+27)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3696),ch128_128_bc(k->ph+28)),ch128_128_xor(ch128_128_load(p+3824),ch128_128_bc(k->ph+29)),1);
          a=ch128_128_accum(a,ch128_128_xor(ch128_128_load(p+3952),ch128_128_bc(k->ph+30)),ch128_128_xor(ch128_128_load(p+4080),ch128_128_bc(k->ph+31)),1);
#endif
          a=ch128_128_accum(a,s7.lo,y,1); a=ch128_128_accum(a,s7.hi,h,1); s7=ch128_128_pack(a,1); }
        p+=CH128_REGION;
    } while(--regions);
    { ch128_raw acc={{0,0},{0,0}}; ch128_word lo[8],hi[8]; unsigned j;
      ch128_128_store(lo+0,s0.lo); ch128_128_store(hi+0,s0.hi);
      ch128_128_store(lo+1,s1.lo); ch128_128_store(hi+1,s1.hi);
      ch128_128_store(lo+2,s2.lo); ch128_128_store(hi+2,s2.hi);
      ch128_128_store(lo+3,s3.lo); ch128_128_store(hi+3,s3.hi);
      ch128_128_store(lo+4,s4.lo); ch128_128_store(hi+4,s4.hi);
      ch128_128_store(lo+5,s5.lo); ch128_128_store(hi+5,s5.hi);
      ch128_128_store(lo+6,s6.lo); ch128_128_store(hi+6,s6.hi);
      ch128_128_store(lo+7,s7.lo); ch128_128_store(hi+7,s7.hi);
      for(j=0;j<8;j++) { acc=ch128_rxor(acc,ch128_prod(lo[j],k->yp[7-j],1,1)); acc=ch128_rxor(acc,ch128_prod(hi[j],k->yh[7-j],1,1)); }
      return ch128_reduce(acc); }
}
#endif

#ifdef CH128_X86
CH128_T256 static void ch128_256_region(const chainhash128_key *k,const uint8_t *p,ch128_raw out[8],int school) {
    unsigned j,c; for(j=0;j<8;j+=2) { ch128_256_acc a=ch128_256_azero(); ch128_256_raw r;
        for(c=0;c<CH128_CHUNKS;c++) a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+256*c+16*j),ch128_256_bc(k->ph+2*c)),ch128_256_xor(ch128_256_load(p+256*c+16*j+128),ch128_256_bc(k->ph+2*c+1)),school);
        r=ch128_256_pack(a,school); { ch128_word lo[2],hi[2]; unsigned t; ch128_256_store(lo,r.lo); ch128_256_store(hi,r.hi); for(t=0;t<2;t++) { out[j+t].lo=lo[t]; out[j+t].hi=hi[t]; } }
    }
}
CH128_T256 static ch128_word ch128_256_bulk0(const chainhash128_key *k,const uint8_t *p,size_t regions,size_t len) {
    const __m256i y=ch128_256_bc(k->yp+8),h=ch128_256_bc(k->yh+8);
    ch128_256_raw s0; s0.lo=s0.hi=ch128_256_zero();
    ch128_256_raw s1; s1.lo=s1.hi=ch128_256_zero();
    ch128_256_raw s2; s2.lo=s2.hi=ch128_256_zero();
    ch128_256_raw s3; s3.lo=s3.hi=ch128_256_zero();
    { ch128_word init[2]={ {0,0} }; init[1].lo=len; s3.lo=ch128_256_load(init); }
    do {
        { ch128_256_acc a=ch128_256_azero();
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+0),ch128_256_bc(k->ph+0)),ch128_256_xor(ch128_256_load(p+128),ch128_256_bc(k->ph+1)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+256),ch128_256_bc(k->ph+2)),ch128_256_xor(ch128_256_load(p+384),ch128_256_bc(k->ph+3)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+512),ch128_256_bc(k->ph+4)),ch128_256_xor(ch128_256_load(p+640),ch128_256_bc(k->ph+5)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+768),ch128_256_bc(k->ph+6)),ch128_256_xor(ch128_256_load(p+896),ch128_256_bc(k->ph+7)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1024),ch128_256_bc(k->ph+8)),ch128_256_xor(ch128_256_load(p+1152),ch128_256_bc(k->ph+9)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1280),ch128_256_bc(k->ph+10)),ch128_256_xor(ch128_256_load(p+1408),ch128_256_bc(k->ph+11)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1536),ch128_256_bc(k->ph+12)),ch128_256_xor(ch128_256_load(p+1664),ch128_256_bc(k->ph+13)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1792),ch128_256_bc(k->ph+14)),ch128_256_xor(ch128_256_load(p+1920),ch128_256_bc(k->ph+15)),0);
#if CHAINHASH128_BLOCK_BYTES == 512
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2048),ch128_256_bc(k->ph+16)),ch128_256_xor(ch128_256_load(p+2176),ch128_256_bc(k->ph+17)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2304),ch128_256_bc(k->ph+18)),ch128_256_xor(ch128_256_load(p+2432),ch128_256_bc(k->ph+19)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2560),ch128_256_bc(k->ph+20)),ch128_256_xor(ch128_256_load(p+2688),ch128_256_bc(k->ph+21)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2816),ch128_256_bc(k->ph+22)),ch128_256_xor(ch128_256_load(p+2944),ch128_256_bc(k->ph+23)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3072),ch128_256_bc(k->ph+24)),ch128_256_xor(ch128_256_load(p+3200),ch128_256_bc(k->ph+25)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3328),ch128_256_bc(k->ph+26)),ch128_256_xor(ch128_256_load(p+3456),ch128_256_bc(k->ph+27)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3584),ch128_256_bc(k->ph+28)),ch128_256_xor(ch128_256_load(p+3712),ch128_256_bc(k->ph+29)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3840),ch128_256_bc(k->ph+30)),ch128_256_xor(ch128_256_load(p+3968),ch128_256_bc(k->ph+31)),0);
#endif
          a=ch128_256_accum(a,s0.lo,y,0); a=ch128_256_accum(a,s0.hi,h,0); s0=ch128_256_pack(a,0); }
        { ch128_256_acc a=ch128_256_azero();
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+32),ch128_256_bc(k->ph+0)),ch128_256_xor(ch128_256_load(p+160),ch128_256_bc(k->ph+1)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+288),ch128_256_bc(k->ph+2)),ch128_256_xor(ch128_256_load(p+416),ch128_256_bc(k->ph+3)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+544),ch128_256_bc(k->ph+4)),ch128_256_xor(ch128_256_load(p+672),ch128_256_bc(k->ph+5)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+800),ch128_256_bc(k->ph+6)),ch128_256_xor(ch128_256_load(p+928),ch128_256_bc(k->ph+7)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1056),ch128_256_bc(k->ph+8)),ch128_256_xor(ch128_256_load(p+1184),ch128_256_bc(k->ph+9)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1312),ch128_256_bc(k->ph+10)),ch128_256_xor(ch128_256_load(p+1440),ch128_256_bc(k->ph+11)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1568),ch128_256_bc(k->ph+12)),ch128_256_xor(ch128_256_load(p+1696),ch128_256_bc(k->ph+13)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1824),ch128_256_bc(k->ph+14)),ch128_256_xor(ch128_256_load(p+1952),ch128_256_bc(k->ph+15)),0);
#if CHAINHASH128_BLOCK_BYTES == 512
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2080),ch128_256_bc(k->ph+16)),ch128_256_xor(ch128_256_load(p+2208),ch128_256_bc(k->ph+17)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2336),ch128_256_bc(k->ph+18)),ch128_256_xor(ch128_256_load(p+2464),ch128_256_bc(k->ph+19)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2592),ch128_256_bc(k->ph+20)),ch128_256_xor(ch128_256_load(p+2720),ch128_256_bc(k->ph+21)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2848),ch128_256_bc(k->ph+22)),ch128_256_xor(ch128_256_load(p+2976),ch128_256_bc(k->ph+23)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3104),ch128_256_bc(k->ph+24)),ch128_256_xor(ch128_256_load(p+3232),ch128_256_bc(k->ph+25)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3360),ch128_256_bc(k->ph+26)),ch128_256_xor(ch128_256_load(p+3488),ch128_256_bc(k->ph+27)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3616),ch128_256_bc(k->ph+28)),ch128_256_xor(ch128_256_load(p+3744),ch128_256_bc(k->ph+29)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3872),ch128_256_bc(k->ph+30)),ch128_256_xor(ch128_256_load(p+4000),ch128_256_bc(k->ph+31)),0);
#endif
          a=ch128_256_accum(a,s1.lo,y,0); a=ch128_256_accum(a,s1.hi,h,0); s1=ch128_256_pack(a,0); }
        { ch128_256_acc a=ch128_256_azero();
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+64),ch128_256_bc(k->ph+0)),ch128_256_xor(ch128_256_load(p+192),ch128_256_bc(k->ph+1)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+320),ch128_256_bc(k->ph+2)),ch128_256_xor(ch128_256_load(p+448),ch128_256_bc(k->ph+3)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+576),ch128_256_bc(k->ph+4)),ch128_256_xor(ch128_256_load(p+704),ch128_256_bc(k->ph+5)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+832),ch128_256_bc(k->ph+6)),ch128_256_xor(ch128_256_load(p+960),ch128_256_bc(k->ph+7)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1088),ch128_256_bc(k->ph+8)),ch128_256_xor(ch128_256_load(p+1216),ch128_256_bc(k->ph+9)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1344),ch128_256_bc(k->ph+10)),ch128_256_xor(ch128_256_load(p+1472),ch128_256_bc(k->ph+11)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1600),ch128_256_bc(k->ph+12)),ch128_256_xor(ch128_256_load(p+1728),ch128_256_bc(k->ph+13)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1856),ch128_256_bc(k->ph+14)),ch128_256_xor(ch128_256_load(p+1984),ch128_256_bc(k->ph+15)),0);
#if CHAINHASH128_BLOCK_BYTES == 512
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2112),ch128_256_bc(k->ph+16)),ch128_256_xor(ch128_256_load(p+2240),ch128_256_bc(k->ph+17)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2368),ch128_256_bc(k->ph+18)),ch128_256_xor(ch128_256_load(p+2496),ch128_256_bc(k->ph+19)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2624),ch128_256_bc(k->ph+20)),ch128_256_xor(ch128_256_load(p+2752),ch128_256_bc(k->ph+21)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2880),ch128_256_bc(k->ph+22)),ch128_256_xor(ch128_256_load(p+3008),ch128_256_bc(k->ph+23)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3136),ch128_256_bc(k->ph+24)),ch128_256_xor(ch128_256_load(p+3264),ch128_256_bc(k->ph+25)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3392),ch128_256_bc(k->ph+26)),ch128_256_xor(ch128_256_load(p+3520),ch128_256_bc(k->ph+27)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3648),ch128_256_bc(k->ph+28)),ch128_256_xor(ch128_256_load(p+3776),ch128_256_bc(k->ph+29)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3904),ch128_256_bc(k->ph+30)),ch128_256_xor(ch128_256_load(p+4032),ch128_256_bc(k->ph+31)),0);
#endif
          a=ch128_256_accum(a,s2.lo,y,0); a=ch128_256_accum(a,s2.hi,h,0); s2=ch128_256_pack(a,0); }
        { ch128_256_acc a=ch128_256_azero();
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+96),ch128_256_bc(k->ph+0)),ch128_256_xor(ch128_256_load(p+224),ch128_256_bc(k->ph+1)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+352),ch128_256_bc(k->ph+2)),ch128_256_xor(ch128_256_load(p+480),ch128_256_bc(k->ph+3)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+608),ch128_256_bc(k->ph+4)),ch128_256_xor(ch128_256_load(p+736),ch128_256_bc(k->ph+5)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+864),ch128_256_bc(k->ph+6)),ch128_256_xor(ch128_256_load(p+992),ch128_256_bc(k->ph+7)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1120),ch128_256_bc(k->ph+8)),ch128_256_xor(ch128_256_load(p+1248),ch128_256_bc(k->ph+9)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1376),ch128_256_bc(k->ph+10)),ch128_256_xor(ch128_256_load(p+1504),ch128_256_bc(k->ph+11)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1632),ch128_256_bc(k->ph+12)),ch128_256_xor(ch128_256_load(p+1760),ch128_256_bc(k->ph+13)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1888),ch128_256_bc(k->ph+14)),ch128_256_xor(ch128_256_load(p+2016),ch128_256_bc(k->ph+15)),0);
#if CHAINHASH128_BLOCK_BYTES == 512
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2144),ch128_256_bc(k->ph+16)),ch128_256_xor(ch128_256_load(p+2272),ch128_256_bc(k->ph+17)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2400),ch128_256_bc(k->ph+18)),ch128_256_xor(ch128_256_load(p+2528),ch128_256_bc(k->ph+19)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2656),ch128_256_bc(k->ph+20)),ch128_256_xor(ch128_256_load(p+2784),ch128_256_bc(k->ph+21)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2912),ch128_256_bc(k->ph+22)),ch128_256_xor(ch128_256_load(p+3040),ch128_256_bc(k->ph+23)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3168),ch128_256_bc(k->ph+24)),ch128_256_xor(ch128_256_load(p+3296),ch128_256_bc(k->ph+25)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3424),ch128_256_bc(k->ph+26)),ch128_256_xor(ch128_256_load(p+3552),ch128_256_bc(k->ph+27)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3680),ch128_256_bc(k->ph+28)),ch128_256_xor(ch128_256_load(p+3808),ch128_256_bc(k->ph+29)),0);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3936),ch128_256_bc(k->ph+30)),ch128_256_xor(ch128_256_load(p+4064),ch128_256_bc(k->ph+31)),0);
#endif
          a=ch128_256_accum(a,s3.lo,y,0); a=ch128_256_accum(a,s3.hi,h,0); s3=ch128_256_pack(a,0); }
        p+=CH128_REGION;
    } while(--regions);
    { ch128_raw acc={{0,0},{0,0}}; ch128_word lo[8],hi[8]; unsigned j;
      ch128_256_store(lo+0,s0.lo); ch128_256_store(hi+0,s0.hi);
      ch128_256_store(lo+2,s1.lo); ch128_256_store(hi+2,s1.hi);
      ch128_256_store(lo+4,s2.lo); ch128_256_store(hi+4,s2.hi);
      ch128_256_store(lo+6,s3.lo); ch128_256_store(hi+6,s3.hi);
      for(j=0;j<8;j++) { acc=ch128_rxor(acc,ch128_prod(lo[j],k->yp[7-j],1,0)); acc=ch128_rxor(acc,ch128_prod(hi[j],k->yh[7-j],1,0)); }
      return ch128_reduce(acc); }
}
CH128_T256 static ch128_word ch128_256_bulk1(const chainhash128_key *k,const uint8_t *p,size_t regions,size_t len) {
    const __m256i y=ch128_256_bc(k->yp+8),h=ch128_256_bc(k->yh+8);
    ch128_256_raw s0; s0.lo=s0.hi=ch128_256_zero();
    ch128_256_raw s1; s1.lo=s1.hi=ch128_256_zero();
    ch128_256_raw s2; s2.lo=s2.hi=ch128_256_zero();
    ch128_256_raw s3; s3.lo=s3.hi=ch128_256_zero();
    { ch128_word init[2]={ {0,0} }; init[1].lo=len; s3.lo=ch128_256_load(init); }
    do {
        { ch128_256_acc a=ch128_256_azero();
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+0),ch128_256_bc(k->ph+0)),ch128_256_xor(ch128_256_load(p+128),ch128_256_bc(k->ph+1)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+256),ch128_256_bc(k->ph+2)),ch128_256_xor(ch128_256_load(p+384),ch128_256_bc(k->ph+3)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+512),ch128_256_bc(k->ph+4)),ch128_256_xor(ch128_256_load(p+640),ch128_256_bc(k->ph+5)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+768),ch128_256_bc(k->ph+6)),ch128_256_xor(ch128_256_load(p+896),ch128_256_bc(k->ph+7)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1024),ch128_256_bc(k->ph+8)),ch128_256_xor(ch128_256_load(p+1152),ch128_256_bc(k->ph+9)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1280),ch128_256_bc(k->ph+10)),ch128_256_xor(ch128_256_load(p+1408),ch128_256_bc(k->ph+11)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1536),ch128_256_bc(k->ph+12)),ch128_256_xor(ch128_256_load(p+1664),ch128_256_bc(k->ph+13)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1792),ch128_256_bc(k->ph+14)),ch128_256_xor(ch128_256_load(p+1920),ch128_256_bc(k->ph+15)),1);
#if CHAINHASH128_BLOCK_BYTES == 512
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2048),ch128_256_bc(k->ph+16)),ch128_256_xor(ch128_256_load(p+2176),ch128_256_bc(k->ph+17)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2304),ch128_256_bc(k->ph+18)),ch128_256_xor(ch128_256_load(p+2432),ch128_256_bc(k->ph+19)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2560),ch128_256_bc(k->ph+20)),ch128_256_xor(ch128_256_load(p+2688),ch128_256_bc(k->ph+21)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2816),ch128_256_bc(k->ph+22)),ch128_256_xor(ch128_256_load(p+2944),ch128_256_bc(k->ph+23)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3072),ch128_256_bc(k->ph+24)),ch128_256_xor(ch128_256_load(p+3200),ch128_256_bc(k->ph+25)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3328),ch128_256_bc(k->ph+26)),ch128_256_xor(ch128_256_load(p+3456),ch128_256_bc(k->ph+27)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3584),ch128_256_bc(k->ph+28)),ch128_256_xor(ch128_256_load(p+3712),ch128_256_bc(k->ph+29)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3840),ch128_256_bc(k->ph+30)),ch128_256_xor(ch128_256_load(p+3968),ch128_256_bc(k->ph+31)),1);
#endif
          a=ch128_256_accum(a,s0.lo,y,1); a=ch128_256_accum(a,s0.hi,h,1); s0=ch128_256_pack(a,1); }
        { ch128_256_acc a=ch128_256_azero();
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+32),ch128_256_bc(k->ph+0)),ch128_256_xor(ch128_256_load(p+160),ch128_256_bc(k->ph+1)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+288),ch128_256_bc(k->ph+2)),ch128_256_xor(ch128_256_load(p+416),ch128_256_bc(k->ph+3)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+544),ch128_256_bc(k->ph+4)),ch128_256_xor(ch128_256_load(p+672),ch128_256_bc(k->ph+5)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+800),ch128_256_bc(k->ph+6)),ch128_256_xor(ch128_256_load(p+928),ch128_256_bc(k->ph+7)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1056),ch128_256_bc(k->ph+8)),ch128_256_xor(ch128_256_load(p+1184),ch128_256_bc(k->ph+9)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1312),ch128_256_bc(k->ph+10)),ch128_256_xor(ch128_256_load(p+1440),ch128_256_bc(k->ph+11)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1568),ch128_256_bc(k->ph+12)),ch128_256_xor(ch128_256_load(p+1696),ch128_256_bc(k->ph+13)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1824),ch128_256_bc(k->ph+14)),ch128_256_xor(ch128_256_load(p+1952),ch128_256_bc(k->ph+15)),1);
#if CHAINHASH128_BLOCK_BYTES == 512
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2080),ch128_256_bc(k->ph+16)),ch128_256_xor(ch128_256_load(p+2208),ch128_256_bc(k->ph+17)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2336),ch128_256_bc(k->ph+18)),ch128_256_xor(ch128_256_load(p+2464),ch128_256_bc(k->ph+19)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2592),ch128_256_bc(k->ph+20)),ch128_256_xor(ch128_256_load(p+2720),ch128_256_bc(k->ph+21)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2848),ch128_256_bc(k->ph+22)),ch128_256_xor(ch128_256_load(p+2976),ch128_256_bc(k->ph+23)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3104),ch128_256_bc(k->ph+24)),ch128_256_xor(ch128_256_load(p+3232),ch128_256_bc(k->ph+25)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3360),ch128_256_bc(k->ph+26)),ch128_256_xor(ch128_256_load(p+3488),ch128_256_bc(k->ph+27)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3616),ch128_256_bc(k->ph+28)),ch128_256_xor(ch128_256_load(p+3744),ch128_256_bc(k->ph+29)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3872),ch128_256_bc(k->ph+30)),ch128_256_xor(ch128_256_load(p+4000),ch128_256_bc(k->ph+31)),1);
#endif
          a=ch128_256_accum(a,s1.lo,y,1); a=ch128_256_accum(a,s1.hi,h,1); s1=ch128_256_pack(a,1); }
        { ch128_256_acc a=ch128_256_azero();
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+64),ch128_256_bc(k->ph+0)),ch128_256_xor(ch128_256_load(p+192),ch128_256_bc(k->ph+1)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+320),ch128_256_bc(k->ph+2)),ch128_256_xor(ch128_256_load(p+448),ch128_256_bc(k->ph+3)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+576),ch128_256_bc(k->ph+4)),ch128_256_xor(ch128_256_load(p+704),ch128_256_bc(k->ph+5)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+832),ch128_256_bc(k->ph+6)),ch128_256_xor(ch128_256_load(p+960),ch128_256_bc(k->ph+7)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1088),ch128_256_bc(k->ph+8)),ch128_256_xor(ch128_256_load(p+1216),ch128_256_bc(k->ph+9)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1344),ch128_256_bc(k->ph+10)),ch128_256_xor(ch128_256_load(p+1472),ch128_256_bc(k->ph+11)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1600),ch128_256_bc(k->ph+12)),ch128_256_xor(ch128_256_load(p+1728),ch128_256_bc(k->ph+13)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1856),ch128_256_bc(k->ph+14)),ch128_256_xor(ch128_256_load(p+1984),ch128_256_bc(k->ph+15)),1);
#if CHAINHASH128_BLOCK_BYTES == 512
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2112),ch128_256_bc(k->ph+16)),ch128_256_xor(ch128_256_load(p+2240),ch128_256_bc(k->ph+17)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2368),ch128_256_bc(k->ph+18)),ch128_256_xor(ch128_256_load(p+2496),ch128_256_bc(k->ph+19)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2624),ch128_256_bc(k->ph+20)),ch128_256_xor(ch128_256_load(p+2752),ch128_256_bc(k->ph+21)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2880),ch128_256_bc(k->ph+22)),ch128_256_xor(ch128_256_load(p+3008),ch128_256_bc(k->ph+23)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3136),ch128_256_bc(k->ph+24)),ch128_256_xor(ch128_256_load(p+3264),ch128_256_bc(k->ph+25)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3392),ch128_256_bc(k->ph+26)),ch128_256_xor(ch128_256_load(p+3520),ch128_256_bc(k->ph+27)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3648),ch128_256_bc(k->ph+28)),ch128_256_xor(ch128_256_load(p+3776),ch128_256_bc(k->ph+29)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3904),ch128_256_bc(k->ph+30)),ch128_256_xor(ch128_256_load(p+4032),ch128_256_bc(k->ph+31)),1);
#endif
          a=ch128_256_accum(a,s2.lo,y,1); a=ch128_256_accum(a,s2.hi,h,1); s2=ch128_256_pack(a,1); }
        { ch128_256_acc a=ch128_256_azero();
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+96),ch128_256_bc(k->ph+0)),ch128_256_xor(ch128_256_load(p+224),ch128_256_bc(k->ph+1)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+352),ch128_256_bc(k->ph+2)),ch128_256_xor(ch128_256_load(p+480),ch128_256_bc(k->ph+3)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+608),ch128_256_bc(k->ph+4)),ch128_256_xor(ch128_256_load(p+736),ch128_256_bc(k->ph+5)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+864),ch128_256_bc(k->ph+6)),ch128_256_xor(ch128_256_load(p+992),ch128_256_bc(k->ph+7)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1120),ch128_256_bc(k->ph+8)),ch128_256_xor(ch128_256_load(p+1248),ch128_256_bc(k->ph+9)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1376),ch128_256_bc(k->ph+10)),ch128_256_xor(ch128_256_load(p+1504),ch128_256_bc(k->ph+11)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1632),ch128_256_bc(k->ph+12)),ch128_256_xor(ch128_256_load(p+1760),ch128_256_bc(k->ph+13)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+1888),ch128_256_bc(k->ph+14)),ch128_256_xor(ch128_256_load(p+2016),ch128_256_bc(k->ph+15)),1);
#if CHAINHASH128_BLOCK_BYTES == 512
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2144),ch128_256_bc(k->ph+16)),ch128_256_xor(ch128_256_load(p+2272),ch128_256_bc(k->ph+17)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2400),ch128_256_bc(k->ph+18)),ch128_256_xor(ch128_256_load(p+2528),ch128_256_bc(k->ph+19)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2656),ch128_256_bc(k->ph+20)),ch128_256_xor(ch128_256_load(p+2784),ch128_256_bc(k->ph+21)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+2912),ch128_256_bc(k->ph+22)),ch128_256_xor(ch128_256_load(p+3040),ch128_256_bc(k->ph+23)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3168),ch128_256_bc(k->ph+24)),ch128_256_xor(ch128_256_load(p+3296),ch128_256_bc(k->ph+25)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3424),ch128_256_bc(k->ph+26)),ch128_256_xor(ch128_256_load(p+3552),ch128_256_bc(k->ph+27)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3680),ch128_256_bc(k->ph+28)),ch128_256_xor(ch128_256_load(p+3808),ch128_256_bc(k->ph+29)),1);
          a=ch128_256_accum(a,ch128_256_xor(ch128_256_load(p+3936),ch128_256_bc(k->ph+30)),ch128_256_xor(ch128_256_load(p+4064),ch128_256_bc(k->ph+31)),1);
#endif
          a=ch128_256_accum(a,s3.lo,y,1); a=ch128_256_accum(a,s3.hi,h,1); s3=ch128_256_pack(a,1); }
        p+=CH128_REGION;
    } while(--regions);
    { ch128_raw acc={{0,0},{0,0}}; ch128_word lo[8],hi[8]; unsigned j;
      ch128_256_store(lo+0,s0.lo); ch128_256_store(hi+0,s0.hi);
      ch128_256_store(lo+2,s1.lo); ch128_256_store(hi+2,s1.hi);
      ch128_256_store(lo+4,s2.lo); ch128_256_store(hi+4,s2.hi);
      ch128_256_store(lo+6,s3.lo); ch128_256_store(hi+6,s3.hi);
      for(j=0;j<8;j++) { acc=ch128_rxor(acc,ch128_prod(lo[j],k->yp[7-j],1,1)); acc=ch128_rxor(acc,ch128_prod(hi[j],k->yh[7-j],1,1)); }
      return ch128_reduce(acc); }
}
#endif

#ifdef CH128_X86
CH128_T512 static void ch128_512_region(const chainhash128_key *k,const uint8_t *p,ch128_raw out[8],int school) {
    unsigned j,c; for(j=0;j<8;j+=4) { ch128_512_acc a=ch128_512_azero(); ch128_512_raw r;
        for(c=0;c<CH128_CHUNKS;c++) a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+256*c+16*j),ch128_512_bc(k->ph+2*c)),ch128_512_xor(ch128_512_load(p+256*c+16*j+128),ch128_512_bc(k->ph+2*c+1)),school);
        r=ch128_512_pack(a,school); { ch128_word lo[4],hi[4]; unsigned t; ch128_512_store(lo,r.lo); ch128_512_store(hi,r.hi); for(t=0;t<4;t++) { out[j+t].lo=lo[t]; out[j+t].hi=hi[t]; } }
    }
}
CH128_T512 static ch128_word ch128_512_bulk0(const chainhash128_key *k,const uint8_t *p,size_t regions,size_t len) {
    const __m512i y=ch128_512_bc(k->yp+4),h=ch128_512_bc(k->yh+4);
    ch128_512_raw state; ch128_word init[4]={{0,0}}; init[3].lo=len; state.lo=ch128_512_load(init);state.hi=ch128_512_zero();
    do {
      { ch128_512_acc a=ch128_512_azero();
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+0),ch128_512_bc(k->ph+0)),ch128_512_xor(ch128_512_load(p+128),ch128_512_bc(k->ph+1)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+256),ch128_512_bc(k->ph+2)),ch128_512_xor(ch128_512_load(p+384),ch128_512_bc(k->ph+3)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+512),ch128_512_bc(k->ph+4)),ch128_512_xor(ch128_512_load(p+640),ch128_512_bc(k->ph+5)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+768),ch128_512_bc(k->ph+6)),ch128_512_xor(ch128_512_load(p+896),ch128_512_bc(k->ph+7)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+1024),ch128_512_bc(k->ph+8)),ch128_512_xor(ch128_512_load(p+1152),ch128_512_bc(k->ph+9)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+1280),ch128_512_bc(k->ph+10)),ch128_512_xor(ch128_512_load(p+1408),ch128_512_bc(k->ph+11)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+1536),ch128_512_bc(k->ph+12)),ch128_512_xor(ch128_512_load(p+1664),ch128_512_bc(k->ph+13)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+1792),ch128_512_bc(k->ph+14)),ch128_512_xor(ch128_512_load(p+1920),ch128_512_bc(k->ph+15)),0);
#if CHAINHASH128_BLOCK_BYTES == 512
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+2048),ch128_512_bc(k->ph+16)),ch128_512_xor(ch128_512_load(p+2176),ch128_512_bc(k->ph+17)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+2304),ch128_512_bc(k->ph+18)),ch128_512_xor(ch128_512_load(p+2432),ch128_512_bc(k->ph+19)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+2560),ch128_512_bc(k->ph+20)),ch128_512_xor(ch128_512_load(p+2688),ch128_512_bc(k->ph+21)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+2816),ch128_512_bc(k->ph+22)),ch128_512_xor(ch128_512_load(p+2944),ch128_512_bc(k->ph+23)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+3072),ch128_512_bc(k->ph+24)),ch128_512_xor(ch128_512_load(p+3200),ch128_512_bc(k->ph+25)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+3328),ch128_512_bc(k->ph+26)),ch128_512_xor(ch128_512_load(p+3456),ch128_512_bc(k->ph+27)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+3584),ch128_512_bc(k->ph+28)),ch128_512_xor(ch128_512_load(p+3712),ch128_512_bc(k->ph+29)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+3840),ch128_512_bc(k->ph+30)),ch128_512_xor(ch128_512_load(p+3968),ch128_512_bc(k->ph+31)),0);
#endif
        a=ch128_512_accum(a,state.lo,y,0);a=ch128_512_accum(a,state.hi,h,0);state=ch128_512_pack(a,0); }
      { ch128_512_acc a=ch128_512_azero();
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+64),ch128_512_bc(k->ph+0)),ch128_512_xor(ch128_512_load(p+192),ch128_512_bc(k->ph+1)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+320),ch128_512_bc(k->ph+2)),ch128_512_xor(ch128_512_load(p+448),ch128_512_bc(k->ph+3)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+576),ch128_512_bc(k->ph+4)),ch128_512_xor(ch128_512_load(p+704),ch128_512_bc(k->ph+5)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+832),ch128_512_bc(k->ph+6)),ch128_512_xor(ch128_512_load(p+960),ch128_512_bc(k->ph+7)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+1088),ch128_512_bc(k->ph+8)),ch128_512_xor(ch128_512_load(p+1216),ch128_512_bc(k->ph+9)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+1344),ch128_512_bc(k->ph+10)),ch128_512_xor(ch128_512_load(p+1472),ch128_512_bc(k->ph+11)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+1600),ch128_512_bc(k->ph+12)),ch128_512_xor(ch128_512_load(p+1728),ch128_512_bc(k->ph+13)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+1856),ch128_512_bc(k->ph+14)),ch128_512_xor(ch128_512_load(p+1984),ch128_512_bc(k->ph+15)),0);
#if CHAINHASH128_BLOCK_BYTES == 512
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+2112),ch128_512_bc(k->ph+16)),ch128_512_xor(ch128_512_load(p+2240),ch128_512_bc(k->ph+17)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+2368),ch128_512_bc(k->ph+18)),ch128_512_xor(ch128_512_load(p+2496),ch128_512_bc(k->ph+19)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+2624),ch128_512_bc(k->ph+20)),ch128_512_xor(ch128_512_load(p+2752),ch128_512_bc(k->ph+21)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+2880),ch128_512_bc(k->ph+22)),ch128_512_xor(ch128_512_load(p+3008),ch128_512_bc(k->ph+23)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+3136),ch128_512_bc(k->ph+24)),ch128_512_xor(ch128_512_load(p+3264),ch128_512_bc(k->ph+25)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+3392),ch128_512_bc(k->ph+26)),ch128_512_xor(ch128_512_load(p+3520),ch128_512_bc(k->ph+27)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+3648),ch128_512_bc(k->ph+28)),ch128_512_xor(ch128_512_load(p+3776),ch128_512_bc(k->ph+29)),0);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+3904),ch128_512_bc(k->ph+30)),ch128_512_xor(ch128_512_load(p+4032),ch128_512_bc(k->ph+31)),0);
#endif
        a=ch128_512_accum(a,state.lo,y,0);a=ch128_512_accum(a,state.hi,h,0);state=ch128_512_pack(a,0); }
      p+=CH128_REGION;
    } while(--regions);
    { ch128_raw acc={{0,0},{0,0}}; ch128_word lo[4],hi[4]; unsigned j;
      ch128_512_store(lo,state.lo);ch128_512_store(hi,state.hi);
      for(j=0;j<4;j++) {acc=ch128_rxor(acc,ch128_prod(lo[j],k->yp[3-j],1,0));acc=ch128_rxor(acc,ch128_prod(hi[j],k->yh[3-j],1,0));}return ch128_reduce(acc);
    }
}
CH128_T512 static ch128_word ch128_512_bulk1(const chainhash128_key *k,const uint8_t *p,size_t regions,size_t len) {
    const __m512i y=ch128_512_bc(k->yp+4),h=ch128_512_bc(k->yh+4);
    ch128_512_raw state; ch128_word init[4]={{0,0}}; init[3].lo=len; state.lo=ch128_512_load(init);state.hi=ch128_512_zero();
    do {
      { ch128_512_acc a=ch128_512_azero();
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+0),ch128_512_bc(k->ph+0)),ch128_512_xor(ch128_512_load(p+128),ch128_512_bc(k->ph+1)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+256),ch128_512_bc(k->ph+2)),ch128_512_xor(ch128_512_load(p+384),ch128_512_bc(k->ph+3)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+512),ch128_512_bc(k->ph+4)),ch128_512_xor(ch128_512_load(p+640),ch128_512_bc(k->ph+5)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+768),ch128_512_bc(k->ph+6)),ch128_512_xor(ch128_512_load(p+896),ch128_512_bc(k->ph+7)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+1024),ch128_512_bc(k->ph+8)),ch128_512_xor(ch128_512_load(p+1152),ch128_512_bc(k->ph+9)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+1280),ch128_512_bc(k->ph+10)),ch128_512_xor(ch128_512_load(p+1408),ch128_512_bc(k->ph+11)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+1536),ch128_512_bc(k->ph+12)),ch128_512_xor(ch128_512_load(p+1664),ch128_512_bc(k->ph+13)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+1792),ch128_512_bc(k->ph+14)),ch128_512_xor(ch128_512_load(p+1920),ch128_512_bc(k->ph+15)),1);
#if CHAINHASH128_BLOCK_BYTES == 512
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+2048),ch128_512_bc(k->ph+16)),ch128_512_xor(ch128_512_load(p+2176),ch128_512_bc(k->ph+17)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+2304),ch128_512_bc(k->ph+18)),ch128_512_xor(ch128_512_load(p+2432),ch128_512_bc(k->ph+19)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+2560),ch128_512_bc(k->ph+20)),ch128_512_xor(ch128_512_load(p+2688),ch128_512_bc(k->ph+21)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+2816),ch128_512_bc(k->ph+22)),ch128_512_xor(ch128_512_load(p+2944),ch128_512_bc(k->ph+23)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+3072),ch128_512_bc(k->ph+24)),ch128_512_xor(ch128_512_load(p+3200),ch128_512_bc(k->ph+25)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+3328),ch128_512_bc(k->ph+26)),ch128_512_xor(ch128_512_load(p+3456),ch128_512_bc(k->ph+27)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+3584),ch128_512_bc(k->ph+28)),ch128_512_xor(ch128_512_load(p+3712),ch128_512_bc(k->ph+29)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+3840),ch128_512_bc(k->ph+30)),ch128_512_xor(ch128_512_load(p+3968),ch128_512_bc(k->ph+31)),1);
#endif
        a=ch128_512_accum(a,state.lo,y,1);a=ch128_512_accum(a,state.hi,h,1);state=ch128_512_pack(a,1); }
      { ch128_512_acc a=ch128_512_azero();
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+64),ch128_512_bc(k->ph+0)),ch128_512_xor(ch128_512_load(p+192),ch128_512_bc(k->ph+1)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+320),ch128_512_bc(k->ph+2)),ch128_512_xor(ch128_512_load(p+448),ch128_512_bc(k->ph+3)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+576),ch128_512_bc(k->ph+4)),ch128_512_xor(ch128_512_load(p+704),ch128_512_bc(k->ph+5)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+832),ch128_512_bc(k->ph+6)),ch128_512_xor(ch128_512_load(p+960),ch128_512_bc(k->ph+7)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+1088),ch128_512_bc(k->ph+8)),ch128_512_xor(ch128_512_load(p+1216),ch128_512_bc(k->ph+9)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+1344),ch128_512_bc(k->ph+10)),ch128_512_xor(ch128_512_load(p+1472),ch128_512_bc(k->ph+11)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+1600),ch128_512_bc(k->ph+12)),ch128_512_xor(ch128_512_load(p+1728),ch128_512_bc(k->ph+13)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+1856),ch128_512_bc(k->ph+14)),ch128_512_xor(ch128_512_load(p+1984),ch128_512_bc(k->ph+15)),1);
#if CHAINHASH128_BLOCK_BYTES == 512
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+2112),ch128_512_bc(k->ph+16)),ch128_512_xor(ch128_512_load(p+2240),ch128_512_bc(k->ph+17)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+2368),ch128_512_bc(k->ph+18)),ch128_512_xor(ch128_512_load(p+2496),ch128_512_bc(k->ph+19)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+2624),ch128_512_bc(k->ph+20)),ch128_512_xor(ch128_512_load(p+2752),ch128_512_bc(k->ph+21)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+2880),ch128_512_bc(k->ph+22)),ch128_512_xor(ch128_512_load(p+3008),ch128_512_bc(k->ph+23)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+3136),ch128_512_bc(k->ph+24)),ch128_512_xor(ch128_512_load(p+3264),ch128_512_bc(k->ph+25)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+3392),ch128_512_bc(k->ph+26)),ch128_512_xor(ch128_512_load(p+3520),ch128_512_bc(k->ph+27)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+3648),ch128_512_bc(k->ph+28)),ch128_512_xor(ch128_512_load(p+3776),ch128_512_bc(k->ph+29)),1);
        a=ch128_512_accum(a,ch128_512_xor(ch128_512_load(p+3904),ch128_512_bc(k->ph+30)),ch128_512_xor(ch128_512_load(p+4032),ch128_512_bc(k->ph+31)),1);
#endif
        a=ch128_512_accum(a,state.lo,y,1);a=ch128_512_accum(a,state.hi,h,1);state=ch128_512_pack(a,1); }
      p+=CH128_REGION;
    } while(--regions);
    { ch128_raw acc={{0,0},{0,0}}; ch128_word lo[4],hi[4]; unsigned j;
      ch128_512_store(lo,state.lo);ch128_512_store(hi,state.hi);
      for(j=0;j<4;j++) {acc=ch128_rxor(acc,ch128_prod(lo[j],k->yp[3-j],1,1));acc=ch128_rxor(acc,ch128_prod(hi[j],k->yh[3-j],1,1));}return ch128_reduce(acc);
    }
}
#endif

#ifdef CH128_ARM
static void ch128_n_region(const chainhash128_key *k,const uint8_t *p,ch128_raw out[8],int school) {
    unsigned j,c; for(j=0;j<8;j+=1) { ch128_n_acc a=ch128_n_azero(); ch128_n_raw r;
        for(c=0;c<CH128_CHUNKS;c++) a=ch128_n_accum(a,ch128_n_xor(ch128_n_load(p+256*c+16*j),ch128_n_bc(k->ph+2*c)),ch128_n_xor(ch128_n_load(p+256*c+16*j+128),ch128_n_bc(k->ph+2*c+1)),school);
        r=ch128_n_pack(a,school); { ch128_word lo[1],hi[1]; unsigned t; ch128_n_store(lo,r.lo); ch128_n_store(hi,r.hi); for(t=0;t<1;t++) { out[j+t].lo=lo[t]; out[j+t].hi=hi[t]; } }
    }
}
/* Fixed-register PMULL instruction templates. STEP consumes four comb
 * pairs and advances the two half pointers by one 256-byte chunk. FOLD
 * advances the four raw states by y^4. Expanded instructions are audited
 * in audit/; these macros introduce no calls or runtime choices. */
#if defined(__ARM_FEATURE_SHA3)
#define CH128_NX3(D,A,B,C) "eor3 v" #D ".16b,v" #A ".16b,v" #B ".16b,v" #C ".16b\n\t"
#else
#define CH128_NX3(D,A,B,C) "eor v" #D ".16b,v" #A ".16b,v" #B ".16b\n\t" \
                              "eor v" #D ".16b,v" #D ".16b,v" #C ".16b\n\t"
#endif
#define CH128_NPH0 \
      "ld1 {v28.2d,v29.2d},[x11],#32\n\t" \
      "ld1 {v20.2d,v21.2d,v22.2d,v23.2d},[x9]\n\t" \
      "ld1 {v24.2d,v25.2d,v26.2d,v27.2d},[x10]\n\t" \
      "eor v20.16b,v20.16b,v28.16b\n\t" \
      "eor v24.16b,v24.16b,v29.16b\n\t" \
      "pmull v30.1q,v20.1d,v24.1d\n\t" \
      "eor v8.16b,v8.16b,v30.16b\n\t" \
      "pmull2 v30.1q,v20.2d,v24.2d\n\t" \
      "eor v9.16b,v9.16b,v30.16b\n\t" \
      "ext v30.16b,v20.16b,v20.16b,#8\n\t" \
      "ext v31.16b,v24.16b,v24.16b,#8\n\t" \
      "eor v30.16b,v30.16b,v20.16b\n\t" \
      "eor v31.16b,v31.16b,v24.16b\n\t" \
      "pmull v30.1q,v30.1d,v31.1d\n\t" \
      "eor v10.16b,v10.16b,v30.16b\n\t" \
      "eor v21.16b,v21.16b,v28.16b\n\t" \
      "eor v25.16b,v25.16b,v29.16b\n\t" \
      "pmull v30.1q,v21.1d,v25.1d\n\t" \
      "eor v11.16b,v11.16b,v30.16b\n\t" \
      "pmull2 v30.1q,v21.2d,v25.2d\n\t" \
      "eor v12.16b,v12.16b,v30.16b\n\t" \
      "ext v30.16b,v21.16b,v21.16b,#8\n\t" \
      "ext v31.16b,v25.16b,v25.16b,#8\n\t" \
      "eor v30.16b,v30.16b,v21.16b\n\t" \
      "eor v31.16b,v31.16b,v25.16b\n\t" \
      "pmull v30.1q,v30.1d,v31.1d\n\t" \
      "eor v13.16b,v13.16b,v30.16b\n\t" \
      "eor v22.16b,v22.16b,v28.16b\n\t" \
      "eor v26.16b,v26.16b,v29.16b\n\t" \
      "pmull v30.1q,v22.1d,v26.1d\n\t" \
      "eor v14.16b,v14.16b,v30.16b\n\t" \
      "pmull2 v30.1q,v22.2d,v26.2d\n\t" \
      "eor v15.16b,v15.16b,v30.16b\n\t" \
      "ext v30.16b,v22.16b,v22.16b,#8\n\t" \
      "ext v31.16b,v26.16b,v26.16b,#8\n\t" \
      "eor v30.16b,v30.16b,v22.16b\n\t" \
      "eor v31.16b,v31.16b,v26.16b\n\t" \
      "pmull v30.1q,v30.1d,v31.1d\n\t" \
      "eor v16.16b,v16.16b,v30.16b\n\t" \
      "eor v23.16b,v23.16b,v28.16b\n\t" \
      "eor v27.16b,v27.16b,v29.16b\n\t" \
      "pmull v30.1q,v23.1d,v27.1d\n\t" \
      "eor v17.16b,v17.16b,v30.16b\n\t" \
      "pmull2 v30.1q,v23.2d,v27.2d\n\t" \
      "eor v18.16b,v18.16b,v30.16b\n\t" \
      "ext v30.16b,v23.16b,v23.16b,#8\n\t" \
      "ext v31.16b,v27.16b,v27.16b,#8\n\t" \
      "eor v30.16b,v30.16b,v23.16b\n\t" \
      "eor v31.16b,v31.16b,v27.16b\n\t" \
      "pmull v30.1q,v30.1d,v31.1d\n\t" \
      "eor v19.16b,v19.16b,v30.16b\n\t"
#define CH128_NSTEP0 \
      CH128_NPH0 \
      "add x9,x9,#256\n\t" \
      "add x10,x10,#256\n\t"
#define CH128_NFOLD0 \
      "ld1 {v28.2d},[%[yp]]\n\t" \
      "ld1 {v29.2d},[%[yh]]\n\t" \
      "pmull v30.1q,v0.1d,v28.1d\n\t" \
      "eor v8.16b,v8.16b,v30.16b\n\t" \
      "pmull2 v30.1q,v0.2d,v28.2d\n\t" \
      "eor v9.16b,v9.16b,v30.16b\n\t" \
      "ext v30.16b,v0.16b,v0.16b,#8\n\t" \
      "ext v31.16b,v28.16b,v28.16b,#8\n\t" \
      "eor v30.16b,v30.16b,v0.16b\n\t" \
      "eor v31.16b,v31.16b,v28.16b\n\t" \
      "pmull v30.1q,v30.1d,v31.1d\n\t" \
      "eor v10.16b,v10.16b,v30.16b\n\t" \
      "pmull v30.1q,v1.1d,v29.1d\n\t" \
      "eor v8.16b,v8.16b,v30.16b\n\t" \
      "pmull2 v30.1q,v1.2d,v29.2d\n\t" \
      "eor v9.16b,v9.16b,v30.16b\n\t" \
      "ext v30.16b,v1.16b,v1.16b,#8\n\t" \
      "ext v31.16b,v29.16b,v29.16b,#8\n\t" \
      "eor v30.16b,v30.16b,v1.16b\n\t" \
      "eor v31.16b,v31.16b,v29.16b\n\t" \
      "pmull v30.1q,v30.1d,v31.1d\n\t" \
      "eor v10.16b,v10.16b,v30.16b\n\t" \
      CH128_NX3(10,10,8,9) \
      "movi v31.2d,#0\n\t" \
      "ext v30.16b,v31.16b,v10.16b,#8\n\t" \
      "eor v0.16b,v8.16b,v30.16b\n\t" \
      "ext v30.16b,v10.16b,v31.16b,#8\n\t" \
      "eor v1.16b,v9.16b,v30.16b\n\t" \
      "pmull v30.1q,v2.1d,v28.1d\n\t" \
      "eor v11.16b,v11.16b,v30.16b\n\t" \
      "pmull2 v30.1q,v2.2d,v28.2d\n\t" \
      "eor v12.16b,v12.16b,v30.16b\n\t" \
      "ext v30.16b,v2.16b,v2.16b,#8\n\t" \
      "ext v31.16b,v28.16b,v28.16b,#8\n\t" \
      "eor v30.16b,v30.16b,v2.16b\n\t" \
      "eor v31.16b,v31.16b,v28.16b\n\t" \
      "pmull v30.1q,v30.1d,v31.1d\n\t" \
      "eor v13.16b,v13.16b,v30.16b\n\t" \
      "pmull v30.1q,v3.1d,v29.1d\n\t" \
      "eor v11.16b,v11.16b,v30.16b\n\t" \
      "pmull2 v30.1q,v3.2d,v29.2d\n\t" \
      "eor v12.16b,v12.16b,v30.16b\n\t" \
      "ext v30.16b,v3.16b,v3.16b,#8\n\t" \
      "ext v31.16b,v29.16b,v29.16b,#8\n\t" \
      "eor v30.16b,v30.16b,v3.16b\n\t" \
      "eor v31.16b,v31.16b,v29.16b\n\t" \
      "pmull v30.1q,v30.1d,v31.1d\n\t" \
      "eor v13.16b,v13.16b,v30.16b\n\t" \
      CH128_NX3(13,13,11,12) \
      "movi v31.2d,#0\n\t" \
      "ext v30.16b,v31.16b,v13.16b,#8\n\t" \
      "eor v2.16b,v11.16b,v30.16b\n\t" \
      "ext v30.16b,v13.16b,v31.16b,#8\n\t" \
      "eor v3.16b,v12.16b,v30.16b\n\t" \
      "pmull v30.1q,v4.1d,v28.1d\n\t" \
      "eor v14.16b,v14.16b,v30.16b\n\t" \
      "pmull2 v30.1q,v4.2d,v28.2d\n\t" \
      "eor v15.16b,v15.16b,v30.16b\n\t" \
      "ext v30.16b,v4.16b,v4.16b,#8\n\t" \
      "ext v31.16b,v28.16b,v28.16b,#8\n\t" \
      "eor v30.16b,v30.16b,v4.16b\n\t" \
      "eor v31.16b,v31.16b,v28.16b\n\t" \
      "pmull v30.1q,v30.1d,v31.1d\n\t" \
      "eor v16.16b,v16.16b,v30.16b\n\t" \
      "pmull v30.1q,v5.1d,v29.1d\n\t" \
      "eor v14.16b,v14.16b,v30.16b\n\t" \
      "pmull2 v30.1q,v5.2d,v29.2d\n\t" \
      "eor v15.16b,v15.16b,v30.16b\n\t" \
      "ext v30.16b,v5.16b,v5.16b,#8\n\t" \
      "ext v31.16b,v29.16b,v29.16b,#8\n\t" \
      "eor v30.16b,v30.16b,v5.16b\n\t" \
      "eor v31.16b,v31.16b,v29.16b\n\t" \
      "pmull v30.1q,v30.1d,v31.1d\n\t" \
      "eor v16.16b,v16.16b,v30.16b\n\t" \
      CH128_NX3(16,16,14,15) \
      "movi v31.2d,#0\n\t" \
      "ext v30.16b,v31.16b,v16.16b,#8\n\t" \
      "eor v4.16b,v14.16b,v30.16b\n\t" \
      "ext v30.16b,v16.16b,v31.16b,#8\n\t" \
      "eor v5.16b,v15.16b,v30.16b\n\t" \
      "pmull v30.1q,v6.1d,v28.1d\n\t" \
      "eor v17.16b,v17.16b,v30.16b\n\t" \
      "pmull2 v30.1q,v6.2d,v28.2d\n\t" \
      "eor v18.16b,v18.16b,v30.16b\n\t" \
      "ext v30.16b,v6.16b,v6.16b,#8\n\t" \
      "ext v31.16b,v28.16b,v28.16b,#8\n\t" \
      "eor v30.16b,v30.16b,v6.16b\n\t" \
      "eor v31.16b,v31.16b,v28.16b\n\t" \
      "pmull v30.1q,v30.1d,v31.1d\n\t" \
      "eor v19.16b,v19.16b,v30.16b\n\t" \
      "pmull v30.1q,v7.1d,v29.1d\n\t" \
      "eor v17.16b,v17.16b,v30.16b\n\t" \
      "pmull2 v30.1q,v7.2d,v29.2d\n\t" \
      "eor v18.16b,v18.16b,v30.16b\n\t" \
      "ext v30.16b,v7.16b,v7.16b,#8\n\t" \
      "ext v31.16b,v29.16b,v29.16b,#8\n\t" \
      "eor v30.16b,v30.16b,v7.16b\n\t" \
      "eor v31.16b,v31.16b,v29.16b\n\t" \
      "pmull v30.1q,v30.1d,v31.1d\n\t" \
      "eor v19.16b,v19.16b,v30.16b\n\t" \
      CH128_NX3(19,19,17,18) \
      "movi v31.2d,#0\n\t" \
      "ext v30.16b,v31.16b,v19.16b,#8\n\t" \
      "eor v6.16b,v17.16b,v30.16b\n\t" \
      "ext v30.16b,v19.16b,v31.16b,#8\n\t" \
      "eor v7.16b,v18.16b,v30.16b\n\t"
#define CH128_NPH1 \
      "ld1 {v28.2d,v29.2d},[x11],#32\n\t" \
      "ld1 {v20.2d,v21.2d,v22.2d,v23.2d},[x9]\n\t" \
      "ld1 {v24.2d,v25.2d,v26.2d,v27.2d},[x10]\n\t" \
      "eor v20.16b,v20.16b,v28.16b\n\t" \
      "eor v24.16b,v24.16b,v29.16b\n\t" \
      "pmull v30.1q,v20.1d,v24.1d\n\t" \
      "eor v8.16b,v8.16b,v30.16b\n\t" \
      "pmull2 v30.1q,v20.2d,v24.2d\n\t" \
      "eor v9.16b,v9.16b,v30.16b\n\t" \
      "ext v30.16b,v20.16b,v20.16b,#8\n\t" \
      "ext v31.16b,v24.16b,v24.16b,#8\n\t" \
      "pmull v30.1q,v30.1d,v24.1d\n\t" \
      "pmull v31.1q,v20.1d,v31.1d\n\t" \
      CH128_NX3(10,10,30,31) \
      "eor v21.16b,v21.16b,v28.16b\n\t" \
      "eor v25.16b,v25.16b,v29.16b\n\t" \
      "pmull v30.1q,v21.1d,v25.1d\n\t" \
      "eor v11.16b,v11.16b,v30.16b\n\t" \
      "pmull2 v30.1q,v21.2d,v25.2d\n\t" \
      "eor v12.16b,v12.16b,v30.16b\n\t" \
      "ext v30.16b,v21.16b,v21.16b,#8\n\t" \
      "ext v31.16b,v25.16b,v25.16b,#8\n\t" \
      "pmull v30.1q,v30.1d,v25.1d\n\t" \
      "pmull v31.1q,v21.1d,v31.1d\n\t" \
      CH128_NX3(13,13,30,31) \
      "eor v22.16b,v22.16b,v28.16b\n\t" \
      "eor v26.16b,v26.16b,v29.16b\n\t" \
      "pmull v30.1q,v22.1d,v26.1d\n\t" \
      "eor v14.16b,v14.16b,v30.16b\n\t" \
      "pmull2 v30.1q,v22.2d,v26.2d\n\t" \
      "eor v15.16b,v15.16b,v30.16b\n\t" \
      "ext v30.16b,v22.16b,v22.16b,#8\n\t" \
      "ext v31.16b,v26.16b,v26.16b,#8\n\t" \
      "pmull v30.1q,v30.1d,v26.1d\n\t" \
      "pmull v31.1q,v22.1d,v31.1d\n\t" \
      CH128_NX3(16,16,30,31) \
      "eor v23.16b,v23.16b,v28.16b\n\t" \
      "eor v27.16b,v27.16b,v29.16b\n\t" \
      "pmull v30.1q,v23.1d,v27.1d\n\t" \
      "eor v17.16b,v17.16b,v30.16b\n\t" \
      "pmull2 v30.1q,v23.2d,v27.2d\n\t" \
      "eor v18.16b,v18.16b,v30.16b\n\t" \
      "ext v30.16b,v23.16b,v23.16b,#8\n\t" \
      "ext v31.16b,v27.16b,v27.16b,#8\n\t" \
      "pmull v30.1q,v30.1d,v27.1d\n\t" \
      "pmull v31.1q,v23.1d,v31.1d\n\t" \
      CH128_NX3(19,19,30,31)
#define CH128_NSTEP1 \
      CH128_NPH1 \
      "add x9,x9,#256\n\t" \
      "add x10,x10,#256\n\t"
#define CH128_NFOLD1 \
      "ld1 {v28.2d},[%[yp]]\n\t" \
      "ld1 {v29.2d},[%[yh]]\n\t" \
      "pmull v30.1q,v0.1d,v28.1d\n\t" \
      "eor v8.16b,v8.16b,v30.16b\n\t" \
      "pmull2 v30.1q,v0.2d,v28.2d\n\t" \
      "eor v9.16b,v9.16b,v30.16b\n\t" \
      "ext v30.16b,v0.16b,v0.16b,#8\n\t" \
      "ext v31.16b,v28.16b,v28.16b,#8\n\t" \
      "pmull v30.1q,v30.1d,v28.1d\n\t" \
      "pmull v31.1q,v0.1d,v31.1d\n\t" \
      CH128_NX3(10,10,30,31) \
      "pmull v30.1q,v1.1d,v29.1d\n\t" \
      "eor v8.16b,v8.16b,v30.16b\n\t" \
      "pmull2 v30.1q,v1.2d,v29.2d\n\t" \
      "eor v9.16b,v9.16b,v30.16b\n\t" \
      "ext v30.16b,v1.16b,v1.16b,#8\n\t" \
      "ext v31.16b,v29.16b,v29.16b,#8\n\t" \
      "pmull v30.1q,v30.1d,v29.1d\n\t" \
      "pmull v31.1q,v1.1d,v31.1d\n\t" \
      CH128_NX3(10,10,30,31) \
      "movi v31.2d,#0\n\t" \
      "ext v30.16b,v31.16b,v10.16b,#8\n\t" \
      "eor v0.16b,v8.16b,v30.16b\n\t" \
      "ext v30.16b,v10.16b,v31.16b,#8\n\t" \
      "eor v1.16b,v9.16b,v30.16b\n\t" \
      "pmull v30.1q,v2.1d,v28.1d\n\t" \
      "eor v11.16b,v11.16b,v30.16b\n\t" \
      "pmull2 v30.1q,v2.2d,v28.2d\n\t" \
      "eor v12.16b,v12.16b,v30.16b\n\t" \
      "ext v30.16b,v2.16b,v2.16b,#8\n\t" \
      "ext v31.16b,v28.16b,v28.16b,#8\n\t" \
      "pmull v30.1q,v30.1d,v28.1d\n\t" \
      "pmull v31.1q,v2.1d,v31.1d\n\t" \
      CH128_NX3(13,13,30,31) \
      "pmull v30.1q,v3.1d,v29.1d\n\t" \
      "eor v11.16b,v11.16b,v30.16b\n\t" \
      "pmull2 v30.1q,v3.2d,v29.2d\n\t" \
      "eor v12.16b,v12.16b,v30.16b\n\t" \
      "ext v30.16b,v3.16b,v3.16b,#8\n\t" \
      "ext v31.16b,v29.16b,v29.16b,#8\n\t" \
      "pmull v30.1q,v30.1d,v29.1d\n\t" \
      "pmull v31.1q,v3.1d,v31.1d\n\t" \
      CH128_NX3(13,13,30,31) \
      "movi v31.2d,#0\n\t" \
      "ext v30.16b,v31.16b,v13.16b,#8\n\t" \
      "eor v2.16b,v11.16b,v30.16b\n\t" \
      "ext v30.16b,v13.16b,v31.16b,#8\n\t" \
      "eor v3.16b,v12.16b,v30.16b\n\t" \
      "pmull v30.1q,v4.1d,v28.1d\n\t" \
      "eor v14.16b,v14.16b,v30.16b\n\t" \
      "pmull2 v30.1q,v4.2d,v28.2d\n\t" \
      "eor v15.16b,v15.16b,v30.16b\n\t" \
      "ext v30.16b,v4.16b,v4.16b,#8\n\t" \
      "ext v31.16b,v28.16b,v28.16b,#8\n\t" \
      "pmull v30.1q,v30.1d,v28.1d\n\t" \
      "pmull v31.1q,v4.1d,v31.1d\n\t" \
      CH128_NX3(16,16,30,31) \
      "pmull v30.1q,v5.1d,v29.1d\n\t" \
      "eor v14.16b,v14.16b,v30.16b\n\t" \
      "pmull2 v30.1q,v5.2d,v29.2d\n\t" \
      "eor v15.16b,v15.16b,v30.16b\n\t" \
      "ext v30.16b,v5.16b,v5.16b,#8\n\t" \
      "ext v31.16b,v29.16b,v29.16b,#8\n\t" \
      "pmull v30.1q,v30.1d,v29.1d\n\t" \
      "pmull v31.1q,v5.1d,v31.1d\n\t" \
      CH128_NX3(16,16,30,31) \
      "movi v31.2d,#0\n\t" \
      "ext v30.16b,v31.16b,v16.16b,#8\n\t" \
      "eor v4.16b,v14.16b,v30.16b\n\t" \
      "ext v30.16b,v16.16b,v31.16b,#8\n\t" \
      "eor v5.16b,v15.16b,v30.16b\n\t" \
      "pmull v30.1q,v6.1d,v28.1d\n\t" \
      "eor v17.16b,v17.16b,v30.16b\n\t" \
      "pmull2 v30.1q,v6.2d,v28.2d\n\t" \
      "eor v18.16b,v18.16b,v30.16b\n\t" \
      "ext v30.16b,v6.16b,v6.16b,#8\n\t" \
      "ext v31.16b,v28.16b,v28.16b,#8\n\t" \
      "pmull v30.1q,v30.1d,v28.1d\n\t" \
      "pmull v31.1q,v6.1d,v31.1d\n\t" \
      CH128_NX3(19,19,30,31) \
      "pmull v30.1q,v7.1d,v29.1d\n\t" \
      "eor v17.16b,v17.16b,v30.16b\n\t" \
      "pmull2 v30.1q,v7.2d,v29.2d\n\t" \
      "eor v18.16b,v18.16b,v30.16b\n\t" \
      "ext v30.16b,v7.16b,v7.16b,#8\n\t" \
      "ext v31.16b,v29.16b,v29.16b,#8\n\t" \
      "pmull v30.1q,v30.1d,v29.1d\n\t" \
      "pmull v31.1q,v7.1d,v31.1d\n\t" \
      CH128_NX3(19,19,30,31) \
      "movi v31.2d,#0\n\t" \
      "ext v30.16b,v31.16b,v19.16b,#8\n\t" \
      "eor v6.16b,v17.16b,v30.16b\n\t" \
      "ext v30.16b,v19.16b,v31.16b,#8\n\t" \
      "eor v7.16b,v18.16b,v30.16b\n\t"
/* Four fixed lazy chains. LD1 lists consume each comb half directly.
 * v0..v7: raw states; v8..v19: three-component block accumulators;
 * v20..v27: four word pairs; v28/v29: keys; v30/v31: scratch.
 * No hot-loop stack spills or vector-to-integer transfers are possible. */
static __attribute__((noinline)) ch128_word ch128_n_bulk0(const chainhash128_key *k,const uint8_t *p,size_t regions,size_t len) {
    ch128_raw state[4],acc={{0,0},{0,0}};uint8_t *out=(uint8_t *)state;unsigned j;
    __asm__ volatile(
      "movi v0.2d,#0\n\t"
      "movi v1.2d,#0\n\t"
      "movi v2.2d,#0\n\t"
      "movi v3.2d,#0\n\t"
      "movi v4.2d,#0\n\t"
      "movi v5.2d,#0\n\t"
      "movi v6.2d,#0\n\t"
      "movi v7.2d,#0\n\t"
      "fmov d6,%[len]\n\t"
      "1:\n\t"
      "movi v8.2d,#0\n\t"
      "movi v9.2d,#0\n\t"
      "movi v10.2d,#0\n\t"
      "movi v11.2d,#0\n\t"
      "movi v12.2d,#0\n\t"
      "movi v13.2d,#0\n\t"
      "movi v14.2d,#0\n\t"
      "movi v15.2d,#0\n\t"
      "movi v16.2d,#0\n\t"
      "movi v17.2d,#0\n\t"
      "movi v18.2d,#0\n\t"
      "movi v19.2d,#0\n\t"
      "add x9,%[p],#0\n\t"
      "add x10,x9,#128\n\t"
      "mov x11,%[key]\n\t"
      CH128_NSTEP0
      CH128_NSTEP0
      CH128_NSTEP0
      CH128_NSTEP0
      CH128_NSTEP0
      CH128_NSTEP0
      CH128_NSTEP0
      CH128_NSTEP0
#if CHAINHASH128_BLOCK_BYTES == 512
      CH128_NSTEP0
      CH128_NSTEP0
      CH128_NSTEP0
      CH128_NSTEP0
      CH128_NSTEP0
      CH128_NSTEP0
      CH128_NSTEP0
      CH128_NPH0
#endif
      CH128_NFOLD0
      "movi v8.2d,#0\n\t"
      "movi v9.2d,#0\n\t"
      "movi v10.2d,#0\n\t"
      "movi v11.2d,#0\n\t"
      "movi v12.2d,#0\n\t"
      "movi v13.2d,#0\n\t"
      "movi v14.2d,#0\n\t"
      "movi v15.2d,#0\n\t"
      "movi v16.2d,#0\n\t"
      "movi v17.2d,#0\n\t"
      "movi v18.2d,#0\n\t"
      "movi v19.2d,#0\n\t"
      "add x9,%[p],#64\n\t"
      "add x10,x9,#128\n\t"
      "mov x11,%[key]\n\t"
      CH128_NSTEP0
      CH128_NSTEP0
      CH128_NSTEP0
      CH128_NSTEP0
      CH128_NSTEP0
      CH128_NSTEP0
      CH128_NSTEP0
      CH128_NSTEP0
#if CHAINHASH128_BLOCK_BYTES == 512
      CH128_NSTEP0
      CH128_NSTEP0
      CH128_NSTEP0
      CH128_NSTEP0
      CH128_NSTEP0
      CH128_NSTEP0
      CH128_NSTEP0
      CH128_NPH0
#endif
      CH128_NFOLD0
      "add %[p],%[p],%[rb]\n\t"
      "subs %[count],%[count],#1\n\t"
      "b.ne 1b\n\t"
      "st1 {v0.2d,v1.2d,v2.2d,v3.2d},[%[out]],#64\n\t"
      "st1 {v4.2d,v5.2d,v6.2d,v7.2d},[%[out]]\n\t"
      : [p] "+&r"(p),[count] "+&r"(regions),[out] "+&r"(out)
      : [key] "r"(k->ph),[yp] "r"(k->yp+4),[yh] "r"(k->yh+4),[len] "r"((uint64_t)len),[rb] "I"(CH128_REGION)
      : "x9","x10","x11","cc","memory","v0","v1","v2","v3","v4","v5","v6","v7","v8","v9","v10","v11","v12","v13","v14","v15","v16","v17","v18","v19","v20","v21","v22","v23","v24","v25","v26","v27","v28","v29","v30","v31");
    for(j=0;j<4;j++) {acc=ch128_rxor(acc,ch128_prod(state[j].lo,k->yp[3-j],4,0));acc=ch128_rxor(acc,ch128_prod(state[j].hi,k->yh[3-j],4,0));}return ch128_reduce(acc);
}
/* Four fixed lazy chains. LD1 lists consume each comb half directly.
 * v0..v7: raw states; v8..v19: three-component block accumulators;
 * v20..v27: four word pairs; v28/v29: keys; v30/v31: scratch.
 * No hot-loop stack spills or vector-to-integer transfers are possible. */
static __attribute__((noinline)) ch128_word ch128_n_bulk1(const chainhash128_key *k,const uint8_t *p,size_t regions,size_t len) {
    ch128_raw state[4],acc={{0,0},{0,0}};uint8_t *out=(uint8_t *)state;unsigned j;
    __asm__ volatile(
      "movi v0.2d,#0\n\t"
      "movi v1.2d,#0\n\t"
      "movi v2.2d,#0\n\t"
      "movi v3.2d,#0\n\t"
      "movi v4.2d,#0\n\t"
      "movi v5.2d,#0\n\t"
      "movi v6.2d,#0\n\t"
      "movi v7.2d,#0\n\t"
      "fmov d6,%[len]\n\t"
      "1:\n\t"
      "movi v8.2d,#0\n\t"
      "movi v9.2d,#0\n\t"
      "movi v10.2d,#0\n\t"
      "movi v11.2d,#0\n\t"
      "movi v12.2d,#0\n\t"
      "movi v13.2d,#0\n\t"
      "movi v14.2d,#0\n\t"
      "movi v15.2d,#0\n\t"
      "movi v16.2d,#0\n\t"
      "movi v17.2d,#0\n\t"
      "movi v18.2d,#0\n\t"
      "movi v19.2d,#0\n\t"
      "add x9,%[p],#0\n\t"
      "add x10,x9,#128\n\t"
      "mov x11,%[key]\n\t"
      CH128_NSTEP1
      CH128_NSTEP1
      CH128_NSTEP1
      CH128_NSTEP1
      CH128_NSTEP1
      CH128_NSTEP1
      CH128_NSTEP1
      CH128_NSTEP1
#if CHAINHASH128_BLOCK_BYTES == 512
      CH128_NSTEP1
      CH128_NSTEP1
      CH128_NSTEP1
      CH128_NSTEP1
      CH128_NSTEP1
      CH128_NSTEP1
      CH128_NSTEP1
      CH128_NPH1
#endif
      CH128_NFOLD1
      "movi v8.2d,#0\n\t"
      "movi v9.2d,#0\n\t"
      "movi v10.2d,#0\n\t"
      "movi v11.2d,#0\n\t"
      "movi v12.2d,#0\n\t"
      "movi v13.2d,#0\n\t"
      "movi v14.2d,#0\n\t"
      "movi v15.2d,#0\n\t"
      "movi v16.2d,#0\n\t"
      "movi v17.2d,#0\n\t"
      "movi v18.2d,#0\n\t"
      "movi v19.2d,#0\n\t"
      "add x9,%[p],#64\n\t"
      "add x10,x9,#128\n\t"
      "mov x11,%[key]\n\t"
      CH128_NSTEP1
      CH128_NSTEP1
      CH128_NSTEP1
      CH128_NSTEP1
      CH128_NSTEP1
      CH128_NSTEP1
      CH128_NSTEP1
      CH128_NSTEP1
#if CHAINHASH128_BLOCK_BYTES == 512
      CH128_NSTEP1
      CH128_NSTEP1
      CH128_NSTEP1
      CH128_NSTEP1
      CH128_NSTEP1
      CH128_NSTEP1
      CH128_NSTEP1
      CH128_NPH1
#endif
      CH128_NFOLD1
      "add %[p],%[p],%[rb]\n\t"
      "subs %[count],%[count],#1\n\t"
      "b.ne 1b\n\t"
      "st1 {v0.2d,v1.2d,v2.2d,v3.2d},[%[out]],#64\n\t"
      "st1 {v4.2d,v5.2d,v6.2d,v7.2d},[%[out]]\n\t"
      : [p] "+&r"(p),[count] "+&r"(regions),[out] "+&r"(out)
      : [key] "r"(k->ph),[yp] "r"(k->yp+4),[yh] "r"(k->yh+4),[len] "r"((uint64_t)len),[rb] "I"(CH128_REGION)
      : "x9","x10","x11","cc","memory","v0","v1","v2","v3","v4","v5","v6","v7","v8","v9","v10","v11","v12","v13","v14","v15","v16","v17","v18","v19","v20","v21","v22","v23","v24","v25","v26","v27","v28","v29","v30","v31");
    for(j=0;j<4;j++) {acc=ch128_rxor(acc,ch128_prod(state[j].lo,k->yp[3-j],4,1));acc=ch128_rxor(acc,ch128_prod(state[j].hi,k->yh[3-j],4,1));}return ch128_reduce(acc);
}
#undef CH128_NX3
#undef CH128_NPH0
#undef CH128_NSTEP0
#undef CH128_NFOLD0
#undef CH128_NPH1
#undef CH128_NSTEP1
#undef CH128_NFOLD1

#endif

static inline void ch128_region(const chainhash128_key *k,const uint8_t *p,size_t n,ch128_raw out[8],int b,int school) {
    if(n==CH128_REGION) {
#ifdef CH128_X86
        if(b==3) { ch128_512_region(k,p,out,school); return; }
        if(b==2) { ch128_256_region(k,p,out,school); return; }
        if(b==1) { ch128_128_region(k,p,out,school); return; }
#elif defined(CH128_ARM)
        if(b==4) { ch128_n_region(k,p,out,school); return; }
#endif
    }
    ch128_region_scalar(k,p,n,out,b,school);
}
typedef struct {
    const chainhash128_key *key; ch128_raw state[8]; uint64_t len,blocks;
    unsigned stride; int lazy,backend,school; size_t used; uint8_t buffer[CH128_REGION];
} chainhash128_stream;
static inline void chainhash128_init(chainhash128_stream *s,const chainhash128_key *k,unsigned stride,int lazy,int b,int school) {
    assert(stride>=1 && stride<=8 && chainhash128_has_backend(b)); assert((lazy==0 || lazy==1) && (school==0 || school==1));
    memset(s,0,sizeof(*s)); s->key=k; s->stride=stride; s->lazy=lazy; s->backend=b; s->school=school;
}
static inline void ch128_absorb(chainhash128_stream *s,const uint8_t *p,size_t n) {
    ch128_raw c[8]; unsigned j,count=ch128_lanes(n); const chainhash128_key *k=s->key;
    ch128_region(k,p,n,c,s->backend,s->school);
    for(j=0;j<count;j++) {
        ch128_raw *r=&s->state[s->blocks%s->stride];
        if(s->blocks<s->stride) { *r=c[j]; if(!s->lazy) { r->lo=ch128_reduce(*r); r->hi=ch128_make(0,0); } }
        else if(s->lazy) *r=ch128_rxor(c[j],ch128_rxor(ch128_prod(r->lo,k->yp[s->stride],s->backend,s->school),ch128_prod(r->hi,k->yh[s->stride],s->backend,s->school)));
        else r->lo=ch128_xor(ch128_mul(r->lo,k->yp[s->stride],s->backend),ch128_reduce(c[j]));
        ++s->blocks;
    }
}
static inline void chainhash128_update(chainhash128_stream *s,const void *data,size_t n) {
    const uint8_t *p=(const uint8_t *)data; assert(n<=UINT64_MAX-s->len); s->len+=n;
    if(s->used) { size_t take=CH128_REGION-s->used; if(take>n) take=n; if(take) { memcpy(s->buffer+s->used,p,take); p+=take; } s->used+=take; n-=take; if(s->used==CH128_REGION) { ch128_absorb(s,s->buffer,CH128_REGION); s->used=0; } }
    while(n>=CH128_REGION) { ch128_absorb(s,p,CH128_REGION); p+=CH128_REGION; n-=CH128_REGION; }
    if(n) { memcpy(s->buffer,p,n); s->used=n; }
}
/* Consumes stream. Empty partitions use (value,blocks)=(0,0) instead. */
static inline ch128_word chainhash128_partial(chainhash128_stream *s) {
    ch128_raw v={{0,0},{0,0}}; unsigned j;
    if(s->used || !s->blocks) { ch128_absorb(s,s->buffer,s->used); s->used=0; }
    for(j=0;j<s->stride && j<s->blocks;j++) { unsigned e=(unsigned)((s->blocks-1-j)%s->stride);
        if(!e) v=ch128_rxor(v,s->state[j]);
        else v=ch128_rxor(v,ch128_rxor(ch128_prod(s->state[j].lo,s->key->yp[e],s->backend,s->school),ch128_prod(s->state[j].hi,s->key->yh[e],s->backend,s->school)));
    } return ch128_reduce(v);
}
static inline ch128_word chainhash128_final(chainhash128_stream *s) {
    ch128_word v=chainhash128_partial(s);
    v=ch128_xor(v,ch128_mul(ch128_make(s->len,0),ch128_pow(s->key->yp[1],s->blocks,s->backend),s->backend));
    return ch128_finish(s->key,v,s->backend);
}
static inline ch128_word chainhash128_join(const chainhash128_key *k,ch128_word left,ch128_word right,uint64_t right_blocks,int b) {
    return ch128_xor(ch128_mul(left,ch128_pow(k->yp[1],right_blocks,b),b),right);
}
static inline ch128_word chainhash128_evaluate(const chainhash128_key *k,const void *p,size_t n,unsigned stride,int lazy,int b,int school) {
    chainhash128_stream s; chainhash128_init(&s,k,stride,lazy,b,school); chainhash128_update(&s,p,n); return chainhash128_final(&s);
}
static inline ch128_word chainhash128_portable(const chainhash128_key *k,const void *data,size_t len) {
    const uint8_t *p=(const uint8_t *)data; size_t n=len; ch128_word v=ch128_make(len,0);
    do { ch128_raw c[8]; unsigned j; size_t take=n<CH128_REGION?n:CH128_REGION;
        ch128_region_scalar(k,p,take,c,0,0); for(j=0;j<ch128_lanes(take);j++) v=ch128_xor(ch128_mul_ref(v,k->yp[1]),ch128_reduce(c[j]));
        n-=take; if(!n) break; p+=take;
    } while(1); return ch128_finish(k,v,0);
}
#ifdef CH128_ARM
/* Evaluate a partial comb region in vector registers. Only the final 256-byte
 * chunk needs padding; skip absent first words so no key-only pairs are added.
 * The cached powers combine the independent lanes without a serial Horner chain. */
static inline ch128_word ch128_n_tail(const chainhash128_key *k,const uint8_t *p,size_t n,ch128_word v,int school) {
    uint8_t tail[256]={0}; size_t chunks=n/256,rem=n%256; unsigned j,c,count=ch128_lanes(n);
    ch128_n_acc sum=ch128_n_accum(ch128_n_azero(),ch128_n_load(&v),ch128_n_load(k->yp+count),0);
    ch128_n_raw last;
    if(rem) memcpy(tail,p+256*chunks,rem);
    last.lo=last.hi=ch128_n_zero();
    for(j=0;j<count;j++) {
        ch128_n_acc a=ch128_n_azero(); ch128_n_raw r;
        for(c=0;c<chunks;c++)
            a=ch128_n_accum(a,ch128_n_xor(ch128_n_load(p+256*c+16*j),ch128_n_load(k->ph+2*c)),
                              ch128_n_xor(ch128_n_load(p+256*c+16*j+128),ch128_n_load(k->ph+2*c+1)),school);
        if(16*j<rem)
            a=ch128_n_accum(a,ch128_n_xor(ch128_n_load(tail+16*j),ch128_n_load(k->ph+2*chunks)),
                              ch128_n_xor(ch128_n_load(tail+16*j+128),ch128_n_load(k->ph+2*chunks+1)),school);
        r=ch128_n_pack(a,school);
        if(j+1<count) sum=ch128_n_accum(sum,ch128_n_reduce(r),ch128_n_load(k->yp+count-1-j),0);
        else last=r;
    }
    { ch128_n_raw r=ch128_n_pack(sum,0);
      r.lo=ch128_n_xor(r.lo,last.lo); r.hi=ch128_n_xor(r.hi,last.hi);
      ch128_n_store(&v,ch128_n_reduce(r)); }
    return v;
}
#endif
static inline ch128_word chainhash128_with_backend(const chainhash128_key *k,const void *data,size_t len,int b,int school) {
    const uint8_t *p=(const uint8_t *)data; size_t full=len/CH128_REGION,n=len%CH128_REGION; ch128_word v=ch128_make(len,0);
    assert(chainhash128_has_backend(b)); assert(school==0 || school==1);
#ifdef CH128_X86
    if(b && len<=128) return ch128_128_short(k,p,len);
#elif defined(CH128_ARM)
    if(b && len<=128) return ch128_n_short(k,p,len);
#endif
    if(full) {
#ifdef CH128_X86
        if(b==3) v=school?ch128_512_bulk1(k,p,full,len):ch128_512_bulk0(k,p,full,len);
        else if(b==2) v=school?ch128_256_bulk1(k,p,full,len):ch128_256_bulk0(k,p,full,len);
        else if(b==1) v=school?ch128_128_bulk1(k,p,full,len):ch128_128_bulk0(k,p,full,len);
        else return chainhash128_evaluate(k,data,len,8,1,b,school);
#elif defined(CH128_ARM)
        if(b==4) v=school?ch128_n_bulk1(k,p,full,len):ch128_n_bulk0(k,p,full,len);
        else return chainhash128_evaluate(k,data,len,8,1,b,school);
#else
        return chainhash128_evaluate(k,data,len,8,1,b,school);
#endif
        p+=full*CH128_REGION;
    }
#ifdef CH128_ARM
    if(b==4 && n) return ch128_finish(k,ch128_n_tail(k,p,n,v,school),b);
#endif
    if(n || !full) { ch128_raw c[8]; unsigned j; ch128_region_scalar(k,p,n,c,b,school); for(j=0;j<ch128_lanes(n);j++) v=ch128_xor(ch128_mul(v,k->yp[1],b),ch128_reduce(c[j])); }
    return ch128_finish(k,v,b);
}
static inline ch128_word chainhash128(const chainhash128_key *k,const void *p,size_t n) { int b=chainhash128_backend(); return chainhash128_with_backend(k,p,n,b,b==CH128_XMM || b==CH128_ZMM || b==CH128_NEON); }
static inline int chainhash128_selftest(void) {
    uint8_t m[CH128_REGION+1]; size_t n; chainhash128_key k=chainhash128_key_from_seed(123);
    for(n=0;n<sizeof(m);n++) m[n]=(uint8_t)(n*137+29);
    /* Independent formal evaluator vectors, test/128/vectors.c. */
    if(!ch128_equal(chainhash128(&k,m,0),ch128_make(UINT64_C(0x66be5c470e2ee79f),UINT64_C(0xcb2a7994d9c3a248))) ||
       !ch128_equal(chainhash128(&k,m,17),ch128_make(UINT64_C(0x2b2f07c62c4ea752),UINT64_C(0xfd15779069b8d199)))) return 0;
#if CHAINHASH128_BLOCK_BYTES == 512
    if(!ch128_equal(chainhash128(&k,m,2049),ch128_make(UINT64_C(0xa298054ce47e3d7d),UINT64_C(0x756d75e371f7f634)))) return 0;
#else
    if(!ch128_equal(chainhash128(&k,m,2049),ch128_make(UINT64_C(0x0d09cd594310045d),UINT64_C(0xaa6d98bd3e2ed773)))) return 0;
#endif
    for(n=0;n<sizeof(m);n=n<65?n+1:n+127) if(!ch128_equal(chainhash128(&k,m,n),chainhash128_portable(&k,m,n))) return 0;
    return ch128_equal(ch128_mul_ref(ch128_make(0,UINT64_C(1)<<63),ch128_make(2,0)),ch128_make(0x87,0));
}
#endif
