/* cert_pk.c -- ChainHash-192 level 1 (power key), certified on the AS-BUILT reference: the header's C192_DERIVE +
 * c192_block_ref applied to a 4096-byte block.  The block value as a function of the key s,
 *     c(s) = sum_{i=0}^{87} (x_i + s^(2i+1)) (y_i + s^(2i+2)),
 * is interpolated as a polynomial in s over GF(2^192) (352 nodes, degree <= 351; checked at 8 more nodes) and must equal
 *     c(s) = sum_i x_i y_i  +  sum_i ( x_i s^(2i+2) + y_i s^(2i+1) )  +  sum_i s^(4i+3)        (exponent classes)
 * where x_i, y_i are read from the bytes by THIS file's own reading of SPEC-192 section 3 (chunks of 8 pairs, rows
 * x0 x1 x2 y0 y1 y2; the last 256 bytes: rows x0 x1 y0 y1 with zero top limbs) -- so the as-built byte layout is
 * certified too.  Every data word therefore owns an exponent in 1..176 and all data x data terms sit at s^0.
 * Adversarial differences (single words at the first / middle / last positions of x and y rows, in chunk 0, 5, 9 and the
 * last chunk; a full pair; several pairs; dense; x-only with y = 0) must give a nonzero difference polynomial of degree
 * <= 176 with the predicted coefficient; the 1-word difference (word 0, the rest zero) must be exactly dw s^2.
 * Negative control (-DNEG): a derivation with colliding exponents (l_j = k_j) must be rejected.
 * -DDUMP: print 300 field products "a b c" (hex, limb 2 first) for oracle.py's independent check of c192_mul. */
#include <stdio.h>
#include "chainhash192.h"
static uint64_t rs = 77; static uint64_t rnd(void) { return c192_splitmix(&rs); }
static c192_el rel(void) { c192_el e; for (int i = 0; i < 3; i++) e.w[i] = rnd(); return e; }
static int eq(c192_el a, c192_el b) { return !memcmp(&a, &b, sizeof a); }
static int iszero(c192_el a) { return c192_iszero(a); }
static c192_el inv(c192_el a) { c192_el r = {{1, 0, 0}}, b = a; for (int i = 1; i < 192; i++) { b = c192_mul(b, b); r = c192_mul(r, b); } return r; }   /* a^(2^192-2) */
#define NP 88
#define N (4 * NP)
#define NMAX (N + 8)
/* fixed nodes xs[0..N+7]; Newton divided differences need 1/(x_i - x_{i-j}): one batch inversion per level j */
static c192_el xs[NMAX], *invd[N];
static c192_key *Knode;
static void interp_setup(void) {
    for (int j = 1; j < N; j++) { int m = N - j; c192_el *den = malloc(m * sizeof(c192_el)), *pre = malloc(m * sizeof(c192_el)); invd[j] = malloc(m * sizeof(c192_el));
        for (int i = 0; i < m; i++) den[i] = c192_xor(xs[j + i], xs[i]);
        pre[0] = den[0]; for (int i = 1; i < m; i++) pre[i] = c192_mul(pre[i - 1], den[i]);
        c192_el t = inv(pre[m - 1]);
        for (int i = m - 1; i > 0; i--) { invd[j][i] = c192_mul(t, pre[i - 1]); t = c192_mul(t, den[i]); } invd[j][0] = t;
        for (int i = 0; i < m; i++) if (!(c192_mul(invd[j][i], den[i]).w[0] == 1 && !c192_mul(invd[j][i], den[i]).w[1] && !c192_mul(invd[j][i], den[i]).w[2])) { printf("inverse table broken\n"); exit(2); }
        free(den); free(pre); } }
static void interp(const c192_el *v, c192_el *c) {
    static c192_el d[NMAX], t[NMAX]; for (int i = 0; i < N; i++) d[i] = v[i];
    for (int j = 1; j < N; j++) for (int i = N - 1; i >= j; i--) d[i] = c192_mul(c192_xor(d[i], d[i - 1]), invd[j][i - j]);
    for (int i = 0; i < N; i++) c[i] = (c192_el){{0, 0, 0}};
    for (int j = N - 1; j >= 0; j--) { for (int i = 0; i < N; i++) t[i] = (c192_el){{0, 0, 0}};
        for (int i = 0; i < N - 1; i++) { t[i + 1] = c192_xor(t[i + 1], c[i]); t[i] = c192_xor(t[i], c192_mul(c[i], xs[j])); }
        t[0] = c192_xor(t[0], d[j]); for (int i = 0; i < N; i++) c[i] = t[i]; } }
static c192_el peval(const c192_el *c, int n, c192_el x) { c192_el r = {{0, 0, 0}}; for (int i = n - 1; i >= 0; i--) r = c192_xor(c192_mul(r, x), c[i]); return r; }
static int fails = 0, checks = 0;
static c192_el mul_(c192_el a, c192_el b) { return c192_mul(a, b); }
#define CHECK(cond, ...) do { checks++; if (!(cond)) { fails++; if (fails < 8) { printf("  FAIL: " __VA_ARGS__); printf("\n"); } } } while (0)
/* this file's own reading of the layout: byte offset of word (pair i, slot j: 0..2 = x limbs, 3..5 = y limbs), -1 if absent */
static int woff(int i, int j) { int g = i / 8, t = i % 8;
    if (g < 10) return 384 * g + 64 * j + 8 * t;
    if (j == 2 || j == 5) return -1;                                   /* the last chunk's pairs have zero top limbs */
    int row = j < 3 ? j : 2 + (j - 3); return 3840 + 64 * row + 8 * t; }
static void put(uint8_t *blk, const c192_el *x, const c192_el *y) {
    memset(blk, 0, 4096);
    for (int i = 0; i < NP; i++) for (int j = 0; j < 6; j++) { int o = woff(i, j); uint64_t w = j < 3 ? x[i].w[j] : y[i].w[j - 3]; if (o >= 0) memcpy(blk + o, &w, 8); } }
static void get(const uint8_t *blk, c192_el *x, c192_el *y) {     /* zero top limbs where absent */
    for (int i = 0; i < NP; i++) for (int j = 0; j < 6; j++) { int o = woff(i, j); uint64_t w = 0; if (o >= 0) memcpy(&w, blk + o, 8); if (j < 3) x[i].w[j] = w; else y[i].w[j - 3] = w; } }
/* the as-built key derivation at every node (C192_DERIVE with the reference multiply; -DNEG: colliding exponents) */
static void keys_setup(void) {
    Knode = malloc(NMAX * sizeof(c192_key));
    for (int i = 0; i < N + 8; i++) { c192_el s = xs[i]; c192_raw R; memset(&R, 0, sizeof R); R.s = s; R.y = (c192_el){{1, 0, 0}};
#ifdef NEG
        c192_el p = s; for (int j = 0; j < NP; j++) { Knode[i].k[j] = p; Knode[i].l[j] = p; p = c192_mul(c192_mul(p, s), s); }   /* broken: l_j = k_j */
#else
        C192_DERIVE(&R, &Knode[i], mul_);
#endif
    } }
/* the as-built block values at all nodes */
static void vals(const uint8_t *blk, c192_el *v) { for (int i = 0; i < N + 8; i++) v[i] = c192_block_ref(&Knode[i], blk); }
static void fit(const c192_el *v, c192_el *c) { interp(v, c); for (int i = N; i < N + 8; i++) CHECK(eq(peval(c, N, xs[i]), v[i]), "degree > %d", N - 1); }
static void poly(const uint8_t *blk, c192_el *c) { static c192_el v[NMAX]; vals(blk, v); fit(v, c); }
static int diffpoly(const uint8_t *a, const uint8_t *b, c192_el *d) {    /* d = poly(a) - poly(b) (linear in the values); 1 if nonzero */
    static c192_el va[NMAX], vb[NMAX]; vals(a, va); vals(b, vb); for (int i = 0; i < N + 8; i++) va[i] = c192_xor(va[i], vb[i]);
    fit(va, d); int nz = 0; for (int e = 0; e < N; e++) if (!iszero(d[e])) nz = 1; return nz; }
int main(void) {
#ifdef DUMP
    for (int t = 0; t < 300; t++) { c192_el a = rel(), b = rel(); if (t < 4) { memset(&a, 0, sizeof a); a.w[2] = 1ULL << 63; } c192_el c = c192_mul(a, b);
        for (int i = 0; i < 3; i++) printf("%016llx", (unsigned long long)a.w[2 - i]); printf(" ");
        for (int i = 0; i < 3; i++) printf("%016llx", (unsigned long long)b.w[2 - i]); printf(" ");
        for (int i = 0; i < 3; i++) printf("%016llx", (unsigned long long)c.w[2 - i]); printf("\n"); }
    return 0;
#endif
    for (int i = 0; i < N + 8; i++) xs[i] = rel();
    interp_setup(); keys_setup();
    printf("[ChainHash-192] power-key level-1 certificate on the as-built reference (C192_DERIVE + c192_block_ref), %d pairs, degree <= %d\n", NP, N - 1);
    static c192_el x[NP], y[NP], c[NMAX], d[NMAX], want[NMAX]; static uint8_t A[4096], B[4096];
    for (int t = 0; t < 2; t++) {
        for (int i = 0; i < 4096; i++) A[i] = (uint8_t)rnd();
        get(A, x, y); poly(A, c);
        for (int e = 0; e < N; e++) want[e] = (c192_el){{0, 0, 0}};
        for (int i = 0; i < NP; i++) { want[0] = c192_xor(want[0], c192_mul(x[i], y[i])); want[2 * i + 2] = c192_xor(want[2 * i + 2], x[i]); want[2 * i + 1] = c192_xor(want[2 * i + 1], y[i]); want[4 * i + 3].w[0] ^= 1; }
        for (int e = 0; e < N; e++) CHECK(eq(c[e], want[e]), "coefficient of s^%d differs from the exponent-class expansion", e); }
    printf("  exact expansion on random blocks (all 512 words, this file's layout reading): %s\n", fails ? "FAIL" : "PASS");
    int base = checks;
    int pairs[] = {0, 1, 7, 8, 40, 47, 72, 79, 80, 83, 87};
    for (unsigned pi = 0; pi < sizeof pairs / sizeof *pairs; pi++) { int i = pairs[pi];
        for (int j = 0; j < 6; j++) { int o = woff(i, j); if (o < 0) continue;
            for (int k = 0; k < 4096; k++) A[k] = B[k] = (uint8_t)rnd();
            uint64_t dw = rnd() | 1, w; memcpy(&w, B + o, 8); w ^= dw; memcpy(B + o, &w, 8);
            CHECK(diffpoly(A, B, d), "pair %d slot %d: difference polynomial is zero", i, j);
            int e = j < 3 ? 2 * i + 2 : 2 * i + 1; c192_el dv = {{0, 0, 0}}; dv.w[j % 3] = dw;
            CHECK(eq(d[e], dv), "pair %d slot %d: coefficient of s^%d is not the word difference at limb %d", i, j, e, j % 3);
            for (int e2 = 177; e2 < N; e2++) CHECK(iszero(d[e2]), "pair %d slot %d: difference above s^176", i, j); } }
    { for (int k = 0; k < 4096; k++) A[k] = B[k] = (uint8_t)rnd(); for (int j = 0; j < 6; j++) { int o = woff(40, j); if (o >= 0) B[o] ^= 0x5a; }
      CHECK(diffpoly(A, B, d), "full pair: zero difference"); }
    { for (int k = 0; k < 4096; k++) A[k] = B[k] = (uint8_t)rnd(); for (int k = 0; k < 4096; k += 517) B[k] ^= 0xa5; CHECK(diffpoly(A, B, d), "several words: zero difference"); }
    { for (int k = 0; k < 4096; k++) { A[k] = (uint8_t)rnd(); B[k] = (uint8_t)rnd(); } CHECK(diffpoly(A, B, d), "dense: zero difference"); }
    { memset(A, 0, 4096); memset(B, 0, 4096); for (int k = 0; k < 192; k++) { A[k] = (uint8_t)rnd(); B[k] = (uint8_t)rnd(); }
      int nz = diffpoly(A, B, d); CHECK(nz, "x-only (192 bytes): zero difference"); int odd = 0; for (int e = 1; e < N; e += 2) if (!iszero(d[e])) odd = 1;
      CHECK(!odd && iszero(d[0]), "x-only: the difference has odd or constant terms (must be a square: sum dx_i s^(2i+2))"); }
    printf("  adversarial differences (single words at pairs 1,2,8,9,41,48,73,80,81,84,88 every slot; full pair; several; dense; x-only): %s [%d checks]\n", fails ? "FAIL" : "PASS", checks - base);
    { memset(A, 0, 4096); memset(B, 0, 4096); uint64_t dw = rnd() | 1; memcpy(B, &dw, 8);
      diffpoly(A, B, d); int only = 1; for (int e = 0; e < N; e++) { if (e == 2) CHECK(d[e].w[0] == dw && !d[e].w[1] && !d[e].w[2], "1-word: s^2 coefficient"); else if (!iszero(d[e])) only = 0; }
      CHECK(only, "1-word difference is not the monomial dw s^2");
      printf("  1-word difference (word 0 = x limb 0 of pair 0, the rest zero) = dw * s^2 exactly -> one root (s = 0): d(1) = 1: %s\n", only ? "PASS" : "FAIL"); }
    printf("checks %d, failures %d\n%s\n", checks, fails, fails ? "CERT PK FAIL" : "CERT PK PASS: power-key exponent classes are distinct (x_i -> s^(2i+2), y_i -> s^(2i+1)), data x data at s^0; degree <= 176; d(1) = 1");
    return fails != 0; }
