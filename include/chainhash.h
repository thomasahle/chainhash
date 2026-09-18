/* ChainHash, 256-byte blocks. Copyright 2026 Thomas Dybdahl Ahle. MIT.
 * C99 / C++11, header only. Default: 80 random bytes (10 words), model A.
 * See docs/THEOREM.md for all key models.
 * Words and input bytes have canonical little-endian interpretation.
 * Baseline compile-time selection; x86 wide PH uses runtime CPUID/XGETBV:
 *   x86-64: -mpclmul; AArch64 GCC/Clang: -march=armv8-a+crypto
 *   Apple Clang: -march=native+crypto
 * Define CHAINHASH_FORCE_PORTABLE to disable hardware paths.
 * The executable must support its baseline instructions. The AVX2 and
 * AVX-512F VPCLMUL paths are isolated with GCC/Clang target attributes.
 * Do not compile the rest of a portable executable with -march=native.
 */
#ifndef CHAINHASH_H_INCLUDED
#define CHAINHASH_H_INCLUDED
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#define CHAINHASH_KEY_BYTES 328 /* expanded resident key size */
#define CHAINHASH_RANDOM_BYTES 80 /* default: 10 independent random words */
#define CHAINHASH_KEY_WORDS 41
#define CHAINHASH_BLOCK_BYTES 256

typedef struct chainhash_key { uint64_t words[CHAINHASH_KEY_WORDS]; } chainhash_key;
/* words: k[0..31], u=32, y=33, z=34, c[0..4]=35..39, twist=40.
 * Exactly 41 words, no alignment requirement beyond uint64_t, no setup cache.
 */
static inline uint64_t ch_load64(const uint8_t *p) {
    uint64_t v = 0;
    unsigned i;
    for (i = 0; i < 8; ++i) v |= (uint64_t)p[i] << (8 * i);
    return v;
}
/* Decode 328 bytes into 41 little-endian words. All byte strings are valid.
 * Paper model: fill bytes with the OS CSPRNG. The proof assumes all words
 * independently uniform; using a CSPRNG is the practical approximation.
 */
static inline chainhash_key chainhash_key_from_328_bytes(const uint8_t bytes[328]) {
    chainhash_key key;
    unsigned i;
    for (i = 0; i < 41; ++i) key.words[i] = ch_load64(bytes + 8 * i);
    return key;
}
/* FIELD multiplication, NOT integer multiplication. X^64 = 0x1b.
 * Portable, fixed 64 iterations; used only during key construction.
 */
static inline uint64_t chainhash_schedule_mul(uint64_t a, uint64_t b) {
    uint64_t r = 0;
    unsigned i;
    for (i = 0; i < 64; ++i) {
        r ^= a & (UINT64_C(0) - (b & 1));
        a = (a << 1) ^ (UINT64_C(0x1b) & (UINT64_C(0) - (a >> 63)));
        b >>= 1;
    }
    return r;
}

/* Ideal-key entry point: numerical words, not an endian-dependent byte copy.
 * Order: k[0..31], u, y, z, c[0..4], tau. All 41 words must be independent
 * uniform for the original paper's ideal-key bound.
 */
static inline chainhash_key chainhash_key_from_words(const uint64_t words[41]) {
    chainhash_key key;
    unsigned i;
    for (i = 0; i < 41; ++i) key.words[i] = words[i];
    return key;
}

static inline void chainhash_schedule_ph(chainhash_key *key, uint64_t s) {
    uint64_t power = s;
    unsigned i;
    for (i = 0; i < 32; ++i) {
        key->words[i] = power;
        if (i != 31) power = chainhash_schedule_mul(power, s);
    }
}

/* A: 10 independent uniform words, encoded little endian:
 * s, u, y, z, c0, c1, c2, c3, c4, tau. 80 random input bytes.
 */
static inline chainhash_key chainhash_key_from_80_bytes(const uint8_t bytes[80]) {
    chainhash_key key;
    unsigned i;
    chainhash_schedule_ph(&key, ch_load64(bytes));
    for (i = 0; i < 9; ++i) key.words[32+i] = ch_load64(bytes + 8*(i+1));
    return key;
}

/* B: s, t, and all five c words independent uniform: 56 random bytes.
 * (u,y,z)=(t^2,t^3,t); tau=s^4 is independent of c, as required.
 * The five c words are the circuit parameters, NOT the expanded monic
 * polynomial coefficients; their bijection is proved in the paper.
 */
static inline chainhash_key chainhash_key_from_seed2(uint64_t s, uint64_t t,
                                                    const uint64_t c[5]) {
    chainhash_key key;
    unsigned i;
    chainhash_schedule_ph(&key, s);
    key.words[32] = chainhash_schedule_mul(t, t);
    key.words[33] = chainhash_schedule_mul(key.words[32], t);
    key.words[34] = t;
    for (i = 0; i < 5; ++i) key.words[35+i] = c[i];
    key.words[40] = key.words[3];
    return key;
}

/* C: six independent uniform words, s and c[0..4]: 48 random bytes.
 * (u,y,z)=(s^2,s^3,s); tau=s^4. The conditional finalizer theorem holds,
 * but the reduced-PH degree argument DOES NOT prove a useful collision
 * bound for the raw-split hash. Experimental; see docs/THEOREM.md.
 */
static inline chainhash_key chainhash_key_from_seed(uint64_t s, const uint64_t c[5]) {
    return chainhash_key_from_seed2(s, s, c);
}

/* D: reference ONLY. One uniform word. k_i=s^(i+1), chain as in C,
 * c_i=s^(33+i), tau=s^38. No five-wise or useful collision claim.
 */
static inline chainhash_key chainhash_key_from_single_word_reference(uint64_t s) {
    chainhash_key key;
    uint64_t power;
    unsigned i;
    chainhash_schedule_ph(&key, s);
    key.words[32] = key.words[1];
    key.words[33] = key.words[2];
    key.words[34] = key.words[0];
    power = chainhash_schedule_mul(key.words[31], s);
    for (i = 0; i < 5; ++i) {
        key.words[35+i] = power;
        power = chainhash_schedule_mul(power, s);
    }
    key.words[40] = power;
    return key;
}

/* Default, model A: 80 independent uniform input bytes (10 words).
 * Input order: s,u,y,z,c0..c4,tau. The 32 PH words are derived from s;
 * the expanded resident key occupies 328 bytes (41 words).
 */
static inline chainhash_key chainhash_key_from_bytes(const uint8_t bytes[CHAINHASH_RANDOM_BYTES]) {
    return chainhash_key_from_80_bytes(bytes);
}

/* Portable definition: no intrinsics or nonstandard 128-bit integer type. */
typedef struct ch_pair { uint64_t lo, hi; } ch_pair;
static inline ch_pair ch_clmul(uint64_t a, uint64_t b) {
    ch_pair r = {0, 0};
    unsigned i;
    for (i = 0; i < 64; ++i) {
        uint64_t mask = UINT64_C(0) - ((b >> i) & 1);
        r.lo ^= (a << i) & mask;
        if (i) r.hi ^= (a >> (64 - i)) & mask;
    }
    return r;
}
static inline uint64_t ch_reduce(ch_pair r) {
    int i;
    for (i = 63; i >= 0; --i) {
        if ((r.hi >> i) & 1) {
            r.hi ^= UINT64_C(1) << i;
            r.lo ^= UINT64_C(27) << i;
            if (i) r.hi ^= UINT64_C(27) >> (64 - i);
        }
    }
    return r.lo;
}
static inline uint64_t ch_mul(uint64_t a, uint64_t b) { return ch_reduce(ch_clmul(a, b)); }
static inline uint64_t ch_word(const uint8_t *p, size_t n, size_t off) {
    uint64_t v = 0;
    unsigned i;
    for (i = 0; i < 8 && off + i < n; ++i) v |= (uint64_t)p[off + i] << (8 * i);
    return v;
}
/* Explicit portable entry point, also available in hardware builds. */
static inline uint64_t chainhash_portable(const chainhash_key *key, const void *data, size_t len) {
    const uint8_t *p = (const uint8_t *)data;
    const uint64_t *k = key->words;
    size_t remaining = len;
    uint64_t state = k[34], v, y, z;
    do {
        size_t n = remaining > 256 ? 256 : remaining;
        size_t g;
        ch_pair acc = {0, 0};
        for (g = 0; g < n; g += 32) {
            unsigned lane;
            for (lane = 0; lane < 2; ++lane) {
                size_t a = g / 8 + lane;
                ch_pair prod = ch_clmul(ch_word(p, n, 8*a) ^ k[a],
                                        ch_word(p, n, 8*(a+2)) ^ k[a+2]);
                acc.lo ^= prod.lo; acc.hi ^= prod.hi;
            }
        }
        remaining -= n;
        if (!remaining) { acc.lo ^= (uint64_t)len; acc.hi ^= (uint64_t)len; }
        state = acc.lo ^ ch_mul(acc.hi ^ k[33], state ^ k[32]);
        if (!remaining) break;
        p += n;
    } while (1);
    v = state + k[40]; /* Integer addition mod 2^64, NOT field addition. */
    y = ch_mul(v, v);
    z = ch_mul(y ^ k[35], v ^ y ^ k[36]);
    return ch_mul(v ^ k[37], z ^ k[38]) ^ k[39];
}

#if !defined(CHAINHASH_FORCE_PORTABLE) && defined(__x86_64__) && defined(__PCLMUL__)
#define CHAINHASH_BACKEND "pclmul+vpclmul-dispatch"
#define CHAINHASH_HARDWARE 1
#include <wmmintrin.h>
typedef __m128i ch_vec;
static inline ch_vec ch_vload(const void *p) { return _mm_loadu_si128((const __m128i *)p); }
static inline ch_vec ch_vzero(void) { return _mm_setzero_si128(); }
static inline ch_vec ch_v64(uint64_t v) { return _mm_cvtsi64_si128((long long)v); }
static inline ch_vec ch_vdup(uint64_t v) { return _mm_set1_epi64x((long long)v); }
static inline ch_vec ch_vxor(ch_vec a, ch_vec b) { return _mm_xor_si128(a,b); }
static inline ch_vec ch_vadd(ch_vec a, ch_vec b) { return _mm_add_epi64(a,b); }
static inline ch_vec ch_ll(ch_vec a, ch_vec b) { return _mm_clmulepi64_si128(a,b,0x00); }
static inline ch_vec ch_hh(ch_vec a, ch_vec b) { return _mm_clmulepi64_si128(a,b,0x11); }
static inline ch_vec ch_hl(ch_vec a, ch_vec b) { return _mm_clmulepi64_si128(a,b,0x01); }
static inline uint64_t ch_low(ch_vec a) { return (uint64_t)_mm_cvtsi128_si64(a); }
#elif !defined(CHAINHASH_FORCE_PORTABLE) && defined(__aarch64__) && \
      !defined(__AARCH64EB__) && (defined(__GNUC__) || defined(__clang__)) && \
      (defined(__ARM_FEATURE_AES) || defined(__ARM_FEATURE_CRYPTO))
#define CHAINHASH_BACKEND "pmull"
#define CHAINHASH_HARDWARE 1
#include <arm_neon.h>
typedef uint64x2_t ch_vec;
static inline ch_vec ch_vload(const void *p) { return vreinterpretq_u64_u8(vld1q_u8((const uint8_t *)p)); }
static inline ch_vec ch_vzero(void) { return vdupq_n_u64(0); }
static inline ch_vec ch_v64(uint64_t v) { return vcombine_u64(vcreate_u64(v),vcreate_u64(0)); }
static inline ch_vec ch_vdup(uint64_t v) { return vdupq_n_u64(v); }
static inline ch_vec ch_vxor(ch_vec a, ch_vec b) { return veorq_u64(a,b); }
static inline ch_vec ch_vadd(ch_vec a, ch_vec b) { return vaddq_u64(a,b); }
/* Pin PMULL/PMULL2: intrinsics can introduce DUP + PMULL2 and move the
 * recurrence state through general registers. State stays in lane 0. */
static inline ch_vec ch_ll(ch_vec a, ch_vec b) {
    ch_vec r; __asm__("pmull %0.1q, %1.1d, %2.1d" : "=w"(r) : "w"(a), "w"(b)); return r;
}
static inline ch_vec ch_hh(ch_vec a, ch_vec b) {
    ch_vec r; __asm__("pmull2 %0.1q, %1.2d, %2.2d" : "=w"(r) : "w"(a), "w"(b)); return r;
}
static inline ch_vec ch_hl(ch_vec a, ch_vec b) { return ch_ll(vextq_u64(a,a,1),b); }
static inline uint64_t ch_low(ch_vec a) { return vgetq_lane_u64(a,0); }
#else
#define CHAINHASH_BACKEND "portable"
#define CHAINHASH_HARDWARE 0
#endif

#if CHAINHASH_HARDWARE
static inline ch_vec ch_xor3(ch_vec a, ch_vec b, ch_vec c) {
#if defined(__aarch64__) && defined(__ARM_FEATURE_SHA3)
    return veor3q_u64(a,b,c);
#else
    return ch_vxor(ch_vxor(a,b),c);
#endif
}
/* Field elements occupy lane 0; lane 1 after reduction is unspecified.
 * x^64 = 27; fold twice. XOR addend overlaps the dependent folds. */
static inline ch_vec ch_reduce_add(ch_vec ab, ch_vec add) {
    ch_vec rr = ch_vdup(27);
    ch_vec xr = ch_hh(ab,rr), zr = ch_hh(xr,rr);
    return ch_xor3(ch_vxor(ab,add),xr,zr);
}
static inline ch_vec ch_group(const uint64_t *k, const uint8_t *p, ch_vec acc) {
    ch_vec a = ch_vxor(ch_vload(p),ch_vload(k));
    ch_vec b = ch_vxor(ch_vload(p+16),ch_vload(k+2));
    return ch_xor3(acc,ch_ll(a,b),ch_hh(a,b));
}
static inline ch_vec ch_block(const uint64_t *k, const uint8_t *p, size_t n) {
    ch_vec a = ch_vzero(), b = ch_vzero();
    size_t off = 0;
    /* Two independent PH accumulators, same load and pairing layout as
     * the benchmark. Only a final incomplete 32-byte group is copied. */
    for (; off + 64 <= n; off += 64) {
        a = ch_group(k+off/8,p+off,a);
        b = ch_group(k+off/8+4,p+off+32,b);
    }
    if (off + 32 <= n) { a = ch_group(k+off/8,p+off,a); off += 32; }
    if (off < n) {
        uint8_t tail[32] = {0};
        memcpy(tail,p+off,n-off);
        b = ch_group(k+off/8,tail,b);
    }
    return ch_vxor(a,b);
}
static inline uint64_t chainhash_hardware(const chainhash_key *key, const void *data, size_t len) {
    const uint64_t *k = key->words;
    const uint8_t *p = (const uint8_t *)data;
    const ch_vec uy = ch_vload(k+32); /* [u,y] */
    ch_vec q = ch_v64(k[34] ^ k[32]); /* Q=P+u, in lane 0 throughout. */
    size_t remaining = len;
    ch_vec v, y, z;
    /* Peel the final block so length logic stays outside the bulk loop. */
    while (remaining > 256) {
        ch_vec t = ch_vxor(ch_block(k,p,256),uy); /* [a+u,b+y] */
        q = ch_reduce_add(ch_hl(t,q),t);
        p += 256; remaining -= 256;
    }
    {
        ch_vec t = ch_vxor(ch_block(k,p,remaining),ch_vdup((uint64_t)len));
        t = ch_vxor(t,ch_vxor(uy,ch_v64(k[32]))); /* [a+len,b+len+y] */
        q = ch_reduce_add(ch_hl(t,q),t); /* P_n */
    }
    v = ch_vadd(q,ch_v64(k[40]));
    y = ch_reduce_add(ch_ll(v,v),ch_v64(k[35])); /* v^2+c0 */
    z = ch_xor3(v,y,ch_v64(k[35]^k[36]));       /* v+v^2+c1 */
    z = ch_reduce_add(ch_ll(y,z),ch_v64(k[38]));
    return ch_low(ch_reduce_add(ch_ll(ch_vxor(v,ch_v64(k[37])),z),ch_v64(k[39])));
}
#endif

#if CHAINHASH_HARDWARE && defined(__x86_64__) && (defined(__GNUC__) || defined(__clang__))
#define CHAINHASH_RUNTIME_WIDE 1
#include <immintrin.h>
#include <cpuid.h>
#define CH_HEADER_WIDE256 __attribute__((target("avx2,vpclmulqdq")))
#define CH_HEADER_WIDE512 __attribute__((target("avx2,avx512f,vpclmulqdq")))

// Check both CPU capabilities and OS register save support. 0=baseline,
// 1=YMM, 2=ZMM. No AVX512BW/DQ/VL requirement in the ZMM path.
static int ch_x86_detect(void) {
    unsigned a,b,c,d;
    if (!__get_cpuid(1,&a,&b,&c,&d) || (c & ((1u<<27)|(1u<<28))) != ((1u<<27)|(1u<<28))) return 0;
    unsigned lo,hi;
    __asm__("xgetbv" : "=a"(lo), "=d"(hi) : "c"(0));
    if ((lo & 6) != 6 || !__get_cpuid_count(7,0,&a,&b,&c,&d) || !(c & (1u<<10)) || !(b & (1u<<5))) return 0;
    return ((lo & 0xe6) == 0xe6 && (b & (1u<<16))) ? 2 : 1;
}
static int ch_x86_width(void) {
    /* C99 and C++: relaxed atomics avoid a racy static cache. */
    static int cached = 0;
    int v = __atomic_load_n(&cached,__ATOMIC_RELAXED);
    if (!v) { v=ch_x86_detect()+1; __atomic_store_n(&cached,v,__ATOMIC_RELAXED); }
    return v-1;
}

// Ice Lake-SP (family 6, model 0x6a): YMM VPCLMUL has no product-throughput
// advantage over XMM, and the wide PH shuffles lose on 256-byte blocks.
// Use the measured pipelined XMM driver for this 256-byte configuration.
static int ch_x86_detect_tuning(void) {
    unsigned a,b,c,d;
    if (!__get_cpuid(0,&a,&b,&c,&d) || b != 0x756e6547u || d != 0x49656e69u || c != 0x6c65746eu) return 0;
    if (!__get_cpuid(1,&a,&b,&c,&d)) return 0;
    const unsigned family = (a >> 8) & 15;
    const unsigned model = ((a >> 4) & 15) | ((a >> 12) & 0xf0);
    return family == 6 && model == 0x6a;
}
static int ch_x86_prefer128(void) {
    static int cached=0;
    int v=__atomic_load_n(&cached,__ATOMIC_RELAXED);
    if (!v) { v=ch_x86_detect_tuning()+1; __atomic_store_n(&cached,v,__ATOMIC_RELAXED); }
    return v-1;
}

// The second CLMUL fold only multiplies a nibble by 27. A 16-entry byte
// table gives the identical polynomial product with a shuffle.
__attribute__((target("ssse3,pclmul"),always_inline)) static inline __m128i ch_wide_reduce(__m128i ab, __m128i add) {
    __m128i xr = _mm_clmulepi64_si128(ab,_mm_set_epi64x(0,27),0x01);
    const __m128i lut = _mm_setr_epi8(0,27,54,45,108,119,90,65,(char)216,(char)195,(char)238,(char)245,(char)180,(char)175,(char)130,(char)153);
    __m128i corr = _mm_shuffle_epi8(lut,_mm_srli_si128(xr,8));
    return _mm_xor_si128(_mm_xor_si128(ab,add),_mm_xor_si128(xr,corr));
}

CH_HEADER_WIDE256 static inline __m256i ch_wload256(const uint8_t *p, int swap) {
    __m256i v = _mm256_loadu_si256((const __m256i *)p);
    if (swap) v = _mm256_shuffle_epi8(v,_mm256_setr_epi8(7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8));
    return v;
}
CH_HEADER_WIDE512 static inline __m512i ch_wload512(const uint8_t *p, int swap) {
    __m512i v = _mm512_loadu_si512(p);
    if (swap) { // AVX512F only: byte/word exchange with shifts and masks.
        const __m512i m8 = _mm512_set1_epi64(0x00ff00ff00ff00ffLL);
        const __m512i m16 = _mm512_set1_epi64(0x0000ffff0000ffffLL);
        v = _mm512_or_si512(_mm512_slli_epi64(_mm512_and_si512(v,m8),8),_mm512_and_si512(_mm512_srli_epi64(v,8),m8));
        v = _mm512_or_si512(_mm512_slli_epi64(_mm512_and_si512(v,m16),16),_mm512_and_si512(_mm512_srli_epi64(v,16),m16));
        v = _mm512_shuffle_epi32(v,(_MM_PERM_ENUM)0xb1);
    }
    return v;
}

CH_HEADER_WIDE256 static inline __m128i ch_ph256(const uint64_t *k,const uint8_t *p) {
    __m256i acc = _mm256_setzero_si256();
    for (int i=0;i<32;i+=8) {
        __m256i x = _mm256_xor_si256(ch_wload256(p+8*i,0),_mm256_loadu_si256((const __m256i *)(k+i)));
        __m256i y = _mm256_xor_si256(ch_wload256(p+8*i+32,0),_mm256_loadu_si256((const __m256i *)(k+i+4)));
        __m256i a = _mm256_permute2x128_si256(x,y,0x20), b = _mm256_permute2x128_si256(x,y,0x31);
        acc = _mm256_xor_si256(acc,_mm256_xor_si256(_mm256_clmulepi64_epi128(a,b,0x00),_mm256_clmulepi64_epi128(a,b,0x11)));
    }
    return _mm_xor_si128(_mm256_castsi256_si128(acc),_mm256_extracti128_si256(acc,1));
}
CH_HEADER_WIDE512 static inline __m128i ch_ph512(const uint64_t *k,const uint8_t *p) {

    __m512i acc = _mm512_setzero_si512();
    for (int i=0;i<32;i+=16) {
        __m512i x = _mm512_xor_si512(ch_wload512(p+8*i,0),_mm512_loadu_si512(k+i));
        __m512i y = _mm512_xor_si512(ch_wload512(p+8*i+64,0),_mm512_loadu_si512(k+i+8));
        __m512i a = _mm512_shuffle_i64x2(x,y,0x88), b = _mm512_shuffle_i64x2(x,y,0xdd);
        acc = _mm512_xor_si512(acc,_mm512_xor_si512(_mm512_clmulepi64_epi128(a,b,0x00),_mm512_clmulepi64_epi128(a,b,0x11)));
    }
    __m256i h = _mm256_xor_si256(_mm512_castsi512_si256(acc),_mm512_extracti64x4_epi64(acc,1));
    return _mm_xor_si128(_mm256_castsi256_si128(h),_mm256_extracti128_si256(h,1));
}


CH_HEADER_WIDE256 static inline __m128i ch_narrow_ph(const uint64_t *k,const uint8_t *p) {
    return ch_block(k,p,256);
}

CH_HEADER_WIDE256 static uint64_t chainhash_narrow(const chainhash_key *key,const void *data,size_t len) {
    const int SW=32,S=1;
    const uint64_t *k=key->words;
    const uint8_t *p=(const uint8_t *)data;
    const size_t SB=256,BB=256;
    const size_t full = (len-1)/BB*S; // leave the complete final block peeled
    const __m128i uy = ch_vload(k+32);
    __m128i q = ch_v64(k[34]^k[32]);
    size_t j = 0;
    if (full) {
        __m128i t = _mm_xor_si128(ch_narrow_ph(k,p),uy);
        for (;j+1<full;++j) {
            __m128i prod = _mm_clmulepi64_si128(t,q,0x01);
            __m128i next = _mm_xor_si128(ch_narrow_ph(k+((j+1)%S)*SW,p+(j+1)*SB),uy);
            q = ch_wide_reduce(prod,t);
            t = next;
        }
        q = ch_wide_reduce(_mm_clmulepi64_si128(t,q,0x01),t);
        ++j;
    }
    const size_t rem = len-full*SB;
    for (int i=0;i<S;++i) {
        const size_t off = (size_t)i*SB;
        const size_t n = rem>off ? (rem-off<SB ? rem-off : SB) : 0;
        __m128i acc;
        if (n==SB) acc = ch_narrow_ph(k+i*SW,p+(full+i)*SB);
        else if (n) acc = ch_block(k+i*SW,p+(full+i)*SB,n);
        else acc = _mm_setzero_si128();
        __m128i t = _mm_xor_si128(acc,i+1<S ? uy : _mm_xor_si128(ch_vxor(uy,ch_v64(k[32])),ch_vdup((uint64_t)len)));
        q = ch_wide_reduce(_mm_clmulepi64_si128(t,q,0x01),t);
    }
    {
        __m128i v=ch_vadd(q,ch_v64(k[40]));
        __m128i y=ch_reduce_add(ch_ll(v,v),ch_v64(k[35]));
        __m128i z=ch_xor3(v,y,ch_v64(k[35]^k[36]));
        z=ch_reduce_add(ch_ll(y,z),ch_v64(k[38]));
        return ch_low(ch_reduce_add(ch_ll(ch_vxor(v,ch_v64(k[37])),z),ch_v64(k[39])));
    }
}

CH_HEADER_WIDE256 static uint64_t chainhash_wide256(const chainhash_key *key,const void *data,size_t len) {
    const int SW=32,S=1;
    const uint64_t *k=key->words;
    const uint8_t *p=(const uint8_t *)data;
    const size_t SB=256,BB=256;
    const size_t full = (len-1)/BB*S; // leave the complete final block peeled
    const __m128i uy = ch_vload(k+32);
    __m128i q = ch_v64(k[34]^k[32]);
    size_t j = 0;
    if (full) {
        __m128i t = _mm_xor_si128(ch_ph256(k,p),uy);
        for (;j+1<full;++j) {
            __m128i prod = _mm_clmulepi64_si128(t,q,0x01);
            __m128i next = _mm_xor_si128(ch_ph256(k+((j+1)%S)*SW,p+(j+1)*SB),uy);
            q = ch_wide_reduce(prod,t);
            t = next;
        }
        q = ch_wide_reduce(_mm_clmulepi64_si128(t,q,0x01),t);
        ++j;
    }
    const size_t rem = len-full*SB;
    for (int i=0;i<S;++i) {
        const size_t off = (size_t)i*SB;
        const size_t n = rem>off ? (rem-off<SB ? rem-off : SB) : 0;
        __m128i acc;
        if (n==SB) acc = ch_ph256(k+i*SW,p+(full+i)*SB);
        else if (n) acc = ch_block(k+i*SW,p+(full+i)*SB,n);
        else acc = _mm_setzero_si128();
        __m128i t = _mm_xor_si128(acc,i+1<S ? uy : _mm_xor_si128(ch_vxor(uy,ch_v64(k[32])),ch_vdup((uint64_t)len)));
        q = ch_wide_reduce(_mm_clmulepi64_si128(t,q,0x01),t);
    }
    {
        __m128i v=ch_vadd(q,ch_v64(k[40]));
        __m128i y=ch_reduce_add(ch_ll(v,v),ch_v64(k[35]));
        __m128i z=ch_xor3(v,y,ch_v64(k[35]^k[36]));
        z=ch_reduce_add(ch_ll(y,z),ch_v64(k[38]));
        return ch_low(ch_reduce_add(ch_ll(ch_vxor(v,ch_v64(k[37])),z),ch_v64(k[39])));
    }
}

CH_HEADER_WIDE512 static uint64_t chainhash_wide512(const chainhash_key *key,const void *data,size_t len) {
    const int SW=32,S=1;
    const uint64_t *k=key->words;
    const uint8_t *p=(const uint8_t *)data;
    const size_t SB=256,BB=256;
    const size_t full = (len-1)/BB*S; // leave the complete final block peeled
    const __m128i uy = ch_vload(k+32);
    __m128i q = ch_v64(k[34]^k[32]);
    size_t j = 0;
    if (full) {
        __m128i t = _mm_xor_si128(ch_ph512(k,p),uy);
        for (;j+1<full;++j) {
            __m128i prod = _mm_clmulepi64_si128(t,q,0x01);
            __m128i next = _mm_xor_si128(ch_ph512(k+((j+1)%S)*SW,p+(j+1)*SB),uy);
            q = ch_wide_reduce(prod,t);
            t = next;
        }
        q = ch_wide_reduce(_mm_clmulepi64_si128(t,q,0x01),t);
        ++j;
    }
    const size_t rem = len-full*SB;
    for (int i=0;i<S;++i) {
        const size_t off = (size_t)i*SB;
        const size_t n = rem>off ? (rem-off<SB ? rem-off : SB) : 0;
        __m128i acc;
        if (n==SB) acc = ch_ph512(k+i*SW,p+(full+i)*SB);
        else if (n) acc = ch_block(k+i*SW,p+(full+i)*SB,n);
        else acc = _mm_setzero_si128();
        __m128i t = _mm_xor_si128(acc,i+1<S ? uy : _mm_xor_si128(ch_vxor(uy,ch_v64(k[32])),ch_vdup((uint64_t)len)));
        q = ch_wide_reduce(_mm_clmulepi64_si128(t,q,0x01),t);
    }
    {
        __m128i v=ch_vadd(q,ch_v64(k[40]));
        __m128i y=ch_reduce_add(ch_ll(v,v),ch_v64(k[35]));
        __m128i z=ch_xor3(v,y,ch_v64(k[35]^k[36]));
        z=ch_reduce_add(ch_ll(y,z),ch_v64(k[38]));
        return ch_low(ch_reduce_add(ch_ll(ch_vxor(v,ch_v64(k[37])),z),ch_v64(k[39])));
    }
}

#undef CH_HEADER_WIDE256
#undef CH_HEADER_WIDE512
#endif

/* Hash len bytes. data may be NULL iff len==0; key must be non-NULL.
 * No input alignment requirement; no reads outside [data,data+len).
 * len must be <2^64 bytes (automatic on usual 32/64-bit size_t targets).
 * Returns the complete 64-bit hash as an integer. Serialize little-endian
 * for the exact bytes of SMHasher3's native little-endian registration.
 * Stateless and thread-safe when the caller does not mutate key/data.
 */
static inline uint64_t chainhash(const chainhash_key *key, const void *data, size_t len) {
#if CHAINHASH_HARDWARE
#if defined(CHAINHASH_RUNTIME_WIDE)
    if (len>256) {
        int width=ch_x86_width();
        if (width && ch_x86_prefer128()) return chainhash_narrow(key,data,len);
        if (width==2) return chainhash_wide512(key,data,len);
        if (width==1) return chainhash_wide256(key,data,len);
    }
#endif
    return chainhash_hardware(key,data,len);
#else
    return chainhash_portable(key,data,len);
#endif
}
#endif
