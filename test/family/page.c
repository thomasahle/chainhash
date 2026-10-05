/* Page-edge test for ChainHash-128 v2, -256, -512 and -192: inputs that end at the last byte before an unmapped page
 * or start at the first byte after one (the short-input paths use masked or overlapping loads), n = 0..2100,
 * every backend this machine has (explicitly selected) against the bit-serial reference. POSIX (mmap). */
#define _DEFAULT_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include "chainhash128v2.h"
#include "chainhash256.h"
#include "chainhash512.h"
#include "chainhash192.h"
static chainhash128v2_key K1;
static chainhash256_key K2[5];
static chainhash512_key K3[5];
static chainhash192_key K4[5];
static const char *const NAME[] = {"portable", "pclmul-sse4.1", "avx512-vpclmulqdq", "neon-pmull"};
static const char *const NAME128[] = {"portable", "xmm", "?", "zmm", "neon"};
int main(void) {
    long pg = sysconf(_SC_PAGESIZE); size_t span = 4 * (size_t)pg, n; int b, nb, bk[5], i;
    uint8_t *m = mmap(0, 3 * span, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (m == MAP_FAILED) { puts("mmap failed"); return 2; }
    uint8_t *mid = m + span;                                  /* [guard][data][guard] */
    mprotect(m, span, PROT_NONE); mprotect(m + 2 * span, span, PROT_NONE);
    for (i = 0; (size_t)i < span; i++) mid[i] = (uint8_t)(i * 151 + 3);
    long tot = 0, bad = 0;

    /* ChainHash-128 v2: one key; the backend is chosen per call */
    chainhash128v2_key_from_seed(&K1, 2026);
    for (n = 0; n <= 2100; n++) for (i = 0; i < 2; i++) {
        const uint8_t *p = i ? mid + span - n : mid;
        ch128_word r = chainhash128v2_reference(&K1, p, n);
        for (b = 1; b <= 4; b++) if (b != 2 && chainhash128v2_has_backend(b)) {
            ch128_word g = chainhash128v2_with_backend(&K1, p, n, b); tot++;
            if (memcmp(&r, &g, sizeof r)) { if (bad < 5) printf("MISMATCH 128v2 %s n=%zu end=%d\n", NAME128[b], n, i); bad++; } } }

    /* ChainHash-256: one key per backend */
    nb = 0; for (b = 0; b < 4; b++) if (chainhash256_has_backend(b)) { chainhash256_key_from_seed_with_backend(&K2[nb], 2026, b); bk[nb++] = b; }
    for (n = 0; n <= 2100; n++) for (i = 0; i < 2; i++) {
        const uint8_t *p = i ? mid + span - n : mid; uint8_t r[32], g[32];
        chainhash256_reference(&K2[0], p, n, r);
        for (b = 1; b < nb; b++) { chainhash256(&K2[b], p, n, g); tot++;
            if (memcmp(r, g, 32)) { if (bad < 5) printf("MISMATCH 256 %s n=%zu end=%d\n", NAME[bk[b]], n, i); bad++; } } }

    /* ChainHash-512: one key per backend */
    nb = 0; for (b = 0; b < 4; b++) if (chainhash512_has_backend(b)) { chainhash512_key_from_seed_with_backend(&K3[nb], 2026, b); bk[nb++] = b; }
    for (n = 0; n <= 2100; n++) for (i = 0; i < 2; i++) {
        const uint8_t *p = i ? mid + span - n : mid; uint8_t r[64], g[64];
        chainhash512_reference(&K3[0], p, n, r);
        for (b = 1; b < nb; b++) { chainhash512(&K3[b], p, n, g); tot++;
            if (memcmp(r, g, 64)) { if (bad < 5) printf("MISMATCH 512 %s n=%zu end=%d\n", NAME[bk[b]], n, i); bad++; } } }

    /* ChainHash-192: one key per backend */
    nb = 0; for (b = 0; b < 4; b++) if (chainhash192_has_backend(b)) { chainhash192_key_from_seed_with_backend(&K4[nb], 2026, b); bk[nb++] = b; }
    for (n = 0; n <= 2100; n++) for (i = 0; i < 2; i++) {
        const uint8_t *p = i ? mid + span - n : mid; uint8_t r[24], g[24];
        chainhash192_reference(&K4[0], p, n, r);
        for (b = 1; b < nb; b++) { chainhash192(&K4[b], p, n, g); tot++;
            if (memcmp(r, g, 24)) { if (bad < 5) printf("MISMATCH 192 %s n=%zu end=%d\n", NAME[bk[b]], n, i); bad++; } } }

    printf("page-edge (128v2, 256, 512, 192; n = 0..2100 at both guard pages): %ld hashes, %ld mismatches -> %s\n", tot, bad, bad ? "FAIL" : "PASS");
    return bad != 0;
}
