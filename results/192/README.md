# ChainHash-192 measurements

ChainHash-192 (`chainhash192.h`) against ChainHash-256 (`chainhash256.h` as of commit 3aaabab) with its
digest truncated to 24 bytes, one-shot hashes of 4 KiB to 16 MiB and dependent short-input latency, both
functions in the same binary. ChainHash-192 was built to be faster than ChainHash-256 truncated to 192 bits;
truncation itself costs nothing, so ChainHash-256 is the baseline.

The function: a pseudo-dot-product over GF(2^192) (f = x^192 + x^7 + x^2 + x + 1) with a power key (masks
s^1..s^176), 4096-byte blocks of 88 pairs stored contiguously (chunks of 8 pairs as six 64-byte rows; the last
256 bytes hold 8 pairs with zero top limbs), ChainHash-256's two-level outer stage (regions of 8 block values,
independent chain key z) and its degree-5 finalizer, a 24-byte digest and a 216-byte key ([SPEC-192.md](../../docs/SPEC-192.md)).
Karatsuba-3 needs 6 carry-less products per 48-byte pair against ChainHash-256's 9 per 64 bytes, 1.125× fewer
products per byte, and the block size keeps every power-of-two input of 4 KiB and up free of partial blocks
(4 KiB = 1 block, 64 KiB = 2 regions).

## Method

Three hosts: an Intel Xeon Platinum 8375C (Ice Lake-SP), an AMD EPYC 9R14 (Zen 4) and an Apple M2 Pro.
Compilers: clang 21 and gcc 11 on the Xeon, gcc 11 on Zen 4, Apple clang 17 on the M2. Each length is timed in
interleaved rounds (ChainHash-192, then ChainHash-256); the ratio is ChainHash-192's throughput over
ChainHash-256's in the same round, and a pass reports the median ratio over 13 rounds. Several passes
(processes) per host; a cell is the range over passes. x86 figures are bytes per TSC tick (2.9 GHz on the Xeon,
2.6 GHz on Zen 4); the M2 is in GB/s. The Xeon is a shared machine (load average 18–28 during these runs).

The measurements ran on a header that differs from the released one in one parameter qualifier (`const` dropped
in `c192x_bend8` for ISO C `-pedantic`): the x86 object code is byte-identical (gcc 11, clang 21 and gcc 9) and
the NEON code is unchanged.

## Bulk throughput against ChainHash-256

| Host, compiler (passes × rounds) | 4 KiB | 16 KiB | 64 KiB | 256 KiB | 1 MiB | 16 MiB |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| M2 Pro, Apple clang 17 (10 × 13) | 1.174–1.216× | 1.295–1.324× | 1.153–1.166× | 1.161–1.183× | 1.138–1.167× | 1.077–1.098× |
| (pass 1, GB/s: 192 vs 256) | 39.24 vs 32.12 | 46.80 vs 35.59 | 49.20 vs 42.47 | 48.11 vs 40.89 | 48.48 vs 42.13 | 46.42 vs 42.20 |
| Xeon 8375C, clang 21 (3 × 13) | 1.223–1.237× | 1.182–1.186× | 1.109–1.114× | 1.110–1.111× | 1.111–1.113× | 1.087–1.111× |
| (pass 1, B/tick) | 10.63 vs 8.60 | 12.79 vs 10.78 | 14.40 vs 12.99 | 14.72 vs 13.27 | 14.76 vs 13.28 | 10.51 vs 9.35 |
| Xeon 8375C, gcc 11 (3 × 13) | 1.130–1.149× | 1.133–1.145× | 1.119–1.136× | 1.118–1.128× | 1.121–1.128× | 1.091–1.099× |
| (pass 1, B/tick) | 9.83 vs 8.69 | 12.23 vs 10.79 | 13.97 vs 11.94 | 14.34 vs 12.83 | 13.96 vs 12.33 | 9.70 vs 8.57 |
| Zen 4, gcc 11 (3 × 13) | 1.129–1.154× | 1.105–1.113× | 1.124× | 1.113–1.118× | 1.098–1.124× | 1.106–1.108× |
| (pass 1, B/tick) | 12.98 vs 11.50 | 15.23 vs 13.78 | 17.00 vs 15.13 | 17.32 vs 15.49 | 17.17 vs 15.28 | 16.93 vs 15.31 |

At 1 MiB that is 42.8 GB/s on the Xeon with clang (ChainHash-256: 38.5), 40.5 with gcc (35.8), 44.6 GB/s on
Zen 4 (39.7) and 48.5 GB/s on the M2 (42.1). Every pass of every cell is above 1. On the Xeon, 16 MiB is
memory-bound (single-core streaming read 12.1–12.4 bytes per tick) and depends on the other tenants: an earlier
round with the same prefetch schedule measured 1.03–1.11× over 24 passes (median 1.067). The M2 ran with
background load during the first set of passes (absolute GB/s about 3% lower; ratios within ±1%) and was
repeated.

## Dependent latency

SMHasher3's timehash_small pattern: the first output word feeds the first input bytes of the next call. Median
of 21 trials × 4000 calls, minus the empty-call loop; both functions in one binary. The forced-PCLMUL rows are
the backend that SMHasher's reference machines (Zen+ and Zen 2) run.

| Host, compiler | Unit | 16 B | 64 B | 256 B | 1 KiB | 1–31 B average |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| M2 Pro, Apple clang | ns | 24.4 vs 26.3 | 24.3 vs 28.0 | 30.2 vs 34.0 | 40.9 vs 47.8 | 24.4 vs 27.2 |
| Xeon, clang 21 | TSC ticks | 91.9 vs 115.4 | 96.8 vs 122.4 | 154.8 vs 200.6 | 192.5 vs 239.2 | 93.8 vs 116.6 |
| Xeon, gcc 11 | TSC ticks | 98.4 vs 123.0 | 101.6 vs 133.8 | 180.3 vs 199.2 | 210.9 vs 231.6 | 99.0 vs 123.6 |
| Zen 4, gcc 11 | core cycles | 109.9 vs 142.0 | 125.5 vs 164.0 | 168.2 vs 200.6 | 216.6 vs 246.6 | 110.8 vs 143.3 |
| Xeon, gcc 9, forced PCLMUL | TSC ticks | 124.0 vs 568.8 | 139.1 vs 570.3 | 257.5 vs 573.4 | 366.4 vs 617.1 | 168.9 vs 797.5 |
| Xeon, clang 21, forced PCLMUL | TSC ticks | 112.5 vs 349.0 | 127.1 vs 352.0 | 198.8 vs 353.8 | 322.2 vs 415.5 | 116.6 vs 358.5 |
| Zen 4, gcc 11, forced PCLMUL | core cycles | 148.6 vs 695.2 | 166.3 vs 691.2 | 347.3 vs 696.7 | 562.1 vs 814.5 | 150.3 vs 688.5 |

ChainHash-192 first, ChainHash-256 second; Zen 4 cycles are `perf` core cycles. On x86, lengths 1–15 are about
91 ticks (clang), and 3 bytes is about 11 cycles slower than 2 or 4 (byte 2 is a separate one-byte load).
ChainHash-256's forced-PCLMUL short path costs about 690 cycles at every length up to 1 KiB on Zen 4 in this
harness, which is why those rows differ by 3–5×. The Xeon forced-PCLMUL rows for 16–1024 bytes and for the
1–31-byte average were taken minutes apart under different load; compare within a row. One cell moved the wrong
way in the last round: Xeon gcc 11 at 256 B was 166.4 ticks before it and 180.3 after (a two-binary A/B on the
shared machine gave 166–190 against 174–175, inside the noise but probably a few ticks worse).

## Forced PCLMUL (xmm) backend

Both functions forced to their PCLMULQDQ + SSE4.1 backends (`CH192_PCLMUL`, `CH256_PCLMUL`), same binary, 11
rounds; ChainHash-192 over ChainHash-256:

| Compiler | 4 KiB | 16 KiB | 64 KiB | 256 KiB | 1 MiB | 16 MiB |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Xeon, gcc 9.5 | 1.804× | 1.557× | 1.333× | 1.312× | 1.317× | 1.499× |
| Xeon, gcc 11.5 | 1.689× | 1.529× | 1.316× | 1.301× | 1.337× | 1.566× |
| Xeon, clang 21 | 1.460× | 1.400× | 1.266× | 1.252× | 1.310× | 1.562× |
| Zen 4, gcc 11 | 1.486× | 1.337× | 1.279× | 1.259× | 1.272× | 1.249× |

## Against the port bound

| Host | ChainHash-192 | ChainHash-256 |
| --- | --- | --- |
| Zen 4, gcc 11, 1 MiB, PMU core cycles | 83.3–83.7 cycles/KiB: 93% of a port model at 77.5, about 98% of the bound calibrated by probing the sweep's instruction mix (about 81.8). The block sweep alone: 77.3–79.0 against its calibrated 77.4 | 93.1–93.6 cycles/KiB (90.5% of its model bound 84.6) |
| Xeon, 1 MiB (single-step trace of one call, calibrated port model; no PMU on this VM) | bound 77.5 cycles/KiB (binding ports 0 + 5); clang 80.0 (96.9%), gcc 81.2 (95.4%); 128 / 132 instructions per KiB | bound 84.9 / 84.6; clang 89.1 (95.3%), gcc 91.2 (92.8%); 151 / 166 instructions per KiB |
| M2 (static count of the sweep: a fused PMULL + EOR is one slot, 4 SIMD slots per cycle, 3.49 GHz) | 32.52 slots per 128 B, a 54.9 GB/s bound; 50.4–50.6 GB/s measured at 64 KiB–1 MiB: 92% | 37.28 slots, 47.9 GB/s; 42.6–43.9 measured: 89–92% |

The port model prices a zmm `vpternlogq` like a `vpxorq` under carry-less-multiply load, which is optimistic on
Zen 4. A probe of the sweep's exact chunk mix (independent operations, PMU cycles): 12 clmul + 18 xor take 27.0
cycles, 12 clmul + 18 ternlog 29.2, the real mix (12 clmul, 6 loads, 6 xor with a memory operand, 6 xor,
6 ternlog) 28.6, and accumulating with xor only (24 xor) 30.0. Six products per pair are the minimum (the
bilinear rank of 3-term multiplication over GF(2)), every clmul operand needs one ALU operation and every two
products one three-input XOR.

## The last round, before and after

The last optimization round changed schedules, the key storage and the key setup only; the digests are those
of the round before (`test/192/vectors.txt` regenerates byte-identical). ChainHash-256 in parentheses.

| Metric | Before | After |
| --- | --- | --- |
| M2 latency 16 B / 64 B / 1–31 B average (ns) | 26.6 / 26.9 / 26.95 (27.5 / 29.6 / 27.72) | 24.4 / 24.3 / 24.4 (26.3 / 28.0 / 27.2); a second run 25.3 / 24.6 / 24.8 (27.7 / 28.1 / 27.5) |
| Xeon clang latency 16 B / 64 B / 1–31 B average (ticks) | 109.8 / 110.2 / 111.9 (113.6 / 121.9 / 115.4) | 91.9 / 96.8 / 93.8 (115.4 / 122.4 / 116.6) |
| Xeon gcc latency 16 B / 64 B / 1–31 B average (ticks) | 109.7 / 117.1 / 111.9 (122.8 / 130.5 / 123.2) | 98.4 / 101.6 / 99.0 (123.0 / 133.8 / 123.6) |
| Zen 4 latency 16 B / 64 B / 1–31 B average (cycles) | 126.5 / 131.7 / 128.5 (143.0 / 165.0 / 143.9) | 109.9 / 125.5 / 110.8 (142.0 / 164.0 / 143.3) |
| forced PCLMUL throughput ratio, Zen 4 gcc 11, 64 KiB / 1 MiB | 1.230 / 1.232 | 1.279 / 1.272 |
| forced PCLMUL throughput ratio, Xeon gcc 9, 64 KiB / 1 MiB | 1.303 / 1.278 | 1.333 / 1.317 |
| bulk ratio 64 KiB–1 MiB (M2 / Xeon clang / Xeon gcc / Zen 4) | 1.16–1.19 / 1.11–1.12 / 1.12–1.13 / 1.10–1.12 | unchanged within noise |
| key setup, Zen 4 AVX-512 / PCLMUL; M2 (µs) | 4.7 / 3.8; 2.6 | 2.5 / 2.0; 1.1–1.2 (ChainHash-256: 2.6; 2.8) |
| expanded key at malloc + 8 or plain `malloc` (Xeon, AVX-512) | segmentation fault | correct, full speed |

What changed:

1. **Finalizer twist by carry-select, every backend.** Both candidate squares of every limb, s_i² and
   (s_i + 1)² (s_i + 1 = v_i + (tau_i + 1), precomputed), start right after the limb additions, and a bitwise
   select picks one when the carries are known (NEON: one `BIT`; x86: ternlog or and-andnot-or). On NEON the
   masks are hidden from clang, which otherwise narrowed them and lowered the select to three instructions
   (slower than before until fixed). M2: 0.8–1.8 ns lower at every length.
2. **Short inputs: the first 16 bytes enter last and in two parts.** Bytes 0..3 (what a dependent caller has
   just written) by one load of at most 4 bytes, the rest only from higher addresses, multiplied separately (the
   products are linear). On x86 a 16-byte or masked load over a pending 4-byte store does not store-forward; a
   4-byte load does. On the M2 a GPR byte assembly plus `fmov` costs about 8 cycles, so bytes 0..3 go straight
   into a vector register. Same binary against the round before (n ≤ 64 path): Xeon AVX-512 clang 109.7 → 93.6
   ticks, gcc 112.4 → 97.0; Xeon PCLMUL clang 128.8 → 115.9, gcc 132.7 → 123.2; Zen 4 AVX-512 129.1 → 113.1
   cycles, PCLMUL 150.9 → 139.2.
3. **Expanded key at any alignment.** The key storage types are vector types with 8-byte alignment and every key
   load is unaligned-capable; the x86 tables sit at a 64-byte-aligned offset chosen when the key is initialized,
   so they are aligned wherever it was initialized, and a key moved by `memcpy` stays correct. The PCLMUL
   full-block sweep exists twice (out of line under gcc), dispatched on the table alignment, so an aligned key's
   rows stay memory operands of `pxor` (legacy SSE cannot take an unaligned one). No measurable cost (without the
   self-aligning store: about 1% on Xeon AVX-512 and 2–5% on the xmm path).
4. **PCLMUL sweep: low-register-pressure statement order** (at most 14 xmm registers live; gcc allocates in
   source order and the all-loads-first order spilled). With item 3's out-of-line sweep: Zen 4 gcc 11 xmm
   +4–5%, Xeon gcc 9 +1–2%, gcc 11 and clang equal.
5. **Key setup: four interleaved power chains with each backend's multiply inlined** (before: 176 sequential
   multiplies through a function pointer). Zen 4: the derivation 3.1 → 0.87 µs.

Measured and not adopted:

- Zen 4 sweep schedules: 48 inline-assembly schedules of the block sweep (point order, ternlog lag, operand
  preparation one chunk ahead or not, early or late u/v XORs) were all slower than gcc's own order (best 79.8 /
  84.4 against 77.3 / 81.5 cycles/KiB at 4 KiB / 1 MiB). Compiler flag variants (`-mtune=znver3`,
  `-mtune=icelake-server`, scheduling options) were equal or worse; a two-block sweep (`-DC192X_SW=2`) equal.
- Region fold rewrites (unpack-first, valign or blend folds): counted, no fewer operations than the current 20
  per point (the region overhead is about 3.7 of 83.5 cycles/KiB). Not built.
- NEON lazy reduction of the finalizer's middle product: estimated −3 of about 85 cycles. Not built.
- Local accumulators in the AVX-512 partial-block sweep: +70 ticks at 256 B under gcc. Reverted.
- Earlier rounds: a Karatsuba-3 finalizer multiply on x86 (`-DC192X_FINM=1`, no faster), T1/T2 prefetch hints
  alone, 8 and 12 KiB prefetch distances, three-register key loads on NEON (0.95× in the sweep
  microbenchmark), a vector twist on NEON (equal).

## Design and schedule decisions

Every schedule below gives the same digests; each was measured.

1. **Layout: contiguous blocks, lanes = pairs**, not ChainHash-256's region-interleaved limb rows. In an M2
   sweep microbenchmark both layouts reach the 4-slot bound in L1 (54.6–54.9 GB/s), but at 1 MiB contiguous
   blocks stream at 53.2 GB/s with no software prefetch against 44.5 (50.9 with prefetch) for interleaved rows.
   On zmm the price is a 4-lane fold per block, done for all 8 blocks of a region at once (2% on Zen 4).
2. **4096-byte blocks** (88 pairs, the last 8 with zero top limbs, 5 data products each) rather than 64 or 128
   pairs: every power-of-two size from 4 KiB has no partial block, for 1.6% extra work per block. An earlier
   192-bit layout with 3 KiB blocks ran 1.07× ChainHash-256 at 48 KiB (whole regions) but 0.95× at 64 KiB on
   the M2 and 0.69× at 4 KiB (a 1 KiB tail block); with 4096-byte blocks the 4 KiB and 64 KiB cells are 1.16× on
   the M2.
3. **NEON sweep: two blocks per pass sharing the key vectors** (12 accumulators; two blocks 54.6 GB/s, one 53.1,
   four 52.7), with pinned EOR and fused PMULL + EOR as in ChainHash-256.
4. **NEON: opaque loop addresses.** LLVM's loop data prefetch pass (on for Apple CPU tuning) inserted `prfm`
   8 KiB ahead in every message loop; near the end of the input these hit unmapped or TLB-cold pages and cost
   about a page walk each: 17–20 GB/s instead of 51 in 10 of 10 processes when a guard page followed a 64 KiB
   message. An empty `asm` on each loop's base pointer removes them. ChainHash-256 is not affected.
5. **NEON: an opaque key-table pointer per sweep** (clang copied the 4.2 KiB table to the stack once per region)
   and a step barrier (no spill stores in the sweep).
6. **AVX-512 sweep: one block, straight-line chunks, key rows as memory operands, explicit accumulator copies**
   (gcc compiled an array copy as `rep movs` 8 times per region: Zen 4 gcc 1.035× → 1.11×).
7. **Intel prefetch** (chosen per key by CPUID vendor; none on AMD): every line of the block 6 KiB ahead into L1,
   pinned in front of each chunk's loads, plus the first two lines of the block 16 KiB ahead into L2, only for
   blocks inside the input. Xeon 16 MiB: none 0.90–0.97×, L1 only 1.00–1.07×, both 1.07–1.12×; 64 KiB–1 MiB
   unchanged. On Zen 4 any prefetch costs 2–9%.
8. **SSE sweep: local accumulators** (gcc stored the accumulator array every step, aliasing the key table):
   Zen 4 xmm 1.04× → 1.21–1.43×.
9. **Short inputs**: n ≤ 64 directly (V = n z + C0 + Σ d_t l_t); one block chunk by chunk with key-only suffix
   sums; a partial chunk with x words only as a linear form; full chunks by plain loads, only the last one
   masked, no stack round trip.

## Tests

`make test-192` runs every backend against the reference `c192_hash_ref` (one-shot and streaming with random
split points and a one-byte dribble, lengths 0..700, every chunk, block and region edge ±1, multi-region lengths,
offsets 0/1/3/7, two seed keys and the raw key as bytes and as words, the frozen vectors, inputs flush against
PROT_NONE pages on both sides), builds with no ISA flags and portable-only, the schedule variants
(x86: `-DC192X_PF_FORCE=0/1`, `-DC192X_FINM=1`, `-DC192X_SW=2`; AArch64: `-DC192N_FIN_GPR=1`,
`-DC192N_SBAR=0`, `-DC192_NOASM`), 300 random raw keys with edge limbs (`xcheck.c`), the fast finalizers on
crafted twist carry patterns (`ftest.c`), keys in place at malloc + 0..63 and relocated by `memcpy` (`align.c`),
and the independent Python implementation against the 168 frozen vectors (`pyref.py`). `make certs` runs the
certificates of [THEOREM-192.md](../../docs/THEOREM-192.md). During development the same programs ran for every
schedule variant on the M2 (Apple clang 17, Homebrew clang), the Xeon (clang 21, gcc 11, gcc 15, gcc 9) and
Zen 4 (gcc 11), and the header compiled without warnings as C99 with `-pedantic -Wall -Wextra` (M2 clang; Xeon
gcc 11, clang 21, gcc 9) and as C++17.

## Open items

- SMHasher3: a 192-bit entry with the seed model used for the other widths, and a run on the reference
  compilers (the PCLMUL path above is what they time).
- Lean: not started; the argument is ChainHash-256's with a new level-1 layout.
- ChainHash-256's forced-PCLMUL short path (about 690 cycles at every length up to 1 KiB on Zen 4) is what
  SMHasher3's small-key timing of ChainHash-256 measures on its reference machines.
- Not done: NEON software prefetch in the full hash (`C192N_PF`, off by default), a rework of the Xeon 16 MiB
  prefetch, and the SSE partial chunk, which still goes through a zero-padded 384-byte stack buffer (tails only,
  not on the dependent path).
