/* ChainHash-128. Copyright 2026 Thomas Dybdahl Ahle. MIT.
 * Self-contained C99 / C++11. See SPEC.md for the mathematical key models.
 * Bytes, words and output use little endian, bit i = coefficient of X^i.
 * Default: 512-byte blocks. Define CHAINHASH128_BLOCK_BYTES=256 to compare.
 * x86: -mpclmul; -mavx2 -mvpclmulqdq enables two parallel products.
 * ARM: -march=armv8-a+crypto (Apple: -march=native+crypto).
 * Compile-time dispatch: the caller must select flags supported by its CPU.
 * CHAINHASH128_FORCE_PORTABLE / CHAINHASH128_NO_VPCLMUL disable fast paths.
 * CHAINHASH128_SCHOOLBOOK selects four CLMULs instead of three (comparison).
 */
#ifndef CHAINHASH128_H_INCLUDED
#define CHAINHASH128_H_INCLUDED
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#ifndef CHAINHASH128_BLOCK_BYTES
#define CHAINHASH128_BLOCK_BYTES 512
#endif
#if CHAINHASH128_BLOCK_BYTES != 256 && CHAINHASH128_BLOCK_BYTES != 512
#error "ChainHash-128 supports 256 or 512 byte blocks"
#endif
#define CHAINHASH128_BLOCK_WORDS (CHAINHASH128_BLOCK_BYTES / 16)
#define CHAINHASH128_KEY_WORDS (CHAINHASH128_BLOCK_WORDS + 9)
#define CHAINHASH128_KEY_BYTES (16 * CHAINHASH128_KEY_WORDS)
#define CHAINHASH128_RANDOM_BYTES 160

typedef struct ch128_word { uint64_t lo, hi; } ch128_word;
typedef struct ch128_raw { ch128_word lo, hi; } ch128_raw;
typedef struct chainhash128_key { ch128_word words[CHAINHASH128_KEY_WORDS]; } chainhash128_key;
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
    if(off<n) { size_t count=n-off; if(count>16) count=16; memcpy(buf,p+off,count); }
    return ch128_load(buf);
}
static inline chainhash128_key chainhash128_key_from_words(const ch128_word *words) {
    chainhash128_key k; memcpy(k.words,words,sizeof k.words); return k;
}
/* Ideal: every one of these bytes independently uniform. */
static inline chainhash128_key chainhash128_key_from_ideal_bytes(const uint8_t *bytes) {
    chainhash128_key k; unsigned i;
    for(i=0;i<CHAINHASH128_KEY_WORDS;i++) k.words[i]=ch128_load(bytes+16*i);
    return k;
}
/* Model A: s,u,y,z,c0,c1,c2,c3,c4,tau, ten independent uniform words.
 * PH k_i=s^(i+1). No integer powers, no single 128-bit seed for all keys. */
static inline chainhash128_key chainhash128_key_from_bytes(const uint8_t bytes[160]) {
    chainhash128_key k; ch128_word s=ch128_load(bytes),power=s; unsigned i;
    for(i=0;i<CHAINHASH128_BLOCK_WORDS;i++) { k.words[i]=power; power=ch128_mul_ref(power,s); }
    for(i=0;i<9;i++) k.words[CHAINHASH128_BLOCK_WORDS+i]=ch128_load(bytes+16*(i+1));
    return k;
}
/* Benchmark convenience ONLY, outside both ideal and model-A theorems. */
static inline uint64_t ch128_splitmix(uint64_t *s) {
    uint64_t z=(*s+=UINT64_C(0x9e3779b97f4a7c15));
    z=(z^(z>>30))*UINT64_C(0xbf58476d1ce4e5b9); z=(z^(z>>27))*UINT64_C(0x94d049bb133111eb);
    return z^(z>>31);
}
static inline chainhash128_key chainhash128_key_from_splitmix64(uint64_t seed) {
    chainhash128_key k; unsigned i;
    for(i=0;i<CHAINHASH128_KEY_WORDS;i++) { k.words[i].lo=ch128_splitmix(&seed); k.words[i].hi=ch128_splitmix(&seed); }
    return k;
}
static inline ch128_word chainhash128_portable(const chainhash128_key *key,const void *data,size_t len) {
    const uint8_t *p=(const uint8_t *)data; const ch128_word *k=key->words;
    const unsigned w=CHAINHASH128_BLOCK_WORDS; size_t rem=len;
    ch128_word state=k[w+2],v,y,z;
    do {
        size_t n=rem>CHAINHASH128_BLOCK_BYTES?CHAINHASH128_BLOCK_BYTES:rem,g;
        ch128_raw acc; acc.lo=acc.hi=ch128_make(0,0);
        for(g=0;g<n;g+=64) {
            unsigned lane;
            for(lane=0;lane<2;lane++) {
                size_t a=g/16+lane;
                ch128_raw prod=ch128_clmul_ref(ch128_xor(ch128_partial(p,n,16*a),k[a]),
                                              ch128_xor(ch128_partial(p,n,16*(a+2)),k[a+2]));
                acc.lo=ch128_xor(acc.lo,prod.lo); acc.hi=ch128_xor(acc.hi,prod.hi);
            }
        }
        rem-=n;
        if(!rem) { ch128_word l=ch128_make((uint64_t)len,0); acc.lo=ch128_xor(acc.lo,l); acc.hi=ch128_xor(acc.hi,l); }
        state=ch128_xor(acc.lo,ch128_mul_ref(ch128_xor(acc.hi,k[w+1]),ch128_xor(state,k[w])));
        if(!rem) break;
        p+=n;
    } while(1);
    v=ch128_addint(state,k[w+8]); y=ch128_mul_ref(v,v);
    z=ch128_mul_ref(ch128_xor(y,k[w+3]),ch128_xor(ch128_xor(v,y),k[w+4]));
    return ch128_xor(ch128_mul_ref(ch128_xor(v,k[w+5]),ch128_xor(z,k[w+6])),k[w+7]);
}

#if !defined(CHAINHASH128_FORCE_PORTABLE) && defined(__x86_64__) && defined(__PCLMUL__)
#include <immintrin.h>
#define CHAINHASH128_HARDWARE 1
#if defined(__VPCLMULQDQ__) && defined(__AVX2__) && !defined(CHAINHASH128_NO_VPCLMUL)
#define CHAINHASH128_VP 1
#define CHAINHASH128_BACKEND "vpclmul256"
#else
#define CHAINHASH128_BACKEND "pclmul"
#endif
typedef __m128i ch128_vec;
static inline ch128_vec ch128_vload(const void *p) { return _mm_loadu_si128((const __m128i *)p); }
static inline ch128_vec ch128_vzero(void) { return _mm_setzero_si128(); }
static inline ch128_vec ch128_vxor(ch128_vec a,ch128_vec b) { return _mm_xor_si128(a,b); }
static inline ch128_vec ch128_swap(ch128_vec a) { return _mm_shuffle_epi32(a,0x4e); }
static inline ch128_vec ch128_left64(ch128_vec a) { return _mm_slli_si128(a,8); }
static inline ch128_vec ch128_right64(ch128_vec a) { return _mm_srli_si128(a,8); }
static inline ch128_vec ch128_ll(ch128_vec a,ch128_vec b) { return _mm_clmulepi64_si128(a,b,0); }
static inline ch128_vec ch128_hh(ch128_vec a,ch128_vec b) { return _mm_clmulepi64_si128(a,b,0x11); }
static inline ch128_vec ch128_hl(ch128_vec a,ch128_vec b) { return _mm_clmulepi64_si128(a,b,1); }
static inline ch128_vec ch128_lh(ch128_vec a,ch128_vec b) { return _mm_clmulepi64_si128(a,b,0x10); }
static inline ch128_vec ch128_vword(ch128_word a) { return _mm_set_epi64x((long long)a.hi,(long long)a.lo); }
static inline ch128_word ch128_wordv(ch128_vec a) { ch128_word r; _mm_storeu_si128((__m128i *)&r,a); return r; }
#define ch128_shl(a,n) _mm_slli_epi64((a),(n))
#define ch128_shr(a,n) _mm_srli_epi64((a),(n))
#elif !defined(CHAINHASH128_FORCE_PORTABLE) && defined(__aarch64__) && !defined(__AARCH64EB__) && \
      (defined(__ARM_FEATURE_AES) || defined(__ARM_FEATURE_CRYPTO)) && (defined(__GNUC__) || defined(__clang__))
#include <arm_neon.h>
#define CHAINHASH128_HARDWARE 1
#define CHAINHASH128_BACKEND "pmull"
typedef uint64x2_t ch128_vec;
static inline ch128_vec ch128_vload(const void *p) { return vreinterpretq_u64_u8(vld1q_u8((const uint8_t *)p)); }
static inline ch128_vec ch128_vzero(void) { return vdupq_n_u64(0); }
static inline ch128_vec ch128_vxor(ch128_vec a,ch128_vec b) { return veorq_u64(a,b); }
static inline ch128_vec ch128_swap(ch128_vec a) { return vextq_u64(a,a,1); }
static inline ch128_vec ch128_left64(ch128_vec a) { return vextq_u64(ch128_vzero(),a,1); }
static inline ch128_vec ch128_right64(ch128_vec a) { return vextq_u64(a,ch128_vzero(),1); }
/* Inline assembly pins lane selection and avoids compiler DUP + PMULL2. */
static inline ch128_vec ch128_ll(ch128_vec a,ch128_vec b) {
    ch128_vec r; __asm__("pmull %0.1q, %1.1d, %2.1d":"=w"(r):"w"(a),"w"(b)); return r;
}
static inline ch128_vec ch128_hh(ch128_vec a,ch128_vec b) {
    ch128_vec r; __asm__("pmull2 %0.1q, %1.2d, %2.2d":"=w"(r):"w"(a),"w"(b)); return r;
}
static inline ch128_vec ch128_hl(ch128_vec a,ch128_vec b) { return ch128_ll(ch128_swap(a),b); }
static inline ch128_vec ch128_lh(ch128_vec a,ch128_vec b) { return ch128_ll(a,ch128_swap(b)); }
static inline ch128_vec ch128_vword(ch128_word a) { return vcombine_u64(vcreate_u64(a.lo),vcreate_u64(a.hi)); }
static inline ch128_word ch128_wordv(ch128_vec a) { return ch128_make(vgetq_lane_u64(a,0),vgetq_lane_u64(a,1)); }
#define ch128_shl(a,n) vshlq_n_u64((a),(n))
#define ch128_shr(a,n) vshrq_n_u64((a),(n))
#else
#define CHAINHASH128_HARDWARE 0
#define CHAINHASH128_BACKEND "portable"
#endif

#if CHAINHASH128_HARDWARE
typedef struct ch128_vraw { ch128_vec lo,hi; } ch128_vraw;
/* Karatsuba accumulators. Reconstruct just once after all PH products. */
typedef struct ch128_kar { ch128_vec l,h,m; } ch128_kar;
static inline ch128_kar ch128_karzero(void) { ch128_kar r; r.l=r.h=r.m=ch128_vzero(); return r; }
static inline ch128_kar ch128_karadd(ch128_kar r,ch128_vec a,ch128_vec b) {
    ch128_vec l=ch128_ll(a,b),h=ch128_hh(a,b),m;
#ifdef CHAINHASH128_SCHOOLBOOK
    m=ch128_vxor(ch128_lh(a,b),ch128_hl(a,b));
#else
    m=ch128_ll(ch128_vxor(a,ch128_swap(a)),ch128_vxor(b,ch128_swap(b)));
#endif
    r.l=ch128_vxor(r.l,l); r.h=ch128_vxor(r.h,h); r.m=ch128_vxor(r.m,m); return r;
}
static inline ch128_vraw ch128_karfinish(ch128_kar r) {
    ch128_vraw p;
#ifndef CHAINHASH128_SCHOOLBOOK
    r.m=ch128_vxor(r.m,ch128_vxor(r.l,r.h));
#endif
    p.lo=ch128_vxor(r.l,ch128_left64(r.m)); p.hi=ch128_vxor(r.h,ch128_right64(r.m)); return p;
}
static inline ch128_vraw ch128_vclmul(ch128_vec a,ch128_vec b) { return ch128_karfinish(ch128_karadd(ch128_karzero(),a,b)); }
/* r=0x87. Fold H*r using two 64x64 products; its <=7 overflow bits
 * are folded with shifts. This also reduces arbitrary 256-bit inputs. */
static inline ch128_vec ch128_reduce(ch128_vraw p) {
    ch128_vec r=ch128_vword(ch128_make(0x87,0));
    ch128_vec a=ch128_ll(p.hi,r),b=ch128_hl(p.hi,r);
    ch128_vec t=ch128_right64(ch128_vxor(ch128_shr(p.hi,63),ch128_vxor(ch128_shr(p.hi,62),ch128_shr(p.hi,57))));
    ch128_vec fold=ch128_vxor(t,ch128_vxor(ch128_shl(t,1),ch128_vxor(ch128_shl(t,2),ch128_shl(t,7))));
    return ch128_vxor(p.lo,ch128_vxor(a,ch128_vxor(ch128_left64(b),fold)));
}
static inline ch128_vec ch128_vmul(ch128_vec a,ch128_vec b) { return ch128_reduce(ch128_vclmul(a,b)); }
/* Squaring has no cross term in characteristic 2: only two CLMULs. */
static inline ch128_vec ch128_vsquare(ch128_vec a) {
    ch128_vraw p; p.lo=ch128_ll(a,a); p.hi=ch128_hh(a,a); return ch128_reduce(p);
}
static inline ch128_kar ch128_group(ch128_kar acc,const ch128_word *k,const uint8_t *p) {
    acc=ch128_karadd(acc,ch128_vxor(ch128_vload(p),ch128_vload(k)),ch128_vxor(ch128_vload(p+32),ch128_vload(k+2)));
    return ch128_karadd(acc,ch128_vxor(ch128_vload(p+16),ch128_vload(k+1)),ch128_vxor(ch128_vload(p+48),ch128_vload(k+3)));
}
#ifdef CHAINHASH128_VP
static inline ch128_vec ch128_hxor256(__m256i v) { return _mm_xor_si128(_mm256_castsi256_si128(v),_mm256_extracti128_si256(v,1)); }
#endif
static inline ch128_vraw ch128_block(const ch128_word *k,const uint8_t *p,size_t n) {
    size_t off=0; ch128_kar acc=ch128_karzero();
#ifdef CHAINHASH128_VP
    __m256i l=_mm256_setzero_si256(),h=l,m=l;
    for(;off+64<=n;off+=64) {
        __m256i a=_mm256_xor_si256(_mm256_loadu_si256((const __m256i *)(p+off)),_mm256_loadu_si256((const __m256i *)(k+off/16)));
        __m256i b=_mm256_xor_si256(_mm256_loadu_si256((const __m256i *)(p+off+32)),_mm256_loadu_si256((const __m256i *)(k+off/16+2)));
        l=_mm256_xor_si256(l,_mm256_clmulepi64_epi128(a,b,0));
        h=_mm256_xor_si256(h,_mm256_clmulepi64_epi128(a,b,0x11));
#ifdef CHAINHASH128_SCHOOLBOOK
        m=_mm256_xor_si256(m,_mm256_xor_si256(_mm256_clmulepi64_epi128(a,b,1),_mm256_clmulepi64_epi128(a,b,0x10)));
#else
        a=_mm256_xor_si256(a,_mm256_shuffle_epi32(a,0x4e)); b=_mm256_xor_si256(b,_mm256_shuffle_epi32(b,0x4e));
        m=_mm256_xor_si256(m,_mm256_clmulepi64_epi128(a,b,0));
#endif
    }
    acc.l=ch128_hxor256(l); acc.h=ch128_hxor256(h); acc.m=ch128_hxor256(m);
#else
    for(;off+64<=n;off+=64) acc=ch128_group(acc,k+off/16,p+off);
#endif
    if(off<n) { uint8_t tail[64]={0}; memcpy(tail,p+off,n-off); acc=ch128_group(acc,k+off/16,tail); }
    return ch128_karfinish(acc);
}
static inline ch128_word chainhash128_hardware(const chainhash128_key *key,const void *data,size_t len) {
    const uint8_t *p=(const uint8_t *)data; const ch128_word *k=key->words;
    const unsigned w=CHAINHASH128_BLOCK_WORDS; size_t rem=len;
    ch128_vec u=ch128_vload(k+w),ykey=ch128_vload(k+w+1),state=ch128_vxor(ch128_vload(k+w+2),u),v,y,z;
    /* Shifted state Q=P+u. Peel the last block, with both length masks. */
    while(rem>CHAINHASH128_BLOCK_BYTES) {
        ch128_vraw acc=ch128_block(k,p,CHAINHASH128_BLOCK_BYTES);
        state=ch128_vxor(ch128_vxor(acc.lo,u),ch128_vmul(ch128_vxor(acc.hi,ykey),state));
        p+=CHAINHASH128_BLOCK_BYTES; rem-=CHAINHASH128_BLOCK_BYTES;
    }
    {
        ch128_vraw acc=ch128_block(k,p,rem); ch128_vec l=ch128_vword(ch128_make((uint64_t)len,0));
        state=ch128_vxor(ch128_vxor(acc.lo,l),ch128_vmul(ch128_vxor(ch128_vxor(acc.hi,l),ykey),state));
    }
    v=ch128_vword(ch128_addint(ch128_wordv(state),k[w+8]));
    y=ch128_vsquare(v);
    z=ch128_vmul(ch128_vxor(y,ch128_vload(k+w+3)),ch128_vxor(ch128_vxor(v,y),ch128_vload(k+w+4)));
    return ch128_wordv(ch128_vxor(ch128_vmul(ch128_vxor(v,ch128_vload(k+w+5)),ch128_vxor(z,ch128_vload(k+w+6))),ch128_vload(k+w+7)));
}
#endif
static inline ch128_word chainhash128(const chainhash128_key *key,const void *data,size_t len) {
#if CHAINHASH128_HARDWARE
    return chainhash128_hardware(key,data,len);
#else
    return chainhash128_portable(key,data,len);
#endif
}
/* Fast smoke check. Full randomized, arithmetic and vector tests: tests/. */
static inline int chainhash128_selftest(void) {
    uint8_t msg[1025]; size_t i; chainhash128_key k=chainhash128_key_from_splitmix64(1);
    static const size_t lengths[]={0,1,15,16,17,31,32,33,63,64,65,255,256,257,511,512,513,1025};
    for(i=0;i<sizeof msg;i++) msg[i]=(uint8_t)(i*137+29);
    for(i=0;i<sizeof lengths/sizeof lengths[0];i++)
        if(!ch128_equal(chainhash128(&k,msg,lengths[i]),chainhash128_portable(&k,msg,lengths[i]))) return 0;
    return ch128_equal(ch128_mul_ref(ch128_make(0,UINT64_C(1)<<63),ch128_make(2,0)),ch128_make(0x87,0));
}
#endif
