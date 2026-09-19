# ChainHash-128 partial-region tail (2026-09-19)

The bulk kernels take whole 4 KiB regions. An input shorter than a region
and the remainder after the last full region are the tail. Before the
change, inputs above 128 bytes that were not a whole number of regions
went through a scalar organization of the hardware products: every word,
including complete ones, was rebuilt through a cleared 16-byte buffer and
a bounded copy, and the eight lane values were then combined by eight
serial Horner steps. On the M2 this made 4095 bytes 8.21× slower than
4096. The change is digest-preserving and touches only the tail: complete
256-byte chunks are loaded directly with vector loads, only the last chunk
is padded, a pair is skipped when its first word is absent (the pair
presence rule), and the lane values are combined with cached powers of y
instead of the serial chain. The complete-word load bypass also improves
the x86 tails. SMHasher3 fixed-size bulk throughput is unchanged. The
header change is 32 lines; the bulk kernels are untouched; the function,
the specification and every Lean theorem are unchanged.

Why the digest is unchanged: for a partial region of n bytes with q
present lanes and C_j the XOR of its unreduced keyed pair products in
lane j, both the old and the new tail compute
`v' = v*y^q XOR sum_(j=0..q-1) R(C_j) * y^(q-1-j)` with R the reduction
modulo `X^128 + X^7 + X^2 + X + 1`; the padded chunk includes lane j
exactly when `16*j < rem`, the original first-word-presence test, and
linearity of R permits the combined reduction of the weighted products.

## Measurement protocol

The repository's `test/speed.c` protocol extended to `test/128/speed.c`:
hot input, seed 123, setup outside timing, a 30 ms warmup, 32 MiB hashed
per sample, three samples per length, explicit backend selection; medians
shown. GB/s means decimal bytes per ns from `CLOCK_MONOTONIC`. M2: Apple
M2 Pro, Apple clang 17.0.0, `-O3 -DNDEBUG -std=c99 -march=native+crypto`.
Xeon: Platinum 8375C, GCC 11.5.0, `-O3 -DNDEBUG -std=c99 -march=native`,
one pinned core. Spread is (maximum − minimum)/median; an asterisk flags
a spread above 15%. The only flagged row is M2 after/16 B (67.4%
spread), which is not a measured latency regression.

### M2 NEON

| Bytes | Before GB/s | After GB/s | Speedup |
| ---: | ---: | ---: | ---: |
| 16 | 0.92 | 0.67 * | 0.73× |
| 31 | 1.21 | 1.33 | 1.10× |
| 64 | 1.50 | 1.96 | 1.31× |
| 128 | 1.60 | 2.15 | 1.34× |
| 256 | 1.18 | 5.01 | 4.23× |
| 512 | 1.70 | 7.86 | 4.61× |
| 1024 | 2.30 | 13.14 | 5.72× |
| 2048 | 2.79 | 19.24 | 6.89× |
| 4095 | 3.15 | 24.75 | 7.85× |
| 4096 | 25.89 | 25.44 | 0.98× |
| 8192 | 29.00 | 28.63 | 0.99× |
| 65536 | 31.93 | 32.61 | 1.02× |

The adjacent-length ratio at 4095/4096 falls from 8.21× to 1.03×. Tiny
inputs still pay the fixed finalizer latency; no bulk throughput is
claimed for 16- or 31-byte messages.

### Xeon XMM

| Bytes | Before GB/s | After GB/s | Speedup |
| ---: | ---: | ---: | ---: |
| 16 | 0.47 | 0.39 | 0.84× |
| 31 | 0.68 | 0.62 | 0.91× |
| 64 | 1.04 | 1.02 | 0.97× |
| 128 | 1.36 | 1.39 | 1.03× |
| 256 | 0.94 | 1.61 | 1.72× |
| 512 | 1.18 | 2.59 | 2.20× |
| 1024 | 1.36 | 3.70 | 2.73× |
| 2048 | 1.46 | 4.67 | 3.19× |
| 4095 | 1.53 | 5.47 | 3.58× |
| 4096 | 9.43 | 9.42 | 1.00× |
| 8192 | 10.32 | 10.35 | 1.00× |
| 65536 | 11.47 | 11.52 | 1.00× |

A pilot with only the complete-word load check reached about 8.20 GB/s
at 4095 bytes against 26.05 at 4096 on the M2, a 3.18× jump; the vector
tail helper is what removes the remaining cliff.
