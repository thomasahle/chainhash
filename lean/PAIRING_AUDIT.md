# Shipped pairing and differential evidence

Inspected repo HEAD: `8d18348ffc5a18ed284b45c0270089a5b5e63992`.
`include/chainhash.h` is unchanged by this integration, SHA256
`963b6000faaf0a0bc5430bfdad791f14ab056e9271c2163d3a4301233d1345f6`.
All paths use **strided pairs `(4g,4g+2),(4g+1,4g+3)`**, and activate two
pairs per intersecting 32-byte group. No path disagreement was found.

| Path | Index derivation |
| --- | --- |
| Portable `chainhash_portable` | `a=g/8+lane`, lane 0 or 1; multiplies words `a` and `a+2`. |
| x86 fallback `chainhash_hardware`, `ch_group` | Loads `[w0,w1]` and `[w2,w3]`; low-low and high-high CLMUL give `(0,2)` and `(1,3)`. |
| NEON/PMULL `ch_group` | Same loads and group loop; PMULL and PMULL2 implement the same low-low and high-high products. |
| Pipelined XMM `chainhash_narrow` | `ch_narrow_ph` calls the same `ch_block`/`ch_group`. |
| YMM `ch_ph256` | `permute2x128(x,y,0x20)` selects `[w0,w1,w4,w5]`; `0x31` selects `[w2,w3,w6,w7]`. Low-low/high-high products within each lane give the strided pairs. |
| ZMM `ch_ph512` | `shuffle_i64x2(x,y,0x88)` selects 128-bit chunks 0,2 from each input; `0xdd` selects 1,3. Low-low/high-high products give the same pairs in all four groups. |
| All hardware tails | `ch_block` zero-pads a final partial 32-byte group and calls `ch_group`. |

The inspected `scratchpad/codex/chainhash-x86/SPEC.md` explicitly describes a
**separate** 1024-byte adjacent-pair hash family, with 137 key words and
16-byte tail groups. It is not the shipped 256-byte, 41-word header.

The Lean map in `ByteEncoding.pairPosition` is
`4*(i/2) + i%2 + (if b then 2 else 0)`. `KeyLayout.decodeKey` and
`referenceBlockKey` apply this same map to keys. `unpairPosition` is its
proved inverse. The model-A `exponent` uses `pairPosition + 1`, so seeded
PH words occupy the actual shipped positions. No index-map changes or
weakened statements were necessary. `referenceHash_matches` is unchanged.

## Reproduction

On the Xeon, with Lean 4.24.0 on PATH and the existing `.lake` cache:

```sh
cd <xeon-work>/chainhash-integrate
lean/check_vectors.sh
LEAN_NUM_THREADS=8 nice -n 10 taskset -c 0-7 make -B test
```

[VectorAgreement.lean](VectorAgreement.lean) is an executable test evaluator
that directly uses the proved encoding's `blockCount`, `activePairs`,
`blockData`, `pairPosition`, and bit conversion. It evaluates raw products,
reduction, recurrence, and the finalizer using Nat bit operations. It is a
test transcription, not an additional equivalence theorem to the
noncomputable `referenceHash`; the formal word/field equivalence remains
`referenceHash_matches`. No test result enters a theorem or its axioms.

[test/lean_vectors.cpp](../test/lean_vectors.cpp) compares each emitted value
against the vendored C++ reference, portable path, selected path, and every
available direct x86 path. Lean agrees on **324 vectors**: 84 existing frozen
vectors of length at most 1025 and 240 model-A vectors (five seeds including
0, 1, 2 and all-ones; 48 lengths including empty, byte/word/group boundaries,
256-byte boundaries, and multiple blocks). The runtime reported width 2,
so both YMM and ZMM were exercised. NEON was source-audited; no ARM execution
was performed during this integration.

The full existing C/C++ suite separately checks all 92 frozen vectors,
random keys/messages, all available direct paths, zero padding, guard pages,
and seeded constructors. Logs: [VECTOR_AGREEMENT.txt](VECTOR_AGREEMENT.txt)
and [HEADER_TESTS.txt](HEADER_TESTS.txt).
