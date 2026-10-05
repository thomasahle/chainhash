# ChainHash-192 specification

This defines the function in [`include/chainhash192.h`](../include/chainhash192.h), a keyed 192-bit hash: a
pseudo-dot-product over GF(2^192) with a power key, 4096-byte blocks and the two-level outer stage of ChainHash-256
(regions of 8 block values, an independent chain key z). The collision bound is in [THEOREM-192.md](THEOREM-192.md).

The normative reference is `c192_hash_ref` in the header (bit-serial), exposed as `chainhash192_reference`.
[`test/192/pyref.py`](../test/192/pyref.py) is an independent Python implementation written from this document; it reproduces
every vector in [`test/192/vectors.txt`](../test/192/vectors.txt).

## 1. Field

L = GF(2)[x]/(f), with f = x^192 + x^7 + x^2 + x + 1. f is irreducible: a Rabin test
([`test/192/cert/field.py`](../test/192/cert/field.py)) checks x^(2^192) ≡ x mod f, gcd(x^(2^96) − x, f) = 1 and
gcd(x^(2^64) − x, f) = 1, and rejects four negative controls (among them a product of two degree-96 irreducibles, which
fails only the second condition, and a product of three degree-64 irreducibles, which fails only the third).

An element is 24 bytes: three little-endian 64-bit limbs. Limb 0 holds the coefficients of x^0..x^63; bit i of limb l
is the coefficient of x^(64l+i). Addition is XOR; multiplication is polynomial multiplication mod f.

## 2. Key (216 bytes)

The key is nine elements of L, 24 bytes each, all independent and uniform, in this order:

| element | role |
|---|---|
| s | block mask generator: pair i = 0..87 has masks k_i = s^(2i+1) (on x_i) and l_i = s^(2i+2) (on y_i) |
| y | region key (the region formula's masks y^1..y^8) |
| z | region chain key |
| tau | twist |
| c_0, c_1, c_2, c_3, c_4 | finalizer |

`chainhash192_key_from_bytes` reads them in this order, each as three little-endian limbs, limb 0 first;
`chainhash192_key_from_words` takes the same 27 limbs. No key is rejected. The 176 masks are computed when the key is
initialized (they are derived, not key material).

`chainhash192_key_from_seed` (splitmix64 of `seed ^ 0x4348313932763100`, three outputs per element, limb 0 first, in
the same order) is for tests and vectors only; the bound is not asserted for it. It replaces a zero y by 1. For key
bytes, y is used as given (y = 0 is a valid key; the bound is over a uniform y including 0).

## 3. Message layout

The message of n bytes is cut into m = ⌈n/4096⌉ blocks of 4096 bytes; the last one is zero-padded to 4096 bytes. The
empty message is one block whose value is 0 (section 4 does not apply to it).

A block holds 88 pairs (x_i, y_i), i = 0..87, of elements, as 8-byte words:

- **Chunks 0..9.** Chunk g (g = 0..9) is the 384 bytes at 384g. It holds pairs 8g..8g+7 as six rows of 64 bytes:
  row j (j = 0..5) is the 64 bytes at 384g + 64j, and its word t (the 8 bytes at 384g + 64j + 8t, t = 0..7) belongs to
  pair i = 8g + t: rows 0, 1, 2 are limbs 0, 1, 2 of x_i, rows 3, 4, 5 are limbs 0, 1, 2 of y_i.
- **The last 256 bytes** (offset 3840) hold pairs 80..87 as four rows of 64 bytes: rows 0, 1 are limbs 0, 1 of x_i and
  rows 2, 3 are limbs 0, 1 of y_i, word t of each row belonging to pair i = 80 + t; limb 2 of x_i and of y_i is zero for
  these pairs.

So every word of the block is one limb of one element; the first 192 bytes of a block are x words only.

## 4. Block value

c = Σ_{i=0}^{87} (x_i + s^(2i+1))·(y_i + s^(2i+2)) in L.

## 5. Outer stage (two-level) and finalizer

1. **Block values.** b_1..b_m are the block values of section 4 in message order. For the empty message m = 1 and b_1 = 0.
2. **Regions.** Eight consecutive block values form a region; m′ = ⌈m/8⌉. Every region has q = 8 values except possibly
   the last, which has q = m − 8(m′ − 1) ∈ {1..8}.
3. **Region value** (the block formula applied to the block values, with key y). For values a_1..a_q, with h = ⌈q/2⌉ and
   f = ⌊q/2⌋:

       c(a_1..a_q) = Σ_{i=1}^{f} (a_i + y^(2i−1))·(a_{h+i} + y^(2i))  +  [q odd]·a_h

   For q = 8, value i is paired with value 4 + i; for odd q the middle value a_h enters bare.
4. **Chain.** V = n·z^{m′} + Σ_{ρ=1}^{m′} c_ρ·z^{m′−ρ}: a Horner polynomial in z with the length leading, where n is the
   byte length as an element (limb 0 = n). For a message of at most one block, V = n·z + b_1; for n = 0, V = 0.
5. **Finalizer.** X = V +_Z tau (192-bit integer addition mod 2^192 of the limb vectors), G = X², t = (G + c_0)·(X + G + c_1),
   out = (X + c_2)·(t + c_3) + c_4.
6. **Digest.** out as 24 bytes, limb 0 first, little-endian.

The outer stage and the finalizer are ChainHash-256's (SPEC-256 section 5) over GF(2^192).

## 6. Interface and implementation notes

These are not part of the definition.

- Backends, all with identical digests: CH192_AVX512 (AVX-512 F/VL/BW/DQ/VBMI2 + VPCLMULQDQ), CH192_PCLMUL (PCLMULQDQ +
  SSE4.1), CH192_NEON (AArch64 PMULL, when the compiler targets +crypto), CH192_PORTABLE (the bit-serial reference). The
  backend is chosen when the key is initialized (`*_with_backend` picks one; an unavailable one falls back to the best).
  x86 kernels carry their own target attributes, so the header builds without `-march`; build with `-O3` under gcc.
  `CHAINHASH192_PORTABLE` omits all hardware code.
- The block kernels hold one block's 8 pairs of a chunk row in a vector register (lanes = pairs) and accumulate the 6
  Karatsuba-3 point products of every pair unreduced; the 6 sums are recombined and reduced once per block (NEON, PCLMUL:
  2 pairs per 128-bit register; AVX-512: 8 per zmm, the 4 128-bit lanes folded across the region's 8 blocks at once). The
  region formula and the z-chain are one 8-lane multiply (AVX-512) or one accumulated product sum (NEON). The reference
  multiplies schoolbook with a bit-level reduction and never uses those evaluations.
- Schedules that differ by host, with the same digests: Intel x86 prefetches ahead of the sweep, AMD does not
  (`-DC192X_PF_FORCE=0/1` forces either); the x86 finalizer multiply is schoolbook (`-DC192X_FINM=1` selects
  Karatsuba-3, measured no faster).
- Finalizer: the twist X = V +_Z tau is folded into the square by carry-select. With s_i = v_i + tau_i (per 64-bit limb,
  mod 2^64) and c_i the carry into limb i (c_1 = g_0, c_2 = g_1 | p_1 g_0; g_i = [v_i > ~tau_i], p_i = [v_i = ~tau_i]),
  X_i = s_i + c_i, so X_i² = c_i ? (s_i + 1)² : s_i²: both candidate squares are computed right after the limb adds
  (s_i + 1 = v_i + (tau_i + 1), precomputed) while the carries are found beside them, and a bitwise select picks one.
  Every backend (NEON, AVX-512, PCLMUL) does this; `test/192/ftest.c` checks crafted carry patterns.
- Short inputs: n ≤ 64 takes a direct path (V = n z + Σ_t d_t l_t + C0, C0 the key-only block value); at most one block
  is swept chunk by chunk with the absent chunks' key-only sums precomputed; a partial chunk with x words only is a linear
  form in the data. In the n ≤ 64 path the first 16 bytes enter last and in two parts (the products are linear in the
  data): bytes 0..3 by one load of at most 4 bytes (a dependent caller's store of ≥ 4 bytes at the start forwards to it;
  a wider load over a narrower pending store does not forward on x86), the rest by loads at higher addresses only. No
  path reads outside [msg, msg + n).
- The expanded key (`chainhash192_key`) has 8-byte alignment and works at any 8-byte-aligned address (`malloc` is
  fine): every key vector is read with unaligned-capable loads. The x86 tables sit at a 64-byte-aligned offset chosen when
  the key is initialized (full speed wherever it was initialized); a key copied elsewhere by `memcpy` stays correct (the
  PCLMUL sweep then uses its unaligned-key copy). `test/192/align.c` checks in-place keys at offsets 0..63 and relocated
  copies on every backend.
- Key setup derives s^1..s^176 in four interleaved chains (s^(e+4) = s^e s^4), with each backend's multiply inlined.
- Streaming (`chainhash192_init/update/final`) folds every full region into V (V ← V·z + c) as soon as it is complete;
  `final` folds the last region and adds n·z^{m′}. Before any region completes, `final` applies the one-shot function to
  the buffered bytes.
- The header needs a little-endian host and GCC or Clang.

## 7. Conformance

- [`test/192/vectors.txt`](../test/192/vectors.txt): lines `key n digest`. The message is m[j] = (137·j + 29) mod 256; `key` is a
  decimal seed (`chainhash192_key_from_seed`) or `R`, the raw key b[i] = (73·i + 11) mod 256, i = 0..215.
- `make test-192` runs every backend against the reference, the vectors and the Python cross-check; `make certs` runs
  the certificates of [THEOREM-192.md](THEOREM-192.md). Measurements: [results/192](../results/192/README.md).
