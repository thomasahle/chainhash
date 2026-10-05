/* ftest.c -- the ChainHash-192 fast finalizers against the reference finisher c192_finish_ref on CRAFTED chain values:
 * every combination of limbs V_i in {~tau_i, ~tau_i + 1, ~tau_i - 1, 0, ~0, random} (6^3 = 216 per key) -- the carry
 * patterns of the integer twist X = V +_Z tau that end-to-end tests cannot reach (a propagating limb has probability
 * 2^-64) -- plus random V; keys with tau limbs forced to 0, 1, ~0 on odd rounds.  x86: the AVX-512 finalizer (vector
 * carry lookahead) and the SSE one (GPR add/adc); NEON: the NEON finalizer.  Uses the header's internal names. */
#include "chainhash192.h"
#include <stdio.h>
static uint64_t rs = 0x5eed; static uint64_t rnd(void) { return c192_splitmix(&rs); }
static uint64_t edge(void) { switch (rnd() % 6) { case 0: return 0; case 1: return ~0ULL; case 2: return 1; case 3: return 1ULL << 63; default: return rnd(); } }
#if defined(C192_X86)
#if defined(__clang__)
#pragma clang attribute push (__attribute__((target("avx512f,avx512vl,avx512bw,avx512dq,avx512vbmi2,vpclmulqdq,pclmul,avx2,sse4.1"))), apply_to=function)
#else
#pragma GCC push_options
#pragma GCC target("avx512f,avx512vl,avx512bw,avx512dq,avx512vbmi2,vpclmulqdq,pclmul,avx2,sse4.1")
#endif
static int fin_x(const c192d_key *H, c192_el v, uint8_t o[24]) { c192h_out(c192x_fin(c192h_ld(v), &H->x.XF), o); return 1; }
static int fin_s(const c192d_key *H, c192_el v, uint8_t o[24]) { c192h_out(c192h_fin(c192h_ld(v), &H->s.F), o); return 1; }
#if defined(__clang__)
#pragma clang attribute pop
#else
#pragma GCC pop_options
#endif
#elif defined(C192_ARM)
static int fin_n(const c192d_key *H, c192_el v, uint8_t o[24]) { c192v_out(c192n_fin(&H->n, c192v_ld(v)), o); return 1; }
#endif
int main(void) {
    static c192d_key Hx, Hs; long bad = 0, cnt = 0; int nfin = 0;
    for (int kk = 0; kk < 24; kk++) {
        c192_raw R; c192_raw_from_seed(&R, rnd()); if (kk & 1) for (int l = 0; l < 3; l++) R.t.w[l] = edge();
        static c192_key K; c192_derive(&R, &K);
#if defined(C192_X86)
        int hx = chainhash192_has_backend(CH192_AVX512), hs = chainhash192_has_backend(CH192_PCLMUL);
        if (hx) c192d_init_raw2(&Hx, &R, CH192_AVX512);
        if (hs) c192d_init_raw2(&Hs, &R, CH192_PCLMUL);
        nfin = hx + hs;
#elif defined(C192_ARM)
        c192d_init_raw2(&Hx, &R, CH192_NEON); nfin = 1; (void)Hs;
#endif
        for (int c = 0; c < 216 + 3000; c++) { c192_el v; int cc = c;
            for (int l = 0; l < 3; l++) { uint64_t t = K.tau.w[l], x; int m = c < 216 ? cc % 6 : 5; cc /= 6;
                switch (m) { case 0: x = ~t; break; case 1: x = ~t + 1; break; case 2: x = ~t - 1; break; case 3: x = 0; break; case 4: x = ~0ULL; break; default: x = rnd(); }
                v.w[l] = x; }
            uint8_t r[24], o[24]; c192_store(c192_finish_ref(v, &K), r);
#if defined(C192_X86)
            if (hx) { fin_x(&Hx, v, o); cnt++; if (memcmp(r, o, 24) && bad++ < 5) printf("  AVX-512 finalizer mismatch key %d case %d\n", kk, c); }
            if (hs) { fin_s(&Hs, v, o); cnt++; if (memcmp(r, o, 24) && bad++ < 5) printf("  SSE finalizer mismatch key %d case %d\n", kk, c); }
#elif defined(C192_ARM)
            fin_n(&Hx, v, o); cnt++; if (memcmp(r, o, 24) && bad++ < 5) printf("  NEON finalizer mismatch key %d case %d\n", kk, c);
#endif
        } }
    if (!nfin) { printf("[ftest] no fast backend: skipped\n"); return 0; }
    printf("[ftest] %d fast finalizer(s) on %ld crafted/random chain values vs c192_finish_ref: %s\n", nfin, cnt, bad ? "FAIL" : "PASS"); return bad != 0; }
