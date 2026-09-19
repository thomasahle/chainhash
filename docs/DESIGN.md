# Design

ChainHash hashes a message in three levels: keyed carry-less products over
256-byte blocks, a Horner chain in an independent key word over `GF(2^64)`
with the byte length as its leading coefficient, and an integer twist
followed by a quintic finalizer. ChainHash-128 is the same construction
over `GF(2^128)` with 512-byte blocks. This page explains why each part has
the shape it has; [SPEC.md](SPEC.md) and [SPEC-128.md](SPEC-128.md) give
the exact definitions and [THEOREM.md](THEOREM.md) and
[THEOREM-128.md](THEOREM-128.md) the bounds. The last section,
[Alternatives considered](#alternatives-considered), records what each
choice was measured against.

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

## Alternatives considered

Each part above was measured against at least one alternative on an Intel
Xeon Platinum 8375C and an Apple M2 Pro. The records behind every number
here are in [results/design/](../results/design/README.md),
[results/64/](../results/64/README.md) and
[results/128/](../results/128/README.md); units are those of
[results/README.md](../results/README.md).

### Block-stage pairing: comb, adjacent, strided

Three pairings give the same level-1 bound; they differ in what a load
must do before its product can issue.

| Pairing | Partner of `w_i` | ZMM | NEON |
| --- | --- | --- | --- |
| strided | two words later, inside a 32-byte group | one `VSHUFI64X2` per product; level-1 stage 19.98 B/TSC | shuffle-free |
| adjacent | `w_(i+1)` | shuffle-free; level-1 stage 31.98 B/TSC | `LD2`, or `LDP` plus `EXT`; 0.883× (256-byte blocks) and 0.926× (1 KiB) of the strided kernel |
| comb `(w_i, w_(i+8))` | same lane, 64 bytes later | shuffle-free | shuffle-free |

The ZMM gap is a port count. On the Xeon a `VPCLMULQDQ zmm` (four
products) issues every 1.72 ticks and an `xmm` product every 0.85, so the
wide form uses both 512-bit pipes. One extra 512-bit ALU op per wide
multiply is free (eight `VPXORQ` or `VPADDD` beside eight multiplies:
1.706 against 1.706 alone), while eight `VSHUFI64X2` cost 2.575, the sum
of the two run alone (1.723 + 0.853): the cross-lane shuffle serialises
behind the multiply on its port, and the strided layout gave away 37% of
the multiply ceiling. On the M2 the adjacent pairing pays instead: `LD2`
takes 1.41× the time of `LDP` per 32-byte group (0.299 against 0.212 ns),
and the best adjacent kernel reaches 19.98 B/cycle against 22.62 for the
strided one in the same binary. The comb needs neither ([The comb
layout](#the-comb-layout)): no bulk loop contains a pair shuffle on any
width ([results/64](../results/64/README.md#object-code)). Records:
[xeon-level1-ports.txt](../results/design/xeon-level1-ports.txt),
[xeon-level1-panel.md](../results/design/xeon-level1-panel.md),
[m2-adjacent-pairing.md](../results/design/m2-adjacent-pairing.md).

### The multiplication: schoolbook or Karatsuba

A 128×128 carry-less product is four 64×64 products (schoolbook) or three
plus limb folds (Karatsuba). Both give the same ChainHash-128 digest
(verification value `0x1FCA728C` either way), so the dispatch follows the
measurement per path.

| Path, 512-byte blocks | Karatsuba | Schoolbook | Dispatched |
| --- | ---: | ---: | --- |
| Xeon XMM, B/TSC | 7.27 | 8.22 | schoolbook |
| Xeon YMM, B/TSC | 9.53 | 8.19 | Karatsuba |
| Xeon ZMM, B/TSC | 13.71 | 14.16 | schoolbook |
| M2 NEON, B/cycle | 9.39 | 10.26 | schoolbook |

Xeon rows are the standalone RDTSC harness
([rdtsc-final512.csv](../results/128/evidence/rdtsc-final512.csv)), M2
rows SMHasher3 medians of three ([results/128](../results/128/README.md)).
On x86 schoolbook selects the limbs through the `CLMUL` immediates and
needs no operand shuffle (limb shuffles per KiB: 72 → 4 on XMM, 18 → 1 on
ZMM), while Karatsuba's folds are shuffles plus XORs that do not overlap
the multiplies (three wide `CLMUL` 5.18 ticks, two shuffles 1.72, the
mixture 6.90: [ports-final.csv](../results/128/evidence/ports-final.csv)).
On the M2 the loop is issue-bound, not multiplier-bound:

| NEON, per KiB | Karatsuba | Schoolbook |
| --- | ---: | ---: |
| `PMULL`/`PMULL2` | 108 | 144 |
| `EXT` | 76 | 76 |
| `EOR` | 248 | 140 |
| `EOR3` | 2 | 36 |
| total | 484 | 446 |

Both loops sustain about 4.5 instructions per calibrated cycle, so the
method with fewer instructions wins although it multiplies more
([audit/](../results/128/audit/)). On YMM the measurement goes the other
way and the dispatch follows it.

### Register widths and dispatch

There is one bulk kernel per width, XMM, YMM and ZMM on x86 and NEON on
ARM, plus the portable evaluator, and `chainhash()` takes the widest the
CPU and the OS state allow (CPUID and XGETBV: AVX with PCLMUL for XMM,
AVX2 with VPCLMULQDQ for YMM, AVX-512F with ZMM state for ZMM). Widest
wins on the Xeon: 27.72 B/TSC on ZMM, 16.83 on YMM, 16.10 on XMM in the
standalone harness ([rdtsc.csv](../results/64/out/Xeon/rdtsc.csv)), with
72, 36 and 18 carry-less multiplies per KiB and no shuffle, reduction or
spill on any width
([bulk-opcodes.json](../results/64/audit/bulk-opcodes.json)). The Horner
step runs at the width of the block products: each region advances the raw
state of every lane by two products with `[y^4, 27*y^4]`, eight 128-bit
products per KiB on XMM and NEON, four 256-bit on YMM, two 512-bit on ZMM,
so the loop-carried dependency per lane is one multiply and one XOR per
KiB and four lanes hide it. Per message the four lanes are folded on
`xmm`, where two extracts cost 2.39 ticks against 3.28 for a shuffle
butterfly ([fold.csv](../results/64/out/Xeon/fold.csv)). A partial region
is serial Horner on `xmm`, one reduced product per present lane, on XMM
and YMM, and two vector products over all lanes on ZMM and NEON.

The AVX-512 licence is inside these numbers. Under the carry-less loop the
core stays on the light licence: 3.43 GHz with a scalar chain, 3.36 with
16 or 24 wide multiplies per 64 adds; dense 512-bit integer multiplies
pull it down (96 `VPMULUDQ zmm` per 64 adds: 2.77 GHz; IFMA at 50% density
2.80, at 87.5% 2.29). B/TSC figures include the effect, since the TSC runs
at 2.9 GHz whatever the core does
([xeon-level1-ports.txt](../results/design/xeon-level1-ports.txt),
[xeon-level1-panel.md](../results/design/xeon-level1-panel.md)).

### The chain level: a constant multiplier

The alternative chain has a message-dependent multiplier, `P_t = a_t XOR
(b_t XOR y)(P_(t-1) XOR u)` with `(a_t, b_t)` the raw halves of the block
value. Its cost is structural. Composing k steps so that lanes can run in
parallel costs `2k-1` products instead of k, and the composed multiplier
carries a degree-3 monomial, so no evaluation over more words saves a
product; on the M2, composing 2, 4 or 8 steps gives 10.46, 10.34 and 10.31
B/cycle against 10.30 for the serial chain. On the Xeon one step is 14.03
ticks of latency against 6.9 ticks of block work per 256 bytes, so the
chain and not the multiply port sets the speed, and the only remedy is a
longer block: the level-1 stage with one such step per 256, 512, 1024 and
2048 bytes runs at 14.02, 21.44, 26.06 and 28.80 B/TSC
([xeon-level1-ports.txt](../results/design/xeon-level1-ports.txt), rows R1
to R8). That is where a block-size zoo comes from: a 256-byte and a 1 KiB
function with different digests and key tables, and on the M2 the 1 KiB
one slower (18.85 against 22.62 B/cycle), since a key table
larger than the NEON register file streams keys through the loop (14.6 to
15.7 B/cycle against 23.8 with a resident 256-byte key)
([horner-panel.md](../results/design/horner-panel.md),
[m2-adjacent-pairing.md](../results/design/m2-adjacent-pairing.md)).

With a key constant as multiplier the digest is one polynomial identity in
the block values ([Horner with a constant
multiplier](#horner-with-a-constant-multiplier)), so k chains, a lazy raw
state, chunked streaming and region-aligned thread splits (`A*y^(p_B) XOR
B`) are evaluation orders of one function. The block can then be the
smallest the definition needs, 32 words, since one keyed product per table
period is necessary anyway ([Why the block size is part of the
definition](#why-the-block-size-is-part-of-the-definition)), and on
512-bit hardware a 256-byte block costs what a 1 KiB block costs. One
function replaces the 256/512/1024-byte variants, and the register width
is a dispatch choice rather than a name. The same change moves the key
from 80 to 64 random bytes and the chart score from 62.415 (fixed length)
and 61 (at most a length) to 63 and 63
([horner-panel.md](../results/design/horner-panel.md)).

### 128-bit output

Two independently keyed 64-bit chains give a 128-bit digest from the same
key bytes as a native `GF(2^128)` chain, but their bound is the product of
two linear bounds and grows quadratically with the length, which is what
the chart score measures.

| 128-bit digest | Bound, messages up to 1 MiB | Score, full length domain | Xeon B/TSC | M2 B/cycle |
| --- | --- | ---: | ---: | ---: |
| two 64-bit chains, independent keys | `4098^2 / 2^128` | about 77 bits (121.0 with a 1 MiB cap) | 7.20 | 10.27 |
| native `GF(2^128)`, 512-byte blocks, strided pairing, message-dependent chain | `2050 / 2^128` | 126.4 | 8.16 | 10.28 |
| ChainHash-128 | `2049 / 2^128` (`(p+1)/2^128` for p blocks) | 127 | 14.43 | 10.26 |

The first two rows are one binary per host, the third its own
([results/128](../results/128/README.md)). The strided native chain is the
predecessor of the block stage: contiguous 512-byte blocks, Karatsuba
products, two-lane `VPCLMULQDQ` on x86 and the message-dependent chain
above. Its 512-byte block was forced by that chain: with 256-byte blocks
the chain-latency ceiling is 9.25 B/cycle on the M2 and 11.76 B/TSC on the
Xeon, doubling the block doubles it (18.49 and 23.52), and the measured
speed follows (M2 9.20 → 10.28, Xeon 6.20 → 8.16). ChainHash-128 keeps
512-byte blocks for a different reason: with Horner the block size is free
of latency, and 32 words of 128 bits halve the Horner degree per byte
while the level-1 root count stays 32, so the score is 127 either way; the
comb kernels measure 14.16 against 12.92 B/TSC on ZMM and 8.22 against
7.51 on XMM for 512 against 256-byte blocks
([rdtsc-final256.csv](../results/128/evidence/rdtsc-final256.csv),
[rdtsc-final512.csv](../results/128/evidence/rdtsc-final512.csv)). Record:
[ch128-two-chains.md](../results/design/ch128-two-chains.md).

An open option is an encode-hash-combine block stage (EHC): encode each
pair of 128-bit words so that 1.5 carry-less products per 16 bytes replace
the schoolbook product's 2, at about five extra XORs per 32 bytes. The
linear bound survives as long as the chain stays in `GF(2^128)`; splitting
it into two 64-bit chains would bring back the quadratic bound of the
table above. It is being prototyped and is not part of the function
([ehc-budget.md](../results/design/ehc-budget.md)).

### Integer alternatives

The block stage could use integer NH instead of carry-less products. Three
designs were built to the same `2^-64` target and measured on the Xeon
against the carry-less stage (level-1 stage at 256 KiB; full hash where
one was built):

| Level-1 engine | Stage, B/TSC | Full hash in that lane, B/TSC | Why it stops there |
| --- | ---: | ---: | --- |
| carry-less, ZMM, no shuffle | 31.98 | 24.84 (adjacent pairing, 1 KiB blocks) | the multiply port |
| two-lane NH-32 on `VPMULUDQ` | 16.87 | 16.23 | 8 p0/p5 uops per 64 bytes (add, shift, multiply, add, twice): 4 core cycles, 18.5 B/TSC before any fold; one lane (`2^-32`) runs 28.51 |
| two-lane NH-52 on IFMA | 16.09 | 12.81 | parse-bound: 4 message bytes per 52-bit limb without a cross-lane byte gather (`VPERMI2B`, 2 core cycles), about 16.7 B/TSC, plus the heavy licence |
| scalar NH-64 on `MULX` | 6.45 | — | one product per cycle, serial |
| dual engine, carry-less plus NH | 28.45 / 26.38 / 23.97 at 20 / 33 / 50% NH | — | no overlap: eight wide multiplies plus eight `MULX` cost 2.580 ticks, the sum of the two alone; paired A/B dual/PH 0.93 to 0.98 |

ChainHash itself measures 28.31 B/TSC
([results/64](../results/64/README.md)). The integer designs also cost
proof and key: NH over `Z/2^64` needs a new family of lemmas, keys of 2120
(1104 with Toeplitz) and 4200 bytes against 448 resident, and load-bearing
zero padding (nested-pair bound `2^-31`) that forces a separate short
path; in the dual engine marginal NH bytes cost 2.03× carry-less bytes
([xeon-level1-panel.md](../results/design/xeon-level1-panel.md),
[xeon-level1-ports.txt](../results/design/xeon-level1-ports.txt)).

AES rounds and `lo XOR hi` folds are faster still and are out because
there is no bound: an AES round network is not an almost-universal family,
and a core that compresses before any key enters collides
key-independently, which no final keyed permutation undoes; `lo XOR hi`,
`lo + hi` and truncated products are neither a field reduction nor an
injective pair encoding, so a fixed multiplier plus a fold has no
root-count argument
([smhasher-survey.md](../results/design/smhasher-survey.md)).

### What the SMHasher survey found

A survey of the fast SMHasher loops (XXH3, rapidhash, komihash, Meow,
t1ha, HighwayHash, HalftimeHash, CLHash, UMASH, Polymur, gxhash and
others) classified every technique as A (already used: independent
accumulators, deferred reduction, resident keys, contiguous partner
loads), B (no bound: AES mixing, integer folds, fixed CRC or ARX
recurrences), C (bound-preserving, unmeasured) or D (measured and
rejected: NH-32, IFMA, dual engines). The two C items were measured in one
binary against the shipped loop, median of three:

| | Shipped | C1: guarded prefetch, 16 hints per KiB at +4 KiB | C2: advance the Horner state first, XOR the products into it |
| --- | ---: | ---: | ---: |
| Xeon, 256 KiB, B/TSC | 27.65 | 26.99 (−2.39%) | 28.21 (+2.03%) |
| Xeon, 8 MiB, B/TSC | 10.29 | 10.48 (+1.85%) | 10.31 (+0.14%) |
| M2, 256 KiB, GB/s | 78.41 | 74.46 (−5.03%) | 80.68 (+2.90%) |
| M2, 8 MiB, GB/s | 71.50 | 66.73 (−6.67%) | 76.01 (+6.30%, spread 8.83%) |
| ZMM hot loop, instructions per KiB | 48 | 66 | 46 |
| NEON hot loop, instructions per KiB | 207 | 226 | 207 |

C1 is rejected: it loses on hot buffers on both hosts. C2 is the same
function (XOR is associative), drops two Boolean instructions per KiB on
ZMM, and is measured, not adopted; whether it survives one-shot,
streaming, every tail and every compiler is a separate integration
question. The survey's verdict: beyond C2 and EHC, nothing substantial is
left on the table in this inventory
([smhasher-survey.md](../results/design/smhasher-survey.md)).

### The partial-region tail

The bulk kernels take whole regions, 1 KiB (4 KiB for ChainHash-128); an
input shorter than a region, and the remainder after the last one, is the
tail. In ChainHash-128 a tail that rebuilt every word through a bounded
copy and then ran eight serial Horner steps made 4095 bytes 8.2× slower
than 4096 on the M2 (3.15 against 25.89 GB/s). The tail now loads complete
256-byte chunks directly, pads only the last chunk, skips a pair whose
first word is absent (the [pair presence](#pair-presence) rule) and joins
the lane values with cached powers of y instead of a serial chain: 4095
bytes run at 24.75 GB/s (1.03× from 4096), 512 bytes at 7.86 against 1.70,
and on the Xeon XMM path 4095 bytes at 5.47 against 1.53. The digest is
unchanged and so is bulk throughput
([partial-region.md](../results/design/partial-region.md)).

## Attribution

The long-input loop structure, keyed pair products feeding a running
polynomial state, follows Orson Peters's
[PolymurHash](https://github.com/orlp/polymur-hash#how-it-works-and-why-its-fast).
ChainHash's binary field, comb layout, length placement, key expansion and
finalizer are defined in this repository.
