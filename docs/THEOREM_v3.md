# ChainHash-Horner v3 collision guarantees

**Lean status: Lean-proved.** The paper and model-A byte collision bounds,
evaluation independence and exact score minima are checked in
`ProvenHashes.ChainHash.V3`: 89 theorems across ten modules, using only
`propext`, `Classical.choice` and `Quot.sound`. The [full audit](../lean/VERIFICATION.txt)
covers both V3 and the retained proofs. The [design record](DESIGN_MEMO_v3.md)
preserves the original proof plan; those V3 formalization obligations are
now discharged. See the [integration record](../lean/V3_INTEGRATION.md).

## Statement, domain and key models

Let `q=2^64`, and let L be an integer with `1<=L<=2^61-1`, so `8L<q`.
Fix distinct byte strings m,m' independently of the key, each at most 8L
bytes long. All probabilities are over **one shared uniformly sampled key**.
The event is equality of all 64 output bits. The equal-fixed-length version
requires both strings to have exactly 8L bytes. The at-most version includes
empty messages, partial words and unequal lengths.

The **paper model for v3** means 39 independent uniform words
`kappa[0..31],y,c0..c4,tau` (312 bytes), not the paper's original v1 function
or its 41-word key. **Model A** means eight independent uniform words
`s,y,c0..c4,tau` (64 bytes), with `kappa[m]=s^(m+1)` in the field.
All field values, including zero, belong to both distributions.

Define the envelope block count for an 8L-byte message by

```text
Q = floor((L-1)/128)
u = 1 + ((L-1) mod 128)              # words in last nonempty region, 1..128
p(L) = 4Q + min(4, ceil(u/2))
```

This is nondecreasing; it is not `ceil(L/32)`. To define the level-1 model-A
root-count bound, put `M=min(L,128)`, `C=floor((M-1)/16)` and
`r=1+((M-1) mod 16)`:

```text
d(L) = 1              if M=1
       2              if 2<=M<=8
       4              if 9<=M<=16
       4C+2           if M>=17 and r=1
       4C+4           if M>=17 and r>=2
```

Thus d saturates at 32. This is a bound on the number of roots, which can
be smaller than the formal polynomial degree because squaring is bijective.

| Key model | Equal fixed length upper bound | Any lengths at most 8L upper bound | Fixed / at-most score |
| --- | --- | --- | --- |
| Paper / ideal, 312 bytes | `min(1,(p(L)+1)/q)` | `min(1,(p(L)+1)/q)` | **63 / 63** |
| A, 64 bytes | `min(1,(d(L)+p(L))/q)` | `min(1,(d(L)+p(L))/q)` | **63 / 63** |

These are certificates (upper bounds), not assertions that the worst pair
attains them. The SplitMix64 convenience constructor is a different key
distribution; neither bound is asserted for it. Deriving y or the finalizer
parameters from s would also require another theorem.

For a non-word-aligned byte limit B, use `L=ceil(B/8)` when `8L<q`, or use
the pair-specific derivation below with actual lengths and block counts.
The mathematical domain is all lengths below q. The C interface additionally
requires addressable input objects, `size_t` lengths and no streaming length
overflow; it does not impose v1's `8L+255<q` rounding restriction.

## Written proof

**1. Equal-length level-1 differences.** Choose a block containing a changed
word. Equal byte lengths give the same presence mask, so every key-only
product cancels when the two block polynomials are subtracted (XORed).
For pair slot pi, write the two message pairs as `(a,b)` and `(a',b')`.
The difference is

```text
(a*b XOR a'*b') XOR (a XOR a')*kappa[2pi+1] XOR (b XOR b')*kappa[2pi]
```

The product-only term is constant in the key.
In the ideal model, condition on all key words except the partner key of a
changed word. The difference is affine in that independent uniform key,
with nonzero slope, and hence has at most one root: probability at most 1/q.
This argument is in F and remains valid after reducing the CLNH sum.

In model A, a changed first word has exponent `2pi+2` in s, and a changed
partner has exponent `2pi+1`. These positions map bijectively to exponents
1..32 within a block; their nonzero coefficients cannot cancel each other.
Thus a changed block gives a nonzero polynomial. The largest available
exponent bounds its roots by 32, or the smaller piecewise envelope above.
In the first eight words only first halves are present, with at most two
first words per block. The difference has the form `a*s^2+b*s^4` (no
message-product constant because partners are zero). For L=1 it has at
most one root. For 2<=L<=8 it has at most two: substitute `z=s^2` and use
bijectivity of squaring in GF(2^64). Once partner words appear, degree four
suffices through L=16. In later chunks, the first new word has exponent
`4C+2` and the second has exponent `4C+4`; previous chunks have degree at
most `4C`. This gives exactly the stated d(L) envelope.

**2. Equal lengths at level 2.** Conditional on level-1 keys for which at
least one block differs, the Horner difference is a nonzero polynomial in
the still-independent uniform y, of degree at most p-1: the common length
term cancels. Hence pre-final collision probability is at most
`(1+p-1)/q=p/q` in the ideal model and `(d+p-1)/q` in model A, by a union
bound. Reusing the PH table across blocks does not require independent
block events: choose one changed block to bound the event that all block
coefficients are equal.

**3. Unequal lengths.** Condition on any level-1 key. If both messages have
the same block count p, the coefficient of `y^p` in their difference is
`ell XOR ell'`, nonzero because different byte lengths below q have
different field representations. If their block counts differ, the
higher-degree coefficient is the length of the message with more blocks.
That length is nonzero: more than one block implies a nonempty message,
even though it does **not** imply more than 256 bytes under the comb layout.
The degree is at most `max(p,p')`. Thus the pre-final collision probability
is at most `max(p,p')/q`, with no exceptional level-1 keys in either model.

**4. Twist and finalizer.** For each fixed tau, integer addition modulo q is
a bijection, so it preserves equality and inequality of pre-final values.
The independent five circuit parameters are in bijection with the five
lower coefficients of a uniform monic quintic (the unchanged finalizer's
coefficient-map argument). On distinct inputs, its outputs collide with
probability exactly 1/q. If `alpha=Pr[V(m)=V(m')]`, then exactly

```text
Pr[H(m)=H(m')] = alpha + (1-alpha)/q.
```

Bounding this by `alpha+1/q` gives the displayed equal-length numerators
`p+1` and `d+p`. Unequal lengths give `max(p,p')+1`, which fits the same
at-most envelopes because p and d are nondecreasing and d>=1. The original
[finalizer write-up](SEEDED_THEOREMS.md) supplies the unchanged algebra;
it is not a claim that the old recurrence theorem covers v3.

For up to five messages, **conditional on pairwise distinct pre-final
values**, the five independent finalizer parameters give independent uniform
outputs. This is not unconditional five-wise independence of message hashes.
For a fixed collection of at most five messages, a union bound on pairwise
pre-final collisions bounds the probability of failure of that condition.

## Scores and examples

Using the same eight-byte word unit as v1, the certificate score is

```text
inf_(1<=L<=2^61-1) log2(L / max(2^-64, epsilon(L))).
```

At L=1 both numerators equal 2, so the score is 63. For the ideal bound,
`p(L)+1<=2L`. For A, `d(L)+p(L)<=2L` also holds: check L=1..16 from the
pieces; for 17..128, p=4 and `d<=4*floor((L-1)/16)+4`, which suffices;
for L>=129, `d=32` and `p<=L/32+4` suffice. Both inequalities are strict
for L>1. Clipping at one does not lower these scores. A score is a
length-adjusted guarantee, not an estimate of attack work or a constant
collision probability for every length.

| Limit | p | d | Ideal numerator | A numerator |
| --- | ---: | ---: | ---: | ---: |
| 8 bytes | 1 | 1 | 2 | 2 |
| 16 bytes | 1 | 2 | 2 | 3 |
| 256 bytes | 4 | 8 | 5 | 12 |
| 1 KiB | 4 | 32 | 5 | 36 |
| 8 KiB | 32 | 32 | 33 | 64 |
| 1 MiB | 4096 | 32 | 4097 | 4128 |

Divide each numerator by `2^64`. For A the numerators at L=1..20 are
`2,3,4,4,5,5,6,6,8,8,8,8,8,8,8,8,10,12,12,12`.

## Formalization and limits

The following are verbatim source signatures in namespace
`ProvenHashes.ChainHash.V3`; definitions and all exported statements are in
[the catalogue](../lean/THEOREM_STATEMENTS.md).

```lean
theorem paper_collision_bound_bytes (L : ℕ) (hL : 8*L < 2^64)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Key39 => hashBytes k m = hashBytes k m') ≤ paperEpsilon L
```

```lean
theorem modelA_collision_bound_bytes (L : ℕ) (hL : 0 < L) (hcap : 8*L < 2^64)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Fin 64 → Byte => modelAHashBytes k m = modelAHashBytes k m') ≤ modelAEpsilon L
```

```lean
theorem complete_evaluation_independence (k : ℕ) (hk : 0 < k) :
    scheduledHash k = hash ∧ lazyHash = hash
```

```lean
theorem paper_score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score paperEpsilon L.val)) 63
```

```lean
theorem modelA_score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score modelAEpsilon L.val)) 63
```

`Key39 = Fin 39 → Word 64` supplies 2496 independent uniform key bits.
`Fin 64 → Byte` supplies exactly 512 independent uniform key bits, with
`Byte = Fin 8 → ZMod 2`; both byte-message hashes return `UInt64`.
`uniformProb` is the exact event/key-space cardinality ratio in `ℚ≥0`.
The definitions are `paperEpsilon L = (blocks (8*L)+1)/2^64` and
`modelAEpsilon L = (degreeBudget L+blocks (8*L))/2^64`, with `p(L)=blocks (8*L)`
and `d(L)=degreeBudget L`. These Lean envelopes are un-clipped; the displayed
clipped bounds also follow from a probability being at most one.

The score theorems concern `log₂(L/epsilon(L))` over all positive natural L,
with minimum 63 attained at L=1. In particular they cover the collision
length domain above. The schedule equality holds for every positive natural
stride, including strides greater than the block count, and every multiplier,
including zero. The lazy equality uses a bounded 128-bit raw polynomial
state and the reduction identity `X^64 = 0x1b`.

There are no assumed probabilistic stage bounds in the endpoints. The proofs
include comb byte injectivity, reduced CLNH difference universality, the
general characteristic-two Frobenius root bound, Horner leading coefficients,
key encoding bijections, model-A composition and envelope arithmetic.
The [464-vector comparison](../lean/V3_VECTORS.txt) checks the public C header
against a separate executable Lean reference, across both key models and
available backends, strides 1–8 and eager/lazy evaluation. These finite tests
do not constitute a formal C/compiler/SIMD or memory-safety refinement proof.

The guarantee concerns fixed messages independent of the key. It does not
establish adaptive or cryptographic security, a MAC, or bounds for truncated
outputs and bucket indices. No statistical suite or small-field experiment
substitutes for these mathematical hypotheses.
