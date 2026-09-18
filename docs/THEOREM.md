# ChainHash collision theorem

This is the 256-byte specialization (`W=32`, `S=1`) of Theorem
`thm:ph:collision` in Thomas D. Ahle and Jakob B. T. Knudsen,
*Fast Evaluation of Polynomials with Rational Preprocessing*, appendix
“Collision probability of ChainHash.” The supplied appendix is preserved in
[appendix_chainhash.tex](appendix_chainhash.tex). This document describes the
mathematical family implemented here; equivalence tests are not a formal
verification of the C implementation.

## Domain and key distribution

Messages are byte strings of length less than `2^64`. The field is
`F = GF(2)[X]/(X^64 + X^4 + X^3 + X + 1)`, of size `q=2^64`.
Bits are polynomial coefficients, so field addition is XOR.
The key consists of **41 mutually independent, uniformly random field words**:
32 CLNH words, recurrence keys `u,y,z`, finalizer parameters `c0,...,c4`, and
the integer-add twist `tau`. The same sampled key hashes both messages;
the messages are fixed independently of that key. In particular, this is
not a statement about adaptively selected inputs after observing keyed hashes.

## Exact collision statement

The appendix states, for its general parameters:

> Fix W, S and n ≥ 1, and put p = Sn. For every two distinct messages m ≠ m′
> with n(m), n(m′) ≤ n (equivalently: of at most nB bytes each),
> Pr[H(m) = H(m′)] ≤ (p + 2)/2^64 = (Sn + 2)/2^64.

Here `B=8W` and `n(m)=max(1,ceil(len(m)/B))`; probability is over all the key
words. In this repository `B=256`, `S=1`, so the bound is `(n+2)/2^64`.
For a byte-length limit `ell`, use

```
n = max(1, ceil(ell / 256))
epsilon_bytes(ell) = (n + 2) / 2^64.
```

For the blog's metric, let `L=ceil(max(len(m),len(m′))/8) ≥ 1`, measured in
64-bit words. Then

```
epsilon(L) = (ceil(L/32) + 2) / 2^64
score = inf_{L>=1} log2(L / max(2^-64, min(1, epsilon(L))))
      = 64 - log2(3) = 62.41503749927884... bits.
```

Indeed `ceil(L/32)+2 ≤ 3L`, with equality at `L=1`. This is a **lower
guarantee** for the family's score, not a tight determination of its worst
collision probability. It describes a length-normalized bound; it does not
mean a constant `2^-62.415` collision probability or that many bits of attack
work. The theorem concerns equality of **all 64 output bits**. Truncation,
bucket indices and selected output bits are not the event bounded here.
Examples: at most 256 bytes gives `3/2^64`; at most 1 MiB gives `4098/2^64`.

## The function

1. Partition the message into 256-byte blocks, retaining one empty block
   for an empty message. In each block, process only its intersected
   32-byte groups. Pad the final incomplete group with zero bytes and
   decode little-endian words. Pair the four words of each group as
   `(w0,w2)` and `(w1,w3)`, XORing each with the key word of its own position.
   XOR their unreduced 64×64 carry-less products to obtain a 128-bit value
   `(a,b)` (low, high). XOR the total byte length into **both** halves of
   the last block digest. The empty CLNH sum is zero.
2. Starting at `P0=z`, compute `Pi = ai XOR ((bi XOR y) * (P(i-1) XOR u))`,
   using multiplication in F. The PH sums themselves remain unreduced;
   only the recurrence and finalizer multiply in F.
3. Set `v = (Pn + tau) mod 2^64` by ordinary integer addition. Then compute
   `Y=v*v`, `Z=(Y XOR c0)*(v XOR Y XOR c1)`, and
   `H=(v XOR c2)*(Z XOR c3) XOR c4` in F.

## Proof sketch with explicit decoders

**CLNH and length encoding.** For two different blocks with equal pair
counts, expand their unreduced CLNH difference over the integral domain
`GF(2)[X]`. Some differing input word supplies a nonzero coefficient
`delta` of its partner's uniform key word. After conditioning on the other
words, the collision equation is `delta*k=C`. Multiplication by nonzero
`delta` is injective, so at most one of the `2^64` key values works.
For unequal pair counts the analogous lemma requires a **nonzero target**.
Append one extra product at a time. With probability `1-1/q` its first
factor is nonzero and the second factor has at most one solution; with
probability `1/q` the product vanishes and the previous bound applies.
Thus the induction gives `(1-1/q)/q + (1/q)(1/q) = 1/q`.

For distinct messages with the same block count, either an earlier
block differs or the last block does. If their byte lengths differ, equality
of their encoded last digests requires the nonzero unreduced target
`(ell XOR ell′)*(1+X^64)`; the length restriction makes it nonzero. This is
why the unequal-pair lemma applies. If lengths agree, the byte encoding is
injective and the equal-pair lemma applies. Consequently stream equality
has probability at most `1/q`. Different block counts give different stream
lengths, so their streams never coincide. No independence between different
blocks' CLNH outputs is assumed.

**Injective recurrence.** Treat `U,Y,Z` as indeterminates and write
`Pn=f1(Y)+Z*f2(Y)+U*f3(Y)`. With `gi=product_{j=i}^n(Y+bj)`,

```
f1 = sum_i ai*g(i+1),   f2 = g1,   f3 = sum_i gi.
```

For `G=product_{j=1}^m(Y+beta_j)` and
`S=sum_{i=1}^m product_{j=i}^m(Y+beta_j)`, decode

```
beta_1 = [Y^(m-1)]G - [Y^(m-2)](S-G) + indicator(m>=3).
```

A coefficient with negative exponent is zero. Divide `G` exactly by the
monic `Y+beta_1` and replace `S` by `S-G`; repeat to recover the remaining
`b` values and suffix products. Recover `a1` as `[Y^(n-1)]f1`, subtract
`a1*g2`, and peel the remaining coefficients in descending degree. This
exhibits injectivity without search or division by a potentially zero pivot.

Equal-length streams share top homogeneous part `(Z+U)Y^n`, so their
nonzero difference has total degree at most `n`. Unequal-length streams
have a nonzero difference of degree at most `max(n,n′)+1`. Schwartz–Zippel
at independent uniform `u,y,z` bounds recurrence collisions by `n/q` or
`(max(n,n′)+1)/q`, respectively, conditional on any fixed distinct streams.

**Finalizer and twist.** The circuit is a monic quintic. Put
`q0=c2, q1=c0+c1, q2=c0, q3=c3, q4=c4`, and
`delta=q2*(q1+q2)`, where additions in this paragraph are field additions.
If `ei` is the coefficient of `v^i`, the explicit inverse is

```
q0 = e4 + 1
q1 = e3 + q0
q2 = e2 + q0*q1
delta = q2*(q1+q2)
q3 = e1 + delta + q0*q2
q4 = e0 + q0*(delta+q3)
(c0,c1,c2,c3,c4) = (q2,q1+q2,q0,q3,q4).
```

Every pivot is one. Thus uniform parameters give independent uniform lower
coefficients of a monic quintic. At distinct fixed inputs its collision
probability is exactly `1/q` (condition on all coefficients but the linear
one). The integer-add twist is a bijection for every fixed `tau`, with
inverse integer subtraction modulo `2^64`; it preserves distinctness and
therefore this bound.

**Composition.** Partition collisions according to their first failing
stage. Equal block counts contribute at most `(1+n+1)/q`. Unequal block
counts contribute at most `(0+(n+1)+1)/q`. Both totals are `(n+2)/q`.

## Qualified five-wise statement

The appendix's Theorem `thm:ph:kwise` is **five-wise independence up to
level-1/2 collisions**, not unconditional five-wise independence of the
whole byte-string family. For `t≤5` distinct messages of at most `n` blocks,
let D mean all their pre-finalizer values are distinct. Then
`Pr[not D] ≤ choose(t,2)*(n+1)/2^64`. Conditional on any fixed earlier
keys for which D holds (and any twist), their final outputs are independent
uniform 64-bit words. Their unconditional joint distribution has total
variation distance at most that same bound from uniform.

## Machine-checked status

The supplied [LEAN_STATUS.md](LEAN_STATUS.md) reports compiled explicit
recurrence decoding, its degree/collision bounds (including unequal stream
lengths), and conditional composition. **The concrete ChainHash theorem is
not yet Lean-checked.** The composition still assumes the unreduced CLNH
stream and concrete finalizer bounds. The byte encoding, length argument,
concrete quintic and twist are not discharged there. A separate job is
working on the concrete theorem; this repository preserves the supplied
status snapshot and does not claim that job has completed.

The copied [symbolic checks](checks/verify5.py) and
[ANF experiment](checks/anf_check.py) are supporting sanity checks, not the
proof. In particular, small-field enumeration does not establish the
64-bit theorem; the explicit decoders above do. Seed expansion via
SplitMix64 is outside the theorem's key-distribution assumption.
