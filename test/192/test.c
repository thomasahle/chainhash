/* test.c -- ChainHash-192 conformance: every compiled backend against the normative reference (c192_hash_ref), one-shot
 * and streaming (random split points; a 1-byte dribble on a subset), lengths 0..700, every chunk / block / region edge
 * +-1, multi-region lengths, offsets 0/1/3/7, two seed keys and the raw key R (as bytes and as words), the frozen
 * vectors, and PROT_NONE page edges (a message ending at a guard page and one starting right after one).
 * Exit status 0 iff everything passes.  usage: test [vectors.txt] */
#define _DEFAULT_SOURCE   /* MAP_ANON under -std=c99 (glibc) */
#include "chainhash192.h"
#include <stdio.h>
#if defined(__unix__) || defined(__APPLE__)
#include <sys/mman.h>
#include <unistd.h>
#define HAVE_MMAP 1
#endif
static uint64_t rs = 0x243F6A8885A308D3ull; static uint64_t rnd(void) { return c192_splitmix(&rs); }
static long fails = 0, checks = 0;
#define CHECK(c, ...) do { checks++; if (!(c)) { if (fails++ < 12) { printf("  FAIL: " __VA_ARGS__); printf("\n"); } } } while (0)
static int backends(int *list) { int n = 0, b[4] = {CH192_PORTABLE, CH192_PCLMUL, CH192_AVX512, CH192_NEON}; for (int i = 0; i < 4; i++) if (chainhash192_has_backend(b[i])) list[n++] = b[i]; return n; }
static void stream_hash(const chainhash192_key *k, const uint8_t *m, size_t n, int mode, uint8_t out[24]) {
    chainhash192_stream s; chainhash192_init(&s, k); size_t i = 0;
    while (i < n) { size_t c = mode == 1 ? 1 : (rnd() % 3 ? 1 + rnd() % 997 : 1 + rnd() % (C192_REGION + 5)); if (c > n - i) c = n - i; chainhash192_update(&s, m + i, c); i += c; }
    chainhash192_final(&s, out); }
int main(int argc, char **argv) {
    const char *vec = argc > 1 ? argv[1] : "vectors.txt";
    size_t maxn = 4 * C192_REGION + 3 * C192_BLOCK + 1000; uint8_t *buf = malloc(maxn + 64); for (size_t i = 0; i < maxn + 64; i++) buf[i] = (uint8_t)rnd();
    int be[4], nb = backends(be);
    printf("[test] backends:"); for (int i = 0; i < nb; i++) printf(" %s", chainhash192_backend_name(be[i])); printf(" (best %s)\n", chainhash192_backend_name(chainhash192_backend()));
    static size_t lens[4096]; int nl = 0;
    for (size_t n = 0; n <= 700; n++) lens[nl++] = n;
    size_t base[] = {768, 1024, 1152, 1536, 1920, 2048, 2304, 2688, 3072, 3456, 3840, 3904, 3968, 4032, 4096, 8192, 12288, 16384, 20480, 24576, 28672, 32768, 36864, 65536, 69632, 98304, 131072, 135168};
    for (size_t i = 0; i < sizeof base / sizeof *base; i++) for (int d = -1; d <= 1; d++) lens[nl++] = base[i] + d;
    for (int i = 0; i < 40; i++) lens[nl++] = rnd() % maxn;
    lens[nl++] = maxn;
    static chainhash192_key R, K;
    for (int key = 0; key < 3; key++) {
        uint8_t raw[216]; uint64_t w[27]; for (int i = 0; i < 216; i++) raw[i] = (uint8_t)(73 * i + 11);
        for (int i = 0; i < 27; i++) { w[i] = 0; for (int j = 0; j < 8; j++) w[i] |= (uint64_t)raw[8 * i + j] << (8 * j); }
        if (key < 2) chainhash192_key_from_seed_with_backend(&R, 1 + 77 * key, CH192_PORTABLE); else chainhash192_key_from_bytes_with_backend(&R, raw, CH192_PORTABLE);
        for (int bi = 0; bi < nb; bi++) { long f0 = fails, c0 = checks;
            if (key < 2) chainhash192_key_from_seed_with_backend(&K, 1 + 77 * key, be[bi]);
            else if (bi & 1) chainhash192_key_from_words_with_backend(&K, w, be[bi]); else chainhash192_key_from_bytes_with_backend(&K, raw, be[bi]);
            CHECK(chainhash192_key_backend(&K) == be[bi], "backend %d not selected", be[bi]);
            for (int li = 0; li < nl; li++) { size_t n = lens[li], off = (size_t)((li * 5 + key) & 7); if (off == 5) off = 7; else if (off > 3) off = off & 1 ? 3 : 1; else off = 0;
                if (n + off > maxn) off = 0;
                uint8_t r[24], o[24]; chainhash192_reference(&R, buf + off, n, r);
                chainhash192(&K, buf + off, n, o); CHECK(!memcmp(r, o, 24), "%s key %d one-shot n=%zu off=%zu", chainhash192_backend_name(be[bi]), key, n, off);
                stream_hash(&K, buf + off, n, 0, o); CHECK(!memcmp(r, o, 24), "%s key %d stream n=%zu off=%zu", chainhash192_backend_name(be[bi]), key, n, off);
                if (li % 23 == 0 && n <= 70000) { stream_hash(&K, buf + off, n, 1, o); CHECK(!memcmp(r, o, 24), "%s key %d dribble n=%zu", chainhash192_backend_name(be[bi]), key, n); } }
            printf("[test] key %d (%s) backend %-18s %ld checks: %s\n", key, key < 2 ? "seed" : (bi & 1 ? "raw words" : "raw bytes"), chainhash192_backend_name(be[bi]), checks - c0, fails > f0 ? "FAIL" : "PASS"); } }
    /* frozen vectors: lines "key n digest", message m[j] = (137 j + 29) mod 256 */
    { FILE *fv = fopen(vec, "r"); long nv = 0, f0 = fails; size_t vmax = 200000; uint8_t *m = malloc(vmax); for (size_t j = 0; j < vmax; j++) m[j] = (uint8_t)(137 * j + 29);
      if (!fv) { printf("[test] FAIL: cannot open %s\n", vec); fails++; }
      else { char ks[16], dh[64]; size_t n; uint8_t raw[216]; for (int i = 0; i < 216; i++) raw[i] = (uint8_t)(73 * i + 11);
        while (fscanf(fv, "%15s %zu %63s", ks, &n, dh) == 3) { if (n > vmax) continue; uint8_t want[24]; for (int i = 0; i < 24; i++) { unsigned v; sscanf(dh + 2 * i, "%2x", &v); want[i] = (uint8_t)v; }
            for (int bi = 0; bi < nb; bi++) { if (ks[0] == 'R') chainhash192_key_from_bytes_with_backend(&K, raw, be[bi]); else chainhash192_key_from_seed_with_backend(&K, strtoull(ks, 0, 10), be[bi]);
                uint8_t o[24]; chainhash192(&K, m, n, o); CHECK(!memcmp(o, want, 24), "vector %s %zu backend %s", ks, n, chainhash192_backend_name(be[bi]));
                if (bi == 0) { chainhash192_reference(&K, m, n, o); CHECK(!memcmp(o, want, 24), "vector %s %zu reference", ks, n); } nv++; } }
        fclose(fv); }
      printf("[test] frozen vectors (%s): %ld backend checks: %s\n", vec, nv, fails > f0 ? "FAIL" : "PASS"); free(m); }
#ifdef HAVE_MMAP
    /* page edges: no read past the end, none before the start */
    { long f0 = fails; size_t pg = (size_t)sysconf(_SC_PAGESIZE), span = 3 * C192_REGION + 4 * pg;
      uint8_t *mp = mmap(0, span + 2 * pg, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANON, -1, 0);
      if (mp != MAP_FAILED) { uint8_t *lo = mp, *hi = mp + pg + span; mprotect(lo, pg, PROT_NONE); mprotect(hi, pg, PROT_NONE);
        uint8_t *data = mp + pg; for (size_t i = 0; i < span; i++) data[i] = (uint8_t)rnd();
        size_t pe[] = {0, 1, 7, 8, 15, 16, 17, 31, 33, 63, 64, 65, 100, 191, 192, 193, 255, 256, 257, 383, 384, 385, 1000, 3839, 3840, 3841, 3967, 3968, 4031, 4095, 4096, 4097, 5000, 8191, 8193, 32767, 32768, 32769, 40000, 65537, 3 * C192_REGION + 4 * pg};
        chainhash192_key_from_seed_with_backend(&R, 99, CH192_PORTABLE);
        for (int bi = 0; bi < nb; bi++) { chainhash192_key_from_seed_with_backend(&K, 99, be[bi]);
            for (size_t i = 0; i < sizeof pe / sizeof *pe; i++) { size_t n = pe[i]; if (n > span) continue; uint8_t r[24], o[24];
                const uint8_t *end = data + span - n; chainhash192_reference(&R, end, n, r); chainhash192(&K, end, n, o); CHECK(!memcmp(r, o, 24), "page end %s n=%zu", chainhash192_backend_name(be[bi]), n);
                stream_hash(&K, end, n, 0, o); CHECK(!memcmp(r, o, 24), "page end stream %s n=%zu", chainhash192_backend_name(be[bi]), n);
                chainhash192_reference(&R, data, n, r); chainhash192(&K, data, n, o); CHECK(!memcmp(r, o, 24), "page start %s n=%zu", chainhash192_backend_name(be[bi]), n); } }
        munmap(mp, span + 2 * pg); }
      printf("[test] page edges (PROT_NONE guards on both sides): %s\n", fails > f0 ? "FAIL" : "PASS"); }
#endif
    printf("[test] %ld checks, %ld failures -> %s\n", checks, fails, fails ? "FAIL" : "PASS");
    return fails != 0; }
