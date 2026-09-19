# ChainHash-128 v3 collision guarantees

**Lean status: Lean-proved.** The paper and model-A byte collision bounds,
evaluation independence and the exact score minima are checked in
`ProvenHashes.ChainHash.V3_128`: 116 theorems across ten modules, using only
`propext`, `Classical.choice` and `Quot.sound`, on the shipped 128-bit base
`ProvenHashes.ChainHash128` (the GCM field with its Rabin irreducibility
certificate, the 16-byte word encoding and the earlier strided ChainHash-128
theorems, now `ProvenHashes.ChainHash128.Strided`). The [full audit](../lean/VERIFICATION.txt)
covers the 64-bit and 128-bit proofs together; see the
[integration record](../lean/V3_128_INTEGRATION.md) and the
[exact signatures](#formalization-and-limits) below. The
[test suite](../test/v3-128/README.md) and the
[625-vector C/Lean comparison](../lean/V3_128_VECTORS.txt) supply executable
identity checks of the header; they are evidence, not a theorem.

## Statement, domain and key models

Let `q = 2^128`, `B = 512`, `W = B/16 = 32`, and let L be an integer with
`1 <= L <= 2^61-1`, so `8L < 2^64`. Fix distinct byte strings m, m'
independently of the key, each at most 8L bytes long. All probabilities are
over **one shared uniformly sampled key**. The event is equality of all 128
output bits. The at-most version includes empty messages, partial words and
unequal lengths; the equal-fixed-length version requires both strings to
have exactly 8L bytes.

The **paper model** means `W+7 = 39` independent uniform 128-bit field words
`kappa[0..31], y, c0..c4, tau` (624 bytes). **Model A** means eight
independent uniform words `s, y, c0..c4, tau` (128 bytes), with
`kappa[a] = s^(a+1)` in F. All field values, including zero, belong to both
distributions. The SplitMix64 seed constructor is a different distribution;
neither bound is asserted for it.

Let p be the maximum actual block count of the two messages, where for byte
length `ell = 4096Q + r`:

```text
p(0)   = 1
p(ell) = 8Q                       if ell > 0 and r = 0
         8Q + min(8, ceil(r/16))  if r > 0
```

**Paper model.** For fixed distinct m, m' with maximum block count p,

```text
epsilon <= min(1, (p+1)/2^128).
```

**Model A, coarse envelope.** For the same pair,

```text
epsilon_A <= min(1, (p+W)/2^128) = min(1, (p+32)/2^128).
```

**Model A, refined at-most-length certificate.** For L as above, put
`p_B(L) = p(8L)` and

```text
d_B(L) = 1                        if L <= 16
         min(W, 2*ceil(L/32))     otherwise
E_A(L) = p_B(L) + d_B(L)
epsilon_A(L) <= min(1, E_A(L)/2^128)
```

for any two distinct messages of at most 8L bytes each. Because the
argument covers unequal lengths and every shorter message, the same
certificate applies to equal fixed lengths.

| Key model | Equal fixed length upper bound | Any lengths at most 8L upper bound | Chart score |
| --- | --- | --- | --- |
| Paper, 624 bytes | `min(1,(p_B(L)+1)/q)` | `min(1,(p_B(L)+1)/q)` | **127** |
| A, 128 bytes, refined | `min(1,E_A(L)/q)` | `min(1,E_A(L)/q)` | **127** |
| A, 128 bytes, coarse envelope only | `min(1,(p_B(L)+32)/q)` | `min(1,(p_B(L)+32)/q)` | 122.955606 |

These are certificates (upper bounds), not assertions that the worst pair
attains them. The chart score is `min_L log2(L/epsilon(L))` over the
integer domain `1 <= L <= 2^61-1`, L in 64-bit words as for every other
entry in the version table. Both the paper certificate and the refined
model-A certificate have `p_B(L) <= L` and `d_B(L) <= L`, so each numerator
is at most 2L with equality at L = 1: the score is exactly **127 bits**,
attained at L = 1. Using only the coarse model-A envelope would instead
report `128 - log2(W+1)`: 123.912537 bits for B = 256 and **122.955606 bits
for B = 512**. Do not silently score the coarse envelope as 127; the
short-length refinement is needed for that score. [`bounds.py`](../test/v3-128/bounds.py)
checks the integer inequalities behind both scores.

## Proof outline

Every step of the [64-bit v3 proof](THEOREM_v3.md#written-proof) is
field-generic: it uses only that F is a finite field of characteristic two
and that the message-to-word encoding is injective. The 128-bit function
replaces `GF(2^64)` with `F = GF(2)[X]/(X^128+X^7+X^2+X+1)`, which is a
field because the GCM polynomial is irreducible
(`ProvenHashes.ChainHash128.modulus_irreducible`, a Rabin certificate with
128 squaring steps and a Bézout identity; it is also the standard GHASH
modulus). The remaining changes are the constants of the comb: 128-bit
words, `W = 32` words per logical block, eight comb lanes with one word per
lane half instead of four lanes with two, and partner offset eight words.
The Lean development formalizes exactly this argument over F; the following
is its outline.

**1. Equal-length level-1 differences.** Choose a block containing a changed
word. Equal byte lengths give the same presence mask, so every key-only
product cancels in the XOR of the two block polynomials. For pair slot C the
difference is

```text
(a*b XOR a'*b') XOR (a XOR a')*kappa[2C+1] XOR (b XOR b')*kappa[2C]
```

with the product-only term constant in the key. In the paper model,
condition on all key words except the partner key of a changed word: the
difference is affine in that independent uniform key with nonzero slope,
hence has at most one root, probability at most `1/q`. The argument is in F
and remains valid after reducing the raw 256-bit CLNH sum. No union bound
over blocks is needed: one changed block suffices to bound the event that
all block coefficients agree.

In model A a changed first word has exponent `2C+2` in s and a changed
partner has exponent `2C+1`. Within a block these positions map bijectively
to exponents `1..W`, so the nonzero coefficients cannot cancel and a changed
block gives a nonzero polynomial in s of degree at most W: at most W = 32
roots. This is the coarse envelope. For the refinement: through 128 bytes
(`L <= 16`) every partner is absent and every block has one pair, so a
changed block difference is `delta*s^2`, which has exactly one root, s = 0;
hence `d = 1` rather than the formal degree two (squaring is a bijection of
a characteristic-two field, the general Frobenius root bound of the 64-bit
proof). Above that range a region prefix of 8L bytes contains at most
`ceil(8L/256)` active pair slots, capped at `W/2`, which bounds every
partner exponent by `min(W, 2*ceil(L/32)) = d_B(L)`, including complete
preceding regions since all regions share the key table.

**2. Equal lengths at level 2.** Conditional on level-1 keys for which at
least one block differs, the Horner difference is a nonzero polynomial in
the still-independent uniform y of degree at most `p-1`; the common length
term cancels. Pre-final collision probability is therefore at most `p/q` in
the paper model and `(d+p-1)/q` in model A, by a union bound over the
level-1 event and the level-2 event.

**3. Unequal lengths.** Condition on any level-1 key. If both messages have
the same block count p, the coefficient of `y^p` in their difference is
`ell XOR ell'`, nonzero because distinct byte lengths below `2^64 < q` have
distinct field representations. If the block counts differ, the top
coefficient is the byte length of the message with more blocks, which is
nonzero since more than one block implies a nonempty message. The degree is
at most `max(p, p')`, so the pre-final collision probability is at most
`max(p,p')/q` with no exceptional level-1 key in either model. Unequal
lengths therefore need no seeded CLNH estimate at all, which is why the
model-A envelope is `p + W` rather than a larger unequal-pair count.

**4. Twist and finalizer.** For fixed tau, integer addition modulo `2^128`
(including the limb carry) is a bijection and preserves distinctness of
pre-final values. The five circuit parameters are in bijection with the five
lower coefficients of a monic quintic over every characteristic-two field;
[SPEC_v3_128.md](SPEC_v3_128.md#collision-certificates-and-chart-scores)
displays the map and its inverse. Independent uniform `c0..c4` therefore
give collision probability exactly `1/q` on two distinct inputs. With
`alpha = Pr[V(m) = V(m')]`, exactly `Pr[H(m)=H(m')] = alpha + (1-alpha)/q`,
bounded by `alpha + 1/q`. This gives the numerators `p+1` (paper), `p+W`
(coarse A) and `p_B(L)+d_B(L)` (refined A); unequal lengths give
`max(p,p')+1`, which fits every envelope because p and d are nondecreasing
and `d >= 1`.

For up to five messages, conditional on pairwise distinct pre-final values,
the five independent finalizer parameters give independent uniform outputs.
This is conditional, not unconditional five-wise independence.

## Scores and examples

For B = 512, L in 64-bit words, 8L bytes:

| Limit | L | p_B | d_B | Paper numerator | Refined A numerator | Coarse A numerator |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 8 bytes | 1 | 1 | 1 | 2 | 2 | 33 |
| 16 bytes | 2 | 1 | 1 | 2 | 2 | 33 |
| 128 bytes | 16 | 8 | 1 | 9 | 9 | 40 |
| 256 bytes | 32 | 8 | 2 | 9 | 10 | 40 |
| 1 KiB | 128 | 8 | 8 | 9 | 16 | 40 |
| 4 KiB | 512 | 8 | 32 | 9 | 40 | 40 |
| 1 MiB | 131072 | 2048 | 32 | 2049 | 2080 | 2080 |

Divide each numerator by `2^128`. The 256-byte comparison family has
`W = 16`, `p_B(L)` with 2 KiB regions, paper/model-A numerators 4097/4112 at
1 MiB, and the same 127-bit refined scores. The larger default block halves
the asymptotic Horner degree and doubles the worst seeded CLNH degree; it
does not lower the refined chart score.

## Formalization and limits

The following are verbatim source signatures in namespace
`ProvenHashes.ChainHash.V3_128`; definitions and all exported statements are
in [the catalogue](../lean/THEOREM_STATEMENTS.md).

```lean
theorem paper_collision_bound_bytes (L : ℕ) (hL : 8*L < 2^128)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Key39 => hashBytes k m = hashBytes k m') ≤ paperEpsilon L
```

```lean
theorem modelA_collision_bound_bytes (L : ℕ) (hL : 0 < L) (hcap : 8*L < 2^128)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Fin 128 → Byte => modelAHashBytes k m = modelAHashBytes k m') ≤
      modelAEpsilon L
```

```lean
theorem complete_evaluation_independence (k : ℕ) (hk : 0 < k) :
    scheduledHash k = hash ∧ lazyHash = hash
```

```lean
theorem paper_score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score paperEpsilon L.val)) 127
```

```lean
theorem modelA_score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score modelAEpsilon L.val)) 127
```

```lean
theorem modelA_coarse_score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score modelACoarseEpsilon L.val))
      (128 - Real.logb 2 33)
```

`Key39 = Fin 39 → Word 128` supplies 4992 independent uniform key bits.
`Fin 128 → Byte` supplies exactly 1024 independent uniform key bits, with
`Byte = Fin 8 → ZMod 2`; both byte-message hashes return `BitVec 128`, and
`paper_collision_bound_output` states the paper bound for the 16 serialized
little-endian output bytes. `uniformProb` is the exact event/key-space
cardinality ratio in `ℚ≥0` (`idealKey_card` gives `(2^128)^39`,
`modelAKey_card` gives `(2^128)^8`). The envelopes are SPEC's, clipped at one:
`paperEpsilon L = min 1 ((blocks (8*L)+1)/2^128)`,
`modelAEpsilon L = min 1 ((blocks (8*L)+degreeBudget L)/2^128)` and
`modelACoarseEpsilon L = min 1 ((blocks (8*L)+32)/2^128)`, with
`p_B(L) = blocks (8*L)` and `d_B(L) = degreeBudget L` exactly as defined
above. The SPEC block forms `min 1 ((p+1)/2^128)` and `min 1 ((p+32)/2^128)`
for any `p` bounding both block counts are `paper_collision_bound_bytes_blocks`
and `modelA_coarse_bound_bytes_blocks`; the 624-byte `key_from_ideal_bytes`
layout is `paper_collision_bound_key_bytes`, and `expandedWords_power` proves
`kappa[a] = s^(a+1)` in the shipped 128-byte layout.

The length domain is `8*L < 2^128`, the field's length word; the C API's
`2^64` limit and the chart's `L <= 2^61-1` are sub-cases. Empty messages,
partial final words and unequal lengths are included; equal fixed lengths
specialize the at-most bounds. The score theorems concern
`log₂(L/epsilon(L))` over all positive natural L, with the three minima
attained at L = 1. The schedule equality holds for every positive natural
stride, including strides greater than the block count, and every
multiplier, including zero; the lazy equality uses the bounded 256-bit raw
state with `X^128 = X^7+X^2+X+1 = 0x87` (`alpha_eq_135`).

There are no assumed probabilistic stage bounds in the endpoints. The proofs
include the SPEC index maps, comb byte injectivity, reduced CLNH difference
universality over F, the general characteristic-two Frobenius root bound,
Horner leading coefficients, key encoding bijections, model-A composition,
SPEC's numerator tables (`envelope_table`, `envelope_large_examples`) and the
score arithmetic. The [625-vector comparison](../lean/V3_128_VECTORS.txt)
checks the public C header against a separate executable Lean reference,
across both key models, every available backend, strides 1–8, eager/lazy
state, schoolbook/Karatsuba products, the dispatched one-shot and the
header's own self-test vectors. These finite tests do not constitute a formal
C/compiler/SIMD or memory-safety refinement proof.

## Scope and limits

The guarantee concerns fixed messages independent of the key. It does not
establish adaptive or cryptographic security, a MAC, or bounds for truncated
outputs and bucket indices. The 128-bit result is not the concatenation of
two 64-bit ChainHash results and does not inherit their theorem; it is one
polynomial over the larger field, and the `p+1` numerator is what makes the
score 127 rather than the roughly 77 bits that two independent 64-bit
evaluations would certify. A deterministic benchmark seed does not supply
the 128 independent random bytes of model A. Executable identity checks
(bit-serial oracle, backend agreement on both hosts, SMHasher3 Sanity and
verification value `0x1FCA728C`) support the implementation, not the
theorem; no statistical suite substitutes for its hypotheses.
