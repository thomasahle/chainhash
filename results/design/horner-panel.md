# Block-agnostic panel memo (2026-09-18), excerpt

The panel asked whether the implementation block size can be taken out
of the definition. Four proposals (D1–D4) were judged on (1) provable
implementation independence of the digest, (2) a provable bound with a
64-byte random key, (3) expected speed against the then-best 24.86 B/TSC
(Xeon 8375C, adjacent pairs, 1 KiB blocks) and 22.8 B/cycle (M2 Pro,
strided pairs, 256-byte blocks). The winner, D3, is the released
construction: comb layout, Horner in a key word `y` with the byte length
as leading coefficient, lazy 128-bit state. The speeds in section 6 are
that memo's expectations; the released function measures 28.31 B/TSC and
26.26 B/cycle ([results/64](../64/README.md)).

## 1. Bottom line

A twist makes the block size not matter for the implementation; no twist
makes it disappear from the definition. Replacing the chain's
message-dependent multiplier `(b_t + y)` with a constant key multiplier
`y` makes the digest a fixed polynomial identity in the block values, and
every machine choice (SIMD width, number of parallel chains, superblock
or stride, lazy or eager reduction, accumulator count, thread split) is
an evaluation order of that identity. What stays in the definition is one
constant, B0 = 32 words = 256 B, the period of the level-1 key table.
This constant cannot be removed within the 0.5-clmul-per-word class
(section 3) and a large table is fatal on NEON (D2, measured). The winner
makes the 256-byte constant cost nothing on 512-bit hardware, by laying
the four 256-byte blocks of each 1 KiB region into the four lanes of a
ZMM register, and at most about 9% of loop time on 128-bit ISAs, exactly
what the 256-byte strided code already pays. The 64-byte-key scores rise
from 62.415 / 61 to 63.0 / 63.0, the key shrinks from 80 to 64 bytes, and
one function replaces the 256/512/1024-byte variants.

## 2. Ranking

| Rank | Proposal | Digest independence | Fixed / at-most score, key | Xeon ZMM / M2 expectation |
| --- | --- | --- | --- | --- |
| 1 | D3, comb: 256-byte block = one lane of a 1 KiB region, partner offset 8, Horner in y with the length as leading coefficient, lazy 128-bit state | full: stride k, lazy/eager, width, accumulators, streaming all give one digest (verified k in {1,2,3,4,5,8,16}, lengths 0..10000, plus the lane-3 length trick); B0 = 256 B and the comb are definitional | 63.0 / 63.0, 64 B (s, y, c0..c4, tau); exhaustive GF(2^8) sweep on adversarial pairs, no violation, tight at L=2 | 26–28.5 / 24–25.5; XMM 16–17 against 15.4 |
| 2 | D1, pi8 pairing inside 16-word groups, Horner in y, length XORed after the loop, P_0 = 1 | full at the evaluation level; B0 = 256 B definitional | 63.0 / 62.0, 64 B; pinned at 62 by the key-only product s^3 (empty against one word) | 22.1–22.5 (9.5–11% below 24.86) because each 256-byte block sum must be transposed into a lane before the y^k product (about 5 TSC/KiB on p5) |
| 3 | D4, half-block pairing (w_i, w_(i+16)), linear level 2, non-definitional power table | full for level 2; B0 = 256 B definitional | 63.0 / 62.0, 64 B | about 21.8 (−12%) at B0 = 32, same transpose floor as D1 |
| 4 | D2, message-dependent chain kept, adjacent pairing, definitional 8 KiB superblock, 1024-word key table | only for inner chunks; the level-1 accumulator must stay unreduced | 62.415 / 61.678, 80 B; 8 KiB resident key | Xeon 28–29 (measured standalone 29.6) but M2 about 15 B/cycle (−34%): a key table larger than the NEON register file is vector-load-bound |

D1 and D3 are the same idea (fixed-multiplier Horner over 256-byte
blocks); D3 wins on the layout. Its comb makes one ZMM lane one 256-byte
block, so the level-2 step is two zmm clmuls per KiB with no cross-lane
fold, whereas D1 and D4 need a 4×4 lane transpose per KiB that is exactly
the 10–12% they lose. D3 also separates unequal lengths key-free (the
length is the leading coefficient of the Horner polynomial), which is why
its at-most score is 63 rather than the 62 that D1 and D4 are pinned to.

## 3. Impossibility results

1. The message-dependent chain cannot be parallelised or amortised. With
   multiplier M_t = b_t + y, evaluating k blocks in parallel means
   composing affine maps Q → A_t + M_t Q; each composition costs two extra
   field products (2k−1 per k blocks instead of k), plus lane packing on
   x86. The composed multiplier contains the degree-3 monomial
   b_(t+1) b_t P, so no evaluation over 2B words saves a product. Measured
   twice: the M2 batched variant b2/b4/b8 (10.30 against 10.46/10.34/10.31
   B/cycle, no gain) and a Xeon lazy state (latency halved, full hash
   slower). The x86 256 B → 1 KiB gain was latency (multiplies +3%, proxy
   speed +86%, 14.03 TSC per step against 6.9 TSC of block work per
   256 B), so it is recoverable, but only by a level-2 step whose
   multiplier is a key constant.
2. Rigidity. For any keyed function of the form "level-1 pair products
   over a key table of period B, combined with key-only per-block scalars
   lambda_b plus O(1) key-scaled linear functionals per block", if
   lambda_b = lambda_(b+1) identically in the key for some b and
   B/2 > 2c, there is a message pair that collides for every key (mirror
   an even-position difference across the two blocks). Corollary: one
   keyed field product per table period is necessary; an implementation
   evaluating 2B words with one clmul per pair still needs as many
   level-2 products as the B-granular evaluation. Hence B0 must be a
   constant of the definition, and the multiply count per word is at
   least 1/2 + 1/B0. The theorem does not cover arbitrary
   message-dependent combining maps; nobody found a counterexample.
3. An unkeyed F2-linear level-2 step is broken outright: with the key
   table reused across blocks, P ← X^j P + c_t collides with probability
   1 for word differences delta_1, delta_2 = X^j delta_1 in consecutive
   blocks. One keyed multiplication per block is the floor.
4. A key table larger than the NEON register file is load-bound on the
   M2 (measured on six kernel shapes, medians of 7): every kernel
   streaming one key byte per message byte lands at 14.6–15.7 B/cycle at
   256 KiB (18–19.5 with L1-resident data) against 23.8 for the
   resident-256-byte-key loop; the 1 KiB strided function (17.9 against
   22.8) is the same effect. B0 must be at most 32 words for NEON key
   residency (B0 = 64 would stream half the key: plausible, unmeasured).
5. Reduction placement is free only when level 2 consumes the reduced
   value. The message-dependent chain feeds the raw 128-bit split
   (a_t, b_t) into level 2, so reducing the level-1 accumulator early
   changes the digest (traced). D1/D3/D4 consume c_t = raw mod Pi, so
   their reduction placement is genuinely free.
6. The at-most score is pinned at 62.0 for any design that separates the
   empty message from a one-word message at level 1 via the key-only
   product of the first pair (exponent at least 3): D1 and D4 both hit
   E(1) = 4. Separating lengths key-free (D3: length as the leading
   coefficient of the level-2 polynomial) lifts the at-most score to
   63.0; the fixed-length 63.0 needs the characteristic-2 Frobenius root
   count (squaring is injective, so delta_0 s^2 + delta_1 s^4 has at most
   2 roots), which is tight (2q hits found in GF(2^8)).
7. The definitional pairing dissolves the strided-versus-adjacent split.
   Three pairings are shuffle-free on XMM, YMM, ZMM and NEON
   simultaneously: D1's pi8 (partner 8 words later inside 16-word
   groups), D3's offset 8 across a 128-byte chunk, D4's half-block
   (w_i, w_(i+16)). All three pair the same lane of two loads 64 or 128
   bytes apart. The strided pairing costs a p5 cross-lane shuffle on ZMM
   (level 1 alone 19.98 against 31.98 B/TSC) and the adjacent pairing
   costs LD2/EXT on NEON; neither is needed again.

## 6. Cost per word and expected speed

Bulk loop: 0.5 clmul (blocks) + 1/16 clmul (level 2) = 0.5625 clmul per
word, 0 reductions, 0 shuffles, 0 cross-lane extracts; XORs only. Per
256-byte block: 16 block clmuls + 2 level-2 clmuls = 18, the strided
count, minus the PSHUFB/27-folds, the accumulator fold and the 14-TSC
loop-carried chain (now one clmul + one XOR, about 6–8 TSC, and one such
step per lane per KiB at k = 4). Per message: k lane reductions, k − 1
combines, ell y^p (free at k = 4 one-shot), finalizer 3 products + 1
integer add. Table 328–424 B (against 1096 B for the x86 1 KiB key).

| Target | Then-current best | Expected | Basis |
| --- | --- | --- | --- |
| Xeon 8375C ZMM | 24.86 B/TSC (adjacent, 1 KiB, 137 words) | 26–28.5 | same level-1 loop (31.98–33.35 alone) plus 2 zmm clmuls + 1 ternlog per KiB, with the extracts, PSHUFB, broadcast and chain removed |
| Xeon XMM | 15.4 (strided 256) | 16–17 | 18 clmuls per 256 B, chain and shuffles gone |
| M2 Pro NEON | 22.8 B/cycle (strided 256) | 24–25.5 | 43 against 48 SIMD ops per block if issue-bound; about 24 if PMULL-bound (18 against 19) |
| 33–256 B | shipped | −7..−13% (naive) / parity (one-region ZMM trick) | +5 independent xmm clmuls |

Cost B-independence is real on 512-bit hardware (a 256-byte block costs
what a 1 KiB block costs); on 128-bit ISAs the residual is 2 clmuls per
32 words against 2 per 128 for a native 1 KiB function (+9%), which
equals what the 128-bit strided code already pays.

## 8. Rejected

D2's definitional superblock and 1024-word table (M2 −34% measured,
1023-multiplication schedule, level-1 accumulator not freely reducible,
the table a permanent commitment); D4 at B0 = 32 (transpose floor, −12%
Xeon) and its B0 = 64 fix (NEON residency lost, unmeasured); D1's pi8
layout (same algebra as D3 but pays the per-256-byte transpose on ZMM,
and its at-most score is 62). A W = 64 (512-byte) variant of the winner
would halve the 128-bit residual at 2× table and a full-block budget of
64; not recommended for the 64-bit function.
