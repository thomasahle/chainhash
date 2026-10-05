# The ChainHash family, version 2

Version 2 adds four keyed hashes with proven collision bounds, one per output width, and places
the released ChainHash and ChainHash-128 in the same construction:

| Function | Header | Key | Block | Outer pairing | Score | Proof status |
| --- | --- | ---: | ---: | --- | ---: | --- |
| ChainHash | `chainhash.h` | 64 B | 256 B | one-sided (Horner in y) | 63 | Lean ([THEOREM.md](THEOREM.md)) |
| ChainHash-128 | `chainhash128.h` | 128 B | 512 B | one-sided (Horner in y) | 127 | Lean ([THEOREM-128.md](THEOREM-128.md)) |
| **ChainHash-128 v2** | `chainhash128v2.h` | 192 B | 2 KiB | two-sided | 127 | paper + certificates ([THEOREM-128v2.md](THEOREM-128v2.md)) |
| **ChainHash-192** | `chainhash192.h` | 216 B | 4 KiB | two-sided | 191 | paper + certificates ([THEOREM-192.md](THEOREM-192.md)) |
| **ChainHash-256** | `chainhash256.h` | 288 B | 4 KiB | two-sided | 255 | paper + certificates ([THEOREM-256.md](THEOREM-256.md)) |
| **ChainHash-512** | `chainhash512.h` | 576 B | 16 KiB | two-sided | 511 | paper + certificates ([THEOREM-512.md](THEOREM-512.md)) |

The released `chainhash.h` and `chainhash128.h` are unchanged, and so are their digests.
ChainHash-128 v2 is a new function with a new name, not a revision of ChainHash-128: the two
compute different digests and can be used side by side. There is no 64-bit version 2: the released
ChainHash *is* the 64-bit instance of the construction (see "Two pairing patterns"). The score is
`min_L log2(L/epsilon(L))` over message limits of L 8-byte words.

**Proof status.** The version 2 bounds are proved on paper, and every exact computation the proofs
rely on (field irreducibility, level-1 exponent classes, Lemma A's bookkeeping, the numerators and
the score) is a machine-checked certificate run by `make certs`. None of the version 2 proofs is
formalized in Lean yet; the Lean development in `lean/` covers ChainHash and ChainHash-128 only.

## The construction

Let F = GF(2^64). An instance fixes a polynomial g over F of degree n, defining the n-word algebra
A = F[T]/(g) (an operand is 8n bytes), the number r ≤ n of output words (Π: A → F^r keeps the top r
coefficients of the reduced representative), and p, the number of operand pairs per block. The
outer field is K = GF(2^(64r)). When n = r, g is irreducible, Π is the identity and A is K itself.
The key is one element s ∈ A for the block, y, z ∈ K for the outer stage, and the finalizer
constants τ, c0..c4 ∈ K.

```text
Hash of a message M of ℓ bytes; key s ∈ A;  y, z, τ, c0..c4 ∈ K

  b_1..b_m  ← block values:  b_t = Π( Σ_{j=1..p} (M_j + s^(2j−1)) · (M'_j + s^(2j)) )   in A
              (the empty message has one block, b_1 = 0)
  V ← ℓ                                                   the length is the leading coefficient
  for each region of up to 8 consecutive block values a_1..a_q (h = ⌈q/2⌉, f = ⌊q/2⌋):
      two-sided:  c ← Σ_{i=1..f} (a_i + y^(2i−1)) · (a_{h+i} + y^(2i))  +  [q odd] · a_h   in K
      one-sided:  c ← Σ_{i=1..q} a_i · y^(q−i)                                            in K
      V ← V · z + c                                        in K  (z = y^q in the one-sided form)
  v ← (V + τ) mod 2^(64r)                                 integer addition on the bit pattern
  return (v + c2) · ((v² + c0)(v + v² + c1) + c3) + c4                          in K
```

The block value and the region value are the same formula in two algebras: the block values are
hashed eight at a time by the pseudo-dot-product in K with key y, and the region values are
chained by a Horner polynomial in z with the length as its leading coefficient. A one-block
message has V = ℓ·z + b_1 in either form. Only the last region can have q < 8.

### Two pairing patterns

The region formula admits two *pairing patterns*, and the difference between them is where the
partner of a block value comes from.

- **Two-sided.** The partner of a_i is another block value, a_{h+i}: four products of two data
  values per region (an odd q leaves its middle value unpaired), and the regions are chained in an
  independent key z. Every block value must be reduced (Π applied, then the field reduction) before
  it is paired. The collision numerator grows as m/8 + 8 in the block count m.
- **One-sided.** The partner is 0, so each term is a_i · y^(q−i): a product of a data value with a
  key power, eight per region, and the chain step V·z is absorbed into them because z = y^8. This is
  ChainHash's Horner chain evaluated lazily: the block accumulators are multiplied raw and reduced
  once per region. The numerator grows as m.

In either pattern the difference of two messages is a polynomial in y whose linear terms occupy
distinct exponents, so the same root count applies. Which pattern is faster is a cost-model
decision per width: the two-sided pattern halves the outer multiplications but must reduce every
block value before pairing it; the one-sided pattern multiplies raw accumulators. At 64 bits the
block is light and the reductions dominate, and after five rounds of scheduling the two-sided
pattern stayed 2–5 % behind on wide backends, so ChainHash keeps the one-sided pattern (the
released function, unchanged). From 128 bits up the multiplications dominate and the two-sided
pattern wins or ties, so the four version 2 functions use it.

### The bound

For messages of at most 8L bytes, with m = blocks(8L) and m' = ⌈m/8⌉ regions,

```text
Pr[collision] <= N(L) / 2^(64r),   N(L) = max( d(L) + E(m) + 1,  m' + 1 ),
E(m) = 8 + m' − 1 if m' >= 2 else 2⌊m/2⌋,
```

where d(L) is the level-1 root count of the instance: the number of roots of the block-difference
polynomial in s. With a power key, s^1..s^(2p) are the masks, every operand word owns one exponent,
and the data × data terms sit at s^0, so d ≤ 2·(pairs that carry message bytes); a message that fits
in the first operand of each pair squares to a polynomial of half the degree. Every instance has
N(L) ≤ 2L with equality only at L = 1, so its score is 64r − 1. Using an independent z rather than a
power of y in the two-sided pattern matters: y^8 is not injective across lengths, and y^9 costs
score.

The twist and the degree-5 finalizer are ChainHash's. They make every fixed subset of output bits,
and every bucket map, inherit the collision bound; see [THEOREM.md](THEOREM.md) step 4.

## The instances

| | ChainHash-128 v2 | ChainHash-192 | ChainHash-256 | ChainHash-512 |
| --- | --- | --- | --- | --- |
| g over F | T^8 + 0x17d T^4 + 0x60c T^2 + 0x770 T + 0xee0 = ∏_{i<8}(T + i) + X·0x770: four distinct irreducible quadratics | irreducible, K = GF(2)[x]/(x^192 + x^7 + x^2 + x + 1) | irreducible, K = GF(2)[x]/(x^256 + x^10 + x^5 + x^2 + 1) | irreducible, K = GF(2)[x]/(x^512 + x^8 + x^5 + x^2 + 1) |
| n, r | 8, 2 | 3, 3 | 4, 4 | 8, 8 |
| outer field K | GF(2)[X]/(X^128 + X^7 + X^2 + X + 1) | as g | as g | as g |
| masks | powers s^1..s^32 of one key element s ∈ A | powers s^1..s^176 of s ∈ K | powers s^1..s^128 of s ∈ K | powers s^1..s^256 of s ∈ K |
| 64×64 products per pair | 9 (8 at the points α_i = i, 1 at infinity) | 6 (Karatsuba-3) | 9 (Karatsuba²) | 27 (Karatsuba³) |
| pairs per block, block | 16 pair-vectors of 8 roles, 2 KiB | 88, 4 KiB (the last 8 pairs with zero top limbs) | 64, 4 KiB | 128, 16 KiB |
| key | 192 B: s (64 B), y, c0..c4, τ, z | 216 B: s, y, z, τ, c0..c4 | 288 B: s, y, z, τ, c0..c4 | 576 B: s, y, τ, c0..c4, z |
| d(L) | 1 at L = 1, else min(32, 2⌈L/128⌉) | pairs(8L) if 8L ≤ 192, else min(2·pairs(8L), 176) | pairs(8L) if 8L ≤ 256, else min(2·pairs(8L), 128) | 1 if 8L ≤ 64, else min(2·pairs(8L), 256) |
| N(L) at 1 MiB | 104 | 216 | 168 | 272 |
| score | 127 | 191 | 255 | 511 |
| development name | CH-128/P v2.2 | ChainHash-192 round 2 | PH-256 v2 (v1.2 schedule) | PH-512 v1.1 |
| definition | [SPEC-128v2.md](SPEC-128v2.md) | [SPEC-192.md](SPEC-192.md) | [SPEC-256.md](SPEC-256.md) | [SPEC-512.md](SPEC-512.md) |

**ChainHash-128 v2.** n = 8 and r = 2 with the points α_i = i: g is four distinct irreducible
quadratics, so A splits into four copies of GF(2^128) by the Chinese remainder theorem and Π is
injective on each; the level-1 bound is a root count in the component of s. Each pair costs 8
products at the points plus one product of the two leading coefficients, which attains the lower
bound n + r − 1 for a bilinear circuit of this rank. The masks are computed at key setup by
exponentiation in A and stored in evaluation coordinates, so the key is 192 bytes.

**ChainHash-192.** n = r = 3: a pseudo-dot-product over GF(2^192) with a power key (216-byte key) and
ChainHash-256's outer stage and finalizer. Karatsuba-3 takes 6 carry-less products per 48-byte pair,
against ChainHash-256's 9 per 64 bytes, 1.125× fewer per byte. Its block layout differs from
ChainHash-128 v2's and ChainHash-256's, which interleave the eight blocks of a region so that a vector
lane holds one block: each 4096-byte block is stored contiguously, as ten 384-byte chunks of 8 pairs
written as six 64-byte rows (x limbs 0..2, then y limbs 0..2; lane t is pair 8g + t), and the last
256 bytes hold 8 more pairs as four rows (x and y limbs 0 and 1; their top limbs are zero). A lane is
a pair, as in ChainHash-512's chunks. With 88 pairs a block is exactly 4 KiB, so no power-of-two input
of 4 KiB or more has a partial block. On the M2 contiguous blocks stream at 53 GB/s without software
prefetch, against 44.5 GB/s (50.9 with prefetch) for region-interleaved rows; on AVX-512 they cost a
4-lane fold per block, done for a region's 8 blocks at once (2 % on Zen 4). In bulk ChainHash-192 is
1.10–1.17× ChainHash-256 (truncated to 24 bytes, same binary, 1 MiB) on every target machine and
1.25–1.34× on the PCLMUL backend ([results/192](../results/192/README.md)).

**ChainHash-256.** The field point n = r = 4: a pseudo-dot-product over GF(2^256) with Karatsuba²
(9 carry-less products per 64-byte pair) and a power key, so the key is 288 bytes. Of the 256-bit
candidates that were built and certified (a pencil with r = 4 is impossible with subspace point
sets, a 21-product pencil ties, an EHC-style split algebra is slower), this one was the fastest on
large inputs on every target machine.

**ChainHash-512.** n = r = 8: a pseudo-dot-product over GF(2^512) with a power key and 16 KiB
blocks. Karatsuba³ (27 products per pair) is faster than Toom-3² or Toom-4 (fewer products, more
linear work) because on every target the binding resource is the pair of vector ports that carry
both the carry-less products and the XORs; the kernel runs at its arithmetic floor.

**ChainHash (64 bits).** g = T, n = r = 1, Π = id: the block is Σ_j (M_j + s^(2j−1))(M'_j + s^(2j))
over F, one product per word pair (NH with a power key), and the outer stage takes the one-sided
pattern. This is the released function; score 63, machine-checked in Lean.

## One function per width

The digest of (key, message) must not depend on the host, so the parameters (g, r, p), the point set
and the layout are fixed once per width. Only the schedule varies by machine: backend, prefetch
distance, blocks in flight, product method, streaming split, and the short-input paths. Every
schedule is tested to give the identical digest on every host (`make test-all`, including inputs
flush against unmapped pages). An instance is chosen by its worst ratio to the best candidate
across the target machines, not by its best case: in bulk, ChainHash-128 v2 is 1.6–1.7×
ChainHash-128 (as of commit 2c61966) on Ice Lake, 1.5× on Zen 4 (gcc) and 1.26× on the M2, and
there is no machine where it is the wrong choice among the 128-bit candidates measured.

## Speed

Bulk one-shot throughput (GB/s, 256 KiB to 1 MiB inputs) from [results/128v2](../results/128v2/README.md),
[results/192](../results/192/README.md), [results/256](../results/256/README.md) and
[results/512](../results/512/README.md). The 128-, 192- and 256-bit x86 figures are TSC ticks
converted at 2.9 GHz (Xeon) and 2.6 GHz (Zen 4; ChainHash-256 there is 15.5 bytes per tick);
ChainHash-512 is timed with `clock_gettime`. The methods and full sweeps are in those files.

| Function | Xeon 8375C | EPYC 9R14 (Zen 4) | Apple M2 Pro |
| --- | ---: | ---: | ---: |
| ChainHash-128 v2 | 72 | 67 | 53 |
| ChainHash-192 | 43 | 45 | 48 |
| ChainHash-256 | 38 | ≈40 | 38 |
| ChainHash-512 | 24 | 23 | 27 |

ChainHash-192's figures are at 1 MiB (Xeon with clang 21; 40.5 GB/s with gcc 11). In the same binary
ChainHash-256 measured 38.5 (Xeon, clang), 39.7 (Zen 4) and 42.1 GB/s (M2), so the ratios at 1 MiB
are 1.11× (Xeon, clang), 1.12–1.13× (Xeon, gcc), 1.10–1.12× (Zen 4) and 1.14–1.17× (M2); from 4 KiB
to 1 MiB every ratio is between 1.10 and 1.32.

Short inputs are a separate schedule (the released schedules of ChainHash and ChainHash-128 got
the same treatment). SMHasher3-style dependent latency, averaged over 1–31-byte inputs, on the
EPYC 9R14 in `perf` core cycles (gcc 11): XXH3-64 28, XXH3-128 33, ChainHash 69, ChainHash-128 116,
ChainHash-128 v2 125, ChainHash-256 132, ChainHash-512 236. ChainHash-192 measured 111 against
ChainHash-256's 143 in its own harness (same host and compiler). The other hosts and the
before/after of each schedule are in the results directories.
