# 128-bit output: native field against two 64-bit chains (2026-09-18)

The first ChainHash-128 lane built a `GF(2^128)` chain with the layout of
that time (contiguous 512-byte blocks of 32 words, strided pairing, S=1,
raw 256-bit accumulators, Karatsuba products, the message-dependent chain
`Q = P + u`, 160 random key bytes) and measured it in one SMHasher3
binary per host against two independently keyed 64-bit ChainHash
evaluations, a 256-byte variant and a four-product schoolbook variant.
The released ChainHash-128 (comb, Horner, 128 random key bytes) is
measured in [results/128](../128/README.md); the block-size table at the
end of this record is from that lane.

## Construction and bound shape

| Family | Output | Block | Ideal random/resident key | 64-byte-model random input | Ideal epsilon for messages of at most 1 MiB |
| --- | ---: | ---: | ---: | ---: | ---: |
| 64-bit ChainHash of that lane | 64 bits | 256 B | 328 B | 80 B | 4098 / 2^64 |
| Two independently keyed 64-bit chains | 128 bits | 256 B each | 656 B | 160 B | 4098^2 / 2^128 |
| Native 128-bit, 256-byte blocks | 128 bits | 256 B | 400 B | 160 B | 4098 / 2^128 |
| Native 128-bit, 512-byte blocks (that lane's default) | 128 bits | 512 B | 656 B | 160 B | 2050 / 2^128 |

The ideal-key bound of the native chain is `(n+2)/2^128` for n blocks,
including arbitrary byte lengths and empty input; its length-normalized
score is `128 − log2(3) = 126.4150` bits, attained at L = 1. Two
independent ideal 64-bit evaluations need the same 656 ideal key bytes
and have `epsilon <= (n+2)^2 / 2^128`. Their certificate has a
full-domain score of approximately 77 bits because of the quadratic
length growth: doubling the output and squaring epsilon does not double
`min_L log2(L / epsilon(L))`. Capping messages at 1 MiB raises the
two-chain certificate's score to 120.998 bits (L = 131041 eight-byte
words is the minimizing block start), while the native score stays
126.415 on that domain.

## Same-binary speed, Xeon Platinum 8375C

Higher bulk and lower small result from two complete runs, selected
independently. Bulk is bytes per TSC tick at 262,144 bytes; small is the
mean cycles per hash over lengths 1–31.

| Hash | Output | Backend | Bulk B/cycle | Small cycles/hash |
| --- | ---: | --- | ---: | ---: |
| 64-bit ChainHash, existing SMHasher3 registration | 64 | `hwclmul` | 14.37 | 103.91 |
| 64-bit ChainHash, supplied header | 64 | `pclmul` | 14.29 | 110.00 |
| Two 64-bit evaluations | 128 | `pclmul` | 7.20 | 207.56 |
| Native 128, 512 B, scalar Karatsuba | 128 | `pclmul` | 7.26 | 164.40 |
| Native 128, 256 B | 128 | `vpclmul256` | 6.20 | 164.29 |
| Native 128, 512 B, four products | 128 | `vpclmul256` | 7.42 | 160.99 |
| Native 128, 512 B (that lane's default) | 128 | `vpclmul256` | 8.16 | 165.06 |
| UMASH-128 | 128 | `hwclmul` | 6.02 | 40.29 |
| komihash | 64 | | 7.36 | 27.49 |
| rapidhash | 64 | | 10.68 | 27.58 |
| XXH3-128 | 128 | `avx512` | 19.86 | 34.90 |

Repetition ranges over both passes: 64-bit header 14.28–14.29; native
256 B 6.16–6.20; native 512 B 8.13–8.16; UMASH-128 6.01–6.02.

## Same-binary speed, Apple M2 Pro

Median of three complete runs per hash; no runs excluded; no summary
metric or length/alignment diagnostic deviated more than 15%.

| Hash | Output | Backend | Bulk B/cycle | Small cycles/hash |
| --- | ---: | --- | ---: | ---: |
| 64-bit ChainHash, existing SMHasher3 registration | 64 | `hwpmull` | 22.03 | 73.02 |
| 64-bit ChainHash, supplied header | 64 | `pmull` | 21.98 | 83.67 |
| Two 64-bit evaluations | 128 | `pmull` | 10.27 | 85.15 |
| Native 128, 512 B, scalar Karatsuba | 128 | `pmull` | 10.34 | 160.94 |
| Native 128, 256 B | 128 | `pmull` | 9.20 | 158.95 |
| Native 128, 512 B, four products | 128 | `pmull` | 11.00 | 149.21 |
| Native 128, 512 B (that lane's default) | 128 | `pmull` | 10.28 | 161.84 |
| UMASH-128 | 128 | `hwclmul` | 7.67 | 42.35 |
| komihash | 64 | | 8.32 | 23.95 |
| rapidhash | 64 | | 15.46 | 20.54 |
| XXH3-128 | 128 | `neon` | 12.97 | 29.90 |

All three runs, bulk B/cycle / small cycles per hash:

| Hash | Run 1 | Run 2 | Run 3 |
| --- | ---: | ---: | ---: |
| strided 64-bit, 256 B | 22.01 / 73.08 | 22.03 / 73.02 | 22.04 / 72.92 |
| 64-bit header | 21.88 / 84.51 | 22.45 / 81.88 | 21.98 / 83.67 |
| two 64-bit evaluations | 10.26 / 85.15 | 10.27 / 85.31 | 10.34 / 83.97 |
| native 128, scalar Karatsuba | 10.55 / 157.69 | 10.30 / 161.62 | 10.34 / 160.94 |
| native 128, 256 B | 9.23 / 158.50 | 9.20 / 158.95 | 9.17 / 159.57 |
| native 128, schoolbook | 11.25 / 145.82 | 10.95 / 150.06 | 11.00 / 149.21 |
| native 128, 512 B | 10.26 / 162.26 | 10.28 / 161.84 | 10.75 / 155.42 |
| UMASH-128 | 7.67 / 42.35 | 7.83 / 41.36 | 7.58 / 43.98 |
| komihash | 8.32 / 23.96 | 8.32 / 23.95 | 8.39 / 23.51 |
| rapidhash | 15.34 / 20.67 | 15.74 / 20.18 | 15.46 / 20.54 |
| XXH3-128 | 12.97 / 29.90 | 13.01 / 29.82 | 12.89 / 30.10 |

On the M2 the four-product schoolbook option reaches 11.00 B/cycle and
149.21 small-key cycles against 10.28 and 161.84 for Karatsuba: about
7.0% more bulk throughput and 7.8% fewer small-key cycles, which is why
counting CLMULs alone does not rank complete implementations. Two
complete 64-bit evaluations deliver 7.20 B/cycle on the Xeon and 10.27 on
the M2, against 14.29 and 21.98 for one.

## Measured instruction and chain ceilings

All entries in the host's SMHasher3 timer units. The issue estimates
include the block products plus the five-CLMUL chain step.

| Host | CLMUL latency | Scalar reciprocal throughput | VP256 reciprocal throughput | Chain-step latency |
| --- | ---: | ---: | ---: | ---: |
| Xeon 8375C | 5.011 | 0.829 | 1.657 | 21.765 |
| M2 Pro | 2.803 | 0.233 | — | 27.685 |

| Host | Block | Scalar products-only B/cycle | Wide products-only B/cycle | Scalar products + chain issue B/cycle | Wide products + chain issue B/cycle | Chain-latency B/cycle |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Xeon 8375C | 256 B | 12.87 | 12.87 | 10.65 | 10.65 | 11.76 |
| Xeon 8375C | 512 B | 12.87 | 12.87 | 11.66 | 11.66 | 23.52 |
| M2 Pro | 256 B | 45.82 | — | 37.92 | — | 9.25 |
| M2 Pro | 512 B | 45.82 | — | 41.50 | — | 18.49 |

Doubling the block doubles the chain ceiling while the product budget per
byte stays constant. On the M2 the 256-byte variant's 9.20 B/cycle is
close to its 9.25 chain ceiling while its CLMUL issue estimate is 37.92;
the 512-byte block raises the chain ceiling to 18.49 and the measured
speed to 10.28. On the Xeon the chain ceilings are 11.76 and 23.52
against issue estimates of 10.65 and 11.66, and the measured 256-to-512
improvement is 6.20 to 8.16. With the message-dependent chain the
512-byte block is bought by chain headroom at the cost of 256 extra
resident key bytes.

## Block size with the comb and Horner (2026-09-19)

Standalone RDTSC harness on the Xeon (262,144 bytes, eight alignments,
median of three 512-call samples, mean over alignments), bytes per TSC
tick; the rows are in [rdtsc-final256.csv](../128/evidence/rdtsc-final256.csv)
and [rdtsc-final512.csv](../128/evidence/rdtsc-final512.csv).

| Block / product | XMM | YMM | ZMM |
| --- | ---: | ---: | ---: |
| 256 / Karatsuba | 7.257 | 8.996 | 12.510 |
| 256 / schoolbook | 7.514 | 7.395 | 12.918 |
| 512 / Karatsuba | 7.272 | 9.534 | 13.711 |
| 512 / schoolbook | 8.215 | 8.189 | 14.156 |

For the released function the paper-model bound is `(p+1)/2^128` with p
the block count and the 64-byte-model bound `(p+W)/2^128` with W = B/16;
the paper numerator at 1 MiB is 4097 with 256-byte blocks and 2049 with
512-byte blocks, the refined chart score is 127 bits for both, and the
larger block halves the asymptotic Horner degree while keeping the
level-1 root count at 32.
