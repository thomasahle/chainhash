# EHC block stage for ChainHash-128: operation budget (2026-09-19)

An analysis, not a measurement. An encode-hash-combine (EHC) block stage
encodes each pair of 128-bit message words before the keyed products so
that fewer carry-less multiplies cover the same 32 bytes, in the manner
of HalftimeHash's encoder, and combines the results with a rank
condition that keeps the block value a nonzero polynomial in the seed
whenever the pair differs.

| Per 32 message bytes | Schoolbook block stage | EHC block stage |
| --- | ---: | ---: |
| 64×64 carry-less multiplies | 4 (2 per 16 bytes) | 3 (1.5 per 16 bytes) |
| extra XORs beyond the accumulate | 0 | about 5 |
| chain | one in GF(2^128) | one in GF(2^128) |

The bound stays linear in the block count, `(p + const)/2^128`, only if
the chain remains a single Horner chain in `GF(2^128)` over the encoded
block values. Splitting the output into two independently keyed 64-bit
chains would make the bound the product of two 64-bit bounds,
quadratic in the length, with the score consequence recorded in
[ch128-two-chains.md](ch128-two-chains.md).

Whether the saved multiply pays for the extra XORs depends on the host:
the NEON loop is issue-bound (446 instructions per KiB with schoolbook
products, [results/128](../128/README.md)), so five XORs per 32 bytes are
not free there, while on ZMM the multiply port is the floor. A prototype
is in progress; nothing in the released function uses EHC.
