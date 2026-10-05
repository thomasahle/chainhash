/* Key placement for every header: a key initialized in place at a 64-byte-aligned base + 0, 8, ..., 56 and at
 * plain malloc, every backend this machine has, one-shot and streaming (the stream object at the same offsets),
 * against the reference digest; then the key relocated by memcpy to another offset (the 64- and 128-bit keys are
 * values; the v2-family keys stay valid when copied, ChainHash-256's possibly on its portable backend).
 * usage: key_alignment [64|128|128v2|256|512|all] */
#define _DEFAULT_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "chainhash.h"
#include "chainhash128.h"
#include "chainhash128v2.h"
#include "chainhash256.h"
#include "chainhash512.h"

typedef struct {
    const char *name; size_t ksz, ssz, osz; int nbe, be[5];
    void (*init)(void *k, int be);                                   /* key in place at k, for backend be */
    void (*ref)(const void *k, const uint8_t *m, size_t n, uint8_t *o);
    void (*hash)(const void *k, int be, const uint8_t *m, size_t n, uint8_t *o);
    void (*stream)(void *s, const void *k, int be, const uint8_t *m, size_t n, uint8_t *o);   /* stream object at s */
} hdesc;
static const uint64_t SEED = 20261005;

/* ChainHash (64-bit): the key is a value, the backend a per-call choice */
static void i64(void *k, int be) { (void)be; *(chainhash_key *)k = chainhash_key_from_seed(SEED); }
static void r64(const void *k, const uint8_t *m, size_t n, uint8_t *o) { uint64_t h = chainhash_portable((const chainhash_key *)k, m, n); memcpy(o, &h, 8); }
static void h64(const void *k, int be, const uint8_t *m, size_t n, uint8_t *o) { uint64_t h = chainhash_with_backend((const chainhash_key *)k, m, n, be); memcpy(o, &h, 8); }
static void s64(void *s, const void *k, int be, const uint8_t *m, size_t n, uint8_t *o) {
    chainhash_stream *st = (chainhash_stream *)s; uint64_t h; size_t c = n / 3;
    chainhash_init(st, (const chainhash_key *)k, 4, 0, be); chainhash_update(st, m, c); chainhash_update(st, m + c, n - c); h = chainhash_final(st); memcpy(o, &h, 8); }
/* ChainHash-128 */
static void i128(void *k, int be) { (void)be; *(chainhash128_key *)k = chainhash128_key_from_seed(SEED); }
static void r128(const void *k, const uint8_t *m, size_t n, uint8_t *o) { chainhash128_store(o, chainhash128_portable((const chainhash128_key *)k, m, n)); }
static void h128(const void *k, int be, const uint8_t *m, size_t n, uint8_t *o) { chainhash128_store(o, chainhash128_with_backend((const chainhash128_key *)k, m, n, be, ch128_school(be))); }
static void s128(void *s, const void *k, int be, const uint8_t *m, size_t n, uint8_t *o) {
    chainhash128_stream *st = (chainhash128_stream *)s; size_t c = n / 3;
    chainhash128_init(st, (const chainhash128_key *)k, 4, 0, be, ch128_school(be)); chainhash128_update(st, m, c); chainhash128_update(st, m + c, n - c); chainhash128_store(o, chainhash128_final(st)); }
/* ChainHash-128 v2: the backend is a per-call choice */
static void i128v2(void *k, int be) { (void)be; chainhash128v2_key_from_seed((chainhash128v2_key *)k, SEED); }
static void r128v2(const void *k, const uint8_t *m, size_t n, uint8_t *o) { chainhash128_store(o, chainhash128v2_reference((const chainhash128v2_key *)k, m, n)); }
static void h128v2(const void *k, int be, const uint8_t *m, size_t n, uint8_t *o) { chainhash128_store(o, chainhash128v2_with_backend((const chainhash128v2_key *)k, m, n, be)); }
static void s128v2(void *s, const void *k, int be, const uint8_t *m, size_t n, uint8_t *o) {
    chainhash128v2_stream *st = (chainhash128v2_stream *)s; size_t c = n / 3;
    chainhash128v2_init(st, (const chainhash128v2_key *)k, be); chainhash128v2_update(st, m, c); chainhash128v2_update(st, m + c, n - c); chainhash128_store(o, chainhash128v2_final(st)); }
/* ChainHash-256 and -512: the backend is fixed when the key is initialized */
static void i256(void *k, int be) { chainhash256_key_from_seed_with_backend((chainhash256_key *)k, SEED, be); }
static void r256(const void *k, const uint8_t *m, size_t n, uint8_t *o) { chainhash256_reference((const chainhash256_key *)k, m, n, o); }
static void h256(const void *k, int be, const uint8_t *m, size_t n, uint8_t *o) { (void)be; chainhash256((const chainhash256_key *)k, m, n, o); }
static void s256(void *s, const void *k, int be, const uint8_t *m, size_t n, uint8_t *o) {
    chainhash256_stream *st = (chainhash256_stream *)s; size_t c = n / 3; (void)be;
    chainhash256_init(st, (const chainhash256_key *)k); chainhash256_update(st, m, c); chainhash256_update(st, m + c, n - c); chainhash256_final(st, o); }
static void i512(void *k, int be) { chainhash512_key_from_seed_with_backend((chainhash512_key *)k, SEED, be); }
static void r512(const void *k, const uint8_t *m, size_t n, uint8_t *o) { chainhash512_reference((const chainhash512_key *)k, m, n, o); }
static void h512(const void *k, int be, const uint8_t *m, size_t n, uint8_t *o) { (void)be; chainhash512((const chainhash512_key *)k, m, n, o); }
static void s512(void *s, const void *k, int be, const uint8_t *m, size_t n, uint8_t *o) {
    chainhash512_stream *st = (chainhash512_stream *)s; size_t c = n / 3; (void)be;
    chainhash512_init(st, (const chainhash512_key *)k); chainhash512_update(st, m, c); chainhash512_update(st, m + c, n - c); chainhash512_final(st, o); }

static hdesc H[5];
static int nh;
static void add(hdesc d, int (*has)(int), int lo, int hi) {
    int b; d.nbe = 0;
    for (b = lo; b <= hi; b++) if (has(b)) d.be[d.nbe++] = b;
    H[nh++] = d;
}
static int has128v2(int b) { return b != 2 && chainhash128v2_has_backend(b); }

static uint8_t *msg;
static uint8_t *amalloc(size_t n) { void *p = 0; if (posix_memalign(&p, 64, (n + 63) / 64 * 64)) { puts("posix_memalign failed"); exit(2); } return (uint8_t *)p; }
static long checks, fails;
static void expect(const uint8_t *want, const uint8_t *got, size_t osz, const hdesc *d, int be, const char *what, int off, size_t n) {
    checks++;
    if (memcmp(want, got, osz)) { if (fails++ < 10) printf("  MISMATCH %s backend %d %s key at %s%d n %zu\n", d->name, be, what, off < 0 ? "malloc" : "64k+", off < 0 ? 0 : off, n); }
}
static void run(const hdesc *d) {
    static const size_t lens[] = {0, 1, 3, 15, 16, 17, 63, 64, 65, 127, 128, 129, 255, 256, 1000, 1024, 4095, 4096, 4097,
                                  16383, 16384, 16385, 32768, 65536 + 4096 + 5, 3 * 32768 + 999};
    enum { NL = sizeof lens / sizeof lens[0] };
    uint8_t ref[NL][64], o[64];
    size_t i; int bi, off;
    uint8_t *kb = amalloc(d->ksz + 64), *kb2 = amalloc(d->ksz + 64), *sb = amalloc(d->ssz + 64);
    long f0 = fails, c0 = checks;
    d->init(kb, 0);                                                     /* the reference (portable backend), 64-byte aligned */
    for (i = 0; i < NL; i++) d->ref(kb, msg, lens[i], ref[i]);
    for (bi = 0; bi < d->nbe; bi++) {
        int be = d->be[bi];
        for (off = -1; off < 64; off += off < 0 ? 1 : 8) {             /* off = -1: plain malloc */
            uint8_t *mk = off < 0 ? (uint8_t *)malloc(d->ksz) : 0, *ms = off < 0 ? (uint8_t *)malloc(d->ssz) : 0;
            void *k = off < 0 ? (void *)mk : (void *)(kb + off), *s = off < 0 ? (void *)ms : (void *)(sb + off), *k2;
            int off2 = ((off < 0 ? 0 : off) * 3 + 24) & 56;
            size_t lmax = be == 0 ? 20000 : (size_t)-1;                  /* the portable backends: the shorter lengths */
            if (off < 0 && (!mk || !ms)) { puts("malloc failed"); exit(2); }
            d->init(k, be);
            for (i = 0; i < NL; i++) if (lens[i] <= lmax) {
                d->hash(k, be, msg, lens[i], o); expect(ref[i], o, d->osz, d, be, "one-shot", off, lens[i]);
                d->stream(s, k, be, msg, lens[i], o); expect(ref[i], o, d->osz, d, be, "stream", off, lens[i]);
            }
            k2 = kb2 + off2; memcpy(k2, k, d->ksz); memset(k, 0xA5, d->ksz);   /* relocated (and the original wiped) */
            for (i = 0; i < NL; i++) if (lens[i] <= lmax) { d->hash(k2, be, msg, lens[i], o); expect(ref[i], o, d->osz, d, be, "relocated", off2, lens[i]); }
            free(mk); free(ms);
        }
    }
    printf("  %-6s backends", d->name); for (bi = 0; bi < d->nbe; bi++) printf(" %d", d->be[bi]);
    printf(": %ld checks, %ld mismatches\n", checks - c0, fails - f0);
    free(kb); free(kb2); free(sb);
}
int main(int argc, char **argv) {
    const char *only = argc > 1 ? argv[1] : "all";
    size_t N = 3 * 32768 + 999, i; int h, ran = 0;
    msg = (uint8_t *)malloc(N); for (i = 0; i < N; i++) msg[i] = (uint8_t)(i * 167 + 13);
    { hdesc d = {"64", sizeof(chainhash_key), sizeof(chainhash_stream), 8, 0, {0}, i64, r64, h64, s64}; add(d, chainhash_has_backend, 0, 4); }
    { hdesc d = {"128", sizeof(chainhash128_key), sizeof(chainhash128_stream), 16, 0, {0}, i128, r128, h128, s128}; add(d, chainhash128_has_backend, 0, 4); }
    { hdesc d = {"128v2", sizeof(chainhash128v2_key), sizeof(chainhash128v2_stream), 16, 0, {0}, i128v2, r128v2, h128v2, s128v2}; add(d, has128v2, 0, 4); }
    { hdesc d = {"256", sizeof(chainhash256_key), sizeof(chainhash256_stream), 32, 0, {0}, i256, r256, h256, s256}; add(d, chainhash256_has_backend, 0, 3); }
    { hdesc d = {"512", sizeof(chainhash512_key), sizeof(chainhash512_stream), 64, 0, {0}, i512, r512, h512, s512}; add(d, chainhash512_has_backend, 0, 3); }
    for (h = 0; h < nh; h++) if (!strcmp(only, "all") || !strcmp(only, H[h].name)) { run(&H[h]); ran++; }
    if (!ran) { printf("unknown header %s\n", only); return 2; }
    printf("key placement (%s: keys and streams at 64k+0..56 and malloc, relocated keys, every backend): %ld checks, %ld mismatches -> %s\n",
           only, checks, fails, fails ? "FAIL" : "PASS");
    free(msg);
    return fails != 0;
}
