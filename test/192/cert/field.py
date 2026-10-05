#!/usr/bin/env python3
"""field.py -- field certificate for ChainHash-192: f = x^192 + x^7 + x^2 + x + 1 is irreducible over GF(2).
Rabin: deg f = 192 = 2^6 * 3, prime divisors 2 and 3, so f is irreducible iff
  (i)   x^(2^192) == x (mod f),
  (ii)  gcd(x^(2^96) - x, f) == 1    (192/2),
  (iii) gcd(x^(2^64) - x, f) == 1    (192/3).
Negative controls (must be rejected): x^192 + 1 (= (x^64 + 1)^3); a product of two degree-96 irreducibles (passes (i),
fails (ii)); a product of three degree-64 irreducibles (passes (i), fails (iii)); x^192 + x^7 + x^2 + x (divisible by x).
Polynomials are Python ints (bit i = coefficient of x^i)."""
def pmod(a, m):
    dm = m.bit_length() - 1
    while a and a.bit_length() - 1 >= dm: a ^= m << (a.bit_length() - 1 - dm)
    return a
def pmul(a, b):
    r = 0
    while b:
        if b & 1: r ^= a
        a <<= 1; b >>= 1
    return r
def sq(a):
    r = 0; i = 0
    while a:
        if a & 1: r |= 1 << (2 * i)
        a >>= 1; i += 1
    return r
def pgcd(a, b):
    while b: a, b = b, pmod(a, b)
    return a
def rabin(F):
    n = F.bit_length() - 1; ps = [p for p in (2, 3, 5, 7) if n % p == 0]
    t = 2; pw = {}
    for k in range(1, n + 1):
        t = pmod(sq(t), F)
        for p in ps:
            if k == n // p: pw[p] = t
    res = {'(i)': t == 2}
    for p in ps: res['gcd n/%d' % p] = pgcd(F, pw[p] ^ 2) == 1
    return res
def irreducible(F): return all(rabin(F).values())
def find_irreducible(deg, start):
    """the first irreducible x^deg + (low part >= start) with an odd low part, by Rabin"""
    c = start | 1
    while True:
        F = (1 << deg) | c
        if irreducible(F): return F
        c += 2
F = (1 << 192) | (1 << 7) | (1 << 2) | (1 << 1) | 1
r = rabin(F)
print("f = x^192 + x^7 + x^2 + x + 1  (low word 0x87)")
for k, v in r.items(): print("  %-10s %s" % (k, v))
ok = all(r.values())
print("FIELD CERT", "PASS: f irreducible, GF(2)[x]/f = GF(2^192)" if ok else "FAIL")
g96a = find_irreducible(96, 3); g96b = find_irreducible(96, (g96a & ((1 << 96) - 1)) + 2)
g64a = find_irreducible(64, 3); g64b = find_irreducible(64, (g64a & ((1 << 64) - 1)) + 2); g64c = find_irreducible(64, (g64b & ((1 << 64) - 1)) + 2)
neg = [("x^192 + 1", (1 << 192) | 1), ("product of two degree-96 irreducibles", pmul(g96a, g96b)),
       ("product of three degree-64 irreducibles", pmul(pmul(g64a, g64b), g64c)), ("x^192 + x^7 + x^2 + x", (1 << 192) | 0x86)]
allneg = True
for name, Fp in neg:
    rr = rabin(Fp); acc = all(rr.values()); allneg &= not acc
    print("negative control %-42s %s -> %s" % (name, ' '.join('%s=%s' % kv for kv in rr.items()), "rejected (OK)" if not acc else "ACCEPTED (tool broken)"))
print("NEGATIVE CONTROLS", "PASS" if allneg else "FAIL")
import sys; sys.exit(0 if ok and allneg else 1)
