/* align.c -- the expanded key at any alignment: initialized in place at malloc + off and memcpy'd (relocated) to
 * malloc + off2, for off, off2 in 0..63 (multiples of 8 are well-defined C; the others are tested because they work on
 * x86-64 and AArch64), every backend this host has, lengths 0..700 and edges up to 3 regions, one-shot and streaming,
 * against the reference.  Also the key in a 4 KiB page right before a PROT_NONE page is not needed: the key is data. */
#include "chainhash192.h"
#include <stdio.h>
#include <stdlib.h>
static int fails, checks;
static void check(const chainhash192_key *k, const chainhash192_key *ref, const uint8_t *m, size_t n, const char *what, int off) {
    uint8_t a[24], b[24]; chainhash192(k, m, n, a); chainhash192_reference(ref, m, n, b); checks++;
    if (memcmp(a, b, 24)) { if (fails++ < 10) printf("FAIL %s off %d n %zu backend %d\n", what, off, n, chainhash192_key_backend(k)); }
    chainhash192_stream s; chainhash192_init(&s, k); size_t c = n / 3; chainhash192_update(&s, m, c); chainhash192_update(&s, m + c, n - c); chainhash192_final(&s, a); checks++;
    if (memcmp(a, b, 24)) { if (fails++ < 10) printf("FAIL stream %s off %d n %zu\n", what, off, n); } }
int main(void) {
    size_t N = 3 * 32768 + 1000; uint8_t *m = malloc(N); for (size_t i = 0; i < N; i++) m[i] = (uint8_t)(i * 167 + 13);
    size_t lens[] = {0, 1, 3, 4, 15, 16, 17, 31, 63, 64, 65, 383, 384, 385, 4095, 4096, 4097, 32767, 32768, 32769, 65536 + 4096 + 5, 3 * 32768 + 999};
    int nb = 0;
    for (int be = 0; be < 4; be++) { if (!chainhash192_has_backend(be)) continue; nb++;
        uint8_t *buf = malloc(sizeof(chainhash192_key) + 64), *buf2 = malloc(sizeof(chainhash192_key) + 64);
        chainhash192_key *ref = malloc(sizeof *ref); chainhash192_key_from_seed_with_backend(ref, 77, CH192_PORTABLE);
        for (int off = 0; off < 64; off += (be == 0 ? 8 : 1)) {
            chainhash192_key *k = (chainhash192_key *)(void *)(buf + off); chainhash192_key_from_seed_with_backend(k, 77, be);
            if (chainhash192_key_backend(k) != be) { printf("backend %d not taken\n", be); return 1; }
            for (size_t i = 0; i < sizeof lens / sizeof lens[0]; i++) check(k, ref, m + (off & 7), lens[i], "in place", off);
            for (size_t n = 0; n <= 700; n += 7) check(k, ref, m, n, "in place", off);
            int off2 = (off * 37 + 11) & 63; chainhash192_key *k2 = (chainhash192_key *)(void *)(buf2 + off2); memcpy(k2, k, sizeof *k);
            for (size_t i = 0; i < sizeof lens / sizeof lens[0]; i++) check(k2, ref, m, lens[i], "relocated", off2); }
        free(buf); free(buf2); free(ref); }
    printf("[align] %d backends, %d checks, %d failures -> %s\n", nb, checks, fails, fails ? "FAIL" : "PASS"); return fails != 0; }
