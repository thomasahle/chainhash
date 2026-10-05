/* xcheck.c -- randomized cross-check against the normative reference c192_hash_ref: many random RAW keys (tau / c_i
 * limbs forced to 0, 1, ~0, ~0-1, 2^63 at random: long carry chains in the twist; y = 0 allowed), every runtime backend,
 * lengths 0..400 and around the chunk / block / region edges, random misalignment, one-shot and streaming (random
 * split points).  -DCH192_HW_CLMUL speeds up the reference (same definition). */
#include "chainhash192.h"
#include <stdio.h>
#ifndef NKEYS
#define NKEYS 300
#endif
static uint64_t rs = 0x1234567; static uint64_t rnd(void) { return c192_splitmix(&rs); }
static uint64_t edge(void) { uint64_t v = rnd(); switch (rnd() % 8) { case 0: return 0; case 1: return ~0ULL; case 2: return 1; case 3: return ~0ULL - 1; case 4: return 1ULL << 63; default: return v; } }
static void rraw(uint8_t b[216]) { for (int i = 0; i < 27; i++) { uint64_t w = rnd(); int el = i / 3; if (el >= 3) w = (rnd() % 3) ? rnd() : edge(); if (el == 1 && rnd() % 16 == 0) w = 0; memcpy(b + 8 * i, &w, 8); } }
int main(void) {
    size_t maxn = 2 * C192_REGION + C192_BLOCK + 400; uint8_t *buf = malloc(maxn + 64); for (size_t i = 0; i < maxn + 64; i++) buf[i] = (uint8_t)rnd();
    int b[4] = {CH192_PORTABLE, CH192_PCLMUL, CH192_AVX512, CH192_NEON}; static chainhash192_key H, R; long fails = 0, n1 = 0, ns = 0;
    size_t edges[] = {191, 192, 193, 383, 384, 385, 3839, 3840, 3841, 3967, 3968, 4095, 4096, 4097, 8192, 8193, C192_REGION - 1, C192_REGION, C192_REGION + 1, C192_REGION + 64, C192_REGION + 4096, 2 * C192_REGION + 300};
    for (int bi = 1; bi < 4; bi++) { if (!chainhash192_has_backend(b[bi])) continue; long f0 = fails;
        for (int kk = 0; kk < NKEYS; kk++) { uint8_t raw[216]; rraw(raw); chainhash192_key_from_bytes_with_backend(&R, raw, CH192_PORTABLE); chainhash192_key_from_bytes_with_backend(&H, raw, b[bi]);
            for (int s = 0; s < 20; s++) { size_t n = s < 12 ? (size_t)(rnd() % 401) : s < 16 ? (size_t)(64 + rnd() % 4100) : edges[rnd() % (sizeof edges / sizeof *edges)];
                if (kk % 4 == 0 && s == 0) n = (size_t)(kk / 4) % 401;
                size_t off = rnd() % 64; uint8_t r[24], o[24]; chainhash192_reference(&R, buf + off, n, r);
                chainhash192(&H, buf + off, n, o); n1++; if (memcmp(r, o, 24) && fails++ < 8) printf("  one-shot mismatch %s n=%zu\n", chainhash192_backend_name(b[bi]), n);
                chainhash192_stream S; chainhash192_init(&S, &H); size_t i = 0; while (i < n) { size_t c = rnd() % 3 ? 1 + rnd() % 97 : 1 + rnd() % (C192_REGION + 5); if (c > n - i) c = n - i; chainhash192_update(&S, buf + off + i, c); i += c; }
                chainhash192_final(&S, o); ns++; if (memcmp(r, o, 24) && fails++ < 8) printf("  stream mismatch %s n=%zu\n", chainhash192_backend_name(b[bi]), n); } }
        printf("[xcheck] backend %-18s random raw keys %d: %s\n", chainhash192_backend_name(b[bi]), NKEYS, fails > f0 ? "FAIL" : "PASS"); }
    printf("[xcheck] %ld one-shot + %ld streaming vs c192_hash_ref: %s\n", n1, ns, fails ? "FAIL" : "PASS"); return fails != 0; }
