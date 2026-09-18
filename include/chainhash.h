/* ChainHash, 256-byte blocks. Copyright 2026 Thomas Dybdahl Ahle. MIT.
 * C99 / C++11, header only. See docs/THEOREM.md for the ideal-key bound.
 * Words and input bytes have canonical little-endian interpretation.
 * Compile-time dispatch, as in the original benchmark/SMHasher3 code:
 *   x86-64: -mpclmul; AArch64 GCC/Clang: -march=armv8-a+crypto
 *   Apple Clang: -march=native+crypto
 * Define CHAINHASH_FORCE_PORTABLE to disable hardware paths.
 * The executable must run on a CPU supporting its selected instructions.
 */
#ifndef CHAINHASH_H_INCLUDED
#define CHAINHASH_H_INCLUDED
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#define CHAINHASH_KEY_BYTES 328
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
 * Recommended: fill bytes with the OS CSPRNG. The proof assumes all words
 * independently uniform; using a CSPRNG is the practical approximation.
 */
static inline chainhash_key chainhash_key_from_bytes(const uint8_t bytes[328]) {
    chainhash_key key;
    unsigned i;
    for (i = 0; i < 41; ++i) key.words[i] = ch_load64(bytes + 8 * i);
    return key;
}
static inline uint64_t ch_splitmix64(uint64_t *state) {
    uint64_t z = (*state += UINT64_C(0x9E3779B97F4A7C15));
    z = (z ^ (z >> 30)) * UINT64_C(0xBF58476D1CE4E5B9);
    z = (z ^ (z >> 27)) * UINT64_C(0x94D049BB133111EB);
    return z ^ (z >> 31);
}
/* Exactly SMHasher3 chainhash_256 seed expansion: successive SplitMix64
 * outputs, starting with state=seed, in the word order above. Convenience
 * only: a 64-bit seed does NOT provide 41 independent uniform key words,
 * and this expansion has no guarantee from the proved collision bound.
 */
static inline chainhash_key chainhash_key_from_seed(uint64_t seed) {
    chainhash_key key;
    unsigned i;
    for (i = 0; i < 41; ++i) key.words[i] = ch_splitmix64(&seed);
    return key;
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
#define CHAINHASH_BACKEND "pclmul"
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

/* Hash len bytes. data may be NULL iff len==0; key must be non-NULL.
 * No input alignment requirement; no reads outside [data,data+len).
 * len must be <2^64 bytes (automatic on usual 32/64-bit size_t targets).
 * Returns the complete 64-bit hash as an integer. Serialize little-endian
 * for the exact bytes of SMHasher3's native little-endian registration.
 * Stateless and thread-safe when the caller does not mutate key/data.
 */
static inline uint64_t chainhash(const chainhash_key *key, const void *data, size_t len) {
#if CHAINHASH_HARDWARE
    return chainhash_hardware(key,data,len);
#else
    return chainhash_portable(key,data,len);
#endif
}
#endif
