# ChainHash-128 collision bound

**Lean-proved.** The bound, the independence of every evaluation
schedule and the exact score minimum are checked in namespace
`ProvenHashes.ChainHash128` (116 theorems), using only the standard axioms
`propext`, `Classical.choice` and `Quot.sound`, on top of the field
`GF(2)[X]/(X^128+X^7+X^2+X+1)` whose irreducibility is certified in the
same namespace (`modulus_irreducible`, a Rabin certificate with 128
squaring steps and a Bézout identity). See [lean/README.md](../lean/README.md)
and [lean/VERIFICATION.txt](../lean/VERIFICATION.txt).

## Statement

Let `q = 2^128`, `W = 32` (words per 512-byte block), and let L be an
integer with `1 <= L <= 2^61-1`. Fix two distinct byte strings m, m', each
at most 8L bytes long, independently of the key. The key is 128 uniformly
random bytes. Then

```text
Pr[ chainhash128(key, m) = chainhash128(key, m') ] <= min(1, (p(L) + d(L)) / 2^128).
```

The probability is over the key alone; the messages are chosen without
seeing the key or any hash value (the guarantee is not adaptive, and the
function is not a MAC). The event is equality of all 128 output bits;
empty messages, partial final words and unequal lengths are included, and
equal fixed lengths are the special case.

`p(L)` is the block count of an 8L-byte message, `p(L) = p_bytes(8L)` with
([SPEC-128.md](SPEC-128.md), `ell = 4096Q + r`)

```text
p_bytes(0)   = 1
p_bytes(ell) = 8Q                       if ell > 0 and r = 0
               8Q + min(8, ceil(r/16))  if r > 0
```

and `d(L)` bounds the root count of the level-1 difference in the seed s:

```text
d(L) = 1                       if L <= 16
       min(W, 2*ceil(L/32))    otherwise
```

| Message limit | L | p | d | Numerator (divide by 2^128) |
| --- | ---: | ---: | ---: | ---: |
| 8 bytes | 1 | 1 | 1 | 2 |
| 16 bytes | 2 | 1 | 1 | 2 |
| 128 bytes | 16 | 8 | 1 | 9 |
| 256 bytes | 32 | 8 | 2 | 10 |
| 1 KiB | 128 | 8 | 8 | 16 |
| 4 KiB | 512 | 8 | 32 | 40 |
| 1 MiB | 131072 | 2048 | 32 | 2080 |

These are certificates (upper bounds). At L = 1 the bound is attained: the
one-byte messages `"\x00"` and `"\x01"` differ before the finalizer by `s^2`,
which vanishes only at `s = 0`, and the empty message and `"\x00"` differ by
`y + s^3`; either pair collides with probability exactly `(2q - 1)/q^2`,
`q = 2^128`, so the score of 127 bits is exact. For larger L the numerators
are not claimed to be attained. The SplitMix64 seed constructor is a different key distribution and
the bound is not asserted for it.

## Score

The strength score `min_L log2(L / epsilon(L))` with
`epsilon(L) = (p(L)+d(L))/2^128`, L in 8-byte words, equals **127 bits**,
attained at L = 1: both `p(L) <= L` and `d(L) <= L`, so every numerator is
at most 2L with equality only at L = 1
([test/128/bounds.py](../test/128/bounds.py) checks these integer
inequalities through 131,072 words and around every power of two up to
`2^61-1`). The short-length refinement `d(L) = 1` for `L <= 16` is what
makes the score 127: the coarser envelope `(p + W)/2^128`, which holds for
every pair (lemma `coarse_collision_bound`), would only score
`128 - log2 33 = 122.96` bits (lemma `coarse_score_minimum`). A score is a
guarantee about fixed messages under a random key, not an estimate of
attack work.

## Proof outline

Every step of the [64-bit proof](THEOREM.md#proof-outline) uses only that
F is a finite field of characteristic two and that the byte-to-word
encoding is injective. The 128-bit function changes the field to
`GF(2)[X]/(X^128+X^7+X^2+X+1)` and the comb constants: 128-bit words,
`W = 32` words per logical block, eight comb lanes with one word per lane
half, and partner offset eight words. The formalization follows the same
route: the bound `(p+1)/2^128` for a key of 39 independent field words
(the internal lemma `ideal_key_collision_bound`), then the root count in
s for the expanded key `kappa[a] = s^(a+1)`.

**1. Level 1, equal lengths.** For pair slot C the block difference is
`(a*b XOR a'*b') XOR (a XOR a')*kappa[2C+1] XOR (b XOR b')*kappa[2C]`.
With 39 independent words the partner key of a changed word gives one
affine root. With the expanded key a changed first word has exponent
`2C+2` in s and a changed partner exponent `2C+1`, a bijection onto
`1..W`, so the difference is a nonzero polynomial in s of degree at most
W: at most 32 roots, the coarse envelope. Through 128 bytes (`L <= 16`)
every partner is absent and every block has one pair, so the difference is
`delta*s^2`, which has exactly one root (squaring is a bijection of a
characteristic-two field): `d = 1`. Above that, a prefix of 8L bytes
touches at most `ceil(8L/256)` pair slots, capped at `W/2`, which bounds
every partner exponent by `min(W, 2*ceil(L/32))`, including for complete
preceding regions since all regions share the key table.

**2. Level 2, equal lengths.** Conditional on level-1 keys with a differing
block, the Horner difference is a nonzero polynomial in the independent
uniform y of degree at most `p-1`; pre-final collision probability at most
`(d + p - 1)/q`.

**3. Unequal lengths.** The coefficient of `y^max(p,p')` is `ell XOR ell'`
(equal block counts; distinct lengths below `2^64 < q` have distinct field
representations) or the byte length of the message with more blocks
(nonzero): at most `max(p,p')/q`, with no exceptional level-1 key and no
dependence on s.

**4. Twist and finalizer.** Integer addition modulo `2^128` (with the limb
carry) is a bijection for fixed tau; the five circuit parameters are in
bijection with the lower coefficients of a uniform monic quintic over any
characteristic-two field, so the finalizer adds exactly
`(1 - alpha)/q <= 1/q`. Numerators: `d + p` (equal lengths) and
`max(p,p') + 1` (unequal), both within `p(L) + d(L)`.

## Formalization

The user-facing endpoints in `ProvenHashes.ChainHash128` are:

- `collision_bound`: for `0 < L`, `8L < 2^128` and distinct byte lists of
  length at most 8L, the exact collision probability over the `2^1024` keys
  is at most `min(1, (p(L) + d(L))/2^128)` with p and d as above. The
  length domain is the field's; the C API's `2^64` limit and the score's
  `L <= 2^61-1` are sub-cases.
- `evaluation_independence`: for every positive stride k, the k-chain
  schedule and the lazy 256-bit-state evaluation (with `X^128 = 0x87`)
  equal the serial Horner definition, for every key including `y = 0`.
- `score_minimum`: `127` is the least value of `log2(L / epsilon(L))`
  over all positive natural L.
- `coarse_collision_bound` and `coarse_score_minimum`: the envelope
  `(p + 32)/2^128` and its score `128 - log2 33`, lemmas on the way to the
  above.

The [625-vector comparison](../lean/vectors/ChainHash128.lean) checks
`include/chainhash128.h` against a separately executable Lean reference
across both key forms, every available backend, strides 1–8, eager/lazy
state, schoolbook/Karatsuba products, the dispatched one-shot and the
header's self-test vectors; it is evidence, not a formal refinement proof
of C, the compiler or the SIMD paths. The 128-bit result is one polynomial
over the larger field, not two 64-bit hashes side by side: the numerator
`p + d` against `2^128` is what makes the score 127 rather than the
roughly 77 bits two independent 64-bit evaluations would certify.
Truncated outputs, bucket indices and adaptively chosen messages need
separate analysis.
