# ChainHash collision bound

**Lean-proved.** The bound, the independence of every evaluation
schedule and the exact score minimum are checked in namespace
`ProvenHashes.ChainHash` (89 theorems), using only the standard axioms
`propext`, `Classical.choice` and `Quot.sound`; see
[lean/README.md](../lean/README.md) and the audit in
[lean/VERIFICATION.txt](../lean/VERIFICATION.txt).

## Statement

Let `q = 2^64` and let L be an integer with `1 <= L <= 2^61-1`, so
`8L < q`. Fix two distinct byte strings m, m', each at most 8L bytes long,
independently of the key. The key is 64 uniformly random bytes. Then

```text
Pr[ chainhash(key, m) = chainhash(key, m') ] <= min(1, (p(L) + d(L)) / 2^64).
```

The probability is over the key alone; "fixed independently of the key"
means the two messages are chosen without seeing the key or any hash
value (the guarantee is not adaptive, and the function is not a MAC). The
event is equality of all 64 output bits; empty messages, partial final
words and unequal lengths are included, and messages of exactly 8L bytes
are the special case with equal fixed length.

`p(L)` is the block count of an 8L-byte message ([SPEC.md](SPEC.md)):

```text
Q = floor((L-1)/128)
u = 1 + ((L-1) mod 128)              # words in the last nonempty region, 1..128
p(L) = 4Q + min(4, ceil(u/2))
```

`d(L)` bounds the number of roots of the level-1 difference polynomial
in the seed s. With `M = min(L,128)`, `C = floor((M-1)/16)` and
`r = 1 + ((M-1) mod 16)`:

```text
d(L) = 1              if M = 1
       2              if 2 <= M <= 8
       4              if 9 <= M <= 16
       4C+2           if M >= 17 and r = 1
       4C+4           if M >= 17 and r >= 2
```

so d saturates at 32. Both p and d are nondecreasing in L, so the bound
for "at most 8L bytes" is the bound at the larger length limit.

| Message limit | L | p | d | Numerator (divide by 2^64) |
| --- | ---: | ---: | ---: | ---: |
| 8 bytes | 1 | 1 | 1 | 2 |
| 16 bytes | 2 | 1 | 2 | 3 |
| 256 bytes | 32 | 4 | 8 | 12 |
| 1 KiB | 128 | 4 | 32 | 36 |
| 8 KiB | 1024 | 32 | 32 | 64 |
| 1 MiB | 131072 | 4096 | 32 | 4128 |

For L = 1..20 the numerators are `2,3,4,4,5,5,6,6,8,8,8,8,8,8,8,8,10,12,12,12`.
These are certificates (upper bounds), not claims that some pair attains
them. The SplitMix64 seed constructor is a different key distribution and
the bound is not asserted for it.

## Score

The strength score is the weakest length-adjusted guarantee,

```text
min over 1 <= L <= 2^61-1 of  log2( L / epsilon(L) ),   epsilon(L) = (p(L)+d(L))/2^64,
```

in units of 8-byte words. It equals **63.0 bits**, attained at L = 1 where
the numerator is 2; for every L > 1, `p(L) + d(L) < 2L`. A score is a
guarantee about the collision probability of fixed messages under a
random key, not an estimate of attack work and not 63 bits of
cryptographic security.

## Proof outline

The function is defined on 39 field words `kappa[0..31], y, c0..c4, tau`
([SPEC.md](SPEC.md)); the key expands 64 random bytes into them with
`kappa[m] = s^(m+1)`. The proof first establishes the bound `(p+1)/2^64`
for a key of 39 independent uniform words (the internal lemma
`ideal_key_collision_bound`, also the starting point of the 128-bit
proof) and then replaces the single-root argument of level 1 by a root
count in s.

**1. Level 1, equal lengths.** Choose a block containing a changed word.
Equal byte lengths give the same presence mask, so every key-only product
cancels in the XOR of the two block polynomials. For pair slot pi the
difference is

```text
(a*b XOR a'*b') XOR (a XOR a')*kappa[2pi+1] XOR (b XOR b')*kappa[2pi]
```

with the product-only term constant in the key. With 39 independent
words, condition on everything but the partner key of a changed word: the
difference is affine in that word with nonzero slope, so it has at most
one root. With `kappa[m] = s^(m+1)`, a changed first word contributes
exponent `2pi+2` in s and a changed partner exponent `2pi+1`; these
positions map bijectively to exponents 1..32 within a block, so their
coefficients cannot cancel and the difference is a nonzero polynomial in
s of degree at most 32. Its root count is at most `d(L)`: in the first
eight words only first halves are present, the difference has the form
`a*s^2 + b*s^4`, and because squaring is a bijection of a
characteristic-two field this has at most one root for L = 1 and at most
two for `2 <= L <= 8` (substitute `z = s^2`); later chunks raise the
largest exponent as the piecewise formula states. The argument is in F and
remains valid after reducing the CLNH sum.

**2. Level 2, equal lengths.** Conditional on level-1 keys for which at
least one block differs, the Horner difference is a nonzero polynomial in
the still-independent uniform y of degree at most `p-1` (the common length
term cancels), so the pre-final collision probability is at most
`(d + p - 1)/q` by a union bound. One changed block suffices; no
independence between block events is needed.

**3. Unequal lengths.** Condition on any level-1 key. With equal block
counts the coefficient of `y^p` in the difference is `ell XOR ell'`,
nonzero because distinct byte lengths below q have distinct field
representations. With different block counts the top coefficient is the
byte length of the message with more blocks, which is nonzero because more
than one block implies a nonempty message. The degree is at most
`max(p, p')`, so the pre-final collision probability is at most
`max(p,p')/q` with no exceptional level-1 key.

**4. Twist and finalizer.** For fixed tau, integer addition modulo q is a
bijection and preserves distinctness of pre-final values. The five circuit
parameters `c0..c4` are in bijection with the five lower coefficients of a
uniform monic quintic, so on two distinct inputs the finalizer collides
with probability exactly `1/q`. With `alpha = Pr[V(m) = V(m')]`,
`Pr[H(m) = H(m')] = alpha + (1 - alpha)/q <= alpha + 1/q`, which gives the
numerator `d + p` for equal lengths and `max(p,p') + 1` for unequal
lengths; both fit `p(L) + d(L)` because p and d are nondecreasing and
`d >= 1`. For up to five messages with pairwise distinct pre-final values
the five parameters give independent uniform outputs; this is conditional,
not unconditional five-wise independence of message hashes.

## Formalization

The user-facing endpoints in `ProvenHashes.ChainHash` are:

- `collision_bound`: for `0 < L`, `8L < 2^64` and distinct byte lists of
  length at most 8L, the exact collision probability over the `2^512`
  keys (the ratio of event size to key-space size in `ℚ≥0`) is at most
  `(d(L) + p(L))/2^64`, with p and d defined exactly as above.
- `evaluation_independence`: for every positive stride k, the round-robin
  k-lane schedule and the lazy 128-bit-state evaluation both equal the
  serial Horner definition, for every key including `y = 0` and for
  strides above the block count.
- `score_minimum`: `63` is the least value of `log2(L / epsilon(L))` over
  all positive natural L.

The proofs include the comb index maps and their injectivity on bytes,
reduced CLNH difference universality, the general characteristic-two
Frobenius root bound, Horner leading coefficients, the key encoding
bijections and the envelope arithmetic; there are no assumed
probabilistic stage bounds. The [464-vector comparison](../lean/vectors/ChainHash.lean)
checks `include/chainhash.h` against a separately executable Lean
reference across both key forms, every available backend, strides 1–8
and eager/lazy evaluation; it is evidence that the C code computes the
formalized function, not a formal refinement proof of C, the compiler or
the SIMD paths. Truncated outputs, bucket indices and messages adapted to
earlier hash values need separate analysis.
