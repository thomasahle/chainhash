# Design

ChainHash hashes a message in three levels: keyed carry-less products over
256-byte blocks, a Horner chain in an independent key word over `GF(2^64)`
with the byte length as its leading coefficient, and an integer twist
followed by a quintic finalizer. ChainHash-128 is the same construction
over `GF(2^128)` with 512-byte blocks. This page explains why each part has
the shape it has; [SPEC.md](SPEC.md) and [SPEC-128.md](SPEC-128.md) give
the exact definitions and [THEOREM.md](THEOREM.md) and
[THEOREM-128.md](THEOREM-128.md) the bounds.

## One carry-less multiply per two words

Level 1 is a reduced CLNH: for each pair of message words `(w_i, w_(i+8))`
one carry-less product `(w_i XOR kappa_a) * (w_(i+8) XOR kappa_b)` is
XORed into the block sum. Carry-less multiplication is the cheapest
universal hashing primitive on both x86 (PCLMULQDQ, VPCLMULQDQ) and ARM
(PMULL/PMULL2), and pairing halves the multiply count: 0.5 products per
64-bit word. XOR-summing raw 128-bit products and reducing once per block
keeps reductions and shuffles out of the loop. A changed word makes the
block difference a nonzero polynomial in the seed s of degree at most 32,
so it vanishes for few keys; that root count is the level-1 term of the
bound.

## Why the block size is part of the definition

A key table of period B words is reused across blocks, so two blocks must
be combined by something keyed: with one key-only scalar per block that is
identical for two consecutive blocks, mirroring a difference across the two
blocks collides for every key. One keyed multiplication per table period
is therefore necessary, and the period B is a constant of the function,
not an implementation choice. The table must also stay resident: on NEON a
key table larger than the register file makes every kernel load-bound, so
B is 32 words (256 bytes; 32 words of 128 bits for ChainHash-128).

## Horner with a constant multiplier

Level 2 combines the block values as a polynomial in an independent key
word y: `V = ell*y^p XOR b_1*y^(p-1) XOR ... XOR b_p`. Because the
multiplier is the same key constant in every step, the digest is a fixed
polynomial identity in the block values, and every machine choice becomes
an evaluation order of that identity: k parallel chains each multiply by
`y^k`, a lazy 128-bit (256-bit) state is advanced with two products and
reduced once at the end, SIMD width and accumulator count are free, a
stream can be chunked at any byte, and region-aligned partitions can be
hashed in parallel and joined as `A*y^(p_B) XOR B`. A message-dependent
multiplier would make the chain serial: composing two steps costs extra
products and the composed multiplier contains a degree-3 monomial, so no
evaluation over more words saves a product. The exact-count k-lane schedule
with lookahead ([SPEC.md](SPEC.md)) uses exactly p field multiplications,
the serial Horner count, for every k.

An unkeyed linear combination of blocks would not do: with the key table
reused, `P <- X^j P XOR c_t` collides with probability one for word
differences `delta` and `X^j delta` in consecutive blocks. One keyed
multiplication per block is the floor, and this design sits on it.

## The comb layout

Each 1 KiB region holds four interleaved logical blocks: word index
`i = 128R + 16C + 8h + 2j + e` belongs to block `4R + j + 1`, and a pair is
`(w_i, w_(i+8))`, the same lane of two loads 64 bytes apart within a
128-byte chunk. This pairing is shuffle-free on XMM, YMM, ZMM and NEON at
once, and on 512-bit hardware one ZMM lane is one block: the level-2 step
is two wide products per KiB with no cross-lane fold in the loop, and the
only horizontal work is one weighted fold per message. Contiguous 256-byte
blocks would instead need a 4×4 lane transpose per KiB, which costs
10 to 12% of the loop. The comb is fixed by the definition; changing it
changes the function. ChainHash-128 uses eight lanes of one 128-bit word
each, partner offset eight words, and 4 KiB regions.

## The length as the leading coefficient

Starting the Horner chain from the byte length, `P_0 = ell`, separates
unequal lengths without any key: two messages with the same block count
differ in the coefficient of `y^p` by `ell XOR ell'`, and with different
block counts the top coefficient is a nonzero length. No terminator, padding
word or length-dependent multiplier is needed, and the empty message is the
finalizer applied to tau. Designs that separate the empty message from a
one-word message through a key-only level-1 product are pinned to a score
of 62; the key-free length term is what lifts the score to 63 (127).

## Pair presence

A pair contributes exactly when its first word has at least one byte; an
absent partner keeps its key and contributes the zero word. Zero-padding a
region and hashing every pair would add key-only products that depend on
nothing in the message and would define a different function; the tail
kernels therefore mask the key words of absent pairs rather than the data.
The block count of a partial region follows from this rule (17 bytes
already have two blocks), and the exact count is what the bound uses.

## The key

The key is 64 random bytes (128 for ChainHash-128): `s, y, c0..c4, tau`,
with the block keys `kappa[m] = s^(m+1)`. Position `2pi` of a block maps to
exponent `2pi+2` and its partner to `2pi+1`, a bijection onto `1..32`, so a
changed block gives a nonzero polynomial in s of degree at most 32 whose
nonzero coefficients cannot cancel; the bound counts its roots. In
characteristic two squaring is a bijection, so the difference `a*s^2 XOR
b*s^4` that appears while only first halves are present has at most two
roots (one for a single word), which is why the numerator is 2 at one word
and the score is exactly 63. The key words y and
`c0..c4, tau` are independent of s; deriving them from s would need a
different theorem. The resident 448-byte (896-byte) key object caches the
rearranged block keys, `y^0..y^8` and `27*y^i` (`0x87*y^i`) for the lazy
updates, and the finalizer words; it is a cache, not a serialization.

## Twist and finalizer

`V` is added to tau as an integer modulo `2^64` (`2^128`), then
`H = (v XOR c2) * ((v*v XOR c0) * (v XOR v*v XOR c1) XOR c3) XOR c4`. The
integer addition is a bijection for each tau, so it preserves distinctness
of pre-final values, and it breaks the `GF(2)`-linearity between the
polynomial stage and the finalizer. The five circuit words are in
bijection with the five lower coefficients of a monic quintic, so the
finalizer collides on distinct inputs with probability exactly `2^-64`
(`2^-128`) and gives independent uniform outputs on up to five distinct
pre-final values; three field products is the cost.

## Lazy state and reduction placement

In F, `X^64 = 27` (`X^128 = 0x87`), so a raw representative `lo + X^64*hi`
is advanced by `clmul(lo, y^k) XOR clmul(hi, 27*y^k) XOR C_t`: two
independent products, no reduction inside the loop, one reduction per
chain at the end. Level 2 consumes the reduced block value, which is what
makes reduction placement free; feeding raw halves into a keyed recurrence
would tie the digest to where reductions happen.

## ChainHash-128

The 128-bit function keeps the construction and changes the field to
`GF(2)[X]/(X^128+X^7+X^2+X+1)` (irreducible; the standard GCM modulus,
used here with the integer polynomial bit convention). A 512-byte block of
32 words halves the Horner degree per byte while keeping the level-1 root
count at 32, so the score stays 127 with the short-length refinement
`d(L) = 1` through 128 bytes. 128×128 products are built from 64×64
carry-less multiplies: schoolbook (four products, limbs selected by CLMUL
immediates) on XMM, ZMM and NEON, Karatsuba (three products plus limb
folds) on YMM and in the portable evaluator. Both give the same digest;
the split follows measurements, because on the M2 the loop is issue-bound
and schoolbook retires fewer instructions, while on YMM Karatsuba is
faster. Messages of at most 128 bytes have one pair per block with the
partner absent, so a shared short kernel factors the common partner key
out of the Horner sum.

## Cost

The bulk loop does 0.5 carry-less multiplies per word for level 1 and
`1/16` per word for level 2 (two products per 256-byte block), with XORs
and no reductions, shuffles or cross-lane extracts. Per message it adds k
lane reductions, `k-1` weighted combines, the `ell*y^p` term (free in the
k = 4 one-shot kernels, which seed lane 3 with ell) and the finalizer's
three products and one integer add. This fixed per-message work is why
short inputs are comparatively slow: ChainHash is a bulk hash.

## Attribution

The long-input loop structure, keyed pair products feeding a running
polynomial state, follows Orson Peters's
[PolymurHash](https://github.com/orlp/polymur-hash#how-it-works-and-why-its-fast).
ChainHash's binary field, comb layout, length placement, key expansion and
finalizer are defined in this repository.
