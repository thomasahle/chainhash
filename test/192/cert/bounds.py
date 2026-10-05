#!/usr/bin/env python3
"""bounds.py -- collision numerators and score of ChainHash-192.  q = 2^192, messages of at most 8L bytes (L in 8-byte words).
Level 1 (power key; cert_pk.c): for a differing block the difference is a nonzero polynomial in s with exponent classes
x_i -> s^(2i+2), y_i -> s^(2i+1) (pairs i = 0..87); its degree is <= 2P, P = the highest 1-based pair index that can hold
message bytes.  If only x words can carry data (n <= 192 bytes: the x rows of the first chunk, y = 0 for both messages),
dc = sum dx_i s^(2i+2) = (sum sqrt(dx_i) s^(i+1))^2, so the root count is <= P.  Hence
   d(n) = P(n)        if n <= 192
          2 P(n)      if 192 < n < 4096        (P(n) = 8 G + min(8, ceil((n - 384 G)/8)), G = (n-1) // 384, G <= 10)
          2 * 88      if n >= 4096             (a full block may differ)
Outer (two-level, as ChainHash-256): N(L) = max(d(8L) + E(m) + 1, m' + 1), m = ceil(8L/4096), m' = ceil(m/8),
E(m) = 8 + m' - 1 if m' >= 2 else 2 floor(m/2).
Claim: N(L) <= 2L for every L, equality only at L = 1 -> score min_L log2(L / (N(L)/2^192)) = 191.
Checked for every L < 2^20 and in +-3000 windows around 2^20..2^61."""
import math, sys
BLOCK = 4096
def nblocks(n): return 1 if n == 0 else -(-n // BLOCK)
def P(n):
    G = (n - 1) // 384
    return 8 * G + min(8, -(-(n - 384 * G) // 8))
def d(n):
    if n <= 0: return 1
    if n >= BLOCK: return 176
    return P(n) if n <= 192 else 2 * P(n)
def N(L):
    n = 8 * L; m = nblocks(n); mp = -(-m // 8); E = 8 + mp - 1 if mp >= 2 else 2 * (m // 2)
    return max(d(n) + E + 1, mp + 1)
def Ls():
    for L in range(1, 1 << 20): yield L
    for k in range(20, 62):
        for L in range(max(1, (1 << k) - 3000), (1 << k) + 3000): yield L
# sanity of P against the layout (pairs 80..87 live in the last 256 bytes, rows x0 x1 y0 y1)
assert P(8) == 1 and P(64) == 8 and P(65) == 8 and P(384) == 8 and P(385) == 9 and P(3840) == 80 and P(3841) == 81 and P(3904) == 88 and P(4095) == 88
worst = (1e9, None); bad = 0; eq = []; cnt = 0
for L in Ls():
    n2 = N(L); s = math.log2(L) + 192 - math.log2(n2); cnt += 1
    if s < worst[0]: worst = (s, L)
    if n2 > 2 * L: bad += 1
    if n2 == 2 * L: eq.append(L)
print("ChainHash-192: %d values of L checked; score %.2f (at L=%d); cases N > 2L: %d; N = 2L at L in %s" % (cnt, worst[0], worst[1], bad, eq[:5]))
print("\n| message limit | L | d(8L) | N(L) |"); print("|---|---:|---:|---:|")
for name, nb in (("8 B", 8), ("16 B", 16), ("64 B", 64), ("192 B", 192), ("200 B", 200), ("256 B", 256), ("1 KiB", 1024), ("4 KiB", 4096), ("16 KiB", 16384), ("32 KiB", 32768), ("64 KiB", 65536),
                 ("1 MiB", 1 << 20), ("16 MiB", 16 << 20), ("1 GiB", 1 << 30), ("2^40 bytes", 1 << 40)):
    L = nb // 8; print("| %s | %d | %d | %d |" % (name, L, d(nb), N(L)))
ok = bad == 0 and eq == [1] and abs(worst[0] - 191) < 1e-9
print("\nCLAIM (N <= 2L for all tested L, equality only at L = 1; score 191):", "PASS" if ok else "FAIL")
sys.exit(0 if ok else 1)
