#!/usr/bin/env python3
"""oracle.py DUMP -- check C c192_mul products (cert_pk -DDUMP: "a b c", hex, limb 2 first) against an independent
Python GF(2^192) multiply (schoolbook carry-less product, reduction by f = x^192 + x^7 + x^2 + x + 1 from the top)."""
import sys
F = (1 << 192) | (1 << 7) | (1 << 2) | (1 << 1) | 1
def mul(a, b):
    r = 0
    while b:
        if b & 1: r ^= a
        a <<= 1; b >>= 1
    for i in range(383, 191, -1):
        if (r >> i) & 1: r ^= F << (i - 192)
    return r
n = bad = 0
for line in open(sys.argv[1]):
    a, b, c = (int(t, 16) for t in line.split()); n += 1; bad += mul(a, b) != c
print("c192_mul vs Python oracle: %d products, %d mismatches -> %s" % (n, bad, "PASS" if n and not bad else "FAIL"))
sys.exit(0 if n and not bad else 1)
