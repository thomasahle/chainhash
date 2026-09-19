# ChainHash-128 v3 collision guarantees

**Lean status: port in progress.** No 128-bit collision theorem is shipped
in this repository yet. The statements below are written proofs obtained
by transferring the Lean-proved 64-bit [ChainHash-Horner v3 theorem](THEOREM_v3.md)
(`ProvenHashes.ChainHash.V3`, 89 theorems) to the field `GF(2^128)`; the
transfer argument is spelled out in the [proof section](#written-proof-transfer-from-the-64-bit-theorem).
Two neighbouring formalizations exist: the 64-bit v3 proofs in
[lean/](../lean/README.md), and a complete Lean proof of the *earlier,
strided* ChainHash-128 (379 theorems, ideal-key and model-A byte bounds, GCM
modulus irreducibility by Rabin certificate) in the paper repository's proof
lane, which is not part of this repository. Neither is a proof of the v3
128-bit function. The [test suite](../test/v3-128/README.md) supplies
executable identity checks; they are evidence, not a theorem.

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

## Written proof: transfer from the 64-bit theorem

Every step of the [64-bit v3 proof](THEOREM_v3.md#written-proof) is
field-generic: it uses only that F is a finite field of characteristic two
and that the message-to-word encoding is injective. The 128-bit function
replaces `GF(2^64)` with `F = GF(2)[X]/(X^128+X^7+X^2+X+1)`, which is a
field because the GCM polynomial is irreducible (the strided-128 Lean lane
checks this with a Rabin certificate, `ChainHash128.modulus_irreducible`;
it is also the standard GHASH modulus). The remaining changes are the
constants of the comb: 128-bit words, `W = 32` words per logical block, eight
comb lanes with one word per lane half instead of four lanes with two, and
partner offset eight words. The proof then reads as follows.

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
