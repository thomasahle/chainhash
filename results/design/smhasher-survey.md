# SMHasher technique survey (2026-09-19), excerpt

A survey of the fast SMHasher loops (XXH3, rapidhash, wyhash, komihash,
MeowHash, t1ha, HighwayHash, HalftimeHash, CLHash, UMASH, Polymur,
gxhash, aHash, foldhash, a5hash, MuseAir, NMHASH, CRC-PCLMUL and others)
asked which of their techniques could still speed up ChainHash while
keeping its bound. One small scheduling change (C2) merits a full
integration lane; the survey found no unclaimed structural shortcut with
a proved bound. Timings are research evidence, not an adoption of new
production code.

## Technique assessment

Classes: A, already used; B, no bound; C, unmeasured and bound-preserving
(C1 and C2 measured below); D, measured earlier and rejected.

| Technique found in the fast loops | Class | Consequence for ChainHash |
| --- | --- | --- |
| Independent accumulators, unrolling, product work before a dependent combine (XXH3, rapidhash, Meow, Aqua, lanehash, a5-128) | A | The four chains of the ZMM/NEON bulk path already expose ILP. More named accumulators alone do not reduce arithmetic. |
| Raw product accumulation, deferred reduction, precomputed multipliers/powers (CLHash, UMASH, Polymur, VHASH) | A | Exactly the CLNH/lazy-Horner structure already used. |
| Contiguous partner streams, no bulk shuffle, unaligned loads, endpoint/tail specializations | A/D | The comb already gives contiguous partner loads without EXT/transpose. Other hashes' overlapping tails transfer only if the exact byte polynomial and length encoding are preserved. Adjacent/strided revisits are settled. |
| PCLMUL/VPCLMUL, PMULL/PMULL2, EOR3 and ternary XOR | A | Already used. No IFMA bulk hash was found that bypasses the measured limb/strength cost. |
| Explicit guarded software prefetch (Meow, XXH3, komihash, t1ha, Pippip, CRC) | C1 | Preserves all arithmetic and key bytes. Tested: 16 L1 hints per KiB at +4096, only while the addresses remain in the input. Rejected below. |
| Advance the chain first and accumulate products directly into it | C2 | Preserves the raw polynomial, removes four separate block accumulators, and saves two Boolean instructions per KiB in the ZMM build. |
| AES/VAES mixing (gxhash, Meow, Aqua, Falk, lanehash, aesni, t1ha0, aHash) | B | Fast nonlinear instructions do not establish an almost-universal family; several cores compress without any key before seed injection, and a final keyed permutation cannot undo an earlier key-independent collision. |
| `lo^hi`, `lo+hi`, integer high-half feedback, truncated products (wy/rapid/fold/mum/a5/MuseAir/NM/Highway) | B | Not a field reduction or an injective pair encoding. Multiplication by a fixed constant plus folding has no root-count bound. |
| Odd-multiply/xorshift permutation after an already proved hash | A | A proved bijection preserves collision probability but is not a replacement proof for the core; the finalizer also supplies the five-wise property, which a cheaper permutation would surrender, and it saves nothing in the bulk stage. |
| Fixed CRC polynomial or fixed ARX recurrence (City/Farm/Spooky/Fast) | B | Fixed message collisions or an unproved nonlinear recurrence cannot use the random-key root argument. |
| NH32, IFMA52, mixed integer/carry-less engines, more expensive pair extraction | D | Already measured ([xeon-level1-panel.md](xeon-level1-panel.md), [m2-adjacent-pairing.md](m2-adjacent-pairing.md)). |
| Halftime error-correcting encoding and rank-controlled combine | C-reserved | Compatible only with the independent-key and rank/fibre proof; the EHC lane owns this structural opportunity. |
| UMASH shared products / twisted second hash; Toeplitz reuse | B as a drop-in | Reusing products is not the same as obtaining independent 64-bit outputs; a joint collision theorem is required. |

Bytes per multiply: wyhash/rapidhash/foldhash obtain 16 B per full
integer product, but their folded cores do not establish ChainHash's
bound. ChainHash's block stage also obtains 16 B per 64×64 carry-less
product; including its eight lazy chain products per KiB gives
1024/72 = 14.222 B per product, packed four per ZMM instruction (18 wide
instructions per KiB). XXH3 obtains 8 B per 32-bit lane product before
scramble; Halftime's distance-two leaf obtains 48/7 = 6.857 B per 32-bit
product.

## Actual hot-loop instructions per KiB

Counted in the compiled binary. No AES, integer multiply, explicit lane
shuffle, stack access or key load appears in any of these hot loops;
keys and multipliers are resident from setup.

| ZMM Xeon | Shipped | C1 prefetch | C2 chain-first |
| --- | ---: | ---: | ---: |
| VPCLMULQDQ (four 64×64 products each) | 18 | 18 | 18 |
| VPXORD | 21 | 21 | 17 |
| VPTERNLOGQ | 6 | 6 | 8 |
| 64-byte memory operands (folded into XORs) | 16 | 16 | 16 |
| PREFETCHT0 | 0 | 16 | 0 |
| Pointer/loop/guard instructions | 3 | 5 | 3 |
| Total hot-loop instructions | 48 | 66 | 46 |

| NEON M2 | Shipped | C1 prefetch | C2 chain-first |
| --- | ---: | ---: | ---: |
| PMULL / PMULL2 | 36 / 36 | 36 / 36 | 36 / 36 |
| LDP of two 16-byte vectors | 32 | 32 | 32 |
| EOR | 64 | 64 | 68 |
| EOR3 | 36 | 36 | 32 |
| PRFM | 0 | 16 | 0 |
| Pointer/loop/guard instructions | 3 | 6 | 3 |
| Total hot-loop instructions | 207 | 226 | 207 |

C1: at the start of each 1 KiB iteration, 16 hints, one per 64-byte line
in the region starting 4096 B ahead, when more than four regions remain.
C2: for each raw state `(lo, hi)`, first compute
`P = clmul(lo, y^4) XOR clmul(hi, 27*y^4)`, then XOR each block product
into P as it becomes available; the shipped schedule builds separate
block accumulators C and then computes `P XOR C`. Associativity and
commutativity of polynomial addition make the two identical, including
unreduced high bits, so the function, key model and bound are unchanged.

## Experiments

Method: a minimal adaptation of the repository's `test/speed.c`
approach, not an SMHasher3 run. Control and both candidates are functions
in the same binary with the same data, keys and calling convention;
256 KiB and 8 MiB buffers, offsets 0/1/7/15/16/31/32/63, 64 MiB processed
per sample, four warmup calls, three rounds with rotating variant order;
the mean of the eight alignment throughputs per run, then the median of
the three run means. Xeon: GCC 11.5.0, `-O3 -march=native`, ZMM, one
pinned core. M2: Apple Clang 17, `-O3 -mcpu=apple-m2`, one thread.

| Host / size | Variant | Median | Versus shipped | Three-run spread |
| --- | --- | ---: | ---: | ---: |
| Xeon 256 KiB, B/TSC | shipped | 27.6484 | — | 0.64% |
| | C1 prefetch | 26.9878 | −2.39% | 0.26% |
| | C2 chain-first | 28.2103 | +2.03% | 0.55% |
| Xeon 8 MiB, B/TSC | shipped | 10.2930 | — | 0.06% |
| | C1 prefetch | 10.4839 | +1.85% | 0.13% |
| | C2 chain-first | 10.3075 | +0.14% | 0.26% |
| M2 256 KiB, GB/s | shipped | 78.4104 | — | 0.86% |
| | C1 prefetch | 74.4644 | −5.03% | 2.14% |
| | C2 chain-first | 80.6814 | +2.90% | 2.88% |
| M2 8 MiB, GB/s | shipped | 71.5043 | — | 7.67% |
| | C1 prefetch | 66.7328 | −6.67% | 2.22% |
| | C2 chain-first | 76.0057 | +6.30% exploratory | 8.83% |

The 8 MiB M2 C2 ratio is not a reliable 6.3% claim: per-round ratios are
about 1.00/1.06/1.02 and the host rate changes appreciably; the 256 KiB
result is the useful signal. The 8 MiB Xeon control is bandwidth or
cache limited, which is why saving two Boolean instructions has little
visible effect there. All runs passed 400 random-key, whole-KiB-length
and alignment comparisons per process: both candidates equal the shipped
bulk value and the shipped one-shot digest.

## Recommendations

1. Try C2 in a full integration lane: the same function and key model
   survive, ZMM loses two Boolean instructions per KiB without spills,
   and 256 KiB gains appear on both hosts. Before adoption that lane must
   cover one-shot and streaming, every tail and backend, compiler
   sensitivity and full speed records including small keys. The data
   supports a modest scheduling improvement, not a promised full-hash
   result.
2. Drop C1 as a general bulk optimization: hot-buffer regressions on both
   hosts and a larger-buffer M2 loss outweigh the 1.85% Xeon 8 MiB gain.
3. Adopt now: no production change from this survey alone. Beyond the
   small C2 schedule and the separately assigned EHC work, nothing
   substantial is left on the table in this inventory. This is a
   conclusion about the inspected implementations and records, not a
   lower-bound theorem excluding future algorithms.
