/* ChainHash-x86. Copyright 2026 Thomas Dybdahl Ahle. MIT.
 * C99 / C++11. Canonical little endian input and key bytes.
 * See SPEC.md and PROOF_SKETCH.md. No ISA flags required on GCC/Clang x86-64.
 * Define CHAINHASH_X86_FORCE_PORTABLE to omit all architecture-specific code.
 */
#ifndef CHAINHASH_X86_H_INCLUDED
#define CHAINHASH_X86_H_INCLUDED
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#ifndef CHAINHASH_X86_BLOCK_BYTES
#define CHAINHASH_X86_BLOCK_BYTES 1024
#endif
#if CHAINHASH_X86_BLOCK_BYTES < 256 || CHAINHASH_X86_BLOCK_BYTES % 256
#error CHAINHASH_X86_BLOCK_BYTES must be a positive multiple of 256
#endif
#define CHAINHASH_X86_PH_WORDS (CHAINHASH_X86_BLOCK_BYTES / 8)
#define CHAINHASH_X86_KEY_WORDS (CHAINHASH_X86_PH_WORDS + 9)
#define CHAINHASH_X86_KEY_BYTES (8 * CHAINHASH_X86_KEY_WORDS)
#define CHAINHASH_X86_RANDOM_BYTES CHAINHASH_X86_KEY_BYTES
typedef struct chainhash_x86_key { uint64_t words[CHAINHASH_X86_KEY_WORDS]; } chainhash_x86_key;
typedef struct chx_pair { uint64_t lo, hi; } chx_pair;

static inline uint64_t chx_load64(const uint8_t *p) {
    uint64_t v=0; unsigned i;
    for (i=0;i<8;++i) v|=(uint64_t)p[i]<<(8*i);
    return v;
}
static inline uint64_t chx_partial(const uint8_t *p,size_t n) {
    uint64_t v=0; size_t i;
    for (i=0;i<n;++i) v|=(uint64_t)p[i]<<(8*i);
    return v;
}
/* The theorem assumes all KEY_BYTES bytes independent uniform. */
static inline chainhash_x86_key chainhash_x86_key_from_bytes(const uint8_t bytes[CHAINHASH_X86_KEY_BYTES]) {
    chainhash_x86_key key; unsigned i;
    for (i=0;i<CHAINHASH_X86_KEY_WORDS;++i) key.words[i]=chx_load64(bytes+8*i);
    return key;
}
static inline chainhash_x86_key chainhash_x86_key_from_words(const uint64_t words[CHAINHASH_X86_KEY_WORDS]) {
    chainhash_x86_key key; memcpy(key.words,words,sizeof(key.words)); return key;
}
/* Convenience / SMHasher seed expansion. No ideal-key guarantee for this
 * 64-bit-seeded subfamily. It is deliberately separate from the ideal API. */
static inline chainhash_x86_key chainhash_x86_key_from_seed(uint64_t seed) {
    chainhash_x86_key key; unsigned i;
    for (i=0;i<CHAINHASH_X86_KEY_WORDS;++i) {
        uint64_t z=(seed+=UINT64_C(0x9e3779b97f4a7c15));
        z=(z^(z>>30))*UINT64_C(0xbf58476d1ce4e5b9);
        z=(z^(z>>27))*UINT64_C(0x94d049bb133111eb);
        key.words[i]=z^(z>>31);
    }
    return key;
}

/* Unreduced polynomial multiplication over F_2; no __int128 dependency. */
static inline chx_pair chx_clmul(uint64_t a,uint64_t b) {
    chx_pair r={0,0}; unsigned i;
    for (i=0;i<64;++i) {
        uint64_t mask=UINT64_C(0)-((b>>i)&1);
        r.lo^=(a<<i)&mask;
        if (i) r.hi^=(a>>(64-i))&mask;
    }
    return r;
}
/* F = F_2[X]/(X^64 + X^4 + X^3 + X + 1). */
static inline uint64_t chx_gfmul(uint64_t a,uint64_t b) {
    uint64_t r=0; unsigned i;
    for (i=0;i<64;++i) {
        r^=a&(UINT64_C(0)-(b&1));
        a=(a<<1)^(UINT64_C(27)&(UINT64_C(0)-(a>>63))); b>>=1;
    }
    return r;
}
static inline chx_pair chx_block_portable(const uint64_t *k,const uint8_t *p,size_t n) {
    chx_pair a={0,0}; size_t off=0;
    while (n>=16) {
        chx_pair b=chx_clmul(chx_load64(p+off)^k[off/8],chx_load64(p+off+8)^k[off/8+1]);
        a.lo^=b.lo; a.hi^=b.hi; off+=16; n-=16;
    }
    if (n) {
        uint64_t x=chx_partial(p+off,n<8?n:8)^k[off/8];
        uint64_t y=(n>8?chx_partial(p+off+8,n-8):0)^k[off/8+1];
        chx_pair b=chx_clmul(x,y); a.lo^=b.lo; a.hi^=b.hi;
    }
    return a;
}
static inline uint64_t chainhash_x86_portable(const chainhash_x86_key *key,const void *data,size_t len) {
    const uint64_t *k=key->words,*t=k+CHAINHASH_X86_PH_WORDS;
    const uint8_t *p=(const uint8_t*)data;
    size_t remaining=len; uint64_t state=t[2],v,y,z;
    do {
        size_t n=remaining>CHAINHASH_X86_BLOCK_BYTES?CHAINHASH_X86_BLOCK_BYTES:remaining;
        chx_pair a=chx_block_portable(k,p,n); remaining-=n;
        if (!remaining) { a.lo^=(uint64_t)len; a.hi^=(uint64_t)len; }
        state=a.lo^chx_gfmul(a.hi^t[1],state^t[0]);
        if (!remaining) break;
        p+=n;
    } while (1);
    v=state+t[8]; y=chx_gfmul(v,v);
    z=chx_gfmul(y^t[3],v^y^t[4]);
    return chx_gfmul(v^t[5],z^t[6])^t[7];
}

#if !defined(CHAINHASH_X86_FORCE_PORTABLE) && defined(__x86_64__) && (defined(__GNUC__) || defined(__clang__))
#define CHAINHASH_X86_HAVE_SIMD 1
#include <immintrin.h>
#include <cpuid.h>
#define CHX_128 __attribute__((target("pclmul,ssse3")))
#define CHX_256 __attribute__((target("avx2,pclmul,ssse3")))
#define CHX_512 __attribute__((target("avx2,avx512f,vpclmulqdq,pclmul,ssse3")))

/* Only the low lane of the return value is meaningful. The second reduction
 * fold multiplies a nibble by 27 and is an exact table lookup. */
CHX_128 static inline __m128i chx_reduce_add(__m128i prod,__m128i add) {
    const __m128i poly=_mm_set_epi64x(0,27);
    const __m128i lut=_mm_setr_epi8(0,27,54,45,108,119,90,65,(char)216,(char)195,(char)238,(char)245,(char)180,(char)175,(char)130,(char)153);
    __m128i r=_mm_clmulepi64_si128(prod,poly,0x01);
    __m128i corr=_mm_shuffle_epi8(lut,_mm_srli_si128(r,8));
    return _mm_xor_si128(_mm_xor_si128(prod,add),_mm_xor_si128(r,corr));
}
CHX_128 static inline __m128i chx_tail(const uint64_t *k,const uint8_t *p,size_t n) {
    __m128i acc=_mm_setzero_si128(); size_t off=0;
    while (n>=16) {
        __m128i a=_mm_xor_si128(_mm_loadu_si128((const __m128i*)(p+off)),_mm_loadu_si128((const __m128i*)(k+off/8)));
        acc=_mm_xor_si128(acc,_mm_clmulepi64_si128(a,a,0x10));off+=16;n-=16;
    }
    if (n) {
        uint8_t buf[16]={0}; __m128i a; memcpy(buf,p+off,n);
        a=_mm_xor_si128(_mm_loadu_si128((const __m128i*)buf),_mm_loadu_si128((const __m128i*)(k+off/8)));
        acc=_mm_xor_si128(acc,_mm_clmulepi64_si128(a,a,0x10));
    }
    return acc;
}
CHX_128 static inline uint64_t chx_finish(__m128i state,const uint64_t *t) {
    __m128i v=_mm_add_epi64(state,_mm_cvtsi64_si128((long long)t[8]));
    __m128i y=chx_reduce_add(_mm_clmulepi64_si128(v,v,0),_mm_cvtsi64_si128((long long)t[3]));
    __m128i z=_mm_xor_si128(_mm_xor_si128(v,y),_mm_cvtsi64_si128((long long)(t[3]^t[4])));
    z=chx_reduce_add(_mm_clmulepi64_si128(y,z,0),_mm_cvtsi64_si128((long long)t[6]));
    v=_mm_xor_si128(v,_mm_cvtsi64_si128((long long)t[5]));
    return (uint64_t)_mm_cvtsi128_si64(chx_reduce_add(_mm_clmulepi64_si128(v,z,0),_mm_cvtsi64_si128((long long)t[7])));
}
CHX_512 static inline __m128i chx_block512(const uint64_t *k,const uint8_t *p,size_t n) {
    __m512i a0=_mm512_setzero_si512(),a1=a0,a2=a0,a3=a0;
    size_t off=0; __m512i x; __m256i h; __m128i out;
    while (n>=256) {
#define CHX_PAIR512(A,O) x=_mm512_xor_si512(_mm512_loadu_si512(p+off+(O)),_mm512_loadu_si512(k+(off+(O))/8)); A=_mm512_xor_si512(A,_mm512_clmulepi64_epi128(x,x,0x10))
        CHX_PAIR512(a0,0); CHX_PAIR512(a1,64); CHX_PAIR512(a2,128); CHX_PAIR512(a3,192);
#undef CHX_PAIR512
        off+=256; n-=256;
    }
    while (n>=64) {
        x=_mm512_xor_si512(_mm512_loadu_si512(p+off),_mm512_loadu_si512(k+off/8));
        a0=_mm512_xor_si512(a0,_mm512_clmulepi64_epi128(x,x,0x10)); off+=64;n-=64;
    }
    a0=_mm512_xor_si512(_mm512_xor_si512(a0,a1),_mm512_xor_si512(a2,a3));
    h=_mm256_xor_si256(_mm512_castsi512_si256(a0),_mm512_extracti64x4_epi64(a0,1));
    out=_mm_xor_si128(_mm256_castsi256_si128(h),_mm256_extracti128_si256(h,1));
    if (n) out=_mm_xor_si128(out,chx_tail(k+off/8,p+off,n));
    return out;
}
CHX_256 static inline __m128i chx_block256(const uint64_t *k,const uint8_t *p,size_t n) {
    __m128i a0=_mm_setzero_si128(),a1=a0,a2=a0,a3=a0;
    size_t off=0;
    while (n>=64) {
        __m256i x=_mm256_xor_si256(_mm256_loadu_si256((const __m256i*)(p+off)),_mm256_loadu_si256((const __m256i*)(k+off/8)));
        __m256i y=_mm256_xor_si256(_mm256_loadu_si256((const __m256i*)(p+off+32)),_mm256_loadu_si256((const __m256i*)(k+off/8+4)));
        __m128i x0=_mm256_castsi256_si128(x),x1=_mm256_extracti128_si256(x,1);
        __m128i y0=_mm256_castsi256_si128(y),y1=_mm256_extracti128_si256(y,1);
        a0=_mm_xor_si128(a0,_mm_clmulepi64_si128(x0,x0,0x10));
        a1=_mm_xor_si128(a1,_mm_clmulepi64_si128(x1,x1,0x10));
        a2=_mm_xor_si128(a2,_mm_clmulepi64_si128(y0,y0,0x10));
        a3=_mm_xor_si128(a3,_mm_clmulepi64_si128(y1,y1,0x10));
        off+=64;n-=64;
    }
    a0=_mm_xor_si128(_mm_xor_si128(a0,a1),_mm_xor_si128(a2,a3));
    if (n) a0=_mm_xor_si128(a0,chx_tail(k+off/8,p+off,n));
    return a0;
}

#define CHX_DRIVER(NAME,ATTR,BLOCK) \
ATTR static inline uint64_t NAME(const chainhash_x86_key *key,const void *data,size_t len) { \
    const uint64_t *k=key->words,*t=k+CHAINHASH_X86_PH_WORDS; \
    const uint8_t *p=(const uint8_t*)data; size_t rem=len; \
    const __m128i uy=_mm_loadu_si128((const __m128i*)t); \
    __m128i q=_mm_cvtsi64_si128((long long)(t[2]^t[0])),a; \
    while (rem>CHAINHASH_X86_BLOCK_BYTES) { \
        a=_mm_xor_si128(BLOCK(k,p,CHAINHASH_X86_BLOCK_BYTES),uy); \
        q=chx_reduce_add(_mm_clmulepi64_si128(a,q,1),a); \
        p+=CHAINHASH_X86_BLOCK_BYTES; rem-=CHAINHASH_X86_BLOCK_BYTES; \
    } \
    a=BLOCK(k,p,rem); \
    a=_mm_xor_si128(a,_mm_set_epi64x((long long)((uint64_t)len^t[1]),(long long)len)); \
    q=chx_reduce_add(_mm_clmulepi64_si128(a,q,1),a); \
    return chx_finish(q,t); \
}
CHX_DRIVER(chainhash_x86_avx512,CHX_512,chx_block512)
CHX_DRIVER(chainhash_x86_avx2,CHX_256,chx_block256)
#undef CHX_DRIVER

/* CPU bits AND OS save-state support. AVX2 fallback needs PCLMUL but does
 * not require VPCLMUL. No AVX512BW, AVX512DQ or AVX512VL is used. */
static inline int chx_detect(void) {
    unsigned a,b,c,d,lo,hi;
    unsigned req=(1u<<1)|(1u<<9)|(1u<<27)|(1u<<28);
    if (!__get_cpuid(1,&a,&b,&c,&d)||(c&req)!=req) return 0;
    __asm__("xgetbv":"=a"(lo),"=d"(hi):"c"(0));
    if ((lo&6)!=6||!__get_cpuid_count(7,0,&a,&b,&c,&d)||!(b&(1u<<5))) return 0;
    return (lo&0xe6)==0xe6&&(b&(1u<<16))&&(c&(1u<<10))?2:1;
}
/* 0 portable, 1 AVX2+PCLMUL, 2 AVX512F+VPCLMUL. Race-free in C99/C++11. */
static inline int chainhash_x86_backend(void) {
    static int cached=0; int v=__atomic_load_n(&cached,__ATOMIC_RELAXED);
    if (!v) {v=chx_detect()+1;__atomic_store_n(&cached,v,__ATOMIC_RELAXED);}
    return v-1;
}
#undef CHX_128
#undef CHX_256
#undef CHX_512
#else
#define CHAINHASH_X86_HAVE_SIMD 0
static inline int chainhash_x86_backend(void) { return 0; }
#endif

/* data may be NULL only for len=0. No out-of-bounds input reads. All size_t
 * lengths below 2^64 are supported. Serialize the returned integer LE. */
static inline uint64_t chainhash_x86(const chainhash_x86_key *key,const void *data,size_t len) {
#if CHAINHASH_X86_HAVE_SIMD
    int b=chainhash_x86_backend();
    if (b==2) return chainhash_x86_avx512(key,data,len);
    if (b==1) return chainhash_x86_avx2(key,data,len);
#endif
    return chainhash_x86_portable(key,data,len);
}
#endif
