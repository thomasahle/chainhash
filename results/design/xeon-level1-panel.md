# Level-1 design panel, Xeon Platinum 8375C (2026-09-18)

Excerpt of the panel report on the 64-bit level-1 stage. The raw probe
behind its port model is [xeon-level1-ports.txt](xeon-level1-ports.txt).
The candidates were judged against the goal of at least HalftimeHash-512
(19.29 B/TSC) and XXH3-64 (19.69) under the SMHasher3 bulk protocol, with
a proved bound of the paper's shape and a per-word score of at least 62
bits. All figures are bytes per TSC tick (TSC 2.9 GHz; measured core
clock 3.36–3.43 GHz on the light AVX-512 licence, so one core cycle is
0.863 TSC ticks). The layout, block size and chain in this excerpt are the
lane's (adjacent pairs, 1 KiB blocks, the message-dependent chain); the
released function uses the comb, 256-byte blocks and Horner, and its own
measurements are in [results/64](../64/README.md).

## Verdict

None of the three integer candidates wins on its own merits; the winner
is the by-product of candidate C, a shuffle-free carry-less block stage.
Candidates A (VPMULUDQ NH) and B (IFMA-52 NH) are rejected: both are
slower than the 1 KiB carry-less function already measured (16.36) and
both add the integer-NH proof burden. Candidate C's dual engine is also
rejected, but its port measurements show the ZMM block stage of the
strided layout giving away 37% of the CLMUL ceiling to `VSHUFI64X2` lane
fixups that exist only to preserve that pairing.

## Shuffle-free carry-less block stage (adopted)

| item | value |
| --- | --- |
| level-1 stage, 256 KiB | 31.98–33.35 (pure CLMUL instruction stream 37.15) |
| strided layout, same harness | 19.98 |
| level 1 + chain proxy, one chain step per 1024 B | 26.06–26.18 |
| full hash, implementation lane, B=1024 S=1 | 24.84 / 24.78 (two passes) |
| controls, same box | XXH3-64 19.69–19.82, HalftimeHash-512 19.24–19.39 |
| new lemmas | zero |
| key | 137 words = 1096 B at B=1024 (one key word per 8 message bytes) |

Port model: `VPCLMULQDQ zmm` is 1.7227 TSC for 4 products (2.00 core
cycles) and engages both 512-bit pipes; the "clmul is p5-only" hypothesis
is false on this part (xmm delivers 1 product per core cycle, zmm 4 per 2
cycles; a single port cannot do that). Exactly one extra 512-bit ALU uop
per `VPCLMULQDQ zmm` is free (`+8 vpxorq` and `+8 vpaddd` cost nothing:
1.706 both ways), while `+8 vshufi64x2` costs 2.575, the exact sum of the
two run alone. Cross-lane shuffles are p5-only and serialise fully behind
clmul. Removing them is not a micro-optimisation, it is the whole gap:
19.98 → 31.98.

The chain-frequency proxy (level 1 plus one chain step per block):
14.0 B/TSC at 256 B, 21.4 at 512 B, 26.1 at 1024 B, 28.8 at 2048 B. The
256-byte configuration is feedback-latency-bound and cannot reach 19.7 by
level-1 work alone.

## Candidate A: two-lane integer NH over 32-bit words, VPMULUDQ on ZMM (rejected)

Full verified spec 16.23 (B=1024), 17.44 at 4 KiB blocks; product stage
alone 18.41–18.49. The ceiling is exact and is a port count: per 64
message bytes, per lane, one `VPADDD`, one `VPSRLQ`, one `VPMULUDQ`, one
`VPADDQ` = 4 p0/p5 uops, doubled for the second lane that 2^-64 demands
= 8 uops = 4 core cycles = 16 B/core-cycle = 18.5 B/TSC. That is below
HalftimeHash-512 before a single byte of fold or chain is paid. The
one-lane reference (eps = 2^-32 only) runs 28.51, which is exactly why
XXH3 and HalftimeHash can reach 19.3–19.7: they pay one multiply stream,
not two. Proof cost is the highest of the three: integer NH
almost-Delta-universality over Z_{2^64} with mod-2^32 key addition is
standard (BHKKR, CRYPTO'99) but entirely new for this project; none of the
carry-less lemmas transfer, because the difficulty is the mod-2^w
wraparound, and the both-words-differ case (naive rectangle count gives
2^{-w+1}, truth is 2^-w) is the bulk of the work. Key is 2120 B (1104
with Toeplitz), and full zero padding of the last block is load-bearing
(integer NH's nested-pair bound is 2^-31, not 2^-32, since
Pr[(m+k)(m'+k') = 0 mod 2^64] = (2^33-1)/2^64), which forces a separate
short path below 1024 B. Verified byte-identical on 4297 lengths; the
work is sound, the design is simply capped.

## Candidate B: two-lane integer NH over 52-bit limbs, AVX-512 IFMA (rejected)

Level-1 stage alone 16.26 (1 KiB blocks drop to 11.08 on a gcc codegen
cliff; 14.39 forced-unrolled), best end-to-end full hash 12.81. IFMA fuses
the multiply and accumulate (3 uops per group instead of 4), but the parse
is the wall: a no-unpack parse gets only 4 message bytes per 52-bit limb,
and a fully packed radix-52 parse needs a byte-granular cross-lane gather
(`VPERMI2B`, 2 core cycles), landing at about 17.3 B/core-cycle, 16.7
B/TSC. Beating 19.3 would need at least 6.03 bytes per limb, and no 1-uop
instruction moves bits across qword lanes. On top of that, IFMA density
costs clock: 3.37 GHz at 0% IFMA, 2.80 at 50%, 2.29 at 87.5%, measured
with a dependent add chain; the carry-less stage keeps the light licence,
which is worth about 17% on its own. Key 525 words (4200 B), i.e. 4 key
bytes per message byte streamed from L1. Proof cost is lower than A (NH
cited at w = 52, one new elementary IFMA-exactness lemma, length carried
as data so plain AU suffices) but the speed is not there.

## Candidate C's dual engine (rejected)

The two engines do not overlap. `8 clmulZ + 8 mulx` costs 2.580, the
exact sum of the two alone; the vector partner fares no better at any mix
ratio. Paired A/B, best of 21 interleaved trials: dual/PH = 0.970
(2048+64), 0.952 (2048+128), 0.980 (4096+64), 0.957 (1024+64), 0.930
(512+64); 50/50 gives 23.98 against PH's 33.35. Marginal NH bytes cost
2.03× what PH bytes cost. The one niche where it should have ridden free,
the chain-latency-bound 256-byte configuration, failed too (256 PH + 64
NH with chain 13.63 against 256 PH alone 16.00), because folding the NH
accumulator to one word needs two p5-only cross-lane extracts sitting on
the feedback path. Its epsilon analysis is worth keeping on file: the
disjoint-case argument (PH differs / PH equal and NH differs / both
equal, lengths differ) gives 2^-64 with no reduction term, where the lazy
union bound would have lost a bit.

## Scoreboard

| design | measured full hash | level-1 ceiling | new lemmas | key bytes | short path |
| --- | ---: | ---: | --- | ---: | --- |
| adjacent-pair carry-less | 24.84 | 33.35 (37.15 raw) | 0 | 1096 | unchanged |
| 1 KiB carry-less, strided | 16.36 | 19.98 | 0 | 328 | unchanged |
| 256-byte carry-less, strided | 15.40 | 19.3 (xmm) | 0 | 328 | unchanged |
| A: NH-32 ×2 | 16.23 | 18.49 | 3 (one hard) | 2120 / 1104 | new, mandatory |
| B: NH-52 IFMA ×2 | 12.81 | 16.26 | 5 (one new, easy) | 4200 | new, mandatory |
| C: dual engine | 23.98–32.34 (level 1) | 33.35 | 6 (two new statements) | 2176 | unchanged |

## Not to be revisited (measured, not speculated)

Scalar `MULX` as a second engine (fully serialises behind clmul at every
vector width); any integer-NH stage as the level-1 primitive (2^-64 needs
two multiply streams, which caps it at 18.5 B/TSC); IFMA-52 (parse-bound
at about 16.7 and clock-poor); an XOR lane-fold over integer NH
accumulators (NH is Delta-universal for subtraction mod 2^64, not XOR); a
keyed 128→64 universal reduction of the block output (adds 2^-64 to the
bound and 3 clmuls per block for nothing).
