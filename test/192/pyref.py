#!/usr/bin/env python3
"""pyref.py VECTORS [maxlen] -- an independent Python implementation of ChainHash-192 written from SPEC-192.md
(field, key from a seed or raw bytes, block layout, two-level outer stage, finalizer); checks every vector line
"key n digest" (key = a decimal seed, or R = raw key bytes (73 i + 11) mod 256) with n <= maxlen, the message being
m[j] = (137 j + 29) mod 256.  Shares no code with the C header.  With --emit KEY N it prints one digest."""
import sys
M64 = (1 << 64) - 1
F = (1 << 192) | (1 << 7) | (1 << 2) | (1 << 1) | 1
def mul(a, b):
    r = 0
    while b:
        if b & 1: r ^= a
        a <<= 1; b >>= 1
    for i in range(r.bit_length() - 1, 191, -1):
        if (r >> i) & 1: r ^= F << (i - 192)
    return r
def splitmix(st):
    st[0] = (st[0] + 0x9E3779B97F4A7C15) & M64; z = st[0]
    z = ((z ^ (z >> 30)) * 0xBF58476D1CE4E5B9) & M64; z = ((z ^ (z >> 27)) * 0x94D049BB133111EB) & M64
    return z ^ (z >> 31)
def key(spec):
    if spec == 'R':
        b = bytes(((73 * i + 11) & 255) for i in range(216)); e = [int.from_bytes(b[24 * i:24 * i + 24], 'little') for i in range(9)]
    else:
        st = [int(spec) ^ 0x4348313932763100]; e = [sum(splitmix(st) << (64 * l) for l in range(3)) for _ in range(9)]
        if e[1] == 0: e[1] = 1
    s, y, z, tau = e[0], e[1], e[2], e[3]; c = e[4:9]
    masks = []; p = s
    for i in range(176): masks.append(p); p = mul(p, s)          # masks[j] = s^(j+1): x_i -> s^(2i+1), y_i -> s^(2i+2)
    return masks, y, z, tau, c
def word(b, o): return int.from_bytes(b[o:o + 8], 'little')
def block_value(blk, masks):
    acc = 0
    for i in range(88):
        g, t = divmod(i, 8)
        if g < 10:
            x = sum(word(blk, 384 * g + 64 * j + 8 * t) << (64 * j) for j in range(3))
            y = sum(word(blk, 384 * g + 192 + 64 * j + 8 * t) << (64 * j) for j in range(3))
        else:
            x = word(blk, 3840 + 8 * t) | (word(blk, 3904 + 8 * t) << 64)
            y = word(blk, 3968 + 8 * t) | (word(blk, 4032 + 8 * t) << 64)
        acc ^= mul(x ^ masks[2 * i], y ^ masks[2 * i + 1])
    return acc
def chainhash192(spec, msg):
    masks, Y, z, tau, c = key(spec); n = len(msg)
    if n == 0: bv = [0]
    else:
        bv = []
        for o in range(0, n, 4096):
            blk = msg[o:o + 4096]; blk = blk + bytes(4096 - len(blk)); bv.append(block_value(blk, masks))
    yp = [1]
    for _ in range(8): yp.append(mul(yp[-1], Y))
    def region(a):
        q = len(a); h = (q + 1) // 2; f = q // 2; r = 0
        for i in range(1, f + 1): r ^= mul(a[i - 1] ^ yp[2 * i - 1], a[h + i - 1] ^ yp[2 * i])
        if q % 2: r ^= a[h - 1]
        return r
    V = n
    for r in range(0, len(bv), 8): V = mul(V, z) ^ region(bv[r:r + 8])
    X = (V + tau) & ((1 << 192) - 1); G = mul(X, X); t = mul(G ^ c[0], X ^ G ^ c[1]); out = mul(X ^ c[2], t ^ c[3]) ^ c[4]
    return out.to_bytes(24, 'little').hex()
def message(n): return bytes(((137 * j + 29) & 255) for j in range(n))
if __name__ == '__main__':
    if sys.argv[1] == '--emit': print(chainhash192(sys.argv[2], message(int(sys.argv[3])))); sys.exit(0)
    maxlen = int(sys.argv[2]) if len(sys.argv) > 2 else 1 << 62; ok = bad = 0
    for line in open(sys.argv[1]):
        if not line.strip() or line.startswith('#'): continue
        k, n, d = line.split(); n = int(n)
        if n > maxlen: continue
        if chainhash192(k, message(n)) == d: ok += 1
        else: bad += 1; print('MISMATCH', k, n)
    print('pyref: %d vectors match, %d mismatches -> %s' % (ok, bad, 'PASS' if bad == 0 and ok > 0 else 'FAIL'))
    sys.exit(1 if bad or not ok else 0)
