/* ChainHash-128 v2: a keyed 128-bit hash for long inputs with a proven collision bound.
 * Copyright 2026 Thomas Dybdahl Ahle. MIT license. C99, one header plus chainhash128.h, no allocation.
 *
 * Key: 192 uniformly random bytes (CHAINHASH128V2_KEY_BYTES), chainhash128v2_key_from_bytes.
 * chainhash128v2_key_from_seed expands a 64-bit seed; it is for benchmarks and tests.
 * The expanded key (about 7 KiB of tables; 15 KiB on x86) is initialized in place, at any 8-byte-aligned address
 * (static, stack, malloc; the tables are aligned inside the key); a copy made with memcpy stays valid.
 * Hash: chainhash128v2(&key, data, len) returns a ch128_word (two uint64_t limbs);
 * chainhash128_store writes its 16 canonical little-endian bytes. Streaming:
 * chainhash128v2_init, chainhash128v2_update, chainhash128v2_final.
 * Backends (run-time dispatch, chainhash128.h's numbering): CH128_ZMM (AVX-512 VPCLMULQDQ),
 * CH128_XMM (PCLMULQDQ, AVX2 tails when present), CH128_NEON (AArch64 PMULL, detected at run
 * time), CH128_PORTABLE. Every backend and every streaming split computes the same digest.
 * Explicit backend calls require chainhash128v2_has_backend().
 * Bound: for two distinct messages fixed independently of the key, each of at most 8L bytes,
 * Pr[collision] <= N(L)/2^128 with N(L) <= 2L (score 127); see docs/THEOREM-128v2.md.
 * The definition: docs/SPEC-128v2.md; the family: docs/FAMILY.md.
 * Proof status: paper proof and machine-checked certificates (test/128v2); not yet in Lean.
 * Builds on chainhash128.h (same directory): GF(2^128) helpers, the finalizer, CPU detection.
 * Define CHAINHASH128_PORTABLE to omit all hardware code. Development name: CH-128/P v2.2.
 * Schedule (same digest either way): on AMD the ZMM kernel reads a 64-byte pre-broadcast mask table
 * with plain loads (a lane broadcast from memory takes FP-pipe slots on Zen 4); Intel keeps the lane
 * broadcasts. CHAINHASH128V2_PREBC=1 uses the table on every CPU, CHAINHASH128V2_NO_PREBC never.
 * NEON prefetches the next 16 KiB region inside the pair kernel; CHAINHASH128V2_NO_NPF turns it off.
 */
#ifndef CHAINHASH128V2_H
#define CHAINHASH128V2_H
#if !defined(CHAINHASH128V2_PREBC) && !defined(CHAINHASH128V2_NO_PREBC)
#define CHAINHASH128V2_PREBC 2
#endif
#if !defined(CHAINHASH128V2_NPF) && !defined(CHAINHASH128V2_NO_NPF)
#define CHAINHASH128V2_NPF 1
#endif
#include "chainhash128.h"

#define CH128P_J 8           /* v1: 8 blocks per region (fixed) */
#define CH128P_M 16          /* v1: 2 KiB blocks (16 pair-vectors) */
#define CH128P_VERSION 1
#define CH128P_REVISION 1    /* kernels: round 4 (as v1.1) */
#define CH128P_V2_REVISION 2 /* v2.2 */
#define CH128P_BLOCK (128*CH128P_M)
#define CH128P_W (8*CH128P_M)
#define CH128P_REGION (CH128P_J*CH128P_BLOCK)
#define CH128P_ROW (16*CH128P_J)      /* bytes per row (word a of all J blocks) */
#define CH128P_PV (128*CH128P_J)      /* bytes per pair-vector (8 rows) */
#define CH128P_KEY_BYTES 176

typedef struct { ch128_word yp[9], yh[9], c[5], tau; } ch128p_outer;   /* ChainHash-128's outer words (no kappa table) */
typedef struct {
    ch128_word mask[CH128P_W];      /* word a=8m+i: lo = u-mask, hi = v-mask (resident, M*128 bytes) */
    ch128_word sm[CH128P_M][7];     /* sm[m][nr-1] = XOR of mask[8m+i], nr<=i<8 (rows past the data), nr = 1..7 */
    ch128_word kd[CH128P_M][7];     /* kd[m][nr-1] = reduced (Q0,Q1) D-part of zero-data rows nr..7 */
    ch128_word kz[CH128P_M];        /* full reduced value of an all-zero-data pair-vector */
    ch128_word zero;                /* nr = 8: no missing rows */
    ch128_word yps[9], yhs[9];      /* limb-swapped y^e and 0x87*y^e (NEON schoolbook without EXT) */
    ch128_word yr[16];              /* yr[i] = y^(7-i) for i<8, 0 after: lane powers of a c-block tail start at yr+8-c */
    ch128p_outer outer;             /* y^0..8, 0x87*y^0..8, c0..c4, tau */
#if defined(CHAINHASH128V2_PREBC) && defined(CH128_X86)
    ch128_word mzb_pad;             /* (puts mzb at a multiple of 64 bytes; the struct asks for no alignment beyond 8) */
    ch128_word mzb[CH128P_W][4];    /* mask[a] pre-broadcast to 64 bytes (ZMM: plain loads, no lane broadcast) */
#endif
} ch128p_key;
#define CH128P_SMP(k, m, nr) ((nr) < 8 ? &(k)->sm[m][(nr) - 1] : &(k)->zero)
#define CH128P_KDP(k, m, nr) ((nr) < 8 ? &(k)->kd[m][(nr) - 1] : &(k)->zero)

/* ---------------- F = GF(2^64) portable arithmetic ---------------- */
static inline void ch128p_clmul64(uint64_t a, uint64_t b, uint64_t *lo, uint64_t *hi) {
    uint64_t l = 0, h = 0; unsigned i;
    for (i = 0; i < 64; i++) {
        uint64_t m = UINT64_C(0) - ((b >> i) & 1);
        l ^= (a << i) & m;
        if (i) h ^= (a >> (64 - i)) & m;
    }
    *lo = l; *hi = h;
}
/* reduce lo + X^64 hi (degree <= 127) mod X^64 + X^4+X^3+X+1 */
static inline uint64_t ch128p_fred(uint64_t lo, uint64_t hi) {
    uint64_t t = (hi >> 63) ^ (hi >> 61) ^ (hi >> 60);
    return lo ^ hi ^ (hi << 1) ^ (hi << 3) ^ (hi << 4) ^ t ^ (t << 1) ^ (t << 3) ^ (t << 4);
}
static inline uint64_t ch128p_fmul(uint64_t a, uint64_t b) {
    uint64_t lo, hi; ch128p_clmul64(a, b, &lo, &hi); return ch128p_fred(lo, hi);
}

/* a * c in F for a small constant c (< 2^12): shift-xor over the set bits of c */
static inline uint64_t ch128p_fmul_small(uint64_t a, uint64_t c) {
    uint64_t l = 0, h = 0; unsigned i;
    for (i = 0; c; i++, c >>= 1) if (c & 1) { l ^= a << i; if (i) h ^= a >> (64 - i); }
    return ch128p_fred(l, h);
}
/* ---------------- A = F[T]/g arithmetic (setup only) ---------------- */
static const uint64_t ch128p_g[8] = { 0xee0, 0x770, 0x60c, 0, 0x17d, 0, 0, 0 }; /* T^8 = sum g_k T^k */
static inline void ch128p_amul(uint64_t r[8], const uint64_t a[8], const uint64_t b[8]) {
    uint64_t t[15] = {0}; int i, j, k;
    for (i = 0; i < 8; i++) for (j = 0; j < 8; j++) t[i + j] ^= ch128p_fmul(a[i], b[j]);
    for (i = 14; i >= 8; i--) {
        uint64_t c = t[i]; t[i] = 0;
        if (c) for (k = 0; k < 8; k++) if (ch128p_g[k]) t[i - 8 + k] ^= ch128p_fmul(c, ch128p_g[k]);
    }
    for (i = 0; i < 8; i++) r[i] = t[i];
}
static inline uint64_t ch128p_aeval(const uint64_t a[8], uint64_t x) {
    uint64_t r = 0; int i; for (i = 7; i >= 0; i--) r = ch128p_fmul(r, x) ^ a[i]; return r;
}

static inline void ch128p_key_init_tables(ch128p_key *k, uint64_t (*fm)(uint64_t, uint64_t)) {
    unsigned m, i;
    for (m = 0; m < CH128P_M; m++) {
        ch128_word s = ch128_make(0, 0); uint64_t q0 = 0, q1 = 0;
        for (i = 8; i-- > 0;) {
            ch128_word w = k->mask[8 * m + i]; uint64_t pr = fm(w.lo, w.hi);
            s = ch128_xor(s, w); q0 ^= pr; q1 ^= ch128p_fmul_small(pr, i);
            if (i >= 1) { k->sm[m][i - 1] = s; k->kd[m][i - 1] = ch128_make(q0, q1); }
        }
        /* zero-data pair-vector: all 8 rows' D-part plus parity xi*(sum mu)(sum mv) */
        k->kz[m] = ch128_make(q0, q1 ^ ch128p_fmul_small(fm(s.lo, s.hi), 2));
    }
    k->zero = ch128_make(0, 0);
}
/* Setup-only carry-less multiply: hardware PCLMUL/PMULL when present, else a 4-bit window
 * (the oracle keeps the independent bit-serial ch128p_clmul64). */
static inline void ch128p_clmul64_w(uint64_t a, uint64_t b, uint64_t *lo, uint64_t *hi) {
    uint64_t tl[16], th[16], l = 0, h = 0; int i;
    tl[0] = th[0] = 0; tl[1] = a; th[1] = 0;
    for (i = 2; i < 16; i++) {
        if (i & 1) { tl[i] = tl[i - 1] ^ a; th[i] = th[i - 1]; }
        else { tl[i] = tl[i / 2] << 1; th[i] = (th[i / 2] << 1) | (tl[i / 2] >> 63); }
    }
    for (i = 60; i >= 0; i -= 4) { unsigned n = (unsigned)(b >> i) & 15; h = (h << 4) | (l >> 60); l <<= 4; l ^= tl[n]; h ^= th[n]; }
    *lo = l; *hi = h;
}
#if !defined(CHAINHASH128_PORTABLE) && (defined(__x86_64__) || defined(__i386__)) && (defined(__GNUC__) || defined(__clang__))
__attribute__((target("pclmul,sse2"))) static inline void ch128p_clmul64_hw(uint64_t a, uint64_t b, uint64_t *lo, uint64_t *hi) {
    __m128i r = _mm_clmulepi64_si128(_mm_cvtsi64_si128((long long)a), _mm_cvtsi64_si128((long long)b), 0);
    *lo = (uint64_t)_mm_cvtsi128_si64(r); *hi = (uint64_t)_mm_cvtsi128_si64(_mm_unpackhi_epi64(r, r));
}
#define CH128P_HAVE_HWCLMUL() (chainhash128_backend() >= 1)
#elif defined(CH128_ARM)
/* PMULL only inside CH128_NBEGIN/CH128_NEND (target "aes"/"+crypto" when the build does not promise it),
 * and only called when chainhash128_backend() reports NEON (PMULL detected at run time). */
CH128_NBEGIN
static inline void ch128p_clmul64_hw(uint64_t a, uint64_t b, uint64_t *lo, uint64_t *hi) {
    poly128_t r = vmull_p64((poly64_t)a, (poly64_t)b); uint64x2_t v = vreinterpretq_u64_p128(r);
    *lo = vgetq_lane_u64(v, 0); *hi = vgetq_lane_u64(v, 1);
}
CH128_NEND
#define CH128P_HAVE_HWCLMUL() (chainhash128_backend() == CH128_NEON)
#else
#define ch128p_clmul64_hw ch128p_clmul64_w
#define CH128P_HAVE_HWCLMUL() 0
#endif
static inline uint64_t ch128p_fmul_hw(uint64_t a, uint64_t b) { uint64_t l, h; ch128p_clmul64_hw(a, b, &l, &h); return ch128p_fred(l, h); }
static inline uint64_t ch128p_fmul_w(uint64_t a, uint64_t b) { uint64_t l, h; ch128p_clmul64_w(a, b, &l, &h); return ch128p_fred(l, h); }
/* r = a*b in A: 64 unreduced products accumulated per T-degree, 15 F-reductions, then
 * T^8 = 0x17d T^4 + 0x60c T^2 + 0x770 T + 0xee0 folded with small-constant products. */
static inline void ch128p_amul_fast(uint64_t r[8], const uint64_t a[8], const uint64_t b[8], int hw) {
    uint64_t tl[15] = {0}, th[15] = {0}, t[15]; int i, j;
    for (i = 0; i < 8; i++) for (j = 0; j < 8; j++) { uint64_t l, h; if (hw) ch128p_clmul64_hw(a[i], b[j], &l, &h); else ch128p_clmul64_w(a[i], b[j], &l, &h); tl[i + j] ^= l; th[i + j] ^= h; }
    for (i = 0; i < 15; i++) t[i] = ch128p_fred(tl[i], th[i]);
    for (i = 14; i >= 8; i--) {
        uint64_t c = t[i]; t[i] = 0;
        if (hw) { t[i - 4] ^= ch128p_fmul_hw(c, 0x17d); t[i - 6] ^= ch128p_fmul_hw(c, 0x60c);    /* v2.1: hardware product */
                  t[i - 7] ^= ch128p_fmul_hw(c, 0x770); t[i - 8] ^= ch128p_fmul_hw(c, 0xee0); }
        else { t[i - 4] ^= ch128p_fmul_small(c, 0x17d); t[i - 6] ^= ch128p_fmul_small(c, 0x60c);
               t[i - 7] ^= ch128p_fmul_small(c, 0x770); t[i - 8] ^= ch128p_fmul_small(c, 0xee0); }
    }
    for (i = 0; i < 8; i++) r[i] = t[i];
}
static const uint64_t ch128p_apow[8][8] = {   /* alpha_i^k in F (degree <= 14: no reduction), i = 0..7, k = 0..7 */
    {0x1, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0},
    {0x1, 0x1, 0x1, 0x1, 0x1, 0x1, 0x1, 0x1},
    {0x1, 0x2, 0x4, 0x8, 0x10, 0x20, 0x40, 0x80},
    {0x1, 0x3, 0x5, 0xf, 0x11, 0x33, 0x55, 0xff},
    {0x1, 0x4, 0x10, 0x40, 0x100, 0x400, 0x1000, 0x4000},
    {0x1, 0x5, 0x11, 0x55, 0x101, 0x505, 0x1111, 0x5555},
    {0x1, 0x6, 0x14, 0x78, 0x110, 0x660, 0x1540, 0x7f80},
    {0x1, 0x7, 0x15, 0x6b, 0x111, 0x777, 0x1445, 0x6ddb} };
/* v2.1: the whole mask expansion (31 ring products in A, 256 evaluations E) in one function compiled for the
 * carry-less-multiply target, so every hardware product inlines (a call per product cost ~30k ticks on x86). */
#if defined(CH128_X86)
#define CH128P_TSETUP CH128_T128
#else
#define CH128P_TSETUP
#endif
#if defined(CH128_ARM)
CH128_NBEGIN
#endif
#if defined(CH128_X86) || defined(CH128_ARM)
#define CH128P_HAVE_FASTSETUP 1
static inline uint64_t ch128p_fred_s(uint64_t lo, uint64_t hi) {   /* = ch128p_fred, local copy for inlining */
    uint64_t t = (hi >> 63) ^ (hi >> 61) ^ (hi >> 60);
    return lo ^ hi ^ (hi << 1) ^ (hi << 3) ^ (hi << 4) ^ t ^ (t << 1) ^ (t << 3) ^ (t << 4);
}
CH128P_TSETUP static inline void ch128p_cl_s(uint64_t a, uint64_t b, uint64_t *lo, uint64_t *hi) {
#if defined(CH128_X86)
    __m128i r = _mm_clmulepi64_si128(_mm_cvtsi64_si128((long long)a), _mm_cvtsi64_si128((long long)b), 0);
    *lo = (uint64_t)_mm_cvtsi128_si64(r); *hi = (uint64_t)_mm_extract_epi64(r, 1);
#else
    uint64x2_t v = vreinterpretq_u64_p128(vmull_p64((poly64_t)a, (poly64_t)b)); *lo = vgetq_lane_u64(v, 0); *hi = vgetq_lane_u64(v, 1);
#endif
}
#if defined(CH128_X86)
/* x86: operands as 64-bit pairs in xmm, PCLMULQDQ picks limbs by immediate, 128-bit accumulators in xmm, one reduction
 * per coefficient (GPR round trips per product had cost 22.7k ticks). */
/* F-reduction in xmm: v = lo + X^64 hi (deg <= 126) -> low lane of the result, upper lane zero. X^64 = X^4+X^3+X+1 = 0x1b:
 * r = lo + hi*0x1b (deg <= 67), then the top <= 4 bits once more. */
CH128_T128 static inline __m128i ch128p_fred_v(__m128i v, __m128i R) {
    __m128i r = _mm_xor_si128(_mm_move_epi64(v), _mm_clmulepi64_si128(v, R, 0x01));
    return _mm_move_epi64(_mm_xor_si128(r, _mm_clmulepi64_si128(r, R, 0x01)));
}
CH128_T128 static __attribute__((noinline)) void ch128p_masks_fast(ch128_word *mask, const uint64_t s[8]) {
    __m128i S[4], P[4], Ap[8][4], G0 = _mm_set_epi64x(0x60c, 0x17d), G1 = _mm_set_epi64x(0xee0, 0x770), R = _mm_cvtsi64_si128(0x1b); unsigned e, i, d; int a, b;
    for (a = 0; a < 4; a++) { S[a] = _mm_loadu_si128((const __m128i *)(s + 2 * a)); P[a] = S[a]; }
    for (i = 0; i < 8; i++) for (a = 0; a < 4; a++) Ap[i][a] = _mm_loadu_si128((const __m128i *)&ch128p_apow[i][2 * a]);
    for (e = 1; e <= 2 * CH128P_M; e++) {
        unsigned m = (e - 1) / 2, half = (e - 1) % 2;
        for (i = 0; i < 8; i++) {   /* E(s^e)_i = sum_d P_d alpha_i^d */
            __m128i acc = _mm_setzero_si128();
            for (d = 0; d < 4; d++) acc = _mm_xor_si128(acc, _mm_xor_si128(_mm_clmulepi64_si128(P[d], Ap[i][d], 0x00), _mm_clmulepi64_si128(P[d], Ap[i][d], 0x11)));
            _mm_storel_epi64((__m128i *)(half == 0 ? &mask[8 * m + i].lo : &mask[8 * m + i].hi), ch128p_fred_v(acc, R));
        }
        if (e < 2 * CH128P_M) {   /* P <- P * S in A: 64 unreduced products, fold T^8 = 0x17d T^4 + 0x60c T^2 + 0x770 T + 0xee0 */
            __m128i acc[15], t[8];
            for (a = 0; a < 15; a++) acc[a] = _mm_setzero_si128();
            for (a = 0; a < 4; a++) for (b = 0; b < 4; b++) {   /* limbs (2a+x, 2b+y) -> coefficient 2a+2b+x+y */
                acc[2 * a + 2 * b] = _mm_xor_si128(acc[2 * a + 2 * b], _mm_clmulepi64_si128(P[a], S[b], 0x00));
                acc[2 * a + 2 * b + 1] = _mm_xor_si128(acc[2 * a + 2 * b + 1], _mm_xor_si128(_mm_clmulepi64_si128(P[a], S[b], 0x01), _mm_clmulepi64_si128(P[a], S[b], 0x10)));
                acc[2 * a + 2 * b + 2] = _mm_xor_si128(acc[2 * a + 2 * b + 2], _mm_clmulepi64_si128(P[a], S[b], 0x11)); }
            for (a = 14; a >= 8; a--) {   /* reduce the coefficient, then fold it down unreduced (products <= 75 bits) */
                __m128i c = ch128p_fred_v(acc[a], R);
                acc[a - 4] = _mm_xor_si128(acc[a - 4], _mm_clmulepi64_si128(c, G0, 0x00)); acc[a - 6] = _mm_xor_si128(acc[a - 6], _mm_clmulepi64_si128(c, G0, 0x10));
                acc[a - 7] = _mm_xor_si128(acc[a - 7], _mm_clmulepi64_si128(c, G1, 0x00)); acc[a - 8] = _mm_xor_si128(acc[a - 8], _mm_clmulepi64_si128(c, G1, 0x10));
            }
            for (a = 0; a < 8; a++) t[a] = ch128p_fred_v(acc[a], R);
            for (a = 0; a < 4; a++) P[a] = _mm_unpacklo_epi64(t[2 * a], t[2 * a + 1]);
        }
    }
}
/* tail constants (sm, kd, kz) in xmm: the same values as ch128p_key_init_tables (v2.1) */
CH128_T128 static __attribute__((noinline)) void ch128p_tables_fast(ch128p_key *k) {
    const __m128i R = _mm_cvtsi64_si128(0x1b), two = _mm_cvtsi64_si128(2); unsigned m, i;
    for (m = 0; m < CH128P_M; m++) {
        __m128i sacc = _mm_setzero_si128(), q0 = sacc, q1 = sacc;
        for (i = 8; i-- > 0;) {
            __m128i w = _mm_loadu_si128((const __m128i *)&k->mask[8 * m + i]), pr = ch128p_fred_v(_mm_clmulepi64_si128(w, w, 0x01), R);
            sacc = _mm_xor_si128(sacc, w); q0 = _mm_xor_si128(q0, pr);
            q1 = _mm_xor_si128(q1, _mm_clmulepi64_si128(pr, _mm_cvtsi64_si128((long long)i), 0x00));   /* alpha_i * pr, unreduced (<= 66 bits) */
            if (i >= 1) { _mm_storeu_si128((__m128i *)&k->sm[m][i - 1], sacc); _mm_storeu_si128((__m128i *)&k->kd[m][i - 1], _mm_unpacklo_epi64(q0, ch128p_fred_v(q1, R))); }
        }
        { __m128i ps = ch128p_fred_v(_mm_clmulepi64_si128(sacc, sacc, 0x01), R);
          q1 = _mm_xor_si128(q1, _mm_clmulepi64_si128(ps, two, 0x00));
          _mm_storeu_si128((__m128i *)&k->kz[m], _mm_unpacklo_epi64(q0, ch128p_fred_v(q1, R))); }
    }
    k->zero = ch128_make(0, 0);
}
#else
/* AArch64 (inside CH128_NBEGIN/NEND): the same structure with PMULL on packed pairs. */
static inline uint64x2_t ch128p_pm00(uint64x2_t a, uint64x2_t b) { return vreinterpretq_u64_p128(vmull_p64((poly64_t)vgetq_lane_u64(a, 0), (poly64_t)vgetq_lane_u64(b, 0))); }
static inline uint64x2_t ch128p_pm11(uint64x2_t a, uint64x2_t b) { return vreinterpretq_u64_p128(vmull_high_p64(vreinterpretq_p64_u64(a), vreinterpretq_p64_u64(b))); }
static inline uint64x2_t ch128p_pm10(uint64x2_t a, uint64x2_t b) { return vreinterpretq_u64_p128(vmull_p64((poly64_t)vgetq_lane_u64(a, 1), (poly64_t)vgetq_lane_u64(b, 0))); }
static inline uint64x2_t ch128p_fred_n(uint64x2_t v, uint64x2_t R) {   /* low lane = v mod f, upper lane zero */
    uint64x2_t z = vdupq_n_u64(0), r = veorq_u64(vsetq_lane_u64(0, v, 1), ch128p_pm10(v, R));
    return vsetq_lane_u64(0, veorq_u64(r, ch128p_pm10(r, R)), 1);
    (void)z;
}
static __attribute__((noinline)) void ch128p_masks_fast(ch128_word *mask, const uint64_t s[8]) {
    uint64x2_t S[4], P[4], Ap[8][4], G0 = vcombine_u64(vcreate_u64(0x17d), vcreate_u64(0x60c)), G1 = vcombine_u64(vcreate_u64(0x770), vcreate_u64(0xee0)), R = vcombine_u64(vcreate_u64(0x1b), vcreate_u64(0));
    unsigned e, i, d; int a, b;
    for (a = 0; a < 4; a++) { S[a] = vld1q_u64(s + 2 * a); P[a] = S[a]; }
    for (i = 0; i < 8; i++) for (a = 0; a < 4; a++) Ap[i][a] = vld1q_u64(&ch128p_apow[i][2 * a]);
    for (e = 1; e <= 2 * CH128P_M; e++) {
        unsigned m = (e - 1) / 2, half = (e - 1) % 2;
        for (i = 0; i < 8; i++) {
            uint64x2_t acc = vdupq_n_u64(0);
            for (d = 0; d < 4; d++) acc = veorq_u64(acc, veorq_u64(ch128p_pm00(P[d], Ap[i][d]), ch128p_pm11(P[d], Ap[i][d])));
            vst1_u64(half == 0 ? &mask[8 * m + i].lo : &mask[8 * m + i].hi, vget_low_u64(ch128p_fred_n(acc, R)));
        }
        if (e < 2 * CH128P_M) {
            uint64x2_t acc[15], t[8];
            for (a = 0; a < 15; a++) acc[a] = vdupq_n_u64(0);
            for (a = 0; a < 4; a++) for (b = 0; b < 4; b++) {
                uint64x2_t Sb = vextq_u64(S[b], S[b], 1);   /* swapped limbs for the cross terms */
                acc[2 * a + 2 * b] = veorq_u64(acc[2 * a + 2 * b], ch128p_pm00(P[a], S[b]));
                acc[2 * a + 2 * b + 1] = veorq_u64(acc[2 * a + 2 * b + 1], veorq_u64(ch128p_pm00(P[a], Sb), ch128p_pm11(P[a], Sb)));
                acc[2 * a + 2 * b + 2] = veorq_u64(acc[2 * a + 2 * b + 2], ch128p_pm11(P[a], S[b])); }
            for (a = 14; a >= 8; a--) {
                uint64x2_t c = ch128p_fred_n(acc[a], R), cc = vdupq_laneq_u64(c, 0);
                acc[a - 4] = veorq_u64(acc[a - 4], ch128p_pm00(cc, G0)); acc[a - 6] = veorq_u64(acc[a - 6], ch128p_pm11(cc, G0));
                acc[a - 7] = veorq_u64(acc[a - 7], ch128p_pm00(cc, G1)); acc[a - 8] = veorq_u64(acc[a - 8], ch128p_pm11(cc, G1));
            }
            for (a = 0; a < 8; a++) t[a] = ch128p_fred_n(acc[a], R);
            for (a = 0; a < 4; a++) P[a] = vzip1q_u64(t[2 * a], t[2 * a + 1]);
        }
    }
}
static __attribute__((noinline)) void ch128p_tables_fast(ch128p_key *k) {
    const uint64x2_t R = vcombine_u64(vcreate_u64(0x1b), vcreate_u64(0)), two = vcombine_u64(vcreate_u64(2), vcreate_u64(0)); unsigned m, i;
    for (m = 0; m < CH128P_M; m++) {
        uint64x2_t sacc = vdupq_n_u64(0), q0 = sacc, q1 = sacc;
        for (i = 8; i-- > 0;) {
            uint64x2_t w = vld1q_u64((const uint64_t *)&k->mask[8 * m + i]), pr = ch128p_fred_n(ch128p_pm10(w, w), R);
            sacc = veorq_u64(sacc, w); q0 = veorq_u64(q0, pr);
            q1 = veorq_u64(q1, ch128p_pm00(pr, vcombine_u64(vcreate_u64(i), vcreate_u64(0))));
            if (i >= 1) { vst1q_u64((uint64_t *)&k->sm[m][i - 1], sacc); vst1q_u64((uint64_t *)&k->kd[m][i - 1], vzip1q_u64(q0, ch128p_fred_n(q1, R))); }
        }
        { uint64x2_t ps = ch128p_fred_n(ch128p_pm10(sacc, sacc), R);
          q1 = veorq_u64(q1, ch128p_pm00(ps, two));
          vst1q_u64((uint64_t *)&k->kz[m], vzip1q_u64(q0, ch128p_fred_n(q1, R))); }
    }
    k->zero = ch128_make(0, 0);
}
#endif
#endif
#if defined(CH128_ARM)
CH128_NEND
#endif
/* E(P)_i = sum_k P_k alpha_i^k: with a hardware carry-less multiply, 8 unreduced products and one reduction per
 * value (v2.1; the bit-serial Horner took ~60% of setup) */
static inline uint64_t ch128p_eval_hw(const uint64_t P[8], unsigned i) {
    uint64_t lo = 0, hi = 0; unsigned d;
    for (d = 0; d < 8; d++) { uint64_t l, h; ch128p_clmul64_hw(P[d], ch128p_apow[i][d], &l, &h); lo ^= l; hi ^= h; }
    return ch128p_fred(lo, hi);
}
static inline void ch128p_key_from_bytes(ch128p_key *k, const uint8_t key[CH128P_KEY_BYTES]) {
    uint64_t s[8], pw[8]; unsigned i, e; int hw = CH128P_HAVE_HWCLMUL();
    memset(k, 0, sizeof(*k));
    for (i = 0; i < 8; i++) s[i] = ch128_load64(key + 8 * i);
    memcpy(pw, s, sizeof(pw));                       /* pw = s^1 */
#ifdef CH128P_HAVE_FASTSETUP
    if (hw) ch128p_masks_fast(k->mask, s); else
#endif
    for (e = 1; e <= 2 * CH128P_M; e++) {
        unsigned m = (e - 1) / 2, half = (e - 1) % 2;  /* e = 2m+1 -> u, 2m+2 -> v */
        for (i = 0; i < 8; i++) {                      /* E: Horner at alpha_i = i (small constants) */
            uint64_t ev = 0; int d;
            if (hw) ev = ch128p_eval_hw(pw, i); else for (d = 7; d >= 0; d--) ev = ch128p_fmul_small(ev, (uint64_t)i) ^ pw[d];
            if (half == 0) k->mask[8 * m + i].lo = ev; else k->mask[8 * m + i].hi = ev;
        }
        if (e < 2 * CH128P_M) ch128p_amul_fast(pw, pw, s, hw);
    }
#if defined(CH128P_HAVE_FASTSETUP)
    if (hw) ch128p_tables_fast(k); else
#endif
    ch128p_key_init_tables(k, hw ? ch128p_fmul_hw : ch128p_fmul_w);
    /* outer words (ChainHash-128's y, c0..c4, tau); powers y^i and 0x87*y^i by field multiply */
    { ch128_word y = ch128_load(key + 64); int b = hw;
      k->outer.yp[0] = ch128_make(1, 0); k->outer.yh[0] = ch128_make(0x87, 0);
      for (i = 1; i <= 8; i++) { k->outer.yp[i] = b ? ch128_mul(k->outer.yp[i - 1], y, 1) : ch128_mul_ref(k->outer.yp[i - 1], y);
                                 k->outer.yh[i] = b ? ch128_mul(k->outer.yp[i], k->outer.yh[0], 1) : ch128_mul_ref(k->outer.yp[i], k->outer.yh[0]); }
      for (i = 0; i < 5; i++) k->outer.c[i] = ch128_load(key + 80 + 16 * i);
      k->outer.tau = ch128_load(key + 160); }
    for (i = 0; i < 9; i++) k->yps[i] = ch128_make(k->outer.yp[i].hi, k->outer.yp[i].lo);
    for (i = 0; i < 9; i++) k->yhs[i] = ch128_make(k->outer.yh[i].hi, k->outer.yh[i].lo);
    for (i = 0; i < 8; i++) k->yr[i] = k->outer.yp[7 - i];
#if defined(CHAINHASH128V2_PREBC) && defined(CH128_X86)
    for (i = 0; i < CH128P_W; i++) { unsigned c; for (c = 0; c < 4; c++) k->mzb[i][c] = k->mask[i]; }
#endif
}
static inline void ch128p_key_from_seed(ch128p_key *k, uint64_t seed) {
    uint8_t p[CH128P_KEY_BYTES]; unsigned i, j;
    for (i = 0; i < CH128P_KEY_BYTES / 8; i++) {
        uint64_t z = (seed += UINT64_C(0x9e3779b97f4a7c15));
        z = (z ^ (z >> 30)) * UINT64_C(0xbf58476d1ce4e5b9); z = (z ^ (z >> 27)) * UINT64_C(0x94d049bb133111eb); z ^= z >> 31;
        for (j = 0; j < 8; j++) p[8 * i + j] = (uint8_t)(z >> (8 * j));
    }
    ch128p_key_from_bytes(k, p);
}

/* ChainHash-128's twist + degree-5 finalizer (its ch128_finish circuit), on ch128p_outer */
static inline ch128_word ch128p_finish_port(const ch128p_outer *k, ch128_word v, int b) {
    ch128_word q, r; v = ch128_addint(v, k->tau); q = ch128_mul(v, v, b);
    r = ch128_mul(ch128_xor(q, k->c[0]), ch128_xor(ch128_xor(v, q), k->c[1]), b);
    return ch128_xor(ch128_mul(ch128_xor(v, k->c[2]), ch128_xor(r, k->c[3]), b), k->c[4]);
}
/* ---------------- block count, oracle ---------------- */
static inline uint64_t ch128p_blocks(size_t n) {
    size_t q = n / CH128P_REGION, r = n % CH128P_REGION;
    if (!n) return 1;
    return CH128P_J * (uint64_t)q + (r ? ((r + 15) / 16 < CH128P_J ? (r + 15) / 16 : CH128P_J) : 0);
}
static inline uint64_t ch128p_ld8(const uint8_t *p, size_t n, size_t off) {
    uint8_t b[8] = {0}; size_t i; for (i = 0; i < 8; i++) if (off + i < n) b[i] = p[off + i];
    return ch128_load64(b);
}
/* Direct-definition block value (no deferral), 0-based block index t. */
static inline ch128_word ch128p_block_ref(const ch128p_key *k, const uint8_t *p, size_t n, uint64_t t) {
    size_t base = (size_t)(t / CH128P_J) * CH128P_REGION, j = (size_t)(t % CH128P_J); uint64_t Q0 = 0, Q1 = 0; unsigned m, i;
    for (m = 0; m < CH128P_M; m++) {
        uint64_t su = 0, sv = 0;
        if (base + CH128P_PV * m + 16 * j >= n) continue;
        for (i = 0; i < 8; i++) {
            size_t off = base + CH128P_PV * m + CH128P_ROW * i + 16 * j;
            uint64_t u = ch128p_ld8(p, n, off) ^ k->mask[8 * m + i].lo, v = ch128p_ld8(p, n, off + 8) ^ k->mask[8 * m + i].hi;
            uint64_t pr = ch128p_fmul(u, v);
            Q0 ^= pr; Q1 ^= ch128p_fmul(i, pr); su ^= u; sv ^= v;
        }
        Q1 ^= ch128p_fmul(2, ch128p_fmul(su, sv));
    }
    return ch128_make(Q0, Q1);
}

/* ---------------- region geometry for a partial region of r bytes ---------------- */
/* Row a (128 bytes) of a partial region: fully readable, partial, or beyond the data. */
typedef struct { const uint8_t *p; size_t r; uint8_t pad[128]; unsigned full_rows, data_rows, count, mhi; } ch128p_tailgeo;
static inline void ch128p_geo(ch128p_tailgeo *g, const uint8_t *p, size_t r) {
    g->p = p; g->r = r; g->full_rows = (unsigned)(r / CH128P_ROW); g->data_rows = (unsigned)((r + CH128P_ROW - 1) / CH128P_ROW);
    g->count = (unsigned)((r + 15) / 16 < CH128P_J ? (r + 15) / 16 : CH128P_J); g->mhi = (unsigned)((r - 1) / CH128P_PV);
    memset(g->pad, 0, 128);
    if (r % CH128P_ROW) memcpy(g->pad, p + CH128P_ROW * (r / CH128P_ROW), r % CH128P_ROW);
}
static inline const uint8_t *ch128p_row(const ch128p_tailgeo *g, unsigned a) {
    return a < g->full_rows ? g->p + CH128P_ROW * (size_t)a : g->pad;   /* only called for a < data_rows */
}
/* number of data rows of pair-vector m (rows beyond are all-zero for every lane) */
static inline unsigned ch128p_rows_in(const ch128p_tailgeo *g, unsigned m) {
    unsigned lo = 8 * m, hi = g->data_rows; return hi <= lo ? 0 : (hi - lo > 8 ? 8 : hi - lo);
}
/* pair-vector m present in block j of the partial region */
static inline int ch128p_pv_present(const ch128p_tailgeo *g, unsigned m, unsigned j) { return CH128P_PV * (size_t)m + 16 * j < g->r; }

/* ---------------- portable deferred path (scalar, second implementation) ---------------- */
typedef struct { uint64_t lo, hi; } ch128p_u128;
static inline ch128_word ch128p_fin_scalar(const ch128p_u128 D[8], ch128p_u128 P) {
    ch128p_u128 r0 = {0, 0}, B0, B1, B2; unsigned i; uint64_t r1lo, r1hi, ext;
    for (i = 0; i < 8; i++) { r0.lo ^= D[i].lo; r0.hi ^= D[i].hi; }
    B0.lo = D[1].lo ^ D[3].lo ^ D[5].lo ^ D[7].lo; B0.hi = D[1].hi ^ D[3].hi ^ D[5].hi ^ D[7].hi;
    B1.lo = D[2].lo ^ D[3].lo ^ D[6].lo ^ D[7].lo ^ P.lo; B1.hi = D[2].hi ^ D[3].hi ^ D[6].hi ^ D[7].hi ^ P.hi;
    B2.lo = D[4].lo ^ D[5].lo ^ D[6].lo ^ D[7].lo; B2.hi = D[4].hi ^ D[5].hi ^ D[6].hi ^ D[7].hi;
    r1lo = B0.lo ^ (B1.lo << 1) ^ (B2.lo << 2);
    r1hi = B0.hi ^ (B1.hi << 1) ^ (B1.lo >> 63) ^ (B2.hi << 2) ^ (B2.lo >> 62);
    ext = (B1.hi >> 63) ^ (B2.hi >> 62);       /* bit 128 (products have degree <= 126) */
    r1hi ^= ext ^ (ext << 1) ^ (ext << 3) ^ (ext << 4);
    return ch128_make(ch128p_fred(r0.lo, r0.hi), ch128p_fred(r1lo, r1hi));
}
/* block j of a (possibly partial) region via the geometry; full regions use g->r = REGION */
static inline ch128_word ch128p_block_scalar(const ch128p_key *k, const ch128p_tailgeo *g, unsigned j) {
    ch128_word b = ch128_make(0, 0); unsigned m, i;
    for (m = 0; m < CH128P_M; m++) {
        ch128p_u128 D[8] = {{0, 0}}, P; uint64_t su, sv; unsigned nr = ch128p_rows_in(g, m);
        if (!ch128p_pv_present(g, m, j)) continue;
        su = CH128P_SMP(k, m, nr)->lo; sv = CH128P_SMP(k, m, nr)->hi;
        for (i = 0; i < nr; i++) {
            const uint8_t *q = ch128p_row(g, 8 * m + i) + 16 * j;
            uint64_t u = ch128_load64(q) ^ k->mask[8 * m + i].lo, v = ch128_load64(q + 8) ^ k->mask[8 * m + i].hi;
            ch128p_clmul64(u, v, &D[i].lo, &D[i].hi); su ^= u; sv ^= v;
        }
        ch128p_clmul64(su, sv, &P.lo, &P.hi);
        b = ch128_xor(b, ch128_xor(ch128p_fin_scalar(D, P), *CH128P_KDP(k, m, nr)));
    }
    return b;
}

#if defined(__clang__)
#define CH128P_NOUNROLL _Pragma("clang loop unroll(disable)")
#elif defined(__GNUC__)
#define CH128P_NOUNROLL _Pragma("GCC unroll 1")
#else
#define CH128P_NOUNROLL
#endif
/* ---------------- dispatch ids ---------------- */
enum { CH128P_PORTABLE = 0, CH128P_XMM = 1, CH128P_ZMM = 3, CH128P_NEON = 4 };

/* ================================ x86 ================================ */
#ifdef CH128_X86
#define CH128P_T512 __attribute__((target("avx2,pclmul,avx512f,avx512bw,avx512vl,vpclmulqdq")))
/* CPUID by inline assembly (chainhash no longer includes <cpuid.h>: gcc 9's has no include guard). */
static inline void ch128p_cpuid(unsigned leaf, unsigned sub, unsigned r[4]) {
    __asm__ __volatile__("cpuid" : "=a"(r[0]), "=b"(r[1]), "=c"(r[2]), "=d"(r[3]) : "a"(leaf), "c"(sub));
}
static inline int ch128p_leaf7_ebx(unsigned *ebx) { unsigned r[4]; ch128p_cpuid(0, 0, r); if (r[0] < 7) return 0; ch128p_cpuid(7, 0, r); *ebx = r[1]; return 1; }
static inline int ch128p_detect(void) {
    unsigned a, b, c, d; int base = chainhash128_backend();
    if (base < 1) return 0;
    (void)a; (void)c; (void)d;
    if (base == 3 && ch128p_leaf7_ebx(&b) && (b & (1u << 30)) && (b & (1u << 31))) return 3;
    return 1;
}
static inline int ch128p_xschool(void);
/* v2.2: the finalizer in latency form (same value as ch128_128_finish). ch128p_128_redh(hi, &e): the high half's
 * share of a reduction, hi*0x87 by two products (returned), the carry-out fold by shifts in *e, so
 * (p mod f) ^ c = (p.lo ^ c ^ e) ^ result: a constant enters a reduction without a level of its own. */
CH128_T128 static inline __m128i ch128p_128_redh(__m128i hi, __m128i *e) {
    const __m128i r = _mm_cvtsi32_si128(0x87);
    __m128i t = _mm_srli_si128(_mm_xor_si128(_mm_srli_epi64(hi, 63), _mm_xor_si128(_mm_srli_epi64(hi, 62), _mm_srli_epi64(hi, 57))), 8);
    *e = _mm_xor_si128(t, _mm_xor_si128(_mm_slli_epi64(t, 1), _mm_xor_si128(_mm_slli_epi64(t, 2), _mm_slli_epi64(t, 7))));
    return _mm_xor_si128(_mm_clmulepi64_si128(hi, r, 0x00), _mm_slli_si128(_mm_clmulepi64_si128(hi, r, 0x01), 8));
}
CH128_T128 static inline __m128i ch128p_128_redc(ch128_128_raw p, __m128i c) {
    __m128i e, h = ch128p_128_redh(p.hi, &e); return _mm_xor_si128(_mm_xor_si128(p.lo, _mm_xor_si128(c, e)), h);
}
/* z*X^128 mod f by shifts (no product) */
CH128_T128 static inline __m128i ch128p_128_x128(__m128i z) {
    __m128i c = _mm_xor_si128(_mm_srli_epi64(z, 63), _mm_xor_si128(_mm_srli_epi64(z, 62), _mm_srli_epi64(z, 57))), t = _mm_srli_si128(c, 8);
    return _mm_xor_si128(_mm_xor_si128(_mm_xor_si128(z, _mm_slli_epi64(z, 1)), _mm_xor_si128(_mm_slli_epi64(z, 2), _mm_slli_epi64(z, 7))),
                         _mm_xor_si128(_mm_xor_si128(t, _mm_slli_si128(c, 8)), _mm_xor_si128(_mm_slli_epi64(t, 1), _mm_xor_si128(_mm_slli_epi64(t, 2), _mm_slli_epi64(t, 7)))));
}
/* x = v + tau in a register; the sign-flipped sum comes from its own addition */
CH128_T128 static inline __m128i ch128p_128_twist(const ch128p_outer *k, __m128i v) {
    const __m128i sign = _mm_set_epi64x(0, (long long)0x8000000000000000ull);
    __m128i t = _mm_loadu_si128((const __m128i *)&k->tau), ts = _mm_xor_si128(t, sign);
    return _mm_sub_epi64(_mm_add_epi64(v, t), _mm_slli_si128(_mm_cmpgt_epi64(ts, _mm_add_epi64(v, ts)), 8));
}
/* x = v + tau, q = x^2, R = (q^c0)(x^q^c1), out = z*(R^c3) ^ c4 (z = x^c2): q^c0 and x^q^c1 share the
 * reduction of x^2 with the constants injected; the last product absorbs R's reduction,
 * z*(R^c3) = z*(R.lo^c3) ^ w*R.hi, w = z*X^128 mod f. Where PCLMULQDQ issues every cycle (Intel with
 * ADX), z*c3 ^ c4 is reduced beside R instead (fewer levels, more products). */
CH128_T128 static inline ch128_word ch128p_128_finish(const ch128p_outer *k, __m128i vv) {   /* = ch128_128_finish */
    const int sc = ch128p_xschool();
    __m128i x = ch128p_128_twist(k, vv), e, H, a, b, z, w, F; ch128_128_raw Q, R; ch128_128_acc A; ch128_word o;
    Q.lo = _mm_clmulepi64_si128(x, x, 0x00); Q.hi = _mm_clmulepi64_si128(x, x, 0x11); H = ch128p_128_redh(Q.hi, &e);
    a = _mm_xor_si128(_mm_xor_si128(Q.lo, _mm_xor_si128(e, _mm_loadu_si128((const __m128i *)k->c))), H);
    b = _mm_xor_si128(_mm_xor_si128(Q.lo, _mm_xor_si128(e, _mm_xor_si128(x, _mm_loadu_si128((const __m128i *)(k->c + 1))))), H);
    z = _mm_xor_si128(x, _mm_loadu_si128((const __m128i *)(k->c + 2))); w = ch128p_128_x128(z); R = ch128_128_prod(a, b, sc);
    if (sc) {
        F = ch128p_128_redc(ch128_128_prod(z, _mm_loadu_si128((const __m128i *)(k->c + 3)), sc), _mm_loadu_si128((const __m128i *)(k->c + 4)));
        A = ch128_128_accum(ch128_128_accum(ch128_128_azero(), z, R.lo, sc), w, R.hi, sc);
    } else {
        F = _mm_loadu_si128((const __m128i *)(k->c + 4));
        A = ch128_128_accum(ch128_128_accum(ch128_128_azero(), z, _mm_xor_si128(R.lo, _mm_loadu_si128((const __m128i *)(k->c + 3))), sc), w, R.hi, sc);
    }
    vv = ch128p_128_redc(ch128_128_pack(A, sc), F); o.lo = (uint64_t)_mm_cvtsi128_si64(vv); o.hi = (uint64_t)_mm_extract_epi64(vv, 1); return o;
}
/* ---- 128-bit (PCLMUL) finalize: 8 role accumulators + parity -> {Q0,Q1} ---- */
CH128_T128 static inline __m128i ch128p_128_sl1(__m128i v) { return _mm_or_si128(_mm_slli_epi64(v, 1), _mm_srli_epi64(_mm_slli_si128(v, 8), 63)); }
CH128_T128 static inline __m128i ch128p_128_fin(__m128i D0, __m128i D1, __m128i D2, __m128i D3, __m128i D4, __m128i D5, __m128i D6, __m128i D7, __m128i P) {
    const __m128i tab = _mm_setr_epi8(0x00,0x1b,0x2d,0x36,0x5a,0x41,0x77,0x6c,(char)0xaf,(char)0xb4,(char)0x82,(char)0x99,(char)0xf5,(char)0xee,(char)0xd8,(char)0xc3);
    const __m128i ce = _mm_set_epi64x(0x1b, 0);
    __m128i t37 = _mm_xor_si128(D3, D7), t56 = _mm_xor_si128(D5, D6);
    __m128i B0 = _mm_xor_si128(_mm_xor_si128(D1, D5), t37);
    __m128i B1 = _mm_xor_si128(_mm_xor_si128(D2, D6), _mm_xor_si128(t37, P));
    __m128i B2 = _mm_xor_si128(_mm_xor_si128(D4, D7), t56);
    __m128i r0 = _mm_xor_si128(_mm_xor_si128(_mm_xor_si128(D0, D1), _mm_xor_si128(D2, D4)), _mm_xor_si128(t37, t56));
    __m128i T = _mm_xor_si128(B1, ch128p_128_sl1(B2));
    __m128i r1 = _mm_xor_si128(B0, ch128p_128_sl1(T));
    __m128i L = _mm_unpacklo_epi64(r0, r1), H = _mm_unpackhi_epi64(r0, r1);
    H = _mm_xor_si128(H, _mm_and_si128(_mm_sub_epi64(_mm_setzero_si128(), _mm_srli_epi64(T, 63)), ce));
    { __m128i f = _mm_xor_si128(_mm_xor_si128(H, _mm_slli_epi64(H, 1)), _mm_xor_si128(_mm_slli_epi64(H, 3), _mm_slli_epi64(H, 4)));
      f = _mm_xor_si128(f, _mm_shuffle_epi8(tab, _mm_srli_epi64(H, 60)));
      return _mm_xor_si128(L, f); }
}
/* fin when roles 4..7 carry no data (D4..D7 = 0): B2 = 0, raw1 = B0 ^ X*B1 fits 128 bits */
CH128_T128 static inline __m128i ch128p_128_fin4(__m128i D0, __m128i D1, __m128i D2, __m128i D3, __m128i P) {
    const __m128i tab = _mm_setr_epi8(0x00,0x1b,0x2d,0x36,0x5a,0x41,0x77,0x6c,(char)0xaf,(char)0xb4,(char)0x82,(char)0x99,(char)0xf5,(char)0xee,(char)0xd8,(char)0xc3);
    __m128i t3 = _mm_xor_si128(D2, D3), r0 = _mm_xor_si128(_mm_xor_si128(D0, D1), t3), r1 = _mm_xor_si128(_mm_xor_si128(D1, D3), ch128p_128_sl1(_mm_xor_si128(t3, P)));
    __m128i L = _mm_unpacklo_epi64(r0, r1), H = _mm_unpackhi_epi64(r0, r1);
    __m128i f = _mm_xor_si128(_mm_xor_si128(H, _mm_slli_epi64(H, 1)), _mm_xor_si128(_mm_slli_epi64(H, 3), _mm_slli_epi64(H, 4)));
    return _mm_xor_si128(L, _mm_xor_si128(f, _mm_shuffle_epi8(tab, _mm_srli_epi64(H, 60))));
}
/* ---- AVX2 + PCLMUL (no VPCLMULQDQ): two blocks per ymm for everything except the clmuls ----
 * One 32-byte load = blocks j, j+1 of a row; the per-block reduction (combine, bit-plane shifts,
 * F-fold) is lane-local, so one ymm pass reduces two blocks. 8 D + S + P + temps fit 16 ymm. */
#define CH128P_T256X __attribute__((target("avx2,pclmul")))
CH128P_T256X static inline __m256i ch128p_256_sl1(__m256i v) { return _mm256_or_si256(_mm256_slli_epi64(v, 1), _mm256_srli_epi64(_mm256_bslli_epi128(v, 8), 63)); }
CH128P_T256X static inline __m256i ch128p_256_fin(__m256i D0, __m256i D1, __m256i D2, __m256i D3, __m256i D4, __m256i D5, __m256i D6, __m256i D7, __m256i P) {
    const __m256i tab = _mm256_broadcastsi128_si256(_mm_setr_epi8(0x00,0x1b,0x2d,0x36,0x5a,0x41,0x77,0x6c,(char)0xaf,(char)0xb4,(char)0x82,(char)0x99,(char)0xf5,(char)0xee,(char)0xd8,(char)0xc3));
    const __m256i ce = _mm256_broadcastsi128_si256(_mm_set_epi64x(0x1b, 0));
    __m256i t37 = _mm256_xor_si256(D3, D7), t56 = _mm256_xor_si256(D5, D6);
    __m256i B0 = _mm256_xor_si256(_mm256_xor_si256(D1, D5), t37);
    __m256i B1 = _mm256_xor_si256(_mm256_xor_si256(D2, D6), _mm256_xor_si256(t37, P));
    __m256i B2 = _mm256_xor_si256(_mm256_xor_si256(D4, D7), t56);
    __m256i r0 = _mm256_xor_si256(_mm256_xor_si256(_mm256_xor_si256(D0, D1), _mm256_xor_si256(D2, D4)), _mm256_xor_si256(t37, t56));
    __m256i T = _mm256_xor_si256(B1, ch128p_256_sl1(B2)), r1 = _mm256_xor_si256(B0, ch128p_256_sl1(T));
    __m256i L = _mm256_unpacklo_epi64(r0, r1), H = _mm256_unpackhi_epi64(r0, r1), f;
    H = _mm256_xor_si256(H, _mm256_and_si256(_mm256_sub_epi64(_mm256_setzero_si256(), _mm256_srli_epi64(T, 63)), ce));
    f = _mm256_xor_si256(_mm256_xor_si256(H, _mm256_slli_epi64(H, 1)), _mm256_xor_si256(_mm256_slli_epi64(H, 3), _mm256_slli_epi64(H, 4)));
    f = _mm256_xor_si256(f, _mm256_shuffle_epi8(tab, _mm256_srli_epi64(H, 60)));
    return _mm256_xor_si256(L, f);
}
CH128P_T256X static inline __m256i ch128p_256_fin4(__m256i D0, __m256i D1, __m256i D2, __m256i D3, __m256i P) {   /* roles 4..7 empty */
    const __m256i tab = _mm256_broadcastsi128_si256(_mm_setr_epi8(0x00,0x1b,0x2d,0x36,0x5a,0x41,0x77,0x6c,(char)0xaf,(char)0xb4,(char)0x82,(char)0x99,(char)0xf5,(char)0xee,(char)0xd8,(char)0xc3));
    __m256i t3 = _mm256_xor_si256(D2, D3), r0 = _mm256_xor_si256(_mm256_xor_si256(D0, D1), t3);
    __m256i r1 = _mm256_xor_si256(_mm256_xor_si256(D1, D3), ch128p_256_sl1(_mm256_xor_si256(t3, P)));
    __m256i L = _mm256_unpacklo_epi64(r0, r1), H = _mm256_unpackhi_epi64(r0, r1);
    __m256i f = _mm256_xor_si256(_mm256_xor_si256(H, _mm256_slli_epi64(H, 1)), _mm256_xor_si256(_mm256_slli_epi64(H, 3), _mm256_slli_epi64(H, 4)));
    return _mm256_xor_si256(L, _mm256_xor_si256(f, _mm256_shuffle_epi8(tab, _mm256_srli_epi64(H, 60))));
}
CH128P_T256X static inline __m256i ch128p_256_clmul2(__m256i w) {   /* u*v in each 128-bit lane */
    __m128i lo = _mm256_castsi256_si128(w), hi = _mm256_extracti128_si256(w, 1);
    return _mm256_inserti128_si256(_mm256_castsi128_si256(_mm_clmulepi64_si128(lo, lo, 0x10)), _mm_clmulepi64_si128(hi, hi, 0x10), 1);
}
/* 0 < r <= REGION bytes of one region: V <- V*y^count + sum_j b_j y^(count-1-j). Full regions
 * (r = REGION) make it the bulk step too. */
CH128P_T256X static __attribute__((noinline)) ch128_word ch128p_256_region(const ch128p_key *k, const uint8_t *p, size_t r, ch128_word v) {
    unsigned full_rows = (unsigned)(r / CH128P_ROW), count = (unsigned)((r + 15) / 16 < CH128P_J ? (r + 15) / 16 : CH128P_J), mhi = (unsigned)((r - 1) / CH128P_PV), j, m;
    uint8_t pad[128]; unsigned nr[CH128P_M]; ch128_128_acc a; __m256i kds = _mm256_setzero_si256();
    const __m256i kzv = _mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i *)&k->kz[mhi]));
    if (r % CH128P_ROW) { memset(pad, 0, 128); memcpy(pad, p + CH128P_ROW * (size_t)full_rows, r % CH128P_ROW); }
    for (m = 0; m <= mhi; m++) { unsigned d = (unsigned)((r + CH128P_ROW - 1) / CH128P_ROW) - 8 * m; nr[m] = d > 8 ? 8 : d; kds = _mm256_xor_si256(kds, _mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i *)CH128P_KDP(k, m, nr[m])))); }
    a = ch128_128_accum(ch128_128_azero(), _mm_set_epi64x((long long)v.hi, (long long)v.lo), ch128_128_load(k->outer.yp + count), 1);
    if (r > 112 && r <= 512) {
        /* 113..512 B: all 8 blocks, one pair-vector, nr <= 4 rows; four blocks per iteration
         * (two ymm pairs = four reduction chains), constant indices, reduced fin. */
        unsigned nr0 = nr[0], jq;
        const __m256i s0 = _mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i *)CH128P_SMP(k, 0, nr0)));
        for (jq = 0; jq < 8; jq += 4) {
            __m256i z = _mm256_setzero_si256(), E0 = z, E1 = z, E2 = z, E3 = z, F0 = z, F1 = z, F2 = z, F3 = z, SE = s0, SF = s0, bE, bF;
#define CH128P_Y4ROW(ii) if (ii < nr0) { const uint8_t *q = (ii < full_rows ? p + CH128P_ROW * ii : pad) + 16 * jq; __m256i kk = _mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i *)(k->mask + ii))); \
                __m256i we = _mm256_xor_si256(_mm256_loadu_si256((const __m256i *)q), kk), wf = _mm256_xor_si256(_mm256_loadu_si256((const __m256i *)(q + 32)), kk); \
                E##ii = ch128p_256_clmul2(we); F##ii = ch128p_256_clmul2(wf); SE = _mm256_xor_si256(SE, we); SF = _mm256_xor_si256(SF, wf); }
            CH128P_Y4ROW(0) CH128P_Y4ROW(1) CH128P_Y4ROW(2) CH128P_Y4ROW(3)
#undef CH128P_Y4ROW
            bE = _mm256_xor_si256(ch128p_256_fin4(E0, E1, E2, E3, ch128p_256_clmul2(SE)), kds);
            bF = _mm256_xor_si256(ch128p_256_fin4(F0, F1, F2, F3, ch128p_256_clmul2(SF)), kds);
            a = ch128_128_accum(a, _mm256_castsi256_si128(bE), ch128_128_load(k->yr + jq), 1);
            a = ch128_128_accum(a, _mm256_extracti128_si256(bE, 1), ch128_128_load(k->yr + jq + 1), 1);
            a = ch128_128_accum(a, _mm256_castsi256_si128(bF), ch128_128_load(k->yr + jq + 2), 1);
            a = ch128_128_accum(a, _mm256_extracti128_si256(bF, 1), ch128_128_load(k->yr + jq + 3), 1);
        }
        ch128_128_store(&v, ch128_128_reduce(ch128_128_pack(a, 1))); return v;
    }
    if (r > 512 && r <= 1024) {
        /* 513..1024 B: one pair-vector, 5..8 rows; two blocks per ymm, constant (guarded) row indices */
        unsigned nr0 = nr[0];
        const __m256i s0 = _mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i *)CH128P_SMP(k, 0, nr0)));
        for (j = 0; j < 8; j += 2) {
            __m256i z = _mm256_setzero_si256(), D0 = z, D1 = z, D2 = z, D3 = z, D4 = z, D5 = z, D6 = z, D7 = z, S = s0, b;
#define CH128P_Y2ROW(ii) if (ii < nr0) { const uint8_t *q = (ii < full_rows ? p + CH128P_ROW * ii : pad) + 16 * j; \
                __m256i w = _mm256_xor_si256(_mm256_loadu_si256((const __m256i *)q), _mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i *)(k->mask + ii)))); \
                D##ii = ch128p_256_clmul2(w); S = _mm256_xor_si256(S, w); }
            CH128P_Y2ROW(0) CH128P_Y2ROW(1) CH128P_Y2ROW(2) CH128P_Y2ROW(3) CH128P_Y2ROW(4) CH128P_Y2ROW(5) CH128P_Y2ROW(6) CH128P_Y2ROW(7)
#undef CH128P_Y2ROW
            b = _mm256_xor_si256(ch128p_256_fin(D0, D1, D2, D3, D4, D5, D6, D7, ch128p_256_clmul2(S)), kds);
            a = ch128_128_accum(a, _mm256_castsi256_si128(b), ch128_128_load(k->yr + j), 1);
            a = ch128_128_accum(a, _mm256_extracti128_si256(b, 1), ch128_128_load(k->yr + j + 1), 1);
        }
        ch128_128_store(&v, ch128_128_reduce(ch128_128_pack(a, 1))); return v;
    }
    for (j = 0; j < count; j += 2) {
        __m256i z = _mm256_setzero_si256(), D0 = z, D1 = z, D2 = z, D3 = z, D4 = z, D5 = z, D6 = z, D7 = z, P = z, b;
        CH128P_NOUNROLL
        for (m = 0; m <= mhi; m++) {
            __m256i S = _mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i *)CH128P_SMP(k, m, nr[m]))); const ch128_word *mk = k->mask + 8 * m;
#define CH128P_YROW(ii, row) { __m256i w = _mm256_xor_si256(_mm256_loadu_si256((const __m256i *)((row) + 16 * j)), _mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i *)(mk + ii)))); \
                D##ii = _mm256_xor_si256(D##ii, ch128p_256_clmul2(w)); S = _mm256_xor_si256(S, w); }
            if (8 * m + 8 <= full_rows) {
                const uint8_t *q0 = p + CH128P_PV * (size_t)m;
                CH128P_YROW(0, q0) CH128P_YROW(1, q0 + 1 * CH128P_ROW) CH128P_YROW(2, q0 + 2 * CH128P_ROW) CH128P_YROW(3, q0 + 3 * CH128P_ROW)
                CH128P_YROW(4, q0 + 4 * CH128P_ROW) CH128P_YROW(5, q0 + 5 * CH128P_ROW) CH128P_YROW(6, q0 + 6 * CH128P_ROW) CH128P_YROW(7, q0 + 7 * CH128P_ROW)
            } else {
#define CH128P_YROWC(ii) { unsigned a_ = 8 * m + ii; CH128P_YROW(ii, (a_ < full_rows ? p + CH128P_ROW * (size_t)a_ : pad)) }
                switch (nr[m]) {
                case 8: CH128P_YROWC(7) /* fall through */ case 7: CH128P_YROWC(6) /* fall through */ case 6: CH128P_YROWC(5) /* fall through */
                case 5: CH128P_YROWC(4) /* fall through */ case 4: CH128P_YROWC(3) /* fall through */ case 3: CH128P_YROWC(2) /* fall through */
                case 2: CH128P_YROWC(1) /* fall through */ default: CH128P_YROWC(0) }
#undef CH128P_YROWC
            }
#undef CH128P_YROW
            P = _mm256_xor_si256(P, ch128p_256_clmul2(S));
        }
        b = _mm256_xor_si256(ch128p_256_fin(D0, D1, D2, D3, D4, D5, D6, D7, P), kds);
        if (mhi) {
            if (CH128P_PV * (size_t)mhi + 16 * j >= r) b = _mm256_xor_si256(b, _mm256_blend_epi32(z, kzv, 0x0f));
            if (CH128P_PV * (size_t)mhi + 16 * (j + 1) >= r) b = _mm256_xor_si256(b, _mm256_blend_epi32(z, kzv, 0xf0));
        }
        a = ch128_128_accum(a, _mm256_castsi256_si128(b), ch128_128_load(k->yr + 8 - count + j), 1);
        a = ch128_128_accum(a, _mm256_extracti128_si256(b, 1), ch128_128_load(k->yr + 9 - count + j), 1);
    }
    ch128_128_store(&v, ch128_128_reduce(ch128_128_pack(a, 1))); return v;
}
static inline int ch128p_has_avx2(void) {   /* -DCH128P_NO_AVX2 forces the plain PCLMUL path (tests) */
#ifdef CH128P_NO_AVX2
    return 0;
#endif
    static int cache = -1; int v = __atomic_load_n(&cache, __ATOMIC_RELAXED);
    if (v < 0) { unsigned b_ = 0; v = chainhash128_backend() >= 1 && ch128p_leaf7_ebx(&b_) && (b_ & (1u << 5)) ? 1 : 0; __atomic_store_n(&cache, v, __ATOMIC_RELAXED); }
    return v;
}
/* 1..128 bytes (J = 8), 1..ROW bytes (J = 4, 2): row 0 only, block j = word j; one block per xmm lane */
CH128_T128 static inline __m128i ch128p_128_sfin(__m128i w, __m128i S1, __m128i KD) {
    const __m128i tab = _mm_setr_epi8(0x00,0x1b,0x2d,0x36,0x5a,0x41,0x77,0x6c,(char)0xaf,(char)0xb4,(char)0x82,(char)0x99,(char)0xf5,(char)0xee,(char)0xd8,(char)0xc3);
    __m128i S = _mm_xor_si128(w, S1), D = _mm_clmulepi64_si128(w, w, 0x10), r1 = ch128p_128_sl1(_mm_clmulepi64_si128(S, S, 0x10));
    __m128i L = _mm_unpacklo_epi64(D, r1), H = _mm_unpackhi_epi64(D, r1);
    __m128i f = _mm_xor_si128(_mm_xor_si128(H, _mm_slli_epi64(H, 1)), _mm_xor_si128(_mm_slli_epi64(H, 3), _mm_slli_epi64(H, 4)));
    f = _mm_xor_si128(f, _mm_shuffle_epi8(tab, _mm_srli_epi64(H, 60)));
    return _mm_xor_si128(_mm_xor_si128(L, f), KD);
}

/* ---- PCLMUL-only backend, round 4 (XMM lane): asm-step bulk + tails ---- */
#define CH128P_XSTR2(x) #x
#define CH128P_XSTR(x) CH128P_XSTR2(x)
#define CH128P_XSTEP \
  "vmovdqu (0*%c11)(%9), %%xmm12\n\t" \
  "vpxor 0(%10), %%xmm12, %%xmm12\n\t" \
  "vpclmulqdq $0x10, %%xmm12, %%xmm12, %%xmm14\n\t" \
  "vpxor %%xmm14, %0, %0\n\t" \
  "vmovdqu (1*%c11)(%9), %%xmm13\n\t" \
  "vpxor 16(%10), %%xmm13, %%xmm13\n\t" \
  "vpclmulqdq $0x10, %%xmm13, %%xmm13, %%xmm14\n\t" \
  "vpxor %%xmm14, %1, %1\n\t" \
  "vpxor %%xmm12, %%xmm13, %%xmm15\n\t" \
  "vmovdqu (2*%c11)(%9), %%xmm12\n\t" \
  "vpxor 32(%10), %%xmm12, %%xmm12\n\t" \
  "vpclmulqdq $0x10, %%xmm12, %%xmm12, %%xmm14\n\t" \
  "vpxor %%xmm14, %2, %2\n\t" \
  "vpxor %%xmm12, %%xmm15, %%xmm15\n\t" \
  "vmovdqu (3*%c11)(%9), %%xmm13\n\t" \
  "vpxor 48(%10), %%xmm13, %%xmm13\n\t" \
  "vpclmulqdq $0x10, %%xmm13, %%xmm13, %%xmm14\n\t" \
  "vpxor %%xmm14, %3, %3\n\t" \
  "vpxor %%xmm13, %%xmm15, %%xmm15\n\t" \
  "vmovdqu (4*%c11)(%9), %%xmm12\n\t" \
  "vpxor 64(%10), %%xmm12, %%xmm12\n\t" \
  "vpclmulqdq $0x10, %%xmm12, %%xmm12, %%xmm14\n\t" \
  "vpxor %%xmm14, %4, %4\n\t" \
  "vpxor %%xmm12, %%xmm15, %%xmm15\n\t" \
  "vmovdqu (5*%c11)(%9), %%xmm13\n\t" \
  "vpxor 80(%10), %%xmm13, %%xmm13\n\t" \
  "vpclmulqdq $0x10, %%xmm13, %%xmm13, %%xmm14\n\t" \
  "vpxor %%xmm14, %5, %5\n\t" \
  "vpxor %%xmm13, %%xmm15, %%xmm15\n\t" \
  "vmovdqu (6*%c11)(%9), %%xmm12\n\t" \
  "vpxor 96(%10), %%xmm12, %%xmm12\n\t" \
  "vpclmulqdq $0x10, %%xmm12, %%xmm12, %%xmm14\n\t" \
  "vpxor %%xmm14, %6, %6\n\t" \
  "vpxor %%xmm12, %%xmm15, %%xmm15\n\t" \
  "vmovdqu (7*%c11)(%9), %%xmm13\n\t" \
  "vpxor 112(%10), %%xmm13, %%xmm13\n\t" \
  "vpclmulqdq $0x10, %%xmm13, %%xmm13, %%xmm14\n\t" \
  "vpxor %%xmm14, %7, %7\n\t" \
  "vpxor %%xmm13, %%xmm15, %%xmm15\n\t" \
  "vpclmulqdq $0x10, %%xmm15, %%xmm15, %%xmm14\n\t" \
  "vpxor %%xmm14, %8, %8\n\t" \
  ""
/* full-region block j: 16 pair-vector steps in inline asm (fixed temporaries xmm12-15, 8 role
 * accumulators + parity in registers; no spills under gcc or clang), then v1's xmm fin. */
CH128_T128 static inline __attribute__((always_inline)) __m128i ch128p_x_fullblock(const ch128p_key *k, const uint8_t *p, unsigned j, int pf) {
    __m128i D0 = _mm_setzero_si128(), D1 = D0, D2 = D0, D3 = D0, D4 = D0, D5 = D0, D6 = D0, D7 = D0, P = D0; unsigned m;
    const ch128_word *mk = k->mask;
    const uint8_t *nx = p + CH128P_REGION + (size_t)CH128P_REGION / CH128P_J * j;
    p += 16 * j;
    for (m = 0; m < CH128P_M; m++) {
        if (pf) {   /* next region, two lines per step (Intel: +3%; Zen 4: -3%, so off there) */
            _mm_prefetch((const char *)(nx + (size_t)CH128P_REGION / CH128P_J / CH128P_M * m), _MM_HINT_T0);
            _mm_prefetch((const char *)(nx + (size_t)CH128P_REGION / CH128P_J / CH128P_M * m + 64), _MM_HINT_T0);
        }
        __asm__(CH128P_XSTEP : "+x"(D0), "+x"(D1), "+x"(D2), "+x"(D3), "+x"(D4), "+x"(D5), "+x"(D6), "+x"(D7), "+x"(P)
                : "r"(p + CH128P_PV * m), "r"(mk + 8 * m), "i"(CH128P_ROW) : "xmm12", "xmm13", "xmm14", "xmm15", "memory");
    }
    return ch128p_128_fin(D0, D1, D2, D3, D4, D5, D6, D7, P);
}
CH128_T128 static inline __attribute__((always_inline)) ch128_word ch128p_x_bulk_t(const ch128p_key *k, const uint8_t *p, size_t regions, ch128_word vin, int pf) {
    const ch128p_outer *o = &k->outer; ch128_128_raw st; ch128_word v;
    st.lo = ch128_128_load(&vin); st.hi = ch128_128_zero();
    do {
        ch128_128_acc a = ch128_128_azero(); unsigned j;
        a = ch128_128_accum(a, st.lo, ch128_128_load(o->yp + CH128P_J), 1); a = ch128_128_accum(a, st.hi, ch128_128_load(o->yh + CH128P_J), 1);
        for (j = 0; j < CH128P_J - 1; j++) a = ch128_128_accum(a, ch128p_x_fullblock(k, p, j, pf), ch128_128_load(o->yp + CH128P_J - 1 - j), 1);
        st = ch128_128_pack(a, 1); st.lo = _mm_xor_si128(st.lo, ch128p_x_fullblock(k, p, CH128P_J - 1, pf));
        p += CH128P_REGION;
    } while (--regions);
    ch128_128_store(&v, ch128_128_reduce(st)); return v;
}
CH128_T128 static __attribute__((noinline)) ch128_word ch128p_x_bulk_pf(const ch128p_key *k, const uint8_t *p, size_t regions, ch128_word vin) { return ch128p_x_bulk_t(k, p, regions, vin, 1); }
CH128_T128 static __attribute__((noinline)) ch128_word ch128p_x_bulk_np(const ch128p_key *k, const uint8_t *p, size_t regions, ch128_word vin) { return ch128p_x_bulk_t(k, p, regions, vin, 0); }
static inline int ch128p_x_amd(void);
/* full regions, PCLMUL-only: the asm-step kernel, with next-region prefetch except on AMD */
static inline ch128_word ch128p_x_bulk(const ch128p_key *k, const uint8_t *p, size_t regions, ch128_word vin) {
#ifdef CH128P_NO_PREFETCH
    return ch128p_x_bulk_np(k, p, regions, vin);
#else
    return ch128p_x_amd() ? ch128p_x_bulk_np(k, p, regions, vin) : ch128p_x_bulk_pf(k, p, regions, vin);
#endif
}
/* The 16-byte word at p+o with bytes at or past p+r zeroed, read in place (chainhash 2c61966's
 * pattern: the partial word is the 16 bytes ending at p+r, shifted by PSHUFB); a 16-byte copy only
 * when fewer than 16 bytes precede p+r (streaming finals). No pad buffer, no store-forwarding stall. */
CH128_T128 static inline __m128i ch128p_x_word(const uint8_t *p, size_t o, size_t r) {
    if (o + 16 <= r) return _mm_loadu_si128((const __m128i *)(p + o));
    if (o >= r) return _mm_setzero_si128();
    if (r >= 16) return ch128_128_word(p, o, r);
    { uint64_t w[2] = {0, 0}; size_t i; for (i = 0; i < r - o; i++) w[i >> 3] |= (uint64_t)p[o + i] << (8 * (i & 7));   /* no call: a memcpy here would clobber the caller's vector registers */
      return _mm_set_epi64x((long long)w[1], (long long)w[0]); }
}
/* block j of a partial region: full pair-vectors through the asm step, the last partial one by rows
 * (rows past the data enter as the constants sm/kd, as in v1). */
CH128_T128 static inline __m128i ch128p_x_tblock(const ch128p_key *k, const uint8_t *p, const uint8_t *pad, unsigned full_rows, unsigned mhi, const unsigned *nr, unsigned j) {
    __m128i D0 = _mm_setzero_si128(), D1 = D0, D2 = D0, D3 = D0, D4 = D0, D5 = D0, D6 = D0, D7 = D0, P = D0; unsigned m;
    CH128P_NOUNROLL
    for (m = 0; m <= mhi; m++) {
        if (8 * m + 8 <= full_rows) {
            __asm__(CH128P_XSTEP : "+x"(D0), "+x"(D1), "+x"(D2), "+x"(D3), "+x"(D4), "+x"(D5), "+x"(D6), "+x"(D7), "+x"(P)
                    : "r"(p + 16 * j + CH128P_PV * (size_t)m), "r"(k->mask + 8 * m), "i"(CH128P_ROW) : "xmm12", "xmm13", "xmm14", "xmm15", "memory");
        } else {
            __m128i S = _mm_loadu_si128((const __m128i *)CH128P_SMP(k, m, nr[m])); const ch128_word *mk = k->mask + 8 * m;
#define XK_ROW(ii) { unsigned a_ = 8 * m + ii; const uint8_t *q = (a_ < full_rows ? p + CH128P_ROW * (size_t)a_ : pad) + 16 * j; \
                __m128i w = _mm_xor_si128(_mm_loadu_si128((const __m128i *)q), _mm_loadu_si128((const __m128i *)(mk + ii))); \
                D##ii = _mm_xor_si128(D##ii, _mm_clmulepi64_si128(w, w, 0x10)); S = _mm_xor_si128(S, w); }
            switch (nr[m]) {
            case 8: XK_ROW(7) /* fall through */ case 7: XK_ROW(6) /* fall through */ case 6: XK_ROW(5) /* fall through */
            case 5: XK_ROW(4) /* fall through */ case 4: XK_ROW(3) /* fall through */ case 3: XK_ROW(2) /* fall through */
            case 2: XK_ROW(1) /* fall through */ default: XK_ROW(0) }
#undef XK_ROW
            P = _mm_xor_si128(P, _mm_clmulepi64_si128(S, S, 0x10));
        }
    }
    return (mhi == 0 && nr[0] <= 4) ? ch128p_128_fin4(D0, D1, D2, D3, P) : ch128p_128_fin(D0, D1, D2, D3, D4, D5, D6, D7, P);
}
/* same block computation, raw accumulators out (for the two-block ymm fin) */
CH128_T128 static inline void ch128p_x_tblockD(const ch128p_key *k, const uint8_t *p, const uint8_t *pad, unsigned full_rows, unsigned mhi, const unsigned *nr, unsigned j, __m128i *o) {
    __m128i D0 = _mm_setzero_si128(), D1 = D0, D2 = D0, D3 = D0, D4 = D0, D5 = D0, D6 = D0, D7 = D0, P = D0; unsigned m;
    CH128P_NOUNROLL
    for (m = 0; m <= mhi; m++) {
        if (8 * m + 8 <= full_rows) {
            __asm__(CH128P_XSTEP : "+x"(D0), "+x"(D1), "+x"(D2), "+x"(D3), "+x"(D4), "+x"(D5), "+x"(D6), "+x"(D7), "+x"(P)
                    : "r"(p + 16 * j + CH128P_PV * (size_t)m), "r"(k->mask + 8 * m), "i"(CH128P_ROW) : "xmm12", "xmm13", "xmm14", "xmm15", "memory");
        } else {
            __m128i S = _mm_loadu_si128((const __m128i *)CH128P_SMP(k, m, nr[m])); const ch128_word *mk = k->mask + 8 * m;
#define XK_ROW(ii) { unsigned a_ = 8 * m + ii; const uint8_t *q = (a_ < full_rows ? p + CH128P_ROW * (size_t)a_ : pad) + 16 * j; \
                __m128i w = _mm_xor_si128(_mm_loadu_si128((const __m128i *)q), _mm_loadu_si128((const __m128i *)(mk + ii))); \
                D##ii = _mm_xor_si128(D##ii, _mm_clmulepi64_si128(w, w, 0x10)); S = _mm_xor_si128(S, w); }
            switch (nr[m]) {
            case 8: XK_ROW(7) /* fall through */ case 7: XK_ROW(6) /* fall through */ case 6: XK_ROW(5) /* fall through */
            case 5: XK_ROW(4) /* fall through */ case 4: XK_ROW(3) /* fall through */ case 3: XK_ROW(2) /* fall through */
            case 2: XK_ROW(1) /* fall through */ default: XK_ROW(0) }
#undef XK_ROW
            P = _mm_xor_si128(P, _mm_clmulepi64_si128(S, S, 0x10));
        }
    }
    _mm_storeu_si128(o + 0, D0); _mm_storeu_si128(o + 1, D1); _mm_storeu_si128(o + 2, D2); _mm_storeu_si128(o + 3, D3);
    _mm_storeu_si128(o + 4, D4); _mm_storeu_si128(o + 5, D5); _mm_storeu_si128(o + 6, D6); _mm_storeu_si128(o + 7, D7); _mm_storeu_si128(o + 8, P);
}
/* partial region, two blocks per ymm fin: block j's accumulators in the low lanes, j+1's in the high
 * lanes (inserted from the stack: a p015 blend, not a p5 shuffle); absent j+1 gets power 0 (yr pad). */
CH128P_T256X static __attribute__((noinline)) ch128_word ch128p_x_region2(const ch128p_key *k, const uint8_t *p, size_t r, ch128_word v) {
    unsigned full_rows = (unsigned)(r / CH128P_ROW), count = (unsigned)((r + 15) / 16 < CH128P_J ? (r + 15) / 16 : CH128P_J), mhi = (unsigned)((r - 1) / CH128P_PV), j, m;
    unsigned nr[CH128P_M]; ch128_word kdsum = ch128_make(0, 0); ch128_128_acc a; __m256i kds, kzv; __m128i A[9], B[9];
    const __m256i z = _mm256_setzero_si256();
    uint8_t pad[128] __attribute__((aligned(16)));
    if (r % CH128P_ROW) { unsigned x; for (x = 0; x < CH128P_ROW; x += 16) _mm_store_si128((__m128i *)(pad + x), ch128p_x_word(p, CH128P_ROW * (size_t)full_rows + x, r)); }   /* partial row from in-place words, whole 16-byte stores: every later 16-byte load forwards */

    for (m = 0; m <= mhi; m++) { unsigned d = (unsigned)((r + CH128P_ROW - 1) / CH128P_ROW) - 8 * m; nr[m] = d > 8 ? 8 : d; kdsum = ch128_xor(kdsum, *CH128P_KDP(k, m, nr[m])); }
    kds = _mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i *)&kdsum)); kzv = _mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i *)&k->kz[mhi]));
    a = ch128_128_accum(ch128_128_azero(), ch128_128_load(&v), ch128_128_load(k->outer.yp + count), 1);
    for (j = 0; j < count; j += 2) {
        __m256i b;
        ch128p_x_tblockD(k, p, pad, full_rows, mhi, nr, j, A);
        if (j + 1 < count) ch128p_x_tblockD(k, p, pad, full_rows, mhi, nr, j + 1, B); else { unsigned i; for (i = 0; i < 9; i++) B[i] = _mm_setzero_si128(); }
#define XK_Y(i) _mm256_inserti128_si256(_mm256_castsi128_si256(_mm_loadu_si128(A + i)), _mm_loadu_si128(B + i), 1)
        b = (mhi == 0 && nr[0] <= 4) ? ch128p_256_fin4(XK_Y(0), XK_Y(1), XK_Y(2), XK_Y(3), XK_Y(8))
                                     : ch128p_256_fin(XK_Y(0), XK_Y(1), XK_Y(2), XK_Y(3), XK_Y(4), XK_Y(5), XK_Y(6), XK_Y(7), XK_Y(8));
#undef XK_Y
        b = _mm256_xor_si256(b, kds);
        if (mhi) {
            if (CH128P_PV * (size_t)mhi + 16 * j >= r) b = _mm256_xor_si256(b, _mm256_blend_epi32(z, kzv, 0x0f));
            if (CH128P_PV * (size_t)mhi + 16 * (j + 1) >= r) b = _mm256_xor_si256(b, _mm256_blend_epi32(z, kzv, 0xf0));
        }
        a = ch128_128_accum(a, _mm256_castsi256_si128(b), ch128_128_load(k->yr + 8 - count + j), 1);
        a = ch128_128_accum(a, _mm256_extracti128_si256(b, 1), ch128_128_load(k->yr + 9 - count + j), 1);
    }
    ch128_128_store(&v, ch128_128_reduce(ch128_128_pack(a, 1))); return v;
}
CH128_T128 static __attribute__((noinline)) ch128_word ch128p_x_region(const ch128p_key *k, const uint8_t *p, size_t r, ch128_word v) {
    unsigned full_rows = (unsigned)(r / CH128P_ROW), count = (unsigned)((r + 15) / 16 < CH128P_J ? (r + 15) / 16 : CH128P_J), mhi = (unsigned)((r - 1) / CH128P_PV), j, m;
    unsigned nr[CH128P_M]; ch128_word kdsum = ch128_make(0, 0); ch128_128_acc a; __m128i kds, kzv;
    uint8_t pad[128] __attribute__((aligned(16)));
    if (r % CH128P_ROW) { unsigned x; for (x = 0; x < CH128P_ROW; x += 16) _mm_store_si128((__m128i *)(pad + x), ch128p_x_word(p, CH128P_ROW * (size_t)full_rows + x, r)); }   /* partial row from in-place words, whole 16-byte stores: every later 16-byte load forwards */

    for (m = 0; m <= mhi; m++) { unsigned d = (unsigned)((r + CH128P_ROW - 1) / CH128P_ROW) - 8 * m; nr[m] = d > 8 ? 8 : d; kdsum = ch128_xor(kdsum, *CH128P_KDP(k, m, nr[m])); }
    kds = _mm_loadu_si128((const __m128i *)&kdsum); kzv = _mm_loadu_si128((const __m128i *)&k->kz[mhi]);
    a = ch128_128_accum(ch128_128_azero(), ch128_128_load(&v), ch128_128_load(k->outer.yp + count), 1);
    for (j = 0; j < count; j++) {
        __m128i b = _mm_xor_si128(ch128p_x_tblock(k, p, pad, full_rows, mhi, nr, j), kds);
        if (mhi && CH128P_PV * (size_t)mhi + 16 * j >= r) b = _mm_xor_si128(b, kzv);
        a = ch128_128_accum(a, b, ch128_128_load(k->yr + 8 - count + j), 1);
    }
    ch128_128_store(&v, ch128_128_reduce(ch128_128_pack(a, 1))); return v;
}
/* CPU vendor for the tail dispatch: on Zen (AMD) the AVX2 two-blocks-per-ymm region kernel's lane
 * extracts/inserts are cheap and it wins every tail length; on Intel they compete with PCLMUL for port 5. */
static inline int ch128p_x_amd(void) {
    static int cache = -1; int v = __atomic_load_n(&cache, __ATOMIC_RELAXED);
    if (v < 0) { unsigned r[4]; ch128p_cpuid(0, 0, r); v = r[1] == 0x68747541u && r[3] == 0x69746e65u && r[2] == 0x444d4163u; __atomic_store_n(&cache, v, __ATOMIC_RELAXED); }
    return v;
}
/* PCLMUL-only backend: full regions through the asm-step bulk, the tail by CPU: without AVX2 one block
 * per xmm; with AVX2 on AMD the two-blocks-per-ymm region kernel for every tail (its lane moves are cheap
 * on Zen); on Intel that kernel up to 1 KiB and the asm-step region2 above (PCLMUL shares port 5 there). */
static inline ch128_word ch128p_x_poly(const ch128p_key *k, const uint8_t *p, size_t n, ch128_word v) {
    size_t full = n / CH128P_REGION, r = n % CH128P_REGION;
    if (full) { v = ch128p_x_bulk(k, p, full, v); p += full * CH128P_REGION; }
    if (r) {
        if (!ch128p_has_avx2()) v = ch128p_x_region(k, p, r, v);
        else if (ch128p_x_amd() || r <= 1024) v = ch128p_256_region(k, p, r, v);
        else v = ch128p_x_region2(k, p, r, v);
    }
    return v;
}
/* ---- compatibility for headers built on v1's XMM helpers (CH-128/P-2L): fullblock = the round-4 asm
 * step; v1's partial-region block (xgeo/tblock) restored as is. Unused by CH-128/P's own dispatch. ---- */
CH128_T128 static inline __attribute__((unused)) __m128i ch128p_128_fullblock(const ch128p_key *k, const uint8_t *p, unsigned j) { return ch128p_x_fullblock(k, p, j, 0); }
typedef struct { const uint8_t *p, *pad; unsigned full_rows, mhi, nr[CH128P_M]; } ch128p_xgeo;
CH128_T128 static inline __attribute__((always_inline, unused)) __m128i ch128p_128_tblock(const ch128p_key *k, const ch128p_xgeo *g, unsigned j) {
    __m128i z = _mm_setzero_si128(), D0 = z, D1 = z, D2 = z, D3 = z, D4 = z, D5 = z, D6 = z, D7 = z, P = z; unsigned m;
    const uint8_t *p = g->p, *pad = g->pad; unsigned full_rows = g->full_rows;
    CH128P_NOUNROLL
    for (m = 0; m <= g->mhi; m++) {
        __m128i S = _mm_loadu_si128((const __m128i *)CH128P_SMP(k, m, g->nr[m])); const ch128_word *mk = k->mask + 8 * m;
#define CH128P_XROW(ii, row) { __m128i w = _mm_xor_si128(_mm_loadu_si128((const __m128i *)((row) + 16 * j)), _mm_loadu_si128((const __m128i *)(mk + ii))); \
            D##ii = _mm_xor_si128(D##ii, _mm_clmulepi64_si128(w, w, 0x10)); S = _mm_xor_si128(S, w); }
#define CH128P_XROWC(ii) { unsigned a_ = 8 * m + ii; CH128P_XROW(ii, (a_ < full_rows ? p + CH128P_ROW * (size_t)a_ : pad)) }
        switch (g->nr[m]) {
        case 8: CH128P_XROWC(7) /* fall through */ case 7: CH128P_XROWC(6) /* fall through */ case 6: CH128P_XROWC(5) /* fall through */
        case 5: CH128P_XROWC(4) /* fall through */ case 4: CH128P_XROWC(3) /* fall through */ case 3: CH128P_XROWC(2) /* fall through */
        case 2: CH128P_XROWC(1) /* fall through */ default: CH128P_XROWC(0) }
#undef CH128P_XROWC
#undef CH128P_XROW
        P = _mm_xor_si128(P, _mm_clmulepi64_si128(S, S, 0x10));
    }
    return (g->mhi == 0 && g->nr[0] <= 4) ? ch128p_128_fin4(D0, D1, D2, D3, P) : ch128p_128_fin(D0, D1, D2, D3, D4, D5, D6, D7, P);
}
/* ---- 512-bit (VPCLMULQDQ, 4 blocks per zmm lane group) ---- */
CH128P_T512 static inline __m512i ch128p_512_sl1(__m512i v) { return _mm512_or_si512(_mm512_slli_epi64(v, 1), _mm512_srli_epi64(_mm512_bslli_epi128(v, 8), 63)); }
CH128P_T512 static inline __m512i ch128p_512_fin(__m512i D0, __m512i D1, __m512i D2, __m512i D3, __m512i D4, __m512i D5, __m512i D6, __m512i D7, __m512i P) {
    const __m512i tab = _mm512_broadcast_i32x4(_mm_setr_epi8(0x00,0x1b,0x2d,0x36,0x5a,0x41,0x77,0x6c,(char)0xaf,(char)0xb4,(char)0x82,(char)0x99,(char)0xf5,(char)0xee,(char)0xd8,(char)0xc3));
    const __m512i ce = _mm512_broadcast_i32x4(_mm_set_epi64x(0x1b, 0));
    __m512i t37 = _mm512_xor_si512(D3, D7), t56 = _mm512_xor_si512(D5, D6);
    __m512i B0 = _mm512_ternarylogic_epi64(D1, D5, t37, 0x96);
    __m512i B1 = _mm512_ternarylogic_epi64(_mm512_xor_si512(D2, D6), t37, P, 0x96);
    __m512i B2 = _mm512_ternarylogic_epi64(D4, D7, t56, 0x96);
    __m512i r0 = _mm512_ternarylogic_epi64(_mm512_ternarylogic_epi64(D0, D1, D2, 0x96), D4, _mm512_xor_si512(t37, t56), 0x96);
    __m512i T = _mm512_xor_si512(B1, ch128p_512_sl1(B2));
    __m512i r1 = _mm512_xor_si512(B0, ch128p_512_sl1(T));
    __m512i L = _mm512_unpacklo_epi64(r0, r1), H = _mm512_unpackhi_epi64(r0, r1);
    H = _mm512_ternarylogic_epi64(H, _mm512_srai_epi64(T, 63), ce, 0x78);   /* H ^ (a & c) */
    { __m512i f = _mm512_ternarylogic_epi64(H, _mm512_slli_epi64(H, 1), _mm512_slli_epi64(H, 3), 0x96);
      f = _mm512_ternarylogic_epi64(f, _mm512_slli_epi64(H, 4), _mm512_shuffle_epi8(tab, _mm512_srli_epi64(H, 60)), 0x96);
      return _mm512_xor_si512(L, f); }
}
/* Both lane groups of a full region in one sequential pass (rows a: lanes 0-3 at
 * +128a, lanes 4-7 at +128a+64); one pair-vector at a time, rows summed in pairs
 * with ternlog. Keeps <=28 zmm live so gcc and clang both allocate without spills. */
#define CH128P_BC(a) _mm512_broadcast_i32x4(_mm_loadu_si128((const __m128i *)&mk[a]))
/* fin when roles 4..7 carry no data: B2 = 0, raw1 = B0 ^ X*B1 fits 128 bits */
CH128P_T512 static inline __m512i ch128p_512_fin4(__m512i D0, __m512i D1, __m512i D2, __m512i D3, __m512i P) {
    const __m512i tab = _mm512_broadcast_i32x4(_mm_setr_epi8(0x00,0x1b,0x2d,0x36,0x5a,0x41,0x77,0x6c,(char)0xaf,(char)0xb4,(char)0x82,(char)0x99,(char)0xf5,(char)0xee,(char)0xd8,(char)0xc3));
    __m512i r0 = _mm512_ternarylogic_epi64(_mm512_xor_si512(D0, D1), D2, D3, 0x96);
    __m512i r1 = _mm512_ternarylogic_epi64(D1, D3, ch128p_512_sl1(_mm512_ternarylogic_epi64(D2, D3, P, 0x96)), 0x96);
    __m512i L = _mm512_unpacklo_epi64(r0, r1), H = _mm512_unpackhi_epi64(r0, r1);
    __m512i f = _mm512_ternarylogic_epi64(H, _mm512_slli_epi64(H, 1), _mm512_slli_epi64(H, 3), 0x96);
    f = _mm512_ternarylogic_epi64(f, _mm512_slli_epi64(H, 4), _mm512_shuffle_epi8(tab, _mm512_srli_epi64(H, 60)), 0x96);
    return _mm512_xor_si512(L, f);
}
CH128P_T512 static inline __m128i ch128p_512_fold(__m512i z) {
    __m256i t = _mm256_xor_si256(_mm512_castsi512_si256(z), _mm512_extracti64x4_epi64(z, 1));
    return _mm_xor_si128(_mm256_castsi256_si128(t), _mm256_extracti128_si256(t, 1));
}
#define CH128P_ZB 64                   /* lane group B = blocks 4..7 of the same region */
#define CH128P_ZSTEP CH128P_REGION
/* Round 4: pair-vectors (m, m+1) per step; the two products of a role (and the two parity
 * products) are accumulated with one ternlog (0.5 op per product instead of 1). The step is
 * inline asm per role pair so gcc and clang emit the same code with fixed temporaries
 * (zmm22-31) and no spills; displacements are baked in for M = 16 (J = 8: rows +128, lane
 * group B +64, pair-vector +1024; J = 4: rows +64, group B = next region +8192, +512). */
#if defined(__GNUC__) && CH128P_M == 16 && !defined(CH128P_NO_ASM)
#define CH128P_MKLD_BC(e, r) "vbroadcasti32x4 " #e "*16(%9), %%zmm" #r "\n\t"   /* frozen: 16-byte masks, lane broadcast */
#define CH128P_MKLD_PB(e, r) "vmovdqu64 " #e "*64(%9), %%zmm" #r "\n\t"         /* CHAINHASH128V2_PREBC: 64-byte pre-broadcast masks, plain load */
#define CH128P_ASM_RP8 CH128P_ASM_RP8_(CH128P_MKLD_BC)
#define CH128P_ASM_RP8PB CH128P_ASM_RP8_(CH128P_MKLD_PB)
#define CH128P_ASM_RP8_(L) \
  L(0, 22) L(1, 23) L(8, 24) L(9, 25) \
  "vpxorq 0(%8), %%zmm22, %%zmm26\n\t" \
  "vpxorq 128(%8), %%zmm23, %%zmm27\n\t" \
  "vpclmulqdq $0x10, %%zmm26, %%zmm26, %%zmm28\n\t" \
  "vpclmulqdq $0x10, %%zmm27, %%zmm27, %%zmm29\n\t" \
  "vpternlogq $0x96, %%zmm27, %%zmm26, %4\n\t" \
  "vpxorq 1024(%8), %%zmm24, %%zmm26\n\t" \
  "vpxorq 1152(%8), %%zmm25, %%zmm27\n\t" \
  "vpclmulqdq $0x10, %%zmm26, %%zmm26, %%zmm30\n\t" \
  "vpclmulqdq $0x10, %%zmm27, %%zmm27, %%zmm31\n\t" \
  "vpternlogq $0x96, %%zmm27, %%zmm26, %5\n\t" \
  "vpternlogq $0x96, %%zmm30, %%zmm28, %0\n\t" \
  "vpternlogq $0x96, %%zmm31, %%zmm29, %1\n\t" \
  "vpxorq 64(%8), %%zmm22, %%zmm26\n\t" \
  "vpxorq 192(%8), %%zmm23, %%zmm27\n\t" \
  "vpclmulqdq $0x10, %%zmm26, %%zmm26, %%zmm28\n\t" \
  "vpclmulqdq $0x10, %%zmm27, %%zmm27, %%zmm29\n\t" \
  "vpternlogq $0x96, %%zmm27, %%zmm26, %6\n\t" \
  "vpxorq 1088(%8), %%zmm24, %%zmm26\n\t" \
  "vpxorq 1216(%8), %%zmm25, %%zmm27\n\t" \
  "vpclmulqdq $0x10, %%zmm26, %%zmm26, %%zmm30\n\t" \
  "vpclmulqdq $0x10, %%zmm27, %%zmm27, %%zmm31\n\t" \
  "vpternlogq $0x96, %%zmm27, %%zmm26, %7\n\t" \
  "vpternlogq $0x96, %%zmm30, %%zmm28, %2\n\t" \
  "vpternlogq $0x96, %%zmm31, %%zmm29, %3\n\t" \
  ""
#define CH128P_ASM_RP4 \
  "vbroadcasti32x4 0(%9), %%zmm22\n\t" \
  "vbroadcasti32x4 16(%9), %%zmm23\n\t" \
  "vbroadcasti32x4 128(%9), %%zmm24\n\t" \
  "vbroadcasti32x4 144(%9), %%zmm25\n\t" \
  "vpxorq 0(%8), %%zmm22, %%zmm26\n\t" \
  "vpxorq 64(%8), %%zmm23, %%zmm27\n\t" \
  "vpclmulqdq $0x10, %%zmm26, %%zmm26, %%zmm28\n\t" \
  "vpclmulqdq $0x10, %%zmm27, %%zmm27, %%zmm29\n\t" \
  "vpternlogq $0x96, %%zmm27, %%zmm26, %4\n\t" \
  "vpxorq 512(%8), %%zmm24, %%zmm26\n\t" \
  "vpxorq 576(%8), %%zmm25, %%zmm27\n\t" \
  "vpclmulqdq $0x10, %%zmm26, %%zmm26, %%zmm30\n\t" \
  "vpclmulqdq $0x10, %%zmm27, %%zmm27, %%zmm31\n\t" \
  "vpternlogq $0x96, %%zmm27, %%zmm26, %5\n\t" \
  "vpternlogq $0x96, %%zmm30, %%zmm28, %0\n\t" \
  "vpternlogq $0x96, %%zmm31, %%zmm29, %1\n\t" \
  "vpxorq 8192(%8), %%zmm22, %%zmm26\n\t" \
  "vpxorq 8256(%8), %%zmm23, %%zmm27\n\t" \
  "vpclmulqdq $0x10, %%zmm26, %%zmm26, %%zmm28\n\t" \
  "vpclmulqdq $0x10, %%zmm27, %%zmm27, %%zmm29\n\t" \
  "vpternlogq $0x96, %%zmm27, %%zmm26, %6\n\t" \
  "vpxorq 8704(%8), %%zmm24, %%zmm26\n\t" \
  "vpxorq 8768(%8), %%zmm25, %%zmm27\n\t" \
  "vpclmulqdq $0x10, %%zmm26, %%zmm26, %%zmm30\n\t" \
  "vpclmulqdq $0x10, %%zmm27, %%zmm27, %%zmm31\n\t" \
  "vpternlogq $0x96, %%zmm27, %%zmm26, %7\n\t" \
  "vpternlogq $0x96, %%zmm30, %%zmm28, %2\n\t" \
  "vpternlogq $0x96, %%zmm31, %%zmm29, %3\n\t" \
  ""
#define CH128P_ASM_RP CH128P_ASM_RP8
/* mask-load form as a compile-time argument (pbc = 0: frozen 16-byte broadcasts; 1: 64-byte pre-broadcast table) */
#define CH128P_CORE_T 1
CH128P_T512 static inline __attribute__((always_inline)) void ch128p_512_core_t(const ch128_word *mk, const uint8_t *q, __m512i DA[8], __m512i DB[8], __m512i *PA, __m512i *PB, const int pbc) {
    unsigned m, i; __m512i pa = _mm512_setzero_si512(), pb = pa; const unsigned mks = pbc ? 4 : 1;
    for (i = 0; i < 8; i++) DA[i] = DB[i] = pa;
    for (m = 0; m < CH128P_M; m += 2) {
        const uint8_t *r = q + CH128P_PV * m; const ch128_word *mq = mk + 8 * mks * m; __m512i SA = _mm512_setzero_si512(), SB = SA, SC = SA, SE = SA;
        for (i = 0; i < 8; i += 2) {
            if (pbc) __asm__(CH128P_ASM_RP8PB : "+v"(DA[i]), "+v"(DA[i + 1]), "+v"(DB[i]), "+v"(DB[i + 1]), "+v"(SA), "+v"(SC), "+v"(SB), "+v"(SE)
                    : "r"(r + CH128P_ROW * i), "r"(mq + mks * i) : "xmm22", "xmm23", "xmm24", "xmm25", "xmm26", "xmm27", "xmm28", "xmm29", "xmm30", "xmm31", "memory");
            else __asm__(CH128P_ASM_RP : "+v"(DA[i]), "+v"(DA[i + 1]), "+v"(DB[i]), "+v"(DB[i + 1]), "+v"(SA), "+v"(SC), "+v"(SB), "+v"(SE)
                    : "r"(r + CH128P_ROW * i), "r"(mq + mks * i) : "xmm22", "xmm23", "xmm24", "xmm25", "xmm26", "xmm27", "xmm28", "xmm29", "xmm30", "xmm31", "memory");
        }
        pa = _mm512_ternarylogic_epi64(pa, _mm512_clmulepi64_epi128(SA, SA, 0x10), _mm512_clmulepi64_epi128(SC, SC, 0x10), 0x96);
        pb = _mm512_ternarylogic_epi64(pb, _mm512_clmulepi64_epi128(SB, SB, 0x10), _mm512_clmulepi64_epi128(SE, SE, 0x10), 0x96);
    }
    *PA = pa; *PB = pb;
}
CH128P_T512 static inline __attribute__((always_inline)) void ch128p_512_core(const ch128_word *mk, const uint8_t *q, __m512i DA[8], __m512i DB[8], __m512i *PA, __m512i *PB) { ch128p_512_core_t(mk, q, DA, DB, PA, PB, 0); }
#else
CH128P_T512 static inline __attribute__((always_inline)) void ch128p_512_core(const ch128_word *mk, const uint8_t *q, __m512i DA[8], __m512i DB[8], __m512i *PA, __m512i *PB) {
    unsigned m, i;
    for (m = 0; m < CH128P_M; m++) {
        const uint8_t *r = q + CH128P_PV * m; __m512i SA = _mm512_setzero_si512(), SB = _mm512_setzero_si512();
        for (i = 0; i < 8; i += 2) {
            __m512i k0 = CH128P_BC(8 * m + i), k1 = CH128P_BC(8 * m + i + 1);
            __m512i a0 = _mm512_xor_si512(_mm512_loadu_si512(r + CH128P_ROW * i), k0), b0 = _mm512_xor_si512(_mm512_loadu_si512(r + CH128P_ROW * i + CH128P_ZB), k0);
            __m512i a1 = _mm512_xor_si512(_mm512_loadu_si512(r + CH128P_ROW * i + CH128P_ROW), k1), b1 = _mm512_xor_si512(_mm512_loadu_si512(r + CH128P_ROW * i + CH128P_ROW + CH128P_ZB), k1);
            SA = _mm512_ternarylogic_epi64(SA, a0, a1, 0x96); SB = _mm512_ternarylogic_epi64(SB, b0, b1, 0x96);
            if (m == 0) { DA[i] = _mm512_clmulepi64_epi128(a0, a0, 0x10); DB[i] = _mm512_clmulepi64_epi128(b0, b0, 0x10); DA[i + 1] = _mm512_clmulepi64_epi128(a1, a1, 0x10); DB[i + 1] = _mm512_clmulepi64_epi128(b1, b1, 0x10); }
            else { DA[i] = _mm512_xor_si512(DA[i], _mm512_clmulepi64_epi128(a0, a0, 0x10)); DB[i] = _mm512_xor_si512(DB[i], _mm512_clmulepi64_epi128(b0, b0, 0x10));
                   DA[i + 1] = _mm512_xor_si512(DA[i + 1], _mm512_clmulepi64_epi128(a1, a1, 0x10)); DB[i + 1] = _mm512_xor_si512(DB[i + 1], _mm512_clmulepi64_epi128(b1, b1, 0x10)); }
        }
        if (m == 0) { *PA = _mm512_clmulepi64_epi128(SA, SA, 0x10); *PB = _mm512_clmulepi64_epi128(SB, SB, 0x10); }
        else { *PA = _mm512_xor_si512(*PA, _mm512_clmulepi64_epi128(SA, SA, 0x10)); *PB = _mm512_xor_si512(*PB, _mm512_clmulepi64_epi128(SB, SB, 0x10)); }
    }
}
#endif
/* 1..128 bytes: only row 0 carries data (block j = word j of pair-vector 0). Per block:
 * D = u0 v0, parity P = (sum u)(sum v) with sum over masked words = w ^ sm[0][1];
 * raw0 = D, raw1 = X*P (alpha_0 = 0), plus the zero-row constant kd[0][1]. */
CH128P_T512 static inline __m512i ch128p_512_sfin(__m512i w, __m512i S1, __m512i KD) {
    const __m512i tab = _mm512_broadcast_i32x4(_mm_setr_epi8(0x00,0x1b,0x2d,0x36,0x5a,0x41,0x77,0x6c,(char)0xaf,(char)0xb4,(char)0x82,(char)0x99,(char)0xf5,(char)0xee,(char)0xd8,(char)0xc3));
    __m512i S = _mm512_xor_si512(w, S1), D = _mm512_clmulepi64_epi128(w, w, 0x10), r1 = ch128p_512_sl1(_mm512_clmulepi64_epi128(S, S, 0x10));
    __m512i L = _mm512_unpacklo_epi64(D, r1), H = _mm512_unpackhi_epi64(D, r1);
    __m512i f = _mm512_ternarylogic_epi64(H, _mm512_slli_epi64(H, 1), _mm512_slli_epi64(H, 3), 0x96);
    f = _mm512_ternarylogic_epi64(f, _mm512_slli_epi64(H, 4), _mm512_shuffle_epi8(tab, _mm512_srli_epi64(H, 60)), 0x96);
    return _mm512_ternarylogic_epi64(L, f, KD, 0x96);
}
#endif /* CH128_X86 */

/* ================================ NEON ================================ */
#ifdef CH128_ARM
CH128_NBEGIN   /* chainhash 2c61966: NEON code under target("aes")/("+crypto") unless the build guarantees PMULL */
/* v2.2: as ch128p_128_finish. On NEON the reduction's carry-out is folded by a third product (a chain of
 * eight dependent shifts and XORs is slower), the twist stays in a register, and z*c3 enters beside R.lo. */
static inline uint64x2_t ch128p_n_redh(uint64x2_t hi, uint64x2_t *e) {
    const uint64x2_t r = vdupq_n_u64(0x87); uint64x2_t b = ch128_n_hh(hi, r);
    *e = ch128_n_hh(b, r);
    return veorq_u64(ch128_n_ll(hi, r), vextq_u64(vdupq_n_u64(0), b, 1));
}
static inline uint64x2_t ch128p_n_redc(ch128_n_raw p, uint64x2_t c) {
    uint64x2_t e, h = ch128p_n_redh(p.hi, &e); return veorq_u64(veorq_u64(p.lo, veorq_u64(c, e)), h);
}
static inline ch128_word ch128p_n_finish(const ch128p_outer *k, uint64x2_t vv) {   /* = ch128_n_finish */
    uint64x2_t t = ch128_n_load(&k->tau), s = vaddq_u64(vv, t), x = vsubq_u64(s, vextq_u64(vdupq_n_u64(0), vcltq_u64(s, t), 1)), e, H, a, b, z, w;
    ch128_n_raw Q, R, zr; ch128_n_acc A; ch128_word o;
    Q.lo = ch128_n_ll(x, x); Q.hi = ch128_n_hh(x, x); H = ch128p_n_redh(Q.hi, &e);
    a = veorq_u64(veorq_u64(Q.lo, veorq_u64(e, ch128_n_load(k->c))), H);
    b = veorq_u64(veorq_u64(Q.lo, veorq_u64(e, veorq_u64(x, ch128_n_load(k->c + 1)))), H);
    z = veorq_u64(x, ch128_n_load(k->c + 2)); zr.lo = vdupq_n_u64(0); zr.hi = z; w = ch128p_n_redc(zr, vdupq_n_u64(0));
    R = ch128_n_prod(a, b, 1);
    A = ch128_n_accum(ch128_n_accum(ch128_n_azero(), z, veorq_u64(R.lo, ch128_n_load(k->c + 3)), 1), w, R.hi, 1);
    vv = ch128p_n_redc(ch128_n_pack(A, 1), ch128_n_load(k->c + 4)); o.lo = vgetq_lane_u64(vv, 0); o.hi = vgetq_lane_u64(vv, 1); return o;
}
static inline uint64x2_t ch128p_n_sl1(uint64x2_t v) { return vorrq_u64(vshlq_n_u64(v, 1), vshrq_n_u64(vextq_u64(vdupq_n_u64(0), v, 1), 63)); }
static inline uint64x2_t ch128p_n_fin(uint64x2_t D0, uint64x2_t D1, uint64x2_t D2, uint64x2_t D3, uint64x2_t D4, uint64x2_t D5, uint64x2_t D6, uint64x2_t D7, uint64x2_t P) {
    static const uint8_t tabb[16] = {0x00,0x1b,0x2d,0x36,0x5a,0x41,0x77,0x6c,0xaf,0xb4,0x82,0x99,0xf5,0xee,0xd8,0xc3};
    const uint8x16_t tab = vld1q_u8(tabb);
    const uint64x2_t ce = vcombine_u64(vcreate_u64(0), vcreate_u64(0x1b));
    uint64x2_t t37 = veorq_u64(D3, D7), t56 = veorq_u64(D5, D6);
    uint64x2_t B0 = veorq_u64(veorq_u64(D1, D5), t37);
    uint64x2_t B1 = veorq_u64(veorq_u64(D2, D6), veorq_u64(t37, P));
    uint64x2_t B2 = veorq_u64(veorq_u64(D4, D7), t56);
    uint64x2_t r0 = veorq_u64(veorq_u64(veorq_u64(D0, D1), veorq_u64(D2, D4)), veorq_u64(t37, t56));
    uint64x2_t T = veorq_u64(B1, ch128p_n_sl1(B2));
    uint64x2_t r1 = veorq_u64(B0, ch128p_n_sl1(T));
    uint64x2_t L = vzip1q_u64(r0, r1), H = vzip2q_u64(r0, r1), f;
    H = veorq_u64(H, vandq_u64(vreinterpretq_u64_s64(vshrq_n_s64(vreinterpretq_s64_u64(T), 63)), ce));
    f = veorq_u64(veorq_u64(H, vshlq_n_u64(H, 1)), veorq_u64(vshlq_n_u64(H, 3), vshlq_n_u64(H, 4)));
    f = veorq_u64(f, vreinterpretq_u64_u8(vqtbl1q_u8(tab, vreinterpretq_u8_u64(vshrq_n_u64(H, 60)))));
    return veorq_u64(L, f);
}
#if CH128_SHA3 == 1   /* EOR3 only when the target guarantees FEAT_SHA3 (and CHAINHASH128_NO_SHA3 is not set) */
#define CH128P_E3(a, b, c) veor3q_u64(a, b, c)
#else
#define CH128P_E3(a, b, c) veorq_u64(veorq_u64(a, b), c)
#endif
/* Two blocks (lanes j, j+1) at once. A = word of block j, B = word of block j+1 (same
 * row, same mask K). C = ext(A,B) = {v_j, u_j1}: pmull(A,C) = u_j v_j (block j) and
 * pmull2(C,B) = u_j1 v_j1 (block j+1): one EXT per two products, no LD2/LD2R. */
/* Round 4: pair-vectors (m, m+1) per step; role, parity-sum and parity accumulation by EOR3
 * (12% fewer SIMD ops; EOR3 issues at ~1.5 slots on the M2, net -5% time). Rows at +CH128P_ROW*i,
 * pair-vectors at +CH128P_PV*m, block j+1 at +16. */
/* Round 4: product-accumulate as a fused PMULL+EOR. Apple cores fuse "pmull Vd; eor Vd, Vd, Vacc"
 * (the EOR writes the PMULL's destination and reads it first): 1.04 issue slots per product-accumulate
 * instead of 1.9 (M2 Pro, measured). The accumulator therefore moves to a new register every step, so
 * the pair-vector loop is fully unrolled (a rolled loop would add a MOV per accumulate at the back edge).
 * On other AArch64 cores the pair is two ordinary instructions (same count as before). */
static inline uint64x2_t ch128p_n_fl(uint64x2_t acc, uint64x2_t a, uint64x2_t b) {   /* acc ^ a.lo*b.lo */
    uint64x2_t r; __asm__("pmull %0.1q, %1.1d, %2.1d\n\teor %0.16b, %0.16b, %3.16b" : "=&w"(r) : "w"(a), "w"(b), "w"(acc)); return r;
}
static inline uint64x2_t ch128p_n_fh(uint64x2_t acc, uint64x2_t a, uint64x2_t b) {   /* acc ^ a.hi*b.hi */
    uint64x2_t r; __asm__("pmull2 %0.1q, %1.2d, %2.2d\n\teor %0.16b, %0.16b, %3.16b" : "=&w"(r) : "w"(a), "w"(b), "w"(acc)); return r;
}
#if defined(__clang__)
#define CH128P_UNROLL_FULL _Pragma("clang loop unroll(full)")
#elif defined(__GNUC__)
#define CH128P_UNROLL_FULL _Pragma("GCC unroll 16")
#else
#define CH128P_UNROLL_FULL
#endif
/* Two blocks (lanes j, j+1) at once: A = word of block j, B = word of block j+1 (same row, mask K);
 * C = ext(A,B) = {v_j, u_j1}: pmull(A,C) = u_j v_j and pmull2(C,B) = u_j1 v_j1. Parity: x = ext(SA,SB)
 * gives both blocks' products (pmull(SA,x), pmull2(x,SB)). Rows +CH128P_ROW*i, pair-vectors +CH128P_PV*m. */
#if defined(CHAINHASH128V2_NPF)
#define CH128P_NPF(p, jp) ((uintptr_t)(p) + (regions > 1 ? (uintptr_t)CH128P_REGION : 0) + (uintptr_t)256 * CH128P_M * (jp))   /* next region, quarter jp (64 lines); the last region re-touches itself (branch-free) */
#else
#define CH128P_NPF(p, jp) ((uintptr_t)0)
#endif
static inline __attribute__((always_inline)) void ch128p_n_pair(const ch128_word *mk, const uint8_t *p, uint64x2_t A[8], uint64x2_t C[8], uint64x2_t *PA, uint64x2_t *PC, uintptr_t pfb) {
    unsigned m, i; uint64x2_t z = vdupq_n_u64(0), pa = z, pc = z;
    for (i = 0; i < 8; i++) A[i] = C[i] = z;
    CH128P_UNROLL_FULL
    for (m = 0; m < CH128P_M; m++) {
        const uint8_t *q = p + CH128P_PV * m; uint64x2_t SA = z, SB = z, x;
#if defined(CHAINHASH128V2_NPF)
        { uintptr_t pf = pfb + (uintptr_t)256 * m; __builtin_prefetch((const void *)pf, 0, 3); __builtin_prefetch((const void *)(pf + 64), 0, 3); __builtin_prefetch((const void *)(pf + 128), 0, 3); __builtin_prefetch((const void *)(pf + 192), 0, 3); }   /* next region, 4 lines per pv */
#else
        (void)pfb;
#endif
        for (i = 0; i < 8; i += 2) {
            uint64x2_t k0 = vld1q_u64((const uint64_t *)&mk[8 * m + i]), k1 = vld1q_u64((const uint64_t *)&mk[8 * m + i + 1]);
            uint64x2_t a0 = veorq_u64(vld1q_u64((const uint64_t *)(q + CH128P_ROW * i)), k0), b0 = veorq_u64(vld1q_u64((const uint64_t *)(q + CH128P_ROW * i + 16)), k0);
            uint64x2_t a1 = veorq_u64(vld1q_u64((const uint64_t *)(q + CH128P_ROW * (i + 1))), k1), b1 = veorq_u64(vld1q_u64((const uint64_t *)(q + CH128P_ROW * (i + 1) + 16)), k1);
            uint64x2_t c0 = vextq_u64(a0, b0, 1), c1 = vextq_u64(a1, b1, 1);
            A[i] = ch128p_n_fl(A[i], a0, c0); C[i] = ch128p_n_fh(C[i], c0, b0); A[i + 1] = ch128p_n_fl(A[i + 1], a1, c1); C[i + 1] = ch128p_n_fh(C[i + 1], c1, b1);
            SA = CH128P_E3(SA, a0, a1); SB = CH128P_E3(SB, b0, b1);
        }
        x = vextq_u64(SA, SB, 1); pa = ch128p_n_fl(pa, SA, x); pc = ch128p_n_fh(pc, x, SB);
    }
    *PA = pa; *PC = pc;
}
/* schoolbook accumulate of x*y for a constant y given with its swap ys = {y.hi, y.lo} */
typedef struct { uint64x2_t l, h, m; } ch128p_n_acc;
static inline __attribute__((always_inline)) void ch128p_n_mac(ch128p_n_acc *a, uint64x2_t x, uint64x2_t y, uint64x2_t ys) {
    a->l = ch128p_n_fl(a->l, x, y); a->h = ch128p_n_fh(a->h, x, y);
    a->m = ch128p_n_fh(ch128p_n_fl(a->m, x, ys), x, ys);
}
static inline ch128_n_raw ch128p_n_pack(ch128p_n_acc a) {
    ch128_n_raw r; r.lo = veorq_u64(a.l, ch128_n_left(a.m)); r.hi = veorq_u64(a.h, ch128_n_right(a.m)); return r;
}
/* fin when roles 4..7 carry no data (D4..D7 = 0): B2 = 0, raw1 = B0 ^ X*B1 fits 128 bits */
static inline uint64x2_t ch128p_n_fin4(uint64x2_t D0, uint64x2_t D1, uint64x2_t D2, uint64x2_t D3, uint64x2_t P) {
    static const uint8_t tabb[16] = {0x00,0x1b,0x2d,0x36,0x5a,0x41,0x77,0x6c,0xaf,0xb4,0x82,0x99,0xf5,0xee,0xd8,0xc3};
    uint64x2_t r0 = veorq_u64(CH128P_E3(D0, D1, D2), D3), r1 = veorq_u64(veorq_u64(D1, D3), ch128p_n_sl1(CH128P_E3(D2, D3, P)));
    uint64x2_t L = vzip1q_u64(r0, r1), H = vzip2q_u64(r0, r1), f;
    f = CH128P_E3(H, vshlq_n_u64(H, 1), vshlq_n_u64(H, 3));
    f = CH128P_E3(f, vshlq_n_u64(H, 4), vreinterpretq_u64_u8(vqtbl1q_u8(vld1q_u8(tabb), vreinterpretq_u8_u64(vshrq_n_u64(H, 60)))));
    return veorq_u64(L, f);
}
/* 1..128 bytes (see the x86 short path) */
static inline uint64x2_t ch128p_n_sfin(uint64x2_t D, uint64x2_t P, uint64x2_t KD) {
    static const uint8_t tabb[16] = {0x00,0x1b,0x2d,0x36,0x5a,0x41,0x77,0x6c,0xaf,0xb4,0x82,0x99,0xf5,0xee,0xd8,0xc3};
    uint64x2_t r1 = ch128p_n_sl1(P), L = vzip1q_u64(D, r1), H = vzip2q_u64(D, r1), f;
    f = CH128P_E3(H, vshlq_n_u64(H, 1), vshlq_n_u64(H, 3));
    f = CH128P_E3(f, vshlq_n_u64(H, 4), vreinterpretq_u64_u8(vqtbl1q_u8(vld1q_u8(tabb), vreinterpretq_u8_u64(vshrq_n_u64(H, 60)))));
    return CH128P_E3(L, f, KD);
}
static inline uint64x2_t ch128p_n_word8(const uint8_t *p, size_t n, size_t off) {   /* 16 bytes at off, zero past n */
    if (off + 16 <= n) return vld1q_u64((const uint64_t *)(p + off));
    if (off >= n) return vdupq_n_u64(0);
    { uint8_t t[16] = {0}; memcpy(t, p + off, n - off); return vld1q_u64((const uint64_t *)t); }
}
CH128_NEND
#endif /* CH128_ARM */


static inline ch128_word ch128p_finish(const ch128p_outer *k, ch128_word v, int b) {
#ifdef CH128_X86
    if (b) return ch128p_128_finish(k, ch128_128_load(&v));
#elif defined(CH128_ARM)
    if (b) return ch128p_n_finish(k, ch128_n_load(&v));
#endif
    return ch128p_finish_port(k, v, b);
}
/* ---------------- backends and one-shot ---------------- */
static inline int ch128p_backend(void) {
#ifdef CH128_X86
    static int cache = -1; int v = __atomic_load_n(&cache, __ATOMIC_RELAXED);
    if (v < 0) { v = ch128p_detect(); __atomic_store_n(&cache, v, __ATOMIC_RELAXED); } return v;
#elif defined(CH128_ARM)
    return chainhash128_backend() == CH128_NEON ? CH128P_NEON : CH128P_PORTABLE;   /* PMULL at run time */
#else
    return CH128P_PORTABLE;
#endif
}
static inline int ch128p_has_backend(int b) {
    int h = ch128p_backend(); return b == 0 || (h == 4 ? b == 4 : (b == 1 && h >= 1) || (b == 3 && h == 3));
}

/* ================= two-level outer (2L) ================= */
#define CH128P2L_KEY_BYTES 192
typedef struct {
    ch128p_key p;                 /* v1 expanded key (masks, tail constants, y powers, c0..c4, tau) */
    ch128_word z, zh, zs, zhs;    /* z, 0x87*z (folds the high half of the raw state), limb swaps (NEON) */
    ch128_word ym[8];             /* ym[e-1] = y^e: pair i (0-based) masks a_i with y^(2i+1), a_(h+i) with y^(2i+2) */
    ch128_word ylo[4], yhi[4];    /* ZMM lanes: (y^1, y^3, y^5, y^7) and (y^2, y^4, y^6, y^8) */
} ch128p2l_key;
#if defined(CHAINHASH128V2_PREBC) && defined(CH128_X86)
/* the 64-byte tables at multiples of 64 bytes from the start of the expanded key (chainhash128v2_key places it at a
 * 64-byte-aligned address) */
typedef char ch128p2l_key_layout_check[(offsetof(ch128p_key, mzb) % 64 == 0 && offsetof(ch128p2l_key, ylo) % 64 == 0 && offsetof(ch128p2l_key, yhi) % 64 == 0) ? 1 : -1];
#endif

static inline void ch128p2l_key_from_bytes(ch128p2l_key *k, const uint8_t key[CH128P2L_KEY_BYTES]) {
    unsigned i;
    ch128p_key_from_bytes(&k->p, key);
    k->z = ch128_load(key + 176);
    k->zh = CH128P_HAVE_HWCLMUL() ? ch128_mul(k->z, ch128_make(0x87, 0), 1) : ch128_mul_ref(k->z, ch128_make(0x87, 0));
    k->zs = ch128_make(k->z.hi, k->z.lo); k->zhs = ch128_make(k->zh.hi, k->zh.lo);
    for (i = 0; i < 8; i++) k->ym[i] = k->p.outer.yp[i + 1];
    for (i = 0; i < 4; i++) { k->ylo[i] = k->ym[2 * i]; k->yhi[i] = k->ym[2 * i + 1]; }
}
static inline void ch128p2l_key_from_seed(ch128p2l_key *k, uint64_t seed) {
    uint8_t p[CH128P2L_KEY_BYTES]; unsigned i, j;
    for (i = 0; i < CH128P2L_KEY_BYTES / 8; i++) {
        uint64_t z = (seed += UINT64_C(0x9e3779b97f4a7c15));
        z = (z ^ (z >> 30)) * UINT64_C(0xbf58476d1ce4e5b9); z = (z ^ (z >> 27)) * UINT64_C(0x94d049bb133111eb); z ^= z >> 31;
        for (j = 0; j < 8; j++) p[8 * i + j] = (uint8_t)(z >> (8 * j));
    }
    ch128p2l_key_from_bytes(k, p);
}

/* ---------------- oracle: the definition, literally (direct blocks, bit-serial field) ---------------- */
static inline ch128_word ch128p2l_c_ref(const ch128p2l_key *k, const ch128_word *a, unsigned q) {
    unsigned h = (q + 1) / 2, i; ch128_word c = ch128_make(0, 0), y = k->p.outer.yp[1], ye = y;
    for (i = 1; i <= q / 2; i++) {             /* ye = y^(2i-1) on entry */
        ch128_word yo = ye, yv = ch128_mul_ref(ye, y);
        c = ch128_xor(c, ch128_mul_ref(ch128_xor(a[i - 1], yo), ch128_xor(a[h + i - 1], yv)));
        ye = ch128_mul_ref(yv, y);
    }
    if (q & 1) c = ch128_xor(c, a[h - 1]);
    return c;
}
static inline ch128_word ch128p2l_ref(const ch128p2l_key *k, const void *data, size_t n) {
    const uint8_t *p = (const uint8_t *)data; uint64_t m = ch128p_blocks(n), t0; ch128_word V = ch128_make(n, 0), a[8];
    if (!n) return ch128p_finish_port(&k->p.outer, ch128_mul_ref(V, k->z), 0);   /* V = 0*z + b_1, b_1 = 0 */
    for (t0 = 0; t0 < m; t0 += 8) {
        unsigned q = (unsigned)(m - t0 < 8 ? m - t0 : 8), j;
        for (j = 0; j < q; j++) a[j] = ch128p_block_ref(&k->p, p, n, t0 + j);
        V = ch128_xor(ch128_mul_ref(V, k->z), ch128p2l_c_ref(k, a, q));
    }
    return ch128p_finish_port(&k->p.outer, V, 0);
}

/* ---------------- portable outer on a region's block values ---------------- */
static inline ch128_word ch128p2l_port_outer(const ch128p2l_key *k, ch128_word v, const ch128_word *bv, unsigned q) {
    unsigned h = (q + 1) / 2, f = q / 2, i;
#ifdef CH128P2L_XOROUTER
    (void)h; (void)f; for (i = 0; i < q; i++) v = ch128_xor(v, bv[i]); (void)k; return v;
#else
    v = ch128_mul(v, k->z, 0);
    for (i = 0; i < f; i++) v = ch128_xor(v, ch128_mul(ch128_xor(bv[i], k->ym[2 * i]), ch128_xor(bv[h + i], k->ym[2 * i + 1]), 0));
    if (q & 1) v = ch128_xor(v, bv[h - 1]);
    return v;
#endif
}
static __attribute__((noinline)) ch128_word ch128p2l_scalar_region(const ch128p2l_key *k, const uint8_t *p, size_t r, ch128_word v) {
    ch128p_tailgeo g; unsigned j; ch128_word bv[8]; ch128p_geo(&g, p, r);
    for (j = 0; j < g.count; j++) bv[j] = ch128p_block_scalar(&k->p, &g, j);
    return ch128p2l_port_outer(k, v, bv, g.count);
}

/* ================================ x86 ================================ */
#ifdef CH128_X86
/* ---- v2.1: PCLMUL-only helpers ----
 * Product method for the XMM outer multiplies (same digest either way), as in chainhash 14950ac: schoolbook only
 * where PCLMULQDQ issues every cycle (Intel with ADX, Broadwell and later); Karatsuba on AMD (one PCLMULQDQ per two
 * cycles at every width) and older Intel. */
static inline int ch128p_xschool(void) {
#ifdef CH128P_XSCHOOL          /* tests: force the method (0 Karatsuba, 1 schoolbook) */
    return CH128P_XSCHOOL;
#endif
    static int cache = -1; int v = __atomic_load_n(&cache, __ATOMIC_RELAXED);
    if (v < 0) { unsigned r[4], b7 = 0; ch128p_cpuid(0, 0, r);
        v = r[1] == 0x756e6547u && r[3] == 0x49656e69u && r[2] == 0x6c65746eu && ch128p_leaf7_ebx(&b7) && (b7 & (1u << 19)) ? 1 : 0;   /* GenuineIntel + ADX */
        __atomic_store_n(&cache, v, __ATOMIC_RELAXED); }
    return v;
}
/* 1..15 bytes into a zero-padded 16-byte word, registers only (overlapping 8/4-byte loads, no stack buffer) */
CH128_T128 static inline __m128i ch128p_x_small(const uint8_t *p, size_t n) {
    uint64_t lo, hi = 0;
    if (n >= 8) { lo = ch128_load64(p); if (n > 8) hi = ch128_load64(p + n - 8) >> (8 * (16 - n)); }
    else if (n >= 4) { uint32_t a, b; memcpy(&a, p, 4); memcpy(&b, p + n - 4, 4); lo = (uint64_t)a | ((uint64_t)b << (8 * (n - 4))); }
    else { lo = p[0]; if (n > 1) lo |= (uint64_t)p[1] << 8; if (n > 2) lo |= (uint64_t)p[2] << 16; }
    return _mm_set_epi64x((long long)hi, (long long)lo);
}
/* V' = V*z + c(bv[0..q-1]), one raw accumulator, one reduction */
CH128_T128 static inline __m128i ch128p2l_128_outer(const ch128p2l_key *K, __m128i v, const ch128_word *bv, unsigned q) {
    unsigned h = (q + 1) / 2, f = q / 2, i;
#ifdef CH128P2L_XOROUTER
    (void)K; (void)h; (void)f; for (i = 0; i < q; i++) v = _mm_xor_si128(v, ch128_128_load(bv + i)); return v;
#else
    const int sc = ch128p_xschool();
    ch128_128_acc a = ch128_128_accum(ch128_128_azero(), v, ch128_128_load(&K->z), sc); ch128_128_raw st;
    for (i = 0; i < f; i++)
        a = ch128_128_accum(a, _mm_xor_si128(ch128_128_load(bv + i), ch128_128_load(K->ym + 2 * i)),
                               _mm_xor_si128(ch128_128_load(bv + h + i), ch128_128_load(K->ym + 2 * i + 1)), sc);
    st = ch128_128_pack(a, sc);
    if (q & 1) st.lo = _mm_xor_si128(st.lo, ch128_128_load(bv + h - 1));
    return ch128_128_reduce(st);
#endif
}
/* XMM bulk: per region 4 pair MACs (blocks i, 4+i) + the 2-MAC fold of the raw state by z */
CH128_T128 static __attribute__((noinline)) ch128_word ch128p2l_128_bulk(const ch128p2l_key *K, const uint8_t *p, size_t regions, ch128_word vin) {
    const ch128p_key *k = &K->p; ch128_128_raw st; ch128_word v; const int sc = ch128p_xschool();
    st.lo = ch128_128_load(&vin); st.hi = ch128_128_zero();
    do {
        __m128i b[4]; unsigned i;
#ifdef CH128P2L_XOROUTER
        (void)b; for (i = 0; i < 8; i++) st.lo = _mm_xor_si128(st.lo, ch128p_128_fullblock(k, p, i));
#else
        ch128_128_acc a = ch128_128_azero();
        a = ch128_128_accum(a, st.lo, ch128_128_load(&K->z), sc); a = ch128_128_accum(a, st.hi, ch128_128_load(&K->zh), sc);
        for (i = 0; i < 4; i++) b[i] = _mm_xor_si128(ch128p_128_fullblock(k, p, i), ch128_128_load(K->ym + 2 * i));
        for (i = 0; i < 4; i++) a = ch128_128_accum(a, b[i], _mm_xor_si128(ch128p_128_fullblock(k, p, 4 + i), ch128_128_load(K->ym + 2 * i + 1)), sc);
        st = ch128_128_pack(a, sc);
#endif
        p += CH128P_REGION;
    } while (--regions);
    ch128_128_store(&v, ch128_128_reduce(st)); return v;
}
/* XMM tail block values (no AVX2): v1's ch128p_128_tail with the MACs replaced by stores */
CH128_T128 static __attribute__((noinline)) unsigned ch128p2l_128_tailbv(const ch128p_key *k, const uint8_t *p, size_t r, ch128_word *bv) {
    unsigned count = (unsigned)((r + 15) / 16 < 8 ? (r + 15) / 16 : 8), j, m; uint8_t pad[128]; ch128_word kdsum = ch128_make(0, 0);
    ch128p_xgeo g; __m128i kds, kzv;
    g.p = p; g.pad = pad; g.full_rows = (unsigned)(r / 128); g.mhi = (unsigned)((r - 1) / 1024);
    kzv = _mm_loadu_si128((const __m128i *)&k->kz[g.mhi]);
    if (r % 128) { memset(pad, 0, 128); memcpy(pad, p + 128 * (size_t)g.full_rows, r % 128); }
    for (m = 0; m <= g.mhi; m++) { unsigned d = (unsigned)((r + 127) / 128) - 8 * m; g.nr[m] = d > 8 ? 8 : d; kdsum = ch128_xor(kdsum, *CH128P_KDP(k, m, g.nr[m])); }
    kds = _mm_loadu_si128((const __m128i *)&kdsum);
    for (j = 0; j < count; j += 2) {
        __m128i b0 = _mm_xor_si128(ch128p_128_tblock(k, &g, j), kds), b1 = _mm_xor_si128(ch128p_128_tblock(k, &g, j + 1), kds);
        if (g.mhi && 1024 * (size_t)g.mhi + 16 * j >= r) b0 = _mm_xor_si128(b0, kzv);
        if (g.mhi && 1024 * (size_t)g.mhi + 16 * (j + 1) >= r) b1 = _mm_xor_si128(b1, kzv);
        ch128_128_store(bv + j, b0); ch128_128_store(bv + j + 1, b1);
    }
    return count;
}
/* AVX2 tail block values: v1's ch128p_256_region with the MACs replaced by stores */
/* (round 4: an in-place row variant measured -5..-30% at 768 B-12 KiB under clang; v1's pad kept) */
CH128P_T256X static __attribute__((noinline)) unsigned ch128p2l_256_tailbv(const ch128p_key *k, const uint8_t *p, size_t r, ch128_word *bv) {
    unsigned full_rows = (unsigned)(r / 128), count = (unsigned)((r + 15) / 16 < 8 ? (r + 15) / 16 : 8), mhi = (unsigned)((r - 1) / 1024), j, m;
    uint8_t pad[128]; unsigned nr[CH128P_M]; __m256i kds = _mm256_setzero_si256();
    const __m256i kzv = _mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i *)&k->kz[mhi]));
    if (r % 128) { memset(pad, 0, 128); memcpy(pad, p + 128 * (size_t)full_rows, r % 128); }
    for (m = 0; m <= mhi; m++) { unsigned d = (unsigned)((r + 127) / 128) - 8 * m; nr[m] = d > 8 ? 8 : d; kds = _mm256_xor_si256(kds, _mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i *)CH128P_KDP(k, m, nr[m])))); }
    if (r > 112 && r <= 512) {
        unsigned nr0 = nr[0], jq;
        const __m256i s0 = _mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i *)CH128P_SMP(k, 0, nr0)));
        for (jq = 0; jq < 8; jq += 4) {
            __m256i z = _mm256_setzero_si256(), E0 = z, E1 = z, E2 = z, E3 = z, F0 = z, F1 = z, F2 = z, F3 = z, SE = s0, SF = s0, bE, bF;
#define CH128P_Y4ROW(ii) if (ii < nr0) { const uint8_t *q = (ii < full_rows ? p + 128 * ii : pad) + 16 * jq; __m256i kk = _mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i *)(k->mask + ii))); \
                __m256i we = _mm256_xor_si256(_mm256_loadu_si256((const __m256i *)q), kk), wf = _mm256_xor_si256(_mm256_loadu_si256((const __m256i *)(q + 32)), kk); \
                E##ii = ch128p_256_clmul2(we); F##ii = ch128p_256_clmul2(wf); SE = _mm256_xor_si256(SE, we); SF = _mm256_xor_si256(SF, wf); }
            CH128P_Y4ROW(0) CH128P_Y4ROW(1) CH128P_Y4ROW(2) CH128P_Y4ROW(3)
#undef CH128P_Y4ROW
            bE = _mm256_xor_si256(ch128p_256_fin4(E0, E1, E2, E3, ch128p_256_clmul2(SE)), kds);
            bF = _mm256_xor_si256(ch128p_256_fin4(F0, F1, F2, F3, ch128p_256_clmul2(SF)), kds);
            _mm256_storeu_si256((__m256i *)(bv + jq), bE); _mm256_storeu_si256((__m256i *)(bv + jq + 2), bF);
        }
    } else if (r > 512 && r <= 1024) {
        unsigned nr0 = nr[0];
        const __m256i s0 = _mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i *)CH128P_SMP(k, 0, nr0)));
        for (j = 0; j < 8; j += 2) {
            __m256i z = _mm256_setzero_si256(), D0 = z, D1 = z, D2 = z, D3 = z, D4 = z, D5 = z, D6 = z, D7 = z, S = s0, b;
#define CH128P_Y2ROW(ii) if (ii < nr0) { const uint8_t *q = (ii < full_rows ? p + 128 * ii : pad) + 16 * j; \
                __m256i w = _mm256_xor_si256(_mm256_loadu_si256((const __m256i *)q), _mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i *)(k->mask + ii)))); \
                D##ii = ch128p_256_clmul2(w); S = _mm256_xor_si256(S, w); }
            CH128P_Y2ROW(0) CH128P_Y2ROW(1) CH128P_Y2ROW(2) CH128P_Y2ROW(3) CH128P_Y2ROW(4) CH128P_Y2ROW(5) CH128P_Y2ROW(6) CH128P_Y2ROW(7)
#undef CH128P_Y2ROW
            b = _mm256_xor_si256(ch128p_256_fin(D0, D1, D2, D3, D4, D5, D6, D7, ch128p_256_clmul2(S)), kds);
            _mm256_storeu_si256((__m256i *)(bv + j), b);
        }
    } else {
        for (j = 0; j < count; j += 2) {
            __m256i z = _mm256_setzero_si256(), D0 = z, D1 = z, D2 = z, D3 = z, D4 = z, D5 = z, D6 = z, D7 = z, P = z, b;
            CH128P_NOUNROLL
            for (m = 0; m <= mhi; m++) {
                __m256i S = _mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i *)CH128P_SMP(k, m, nr[m]))); const ch128_word *mk = k->mask + 8 * m;
#define CH128P_YROW(ii, row) { __m256i w = _mm256_xor_si256(_mm256_loadu_si256((const __m256i *)((row) + 16 * j)), _mm256_broadcastsi128_si256(_mm_loadu_si128((const __m128i *)(mk + ii)))); \
                    D##ii = _mm256_xor_si256(D##ii, ch128p_256_clmul2(w)); S = _mm256_xor_si256(S, w); }
                if (8 * m + 8 <= full_rows) {
                    const uint8_t *q0 = p + 1024 * (size_t)m;
                    CH128P_YROW(0, q0) CH128P_YROW(1, q0 + 128) CH128P_YROW(2, q0 + 256) CH128P_YROW(3, q0 + 384)
                    CH128P_YROW(4, q0 + 512) CH128P_YROW(5, q0 + 640) CH128P_YROW(6, q0 + 768) CH128P_YROW(7, q0 + 896)
                } else {
#define CH128P_YROWC(ii) { unsigned a_ = 8 * m + ii; CH128P_YROW(ii, (a_ < full_rows ? p + 128 * (size_t)a_ : pad)) }
                    switch (nr[m]) {
                    case 8: CH128P_YROWC(7) /* fall through */ case 7: CH128P_YROWC(6) /* fall through */ case 6: CH128P_YROWC(5) /* fall through */
                    case 5: CH128P_YROWC(4) /* fall through */ case 4: CH128P_YROWC(3) /* fall through */ case 3: CH128P_YROWC(2) /* fall through */
                    case 2: CH128P_YROWC(1) /* fall through */ default: CH128P_YROWC(0) }
#undef CH128P_YROWC
                }
#undef CH128P_YROW
                P = _mm256_xor_si256(P, ch128p_256_clmul2(S));
            }
            b = _mm256_xor_si256(ch128p_256_fin(D0, D1, D2, D3, D4, D5, D6, D7, P), kds);
            if (mhi) {
                if (1024 * (size_t)mhi + 16 * j >= r) b = _mm256_xor_si256(b, _mm256_blend_epi32(z, kzv, 0x0f));
                if (1024 * (size_t)mhi + 16 * (j + 1) >= r) b = _mm256_xor_si256(b, _mm256_blend_epi32(z, kzv, 0xf0));
            }
            _mm256_storeu_si256((__m256i *)(bv + j), b);
        }
    }
    return count;
}
/* XMM short, 1..128 bytes: v1's sfin per block (only row 0 carries data); block values stay in
 * registers (constant q per switch arm, so the pairing is fully unrolled) */
CH128_T128 static inline __attribute__((always_inline)) __m128i ch128p2l_128_outer_r(const ch128p2l_key *K, __m128i v, const __m128i *b, const unsigned q) {
    const unsigned h = (q + 1) / 2, f = q / 2; unsigned i;
#ifdef CH128P2L_XOROUTER
    (void)K; (void)h; (void)f; for (i = 0; i < q; i++) v = _mm_xor_si128(v, b[i]); return v;
#else
    const int sc = ch128p_xschool();
    ch128_128_acc a = ch128_128_accum(ch128_128_azero(), v, ch128_128_load(&K->z), sc); ch128_128_raw st;
    for (i = 0; i < f; i++)
        a = ch128_128_accum(a, _mm_xor_si128(b[i], ch128_128_load(K->ym + 2 * i)), _mm_xor_si128(b[h + i], ch128_128_load(K->ym + 2 * i + 1)), sc);
    st = ch128_128_pack(a, sc);
    if (q & 1) st.lo = _mm_xor_si128(st.lo, b[h - 1]);
    return ch128_128_reduce(st);
#endif
}
CH128_T128 static __attribute__((noinline)) ch128_word ch128p2l_128_short(const ch128p2l_key *K, const uint8_t *p, size_t n) {
    const ch128p_key *k = &K->p; unsigned count = (unsigned)((n + 15) / 16); __m128i b[8], v, L;
    const __m128i K0 = _mm_loadu_si128((const __m128i *)k->mask), S1 = _mm_loadu_si128((const __m128i *)&k->sm[0][0]), KD = _mm_loadu_si128((const __m128i *)&k->kd[0][0]);
    /* v2.1: registers only -- whole words in place, the partial last word as the 16 bytes ending at p+n shifted by
     * PSHUFB, below 16 bytes overlapping scalar loads; no stack buffer (no store-forwarding stall) */
#define CH128P2L_XW(jj) (16 * (jj) + 16 <= n ? _mm_loadu_si128((const __m128i *)(p + 16 * (jj))) : n >= 16 ? ch128_128_word(p, 16 * (jj), n) : ch128p_x_small(p, n))
#define CH128P2L_XS(jj) b[jj] = ch128p_128_sfin(_mm_xor_si128(CH128P2L_XW(jj), K0), S1, KD);
    CH128P2L_XS(0)
    if (count > 1) { CH128P2L_XS(1) if (count > 2) { CH128P2L_XS(2) if (count > 3) { CH128P2L_XS(3)
    if (count > 4) { CH128P2L_XS(4) if (count > 5) { CH128P2L_XS(5) if (count > 6) { CH128P2L_XS(6) if (count > 7) CH128P2L_XS(7) } } } } } }
#undef CH128P2L_XS
#undef CH128P2L_XW
    L = _mm_cvtsi64_si128((long long)n);
    switch (count) {
    case 1: v = ch128p2l_128_outer_r(K, L, b, 1); break;   case 2: v = ch128p2l_128_outer_r(K, L, b, 2); break;
    case 3: v = ch128p2l_128_outer_r(K, L, b, 3); break;   case 4: v = ch128p2l_128_outer_r(K, L, b, 4); break;
    case 5: v = ch128p2l_128_outer_r(K, L, b, 5); break;   case 6: v = ch128p2l_128_outer_r(K, L, b, 6); break;
    case 7: v = ch128p2l_128_outer_r(K, L, b, 7); break;   default: v = ch128p2l_128_outer_r(K, L, b, 8); break;
    }
    return ch128p_128_finish(&k->outer, v);
}
CH128_T128 static __attribute__((noinline)) ch128_word ch128p2l_128_tail(const ch128p2l_key *K, const uint8_t *p, size_t r, ch128_word v, int avx2) {
    ch128_word bv[8]; unsigned q = avx2 ? ch128p2l_256_tailbv(&K->p, p, r, bv) : ch128p2l_128_tailbv(&K->p, p, r, bv);
    ch128_128_store(&v, ch128p2l_128_outer(K, ch128_128_load(&v), bv, q)); return v;
}

/* ---- ZMM ---- */
/* V' = V*z + c(bv): the f <= 4 pair products as one 4-lane MAC (lanes >= f masked to zero) */
CH128P_T512 static inline __m128i ch128p2l_512_outer(const ch128p2l_key *K, __m128i v, const ch128_word *bv, unsigned q) {
#ifdef CH128P2L_XOROUTER
    return ch128p2l_128_outer(K, v, bv, q);
#else
    unsigned h = (q + 1) / 2, f = q / 2; ch128_128_raw t = ch128_128_prod(v, ch128_128_load(&K->z), 1);
    if (f) {
        __m512i X, Y; ch128_512_raw rr;
        if (f == 4) { X = _mm512_xor_si512(ch128_512_load(bv), ch128_512_load(K->ylo)); Y = _mm512_xor_si512(ch128_512_load(bv + 4), ch128_512_load(K->yhi)); }
        else { __mmask8 km = (__mmask8)((1u << (2 * f)) - 1);
               X = _mm512_maskz_xor_epi64(km, _mm512_maskz_loadu_epi64(km, bv), ch128_512_load(K->ylo));
               Y = _mm512_maskz_xor_epi64(km, _mm512_maskz_loadu_epi64(km, bv + h), ch128_512_load(K->yhi)); }
        rr = ch128_512_prod(X, Y, 1);
        t.lo = _mm_xor_si128(t.lo, ch128p_512_fold(rr.lo)); t.hi = _mm_xor_si128(t.hi, ch128p_512_fold(rr.hi));
    }
    if (q & 1) t.lo = _mm_xor_si128(t.lo, ch128_128_load(bv + h - 1));
    return ch128_128_reduce(t);
#endif
}
/* ZMM bulk: lane c = the chain of pair c; region = 1 pair MAC (b0 lanes x b1 lanes) + 2-MAC fold */
CH128P_T512 static inline __attribute__((always_inline)) ch128_word ch128p2l_512_bulk_t(const ch128p2l_key *K, const uint8_t *p, size_t regions, ch128_word vin, const int pbc) {
    const ch128p_key *k = &K->p;
    const __m512i zb = ch128_512_bc(&K->z), zhb = ch128_512_bc(&K->zh), ylo = ch128_512_load(K->ylo), yhi = ch128_512_load(K->yhi);
    ch128_512_raw st; ch128_word init[4] = {{0, 0}}, v; ch128_128_raw t;
    init[0] = vin; st.lo = ch128_512_load(init); st.hi = ch128_512_zero();
    do {
        __m512i DA[8], DB[8], PA, PB, b0, b1;
#if defined(CHAINHASH128V2_PREBC) && defined(CH128P_CORE_T)
        const ch128_word *mk = pbc ? &k->mzb[0][0] : k->mask;
        __asm__("" : "+r"(mk));
        ch128p_512_core_t(mk, p, DA, DB, &PA, &PB, pbc);
#else
        const ch128_word *mk = k->mask; (void)pbc;
        __asm__("" : "+r"(mk));
        ch128p_512_core(mk, p, DA, DB, &PA, &PB);
#endif
        b0 = ch128p_512_fin(DA[0], DA[1], DA[2], DA[3], DA[4], DA[5], DA[6], DA[7], PA);
        b1 = ch128p_512_fin(DB[0], DB[1], DB[2], DB[3], DB[4], DB[5], DB[6], DB[7], PB);
#ifdef CH128P2L_XOROUTER
        st.lo = _mm512_ternarylogic_epi64(st.lo, b0, b1, 0x96); (void)zb; (void)zhb; (void)ylo; (void)yhi;
#else
        { ch128_512_acc a = ch128_512_azero();
          a = ch128_512_accum(a, st.lo, zb, 1); a = ch128_512_accum(a, st.hi, zhb, 1);
          a = ch128_512_accum(a, _mm512_xor_si512(b0, ylo), _mm512_xor_si512(b1, yhi), 1);
          st = ch128_512_pack(a, 1); }
#endif
        p += CH128P_REGION;
    } while (--regions);
    t.lo = ch128p_512_fold(st.lo); t.hi = ch128p_512_fold(st.hi);
    ch128_128_store(&v, ch128_128_reduce(t)); return v;
}
CH128P_T512 static __attribute__((noinline)) ch128_word ch128p2l_512_bulk(const ch128p2l_key *K, const uint8_t *p, size_t regions, ch128_word vin) { return ch128p2l_512_bulk_t(K, p, regions, vin, 0); }
#if defined(CHAINHASH128V2_PREBC) && defined(CH128P_CORE_T)
/* CHAINHASH128V2_PREBC: the same bulk with the pre-broadcast mask table (plain loads). CHAINHASH128V2_PREBC=1: always; CHAINHASH128V2_PREBC=2: on AMD only
 * (Zen 4: a lane broadcast from memory takes FP-pipe slots, +9-11% without; Ice Lake: pure loads either way, neutral). */
CH128P_T512 static __attribute__((noinline)) ch128_word ch128p2l_512_bulk_pb(const ch128p2l_key *K, const uint8_t *p, size_t regions, ch128_word vin) { return ch128p2l_512_bulk_t(K, p, regions, vin, 1); }
static inline int ch128p_af_amd(void) { static int c = -1; if (c < 0) { unsigned r[4]; ch128p_cpuid(0, 0, r); c = (r[1] == 0x68747541u && r[3] == 0x69746e65u && r[2] == 0x444d4163u); } return c; }
#if CHAINHASH128V2_PREBC == 2
#define CH128P2L_512_BULK(K, p, n, v) (ch128p_af_amd() ? ch128p2l_512_bulk_pb(K, p, n, v) : ch128p2l_512_bulk(K, p, n, v))
#else
#define CH128P2L_512_BULK(K, p, n, v) ((void)ch128p2l_512_bulk, ch128p2l_512_bulk_pb(K, p, n, v))
#endif
#else
#define CH128P2L_512_BULK(K, p, n, v) ch128p2l_512_bulk(K, p, n, v)
#endif
/* ZMM tail block values (round 4: v1's pad kept; an in-place / masked-load partial row measured +12% at
 * 129-192 B on Ice Lake but -10..-30% at 256 B-8 KiB on Zen 4 under gcc): v1's ch128p_512_tail with the lane-group MAC replaced by keeping the
 * group (bg[grp] = blocks 4grp..4grp+3 in lanes) */
CH128P_T512 static inline __attribute__((always_inline)) unsigned ch128p2l_512_tailbv(const ch128p_key *k, const uint8_t *p, size_t r, __m512i bg[2]) {
    unsigned full_rows = (unsigned)(r / 128), count = (unsigned)((r + 15) / 16 < 8 ? (r + 15) / 16 : 8), mhi = (unsigned)((r - 1) / 1024), grp, m, j;
    ch128_word corr[8], kdsum = ch128_make(0, 0); unsigned nr[CH128P_M];
    /* v2.2: the partial row by masked loads in place (no stack copy, no store-forwarding stall); masked-off
     * bytes are neither read nor faulted on */
    unsigned pr = (unsigned)(r % 128); __mmask64 mrow[2];
    mrow[0] = pr >= 64 ? ~(__mmask64)0 : (((__mmask64)1 << pr) - 1); mrow[1] = pr >= 128 ? ~(__mmask64)0 : pr <= 64 ? 0 : (((__mmask64)1 << (pr - 64)) - 1);
    for (m = 0; m <= mhi; m++) { unsigned d = (unsigned)((r + 127) / 128) - 8 * m; nr[m] = d > 8 ? 8 : d; kdsum = ch128_xor(kdsum, *CH128P_KDP(k, m, nr[m])); }
    if (mhi) for (j = 0; j < 8; j++) corr[j] = (j < count && 1024 * (size_t)mhi + 16 * j >= r) ? k->kz[mhi] : ch128_make(0, 0);
    for (grp = 0; grp < 2 && 4 * grp < count; grp++) {
        __m512i D0 = _mm512_setzero_si512(), D1 = D0, D2 = D0, D3 = D0, D4 = D0, D5 = D0, D6 = D0, D7 = D0, P = D0, b;
        CH128P_NOUNROLL
        for (m = 0; m <= mhi; m++) {
            __m512i S = ch128_512_bc(CH128P_SMP(k, m, nr[m]));
            if (8 * m + 8 <= full_rows) {
                const uint8_t *q = p + 1024 * (size_t)m + 64 * grp; const ch128_word *mk = k->mask + 8 * m;
#define CH128P_FROW(ii, Dk) { __m512i w = _mm512_xor_si512(_mm512_loadu_si512(q + 128 * ii), ch128_512_bc(mk + ii)); \
                Dk = _mm512_xor_si512(Dk, _mm512_clmulepi64_epi128(w, w, 0x10)); S = _mm512_xor_si512(S, w); }
                CH128P_FROW(0, D0) CH128P_FROW(1, D1) CH128P_FROW(2, D2) CH128P_FROW(3, D3) CH128P_FROW(4, D4) CH128P_FROW(5, D5) CH128P_FROW(6, D6) CH128P_FROW(7, D7)
#undef CH128P_FROW
            } else {
#define CH128P_TROW(ii, Dk) { unsigned a_ = 8 * m + ii; \
                __m512i w = _mm512_xor_si512(a_ < full_rows ? _mm512_loadu_si512(p + 128 * (size_t)a_ + 64 * grp) : _mm512_maskz_loadu_epi8(mrow[grp], p + 128 * (size_t)a_ + 64 * grp), ch128_512_bc(k->mask + a_)); \
                Dk = _mm512_xor_si512(Dk, _mm512_clmulepi64_epi128(w, w, 0x10)); S = _mm512_xor_si512(S, w); }
                switch (nr[m]) {
                case 8: CH128P_TROW(7, D7) /* fall through */ case 7: CH128P_TROW(6, D6) /* fall through */ case 6: CH128P_TROW(5, D5) /* fall through */
                case 5: CH128P_TROW(4, D4) /* fall through */ case 4: CH128P_TROW(3, D3) /* fall through */ case 3: CH128P_TROW(2, D2) /* fall through */
                case 2: CH128P_TROW(1, D1) /* fall through */ default: CH128P_TROW(0, D0) }
#undef CH128P_TROW
            }
            P = _mm512_xor_si512(P, _mm512_clmulepi64_epi128(S, S, 0x10));
        }
        b = (mhi == 0 && nr[0] <= 4) ? ch128p_512_fin4(D0, D1, D2, D3, P) : ch128p_512_fin(D0, D1, D2, D3, D4, D5, D6, D7, P);
        b = mhi ? _mm512_ternarylogic_epi64(b, ch128_512_bc(&kdsum), ch128_512_load(corr + 4 * grp), 0x96) : _mm512_xor_si512(b, ch128_512_bc(&kdsum));
        bg[grp] = b;
    }
    return count;
}
/* ZMM tail: with q = 8 (every r > 112) the two lane groups are the pair operands directly */
CH128P_T512 static __attribute__((noinline)) ch128_word ch128p2l_512_tail(const ch128p2l_key *K, const uint8_t *p, size_t r, ch128_word v) {
    __m512i bg[2]; unsigned q = ch128p2l_512_tailbv(&K->p, p, r, bg);
#ifndef CH128P2L_XOROUTER
    if (q == 8) {
        ch128_128_raw t = ch128_128_prod(ch128_128_load(&v), ch128_128_load(&K->z), 1);
        ch128_512_raw rr = ch128_512_prod(_mm512_xor_si512(bg[0], ch128_512_load(K->ylo)), _mm512_xor_si512(bg[1], ch128_512_load(K->yhi)), 1);
        t.lo = _mm_xor_si128(t.lo, ch128p_512_fold(rr.lo)); t.hi = _mm_xor_si128(t.hi, ch128p_512_fold(rr.hi));
        ch128_128_store(&v, ch128_128_reduce(t)); return v;
    }
#endif
    { ch128_word bv[8]; _mm512_storeu_si512((void *)bv, bg[0]); if (q > 4) _mm512_storeu_si512((void *)(bv + 4), bg[1]);
      ch128_128_store(&v, ch128p2l_512_outer(K, ch128_128_load(&v), bv, q)); return v; }
}
/* ZMM short, 65..128 bytes (the XMM short handles 1..64): v1's sfin, 4 blocks per zmm; with q = 8
 * the two zmm are the pair operands directly */
CH128P_T512 static __attribute__((noinline)) ch128_word ch128p2l_512_short(const ch128p2l_key *K, const uint8_t *p, size_t n) {
    const ch128p_key *k = &K->p; unsigned count = (unsigned)((n + 15) / 16); ch128_word bv[8];
    const __m512i K0 = ch128_512_bc(k->mask), S1 = ch128_512_bc(&k->sm[0][0]), KD = ch128_512_bc(&k->kd[0][0]);
    __mmask64 m1 = n >= 128 ? ~(__mmask64)0 : (((__mmask64)1 << (n - 64)) - 1);
    __m512i b0 = ch128p_512_sfin(_mm512_xor_si512(_mm512_loadu_si512(p), K0), S1, KD);
    __m512i b1 = ch128p_512_sfin(_mm512_xor_si512(_mm512_maskz_loadu_epi8(m1, p + 64), K0), S1, KD);
#ifndef CH128P2L_XOROUTER
    if (count == 8) {
        ch128_128_raw t = ch128_128_prod(_mm_cvtsi64_si128((long long)n), ch128_128_load(&K->z), 1);
        ch128_512_raw rr = ch128_512_prod(_mm512_xor_si512(b0, ch128_512_load(K->ylo)), _mm512_xor_si512(b1, ch128_512_load(K->yhi)), 1);
        t.lo = _mm_xor_si128(t.lo, ch128p_512_fold(rr.lo)); t.hi = _mm_xor_si128(t.hi, ch128p_512_fold(rr.hi));
        return ch128p_128_finish(&k->outer, ch128_128_reduce(t));
    }
#endif
    {   /* q = 5..7: lanes to registers (a masked reload of just-stored values would miss store forwarding) */
        __m128i b[8], L = _mm_cvtsi64_si128((long long)n), v;
        b[0] = _mm512_castsi512_si128(b0); b[1] = _mm512_extracti32x4_epi32(b0, 1); b[2] = _mm512_extracti32x4_epi32(b0, 2); b[3] = _mm512_extracti32x4_epi32(b0, 3);
        b[4] = _mm512_castsi512_si128(b1); b[5] = _mm512_extracti32x4_epi32(b1, 1); b[6] = _mm512_extracti32x4_epi32(b1, 2); b[7] = _mm512_extracti32x4_epi32(b1, 3);
        switch (count) { case 5: v = ch128p2l_128_outer_r(K, L, b, 5); break; case 6: v = ch128p2l_128_outer_r(K, L, b, 6); break;
                         case 7: v = ch128p2l_128_outer_r(K, L, b, 7); break; default: v = ch128p2l_128_outer_r(K, L, b, 8); break; }
        (void)bv; return ch128p_128_finish(&k->outer, v);
    }
}
#endif /* CH128_X86 */

/* ================================ NEON ================================ */
#ifdef CH128_ARM
CH128_NBEGIN
static inline uint64x2_t ch128p2l_n_outer(const ch128p2l_key *K, uint64x2_t v, const ch128_word *bv, unsigned q) {
    unsigned h = (q + 1) / 2, f = q / 2, i;
#ifdef CH128P2L_XOROUTER
    (void)K; (void)h; (void)f; for (i = 0; i < q; i++) v = veorq_u64(v, ch128_n_load(bv + i)); return v;
#else
    ch128p_n_acc a; ch128_n_raw st;
    a.l = a.h = a.m = vdupq_n_u64(0);
    ch128p_n_mac(&a, v, ch128_n_load(&K->z), ch128_n_load(&K->zs));
    for (i = 0; i < f; i++) {
        uint64x2_t X = veorq_u64(ch128_n_load(bv + i), ch128_n_load(K->ym + 2 * i)), Y = veorq_u64(ch128_n_load(bv + h + i), ch128_n_load(K->ym + 2 * i + 1));
        ch128p_n_mac(&a, X, Y, vextq_u64(Y, Y, 1));
    }
    st = ch128p_n_pack(a);
    if (q & 1) st.lo = veorq_u64(st.lo, ch128_n_load(bv + h - 1));
    return ch128_n_reduce(st);
#endif
}
/* NEON bulk: v1's pair kernel (blocks 2jp, 2jp+1) stores the region's 8 block values; then 4 pair
 * MACs + the 2-MAC fold by z (v1: 9 MACs). Measured against holding the values in registers
 * (orders 0,1,2,3 and 0,2,1,3; fold first or last): all within 1%, this one fastest (nbulk_exp.c). */
static __attribute__((noinline)) ch128_word ch128p2l_n_bulk(const ch128p2l_key *K, const uint8_t *p, size_t regions, ch128_word vin) {
    const ch128p_key *k = &K->p; ch128_n_raw st; ch128_word v;
    st.lo = ch128_n_load(&vin); st.hi = ch128_n_zero();
    do {
        ch128_word bv[8]; unsigned jp; const ch128p2l_key *kk = K;
        for (jp = 0; jp < 4; jp++) {
            uint64x2_t A[8], C[8], PA, PC; const ch128_word *mk = k->mask;
            __asm__("" : "+r"(mk));
            ch128p_n_pair(mk, p + 32 * jp, A, C, &PA, &PC, CH128P_NPF(p, jp));
            ch128_n_store(bv + 2 * jp, ch128p_n_fin(A[0], A[1], A[2], A[3], A[4], A[5], A[6], A[7], PA));
            ch128_n_store(bv + 2 * jp + 1, ch128p_n_fin(C[0], C[1], C[2], C[3], C[4], C[5], C[6], C[7], PC));
        }
        __asm__("" : "+r"(kk));   /* reload the outer constants per region (as v1 does its y powers) */
#ifdef CH128P2L_XOROUTER
        { unsigned i; for (i = 0; i < 8; i++) st.lo = veorq_u64(st.lo, ch128_n_load(bv + i)); (void)kk; }
#else
        { ch128p_n_acc a; unsigned i;
          a.l = a.h = a.m = vdupq_n_u64(0);
          ch128p_n_mac(&a, st.lo, ch128_n_load(&kk->z), ch128_n_load(&kk->zs)); ch128p_n_mac(&a, st.hi, ch128_n_load(&kk->zh), ch128_n_load(&kk->zhs));
          for (i = 0; i < 4; i++) {
              uint64x2_t X = veorq_u64(ch128_n_load(bv + i), ch128_n_load(kk->ym + 2 * i)), Y = veorq_u64(ch128_n_load(bv + 4 + i), ch128_n_load(kk->ym + 2 * i + 1));
              ch128p_n_mac(&a, X, Y, vextq_u64(Y, Y, 1));
          }
          st = ch128p_n_pack(a); }
#endif
        p += CH128P_REGION;
    } while (--regions);
    ch128_n_store(&v, ch128_n_reduce(st)); return v;
}
/* round 4: the 16-byte word at p+o with bytes at or past p+r zeroed, read in place (chainhash 2c61966):
 * the partial word is the 16 bytes ending at p+r shifted by TBL; a 16-byte copy only if r < 16. */
static inline uint64x2_t ch128p2l_n_tw(const uint8_t *p, size_t o, size_t r) {
    if (o + 16 <= r) return vld1q_u64((const uint64_t *)(p + o));
    if (o >= r) return vdupq_n_u64(0);
    if (r >= 16) return ch128_n_word(p, o, r);
    { uint64_t w[2] = {0, 0}; size_t i; for (i = 0; i < r - o; i++) w[i >> 3] |= (uint64_t)p[o + i] << (8 * (i & 7));   /* no call: a memcpy here would clobber the caller's vector registers */
      return vcombine_u64(vcreate_u64(w[0]), vcreate_u64(w[1])); }
}
/* round 4: the fully present pair-vectors [m0, m1) of block pair (j, j+1) in a partial region, with the bulk's
 * fused PMULL+EOR accumulate; the loop is unrolled by two so the rotating accumulators need no moves. */
static inline __attribute__((always_inline)) void ch128p2l_n_fullpv(const ch128p_key *k, const uint8_t *p, unsigned j, unsigned m0, unsigned m1, uint64x2_t A[8], uint64x2_t C[8], uint64x2_t *PA, uint64x2_t *PC) {
    unsigned m, i; uint64x2_t pa = *PA, pc = *PC;
#define CH128P2L_FSTEP(mm) { const uint8_t *q = p + 1024 * (size_t)(mm) + 16 * j; const ch128_word *mk = k->mask + 8 * (mm); uint64x2_t SA = vdupq_n_u64(0), SB = SA, x; \
        for (i = 0; i < 8; i += 2) { \
            uint64x2_t k0 = vld1q_u64((const uint64_t *)&mk[i]), k1 = vld1q_u64((const uint64_t *)&mk[i + 1]); \
            uint64x2_t a0 = veorq_u64(vld1q_u64((const uint64_t *)(q + 128 * i)), k0), b0 = veorq_u64(vld1q_u64((const uint64_t *)(q + 128 * i + 16)), k0); \
            uint64x2_t a1 = veorq_u64(vld1q_u64((const uint64_t *)(q + 128 * i + 128)), k1), b1 = veorq_u64(vld1q_u64((const uint64_t *)(q + 128 * i + 144)), k1); \
            uint64x2_t c0 = vextq_u64(a0, b0, 1), c1 = vextq_u64(a1, b1, 1); \
            A[i] = ch128p_n_fl(A[i], a0, c0); C[i] = ch128p_n_fh(C[i], c0, b0); A[i + 1] = ch128p_n_fl(A[i + 1], a1, c1); C[i + 1] = ch128p_n_fh(C[i + 1], c1, b1); \
            SA = CH128P_E3(SA, a0, a1); SB = CH128P_E3(SB, b0, b1); } \
        x = vextq_u64(SA, SB, 1); pa = ch128p_n_fl(pa, SA, x); pc = ch128p_n_fh(pc, x, SB); }
    for (m = m0; m + 2 <= m1; m += 2) { CH128P2L_FSTEP(m) CH128P2L_FSTEP(m + 1) }
    if (m < m1) CH128P2L_FSTEP(m)
#undef CH128P2L_FSTEP
    *PA = pa; *PC = pc;
}
/* NEON tail block values: v1's ch128p_n_tail with the MACs replaced by stores */
static __attribute__((noinline)) unsigned ch128p2l_n_tailbv(const ch128p_key *k, const uint8_t *p, size_t r, ch128_word *bv) {
    unsigned full_rows = (unsigned)(r / 128), count = (unsigned)((r + 15) / 16 < 8 ? (r + 15) / 16 : 8), mhi = (unsigned)((r - 1) / 1024), jp, m;
    uint8_t pad[128]; ch128_word kdsum = ch128_make(0, 0); unsigned nr[CH128P_M];
    uint64x2_t kds, kzv = vld1q_u64((const uint64_t *)&k->kz[mhi]);
    if (r % 128) { unsigned x; for (x = 0; x < 128; x += 16) vst1q_u64((uint64_t *)(pad + x), ch128p2l_n_tw(p, 128 * (size_t)full_rows + x, r)); }   /* round 4: the partial row from in-place words, one 16-byte store each: every later 16-byte load forwards (a memcpy'd buffer did not) */
    if (r > 112 && r <= 512) {
        unsigned nr0 = (unsigned)((r + 127) / 128), jq, i; const uint8_t *row[4];
        uint64x2_t kd0 = vld1q_u64((const uint64_t *)CH128P_KDP(k, 0, nr0)), s0 = vld1q_u64((const uint64_t *)CH128P_SMP(k, 0, nr0));
        for (i = 0; i < 4; i++) row[i] = i < full_rows ? p + 128 * i : pad;
        for (jq = 0; jq < 8; jq += 4) {
            uint64x2_t z = vdupq_n_u64(0), D[4][4], S[4], P[4]; unsigned t;
            for (t = 0; t < 4; t++) { D[t][0] = D[t][1] = D[t][2] = D[t][3] = z; S[t] = s0; }
            for (i = 0; i < nr0; i++) {
                uint64x2_t kk = vld1q_u64((const uint64_t *)&k->mask[i]);
                uint64x2_t a0 = veorq_u64(vld1q_u64((const uint64_t *)(row[i] + 16 * jq)), kk), b0 = veorq_u64(vld1q_u64((const uint64_t *)(row[i] + 16 * jq + 16)), kk);
                uint64x2_t a1 = veorq_u64(vld1q_u64((const uint64_t *)(row[i] + 16 * jq + 32)), kk), b1 = veorq_u64(vld1q_u64((const uint64_t *)(row[i] + 16 * jq + 48)), kk);
                uint64x2_t c0 = vextq_u64(a0, b0, 1), c1 = vextq_u64(a1, b1, 1);
                D[0][i] = ch128_n_ll(a0, c0); D[1][i] = ch128_n_hh(c0, b0); D[2][i] = ch128_n_ll(a1, c1); D[3][i] = ch128_n_hh(c1, b1);
                S[0] = veorq_u64(S[0], a0); S[1] = veorq_u64(S[1], b0); S[2] = veorq_u64(S[2], a1); S[3] = veorq_u64(S[3], b1);
            }
            for (t = 0; t < 4; t++) P[t] = ch128_n_ll(S[t], vextq_u64(S[t], S[t], 1));
            for (t = 0; t < 4; t++) ch128_n_store(bv + jq + t, veorq_u64(ch128p_n_fin4(D[t][0], D[t][1], D[t][2], D[t][3], P[t]), kd0));
        }
    } else if (r > 512 && r <= 1024) {
        unsigned nr0 = (unsigned)((r + 127) / 128), jq, t;
        uint64x2_t kd0 = vld1q_u64((const uint64_t *)CH128P_KDP(k, 0, nr0)), s0 = vld1q_u64((const uint64_t *)CH128P_SMP(k, 0, nr0));
        for (jq = 0; jq < 8; jq += 4) {
            uint64x2_t z = vdupq_n_u64(0), D[4][8], S[4], P[4];
            for (t = 0; t < 4; t++) { unsigned i; for (i = 0; i < 8; i++) D[t][i] = z; S[t] = s0; }
#define CH128P_N4ROW(ii) if (ii < nr0) { const uint8_t *q = (ii < full_rows ? p + 128 * ii : pad) + 16 * jq; uint64x2_t kk = vld1q_u64((const uint64_t *)&k->mask[ii]); \
                uint64x2_t a0 = veorq_u64(vld1q_u64((const uint64_t *)q), kk), b0 = veorq_u64(vld1q_u64((const uint64_t *)(q + 16)), kk); \
                uint64x2_t a1 = veorq_u64(vld1q_u64((const uint64_t *)(q + 32)), kk), b1 = veorq_u64(vld1q_u64((const uint64_t *)(q + 48)), kk); \
                uint64x2_t c0 = vextq_u64(a0, b0, 1), c1 = vextq_u64(a1, b1, 1); \
                D[0][ii] = ch128_n_ll(a0, c0); D[1][ii] = ch128_n_hh(c0, b0); D[2][ii] = ch128_n_ll(a1, c1); D[3][ii] = ch128_n_hh(c1, b1); \
                S[0] = veorq_u64(S[0], a0); S[1] = veorq_u64(S[1], b0); S[2] = veorq_u64(S[2], a1); S[3] = veorq_u64(S[3], b1); }
            CH128P_N4ROW(0) CH128P_N4ROW(1) CH128P_N4ROW(2) CH128P_N4ROW(3) CH128P_N4ROW(4) CH128P_N4ROW(5) CH128P_N4ROW(6) CH128P_N4ROW(7)
#undef CH128P_N4ROW
            for (t = 0; t < 4; t++) P[t] = ch128_n_ll(S[t], vextq_u64(S[t], S[t], 1));
            for (t = 0; t < 4; t++) ch128_n_store(bv + jq + t, veorq_u64(ch128p_n_fin(D[t][0], D[t][1], D[t][2], D[t][3], D[t][4], D[t][5], D[t][6], D[t][7], P[t]), kd0));
        }
    } else {
        for (m = 0; m <= mhi; m++) { unsigned d = (unsigned)((r + 127) / 128) - 8 * m; nr[m] = d > 8 ? 8 : d; kdsum = ch128_xor(kdsum, *CH128P_KDP(k, m, nr[m])); }
        kds = vld1q_u64((const uint64_t *)&kdsum);
        for (jp = 0; 2 * jp < count; jp++) {
            uint64x2_t z = vdupq_n_u64(0), A0 = z, A1 = z, A2 = z, A3 = z, A4 = z, A5 = z, A6 = z, A7 = z, C0 = z, C1 = z, C2 = z, C3 = z, C4 = z, C5 = z, C6 = z, C7 = z;
            uint64x2_t PA = z, PC = z, bA, bC; unsigned j = 2 * jp, mf = full_rows / 8 < mhi + 1 ? full_rows / 8 : mhi + 1;
            { uint64x2_t Af[8] = {z, z, z, z, z, z, z, z}, Cf[8] = {z, z, z, z, z, z, z, z};
              ch128p2l_n_fullpv(k, p, j, 0, mf, Af, Cf, &PA, &PC);
              A0 = Af[0]; A1 = Af[1]; A2 = Af[2]; A3 = Af[3]; A4 = Af[4]; A5 = Af[5]; A6 = Af[6]; A7 = Af[7];
              C0 = Cf[0]; C1 = Cf[1]; C2 = Cf[2]; C3 = Cf[3]; C4 = Cf[4]; C5 = Cf[5]; C6 = Cf[6]; C7 = Cf[7]; }
            CH128P_NOUNROLL
            for (m = mf; m <= mhi; m++) {
                uint64x2_t SA = vld1q_u64((const uint64_t *)CH128P_SMP(k, m, nr[m])), SB = SA; const ch128_word *mk = k->mask + 8 * m;
#define CH128P_NROW(ii, row) { const uint8_t *q = (row) + 16 * j; uint64x2_t kk = vld1q_u64((const uint64_t *)(mk + ii)); \
                    uint64x2_t a0 = veorq_u64(vld1q_u64((const uint64_t *)q), kk), b0 = veorq_u64(vld1q_u64((const uint64_t *)(q + 16)), kk), c0 = vextq_u64(a0, b0, 1); \
                    A##ii = veorq_u64(A##ii, ch128_n_ll(a0, c0)); C##ii = veorq_u64(C##ii, ch128_n_hh(c0, b0)); SA = veorq_u64(SA, a0); SB = veorq_u64(SB, b0); }
                if (8 * m + 8 <= full_rows) {
                    const uint8_t *q0 = p + 1024 * (size_t)m;
                    CH128P_NROW(0, q0) CH128P_NROW(1, q0 + 128) CH128P_NROW(2, q0 + 256) CH128P_NROW(3, q0 + 384)
                    CH128P_NROW(4, q0 + 512) CH128P_NROW(5, q0 + 640) CH128P_NROW(6, q0 + 768) CH128P_NROW(7, q0 + 896)
                } else {
#define CH128P_NROWC(ii) { unsigned a_ = 8 * m + ii; CH128P_NROW(ii, (a_ < full_rows ? p + 128 * (size_t)a_ : pad)) }
                    switch (nr[m]) {
                    case 8: CH128P_NROWC(7) /* fall through */ case 7: CH128P_NROWC(6) /* fall through */ case 6: CH128P_NROWC(5) /* fall through */
                    case 5: CH128P_NROWC(4) /* fall through */ case 4: CH128P_NROWC(3) /* fall through */ case 3: CH128P_NROWC(2) /* fall through */
                    case 2: CH128P_NROWC(1) /* fall through */ default: CH128P_NROWC(0) }
#undef CH128P_NROWC
                }
#undef CH128P_NROW
                PA = veorq_u64(PA, ch128_n_ll(SA, vextq_u64(SA, SA, 1))); PC = veorq_u64(PC, ch128_n_ll(SB, vextq_u64(SB, SB, 1)));
            }
            if (mhi == 0 && nr[0] <= 4) { bA = veorq_u64(ch128p_n_fin4(A0, A1, A2, A3, PA), kds); bC = veorq_u64(ch128p_n_fin4(C0, C1, C2, C3, PC), kds); }
            else { bA = veorq_u64(ch128p_n_fin(A0, A1, A2, A3, A4, A5, A6, A7, PA), kds); bC = veorq_u64(ch128p_n_fin(C0, C1, C2, C3, C4, C5, C6, C7, PC), kds); }
            if (1024 * (size_t)mhi + 16 * j >= r) bA = veorq_u64(bA, kzv);
            if (1024 * (size_t)mhi + 16 * (j + 1) >= r) bC = veorq_u64(bC, kzv);
            ch128_n_store(bv + j, bA); ch128_n_store(bv + j + 1, bC);
        }
    }
    return count;
}
static __attribute__((noinline)) ch128_word ch128p2l_n_tail(const ch128p2l_key *K, const uint8_t *p, size_t r, ch128_word v) {
    ch128_word bv[8]; unsigned q = ch128p2l_n_tailbv(&K->p, p, r, bv);
    ch128_n_store(&v, ch128p2l_n_outer(K, ch128_n_load(&v), bv, q)); return v;
}
/* NEON short, 1..128 bytes: v1's sfin per block; block values stay in registers (constant q per
 * switch arm, so the pairing is fully unrolled) */
static inline __attribute__((always_inline)) uint64x2_t ch128p2l_n_outer_r(const ch128p2l_key *K, uint64x2_t v, const uint64x2_t *b, const unsigned q) {
    const unsigned h = (q + 1) / 2, f = q / 2; unsigned i;
#ifdef CH128P2L_XOROUTER
    (void)K; (void)h; (void)f; for (i = 0; i < q; i++) v = veorq_u64(v, b[i]); return v;
#else
    ch128p_n_acc a; ch128_n_raw st;
    a.l = a.h = a.m = vdupq_n_u64(0);
    ch128p_n_mac(&a, v, ch128_n_load(&K->z), ch128_n_load(&K->zs));
    for (i = 0; i < f; i++) {
        uint64x2_t X = veorq_u64(b[i], ch128_n_load(K->ym + 2 * i)), Y = veorq_u64(b[h + i], ch128_n_load(K->ym + 2 * i + 1));
        ch128p_n_mac(&a, X, Y, vextq_u64(Y, Y, 1));
    }
    st = ch128p_n_pack(a);
    if (q & 1) st.lo = veorq_u64(st.lo, b[h - 1]);
    return ch128_n_reduce(st);
#endif
}
static __attribute__((noinline)) ch128_word ch128p2l_n_short(const ch128p2l_key *K, const uint8_t *p, size_t n) {
    const ch128p_key *k = &K->p; unsigned count = (unsigned)((n + 15) / 16), j; uint64x2_t b[8], v, L;
    const uint64x2_t K0 = vld1q_u64((const uint64_t *)k->mask), S1 = vld1q_u64((const uint64_t *)&k->sm[0][0]), KD = vld1q_u64((const uint64_t *)&k->kd[0][0]);
    /* round 4: words read in place (only a partial last word goes through a 16-byte temporary), one EXT gives both
     * blocks' parity products, and the partner of an odd last block is not finalized */
#define CH128P2L_NS(jj) { uint64x2_t A = veorq_u64(ch128p_n_word8(p, n, 16 * (jj)), K0), B = veorq_u64(ch128p_n_word8(p, n, 16 * (jj) + 16), K0), C = vextq_u64(A, B, 1); \
        uint64x2_t SA = veorq_u64(A, S1), SB = veorq_u64(B, S1), X = vextq_u64(SA, SB, 1); \
        b[jj] = ch128p_n_sfin(ch128_n_ll(A, C), ch128_n_ll(SA, X), KD); \
        if ((jj) + 1 < count) b[(jj) + 1] = ch128p_n_sfin(ch128_n_hh(C, B), ch128_n_hh(X, SB), KD); }
    L = vsetq_lane_u64((uint64_t)n, vdupq_n_u64(0), 0);
    CH128P2L_NS(0)
    if (count > 2) CH128P2L_NS(2)
    if (count > 4) { CH128P2L_NS(4) if (count > 6) CH128P2L_NS(6) }
#undef CH128P2L_NS
    switch (count) {
    case 1: v = ch128p2l_n_outer_r(K, L, b, 1); break;   case 2: v = ch128p2l_n_outer_r(K, L, b, 2); break;
    case 3: v = ch128p2l_n_outer_r(K, L, b, 3); break;   case 4: v = ch128p2l_n_outer_r(K, L, b, 4); break;
    case 5: v = ch128p2l_n_outer_r(K, L, b, 5); break;   case 6: v = ch128p2l_n_outer_r(K, L, b, 6); break;
    case 7: v = ch128p2l_n_outer_r(K, L, b, 7); break;   default: v = ch128p2l_n_outer_r(K, L, b, 8); break;
    }
    (void)j;
    return ch128p_n_finish(&k->outer, v);
}
CH128_NEND
#endif /* CH128_ARM */

/* ---------------- dispatch ---------------- */
/* V <- V*z^(regions) + sum_rho c_rho z^(...), over the full regions and the partial tail of p[0..n) */
static inline ch128_word ch128p2l_poly(const ch128p2l_key *k, const uint8_t *p, size_t n, ch128_word V, int b) {
    size_t full = n / CH128P_REGION, r = n % CH128P_REGION; (void)b;
    if (full) {
#ifdef CH128_X86
        if (b == 3) V = CH128P2L_512_BULK(k, p, full, V); else if (b == 1) V = ch128p2l_128_bulk(k, p, full, V); else
#elif defined(CH128_ARM)
        if (b == 4) V = ch128p2l_n_bulk(k, p, full, V); else
#endif
        { size_t i; for (i = 0; i < full; i++) V = ch128p2l_scalar_region(k, p + i * CH128P_REGION, CH128P_REGION, V); }
        p += full * CH128P_REGION;
    }
    if (r) {
#ifdef CH128_X86
        if (b == 3) V = ch128p2l_512_tail(k, p, r, V); else if (b == 1) V = ch128p2l_128_tail(k, p, r, V, ch128p_has_avx2()); else
#elif defined(CH128_ARM)
        if (b == 4) V = ch128p2l_n_tail(k, p, r, V); else
#endif
        V = ch128p2l_scalar_region(k, p, r, V);
    }
    return V;
}
/* v2.2: the general path in its own (noinline) function, so the short paths are reached without its frame */
static __attribute__((noinline)) ch128_word ch128p2l_long(const ch128p2l_key *k, const uint8_t *p, size_t n, int b) {
    return ch128p_finish(&k->p.outer, ch128p2l_poly(k, p, n, ch128_make(n, 0), b), b ? 1 : 0);
}
static inline ch128_word ch128p2l_with_backend(const ch128p2l_key *k, const void *data, size_t n, int b) {
    if (!n) return ch128p_finish(&k->p.outer, ch128_make(0, 0), b ? 1 : 0);   /* one empty block: V = 0*z + 0 */
#ifdef CH128_X86
    if ((b == 3 && n <= 64) || (b == 1 && n <= 128)) return ch128p2l_128_short(k, (const uint8_t *)data, n);
    if (b == 3 && n <= 128) return ch128p2l_512_short(k, (const uint8_t *)data, n);
#elif defined(CH128_ARM)
    if (b == 4 && n <= 128) return ch128p2l_n_short(k, (const uint8_t *)data, n);
#endif
    return ch128p2l_long(k, (const uint8_t *)data, n, b);
}
static inline ch128_word ch128p2l(const ch128p2l_key *k, const void *p, size_t n) { return ch128p2l_with_backend(k, p, n, ch128p_backend()); }

/* ---------------- streaming: one pass, one 16 KiB region buffered (full regions are c with q = 8
 * whether or not they are last); the length term len*z^m' is added in final. ---------------- */
typedef struct {
    const ch128p2l_key *key; ch128_word V; uint64_t len, regions; int backend; size_t used;
    uint8_t buffer[CH128P_REGION];
} ch128p2l_stream;
static inline void ch128p2l_init(ch128p2l_stream *s, const ch128p2l_key *k, int b) {
    assert(ch128p_has_backend(b)); memset(s, 0, sizeof(*s)); s->key = k; s->backend = b;
}
static inline void ch128p2l_update(ch128p2l_stream *s, const void *data, size_t n) {
    const uint8_t *p = (const uint8_t *)data; assert(n <= UINT64_MAX - s->len); s->len += n;
    if (s->used) {
        size_t take = CH128P_REGION - s->used; if (take > n) take = n;
        if (take) { memcpy(s->buffer + s->used, p, take); p += take; n -= take; s->used += take; }
        if (s->used == CH128P_REGION) { s->V = ch128p2l_poly(s->key, s->buffer, CH128P_REGION, s->V, s->backend); s->regions++; s->used = 0; }
    }
    if (n >= CH128P_REGION) {
        size_t full = n / CH128P_REGION;
        s->V = ch128p2l_poly(s->key, p, full * CH128P_REGION, s->V, s->backend); s->regions += full;
        p += full * CH128P_REGION; n -= full * CH128P_REGION;
    }
    if (n) { memcpy(s->buffer, p, n); s->used = n; }
}
static inline ch128_word ch128p2l_final(ch128p2l_stream *s) {
    int b = s->backend ? 1 : 0;
    if (!s->regions) return ch128p2l_with_backend(s->key, s->buffer, s->used, s->backend);   /* every byte is still buffered */
    if (s->used) { s->V = ch128p2l_poly(s->key, s->buffer, s->used, s->V, s->backend); s->regions++; s->used = 0; }
    s->V = ch128_xor(s->V, ch128_mul(ch128_make(s->len, 0), ch128_pow(s->key->z, s->regions, b), b));
    return ch128p_finish(&s->key->p.outer, s->V, b);
}

/* ================= public API ================= */
#define CHAINHASH128V2_KEY_BYTES 192
#define CHAINHASH128V2_KEY_WORDS 12
/* The key object: the expanded key at store + off, 64-byte aligned at the address where the key was initialized, so
 * a key in place at any 8-byte-aligned address (malloc, new, the stack, static storage) has aligned tables.  A copy
 * (memcpy) keeps off and computes the same digests; its tables may then be unaligned (slower on some backends). */
typedef struct { uint64_t off; unsigned char store[sizeof(ch128p2l_key) + 64]; } ch128p2l_akey;
static inline ch128p2l_key *ch128p2l_place(ch128p2l_akey *k) { k->off = (64 - ((uintptr_t)k->store & 63)) & 63; return (ch128p2l_key *)(void *)(k->store + k->off); }
static inline const ch128p2l_key *ch128p2l_in(const ch128p2l_akey *k) { return (const ch128p2l_key *)(const void *)(k->store + k->off); }
typedef ch128p2l_akey chainhash128v2_key;
typedef ch128p2l_stream chainhash128v2_stream;
/* key = s (bytes 0..63) || y || c0..c4 || tau || z (16 bytes each); docs/SPEC-128v2.md section 1 */
static inline void chainhash128v2_key_from_bytes(chainhash128v2_key *k, const uint8_t p[CHAINHASH128V2_KEY_BYTES]) { ch128p2l_key_from_bytes(ch128p2l_place(k), p); }
/* the same 192 bytes as 12 words; word i is bytes 16i..16i+15 (lo = bytes 16i..16i+7) */
static inline void chainhash128v2_key_from_words(chainhash128v2_key *k, const ch128_word w[CHAINHASH128V2_KEY_WORDS]) {
    uint8_t p[CHAINHASH128V2_KEY_BYTES]; unsigned i;
    for (i = 0; i < CHAINHASH128V2_KEY_WORDS; i++) chainhash128_store(p + 16 * i, w[i]);
    ch128p2l_key_from_bytes(ch128p2l_place(k), p);
}
/* SplitMix64 expansion of a seed: for benchmarks and tests, not covered by the bound */
static inline void chainhash128v2_key_from_seed(chainhash128v2_key *k, uint64_t seed) { ch128p2l_key_from_seed(ch128p2l_place(k), seed); }
static inline int chainhash128v2_backend(void) { return ch128p_backend(); }
static inline int chainhash128v2_has_backend(int b) { return ch128p_has_backend(b); }
static inline ch128_word chainhash128v2_with_backend(const chainhash128v2_key *k, const void *data, size_t len, int b) { return ch128p2l_with_backend(ch128p2l_in(k), data, len, b); }
static inline ch128_word chainhash128v2(const chainhash128v2_key *k, const void *data, size_t len) { return ch128p2l(ch128p2l_in(k), data, len); }
/* the definition, literally (bit-serial field arithmetic); for tests */
static inline ch128_word chainhash128v2_reference(const chainhash128v2_key *k, const void *data, size_t len) { return ch128p2l_ref(ch128p2l_in(k), data, len); }
static inline void chainhash128v2_init(chainhash128v2_stream *s, const chainhash128v2_key *k, int b) { ch128p2l_init(s, ch128p2l_in(k), b); }
static inline void chainhash128v2_update(chainhash128v2_stream *s, const void *data, size_t len) { ch128p2l_update(s, data, len); }
static inline ch128_word chainhash128v2_final(chainhash128v2_stream *s) { return ch128p2l_final(s); }

#endif /* CHAINHASH128V2_H */
