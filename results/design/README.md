# Design records

The measurements and panel excerpts behind
[docs/DESIGN.md, "Alternatives considered"](../../docs/DESIGN.md#alternatives-considered).
Each file says which lane it comes from by date. Host placeholders follow
[results/README.md](../README.md): `<xeon>` is the Xeon Platinum 8375C
host, `<scratch>` a scratch checkout. Units: Xeon "cycles" are invariant
TSC reference ticks (2.9 GHz), M2 "cycles" are SMHasher3's calibrated
estimates or, in the raw microbenchmarks, the harness's own calibration;
none is a core-cycle counter, and cross-host ratios are not meaningful.

| Record | Contents | Lane |
| --- | --- | --- |
| [xeon-level1-ports.txt](xeon-level1-ports.txt) | verbatim probe: isolated reciprocal throughputs, core clock under each engine, instruction mixtures, level-1 variants (carry-less with and without the shuffle, two-lane NH-32, IFMA-52, MULX, dual engines, chain spacing), paired A/B trials | 2026-09-18, level-1 engine probe |
| [xeon-level1-panel.md](xeon-level1-panel.md) | excerpt of the level-1 design panel: verdict, port model, why NH-32, IFMA-52 and the dual engine are rejected, scoreboard | 2026-09-18 |
| [m2-adjacent-pairing.md](m2-adjacent-pairing.md) | adjacent-pair NEON kernels against the strided control on the M2; LD2 against LDP+EXT | 2026-09-19 |
| [horner-panel.md](horner-panel.md) | excerpt of the block-agnostic panel memo: ranking, impossibility results, cost model, what was rejected | 2026-09-18 |
| [ch128-two-chains.md](ch128-two-chains.md) | 128-bit predecessor lane: native GF(2^128) against two 64-bit chains, 256 against 512-byte blocks, chain-latency ceilings, score arithmetic; the comb kernels' block-size table | 2026-09-18 and 2026-09-19 |
| [smhasher-survey.md](smhasher-survey.md) | technique classification, hot-loop counts and the C1/C2 experiments | 2026-09-19 |
| [partial-region.md](partial-region.md) | ChainHash-128 partial-region tail before and after | 2026-09-19 |
| [ehc-budget.md](ehc-budget.md) | multiply and XOR budget of an encode-hash-combine block stage; an analysis, not a measurement | 2026-09-19 |

The released functions' own measurements are in [results/64](../64/README.md)
and [results/128](../128/README.md); the records here compare alternatives
and often use the lane's own layout, block size or chain, which the text
of each record states.
