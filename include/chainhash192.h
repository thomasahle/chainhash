/* ChainHash-192: a keyed 192-bit hash for long inputs with a proven collision bound.
 * Copyright 2026 Thomas Dybdahl Ahle. MIT license. C99 (GCC/Clang), one header, no allocation in the hash.
 *
 * Key: 216 uniformly random bytes (CHAINHASH192_KEY_BYTES), chainhash192_key_from_bytes; the 176 block
 * masks are powers of the key element s, derived when the key is initialized.
 * chainhash192_key_from_seed expands a 64-bit seed; it is for benchmarks and tests.
 * The expanded key is initialized in place: do not copy it.
 * Hash: chainhash192(&key, data, len, out) writes 24 canonical little-endian bytes. Streaming:
 * chainhash192_init, chainhash192_update, chainhash192_final.
 * Backends (identical digests; chosen when the key is initialized): CH192_AVX512
 * (AVX-512 F/VL/BW/DQ/VBMI2 + VPCLMULQDQ), CH192_PCLMUL (PCLMULQDQ + SSE4.1),
 * CH192_NEON (AArch64 PMULL; needs +crypto at compile time), CH192_PORTABLE.
 * x86: the kernels carry their own target attributes, so no -march flag is needed; gcc: build with -O3.
 * Bound: for two distinct messages fixed independently of the key, each of at most 8L bytes,
 * Pr[collision] <= N(L)/2^192 with N(L) <= 2L (score 191); see docs/THEOREM-192.md.
 * The definition: docs/SPEC-192.md.
 * Proof status: paper proof and machine-checked certificates (test/192); not yet in Lean.
 * Little-endian hosts. Define CHAINHASH192_PORTABLE to omit all hardware code.
 * Design: GF(2^192) pseudo-dot-product (6 Karatsuba-3 products per 48-byte pair against ChainHash-256's 9 per 64 bytes),
 * 4096-byte blocks of 88 pairs stored contiguously (chunks of 8 pairs as six 64-byte rows; the last 256 bytes hold 8
 * pairs with zero top limbs), the ChainHash-256 two-level outer stage (regions of 8 blocks) and finalizer.
 * Measurements: results/192/README.md.
 */
#ifndef CHAINHASH192_H
#define CHAINHASH192_H
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
/* Internal structure: c192_* is the specification as C (bit-serial; c192_hash_ref is the normative definition),
 * c192x_* the AVX-512 kernels, c192s_* the PCLMULQDQ + SSE4.1 kernels, c192n_* the NEON kernels, c192d_* the run-time
 * dispatch and streaming layer under the public API at the end of the file. */

/* ============================= the specification as C (docs/SPEC-192.md) =============================
 *   field   L = GF(2)[x]/(f), f = x^192 + x^7 + x^2 + x + 1; element = 3 little-endian 64-bit limbs
 *   block   4096 bytes = 88 pairs (x_i, y_i): chunks g = 0..9 of 384 bytes hold pairs 8g..8g+7 as six 64-byte rows
 *           (x limbs 0..2, y limbs 0..2; lane t = pair 8g+t); the last 256 bytes hold pairs 80..87 as four rows
 *           (x limbs 0, 1, y limbs 0, 1; their limb 2 is zero).  c = sum_i (x_i + s^(2i+1)) (y_i + s^(2i+2)), i = 0..87
 *   blocks  the message in 4096-byte blocks, the last zero-padded; the empty message is one block of value 0
 *   outer   regions of 8 block values; c(a_1..a_q) = sum_{i<=q/2} (a_i + y^(2i-1)) (a_{h+i} + y^(2i)) + [q odd] a_h,
 *           h = ceil(q/2); V = n z^{m'} + sum_rho c_rho z^{m'-rho}
 *   final   X = V +_Z tau (integer addition mod 2^192), G = X^2, t = (G + c0)(X + G + c1), out = (X + c2)(t + c3) + c4
 * The multiply here is schoolbook over limbs with c192_clmul64 (bit-serial unless CH192_HW_CLMUL) and a bit-level
 * reduction; it never uses the Karatsuba evaluation the kernels use. */
#define C192_BLOCK 4096
#define C192_REGION 32768
#define C192_NP 88                       /* pairs per block */
#if defined(CH192_HW_CLMUL) && defined(__aarch64__) && (defined(__ARM_FEATURE_AES) || defined(__ARM_FEATURE_CRYPTO))
#include <arm_neon.h>
static inline void c192_clmul64(uint64_t a, uint64_t b, uint64_t *lo, uint64_t *hi) {
    uint64x2_t v = vreinterpretq_u64_p128(vmull_p64((poly64_t)a, (poly64_t)b)); *lo = vgetq_lane_u64(v, 0); *hi = vgetq_lane_u64(v, 1); }
#elif defined(CH192_HW_CLMUL) && defined(__PCLMUL__)
#include <immintrin.h>
static inline void c192_clmul64(uint64_t a, uint64_t b, uint64_t *lo, uint64_t *hi) {
    __m128i r = _mm_clmulepi64_si128(_mm_set_epi64x(0, (long long)a), _mm_set_epi64x(0, (long long)b), 0x00);
    *lo = (uint64_t)_mm_cvtsi128_si64(r); *hi = (uint64_t)_mm_extract_epi64(r, 1); }
#else
static inline void c192_clmul64(uint64_t a, uint64_t b, uint64_t *lo, uint64_t *hi) {
    uint64_t l = 0, h = 0;
    for (int i = 0; i < 64; i++) if ((b >> i) & 1u) { l ^= a << i; if (i) h ^= a >> (64 - i); }
    *lo = l; *hi = h; }
#endif
static inline uint64_t c192_splitmix(uint64_t *st) {
    uint64_t z = (*st += 0x9E3779B97F4A7C15ULL);
    z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9ULL; z = (z ^ (z >> 27)) * 0x94D049BB133111EBULL; return z ^ (z >> 31); }
static inline uint64_t c192_ld64(const uint8_t *p) { uint64_t v; memcpy(&v, p, 8); return v; }
typedef struct { uint64_t w[3]; } c192_el;
static inline c192_el c192_xor(c192_el a, c192_el b) { c192_el r; for (int i = 0; i < 3; i++) r.w[i] = a.w[i] ^ b.w[i]; return r; }
static inline int c192_iszero(c192_el a) { return !(a.w[0] | a.w[1] | a.w[2]); }
/* reduce a 384-bit product r[0..5] mod f, bit by bit from the top */
static inline c192_el c192_red384(const uint64_t r0[6]) {
    uint64_t r[6]; memcpy(r, r0, sizeof r);
    for (int i = 383; i >= 192; i--) if ((r[i >> 6] >> (i & 63)) & 1) { r[i >> 6] ^= 1ULL << (i & 63);
        int t[4] = {i - 192 + 7, i - 192 + 2, i - 192 + 1, i - 192}; for (int j = 0; j < 4; j++) r[t[j] >> 6] ^= 1ULL << (t[j] & 63); }
    c192_el e; memcpy(e.w, r, 24); return e; }
static inline c192_el c192_mul(c192_el a, c192_el b) {
    uint64_t r[6] = {0, 0, 0, 0, 0, 0};
    for (int i = 0; i < 3; i++) for (int j = 0; j < 3; j++) { uint64_t lo, hi; c192_clmul64(a.w[i], b.w[j], &lo, &hi); r[i + j] ^= lo; r[i + j + 1] ^= hi; }
    return c192_red384(r); }
/* X = v + t as 192-bit integers (mod 2^192) */
static inline c192_el c192_addint(c192_el v, c192_el t) {
    c192_el r; uint64_t c = 0;
    for (int i = 0; i < 3; i++) { uint64_t s = v.w[i] + c; uint64_t c1 = s < c; s += t.w[i]; c = c1 | (s < t.w[i]); r.w[i] = s; }
    return r; }
static inline c192_el c192_pow(c192_el b, uint64_t e) { c192_el r = {{1, 0, 0}}; while (e) { if (e & 1) r = c192_mul(r, b); b = c192_mul(b, b); e >>= 1; } return r; }
/* the expanded key: masks k_i = s^(2i+1), l_i = s^(2i+2) (i = 0..87), Y = y, z, tau, c0..c4 */
typedef struct { c192_el k[C192_NP], l[C192_NP]; c192_el Y, z, tau, c[5]; } c192_key;
/* the raw key: s | y | z | t | c0..c4, 9 elements of 24 bytes (limb 0 first, little-endian) */
typedef struct { c192_el s, y, z, t, c[5]; } c192_raw;
/* the masks s^1..s^176 in four interleaved chains (s^(e+4) = s^e s^4: independent multiplies); MUL is inlined by
 * each backend's own copy (x86: inside its target region, where a function pointer would block inlining) */
#define C192_DERIVE(R, K, MUL) do { c192_el p_[4], s4_; \
        p_[0] = (R)->s; p_[1] = MUL((R)->s, (R)->s); p_[2] = MUL(p_[1], (R)->s); p_[3] = MUL(p_[1], p_[1]); s4_ = p_[3]; \
        for (int e_ = 1; e_ <= 2 * C192_NP; e_ += 4) for (int t_ = 0; t_ < 4; t_++) { \
            int f_ = e_ + t_; if (f_ & 1) (K)->k[(f_ - 1) / 2] = p_[t_]; else (K)->l[(f_ - 2) / 2] = p_[t_]; \
            if (e_ + 4 <= 2 * C192_NP) p_[t_] = MUL(p_[t_], s4_); } \
        (K)->Y = (R)->y; (K)->z = (R)->z; (K)->tau = (R)->t; for (int i_ = 0; i_ < 5; i_++) (K)->c[i_] = (R)->c[i_]; } while (0)
static inline void c192_derive(const c192_raw *R, c192_key *K) { C192_DERIVE(R, K, c192_mul); }
static inline void c192_raw_from_bytes(const uint8_t b[216], c192_raw *R) { c192_el *e = &R->s;
    for (int i = 0; i < 9; i++) for (int l = 0; l < 3; l++) e[i].w[l] = c192_ld64(b + 24 * i + 8 * l); }
static inline void c192_raw_from_seed(c192_raw *R, uint64_t seed) {        /* tests/vectors only */
    uint64_t st = seed ^ 0x4348313932763100ULL;                              /* "CH192v1" */
    c192_el *e = &R->s; for (int i = 0; i < 9; i++) for (int l = 0; l < 3; l++) e[i].w[l] = c192_splitmix(&st);
    if (c192_iszero(R->y)) R->y.w[0] = 1; }
/* pair i of a 4096-byte block (zero-padded): x_i, y_i */
static inline void c192_pair(const uint8_t *blk, int i, c192_el *x, c192_el *y) {
    int g = i / 8, t = i % 8;
    if (g < 10) { for (int j = 0; j < 3; j++) { x->w[j] = c192_ld64(blk + 384 * g + 64 * j + 8 * t); y->w[j] = c192_ld64(blk + 384 * g + 192 + 64 * j + 8 * t); } }
    else { x->w[0] = c192_ld64(blk + 3840 + 8 * t); x->w[1] = c192_ld64(blk + 3904 + 8 * t); x->w[2] = 0;
           y->w[0] = c192_ld64(blk + 3968 + 8 * t); y->w[1] = c192_ld64(blk + 4032 + 8 * t); y->w[2] = 0; } }
static inline c192_el c192_block_ref(const c192_key *K, const uint8_t *blk) {
    c192_el c = {{0, 0, 0}};
    for (int i = 0; i < C192_NP; i++) { c192_el x, y; c192_pair(blk, i, &x, &y); c = c192_xor(c, c192_mul(c192_xor(x, K->k[i]), c192_xor(y, K->l[i]))); }
    return c; }
static inline size_t c192_nblocks(size_t n) { return n ? (n + C192_BLOCK - 1) / C192_BLOCK : 1; }
/* all block values (b[0..m-1]); the last block zero-padded; n = 0: one block of value 0 */
static inline size_t c192_blocks_ref(const c192_key *K, const uint8_t *m, size_t n, c192_el *b) {
    if (!n) { b[0] = (c192_el){{0, 0, 0}}; return 1; }
    size_t nb = c192_nblocks(n);
    for (size_t t = 0; t < nb; t++) { uint8_t blk[C192_BLOCK]; size_t av = n - t * C192_BLOCK; if (av > C192_BLOCK) av = C192_BLOCK;
        memcpy(blk, m + t * C192_BLOCK, av); memset(blk + av, 0, C192_BLOCK - av); b[t] = c192_block_ref(K, blk); }
    return nb; }
/* region value of q (1..8) values: sum_{i=1}^{f} (a_i + Y^(2i-1)) (a_{h+i} + Y^(2i)) + [q odd] a_h */
static inline c192_el c192_region_ref(const c192_el *a, int q, const c192_el *Y) {
    int h = (q + 1) / 2, f = q / 2; c192_el c = {{0, 0, 0}}, yp[9]; yp[0] = (c192_el){{1, 0, 0}};
    for (int e = 1; e <= 8; e++) yp[e] = c192_mul(yp[e - 1], *Y);
    for (int i = 1; i <= f; i++) c = c192_xor(c, c192_mul(c192_xor(a[i - 1], yp[2 * i - 1]), c192_xor(a[h + i - 1], yp[2 * i])));
    if (q & 1) c = c192_xor(c, a[h - 1]);
    return c; }
/* V = n z^{m'} + sum_rho c_rho z^{m'-rho} from the block values */
static inline c192_el c192_outer_ref(const c192_el *b, size_t m, uint64_t n, const c192_el *Y, const c192_el *z) {
    size_t mp = (m + 7) / 8; c192_el V = {{n, 0, 0}};
    for (size_t r = 0; r < mp; r++) { int q = (int)((m - 8 * r) < 8 ? m - 8 * r : 8); V = c192_xor(c192_mul(V, *z), c192_region_ref(b + 8 * r, q, Y)); }
    return V; }
static inline c192_el c192_finish_ref(c192_el v, const c192_key *K) {
    c192_el X = c192_addint(v, K->tau), G = c192_mul(X, X);
    c192_el t = c192_mul(c192_xor(G, K->c[0]), c192_xor(c192_xor(X, G), K->c[1]));
    return c192_xor(c192_mul(c192_xor(X, K->c[2]), c192_xor(t, K->c[3])), K->c[4]); }
static inline void c192_store(c192_el d, uint8_t out[24]) { for (int i = 0; i < 3; i++) for (int b = 0; b < 8; b++) out[8 * i + b] = (uint8_t)(d.w[i] >> (8 * b)); }
/* the normative definition */
static inline void c192_hash_ref(const c192_key *K, const uint8_t *m, size_t n, uint8_t out[24]) {
    size_t mb = c192_nblocks(n); c192_el *b = (c192_el *)malloc(mb * sizeof(c192_el));
    mb = c192_blocks_ref(K, m, n, b); c192_el V = c192_outer_ref(b, mb, (uint64_t)n, &K->Y, &K->z); free(b);
    c192_store(c192_finish_ref(V, K), out); }

enum { C192_PORTABLE = 0, C192_PCLMUL = 1, C192_AVX512 = 2, C192_NEON = 3 };
static const char *const C192_BACKEND_NAME[4] = {"portable", "pclmul-sse4.1", "avx512-vpclmulqdq", "neon-pmull"};

#if !defined(CHAINHASH192_PORTABLE) && defined(__x86_64__) && (defined(__GNUC__) || defined(__clang__))
#define C192_X86 1
#include <immintrin.h>
#if defined(__clang__)
#pragma clang attribute push (__attribute__((target("pclmul,sse4.1"))), apply_to=function)
#else
#pragma GCC push_options
#pragma GCC target("pclmul,sse4.1")
#endif
/* ------------------------------------- PCLMULQDQ + SSE4.1 backend (c192s_) -------------------------------------
 * Block sweep as on NEON: an xmm register holds limb j of pairs (2a, 2a+1) of one block; per step the 6 keyed limbs
 * (pxor with the key table), the 6 Karatsuba-3 points, PCLMUL 0x00 / 0x11 into 6 point accumulators (both halves are
 * pairs of the same block).  One block per sweep (16 registers).  Block end and the region formula on xmm elements
 * (a = limbs (0, 1), b = limb 2 in the low qword; the high qword of b is not used). */
/* key storage: vectors with 8-byte alignment (the expanded key works at any 8-byte-aligned address; loads unaligned) */
typedef __m128i c192_xu __attribute__((aligned(8)));
typedef __m512i c192_zu __attribute__((aligned(8)));
typedef struct { c192_xu a, b; } c192h;
#define SX(a, b) _mm_xor_si128(a, b)
#define SCL(a, b, i) _mm_clmulepi64_si128(a, b, i)
#define SLD(p) _mm_loadu_si128((const __m128i *)(const void *)(p))
#define C192S_INL static inline __attribute__((always_inline))
C192S_INL c192h c192h_ld(c192_el e) { c192h r = {_mm_loadu_si128((const __m128i *)e.w), _mm_cvtsi64_si128((long long)e.w[2])}; return r; }
C192S_INL c192_el c192h_st(c192h v) { c192_el e; _mm_storeu_si128((__m128i *)e.w, v.a); e.w[2] = (uint64_t)_mm_cvtsi128_si64(v.b); return e; }
C192S_INL void c192h_out(c192h v, uint8_t out[24]) { _mm_storeu_si128((__m128i *)out, v.a); _mm_storel_epi64((__m128i *)(out + 16), v.b); }
C192S_INL c192h c192h_x(c192h x, c192h y) { c192h r = {SX(x.a, y.a), SX(x.b, y.b)}; return r; }
/* 192 x 192 schoolbook, 9 clmul -> R0 = limbs (0,1), R1 = (2,3), R2 = (4,5) */
C192S_INL void c192h_mulraw(c192h x, c192h y, __m128i *R0, __m128i *R1, __m128i *R2) {
    __m128i p0 = SCL(x.a, y.a, 0x00), p1 = SX(SCL(x.a, y.a, 0x01), SCL(x.a, y.a, 0x10));
    __m128i p2 = SX(SX(SCL(x.a, y.a, 0x11), SCL(x.a, y.b, 0x00)), SCL(x.b, y.a, 0x00));
    __m128i p3 = SX(SCL(x.a, y.b, 0x01), SCL(x.b, y.a, 0x10)), p4 = SCL(x.b, y.b, 0x00);
    *R0 = SX(p0, _mm_slli_si128(p1, 8)); *R1 = SX(SX(p2, _mm_srli_si128(p1, 8)), _mm_slli_si128(p3, 8)); *R2 = SX(p4, _mm_srli_si128(p3, 8)); }
/* (R0, R1, R2) mod f + E: lo + H (1 + x + x^2 + x^7), H = limbs 3..5 */
C192S_INL c192h c192h_red(__m128i R0, __m128i R1, __m128i R2, c192h E) {
    __m128i H01 = _mm_alignr_epi8(R2, R1, 8), Hz0 = _mm_unpackhi_epi64(_mm_setzero_si128(), R1), H2 = _mm_srli_si128(R2, 8);
#define C192S_SH(A, B, k) _mm_or_si128(_mm_slli_epi64(A, k), _mm_srli_epi64(B, 64 - (k)))
    __m128i s01 = SX(SX(C192S_SH(H01, Hz0, 1), C192S_SH(H01, Hz0, 2)), C192S_SH(H01, Hz0, 7));
    __m128i s2 = SX(SX(C192S_SH(H2, R2, 1), C192S_SH(H2, R2, 2)), C192S_SH(H2, R2, 7));
    __m128i ov = SX(SX(_mm_srli_epi64(H2, 63), _mm_srli_epi64(H2, 62)), _mm_srli_epi64(H2, 57));
    __m128i og = SX(SX(ov, _mm_slli_epi64(ov, 1)), SX(_mm_slli_epi64(ov, 2), _mm_slli_epi64(ov, 7)));
    c192h r = {SX(SX(SX(R0, H01), SX(s01, og)), E.a), SX(SX(R1, H2), SX(s2, E.b))}; return r; }
C192S_INL c192h c192h_zero(void) { c192h r = {_mm_setzero_si128(), _mm_setzero_si128()}; return r; }
C192S_INL c192h c192h_mul(c192h x, c192h y) { __m128i R0, R1, R2; c192h_mulraw(x, y, &R0, &R1, &R2); return c192h_red(R0, R1, R2, c192h_zero()); }
C192S_INL c192h c192h_sq(c192h x) { return c192h_red(SCL(x.a, x.a, 0x00), SCL(x.a, x.a, 0x11), SCL(x.b, x.b, 0x00), c192h_zero()); }
/* 6 Karatsuba-3 point sums -> (R0, R1, R2) */
C192S_INL void c192h_interp_raw(const __m128i q[6], __m128i *R0, __m128i *R1, __m128i *R2) {
    __m128i q01 = SX(q[0], q[1]), C1 = SX(q01, q[3]), C2 = SX(SX(q01, q[2]), q[4]), C3 = SX(SX(q[1], q[2]), q[5]);
    *R0 = SX(q[0], _mm_slli_si128(C1, 8)); *R1 = SX(SX(_mm_srli_si128(C1, 8), C2), _mm_slli_si128(C3, 8)); *R2 = SX(_mm_srli_si128(C3, 8), q[2]); }
C192S_INL c192h c192h_interp(const __m128i q[6]) { __m128i R0, R1, R2; c192h_interp_raw(q, &R0, &R1, &R2); return c192h_red(R0, R1, R2, c192h_zero()); }
/* n (< 2^64) times z, unreduced, accumulated */
C192S_INL void c192h_nz(uint64_t n, c192h z, __m128i *R0, __m128i *R1) {
    __m128i nv = _mm_cvtsi64_si128((long long)n), p0 = SCL(nv, z.a, 0x00), p1 = SCL(nv, z.a, 0x10), p2 = SCL(nv, z.b, 0x00);
    *R0 = SX(*R0, SX(p0, _mm_slli_si128(p1, 8))); *R1 = SX(*R1, SX(_mm_srli_si128(p1, 8), p2)); }
/* finalizer: X = v +_Z tau, G = X^2, t = (G + c0)(X + G + c1), out = (X + c2)(t + c3) + c4 */
typedef struct { c192h cc[5], tau, tau1, ntau; } c192h_fk;
/* m ? a : b (bitwise) */
C192S_INL __m128i c192h_sel(__m128i m, __m128i a, __m128i b) { return _mm_or_si128(_mm_and_si128(m, a), _mm_andnot_si128(m, b)); }
/* The twist by carry-select (as on NEON): with s_i = v_i + tau_i per limb, X_i = s_i + [carry into limb i], so
 * X_i^2 = carry ? (s_i + 1)^2 : s_i^2; the five squares start right after the limb adds (s_i + 1 = v_i + (tau_i + 1))
 * while the carries are found beside them: g_i = top bit of (v t) | ((v | t) ~s), p_1 = [v_1 == ~tau_1];
 * carry into limb 1 = g_0, into limb 2 = g_1 | p_1 g_0 */
C192S_INL c192h c192h_fin(c192h v, const c192h_fk *k) {
    __m128i sa = _mm_add_epi64(v.a, k->tau.a), sb = _mm_add_epi64(v.b, k->tau.b), sa1 = _mm_add_epi64(v.a, k->tau1.a), sb1 = _mm_add_epi64(v.b, k->tau1.b);
    __m128i S0 = SCL(sa, sa, 0x00), S1 = SCL(sa, sa, 0x11), P1 = SCL(sa1, sa1, 0x11), S2 = SCL(sb, sb, 0x00), P2 = SCL(sb1, sb1, 0x00);
    __m128i c = _mm_or_si128(_mm_and_si128(v.a, k->tau.a), _mm_andnot_si128(sa, _mm_or_si128(v.a, k->tau.a)));
    __m128i ga = _mm_shuffle_epi32(_mm_srai_epi32(c, 31), 0xF5), pa = _mm_cmpeq_epi64(v.a, k->ntau.a);        /* [g0, g1], [p0, p1] */
    __m128i m1 = _mm_shuffle_epi32(ga, 0x44), m2 = _mm_or_si128(_mm_shuffle_epi32(ga, 0xEE), _mm_and_si128(_mm_shuffle_epi32(pa, 0xEE), m1));
    c192h X = {c192h_sel(_mm_slli_si128(ga, 8), sa1, sa), c192h_sel(m2, sb1, sb)};
    c192h G = c192h_red(S0, c192h_sel(m1, P1, S1), c192h_sel(m2, P2, S2), c192h_zero());
    __m128i R0, R1, R2; c192h_mulraw(c192h_x(G, k->cc[0]), c192h_x(c192h_x(X, G), k->cc[1]), &R0, &R1, &R2);
    c192h T = c192h_red(R0, R1, R2, k->cc[3]);
    c192h_mulraw(c192h_x(X, k->cc[2]), T, &R0, &R1, &R2); return c192h_red(R0, R1, R2, k->cc[4]); }
C192S_INL c192_el c192s_mulk(c192_el a, c192_el b) { return c192h_st(c192h_mul(c192h_ld(a), c192h_ld(b))); }
static inline void c192s_derive(const c192_raw *R, c192_key *K) { C192_DERIVE(R, K, c192s_mulk); }
/* n <= 64 keys: L8[j][l] = (l_2j limb l, l_2j+1 limb l); Z[l] = (z limb l, 0) */
typedef struct { c192_xu L8[4][3], Z[3]; c192h C0; } c192h_sk;
/* k (1..16) valid bytes at p, zero-filled; no read past p + k and no store-to-load round trip through a stack buffer */
C192S_INL __m128i c192h_chunk(const uint8_t *p, size_t k) {
    if (k >= 16) return SLD(p);
    if (k >= 8) { __m128i lo = _mm_loadl_epi64((const __m128i *)(const void *)p), hi = _mm_setzero_si128();
        if (k > 8) hi = _mm_srl_epi64(_mm_loadl_epi64((const __m128i *)(const void *)(p + k - 8)), _mm_cvtsi32_si128((int)(8 * (16 - k))));
        return _mm_unpacklo_epi64(lo, hi); }
    uint64_t lo;
    if (k >= 4) { uint32_t a, b; memcpy(&a, p, 4); memcpy(&b, p + k - 4, 4); lo = (uint64_t)a | ((uint64_t)b << (8 * (k - 4))); }
    else lo = (uint64_t)p[0] | ((uint64_t)p[k >> 1] << (8 * (k >> 1))) | ((uint64_t)p[k - 1] << (8 * (k - 1)));
    return _mm_cvtsi64_si128((long long)lo); }
/* V = n z + C0 + sum_{t<8} d_t l_t for n <= 64 (d_t = 8-byte word t = x limb 0 of pair t, y = 0) */
static inline c192h c192h_v64(const c192h_sk *s, const uint8_t *p, size_t n) {
    __m128i nv = _mm_cvtsi64_si128((long long)n), Q[3];
    for (int l = 0; l < 3; l++) Q[l] = SCL(nv, s->Z[l], 0x00);
    size_t w = (n + 15) / 16;
    for (size_t j = w; j-- > 1;) { __m128i D = c192h_chunk(p + 16 * j, n - 16 * j); for (int l = 2; l >= 0; l--) Q[l] = SX(Q[l], SX(SCL(D, s->L8[j][l], 0x00), SCL(D, s->L8[j][l], 0x11))); }
    {   /* chunk 0 last, in two parts (the products are linear): bytes 0..3 (what a dependent caller may just have written)
         * by ONE load that any store of >= 4 bytes at p forwards to, bytes 4..15 by loads at p + 4 and above */
        size_t k = n < 16 ? n : 16; __m128i A;
        if (k >= 4) { uint32_t a; memcpy(&a, p, 4); A = _mm_cvtsi32_si128((int)a); }
        else { uint16_t a = p[0]; if (k >= 2) memcpy(&a, p, 2); A = _mm_insert_epi16(_mm_setzero_si128(), a, 0); }
        if (k > 4) { __m128i R = _mm_slli_si128(c192h_chunk(p + 4, k - 4), 4); for (int l = 2; l >= 0; l--) Q[l] = SX(Q[l], SX(SCL(R, s->L8[0][l], 0x00), SCL(R, s->L8[0][l], 0x11))); }
        if (k == 3) { __m128i R = _mm_cvtsi32_si128((int)p[2] << 16); for (int l = 2; l >= 0; l--) Q[l] = SX(Q[l], SCL(R, s->L8[0][l], 0x00)); }
        for (int l = 2; l >= 0; l--) Q[l] = SX(Q[l], SCL(A, s->L8[0][l], 0x00)); }
    __m128i R2 = _mm_srli_si128(Q[2], 8);                                   /* limb 3 = Q2.hi: times g into limbs 0, 1 */
    __m128i g = _mm_cvtsi64_si128(0x87), o = SCL(R2, g, 0x00);
    c192h r = {SX(SX(Q[0], _mm_slli_si128(Q[1], 8)), SX(o, s->C0.a)), SX(SX(_mm_srli_si128(Q[1], 8), Q[2]), s->C0.b)}; return r; }
static inline void c192h_sk_init(c192h_sk *s, const c192_key *K, c192_el C0) {
    for (int j = 0; j < 4; j++) for (int l = 0; l < 3; l++) s->L8[j][l] = _mm_set_epi64x((long long)K->l[2 * j + 1].w[l], (long long)K->l[2 * j].w[l]);
    for (int l = 0; l < 3; l++) s->Z[l] = _mm_cvtsi64_si128((long long)K->z.w[l]);
    s->C0 = c192h_ld(C0); }
static inline void c192h_fk_init(c192h_fk *k, const c192_key *K) { c192_el t1, nt; for (int i = 0; i < 3; i++) { t1.w[i] = K->tau.w[i] + 1; nt.w[i] = ~K->tau.w[i]; }
    for (int j = 0; j < 5; j++) k->cc[j] = c192h_ld(K->c[j]);
    k->tau = c192h_ld(K->tau); k->tau1 = c192h_ld(t1); k->ntau = c192h_ld(nt); }
typedef struct {
    c192_xu KS[44][6];        /* [pair pair a][x limbs 0..2, y limbs 0..2], lanes = pairs 2a, 2a+1 */
    c192_xu SF[12][6];        /* key-only point sums of chunks g..10 */
    c192_xu CK10;
} c192s_tab;
/* The tables live at tstore + toff, 64-byte aligned at the address where the key was initialized (a key at any
 * 8-byte alignment runs at full speed; a key moved by memcpy stays correct, its loads possibly split) */
typedef struct {
    c192_key K;
    c192h yp[9], zv;
    c192h_fk F; c192h_sk S;
    unsigned toff; unsigned char tstore[sizeof(c192s_tab) + 64];
} c192s_key;
#define C192S_TB(x) ((const c192s_tab *)(const void *)((x)->tstore + (x)->toff))
/* statement order = low register pressure (at most 14 xmm live: 6 sums, 4..6 rows, a point pair, 2 products); gcc
 * allocates registers in source order, and the all-loads-first order spilled */
#define C192S_STEP(A, p, k) do { \
        __m128i x0 = SX(SLD(p), (k)[0]), y0 = SX(SLD((p) + 192), (k)[3]); (A)[0] = SX((A)[0], SX(SCL(x0, y0, 0x00), SCL(x0, y0, 0x11))); \
        __m128i x1 = SX(SLD((p) + 64), (k)[1]), y1 = SX(SLD((p) + 256), (k)[4]); (A)[1] = SX((A)[1], SX(SCL(x1, y1, 0x00), SCL(x1, y1, 0x11))); \
        { __m128i u_ = SX(x0, x1), v_ = SX(y0, y1); (A)[3] = SX((A)[3], SX(SCL(u_, v_, 0x00), SCL(u_, v_, 0x11))); } \
        __m128i x2 = SX(SLD((p) + 128), (k)[2]), y2 = SX(SLD((p) + 320), (k)[5]); (A)[2] = SX((A)[2], SX(SCL(x2, y2, 0x00), SCL(x2, y2, 0x11))); \
        { __m128i u_ = SX(x0, x2), v_ = SX(y0, y2); (A)[4] = SX((A)[4], SX(SCL(u_, v_, 0x00), SCL(u_, v_, 0x11))); } \
        { __m128i u_ = SX(x1, x2), v_ = SX(y1, y2); (A)[5] = SX((A)[5], SX(SCL(u_, v_, 0x00), SCL(u_, v_, 0x11))); } } while (0)
#define C192S_STEP10(A, p, k) do { \
        __m128i x0 = SX(SLD(p), (k)[0]), x1 = SX(SLD((p) + 64), (k)[1]), y0 = SX(SLD((p) + 128), (k)[3]), y1 = SX(SLD((p) + 192), (k)[4]); \
        (A)[0] = SX((A)[0], SX(SCL(x0, y0, 0x00), SCL(x0, y0, 0x11))); (A)[1] = SX((A)[1], SX(SCL(x1, y1, 0x00), SCL(x1, y1, 0x11))); \
        { __m128i u_ = SX(x0, x1), v_ = SX(y0, y1); (A)[3] = SX((A)[3], SX(SCL(u_, v_, 0x00), SCL(u_, v_, 0x11))); } \
        { __m128i u_ = SX(x0, (k)[2]), v_ = SX(y0, (k)[5]); (A)[4] = SX((A)[4], SX(SCL(u_, v_, 0x00), SCL(u_, v_, 0x11))); } \
        { __m128i u_ = SX(x1, (k)[2]), v_ = SX(y1, (k)[5]); (A)[5] = SX((A)[5], SX(SCL(u_, v_, 0x00), SCL(u_, v_, 0x11))); } } while (0)
/* one block with av (1..4096) data bytes at p: raw point sums.  The accumulators are locals (B[]): written through
 * the A pointer, gcc must store them every step (A may alias the key table) */
#if defined(__clang__)
#define C192S_UNROLL _Pragma("clang loop unroll(full)")
#else
#define C192S_UNROLL _Pragma("GCC unroll 4")
#endif
/* one full block; KT = the key element type: __m128i where the tables are 16-byte aligned (the usual case: key-row
 * xors take the key as a memory operand), c192_xu otherwise (a key moved by memcpy: movdqu + pxor).  Out of line
 * under gcc (one block per call), so each copy gets its own register allocation */
#if defined(__GNUC__) && !defined(__clang__)
#define C192S_SWKW static __attribute__((noinline))
#else
#define C192S_SWKW static inline
#endif
#define C192S_FULL(KT) do { const KT (*KS)[6] = (const KT (*)[6])(const void *)T->KS; __m128i B[6]; \
        for (int q = 0; q < 6; q++) { B[q] = _mm_setzero_si128(); } \
        B[2] = T->CK10; \
        for (int g = 9; g >= 0; g--) { const uint8_t *r = p + 384 * (size_t)g; const KT (*k)[6] = KS + 4 * g; \
            C192S_STEP(B, r, k[0]); C192S_STEP(B, r + 16, k[1]); C192S_STEP(B, r + 32, k[2]); C192S_STEP(B, r + 48, k[3]); } \
        C192S_STEP10(B, p + 3840, KS[40]); C192S_STEP10(B, p + 3856, KS[41]); C192S_STEP10(B, p + 3872, KS[42]); C192S_STEP10(B, p + 3888, KS[43]); \
        for (int q = 0; q < 6; q++) A[q] = B[q]; } while (0)
C192S_SWKW void c192s_full_a(const c192s_tab *T, const uint8_t *p, __m128i A[6]) { C192S_FULL(__m128i); }
C192S_SWKW void c192s_full_u(const c192s_tab *T, const uint8_t *p, __m128i A[6]) { C192S_FULL(c192_xu); }
static inline void c192s_sweep(const c192s_key *x, const uint8_t *p, size_t av, __m128i A[6]) {
    __m128i B[6];
    const c192s_tab *T = C192S_TB(x);
    if (av >= C192_BLOCK) { if (!((uintptr_t)T & 15)) c192s_full_a(T, p, A); else c192s_full_u(T, p, A); return; }
    int nf = (int)(av / 384); size_t done = (size_t)384 * nf; int ng = nf + (av > done ? 1 : 0);
    for (int q = 0; q < 6; q++) B[q] = T->SF[ng][q];
    if (ng > nf) { uint8_t buf[384]; memset(buf, 0, sizeof buf); memcpy(buf, p + done, av - done);
        if (nf < 10) { for (int u = 0; u < 4; u++) C192S_STEP(B, buf + 16 * u, T->KS[4 * nf + u]); }
        else { B[2] = SX(B[2], T->CK10); for (int u = 0; u < 4; u++) C192S_STEP10(B, buf + 16 * u, T->KS[40 + u]); } }
    for (int g = nf - 1; g >= 0; g--) { const uint8_t *r = p + 384 * (size_t)g; const c192_xu (*k)[6] = T->KS + 4 * g;     /* chunk 0 last */
        C192S_STEP(B, r, k[0]); C192S_STEP(B, r + 16, k[1]); C192S_STEP(B, r + 32, k[2]); C192S_STEP(B, r + 48, k[3]); }
    for (int q = 0; q < 6; q++) A[q] = B[q]; }
static inline void c192s_key_init(c192s_key *x, const c192_key *K) {
    x->K = *K; x->toff = (unsigned)((64 - ((uintptr_t)x->tstore & 63)) & 63);
    c192s_tab *T = (c192s_tab *)(void *)(x->tstore + x->toff);
    for (int a = 0; a < 44; a++) for (int j = 0; j < 3; j++) { T->KS[a][j] = _mm_set_epi64x((long long)K->k[2 * a + 1].w[j], (long long)K->k[2 * a].w[j]);
        T->KS[a][3 + j] = _mm_set_epi64x((long long)K->l[2 * a + 1].w[j], (long long)K->l[2 * a].w[j]); }
    T->CK10 = _mm_setzero_si128(); for (int a = 40; a < 44; a++) T->CK10 = SX(T->CK10, SX(SCL(T->KS[a][2], T->KS[a][5], 0x00), SCL(T->KS[a][2], T->KS[a][5], 0x11)));
    { static const uint8_t zb[384] = {0}; __m128i A[6]; for (int q = 0; q < 6; q++) { A[q] = _mm_setzero_si128(); T->SF[11][q] = A[q]; }
      A[2] = T->CK10; for (int a = 40; a < 44; a++) C192S_STEP10(A, zb + 16 * (a - 40), T->KS[a]);
      for (int q = 0; q < 6; q++) T->SF[10][q] = A[q];
      for (int g = 9; g >= 0; g--) { for (int u = 0; u < 4; u++) C192S_STEP(A, zb + 16 * u, T->KS[4 * g + u]); for (int q = 0; q < 6; q++) T->SF[g][q] = A[q]; } }
    x->yp[0] = c192h_ld((c192_el){{1, 0, 0}}); for (int e = 1; e <= 8; e++) x->yp[e] = c192h_mul(x->yp[e - 1], c192h_ld(K->Y));
    x->zv = c192h_ld(K->z); c192h_fk_init(&x->F, K); { __m128i q[6]; for (int i = 0; i < 6; i++) q[i] = T->SF[0][i]; c192h_sk_init(&x->S, K, c192h_st(c192h_interp(q))); } }
/* region value of e[0..q-1] (+ the unreduced R0..R2): sum_{i<=f} (e_{i-1} + y^(2i-1)) (e_{h+i-1} + y^(2i)) + [q odd] e_{h-1} */
C192S_INL c192h c192h_cq(const c192h *yp, const c192h *e, int q, __m128i R0, __m128i R1, __m128i R2) {
    int h = (q + 1) / 2, f = q / 2;
    for (int i = 1; i <= f; i++) { __m128i S0, S1, S2; c192h_mulraw(c192h_x(e[i - 1], yp[2 * i - 1]), c192h_x(e[h + i - 1], yp[2 * i]), &S0, &S1, &S2); R0 = SX(R0, S0); R1 = SX(R1, S1); R2 = SX(R2, S2); }
    return c192h_red(R0, R1, R2, (q & 1) ? e[h - 1] : c192h_zero()); }
/* V <- V z + c(region of q blocks in [T, T + rem)) */
static inline c192h c192s_regfold(const c192s_key *x, c192h V, const uint8_t *T, size_t rem) {
    int q = (int)((rem + 4095) / 4096); c192h e[8];
    for (int b = 0; b < q; b++) { __m128i A[6]; size_t av = rem - 4096 * (size_t)b; if (av > 4096) av = 4096; c192s_sweep(x, T + 4096 * (size_t)b, av, A); e[b] = c192h_interp(A); }
    __m128i R0, R1, R2; c192h_mulraw(V, x->zv, &R0, &R1, &R2); return c192h_cq(x->yp, e, q, R0, R1, R2); }
static inline c192h c192s_short(const c192s_key *x, const uint8_t *T, size_t n) {
    if (!n) return c192h_zero();
    if (n <= 64) return c192h_v64(&x->S, T, n);
    __m128i R0 = _mm_setzero_si128(), R1 = R0, R2 = R0; c192h_nz((uint64_t)n, x->zv, &R0, &R1);
    if (n <= 4096) { __m128i A[6], S0, S1, S2; c192s_sweep(x, T, n, A); c192h_interp_raw(A, &S0, &S1, &S2); return c192h_red(SX(R0, S0), SX(R1, S1), S2, c192h_zero()); }
    int q = (int)((n + 4095) / 4096); c192h e[8];
    for (int b = 0; b < q; b++) { __m128i A[6]; size_t av = n - 4096 * (size_t)b; if (av > 4096) av = 4096; c192s_sweep(x, T + 4096 * (size_t)b, av, A); e[b] = c192h_interp(A); }
    return c192h_cq(x->yp, e, q, R0, R1, R2); }
static inline void c192s_hash(const c192s_key *x, const uint8_t *msg, size_t n, uint8_t out[24]) {
    size_t nr = n / C192_REGION, rem = n - nr * C192_REGION; c192h V;
    if (!nr) V = c192s_short(x, msg, n);
    else { V.a = _mm_cvtsi64_si128((long long)n); V.b = _mm_setzero_si128();
        for (size_t r = 0; r < nr; r++) V = c192s_regfold(x, V, msg + r * C192_REGION, C192_REGION);
        if (rem) V = c192s_regfold(x, V, msg + nr * C192_REGION, rem); }
    c192h_out(c192h_fin(V, &x->F), out); }
static inline void c192s_fold(const c192s_key *x, c192_el *V, const uint8_t *msg, size_t nr) {
    c192h v = c192h_ld(*V); for (size_t r = 0; r < nr; r++) v = c192s_regfold(x, v, msg + r * C192_REGION, C192_REGION); *V = c192h_st(v); }
/* z^e by square-and-multiply */
C192S_INL c192h c192h_pow(c192h b, size_t e) { c192h r = c192h_ld((c192_el){{1, 0, 0}}); while (e) { if (e & 1) r = c192h_mul(r, b); e >>= 1; if (e) b = c192h_sq(b); } return r; }
static inline void c192s_final(const c192s_key *x, c192_el V0, size_t nreg, const uint8_t *T, size_t rem, size_t n, uint8_t out[24]) {
    c192h V = c192h_ld(V0); size_t mp = nreg;
    if (rem) { V = c192s_regfold(x, V, T, rem); mp++; }
    __m128i R0 = _mm_setzero_si128(), R1 = R0; c192h_nz((uint64_t)n, c192h_pow(x->zv, mp), &R0, &R1);
    V = c192h_red(R0, R1, _mm_setzero_si128(), V);
    c192h_out(c192h_fin(V, &x->F), out); }
#if defined(__clang__)
#pragma clang attribute pop
#else
#pragma GCC pop_options
#endif

#if defined(__clang__)
#pragma clang attribute push (__attribute__((target("avx512f,avx512vl,avx512bw,avx512dq,avx512vbmi2,vpclmulqdq,pclmul,avx2,sse4.1"))), apply_to=function)
#else
#pragma GCC push_options
#pragma GCC target("avx512f,avx512vl,avx512bw,avx512dq,avx512vbmi2,vpclmulqdq,pclmul,avx2,sse4.1")
#endif
/* ------------------------------------- AVX-512 + VPCLMULQDQ backend (c192x_) -------------------------------------
 * Block sweep: a zmm row holds limb j of the 8 pairs of a chunk (lanes = pairs); per chunk 6 keyed rows (key rows are
 * memory operands), the 6 Karatsuba-3 points, VPCLMULQDQ 0x00 / 0x11 summed into one accumulator per point (ternlog).
 * Block end: the 4 lanes of each accumulator are folded across the region's 8 blocks at once (two shuffle levels),
 * unpacked limb-major, recombined and reduced lane-parallel (VPSHLDQ); the region formula and the z-chain as ONE
 * 8-lane multiply (lanes 0..3: (b_c + y^(2c+1)) (b_{c+4} + y^(2c+2)), lanes 4..7: the 4 chain lanes times z). */
#define ZX(a, b) _mm512_xor_si512(a, b)
#define ZT3(a, b, c) _mm512_ternarylogic_epi64(a, b, c, 0x96)
#define ZCL(a, b, i) _mm512_clmulepi64_epi128(a, b, i)
#define ZLD(p) _mm512_loadu_si512((const void *)(p))
#define XT3(a, b, c) _mm_ternarylogic_epi64(a, b, c, 0x96)
/* ---- AVX-512VL latency path on xmm elements (finalizer, <= 64 B): VPSHLDQ reduction, ternlog, masked loads ---- */
#define C192X_INL static inline __attribute__((always_inline))
#define C192X_HIDE(x) __asm__("" : "+v"(x))
/* (R0, R1, R2) mod f + E */
C192X_INL c192h c192x_red(__m128i R0, __m128i R1, __m128i R2, c192h E) {
    __m128i H01 = _mm_alignr_epi8(R2, R1, 8), Hz0 = _mm_unpackhi_epi64(_mm_setzero_si128(), R1), H2 = _mm_srli_si128(R2, 8);
    __m128i s01 = XT3(_mm_shldi_epi64(H01, Hz0, 1), _mm_shldi_epi64(H01, Hz0, 2), _mm_shldi_epi64(H01, Hz0, 7));
    __m128i s2 = XT3(_mm_shldi_epi64(H2, R2, 1), _mm_shldi_epi64(H2, R2, 2), _mm_shldi_epi64(H2, R2, 7));
    __m128i ov = XT3(_mm_srli_epi64(H2, 63), _mm_srli_epi64(H2, 62), _mm_srli_epi64(H2, 57));
    __m128i og = XT3(ov, _mm_slli_epi64(ov, 1), _mm_xor_si128(_mm_slli_epi64(ov, 2), _mm_slli_epi64(ov, 7)));
    c192h r = {XT3(XT3(R0, H01, s01), og, E.a), XT3(XT3(R1, H2, s2), E.b, _mm_setzero_si128())}; return r; }
/* a reduced square (limb squares R0, R1, R2), two free terms: X^2 + E and X^2 + F */
C192X_INL void c192x_sq2r(__m128i R0, __m128i R1, __m128i R2, c192h E, c192h F, c192h *oe, c192h *of) {
    __m128i H01 = _mm_alignr_epi8(R2, R1, 8), Hz0 = _mm_unpackhi_epi64(_mm_setzero_si128(), R1), H2 = _mm_srli_si128(R2, 8);
    __m128i s01 = XT3(_mm_shldi_epi64(H01, Hz0, 1), _mm_shldi_epi64(H01, Hz0, 2), _mm_shldi_epi64(H01, Hz0, 7));
    __m128i s2 = XT3(_mm_shldi_epi64(H2, R2, 1), _mm_shldi_epi64(H2, R2, 2), _mm_shldi_epi64(H2, R2, 7));
    __m128i ov = XT3(_mm_srli_epi64(H2, 63), _mm_srli_epi64(H2, 62), _mm_srli_epi64(H2, 57));
    __m128i og = XT3(ov, _mm_slli_epi64(ov, 1), _mm_xor_si128(_mm_slli_epi64(ov, 2), _mm_slli_epi64(ov, 7)));
    __m128i a = XT3(R0, H01, s01), b = XT3(R1, H2, s2);
    oe->a = XT3(a, og, E.a); oe->b = _mm_xor_si128(b, E.b); of->a = XT3(a, og, F.a); of->b = _mm_xor_si128(b, F.b); }
/* 192 x 192 by Karatsuba-3 (6 clmul): P0 = a0 b0, P1 = a1 b1, P2 = a2 b2, P3 = (a0+a1)(b0+b1), P4 = (a0+a2)(b0+b2),
 * P5 = (a1+a2)(b1+b2); C1 = P0+P1+P3, C2 = P0+P1+P2+P4, C3 = P1+P2+P5 -> R0..R2 (fewer clmul issue slots than schoolbook) */
C192X_INL void c192x_mulk3(c192h x, c192h y, __m128i *R0, __m128i *R1, __m128i *R2) {
    __m128i xs = _mm_shuffle_epi32(x.a, 0x4E), ys = _mm_shuffle_epi32(y.a, 0x4E), x2 = _mm_unpacklo_epi64(x.b, x.b), y2 = _mm_unpacklo_epi64(y.b, y.b);
    __m128i xm = _mm_xor_si128(x.a, xs), ym = _mm_xor_si128(y.a, ys), xt = _mm_xor_si128(x.a, x2), yt = _mm_xor_si128(y.a, y2);
    __m128i P0 = _mm_clmulepi64_si128(x.a, y.a, 0x00), P1 = _mm_clmulepi64_si128(x.a, y.a, 0x11), P2 = _mm_clmulepi64_si128(x.b, y.b, 0x00);
    __m128i P3 = _mm_clmulepi64_si128(xm, ym, 0x00), P4 = _mm_clmulepi64_si128(xt, yt, 0x00), P5 = _mm_clmulepi64_si128(xt, yt, 0x11);
    __m128i C1 = XT3(P0, P1, P3), C3 = XT3(P1, P2, P5), C2 = XT3(XT3(P0, P1, P2), P4, _mm_setzero_si128());
    *R0 = _mm_xor_si128(P0, _mm_slli_si128(C1, 8)); *R1 = XT3(_mm_srli_si128(C1, 8), C2, _mm_slli_si128(C3, 8)); *R2 = _mm_xor_si128(_mm_srli_si128(C3, 8), P2); }
typedef struct { c192h tau, tau1, ntau, cc[5]; } c192x_fk;
static inline void c192x_fk_init(c192x_fk *k, const c192_key *K) { c192_el nt, t1; for (int i = 0; i < 3; i++) { nt.w[i] = ~K->tau.w[i]; t1.w[i] = K->tau.w[i] + 1; }
    k->tau = c192h_ld(K->tau); k->tau1 = c192h_ld(t1); k->ntau = c192h_ld(nt); for (int j = 0; j < 5; j++) k->cc[j] = c192h_ld(K->c[j]); }
#ifndef C192X_FINM
#define C192X_FINM 0                 /* finalizer multiply: 0 = schoolbook (9 clmul), 1 = Karatsuba-3 (6 clmul; measured no faster) */
#endif
#if C192X_FINM
#define C192X_FMUL c192x_mulk3
#else
#define C192X_FMUL c192h_mulraw
#endif
/* The twist by carry-select (see c192h_fin): both squares of every limb start right after the limb adds, the carries
 * (g = carry out of the limb sum, p = the limb sum is all ones) select them; the masks are hidden from the compiler */
C192X_INL c192h c192x_fin(c192h v, const c192x_fk *k) {
    __m128i sa = _mm_add_epi64(v.a, k->tau.a), sb = _mm_add_epi64(v.b, k->tau.b), sa1 = _mm_add_epi64(v.a, k->tau1.a), sb1 = _mm_add_epi64(v.b, k->tau1.b);
    __m128i S0 = _mm_clmulepi64_si128(sa, sa, 0x00), S1 = _mm_clmulepi64_si128(sa, sa, 0x11), P1 = _mm_clmulepi64_si128(sa1, sa1, 0x11);
    __m128i S2 = _mm_clmulepi64_si128(sb, sb, 0x00), P2 = _mm_clmulepi64_si128(sb1, sb1, 0x00);
    __m128i ga = _mm_srai_epi64(_mm_ternarylogic_epi64(v.a, k->tau.a, sa, 0xD4), 63), pa = _mm_cmpeq_epi64(v.a, k->ntau.a);
    C192X_HIDE(ga); C192X_HIDE(pa);
    __m128i m1 = _mm_unpacklo_epi64(ga, ga), m2 = _mm_ternarylogic_epi64(_mm_unpackhi_epi64(ga, ga), _mm_unpackhi_epi64(pa, pa), m1, 0xF8);   /* g0; g1 | p1 g0 */
    c192h X = {_mm_ternarylogic_epi64(_mm_slli_si128(ga, 8), sa1, sa, 0xCA), _mm_ternarylogic_epi64(m2, sb1, sb, 0xCA)}, U, W;
    c192x_sq2r(S0, _mm_ternarylogic_epi64(m1, P1, S1, 0xCA), _mm_ternarylogic_epi64(m2, P2, S2, 0xCA), k->cc[0], c192h_x(X, k->cc[1]), &U, &W);
    __m128i R0, R1, R2; C192X_FMUL(U, W, &R0, &R1, &R2);
    c192h T = c192x_red(R0, R1, R2, k->cc[3]);
    C192X_FMUL(c192h_x(X, k->cc[2]), T, &R0, &R1, &R2); return c192x_red(R0, R1, R2, k->cc[4]); }
/* V = n z + C0 + sum_{t<8} d_t l_t for n <= 64, masked loads; limb 3 folded by shifts */
static inline c192h c192x_v64(const c192h_sk *s, const uint8_t *p, size_t n) {
    __m128i nv = _mm_cvtsi64_si128((long long)n), Q[3];
    for (int l = 0; l < 3; l++) Q[l] = _mm_clmulepi64_si128(nv, s->Z[l], 0x00);
    size_t w = (n + 15) / 16;
/* full chunks by plain loads, only the last one masked; chunk 0 (the bytes a dependent caller just wrote) enters last */
#define C192X_MLD(o) ((n - (o)) >= 16 ? _mm_loadu_si128((const __m128i *)(const void *)(p + (o))) : _mm_maskz_loadu_epi8((__mmask16)((1u << (n - (o))) - 1), (const void *)(p + (o))))
#define C192X_ACC(D, j) do { for (int l_ = 2; l_ >= 0; l_--) Q[l_] = XT3(Q[l_], _mm_clmulepi64_si128(D, s->L8[j][l_], 0x00), _mm_clmulepi64_si128(D, s->L8[j][l_], 0x11)); } while (0)
    if (w > 3) { __m128i D = C192X_MLD(48); C192X_ACC(D, 3); }
    if (w > 2) { __m128i D = C192X_MLD(32); C192X_ACC(D, 2); }
    if (w > 1) { __m128i D = C192X_MLD(16); C192X_ACC(D, 1); }
    {   /* chunk 0 last, in two parts (as c192h_v64): bytes 0..3 by one forwardable load, bytes 4..15 masked from p + 4 */
        size_t k = n < 16 ? n : 16; __m128i A;
        if (k >= 4) { uint32_t a; memcpy(&a, p, 4); A = _mm_cvtsi32_si128((int)a); }
        else { uint16_t a = p[0]; if (k >= 2) memcpy(&a, p, 2); A = _mm_insert_epi16(_mm_setzero_si128(), a, 0); }    /* forwardable too */
        if (k > 4) { __m128i R = _mm_bslli_si128(_mm_maskz_loadu_epi8((__mmask16)((1u << (k - 4)) - 1), (const void *)(p + 4)), 4); C192X_ACC(R, 0); }
        if (k == 3) { __m128i R = _mm_cvtsi32_si128((int)p[2] << 16); for (int l = 2; l >= 0; l--) Q[l] = _mm_xor_si128(Q[l], _mm_clmulepi64_si128(R, s->L8[0][l], 0x00)); }
        for (int l = 2; l >= 0; l--) Q[l] = _mm_xor_si128(Q[l], _mm_clmulepi64_si128(A, s->L8[0][l], 0x00)); }
    __m128i T = _mm_srli_si128(Q[2], 8), B = _mm_unpackhi_epi64(_mm_setzero_si128(), Q[2]);          /* [L3, 0], [0, L3] */
    __m128i L3g = XT3(T, _mm_shldi_epi64(T, B, 1), _mm_xor_si128(_mm_shldi_epi64(T, B, 2), _mm_shldi_epi64(T, B, 7)));
    c192h r = {XT3(XT3(Q[0], _mm_slli_si128(Q[1], 8), L3g), s->C0.a, _mm_setzero_si128()), XT3(_mm_srli_si128(Q[1], 8), Q[2], s->C0.b)}; return r; }
typedef struct {
    c192_zu KZ[11][6];        /* chunk keys: lane t = pair 8g+t; x limbs 0..2, y limbs 0..2 */
    c192_zu SF[12][6];        /* key-only raw point sums of chunks g..10 */
    c192_zu CK10;             /* the point-2 seed of the last chunk */
    c192_zu YO[3], YEZ[3];    /* limb l: YO lanes 0..3 = y^1, y^3, y^5, y^7; YEZ lanes 0..3 = y^2, y^4, y^6, y^8, lanes 4..7 = z */
} c192x_tab;
typedef struct {              /* tables at tstore + toff, 64-byte aligned where the key was initialized (as c192s_key) */
    c192_key K;
    c192h yp[9], zv;
    c192h_fk F; c192h_sk S; c192x_fk XF;
    int pf;                   /* region sweeps prefetch (Intel) or not (AMD): a schedule choice, same values */
    unsigned toff; unsigned char tstore[sizeof(c192x_tab) + 64];
} c192x_key;
#define C192X_TB(x) ((const c192x_tab *)(const void *)((x)->tstore + (x)->toff))
#define C192X_CHUNK(A, p, KZ) do { \
        __m512i x0 = ZX(ZLD(p), (KZ)[0]), x1 = ZX(ZLD((p) + 64), (KZ)[1]), x2 = ZX(ZLD((p) + 128), (KZ)[2]); \
        __m512i y0 = ZX(ZLD((p) + 192), (KZ)[3]), y1 = ZX(ZLD((p) + 256), (KZ)[4]), y2 = ZX(ZLD((p) + 320), (KZ)[5]); \
        (A)[0] = ZT3((A)[0], ZCL(x0, y0, 0x00), ZCL(x0, y0, 0x11)); (A)[1] = ZT3((A)[1], ZCL(x1, y1, 0x00), ZCL(x1, y1, 0x11)); \
        (A)[2] = ZT3((A)[2], ZCL(x2, y2, 0x00), ZCL(x2, y2, 0x11)); \
        { __m512i u_ = ZX(x0, x1), v_ = ZX(y0, y1); (A)[3] = ZT3((A)[3], ZCL(u_, v_, 0x00), ZCL(u_, v_, 0x11)); } \
        { __m512i u_ = ZX(x0, x2), v_ = ZX(y0, y2); (A)[4] = ZT3((A)[4], ZCL(u_, v_, 0x00), ZCL(u_, v_, 0x11)); } \
        { __m512i u_ = ZX(x1, x2), v_ = ZX(y1, y2); (A)[5] = ZT3((A)[5], ZCL(u_, v_, 0x00), ZCL(u_, v_, 0x11)); } } while (0)
#define C192X_CHUNK10_(A, x0, x1, y0, y1, KZ) do { \
        (A)[0] = ZT3((A)[0], ZCL(x0, y0, 0x00), ZCL(x0, y0, 0x11)); (A)[1] = ZT3((A)[1], ZCL(x1, y1, 0x00), ZCL(x1, y1, 0x11)); \
        { __m512i u_ = ZX(x0, x1), v_ = ZX(y0, y1); (A)[3] = ZT3((A)[3], ZCL(u_, v_, 0x00), ZCL(u_, v_, 0x11)); } \
        { __m512i u_ = ZX(x0, (KZ)[2]), v_ = ZX(y0, (KZ)[5]); (A)[4] = ZT3((A)[4], ZCL(u_, v_, 0x00), ZCL(u_, v_, 0x11)); } \
        { __m512i u_ = ZX(x1, (KZ)[2]), v_ = ZX(y1, (KZ)[5]); (A)[5] = ZT3((A)[5], ZCL(u_, v_, 0x00), ZCL(u_, v_, 0x11)); } } while (0)
#define C192X_CHUNK10(A, p, KZ) do { __m512i x0 = ZX(ZLD(p), (KZ)[0]), x1 = ZX(ZLD((p) + 64), (KZ)[1]), y0 = ZX(ZLD((p) + 128), (KZ)[3]), y1 = ZX(ZLD((p) + 192), (KZ)[4]); \
        C192X_CHUNK10_(A, x0, x1, y0, y1, KZ); } while (0)
/* 64 bytes at p + o with the bytes at or beyond av zeroed (no read past av) */
static inline __m512i c192x_mld(const uint8_t *p, size_t o, size_t av) {
    if (o + 64 <= av) return ZLD(p + o);
    if (o >= av) return _mm512_setzero_si512();
    return _mm512_maskz_loadu_epi8((((__mmask64)1) << (av - o)) - 1, (const void *)(p + o)); }
#if defined(__GNUC__) && !defined(__clang__)
#define C192X_SWKW static __attribute__((noinline))
#else
#define C192X_SWKW static inline
#endif
/* one full block -> raw point sums */
/* Schedules (same values): C192X_SW 1 = one block per sweep, straight-line chunks (default), 2 = two blocks interleaved.
 * Prefetch (Intel only; chosen once per key, x->pf; -DC192X_PF_FORCE=0/1 forces either): every line of the block
 * 6 KiB ahead into L1 (6 lines per chunk, pinned in front of the chunk's loads), and at chunk 0 the first two lines of
 * the block 16 KiB ahead into L2 (it starts the L2 streamer on that page); only blocks inside the input.  Xeon 16 MiB:
 * none 0.90-0.97x CH-256, L1 only 1.00-1.07x, both 1.07-1.12x; 64 KiB..1 MiB unchanged.  AMD does not prefetch
 * (Zen 4: -2..-9 %). */
#ifndef C192X_SW
#define C192X_SW 1
#endif
#ifndef C192X_PFD
#define C192X_PFD 6144
#endif
#define C192X_PF6(p, g) do { const char *q_ = (const char *)(p) + C192X_PFD + 384 * (g); _mm_prefetch(q_, _MM_HINT_T0); _mm_prefetch(q_ + 64, _MM_HINT_T0); \
        _mm_prefetch(q_ + 128, _MM_HINT_T0); _mm_prefetch(q_ + 192, _MM_HINT_T0); _mm_prefetch(q_ + 256, _MM_HINT_T0); _mm_prefetch(q_ + 320, _MM_HINT_T0); } while (0)
/* the prefetches of a chunk stay in front of its loads: gcc otherwise hoists all 60 to the function entry (a burst that
 * stalls the fill buffers: Xeon gcc 16 MiB 0.75x); the empty asm with a memory clobber pins them */
#ifndef C192X_PFX
#define C192X_PFX 1                  /* the first lines of the block 4 ahead into L2 at chunk 0 */
#endif
#define C192X_CHP(B, p, g, PF) do { if (PF) { C192X_PF6(p, g); if (C192X_PFX && (g) == 0) { _mm_prefetch((const char *)(p) + 4 * 4096, _MM_HINT_T1); _mm_prefetch((const char *)(p) + 4 * 4096 + 64, _MM_HINT_T1); } \
        __asm__ volatile("" ::: "memory"); } C192X_CHUNK(B, (p) + 384 * (g), xt_->KZ[g]); } while (0)
/* one full block -> raw point sums (PF: prefetch 8 KiB ahead) */
#define C192X_SWEEP_BODY(PF) \
    const c192x_tab *xt_ = C192X_TB(x); __m512i a0 = _mm512_setzero_si512(), a2 = xt_->CK10; __m512i B[6] = {a0, a0, a2, a0, a0, a0}; \
    C192X_CHP(B, p, 0, PF); C192X_CHP(B, p, 1, PF); C192X_CHP(B, p, 2, PF); C192X_CHP(B, p, 3, PF); C192X_CHP(B, p, 4, PF); \
    C192X_CHP(B, p, 5, PF); C192X_CHP(B, p, 6, PF); C192X_CHP(B, p, 7, PF); C192X_CHP(B, p, 8, PF); C192X_CHP(B, p, 9, PF); \
    if (PF) { const char *q_ = (const char *)p + C192X_PFD + 3840; _mm_prefetch(q_, _MM_HINT_T0); _mm_prefetch(q_ + 64, _MM_HINT_T0); \
        _mm_prefetch(q_ + 128, _MM_HINT_T0); _mm_prefetch(q_ + 192, _MM_HINT_T0); __asm__ volatile("" ::: "memory"); } \
    C192X_CHUNK10(B, p + 3840, xt_->KZ[10]); \
    A[0] = B[0]; A[1] = B[1]; A[2] = B[2]; A[3] = B[3]; A[4] = B[4]; A[5] = B[5];
C192X_SWKW void c192x_sweep(const c192x_key *x, const uint8_t *p, __m512i A[6]) { C192X_SWEEP_BODY(0) }
C192X_SWKW void c192x_sweep_pf(const c192x_key *x, const uint8_t *p, __m512i A[6]) { C192X_SWEEP_BODY(1) }
#define C192X_PF(p, g) do { } while (0)
#if C192X_SW == 2
/* two full blocks, chunks interleaved */
#define C192X_CH2(B, C, p, q, g) do { C192X_PF(p, g); C192X_CHUNK(B, (p) + 384 * (g), xt_->KZ[g]); C192X_PF(q, g); C192X_CHUNK(C, (q) + 384 * (g), xt_->KZ[g]); } while (0)
C192X_SWKW void c192x_sweep2(const c192x_key *x, const uint8_t *p, const uint8_t *q, __m512i A[6], __m512i A2[6]) {
    const c192x_tab *xt_ = C192X_TB(x); __m512i a0 = _mm512_setzero_si512(), a2 = xt_->CK10;
    __m512i B[6] = {a0, a0, a2, a0, a0, a0}, C[6] = {a0, a0, a2, a0, a0, a0};
    C192X_CH2(B, C, p, q, 0); C192X_CH2(B, C, p, q, 1); C192X_CH2(B, C, p, q, 2); C192X_CH2(B, C, p, q, 3); C192X_CH2(B, C, p, q, 4);
    C192X_CH2(B, C, p, q, 5); C192X_CH2(B, C, p, q, 6); C192X_CH2(B, C, p, q, 7); C192X_CH2(B, C, p, q, 8); C192X_CH2(B, C, p, q, 9);
    C192X_CHUNK10(B, p + 3840, xt_->KZ[10]); C192X_CHUNK10(C, q + 3840, xt_->KZ[10]);
    A[0] = B[0]; A[1] = B[1]; A[2] = B[2]; A[3] = B[3]; A[4] = B[4]; A[5] = B[5];
    A2[0] = C[0]; A2[1] = C[1]; A2[2] = C[2]; A2[3] = C[3]; A2[4] = C[4]; A2[5] = C[5]; }
#endif
/* one block with av (1..4095) data bytes */
static inline void c192x_sweep_part(const c192x_key *x, const uint8_t *p, size_t av, __m512i A[6]) {
    const c192x_tab *xt_ = C192X_TB(x);
    int nf = (int)(av / 384); size_t done = (size_t)384 * nf; int ng = nf + (av > done ? 1 : 0);
    for (int q = 0; q < 6; q++) A[q] = xt_->SF[ng][q];
    if (ng > nf) {
        if (nf < 10) { const uint8_t *r = p + done; size_t k = av - done;
            __m512i x0 = ZX(c192x_mld(r, 0, k), xt_->KZ[nf][0]), x1 = ZX(c192x_mld(r, 64, k), xt_->KZ[nf][1]), x2 = ZX(c192x_mld(r, 128, k), xt_->KZ[nf][2]);
            __m512i y0 = ZX(c192x_mld(r, 192, k), xt_->KZ[nf][3]), y1 = ZX(c192x_mld(r, 256, k), xt_->KZ[nf][4]), y2 = ZX(c192x_mld(r, 320, k), xt_->KZ[nf][5]);
            A[0] = ZT3(A[0], ZCL(x0, y0, 0x00), ZCL(x0, y0, 0x11)); A[1] = ZT3(A[1], ZCL(x1, y1, 0x00), ZCL(x1, y1, 0x11)); A[2] = ZT3(A[2], ZCL(x2, y2, 0x00), ZCL(x2, y2, 0x11));
            { __m512i u_ = ZX(x0, x1), v_ = ZX(y0, y1); A[3] = ZT3(A[3], ZCL(u_, v_, 0x00), ZCL(u_, v_, 0x11)); }
            { __m512i u_ = ZX(x0, x2), v_ = ZX(y0, y2); A[4] = ZT3(A[4], ZCL(u_, v_, 0x00), ZCL(u_, v_, 0x11)); }
            { __m512i u_ = ZX(x1, x2), v_ = ZX(y1, y2); A[5] = ZT3(A[5], ZCL(u_, v_, 0x00), ZCL(u_, v_, 0x11)); } }
        else { const uint8_t *r = p + 3840; size_t k = av - 3840; A[2] = ZX(A[2], xt_->CK10);
            __m512i x0 = ZX(c192x_mld(r, 0, k), xt_->KZ[10][0]), x1 = ZX(c192x_mld(r, 64, k), xt_->KZ[10][1]), y0 = ZX(c192x_mld(r, 128, k), xt_->KZ[10][3]), y1 = ZX(c192x_mld(r, 192, k), xt_->KZ[10][4]);
            C192X_CHUNK10_(A, x0, x1, y0, y1, xt_->KZ[10]); } }
    for (int g = nf - 1; g >= 0; g--) C192X_CHUNK(A, p + 384 * g, xt_->KZ[g]); }      /* chunk 0 last */
/* lanes (4 x 128-bit) of 8 blocks' accumulators of one point -> LO, HI: qword b = low / high half of block b's sum */
static inline void c192x_fold8(const __m512i *R0, const __m512i *R1, const __m512i *R2, const __m512i *R3, const __m512i *R4, const __m512i *R5, const __m512i *R6, const __m512i *R7, int p, __m512i *LO, __m512i *HI) {
#define C192X_F1(a, b) ZX(_mm512_shuffle_i64x2(a, b, 0x44), _mm512_shuffle_i64x2(a, b, 0xEE))
#define C192X_F2(a, b) ZX(_mm512_shuffle_i64x2(a, b, 0x88), _mm512_shuffle_i64x2(a, b, 0xDD))
    __m512i T01 = C192X_F1(R0[p], R1[p]), T23 = C192X_F1(R2[p], R3[p]), T45 = C192X_F1(R4[p], R5[p]), T67 = C192X_F1(R6[p], R7[p]);
    __m512i Q0 = C192X_F2(T01, T23), Q1 = C192X_F2(T45, T67);              /* 128-bit lanes = blocks 0..3 / 4..7 */
    *LO = _mm512_permutex2var_epi64(Q0, _mm512_set_epi64(14, 12, 10, 8, 6, 4, 2, 0), Q1);
    *HI = _mm512_permutex2var_epi64(Q0, _mm512_set_epi64(15, 13, 11, 9, 7, 5, 3, 1), Q1); }
/* lane-parallel recombination of the 6 point sums (LO/HI limb-major) and reduction -> 3 limb-major zmm */
static inline void c192x_interp8(const __m512i LO[6], const __m512i HI[6], __m512i s[3]) {
    __m512i l01 = ZX(LO[0], LO[1]), h01 = ZX(HI[0], HI[1]);
    __m512i L0 = LO[0], L1 = ZT3(HI[0], l01, LO[3]), L2 = ZT3(ZX(h01, HI[3]), ZX(l01, LO[2]), LO[4]);
    __m512i L3 = ZT3(ZX(h01, HI[2]), HI[4], ZT3(LO[1], LO[2], LO[5])), L4 = ZT3(ZX(HI[1], HI[2]), HI[5], LO[2]), L5 = HI[2];
    __m512i ov = ZT3(_mm512_srli_epi64(L5, 63), _mm512_srli_epi64(L5, 62), _mm512_srli_epi64(L5, 57));
    __m512i og = ZT3(ov, _mm512_slli_epi64(ov, 1), ZX(_mm512_slli_epi64(ov, 2), _mm512_slli_epi64(ov, 7)));
    s[0] = ZT3(ZT3(L0, L3, _mm512_slli_epi64(L3, 1)), ZT3(_mm512_slli_epi64(L3, 2), _mm512_slli_epi64(L3, 7), og), _mm512_setzero_si512());
    s[1] = ZT3(ZT3(L1, L4, _mm512_shldi_epi64(L4, L3, 1)), _mm512_shldi_epi64(L4, L3, 2), _mm512_shldi_epi64(L4, L3, 7));
    s[2] = ZT3(ZT3(L2, L5, _mm512_shldi_epi64(L5, L4, 1)), _mm512_shldi_epi64(L5, L4, 2), _mm512_shldi_epi64(L5, L4, 7)); }
/* 8-lane product of limb-major X[3], Y[3] -> P[3] (reduced) */
static inline void c192x_mul8(const __m512i X[3], const __m512i Y[3], __m512i P[3]) {
    __m512i XP[6] = {X[0], X[1], X[2], ZX(X[0], X[1]), ZX(X[0], X[2]), ZX(X[1], X[2])};
    __m512i YP[6] = {Y[0], Y[1], Y[2], ZX(Y[0], Y[1]), ZX(Y[0], Y[2]), ZX(Y[1], Y[2])};
    __m512i LO[6], HI[6];
    for (int t = 0; t < 6; t++) { __m512i E = ZCL(XP[t], YP[t], 0x00), O = ZCL(XP[t], YP[t], 0x11); LO[t] = _mm512_unpacklo_epi64(E, O); HI[t] = _mm512_unpackhi_epi64(E, O); }
    c192x_interp8(LO, HI, P); }
/* block values B (limb-major, lane b = block b) of a full region -> acc (lanes 4..7: the chains): acc_c <- acc_c z + P_c */
static inline void c192x_outer(const c192x_key *x, const __m512i B[3], __m512i acc[3]) {
    const c192x_tab *xt_ = C192X_TB(x);
    const __m512i up = _mm512_set_epi64(3, 2, 1, 0, 3, 2, 1, 0), dn = _mm512_set_epi64(0, 0, 0, 0, 7, 6, 5, 4);
    __m512i X[3], Y[3], P[3];
    for (int l = 0; l < 3; l++) { X[l] = _mm512_mask_blend_epi64(0xF0, ZX(B[l], xt_->YO[l]), acc[l]); Y[l] = ZX(_mm512_maskz_permutexvar_epi64(0x0F, dn, B[l]), xt_->YEZ[l]); }
    c192x_mul8(X, Y, P);
    for (int l = 0; l < 3; l++) acc[l] = ZX(P[l], _mm512_permutexvar_epi64(up, P[l])); }
/* raw sums of 8 blocks (RAW[b][p]) -> block values, limb-major */
static inline void c192x_bend8(__m512i RAW[8][6], __m512i B[3]) {     /* RAW not const: ISO C rejects T (*)[6] -> const T (*)[6] */
    __m512i LO[6], HI[6];
    for (int p = 0; p < 6; p++) c192x_fold8(RAW[0], RAW[1], RAW[2], RAW[3], RAW[4], RAW[5], RAW[6], RAW[7], p, &LO[p], &HI[p]);
    c192x_interp8(LO, HI, B); }
static inline void c192x_regions(const c192x_key *x, const uint8_t *msg, size_t nr, __m512i acc[3], const uint8_t *end) {
    for (size_t r = 0; r < nr; r++) { const uint8_t *R = msg + r * C192_REGION; __m512i RAW[8][6], B[3];
#if C192X_SW == 2
        for (int b = 0; b < 8; b += 2) c192x_sweep2(x, R + 4096 * b, R + 4096 * (b + 1), RAW[b], RAW[b + 1]);
#else
        for (int b = 0; b < 8; b++) { const uint8_t *P = R + 4096 * b;          /* prefetch only blocks inside the input */
            if (x->pf && (size_t)(end - P) >= 4096 + (C192X_PFX ? 4 * 4096 : C192X_PFD) + 4096) c192x_sweep_pf(x, P, RAW[b]); else c192x_sweep(x, P, RAW[b]); }
#endif
        c192x_bend8(RAW, B); c192x_outer(x, B, acc); } }
static inline uint64_t c192x_hxor(__m512i v) { __m256i h = _mm256_xor_si256(_mm512_castsi512_si256(v), _mm512_extracti64x4_epi64(v, 1));
    __m128i q = _mm_xor_si128(_mm256_castsi256_si128(h), _mm256_extracti128_si256(h, 1)); return (uint64_t)_mm_cvtsi128_si64(q) ^ (uint64_t)_mm_extract_epi64(q, 1); }
static inline c192h c192x_chainsum(const __m512i acc[3]) {
    uint64_t w0 = c192x_hxor(_mm512_maskz_mov_epi64(0xF0, acc[0])), w1 = c192x_hxor(_mm512_maskz_mov_epi64(0xF0, acc[1])), w2 = c192x_hxor(_mm512_maskz_mov_epi64(0xF0, acc[2]));
    c192h r = {_mm_set_epi64x((long long)w1, (long long)w0), _mm_cvtsi64_si128((long long)w2)}; return r; }
/* 128-bit lane sum of a zmm */
static inline __m128i c192x_lsum(__m512i v) { __m256i h = _mm256_xor_si256(_mm512_castsi512_si256(v), _mm512_extracti64x4_epi64(v, 1)); return _mm_xor_si128(_mm256_castsi256_si128(h), _mm256_extracti128_si256(h, 1)); }
/* block values of the q blocks in [T, T + rem) as elements */
static inline void c192x_tailvals(const c192x_key *x, const uint8_t *T, size_t rem, c192h *e, int q) {
    if (q == 1) { __m512i A[6]; __m128i s[6]; if (rem >= 4096) c192x_sweep(x, T, A); else c192x_sweep_part(x, T, rem, A);
        for (int p = 0; p < 6; p++) { s[p] = c192x_lsum(A[p]); }
        e[0] = c192h_interp(s); return; }
    __m512i RAW[8][6], B[3];
    for (int b = 0; b < 8; b++) { size_t av = rem > 4096 * (size_t)b ? rem - 4096 * (size_t)b : 0; if (av > 4096) av = 4096;
        if (av == 4096) c192x_sweep(x, T + 4096 * (size_t)b, RAW[b]); else if (av) c192x_sweep_part(x, T + 4096 * (size_t)b, av, RAW[b]); else for (int p = 0; p < 6; p++) RAW[b][p] = _mm512_setzero_si512(); }
    c192x_bend8(RAW, B);
    uint64_t w[3][8]; for (int l = 0; l < 3; l++) _mm512_storeu_si512(w[l], B[l]);
    for (int b = 0; b < q; b++) { e[b].a = _mm_set_epi64x((long long)w[1][b], (long long)w[0][b]); e[b].b = _mm_cvtsi64_si128((long long)w[2][b]); } }
static inline c192h c192x_regfold(const c192x_key *x, c192h V, const uint8_t *T, size_t rem) {
    int q = (int)((rem + 4095) / 4096); c192h e[8]; c192x_tailvals(x, T, rem, e, q);
    __m128i R0, R1, R2; c192h_mulraw(V, x->zv, &R0, &R1, &R2); return c192h_cq(x->yp, e, q, R0, R1, R2); }
static inline c192h c192x_short(const c192x_key *x, const uint8_t *T, size_t n) {
    if (!n) return c192h_zero();
    if (n <= 64) return c192x_v64(&x->S, T, n);
    __m128i R0 = _mm_setzero_si128(), R1 = R0, R2 = R0; c192h_nz((uint64_t)n, x->zv, &R0, &R1);
    if (n <= 4096) { __m512i A[6]; __m128i s[6], S0, S1, S2; if (n == 4096) c192x_sweep(x, T, A); else c192x_sweep_part(x, T, n, A);
        for (int p = 0; p < 6; p++) { s[p] = c192x_lsum(A[p]); }
        c192h_interp_raw(s, &S0, &S1, &S2); return c192x_red(SX(R0, S0), SX(R1, S1), S2, c192h_zero()); }
    int q = (int)((n + 4095) / 4096); c192h e[8]; c192x_tailvals(x, T, n, e, q); return c192h_cq(x->yp, e, q, R0, R1, R2); }
static inline void c192x_hash(const c192x_key *x, const uint8_t *msg, size_t n, uint8_t out[24]) {
    size_t nr = n / C192_REGION, rem = n - nr * C192_REGION; c192h V;
    if (!nr) V = c192x_short(x, msg, n);
    else { const __m512i z = _mm512_setzero_si512(); __m512i acc[3] = {_mm512_mask_mov_epi64(z, 0x10, _mm512_set1_epi64((long long)n)), z, z};
        c192x_regions(x, msg, nr, acc, msg + n); V = c192x_chainsum(acc);
        if (rem) V = c192x_regfold(x, V, msg + nr * C192_REGION, rem); }
    c192h_out(c192x_fin(V, &x->XF), out); }
static inline void c192x_fold(const c192x_key *x, c192_el *V, const uint8_t *msg, size_t nr) {
    const __m512i z = _mm512_setzero_si512(); __m512i acc[3];
    for (int l = 0; l < 3; l++) acc[l] = _mm512_mask_mov_epi64(z, 0x10, _mm512_set1_epi64((long long)V->w[l]));
    c192x_regions(x, msg, nr, acc, msg + nr * C192_REGION); *V = c192h_st(c192x_chainsum(acc)); }
static inline void c192x_final(const c192x_key *x, c192_el V0, size_t nreg, const uint8_t *T, size_t rem, size_t n, uint8_t out[24]) {
    c192h V = c192h_ld(V0); size_t mp = nreg;
    if (rem) { V = c192x_regfold(x, V, T, rem); mp++; }
    __m128i R0 = _mm_setzero_si128(), R1 = R0; c192h_nz((uint64_t)n, c192h_pow(x->zv, mp), &R0, &R1);
    V = c192h_red(R0, R1, _mm_setzero_si128(), V);
    c192h_out(c192x_fin(V, &x->XF), out); }
C192X_INL c192_el c192x_mulk(c192_el a, c192_el b) { __m128i R0, R1, R2; c192x_mulk3(c192h_ld(a), c192h_ld(b), &R0, &R1, &R2); return c192h_st(c192x_red(R0, R1, R2, c192h_zero())); }
static inline void c192x_derive(const c192_raw *R, c192_key *K) { C192_DERIVE(R, K, c192x_mulk); }
static inline int c192x_is_amd(void) { unsigned r[4]; __asm__ volatile("cpuid" : "=a"(r[0]), "=b"(r[1]), "=c"(r[2]), "=d"(r[3]) : "a"(0), "c"(0)); return r[1] == 0x68747541u && r[3] == 0x69746e65u && r[2] == 0x444d4163u; }
static inline void c192x_key_init(c192x_key *x, const c192_key *K) {
    x->K = *K; x->toff = (unsigned)((64 - ((uintptr_t)x->tstore & 63)) & 63);
    c192x_tab *T = (c192x_tab *)(void *)(x->tstore + x->toff);
#ifdef C192X_PF_FORCE
    x->pf = C192X_PF_FORCE;
#else
    x->pf = !c192x_is_amd();
#endif
    for (int g = 0; g < 11; g++) for (int j = 0; j < 3; j++) { uint64_t a[8], b[8]; for (int t = 0; t < 8; t++) { a[t] = K->k[8 * g + t].w[j]; b[t] = K->l[8 * g + t].w[j]; }
        T->KZ[g][j] = _mm512_loadu_si512(a); T->KZ[g][3 + j] = _mm512_loadu_si512(b); }
    T->CK10 = ZX(ZCL(T->KZ[10][2], T->KZ[10][5], 0x00), ZCL(T->KZ[10][2], T->KZ[10][5], 0x11));
    { static const uint8_t zb[384] = {0}; __m512i A[6]; for (int q = 0; q < 6; q++) { A[q] = _mm512_setzero_si512(); T->SF[11][q] = A[q]; }
      A[2] = T->CK10; C192X_CHUNK10(A, zb, T->KZ[10]); for (int q = 0; q < 6; q++) T->SF[10][q] = A[q];
      for (int g = 9; g >= 0; g--) { C192X_CHUNK(A, zb, T->KZ[g]); for (int q = 0; q < 6; q++) T->SF[g][q] = A[q]; } }
    x->yp[0] = c192h_ld((c192_el){{1, 0, 0}}); for (int e = 1; e <= 8; e++) x->yp[e] = c192h_mul(x->yp[e - 1], c192h_ld(K->Y));
    x->zv = c192h_ld(K->z);
    for (int l = 0; l < 3; l++) { uint64_t a[8] = {0}, b[8]; for (int c = 0; c < 4; c++) { c192_el o = c192h_st(x->yp[2 * c + 1]), e = c192h_st(x->yp[2 * c + 2]); a[c] = o.w[l]; b[c] = e.w[l]; b[4 + c] = K->z.w[l]; }
        T->YO[l] = _mm512_loadu_si512(a); T->YEZ[l] = _mm512_loadu_si512(b); }
    __m128i s[6]; for (int p = 0; p < 6; p++) s[p] = c192x_lsum(T->SF[0][p]);
    c192h_fk_init(&x->F, K); c192h_sk_init(&x->S, K, c192h_st(c192h_interp(s))); c192x_fk_init(&x->XF, K); }
#if defined(__clang__)
#pragma clang attribute pop
#else
#pragma GCC pop_options
#endif
static inline uint64_t c192_xgetbv0(void) { uint32_t a, d; __asm__ volatile("xgetbv" : "=a"(a), "=d"(d) : "c"(0)); return ((uint64_t)d << 32) | a; }
static inline void c192_cpuid(unsigned leaf, unsigned sub, unsigned r[4]) { __asm__ __volatile__("cpuid" : "=a"(r[0]), "=b"(r[1]), "=c"(r[2]), "=d"(r[3]) : "a"(leaf), "c"(sub)); }
static inline int c192d_detect(void) {
    unsigned r[4], maxleaf; c192_cpuid(0, 0, r); maxleaf = r[0];
    if (maxleaf < 1) return C192_PORTABLE;
    c192_cpuid(1, 0, r); unsigned c = r[2];
    int pclmul = (c >> 1) & 1, sse41 = (c >> 19) & 1, osxsave = (c >> 27) & 1;
    int best = (pclmul && sse41) ? C192_PCLMUL : C192_PORTABLE;
    if (!osxsave || maxleaf < 7) return best;
    if ((c192_xgetbv0() & 0xE6) != 0xE6) return best;
    c192_cpuid(7, 0, r); unsigned b = r[1]; c = r[2];
    int f = (b >> 16) & 1, dq = (b >> 17) & 1, bw = (b >> 30) & 1, vl = (b >> 31) & 1, vpcl = (c >> 10) & 1, vbmi2 = (c >> 6) & 1;
    if (f && dq && bw && vl && vpcl && vbmi2 && pclmul && sse41) return C192_AVX512;
    return best; }
/* cached: CPUID traps to the hypervisor on VMs */
static inline int c192d_backend(void) { static int cached = -1; int v = cached; if (v < 0) { v = c192d_detect(); cached = v; } return v; }
#elif !defined(CHAINHASH192_PORTABLE) && defined(__aarch64__) && !defined(__AARCH64EB__) && (defined(__ARM_FEATURE_CRYPTO) || defined(__ARM_FEATURE_AES))
#define C192_ARM 1
/* ---------------------------------------------- NEON (PMULL) backend ----------------------------------------------
 * Block sweep: a q register holds limb j of pairs (2a, 2a+1) of ONE block (16 bytes of a 64-byte row); two blocks per
 * sweep share the key vectors.  Per step: 6 keyed limbs per block (plain EOR, pinned), the 6 Karatsuba-3 points
 * (x0, x1, x2, x0+x1, x0+x2, x1+x2), fused PMULL/PMULL2 + EOR into 6 point accumulators per block (both halves of a
 * register are pairs of the same block, so they sum into the same accumulator).  The 256-byte last chunk holds pairs
 * with zero top limbs: 5 data products per pair, the constant k_2 l_2 enters as an accumulator seed (CK10).
 * Block end: two blocks lane-parallel (zip), Karatsuba recombination, shift reduction mod x^192 + x^7 + x^2 + x + 1.
 * Region: the 4 pair products of the region formula lane-wise ((b0,b1) x (b4,b5), (b2,b3) x (b6,b7)) and V z summed into
 * the same 6 point sums; one recombination + reduction per region.
 * Short inputs: n <= 64: V = n z + C0 + sum_i d_i l_i (direct); n <= 4096: one block, partial chunk zero-filled, the
 * key-only chunks from suffix sums; the finalizer on q registers with PMULL reductions. */
#include <arm_neon.h>
typedef uint64x2_t c192q;
#define CQX(a, b) veorq_u64(a, b)
#if defined(__ARM_FEATURE_SHA3)
#define CQX3(a, b, c) veor3q_u64(a, b, c)
#else
#define CQX3(a, b, c) veorq_u64(veorq_u64(a, b), c)
#endif
#define CPM1(a, b) vreinterpretq_u64_p128(vmull_p64(vgetq_lane_p64(vreinterpretq_p64_u64(a), 0), vgetq_lane_p64(vreinterpretq_p64_u64(b), 0)))
#define CPM2(a, b) vreinterpretq_u64_p128(vmull_high_p64(vreinterpretq_p64_u64(a), vreinterpretq_p64_u64(b)))
#if defined(C192_NOASM)
#define C192N_MACL(acc, a, b) (acc) = CQX(acc, CPM1(a, b))
#define C192N_MACH(acc, a, b) (acc) = CQX(acc, CPM2(a, b))
static inline c192q C192N_E(c192q a, c192q b) { return veorq_u64(a, b); }
#else
/* the fusable form (Apple cores fuse PMULL + EOR when the EOR writes the PMULL destination) */
#define C192N_MACL(acc, a, b) do { c192q t_; __asm__("pmull %0.1q, %1.1d, %2.1d\n\teor %0.16b, %0.16b, %3.16b" : "=&w"(t_) : "w"(a), "w"(b), "w"(acc)); (acc) = t_; } while (0)
#define C192N_MACH(acc, a, b) do { c192q t_; __asm__("pmull2 %0.1q, %1.2d, %2.2d\n\teor %0.16b, %0.16b, %3.16b" : "=&w"(t_) : "w"(a), "w"(b), "w"(acc)); (acc) = t_; } while (0)
/* pinned plain EOR: clang otherwise merges chains into EOR3 (lower issue rate on the M2) */
static inline __attribute__((always_inline)) c192q C192N_E(c192q a, c192q b) { c192q r; __asm__("eor %0.16b, %1.16b, %2.16b" : "=w"(r) : "w"(a), "w"(b)); return r; }
#endif
#define CNLD(p) vld1q_u64((const uint64_t *)(p))
/* opaque address: LLVM's loop data prefetch pass (on for Apple CPU tuning) otherwise inserts prfm 8 KiB ahead of the
 * loads of every message loop; near the end of the input they hit unmapped or TLB-cold pages, and on the M2 that costs
 * a page walk per prfm (ChainHash-192 ran at 17-20 GB/s instead of 51 whenever a guard page followed the message) */
#define C192N_OPQ(p) __asm__("" : "+r"(p))
#if defined(C192_NOASM)
#define C192N_HV(v) do { } while (0)
#define C192N_BIT(d, n, m) (d) = vbslq_u64(m, n, d)
#else
#define C192N_HV(v) __asm__("" : "+w"(v))
/* d = m ? n : d bitwise, one BIT (clang otherwise lowers vbslq to and/bic/orr: two levels) */
#define C192N_BIT(d, n, m) __asm__("bit %0.16b, %1.16b, %2.16b" : "+w"(d) : "w"(n), "w"(m))
#endif
#define C192N_INL static inline __attribute__((always_inline))
#if defined(__clang__)
#define C192N_UNROLL _Pragma("clang loop unroll(full)")
#else
#define C192N_UNROLL _Pragma("GCC unroll 64")
#endif
typedef uint64x2_t c192qu __attribute__((aligned(8)));     /* key storage (8-byte alignment, as on x86) */
typedef struct { c192qu a, b; } c192v;       /* element: a = limbs (0, 1), b = (limb 2, unused) */
typedef struct {
    c192_key K;
    c192qu KP[44][6];          /* [pair pair a][x limbs 0..2, y limbs 0..2], lanes = pairs 2a, 2a+1 */
    c192qu SF[12][6];          /* key-only raw point sums of chunks g..10 (SF[11] = 0) */
    c192qu CK10;               /* sum over pairs 80..87 of k_i2 l_i2 (point 2 of the zero-top-limb pairs) */
    c192qu YA[2][3], YB[2][3]; /* region masks, limb-major: YA[0] = (y^1, y^3), YA[1] = (y^5, y^7); YB[0] = (y^2, y^4), YB[1] = (y^6, y^8) */
    c192qu ZP[6];              /* Karatsuba points of z (dup) */
    c192v Zv, YP[9];          /* z, y^e */
    c192v CKS[11];            /* key-only element sums: CKS[g] = sum_{i >= 8g} k_i l_i (CKS[0] = the key-only block value) */
    c192v tau, tau1, ntau, cc[5]; c192qu nt0d, nt1d, Gd; c192_el tau_e;     /* finalizer: tau, tau + 1 per limb, ~tau, ~tau_0, ~tau_1 (dup) */
    c192qu L8[4][3], Zd[3];    /* n <= 64: (l_2j limb l, l_2j+1 limb l); z limb l (dup) */
} c192n_key;
static inline c192q c192n_pair(uint64_t a, uint64_t b) { return vcombine_u64(vcreate_u64(a), vcreate_u64(b)); }
static inline c192_el c192_red6(const uint64_t r[6]) {          /* shift reduction (lo + hi (1 + x + x^2 + x^7)) */
    uint64_t h[4] = {0, r[3], r[4], r[5]}; c192_el o;
    for (int l = 0; l < 3; l++) o.w[l] = r[l] ^ h[l + 1] ^ ((h[l + 1] << 1) | (h[l] >> 63)) ^ ((h[l + 1] << 2) | (h[l] >> 62)) ^ ((h[l + 1] << 7) | (h[l] >> 57));
    uint64_t ov = (r[5] >> 63) ^ (r[5] >> 62) ^ (r[5] >> 57); o.w[0] ^= ov ^ (ov << 1) ^ (ov << 2) ^ (ov << 7); return o; }
C192N_INL c192_el c192n_mulk(c192_el a, c192_el b) {          /* key setup multiply: 9 PMULL + shift reduction */
    uint64_t r[6] = {0, 0, 0, 0, 0, 0};
    for (int i = 0; i < 3; i++) for (int j = 0; j < 3; j++) { c192q p = vreinterpretq_u64_p128(vmull_p64((poly64_t)a.w[i], (poly64_t)b.w[j]));
        r[i + j] ^= vgetq_lane_u64(p, 0); r[i + j + 1] ^= vgetq_lane_u64(p, 1); }
    return c192_red6(r); }
static inline c192v c192v_ld(c192_el e) { c192v r = {vld1q_u64(&e.w[0]), vcombine_u64(vcreate_u64(e.w[2]), vcreate_u64(0))}; return r; }
static inline c192_el c192v_st(c192v v) { c192_el e; vst1q_u64(&e.w[0], v.a); e.w[2] = vgetq_lane_u64(v.b, 0); return e; }
static inline c192v c192v_x(c192v x, c192v y) { c192v r = {CQX(x.a, y.a), CQX(x.b, y.b)}; return r; }
static inline void c192v_out(c192v v, uint8_t out[24]) { vst1q_u8(out, vreinterpretq_u8_u64(v.a)); vst1_u8(out + 16, vreinterpret_u8_u64(vget_low_u64(v.b))); }
/* (R0, R1, R2) = limbs (0,1), (2,3), (4,5) of a 384-bit value -> reduced + E: the high limbs times g = 0x87 by PMULL
 * (g has degree 7, so h g < 2^71: the limb-3 overflow is folded by one more PMULL) */
C192N_INL c192v c192v_red(c192q R0, c192q R1, c192q R2, c192q Gd, c192v E) {
    c192q z = vdupq_n_u64(0);
    c192q g3 = CPM2(R1, Gd), g4 = CPM1(R2, Gd), g5 = CPM2(R2, Gd), og = CPM2(g5, Gd);
    c192v r = {CQX3(CQX3(R0, g3, og), vextq_u64(z, g4, 1), E.a), CQX3(CQX(R1, g5), vextq_u64(g4, z, 1), E.b)}; return r; }
/* 192 x 192 schoolbook, 9 PMULL -> (R0, R1, R2) unreduced; ys = y.a limb-swapped, y2h = (., y2) */
C192N_INL void c192v_mulraw_s(c192v x, c192v y, c192q ys, c192q y2h, c192q *R0, c192q *R1, c192q *R2) {
    c192q z = vdupq_n_u64(0);
    c192q p0 = CPM1(x.a, y.a), p1 = CQX(CPM1(x.a, ys), CPM2(x.a, ys)), p2 = CQX3(CPM2(x.a, y.a), CPM1(x.a, y.b), CPM1(x.b, y.a));
    c192q p3 = CQX(CPM2(x.a, y2h), CPM1(x.b, ys)), p4 = CPM1(x.b, y.b);
    *R0 = CQX(p0, vextq_u64(z, p1, 1)); *R1 = CQX3(p2, vextq_u64(p1, p3, 1), z); *R2 = CQX(p4, vextq_u64(p3, z, 1)); }
C192N_INL void c192v_mulraw(c192v x, c192v y, c192q *R0, c192q *R1, c192q *R2) { c192v_mulraw_s(x, y, vextq_u64(y.a, y.a, 1), vextq_u64(y.b, y.b, 1), R0, R1, R2); }
C192N_INL c192v c192v_mul(c192v x, c192v y, c192q Gd) { c192q R0, R1, R2; c192v_mulraw(x, y, &R0, &R1, &R2); c192v z0 = {vdupq_n_u64(0), vdupq_n_u64(0)}; return c192v_red(R0, R1, R2, Gd, z0); }
C192N_INL c192v c192v_sq(c192v x, c192q Gd) { c192v z0 = {vdupq_n_u64(0), vdupq_n_u64(0)}; return c192v_red(CPM1(x.a, x.a), CPM2(x.a, x.a), CPM1(x.b, x.b), Gd, z0); }
/* 6 Karatsuba-3 point sums (128-bit) -> (R0, R1, R2) unreduced:
 * C0 = P0, C1 = P0+P1+P3, C2 = P0+P1+P2+P4, C3 = P1+P2+P5, C4 = P2 at limb offsets 0..4 */
C192N_INL void c192n_interp_raw(const c192qu q[6], c192q *R0, c192q *R1, c192q *R2) {
    c192q z = vdupq_n_u64(0), q01 = CQX(q[0], q[1]), q12 = CQX(q[1], q[2]);
    c192q C1 = CQX(q01, q[3]), C2 = CQX3(q01, q[2], q[4]), C3 = CQX(q12, q[5]);
    *R0 = CQX(q[0], vextq_u64(z, C1, 1)); *R1 = CQX3(vextq_u64(C1, z, 1), C2, vextq_u64(z, C3, 1)); *R2 = CQX(vextq_u64(C3, z, 1), q[2]); }
C192N_INL c192v c192n_interp(const c192qu q[6], c192q Gd) { c192q R0, R1, R2; c192n_interp_raw(q, &R0, &R1, &R2); c192v z0 = {vdupq_n_u64(0), vdupq_n_u64(0)}; return c192v_red(R0, R1, R2, Gd, z0); }
/* ---- block sweep steps (pairs 2a, 2a+1 of one block at p; k = KP[a]) ---- */
#define C192N_STEP(A, p, k) do { \
        c192q x0 = C192N_E(CNLD(p), (k)[0]), x1 = C192N_E(CNLD((p) + 64), (k)[1]), x2 = C192N_E(CNLD((p) + 128), (k)[2]); \
        c192q y0 = C192N_E(CNLD((p) + 192), (k)[3]), y1 = C192N_E(CNLD((p) + 256), (k)[4]), y2 = C192N_E(CNLD((p) + 320), (k)[5]); \
        C192N_MACL((A)[0], x0, y0); C192N_MACH((A)[0], x0, y0); C192N_MACL((A)[1], x1, y1); C192N_MACH((A)[1], x1, y1); \
        C192N_MACL((A)[2], x2, y2); C192N_MACH((A)[2], x2, y2); \
        { c192q u_ = C192N_E(x0, x1), v_ = C192N_E(y0, y1); C192N_MACL((A)[3], u_, v_); C192N_MACH((A)[3], u_, v_); } \
        { c192q u_ = C192N_E(x0, x2), v_ = C192N_E(y0, y2); C192N_MACL((A)[4], u_, v_); C192N_MACH((A)[4], u_, v_); } \
        { c192q u_ = C192N_E(x1, x2), v_ = C192N_E(y1, y2); C192N_MACL((A)[5], u_, v_); C192N_MACH((A)[5], u_, v_); } } while (0)
/* the last chunk: rows x0, x1, y0, y1; the top limbs are the keys k2, l2 (their product is the CK10 seed) */
#define C192N_STEP10(A, p, k) do { \
        c192q x0 = C192N_E(CNLD(p), (k)[0]), x1 = C192N_E(CNLD((p) + 64), (k)[1]); \
        c192q y0 = C192N_E(CNLD((p) + 128), (k)[3]), y1 = C192N_E(CNLD((p) + 192), (k)[4]); \
        C192N_MACL((A)[0], x0, y0); C192N_MACH((A)[0], x0, y0); C192N_MACL((A)[1], x1, y1); C192N_MACH((A)[1], x1, y1); \
        { c192q u_ = C192N_E(x0, x1), v_ = C192N_E(y0, y1); C192N_MACL((A)[3], u_, v_); C192N_MACH((A)[3], u_, v_); } \
        { c192q u_ = C192N_E(x0, (k)[2]), v_ = C192N_E(y0, (k)[5]); C192N_MACL((A)[4], u_, v_); C192N_MACH((A)[4], u_, v_); } \
        { c192q u_ = C192N_E(x1, (k)[2]), v_ = C192N_E(y1, (k)[5]); C192N_MACL((A)[5], u_, v_); C192N_MACH((A)[5], u_, v_); } } while (0)
/* two full blocks at P0, P1 -> raw point sums A, B; the next blocks' first lines are prefetched from pf (if set) */
#ifndef C192N_PF
#define C192N_PF 0
#endif
/* step barrier: the loads of a step are not hoisted above the previous step's products (bounded register pressure: no
 * spill stores in the sweep).  -DC192N_SBAR=0 removes it (same values). */
#ifndef C192N_SBAR
#define C192N_SBAR 1
#endif
#if C192N_SBAR
#define C192N_SB() __asm__ volatile("" ::: "memory")
#else
#define C192N_SB() do { } while (0)
#endif
static inline __attribute__((always_inline)) void c192n_sweep2(const c192n_key *x, const uint8_t *P0, const uint8_t *P1, c192q A[6], c192q B[6], const uint8_t *pf) {
    c192q z = vdupq_n_u64(0);
    for (int p = 0; p < 6; p++) A[p] = B[p] = z;
    A[2] = B[2] = x->CK10; (void)pf;
    /* the key table pointer is opaque per call: otherwise clang hoists the 4.2 KiB of key loads out of the region's
     * block-pair loop by copying the table to the stack once per region (3.5 KiB of stores whose addresses can alias the
     * data loads: M2 runs at 0.43-0.84x in some processes) */
    const c192qu (*KP)[6] = x->KP; __asm__("" : "+r"(KP));
    C192N_UNROLL
    for (int a = 0; a < 40; a++) { size_t o = 384 * (size_t)(a >> 2) + 16 * (size_t)(a & 3); const c192qu *k = KP[a];
#if C192N_PF
        if (pf && (a & 1) == 0) { __builtin_prefetch(pf + 128 * (a >> 1), 0, 3); __builtin_prefetch(pf + 4096 + 128 * (a >> 1), 0, 3); }
#endif
        C192N_STEP(A, P0 + o, k); C192N_SB(); C192N_STEP(B, P1 + o, k); C192N_SB(); }
    C192N_UNROLL
    for (int a = 40; a < 44; a++) { size_t o = 3840 + 16 * (size_t)(a - 40); const c192qu *k = KP[a];
        C192N_STEP10(A, P0 + o, k); C192N_SB(); C192N_STEP10(B, P1 + o, k); C192N_SB(); }
}
/* one block with av (1..4096) data bytes at p (no read past p + av): full chunks direct, the partial chunk from a
 * zero-filled copy, the key-only chunks from SF; two accumulator sets (PMULL / PMULL2 alternate steps) for latency */
static inline void c192n_sweep1(const c192n_key *x, const uint8_t *p, size_t av, c192q A[6]) {
    if (av >= C192_BLOCK) {                              /* a full block: straight-line, two accumulator sets */
        c192q B[6], z = vdupq_n_u64(0);
        for (int q = 0; q < 6; q++) { A[q] = z; B[q] = z; }
        A[2] = x->CK10;
        C192N_UNROLL
        for (int a = 0; a < 40; a++) { const uint8_t *r = p + 384 * (size_t)(a >> 2) + 16 * (size_t)(a & 3); if (a & 1) C192N_STEP(B, r, x->KP[a]); else C192N_STEP(A, r, x->KP[a]); }
        C192N_UNROLL
        for (int a = 40; a < 44; a++) { const uint8_t *r = p + 3840 + 16 * (size_t)(a - 40); if (a & 1) C192N_STEP10(B, r, x->KP[a]); else C192N_STEP10(A, r, x->KP[a]); }
        for (int q = 0; q < 6; q++) A[q] = CQX(A[q], B[q]);
        return; }
    int nf = (int)(av / 384), ng; if (nf > 10) nf = 10;
    size_t done = (size_t)384 * nf; ng = nf + (av > done ? 1 : 0);
    c192q B[6], z = vdupq_n_u64(0);
    for (int q = 0; q < 6; q++) { A[q] = x->SF[ng][q]; B[q] = z; }
    for (int g = 0; g < nf; g++) { const uint8_t *r = p + 384 * (size_t)g; C192N_OPQ(r);
        C192N_UNROLL
        for (int u = 0; u < 4; u++) { const c192qu *k = x->KP[4 * g + u]; if (u & 1) C192N_STEP(B, r + 16 * u, k); else C192N_STEP(A, r + 16 * u, k); } }
    if (ng > nf) {
        uint8_t buf[384] __attribute__((aligned(16))); size_t k = av - done; memset(buf, 0, sizeof buf); memcpy(buf, p + done, k);
        if (nf < 10) { C192N_UNROLL for (int u = 0; u < 4; u++) { const c192qu *kk = x->KP[4 * nf + u]; if (u & 1) C192N_STEP(B, buf + 16 * u, kk); else C192N_STEP(A, buf + 16 * u, kk); } }
        else { A[2] = CQX(A[2], x->CK10); C192N_UNROLL for (int u = 0; u < 4; u++) { const c192qu *kk = x->KP[40 + u]; if (u & 1) C192N_STEP10(B, buf + 16 * u, kk); else C192N_STEP10(A, buf + 16 * u, kk); } } }
    for (int q = 0; q < 6; q++) A[q] = CQX(A[q], B[q]);
}
/* two blocks' raw point sums -> their values, limb-major (s[l] = limb l of (block A, block B)) */
C192N_INL void c192n_bend2(const c192q A[6], const c192q B[6], c192q s[3]) {
    c192q lo[6], hi[6];
    for (int p = 0; p < 6; p++) { lo[p] = vzip1q_u64(A[p], B[p]); hi[p] = vzip2q_u64(A[p], B[p]); }
    c192q l01 = CQX(lo[0], lo[1]), h01 = CQX(hi[0], hi[1]);
    c192q L0 = lo[0], L1 = CQX3(hi[0], l01, lo[3]), L2 = CQX3(CQX(h01, hi[3]), CQX(l01, lo[2]), lo[4]);
    c192q L3 = CQX3(CQX(h01, hi[2]), hi[4], CQX3(lo[1], lo[2], lo[5])), L4 = CQX3(CQX(hi[1], hi[2]), hi[5], lo[2]), L5 = hi[2];
    c192q ov = CQX3(vshrq_n_u64(L5, 63), vshrq_n_u64(L5, 62), vshrq_n_u64(L5, 57));
    s[0] = CQX3(CQX3(L0, L3, vshlq_n_u64(L3, 1)), vshlq_n_u64(L3, 2), vshlq_n_u64(L3, 7));
    s[0] = CQX3(CQX3(s[0], ov, vshlq_n_u64(ov, 1)), vshlq_n_u64(ov, 2), vshlq_n_u64(ov, 7));
    s[1] = CQX3(CQX3(L1, L4, vsliq_n_u64(vshrq_n_u64(L3, 63), L4, 1)), vsliq_n_u64(vshrq_n_u64(L3, 62), L4, 2), vsliq_n_u64(vshrq_n_u64(L3, 57), L4, 7));
    s[2] = CQX3(CQX3(L2, L5, vsliq_n_u64(vshrq_n_u64(L4, 63), L5, 1)), vsliq_n_u64(vshrq_n_u64(L4, 62), L5, 2), vsliq_n_u64(vshrq_n_u64(L4, 57), L5, 7));
}
/* limb-major lane j of s -> element */
C192N_INL c192v c192n_lane(const c192q s[3], int j) {
    c192v r; if (j) { r.a = vzip2q_u64(s[0], s[1]); r.b = vextq_u64(s[2], s[2], 1); } else { r.a = vzip1q_u64(s[0], s[1]); r.b = s[2]; } return r; }
/* points (6) of a limb triple */
#define C192N_PTS(P, a0, a1, a2) c192q P[6]; P[0] = a0; P[1] = a1; P[2] = a2; P[3] = CQX(a0, a1); P[4] = CQX(a0, a2); P[5] = CQX(a1, a2)
/* one full region: V <- V z + sum_{c<4} (b_c + y^(2c+1)) (b_{c+4} + y^(2c+2)) */
static inline c192v c192n_region(const c192n_key *x, c192v V, const uint8_t *R, const uint8_t *Rn) {
    c192q s[4][3];
    for (int c = 0; c < 4; c++) { c192q A[6], B[6]; const uint8_t *P = R + 8192 * (size_t)c; C192N_OPQ(P);
        c192n_sweep2(x, P, P + 4096, A, B, Rn ? Rn + 8192 * (size_t)c : (c < 3 ? R + 8192 * (size_t)(c + 1) : 0));
        c192n_bend2(A, B, s[c]); }
    c192q U0[3], W0[3], U1[3], W1[3];
    for (int l = 0; l < 3; l++) { U0[l] = CQX(s[0][l], x->YA[0][l]); W0[l] = CQX(s[2][l], x->YB[0][l]); U1[l] = CQX(s[1][l], x->YA[1][l]); W1[l] = CQX(s[3][l], x->YB[1][l]); }
    C192N_PTS(PU0, U0[0], U0[1], U0[2]); C192N_PTS(PW0, W0[0], W0[1], W0[2]); C192N_PTS(PU1, U1[0], U1[1], U1[2]); C192N_PTS(PW1, W1[0], W1[1], W1[2]);
    C192N_PTS(PV, V.a, vextq_u64(V.a, V.a, 1), V.b);
    c192q q[6];
    for (int t = 0; t < 6; t++) q[t] = CQX(CQX3(CPM1(PU0[t], PW0[t]), CPM2(PU0[t], PW0[t]), CPM1(PU1[t], PW1[t])), CQX(CPM2(PU1[t], PW1[t]), CPM1(PV[t], x->ZP[t])));
    return c192n_interp(q, x->Gd);
}
/* block values of the q (1..8) blocks in [T, T + rem) (the last possibly partial) */
static inline void c192n_tailvals(const c192n_key *x, const uint8_t *T, size_t rem, c192v *e, int q) {
    int b = 0;
    while (b + 2 <= q && (size_t)(b + 2) * 4096 <= rem) { c192q A[6], B[6], s[3]; const uint8_t *P = T + 4096 * (size_t)b; C192N_OPQ(P); c192n_sweep2(x, P, P + 4096, A, B, 0);
        c192n_bend2(A, B, s); e[b] = c192n_lane(s, 0); e[b + 1] = c192n_lane(s, 1); b += 2; }
    for (; b < q; b++) { c192q A[6]; size_t av = rem - 4096 * (size_t)b; if (av > 4096) av = 4096; const uint8_t *P = T + 4096 * (size_t)b; C192N_OPQ(P); c192n_sweep1(x, P, av, A); e[b] = c192n_interp(A, x->Gd); }
}
/* unreduced product accumulated into r[0..2] */
C192N_INL void c192v_mac(c192q r[3], c192v u, c192v w) { c192q R0, R1, R2; c192v_mulraw(u, w, &R0, &R1, &R2); r[0] = CQX(r[0], R0); r[1] = CQX(r[1], R1); r[2] = CQX(r[2], R2); }
/* region value of e[0..q-1] plus the unreduced r: one reduction */
static inline c192v c192n_cq(const c192n_key *x, c192q r[3], const c192v *e, int q) {
    int h = (q + 1) / 2, f = q / 2;
    for (int i = 1; i <= f; i++) c192v_mac(r, c192v_x(e[i - 1], x->YP[2 * i - 1]), c192v_x(e[h + i - 1], x->YP[2 * i]));
    c192v z0 = {vdupq_n_u64(0), vdupq_n_u64(0)};
    c192v v = c192v_red(r[0], r[1], r[2], x->Gd, (q & 1) ? e[h - 1] : z0);
    return v; }
/* V <- V z + c(tail region of rem bytes) */
static inline c192v c192n_tailfold(const c192n_key *x, c192v V, const uint8_t *T, size_t rem) {
    int q = (int)((rem + 4095) / 4096); c192v e[8]; c192n_tailvals(x, T, rem, e, q);
    c192q z = vdupq_n_u64(0), r[3] = {z, z, z}; c192v_mac(r, V, x->Zv); return c192n_cq(x, r, e, q); }
/* n (< 2^64) times z, unreduced */
C192N_INL void c192n_nz(const c192n_key *x, uint64_t n, c192q r[3]) {
    c192q nv = vdupq_n_u64(n), z = vdupq_n_u64(0);
    c192q a0 = CPM1(nv, x->Zv.a), a1 = CPM2(nv, x->Zv.a), b0 = CPM1(nv, x->Zv.b);
    r[0] = CQX3(r[0], a0, vextq_u64(z, a1, 1)); r[1] = CQX3(r[1], vextq_u64(a1, z, 1), b0); }
/* 16 bytes at p with k (1..16) valid, zero-filled; no read past p + k and no store-to-load round trip */
static inline c192q c192n_ld16(const uint8_t *p, size_t k) {
    if (k >= 16) return vld1q_u64((const uint64_t *)p);
    if (k >= 8) { uint64x1_t lo = vld1_u64((const uint64_t *)p), hi = vdup_n_u64(0);
        if (k > 8) hi = vshl_u64(vld1_u64((const uint64_t *)(p + k - 8)), vdup_n_s64(-(int64_t)(8 * (16 - k))));
        return vcombine_u64(lo, hi); }
    uint64_t lo;
    if (k >= 4) { uint32_t a, b; memcpy(&a, p, 4); memcpy(&b, p + k - 4, 4); lo = (uint64_t)a | ((uint64_t)b << (8 * (k - 4))); }
    else lo = (uint64_t)p[0] | ((uint64_t)p[k >> 1] << (8 * (k >> 1))) | ((uint64_t)p[k - 1] << (8 * (k - 1)));
    return vcombine_u64(vcreate_u64(lo), vdup_n_u64(0)); }
/* x y + E with the reduction applied to the unaligned product pieces (PMULL is linear): p_d = the 128-bit sum at limb
 * offset d; limbs >= 3 times g = 0x87 (the limb-5 part overflows into limb 3 once more: og); one realignment (EXT) */
C192N_INL c192v c192v_mule(c192v x, c192v y, c192q ys, c192q y2h, c192q Gd, c192v E) {
    c192q z = vdupq_n_u64(0);
    c192q p0 = CPM1(x.a, y.a), p1 = CQX(CPM1(x.a, ys), CPM2(x.a, ys)), p2 = CQX3(CPM2(x.a, y.a), CPM1(x.a, y.b), CPM1(x.b, y.a));
    c192q p3 = CQX(CPM2(x.a, y2h), CPM1(x.b, ys)), p4 = CPM1(x.b, y.b);
    c192q h0g = CQX(CPM2(p2, Gd), CPM1(p3, Gd)), h1g = CQX(CPM2(p3, Gd), CPM1(p4, Gd)), h2g = CPM2(p4, Gd), og = CPM2(h2g, Gd);
    c192q B = CQX(p1, h1g);
    c192v r = {CQX3(CQX3(p0, h0g, og), vextq_u64(z, B, 1), E.a), CQX3(CQX(p2, h2g), vextq_u64(B, z, 1), E.b)}; return r; }
/* X = v + tau as 192-bit integers (GPR add/adc chain: on the M2 ahead of a vector carry lookahead) */
C192N_INL c192v c192n_addint(c192v v, const c192_el *t) {
    uint64_t a0 = vgetq_lane_u64(v.a, 0), a1 = vgetq_lane_u64(v.a, 1), a2 = vgetq_lane_u64(v.b, 0), c;
    uint64_t s0 = __builtin_addcll(a0, t->w[0], 0, &c), s1 = __builtin_addcll(a1, t->w[1], c, &c), s2 = a2 + t->w[2] + c;
    c192v r = {c192n_pair(s0, s1), vcombine_u64(vcreate_u64(s2), vcreate_u64(0))}; return r; }
/* X = V +_Z tau; G = X^2 -> U = G + c0 and W = G + X + c1 from one reduction; T = U W + c3; out = (X + c2) T + c4.
 * The twist is folded into the square (carry-select): with s_i = v_i + tau_i the per-limb sums and m_i the carry-in
 * mask of limb i, X_i = m_i ? s_i + 1 : s_i, so X_i^2 = m_i ? (s_i + 1)^2 : s_i^2 (one BSL); both squares start right
 * after the per-limb adds (s_i + 1 = v_i + (tau_i + 1), precomputed) while the carry lookahead runs beside them on
 * broadcast limbs (m_1 = g_0 = [v_0 > ~tau_0], m_2 = g_1 | p_1 g_0 = BSL(p_1, g_0, g_1), p_1 = [v_1 == ~tau_1]).  C192N_FIN_GPR=1 selects the GPR add/adc twist instead (same values). */
#ifndef C192N_FIN_GPR
#define C192N_FIN_GPR 0
#endif
static inline c192v c192n_fin(const c192n_key *x, c192v v) {
    c192q Gd = x->Gd, z = vdupq_n_u64(0);
#if C192N_FIN_GPR
    c192v X = c192n_addint(v, &x->tau_e), X2 = c192v_x(X, x->cc[2]);
    c192q S0 = CPM1(X.a, X.a), S1 = CPM2(X.a, X.a), S2 = CPM1(X.b, X.b);
#else
    c192q sa = vaddq_u64(v.a, x->tau.a), sb = vaddq_u64(v.b, x->tau.b), sa1 = vaddq_u64(v.a, x->tau1.a), sb1 = vaddq_u64(v.b, x->tau1.b);
    c192q S0 = CPM1(sa, sa), S1s = CPM2(sa, sa), S2s = CPM1(sb, sb), P1 = CPM2(sa1, sa1), P2 = CPM1(sb1, sb1);
    c192q dv0 = vdupq_laneq_u64(v.a, 0), dv1 = vdupq_laneq_u64(v.a, 1);
    c192q m1 = vcgtq_u64(dv0, x->nt0d), g1 = vcgtq_u64(dv1, x->nt1d), p1 = vceqq_u64(dv1, x->nt1d);
    C192N_HV(m1); C192N_HV(g1); C192N_HV(p1);            /* opaque: clang otherwise narrows the masks (xtn .. cmlt, +10 cycles) */
    c192q m2 = g1; C192N_BIT(m2, m1, p1);                                 /* g1 | p1 g0 (g1, p1 exclusive) */
    c192q S1 = S1s, S2 = S2s, Xa = sa, Xb = sb; C192N_BIT(S1, P1, m1); C192N_BIT(S2, P2, m2); C192N_BIT(Xa, sa1, vextq_u64(z, m1, 1)); C192N_BIT(Xb, sb1, m2);
    c192v X = {Xa, Xb}, X2 = c192v_x(X, x->cc[2]);
#endif
    c192q x2s = vextq_u64(X2.a, X2.a, 1), x2h = vextq_u64(X2.b, X2.b, 1);              /* X + c2 is ready early: its swaps too */
    c192q h0g = CPM2(S1, Gd), h1g = CPM1(S2, Gd), h2g = CPM2(S2, Gd), og = CPM2(h2g, Gd);
    c192q Ga = CQX3(CQX(S0, h0g), og, vextq_u64(z, h1g, 1)), Gb = CQX3(S1, h2g, vextq_u64(h1g, z, 1));
    c192v U = {CQX(Ga, x->cc[0].a), CQX(Gb, x->cc[0].b)}, W = {CQX3(Ga, X.a, x->cc[1].a), CQX3(Gb, X.b, x->cc[1].b)};
    c192v T = c192v_mule(U, W, vextq_u64(W.a, W.a, 1), vextq_u64(W.b, W.b, 1), Gd, x->cc[3]);
    return c192v_mule(T, X2, x2s, x2h, Gd, x->cc[4]); }
/* n <= 16, chunk 0 of k (1..15) bytes: the bytes a dependent caller may just have written (0..3) by ONE load straight
 * into a vector register (ldr b/h/s/d; a GPR assembly + fmov costs ~8 cycles), the rest from loads at higher addresses.
 * The products are linear in the data, so the two parts are multiplied separately: A (lane 0 = word 0 or its low
 * bytes) by lane 0 of the key pair, B by lane 1 (word 1, k > 8) or lane 0 (bytes 4..k-1 of word 0, k < 8) */
static inline uint64_t c192n_rest(const uint8_t *p, size_t k) {     /* k (0..3) bytes at p, zero-filled */
    if (!k) return 0;
    return (uint64_t)p[0] | ((uint64_t)p[k >> 1] << (8 * (k >> 1))) | ((uint64_t)p[k - 1] << (8 * (k - 1))); }
C192N_INL void c192n_acc0(const c192n_key *x, const uint8_t *p, size_t k, c192q Q[3]) {
    c192q z = vdupq_n_u64(0), A, B;
    if (k >= 8) { uint64_t a; memcpy(&a, p, 8); A = vcombine_u64(vcreate_u64(a), vdup_n_u64(0));
        if (k >= 12) { uint64_t h; memcpy(&h, p + k - 8, 8); B = vcombine_u64(vdup_n_u64(0), vcreate_u64(h >> (8 * (16 - k)))); }
        else B = vcombine_u64(vdup_n_u64(0), vcreate_u64(c192n_rest(p + 8, k - 8)));
        for (int l = 2; l >= 0; l--) Q[l] = CQX3(Q[l], CPM1(A, x->L8[0][l]), CPM2(B, x->L8[0][l]));
        return; }
    if (k >= 4) { uint32_t a; memcpy(&a, p, 4); A = vreinterpretq_u64_u32(vsetq_lane_u32(a, vdupq_n_u32(0), 0));
        B = vcombine_u64(vcreate_u64(c192n_rest(p + 4, k - 4) << 32), vdup_n_u64(0)); }
    else if (k >= 2) { uint16_t a; memcpy(&a, p, 2); A = vreinterpretq_u64_u16(vsetq_lane_u16(a, vdupq_n_u16(0), 0)); B = z;
        if (k == 3) A = vreinterpretq_u64_u8(vld1q_lane_u8(p + 2, vreinterpretq_u8_u64(A), 2)); }
    else { A = vreinterpretq_u64_u8(vsetq_lane_u8(p[0], vdupq_n_u8(0), 0)); B = z; }
    for (int l = 2; l >= 0; l--) Q[l] = CQX3(Q[l], CPM1(A, x->L8[0][l]), CPM1(B, x->L8[0][l])); }
/* n <= 64: V = n z + C0 + sum_{t<8} d_t l_t (d_t = the 8-byte word t = x limb 0 of pair t; y = 0) */
static inline c192v c192n_v64(const c192n_key *x, const uint8_t *p, size_t n) {
    c192q nv = vdupq_n_u64((uint64_t)n), z = vdupq_n_u64(0), Q[3];
    for (int l = 0; l < 3; l++) Q[l] = CPM1(nv, x->Zd[l]);
    size_t w = (n + 15) / 16, last = n - 16 * (w - 1);
    /* chunk 0 (the bytes a dependent caller has just written) enters last */
    if (w > 3) { c192q D = c192n_ld16(p + 48, last); for (int l = 2; l >= 0; l--) Q[l] = CQX3(Q[l], CPM1(D, x->L8[3][l]), CPM2(D, x->L8[3][l])); }
    if (w > 2) { c192q D = c192n_ld16(p + 32, w > 3 ? 16 : last); for (int l = 2; l >= 0; l--) Q[l] = CQX3(Q[l], CPM1(D, x->L8[2][l]), CPM2(D, x->L8[2][l])); }
    if (w > 1) { c192q D = c192n_ld16(p + 16, w > 2 ? 16 : last); for (int l = 2; l >= 0; l--) Q[l] = CQX3(Q[l], CPM1(D, x->L8[1][l]), CPM2(D, x->L8[1][l])); }
    if (w > 1 || last == 16) { c192q D = CNLD(p); for (int l = 2; l >= 0; l--) Q[l] = CQX3(Q[l], CPM1(D, x->L8[0][l]), CPM2(D, x->L8[0][l])); }
    else c192n_acc0(x, p, last, Q);
    /* Q_l = 128 bits at limb l: limbs (0,1) = Q0 + Q1 << 64, limb 2 = Q1.hi + Q2.lo, limb 3 = Q2.hi -> times g into limbs 0, 1 */
    c192v r = {CQX3(CQX(Q[0], vextq_u64(z, Q[1], 1)), CPM2(Q[2], x->Gd), x->CKS[0].a), CQX3(vextq_u64(Q[1], z, 1), Q[2], x->CKS[0].b)}; return r; }
/* the x rows of chunk g with ag (1..192; chunk 10: 1..128) data bytes, y = 0: D[d] += word * (l limb) at limb offset d */
C192N_INL void c192n_xonly(const c192n_key *x, const uint8_t *r0, size_t ag, int g, c192q D[5]) {
    int rows = (int)((ag + 63) / 64);
    for (int j = 0; j < rows; j++) for (int u = 0; u < 4; u++) { size_t o = 64 * (size_t)j + 16 * (size_t)u; if (o >= ag) break;
        c192q w = c192n_ld16(r0 + o, ag - o); const c192qu *ky = x->KP[4 * g + u] + 3;
        D[j] = CQX3(D[j], CPM1(w, ky[0]), CPM2(w, ky[0])); D[j + 1] = CQX3(D[j + 1], CPM1(w, ky[1]), CPM2(w, ky[1])); D[j + 2] = CQX3(D[j + 2], CPM1(w, ky[2]), CPM2(w, ky[2])); } }
#define C192N_LZ(r0, o, ag) ((o) < (ag) ? c192n_ld16((r0) + (o), (ag) - (o)) : vdupq_n_u64(0))
/* one block of 64 < n <= 4096 bytes: V = n z + b_1, one reduction */
static inline c192v c192n_one(const c192n_key *x, const uint8_t *p, size_t n) {
    c192q z = vdupq_n_u64(0), A[6], B[6], D[5] = {z, z, z, z, z}; c192v E = {z, z};
    int gf = (int)(n / 384); if (gf > 10) gf = 10;
    size_t ag = n - 384 * (size_t)gf;
    for (int q = 0; q < 6; q++) B[q] = z;
    if (!ag) { for (int q = 0; q < 6; q++) A[q] = x->SF[gf][q]; }
    else if (ag <= (gf < 10 ? 192u : 128u)) { for (int q = 0; q < 6; q++) A[q] = z; E = x->CKS[gf]; c192n_xonly(x, p + 384 * (size_t)gf, ag, gf, D); }
    else { const uint8_t *r0 = p + 384 * (size_t)gf;
        if (gf < 10) { for (int q = 0; q < 6; q++) A[q] = x->SF[gf + 1][q];
#define C192N_STEPP(C, u) do { const c192qu *k = x->KP[4 * gf + (u)]; size_t o = 16 * (size_t)(u); \
                c192q x0 = C192N_E(CNLD(r0 + o), k[0]), x1 = C192N_E(CNLD(r0 + o + 64), k[1]), x2 = C192N_E(CNLD(r0 + o + 128), k[2]); \
                c192q y0 = C192N_E(C192N_LZ(r0, o + 192, ag), k[3]), y1 = C192N_E(C192N_LZ(r0, o + 256, ag), k[4]), y2 = C192N_E(C192N_LZ(r0, o + 320, ag), k[5]); \
                C192N_MACL(C[0], x0, y0); C192N_MACH(C[0], x0, y0); C192N_MACL(C[1], x1, y1); C192N_MACH(C[1], x1, y1); C192N_MACL(C[2], x2, y2); C192N_MACH(C[2], x2, y2); \
                { c192q u_ = C192N_E(x0, x1), v_ = C192N_E(y0, y1); C192N_MACL(C[3], u_, v_); C192N_MACH(C[3], u_, v_); } \
                { c192q u_ = C192N_E(x0, x2), v_ = C192N_E(y0, y2); C192N_MACL(C[4], u_, v_); C192N_MACH(C[4], u_, v_); } \
                { c192q u_ = C192N_E(x1, x2), v_ = C192N_E(y1, y2); C192N_MACL(C[5], u_, v_); C192N_MACH(C[5], u_, v_); } } while (0)
            C192N_STEPP(A, 0); C192N_STEPP(B, 1); C192N_STEPP(A, 2); C192N_STEPP(B, 3); }
        else { for (int q = 0; q < 6; q++) A[q] = z; A[2] = x->CK10;
#define C192N_STEPP10(C, u) do { const c192qu *k = x->KP[40 + (u)]; size_t o = 16 * (size_t)(u); \
                c192q x0 = C192N_E(CNLD(r0 + o), k[0]), x1 = C192N_E(CNLD(r0 + o + 64), k[1]); \
                c192q y0 = C192N_E(C192N_LZ(r0, o + 128, ag), k[3]), y1 = C192N_E(C192N_LZ(r0, o + 192, ag), k[4]); \
                C192N_MACL(C[0], x0, y0); C192N_MACH(C[0], x0, y0); C192N_MACL(C[1], x1, y1); C192N_MACH(C[1], x1, y1); \
                { c192q u_ = C192N_E(x0, x1), v_ = C192N_E(y0, y1); C192N_MACL(C[3], u_, v_); C192N_MACH(C[3], u_, v_); } \
                { c192q u_ = C192N_E(x0, k[2]), v_ = C192N_E(y0, k[5]); C192N_MACL(C[4], u_, v_); C192N_MACH(C[4], u_, v_); } \
                { c192q u_ = C192N_E(x1, k[2]), v_ = C192N_E(y1, k[5]); C192N_MACL(C[5], u_, v_); C192N_MACH(C[5], u_, v_); } } while (0)
            C192N_STEPP10(A, 0); C192N_STEPP10(B, 1); C192N_STEPP10(A, 2); C192N_STEPP10(B, 3); } }
    for (int g = gf - 1; g >= 0; g--) {                  /* chunk 0 last (a dependent caller's bytes) */
        const uint8_t *rg = p + 384 * (size_t)g; C192N_OPQ(rg);
        C192N_UNROLL
        for (int u = 0; u < 4; u++) { const uint8_t *r = rg + 16 * (size_t)u; if (u & 1) C192N_STEP(B, r, x->KP[4 * g + u]); else C192N_STEP(A, r, x->KP[4 * g + u]); } }
    for (int q = 0; q < 6; q++) A[q] = CQX(A[q], B[q]);
    c192q R0, R1, R2, r[3] = {z, z, z}; c192n_interp_raw(A, &R0, &R1, &R2); c192n_nz(x, (uint64_t)n, r);
    R0 = CQX3(R0, r[0], CQX(D[0], vextq_u64(z, D[1], 1))); R1 = CQX3(R1, r[1], CQX3(vextq_u64(D[1], z, 1), D[2], vextq_u64(z, D[3], 1))); R2 = CQX3(R2, vextq_u64(D[3], z, 1), D[4]);
    return c192v_red(R0, R1, R2, x->Gd, E); }
static inline void c192n_key_init(c192n_key *x, const c192_key *K) {
    x->K = *K; c192q z = vdupq_n_u64(0);
    for (int a = 0; a < 44; a++) for (int j = 0; j < 3; j++) { x->KP[a][j] = c192n_pair(K->k[2 * a].w[j], K->k[2 * a + 1].w[j]); x->KP[a][3 + j] = c192n_pair(K->l[2 * a].w[j], K->l[2 * a + 1].w[j]); }
    x->CK10 = z; for (int a = 40; a < 44; a++) x->CK10 = CQX3(x->CK10, CPM1(x->KP[a][2], x->KP[a][5]), CPM2(x->KP[a][2], x->KP[a][5]));
    /* key-only chunks (zero data): suffix sums of the point sums */
    { static const uint8_t zb[384] __attribute__((aligned(16))) = {0}; c192q A[6];
      for (int p = 0; p < 6; p++) { A[p] = z; x->SF[11][p] = z; }
      A[2] = x->CK10; for (int a = 40; a < 44; a++) C192N_STEP10(A, zb + 16 * (a - 40), x->KP[a]);
      for (int p = 0; p < 6; p++) x->SF[10][p] = A[p];
      for (int g = 9; g >= 0; g--) { for (int u = 0; u < 4; u++) C192N_STEP(A, zb + 16 * u, x->KP[4 * g + u]); for (int p = 0; p < 6; p++) x->SF[g][p] = A[p]; } }
    x->Gd = vdupq_n_u64(0x87);
    for (int g = 0; g <= 10; g++) x->CKS[g] = c192n_interp(x->SF[g], x->Gd);
    x->YP[0] = c192v_ld((c192_el){{1, 0, 0}}); for (int e = 1; e <= 8; e++) x->YP[e] = c192v_mul(x->YP[e - 1], c192v_ld(K->Y), x->Gd);
    for (int l = 0; l < 3; l++) { c192_el e1 = c192v_st(x->YP[1]), e3 = c192v_st(x->YP[3]), e5 = c192v_st(x->YP[5]), e7 = c192v_st(x->YP[7]);
        c192_el e2 = c192v_st(x->YP[2]), e4 = c192v_st(x->YP[4]), e6 = c192v_st(x->YP[6]), e8 = c192v_st(x->YP[8]);
        x->YA[0][l] = c192n_pair(e1.w[l], e3.w[l]); x->YA[1][l] = c192n_pair(e5.w[l], e7.w[l]); x->YB[0][l] = c192n_pair(e2.w[l], e4.w[l]); x->YB[1][l] = c192n_pair(e6.w[l], e8.w[l]); }
    { const uint64_t *w = K->z.w; uint64_t p[6] = {w[0], w[1], w[2], w[0] ^ w[1], w[0] ^ w[2], w[1] ^ w[2]}; for (int t = 0; t < 6; t++) x->ZP[t] = vdupq_n_u64(p[t]); }
    x->Zv = c192v_ld(K->z); x->tau = c192v_ld(K->tau); x->tau_e = K->tau; { c192_el t1; for (int i = 0; i < 3; i++) t1.w[i] = K->tau.w[i] + 1; x->tau1 = c192v_ld(t1); }
    x->nt0d = vdupq_n_u64(~K->tau.w[0]); x->nt1d = vdupq_n_u64(~K->tau.w[1]); { c192_el nt; for (int i = 0; i < 3; i++) nt.w[i] = ~K->tau.w[i]; x->ntau = c192v_ld(nt); } for (int j = 0; j < 5; j++) x->cc[j] = c192v_ld(K->c[j]);
    for (int j = 0; j < 4; j++) for (int l = 0; l < 3; l++) x->L8[j][l] = c192n_pair(K->l[2 * j].w[l], K->l[2 * j + 1].w[l]);
    for (int l = 0; l < 3; l++) x->Zd[l] = vdupq_n_u64(K->z.w[l]);
}
/* n < REGION: V = n z + c(b_1..b_q); n <= 64 direct; n = 0: V = 0 */
static inline c192v c192n_short(const c192n_key *x, const uint8_t *T, size_t n) {
    c192q z = vdupq_n_u64(0); c192v V = {z, z};
    if (!n) return V;
    if (n <= 64) return c192n_v64(x, T, n);
    if (n <= 4096) return c192n_one(x, T, n);
    c192q r[3] = {z, z, z}; c192n_nz(x, (uint64_t)n, r);
    int q = (int)((n + 4095) / 4096); c192v e[8]; c192n_tailvals(x, T, n, e, q); return c192n_cq(x, r, e, q); }
static inline void c192n_hash(const c192n_key *x, const uint8_t *msg, size_t n, uint8_t out[24]) {
    size_t nfull = n / C192_REGION, rem = n - nfull * C192_REGION; c192v V;
    if (!nfull) V = c192n_short(x, msg, n);
    else { c192q z = vdupq_n_u64(0); V.a = vsetq_lane_u64((uint64_t)n, z, 0); V.b = z;    /* length-leading Horner in z */
        for (size_t r = 0; r < nfull; r++) { const uint8_t *R = msg + r * C192_REGION; C192N_OPQ(R); V = c192n_region(x, V, R, 0); }
        if (rem) V = c192n_tailfold(x, V, msg + nfull * C192_REGION, rem); }
    c192v_out(c192n_fin(x, V), out); }
static inline void c192n_fold(const c192n_key *x, c192_el *V, const uint8_t *msg, size_t nr) {
    c192v v = c192v_ld(*V); for (size_t r = 0; r < nr; r++) { const uint8_t *R = msg + r * C192_REGION; C192N_OPQ(R); v = c192n_region(x, v, R, 0); } *V = c192v_st(v); }
static inline void c192n_final(const c192n_key *x, c192_el V, size_t nreg, const uint8_t *T, size_t rem, size_t n, uint8_t out[24]) {
    c192v v = c192v_ld(V); size_t mp = nreg;
    if (rem) { v = c192n_tailfold(x, v, T, rem); mp++; }
    c192v zp = x->Zv, b = x->Zv; size_t e = mp - 1;                 /* z^{m'} */
    while (e) { if (e & 1) zp = c192v_mul(zp, b, x->Gd); e >>= 1; if (e) b = c192v_sq(b, x->Gd); }
    c192q z = vdupq_n_u64(0), r[3] = {z, z, z};
    { c192q nv = vdupq_n_u64((uint64_t)n); r[0] = CQX(CPM1(nv, zp.a), vextq_u64(z, CPM2(nv, zp.a), 1)); r[1] = CQX(vextq_u64(CPM2(nv, zp.a), z, 1), CPM1(nv, zp.b)); }
    v = c192v_red(r[0], r[1], r[2], x->Gd, v);
    c192v_out(c192n_fin(x, v), out); }
static inline int c192d_backend(void) { return C192_NEON; }
#else
static inline int c192d_backend(void) { return C192_PORTABLE; }
#endif


/* ---------------- portable pieces (reference arithmetic) ---------------- */
/* V <- V z^nr + ... for nr full regions (no length term) */
static inline void c192p_fold(const c192_key *K, c192_el *V, const uint8_t *msg, size_t nr) {
    for (size_t r = 0; r < nr; r++) { c192_el b[8]; for (int t = 0; t < 8; t++) b[t] = c192_block_ref(K, msg + r * C192_REGION + t * C192_BLOCK);
        *V = c192_xor(c192_mul(*V, K->z), c192_region_ref(b, 8, &K->Y)); } }
/* nreg full regions folded into V: fold the tail region (rem bytes at T, if any), add n z^{m'}, finalize */
static inline void c192p_final(const c192_key *K, c192_el V, size_t nreg, const uint8_t *T, size_t rem, size_t n, uint8_t out[24]) {
    c192_el b[8]; size_t nb = (rem + C192_BLOCK - 1) / C192_BLOCK;
    for (size_t t = 0; t < nb; t++) { uint8_t blk[C192_BLOCK]; size_t av = rem - t * C192_BLOCK; if (av > C192_BLOCK) av = C192_BLOCK;
        memcpy(blk, T + t * C192_BLOCK, av); memset(blk + av, 0, C192_BLOCK - av); b[t] = c192_block_ref(K, blk); }
    if (nb) V = c192_xor(c192_mul(V, K->z), c192_region_ref(b, (int)nb, &K->Y));
    V = c192_xor(V, c192_mul((c192_el){{(uint64_t)n, 0, 0}}, c192_pow(K->z, (uint64_t)(nreg + (nb > 0)))));
    c192_store(c192_finish_ref(V, K), out); }
/* out of line: the reference's 4 KiB block buffers would give the dispatcher a large frame (stack-clash probes) */
static __attribute__((noinline)) void c192p_hash(const c192_key *K, const uint8_t *m, size_t n, uint8_t out[24]) { c192_hash_ref(K, m, n, out); }
static __attribute__((noinline)) void c192p_fold_(const c192_key *K, c192_el *V, const uint8_t *msg, size_t nr) { c192p_fold(K, V, msg, nr); }
static __attribute__((noinline)) void c192p_final_(const c192_key *K, c192_el V, size_t nreg, const uint8_t *T, size_t rem, size_t n, uint8_t out[24]) { c192p_final(K, V, nreg, T, rem, n, out); }

typedef struct {
    c192_key k; int backend;
#if defined(C192_X86)
    c192x_key x; c192s_key s;
#elif defined(C192_ARM)
    c192n_key n;
#endif
} c192d_key;
static inline int c192d_ok(int backend, int best) { return backend == C192_PORTABLE || backend == best || (best == C192_AVX512 && backend == C192_PCLMUL); }
static inline void c192d_init_raw2(c192d_key *K, const c192_raw *R, int backend) {
    int best = c192d_backend(); if (backend < 0 || !c192d_ok(backend, best)) backend = best;
    K->backend = backend;
#if defined(C192_X86)
    if (backend == C192_AVX512) { c192x_derive(R, &K->k); c192x_key_init(&K->x, &K->k); return; }
    if (backend == C192_PCLMUL) { c192s_derive(R, &K->k); c192s_key_init(&K->s, &K->k); return; }
#elif defined(C192_ARM)
    if (backend == C192_NEON) { C192_DERIVE(R, &K->k, c192n_mulk); c192n_key_init(&K->n, &K->k); return; }
#endif
    c192_derive(R, &K->k); }
static inline void c192d_init_raw(c192d_key *K, const uint8_t key[216], int backend) { c192_raw R; c192_raw_from_bytes(key, &R); c192d_init_raw2(K, &R, backend); }
static inline void c192d_init_seed(c192d_key *K, uint64_t seed, int backend) { c192_raw R; c192_raw_from_seed(&R, seed); c192d_init_raw2(K, &R, backend); }
static inline void c192d_hash(const c192d_key *K, const void *msg, size_t n, uint8_t out[24]) {
    const uint8_t *m = (const uint8_t *)msg;
    switch (K->backend) {
#if defined(C192_X86)
    case C192_AVX512: c192x_hash(&K->x, m, n, out); return;
    case C192_PCLMUL: c192s_hash(&K->s, m, n, out); return;
#elif defined(C192_ARM)
    case C192_NEON: c192n_hash(&K->n, m, n, out); return;
#endif
    default: c192p_hash(&K->k, m, n, out); return; } }
/* ---------------- streaming: every full region is folded into V as soon as it is complete ---------------- */
typedef struct { const c192d_key *K; c192_el V; size_t total, nreg, blen; uint8_t buf[C192_REGION]; } c192d_stream;
static inline void c192d_stream_init(c192d_stream *s, const c192d_key *K) { memset(&s->V, 0, sizeof s->V); s->K = K; s->total = s->nreg = s->blen = 0; }
static inline void c192d_fold(const c192d_key *K, c192_el *V, const uint8_t *p, size_t nr) {
    switch (K->backend) {
#if defined(C192_X86)
    case C192_AVX512: c192x_fold(&K->x, V, p, nr); return;
    case C192_PCLMUL: c192s_fold(&K->s, V, p, nr); return;
#elif defined(C192_ARM)
    case C192_NEON: c192n_fold(&K->n, V, p, nr); return;
#endif
    default: c192p_fold_(&K->k, V, p, nr); return; } }
static inline void c192d_update(c192d_stream *s, const void *data, size_t len) {
    const uint8_t *p = (const uint8_t *)data; s->total += len;
    if (s->blen) { size_t t = C192_REGION - s->blen; if (t > len) t = len; memcpy(s->buf + s->blen, p, t); s->blen += t; p += t; len -= t;
        if (s->blen == C192_REGION) { c192d_fold(s->K, &s->V, s->buf, 1); s->nreg++; s->blen = 0; } }
    size_t nr = len / C192_REGION;
    if (nr) { c192d_fold(s->K, &s->V, p, nr); s->nreg += nr; p += nr * C192_REGION; len -= nr * C192_REGION; }
    if (len) { memcpy(s->buf, p, len); s->blen = len; } }
static inline void c192d_final(c192d_stream *s, uint8_t out[24]) {
    const c192d_key *K = s->K; size_t n = s->total;
    if (!s->nreg) { c192d_hash(K, s->buf, s->blen, out); return; }            /* every byte is still buffered: one-shot */
    switch (K->backend) {
#if defined(C192_X86)
    case C192_AVX512: c192x_final(&K->x, s->V, s->nreg, s->buf, s->blen, n, out); return;
    case C192_PCLMUL: c192s_final(&K->s, s->V, s->nreg, s->buf, s->blen, n, out); return;
#elif defined(C192_ARM)
    case C192_NEON: c192n_final(&K->n, s->V, s->nreg, s->buf, s->blen, n, out); return;
#endif
    default: c192p_final_(&K->k, s->V, s->nreg, s->buf, s->blen, n, out); return; } }

/* ================= public API ================= */
#define CHAINHASH192_KEY_BYTES 216
#define CHAINHASH192_KEY_WORDS (CHAINHASH192_KEY_BYTES / 8)
enum { CH192_PORTABLE = C192_PORTABLE, CH192_PCLMUL = C192_PCLMUL, CH192_AVX512 = C192_AVX512, CH192_NEON = C192_NEON };
typedef c192d_key chainhash192_key;
typedef c192d_stream chainhash192_stream;
static inline int chainhash192_backend(void) { return c192d_backend(); }
static inline int chainhash192_has_backend(int b) { return c192d_ok(b, c192d_backend()); }
static inline const char *chainhash192_backend_name(int b) { return (b >= 0 && b < 4) ? C192_BACKEND_NAME[b] : "?"; }
/* key = s, y, z, t, c_0..c_4: 9 elements of 24 bytes, each three little-endian 64-bit limbs, limb 0 first
 * (docs/SPEC-192.md section 2). No key is rejected. The masks s^1..s^176 are derived here.
 * The backend is fixed here (-1: the best one available; an unavailable backend falls back to it). */
static inline void chainhash192_key_from_bytes_with_backend(chainhash192_key *k, const uint8_t p[CHAINHASH192_KEY_BYTES], int b) { c192d_init_raw(k, p, b); }
static inline void chainhash192_key_from_bytes(chainhash192_key *k, const uint8_t p[CHAINHASH192_KEY_BYTES]) { c192d_init_raw(k, p, -1); }
/* the same 216 bytes as 27 little-endian 64-bit words */
static inline void chainhash192_key_from_words_with_backend(chainhash192_key *k, const uint64_t w[CHAINHASH192_KEY_WORDS], int b) {
    uint8_t p[CHAINHASH192_KEY_BYTES]; int i, j;
    for (i = 0; i < CHAINHASH192_KEY_WORDS; i++) for (j = 0; j < 8; j++) p[8 * i + j] = (uint8_t)(w[i] >> (8 * j));
    c192d_init_raw(k, p, b); }
static inline void chainhash192_key_from_words(chainhash192_key *k, const uint64_t w[CHAINHASH192_KEY_WORDS]) { chainhash192_key_from_words_with_backend(k, w, -1); }
/* SplitMix64 expansion of a seed (the vectors' seed keys; a zero y becomes 1): for benchmarks and tests,
 * not covered by the bound */
static inline void chainhash192_key_from_seed_with_backend(chainhash192_key *k, uint64_t seed, int b) { c192d_init_seed(k, seed, b); }
static inline void chainhash192_key_from_seed(chainhash192_key *k, uint64_t seed) { c192d_init_seed(k, seed, -1); }
static inline int chainhash192_key_backend(const chainhash192_key *k) { return k->backend; }
static inline void chainhash192(const chainhash192_key *k, const void *data, size_t len, uint8_t out[24]) { c192d_hash(k, data, len, out); }
/* the definition, literally (bit-serial); for tests */
static inline void chainhash192_reference(const chainhash192_key *k, const void *data, size_t len, uint8_t out[24]) { c192_hash_ref(&k->k, (const uint8_t *)data, len, out); }
static inline void chainhash192_init(chainhash192_stream *s, const chainhash192_key *k) { c192d_stream_init(s, k); }
static inline void chainhash192_update(chainhash192_stream *s, const void *data, size_t len) { c192d_update(s, data, len); }
static inline void chainhash192_final(chainhash192_stream *s, uint8_t out[24]) { c192d_final(s, out); }
#endif /* CHAINHASH192_H */
