> Historical design record (2026-09-18), preserved below. Predictions and
> proposed work are not release claims. [SPEC_v3.md](SPEC_v3.md),
> [THEOREM_v3.md](THEOREM_v3.md) and the [measured report](../results/v3/REPORT.md)
> describe the integrated function, bounds and observed performance. The
> original panel artifacts named below are not bundled with this memo.

# Panel memo: making ChainHash independent of the implementation block size

For: Thomas Ahle. From: the design panel (scout brief, four proposals D1-D4, proof + implementation verdicts per proposal). Raw inputs: `panel.json` beside this file. Date: 2026-09-18.

## 1. Bottom line

**Yes, a twist makes the block size not matter for the implementation; no twist makes it disappear from the definition.** Replace the recurrence's message-dependent multiplier (b_t + y) with a constant key multiplier y (Horner / polynomial level 2). Then the digest is a fixed polynomial identity in the block digests, and every machine choice (SIMD width, number of parallel chains, superblock or stride, lazy vs eager reduction, accumulator count, thread split) is an evaluation order of that identity. What stays in the definition is one constant, B0 = 32 words = 256 B, the period of the level-1 key table. The panel proved (section 3) that this constant cannot be removed within the 0.5-clmul-per-word class, and measured (D2) that a large table is fatal on NEON. The winner (D3, "ChainHash-Horner", section 4) makes the 256-B constant cost nothing on 512-bit hardware, by laying the four 256-B blocks of each 1 KB region into the four lanes of a ZMM register, and at most ~9% of loop time on 128-bit ISAs, i.e. exactly what the shipped 256-B code already pays. Expected speed exceeds both current bests (Xeon 26-28.5 vs 24.86 B/TSC; M2 24-25.5 vs 22.8 B/cycle), the model-A key shrinks from 80 to 64 bytes, the chart scores rise from 62.415 / 61 to 63.0 / 63.0, and the Lean proof loses its hardest lemmas (recurrence decoder, three-variable Schwartz-Zippel, nested-pair lemma). One function replaces ChainHash-256 / -512 / -1024.

## 2. Ranking

Criteria in the order asked: (1) provable implementation independence of the digest, (2) provable model-A bound, (3) expected speed against 24.86 B/TSC (Xeon 8375C, x86 adjacent 1 KB) and 22.8 B/cycle (M2 Pro, strided 256 B).

| Rank | Proposal | (1) Digest independence | (2) Model A: fixed / at-most score, key | (3) Xeon ZMM / M2 expectation | Verdicts (proof, impl) |
|---|---|---|---|---|---|
| **1** | **D3 ChainHash-Horner** (comb: 256-B block = one lane of a 1 KB region, Delta=8 pairing, Horner in y with the length as leading coefficient, lazy 128-bit state) | Full: stride k, lazy/eager, width, accumulators, streaming all give one digest (verified k in {1,2,3,4,5,8,16}, lengths 0..10000, plus the lane-3 length trick). B0 = 256 B and the comb are definitional. | **63.0 / 63.0**, 64 B (s, y, c0..c4, tau). Exhaustive GF(2^8) sweep on adversarial pairs: no violation, tight at L=2. | **26-28.5 / 24-25.5** (both above current best); XMM 16-17 vs 15.4. 33-256 B messages ~4 TSC slower unless the one-region ZMM trick is used. | not refuted (high) / not refuted (high on counts, medium on B/TSC) |
| 2 | D1 ChainHash-U (pi8 pairing inside 16-word groups, Horner in y, length XORed after the loop, P_0 = 1) | Full at the evaluation level (traced at 19 lengths, k = 2/4/8, lazy chain). B0 = 256 B definitional. | 63.0 / 62.0, 64 B. At-most pinned at 62 by the key-only product s^3 (empty vs one word). Envelope formula for n >= 2 misstated (fixable: n + 62 + [R >= 25]). | 22.1-22.5 (9.5-11% below 24.86) because each 256-B block sum must be transposed into a lane before the y^k product (~5 TSC/KB on p5); M2 ~22.8 asserted, unmeasured. | not refuted / not refuted (medium) |
| 3 | D4 PowerChain (half-block pairing (w_i, w_{i+16}), linear level 2 V = r^n + sum r^{j-1} c_j, non-definitional power table T) | Full for level 2 (traced: T in {1,4,8,64,256}, thread split, 695 lengths, 0 mismatches). B0 = 256 B definitional. | 63.0 / 62.0, 64 B. Proof exhaustively checked over GF(2^8) at three geometries; constants exactly attained. | ~21.8 (-12%) at B0 = 32 (same transpose floor as D1); "T = 1 table-free" form is actually 25% more clmul work on NEON, T >= 32 needed; M2 +1-6%. Fix is B0 = 64 (Xeon parity) at the cost of NEON key residency. | not refuted (high) / **refuted** (borderline, cost) |
| 4 | D2 ChainHash-T (shipped algebra, adjacent pairing, definitional 8 KiB superblock, k_i = s^{i+1} for 1024 words) | Only for inner chunks <= 8T; T is definitional; the level-1 accumulator must stay unreduced (proposal's "reduce anywhere" is wrong). | 62.415 / 61.678, 80 B, T-independent score; 8 KiB resident key, 1023-multiplication schedule. | Xeon 28-29 (measured standalone 29.6) but **M2 ~15 B/cycle (-34%)**: any key table larger than the NEON register file is vector-load-bound (measured on six kernel shapes). | not refuted (rigidity theorem overclaimed) / **refuted** (measured) |

D1 and D3 are the same idea (fixed-multiplier Horner over 256-B blocks); D3 wins on the layout. Its comb makes "one ZMM lane = one 256-B block", so the level-2 step is two zmm clmuls per 1 KB with no cross-lane fold, whereas D1 and D4 need a 4x4 lane transpose per KB that is exactly the 10-12% they lose. D3 also separates unequal lengths key-free (the length is the leading coefficient of the Horner polynomial), which is why its at-most score is 63 rather than the 62 that D1 and D4 are pinned to.

## 3. Impossibility results the panel established

1. **The shipped recurrence cannot be parallelised or amortised.** With multiplier M_t = b_t + y, evaluating k blocks in parallel means composing affine maps Q -> A_t + M_t Q; each composition costs two extra field products (2k-1 per k blocks instead of k), plus lane packing on x86. The composed multiplier contains the degree-3 monomial b_{t+1} b_t P, so no evaluation over 2B words saves a product (D2, proposition). Measured twice: the M2 batched variant b2/b4/b8 (10.30 vs 10.46/10.34/10.31 B/cycle, no gain) and the rejected Xeon lazy state (latency halved, full hash slower). The x86 256 B -> 1 KB gain was latency (multiplies +3%, proxy speed +86%, 14.03 TSC per step vs 6.9 TSC of PH work per 256 B), so it is recoverable, but only by a level-2 step whose multiplier is a key constant.
2. **Rigidity theorem (D2, confirmed by the proof lens in its class).** For any keyed function of the form "level-1 pair products over a key table of period B, combined with key-only per-block scalars lambda_b plus O(1) key-scaled linear functionals per block", if lambda_b = lambda_{b+1} identically in the key for some b and B/2 > 2c, there is a message pair that collides for every key (mirror an even-position difference across the two blocks). Corollary: one keyed field product per table period is necessary; an implementation evaluating 2B words with one clmul per pair still needs as many level-2 products as the B-granular evaluation. Hence B0 must be a constant of the definition, and multiply count per word is >= 1/2 + 1/B0. Caveat (proof lens): the theorem does not cover arbitrary message-dependent combining maps; for those only the shipped recurrence's 2-products-per-composition fact is proved. Nobody found a counterexample.
3. **An unkeyed F2-linear level-2 step is broken outright** (D3): with the key table reused across blocks, P <- X^j P + c_t collides with probability 1 for word differences delta_1, delta_2 = X^j delta_1 in consecutive blocks. One keyed multiplication per block is the floor, and the shipped design already sits on it.
4. **A key table larger than the NEON register file is load-bound on M2** (D2 impl lens, measured on this machine, medians of 7): every kernel streaming one key byte per message byte lands at 14.6-15.7 B/cycle at 256 KiB (18-19.5 with L1-resident data) against 23.8 for the resident-256-B-key loop; the shipped 1 KB strided function (17.9 vs 22.8) is the same effect. So the "big definitional superblock" route is dead on NEON; B0 must be <= 32 words (256 B) for NEON key residency (B0 = 64 would stream half the key: plausible, unmeasured).
5. **Reduction placement is free only when level 2 consumes the reduced value.** The shipped algebra feeds the raw 128-bit split (a_t, b_t) into level 2, so reducing the level-1 accumulator early changes the digest (traced: different digests). D1/D3/D4 consume c_t = raw mod Pi, so their reduction placement is genuinely free.
6. **At-most score is pinned at 62.0 for any design that separates the empty message from a one-word message at level 1** via the key-only product of the first pair (exponent >= 3): D1 and D4 both hit E(1) = 4. Separating lengths key-free (D3: length as the leading coefficient of the level-2 polynomial) lifts the at-most score to 63.0; the fixed-length 63.0 needs the characteristic-2 Frobenius root count (squaring is injective, so delta_0 s^2 + delta_1 s^4 has <= 2 roots), which is tight (2q hits found in GF(2^8)).
7. **The definitional pairing dissolves the strided-vs-adjacent split.** Three pairings were found that are shuffle-free on XMM, YMM, ZMM and NEON simultaneously: D1's pi8 (partner 8 words later inside 16-word groups), D3's Delta=8 across a 128-byte chunk, D4's half-block (w_i, w_{i+16}). All three pair "the same lane of two loads 64 or 128 bytes apart". The current strided pairing costs a p5 cross-lane shuffle on ZMM (level 1 alone 19.98 vs 31.98 B/TSC) and the adjacent pairing costs LD2/EXT on NEON; neither is needed again.

## 4. Winner: ChainHash-Horner (D3, with grafts) - exact definition

Field F = GF(2)[X]/(Pi), Pi = X^64 + X^4 + X^3 + X + 1, q = 2^64, X^64 = 27 in F. Words are little-endian 64-bit; a message of ell bytes has L = ceil(ell/8) words, the last one zero-padded; w_i = 0 for any partner index i >= L.

**Layout (fixed by the definition).** Index i decomposes uniquely as i = 128R + 16C + 8h + 2j + e with R >= 0 (1 KB region), C in [0,8) (128-byte chunk), h in {0,1} (chunk half), j in [0,4) (lane), e in {0,1}.
- Pairs: (w_i, w_{i+8}) for every present i (i < L) with h(i) = 0. A pair is present iff its first word is present; the partner is zero if absent.
- Block of the pair: t(i) = 4R + j + 1; pair slot pi(i) = 2C + e in [0,16); block positions 2pi (first word), 2pi + 1 (partner).
- So each block is the 32 words {128R + 16C + 8h + 2j + e : C, h, e} of one lane j of one region: W = 32 words = 256 B, four interleaved blocks per 1 KB region, ordered t = 4R + j + 1. p = number of nonempty blocks (p = 1 for the empty message, with c_1 = 0). Nonempty blocks are contiguous 1..p because the lowest index of lane j in a region is 128R + 2j.

**Level 1 (reduced CLNH, one 32-word table kappa_0..kappa_31 shared by all blocks):**

    c_t = SUM_{i : t(i) = t, h(i) = 0, i < L} (w_i + kappa_{2 pi(i)}) (w_{i+8} + kappa_{2 pi(i) + 1})   in F

(carry-less products XOR-summed; reduction mod Pi may happen anywhere). Model A: kappa_m = s^{m+1}, m in [0,32).

**Level 2 (one key word y; no u, no z; the byte length is the leading coefficient):**

    P_0 = ell,   P_t = y P_{t-1} + c_t  (t = 1..p),   V = P_p  =  ell y^p + SUM_{t=1}^{p} c_t y^{p-t}   in F,

with ell read as a field element (ell < 2^64).

**Level 3 (unchanged):** v = V boxplus tau (integer addition mod 2^64); G1 = v^2; G2 = (G1 + c0)(v + G1 + c1); H = (v + c2)(G2 + c3) + c4.

**Key.** Paper model: kappa_0..kappa_31, y, c0..c4, tau = 39 independent words. Model A: s, y, c0..c4, tau = 8 words = 64 random bytes (from 80). Resident expanded table is an implementation choice: 32 PH words laid out as 16 broadcast patterns, [y^k, X^64 y^k mod Pi] per supported stride k, y^1..y^{k-1}, c0..c4, tau: 41-53 words (328-424 B).

**Free for the implementation (digest unchanged, all verified numerically):**
- stride k >= 1: lane j holds blocks t = j (mod k) with multiplier y^k; combine V = SUM_j y^{e_j} R_j + ell y^p, e_j = (p - 1 - j) mod k; at k = 4 one-shot the ell term is simply the initial content of physical lane 3 and the last region's step is masked to the nonempty lanes;
- lazy 128-bit state U with P = U mod Pi and step U <- y^k (x) lo(U) xor (X^64 y^k mod Pi) (x) hi(U) xor C_t, C_t the block's raw 128-bit XOR of products (two independent 64x64 clmuls, no reduction in the loop; one reduction per lane at the end), or eager reduction;
- any number of PH accumulators, any SIMD width, any thread split (V = SUM_chunks y^{start} V_chunk), streaming with ell y^p supplied at finalisation.

**Corrections and grafts folded into the definition text (from the verdicts):**
- Key patterns on ZMM/NEON (impl lens): the first-half load of chunk C is XORed with the broadcast pattern [kappa_{4C}, kappa_{4C+2}] and the second-half load with [kappa_{4C+1}, kappa_{4C+3}] (both words of a 128-bit lane in the first half are "first words", slots 2C and 2C+1). The proposal's [kappa_{2pi}, kappa_{2pi+1}] would compute a different function.
- Tail (grafted from D1's impl lens): a pair is absent iff its first word is absent, so the tail path must mask the KEY words of absent pairs (k-mask on AVX-512, a mask table on XMM/NEON); zero-padding the data alone would leak key-only products. Bulk cost unaffected.
- Proof case (i) (proof lens): "p >= 2 forces ell > 256" is wrong under the comb (p = 2 at 17 bytes); the fact used is ell != 0 whenever p >= 2.
- Mid-length messages (impl lens): for 33-256 B the straightforward path costs ~5 extra independent xmm clmuls (~4 TSC, 7-13% at those lengths); on ZMM absorb the one-region Horner into 2 zmm clmuls with per-lane constants [y^3, 27y^3 | y^2, 27y^2 | y, 27y | 1, 27] plus one 4-lane fold.

## 5. Bound: epsilon(L) and scores

Let p(L) be the block count of an 8L-byte message (p = ceil(L/2) for L <= 8; 4 for 9 <= L <= 16; in general 4R_last + 4 if the last word's chunk index C >= 1, else 4R_last + min(4, ceil(r/2)); asymptotically L/32).

**Paper model (39 independent words):** for all pairs of distinct messages of at most 8L bytes,

    eps(L) = (p(L) + 1)/q

(equal lengths: 1/q + (p-1)/q + 1/q; equal p, unequal length: 0 + p/q + 1/q; unequal p: 0 + N/q + 1/q). Score inf_L log2(L/eps) = 64 - log2 2 = **63.000** at L = 1 (today 62.415).

**Model A (64 random bytes), both fixed length and at-most (d and p are nondecreasing in L, and unequal-length pairs contribute at most (p+1)/q <= (d+p)/q):**

    eps_A(L) = (d(L) + p(L))/q,   d(L) = 1 (L = 1), 2 (2 <= L <= 8), 4 (9 <= L <= 16), 4C+2 / 4C+4 for the last chunk C of region 0 (r = 1 / r >= 2), 32 (L >= 122).

Numerators E_A(L), L = 1..20: 2, 3, 4, 4, 5, 5, 6, 6, 8, 8, 8, 8, 8, 8, 8, 8, 10, 12, 12, 12; L = 32 (256 B): 12; L = 121/128 (1 KB): 36; L = 129: 37; L = 1024: 64; 1 MB: 4128. Today: 256 B fixed 34/q, at-most 64/q; 1 KB 37/q and 67/q; 1 MB 4129/q and 4159/q. Score (both columns) = **63.000** at L = 1, uniquely (L = 2: 63.415, L = 3: 63.585, long L tends to ~69); today 62.415 / 61. The L = 2 figure depends on the Frobenius root-count lemma; without it in Lean the honest headline is 62.68.

Proof shape (all steps checked by the proof lens by hand and by an exhaustive GF(2^8) sweep over (s, y) on structured adversarial pairs, 0 violations, tight at L = 2): level 1 is a univariate root count in s (word difference sits alone at its partner exponent, the position -> exponent map 2pi -> 2pi + 2, 2pi + 1 -> 2pi + 1 is a bijection onto 1..32; paper model: one affine root in the partner key); level 2 is a univariate root count in y (equal-length: degree <= p - 1; unequal length: leading coefficient ell + ell' != 0 or ell != 0, key-free); level 3 unchanged (twist bijection, uniform monic quintic, Theorem 9 composition, 5-wise theorem conditional only on pairwise distinct V). No injectivity of a parameter map, no nested-pair lemma, no three-variable Schwartz-Zippel.

## 6. Cost per word and expected speed

Bulk loop: **0.5 clmul (PH) + 1/16 clmul (level 2) = 0.5625 clmul/word, 0 reductions, 0 shuffles, 0 cross-lane extracts**; XORs only. Per 256-B block: 16 PH clmuls + 2 level-2 clmuls = 18, the shipped strided count, minus the PSHUFB/27-folds, the accumulator fold and the 14-TSC loop-carried chain (now one clmul + one XOR, ~6-8 TSC, and one such step per lane per KB at k = 4). Per 1 KB on ZMM: 18 zmm clmuls, 16 loads, 16 key XORs, 17 ternlogs, 16 broadcast key loads (or 16 resident zmm, as the current 1 KB loop). Per message: k lane reductions, k - 1 combines, ell y^p (free at k = 4 one-shot), finalizer 3 products + 1 integer add. Table 328-424 B (vs 1096 B for the x86 1 KB key).

| Target | Current best | Expected | Basis |
|---|---|---|---|
| Xeon 8375C ZMM | 24.86 B/TSC (x86-1k, 137 words) | 26-28.5 | Same level-1 loop as x86-1k (31.98-33.35 alone) plus 2 zmm clmuls + 1 ternlog per KB, with the extracts, PSHUFB, broadcast and chain removed; cannot be slower by throughput |
| Xeon XMM | 15.4 (strided 256) | 16-17 | 18 clmuls per 256 B, budget 17.2, chain and shuffles gone |
| M2 Pro NEON | 22.8 B/cycle (strided 256) | 24-25.5 | 43 vs 48 SIMD ops per block if issue-bound (48 already includes the shipped recurrence: impl lens corrected the proposal's 55); ~24 if PMULL-bound (18 vs 19) |
| 33-256 B | shipped | -7..-13% (naive) / parity (one-region ZMM trick) | +5 independent xmm clmuls |

Cost B-independence is real on 512-bit hardware (a 256-B block costs what a 1 KB block costs today); on 128-bit ISAs the residual is 2 clmuls per 32 words versus 2 per 128 for a native 1 KB function (+9%), which equals what the shipped 128-bit code already pays. None of these numbers is measured; the qualitative ordering (>= shipped best on both ISAs) is robust because the loop is the current level-1 loop with strictly less level-2 work.

## 7. What changes in the Lean proof

Reused verbatim: `polynomial_zero_count` / `polynomial_probability_le` and `Polynomial.polynomial_collision_bound` (level 2 is literally the polynomial hash over `GaloisField 2 64` with (ell, c_1..c_p) as the message); the finalizer stack (`Finalizer.lean`, `FinalizerIndependence`, `FinalizerKwise.twisted_kwise_uniform`, `MachineTwist` twist bijection); the generic `compose_collision_bound`; `Modulus*` / `GF64*` irreducibility and representation (`reduce_eq_toWord` gives reduce_mul since `AdjoinRoot.mk` is a ring hom); `Probability.lean`; the structure of `SeededPH.differencePoly_coeff` / `ph_equal_groups_bound` (parametric in `exponent`/`partner`).

New (all mechanical; none a new probabilistic idea):
- N1 comb index maps i -> (R, C, h, j, e), t(i), pi(i), partner(pos) as a bijection onto 1..32, re-indexed `ByteEncoding.lean` / `KeyLayout.lean`, and a fresh `partnerExponent_injective` (the current one goes through the strided `pairPositionEquiv`).
- N2 `hornerPoly` difference: nonzero with natDegree <= p - 1 for equal p and equal ell; leading coefficient ell + ell' != 0 (distinct integers < 2^64) for equal p; monic-in-ell of degree max(p, p') otherwise (needs ell != 0 for p >= 2).
- N3 `frobenius_root_count`: roots of h.comp (X^2) <= natDegree h (state it for a general h, per D4's proof lens, not only for s^2 g(s^2)); load-bearing for d(2) = 2 and the 63.0 headline.
- N4 reduced-CLNH universality in F for the paper model: the F-version of `clnh_difference_bound` (difference = delta * kappa_{2pi+1} + const, one affine root). The existing `CLNH.lean` lemmas are over `BitsPolynomial` with a 128-bit target and cannot be reused by a union over preimages of a reduced target (D1's proof lens; D3's proof lens moved this from "carry over" to "new").
- N5 envelope arithmetic: p(L), d(L), E_A(L) = d(L) + p(L), and the fixed/at-most theorems in the main tree (the model-A envelope layer today exists only in the scratchpad lane `codex/lean-chainhash-modelA`).
- N6 new stage-composition wrappers: `chainhash_equal_length_from_stages` / `different_lengths_from_stages` are hard-wired to `Recurrence.hash` with the (u, y, z) key (D1's proof lens); a new `ChainHashModel` with a 39-word `IdealKey` (`idealKey_card` is currently (2^64)^41) and a `ConcreteChainHash` instance for the comb layout.
- N7 (implementation correctness, no probability): stride-k and lazy-representative evaluation equal the Horner definition (ring identity per k plus X^64 = 27).

Dropped for this hash: `Recurrence.lean` decoder (`keyPolynomial_injective`, `decode_keyPolynomial`, slice/lift, fuel), lem:ph:injective, the three-variable lem:ph:sz, `FieldStream.splitWords_injective` / lengthMask, `clnh_natDegree_le`, `clnh_nested_nonzero_bound` as a dependency, `phPoly_group_degree` with g <= 8, and the key words u, z. Keep the recurrence files for the paper's polynomial-evaluation theme.

## 8. Grafts from the runners-up, and what was rejected

Grafted onto D3: the lazy 128-bit state against the packed [y^k, 27 y^k] register (D1 impl lens; D3 already has it, and it is what makes the chain 6-8 TSC); tail key masking (D1 impl lens); the general-h Frobenius lemma (D4 proof lens); non-definitional stride/table (D4's central point: T belongs to the implementation); the x86 kernel-shape lesson that the 8 KiB "14.05" result was codegen and a 1 KB unrolled body with live accumulators is the right structure (D2 impl lens, applies to the k = 4 loop); the rigidity theorem as the justification for keeping B0 in the definition (D2).

Rejected: D2's definitional superblock and 1024-word table (M2 -34% measured, 1023-multiplication schedule, level-1 accumulator not freely reducible, T a permanent commitment); D4 at B0 = 32 (transpose floor, -12% Xeon) and its B0 = 64 fix (NEON residency lost, unmeasured); D1's pi8 layout (same algebra as D3 but pays the per-256-B transpose on ZMM, and its at-most score is 62). A W = 64 (512-B) variant of the winner would halve the 128-bit residual at 2x table and a full-block budget of 64; not recommended.

## 9. Next steps

Decisions for you: (a) accept a digest change (v3: new verification constants, SMHasher3 rerun, blog numbers regenerated); (b) name (ChainHash v3 / ChainHash-H); (c) the Frobenius lemma goes into the Lean scope (otherwise the headline is 62.68).

Lane A, implementation (delegate to Codex per your 2026-09-17 rule):
1. Portable C99 reference of the definition above (word-granular presence with key masking, corrected key patterns), checked bit-for-bit against `scratchpad/d3/check.py` and `scratchpad/d3/lane3.py` on lengths 0..4096 and every 1/2/4 KB boundary.
2. Property test T8': stride k in {1, 2, 4, 8} x lazy/eager x XMM/ZMM/NEON x 2-thread split must agree with the reference.
3. Kernels: ZMM k = 4 (16 broadcast key patterns, lazy state, masked last region, ell seeded in lane 3, one-region trick for 33-256 B); XMM; NEON with inline-asm-pinned PMULL/PMULL2 for the state and accumulator registers (the memory rule: clang's DUP/GPR round trips cost 2x), k = 1 and k = 2 to test the latency co-bound hypothesis; accept 2 key reloads per chunk under register pressure.
4. Measurements: Xeon SMHasher3 bulk, median of 5, with the `hardware.normalcomputing.net` recipe; M2 median of 5 retimed (medians only); per-length speed table 1-256 B; full SMHasher3 run. Gates: Xeon >= 24.86 B/TSC, M2 >= 22.8 B/cycle, SMHasher3 200/200 (if the Zeroes keyset fails, the provable fixes are raising K or a second length slot, never a heuristic mixer).

Lane B, Lean: N1-N7 above; concrete theorem `chainHashHorner_collision_bound` for the 39-word paper model and the 8-word model A, with the envelope theorem; explicit lake targets; report which of the shipped-instance files become dead.

Lane C, after Lane A's gates: appendix v3 text (comb and Delta=8 pairing motivated in one paragraph: shuffle-free on 128/256/512-bit lanes), THEOREM.md / SEEDED_THEOREMS.md tables, verification constants, blog post numbers.

## 10. Open risks carried forward

Speed is modelled, not measured, on both machines (Xeon 26-28.5, M2 24-25.5); the unexplained 2 TSC/KB proxy-vs-full gap on Xeon may persist. SMHasher3 record not re-established (length now enters as ell y^p, a random multiple, analogous to the shipped mechanism). Streaming APIs pay popcount(p) multiplications for ell y^p at finalisation. Degenerate keys y = 0, s = 0 are inside the bound as single keys. A model-B-style derivation of y or tau from s has no bound yet. A 1024-bit ISA pays one lane-pair fold per 2 KB.
