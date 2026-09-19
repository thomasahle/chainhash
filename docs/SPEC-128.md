# ChainHash-128 specification

This defines the function in [`include/chainhash128.h`](../include/chainhash128.h):
the [ChainHash](SPEC.md) design over the field `GF(2^128)`, with the same
three levels, comb pairing, length-leading Horner and integer-twist/quintic
finalizer, 128-bit words, a 512-byte logical block and a 128-bit result.
The collision bound is stated in [THEOREM-128.md](THEOREM-128.md).

## Representation and domain

The field is `F = GF(2)[X]/(X^128 + X^7 + X^2 + X + 1)`, `q = 2^128`. Bit i
of a 128-bit word represents `X^i`. Words, keys and output bytes are little
endian. This is the integer polynomial convention, not GHASH's external
bit-string convention. Addition in F is XOR; `X^128 = 0x87` in F. Only the
final twist uses integer addition with carries.

The logical block is `B = 512` bytes: `W = B/16 = 32` words, `W/2 = 16`
pairs. Eight logical blocks are interleaved in a region of `8B = 4096`
bytes; a logical block is not a contiguous 512-byte slice. Changing a
backend, multiplication method, chain count or reduction schedule does not
change the function; bulk products are schoolbook on XMM, ZMM and NEON and
Karatsuba on YMM and in the portable evaluator.

## Complete index maps and padding

For a zero-based global 128-bit input word index i, uniquely write

```text
R = floor(i/(8W))             region
C = floor((i mod (8W))/16)    chunk, 0 <= C < W/2
h = floor((i mod 16)/8)       half, 0 or 1
j = i mod 8                   comb lane, 0..7
i = 8W*R + 16C + 8h + j
```

The first half word, `h=0`, pairs with word `i+8`. Its one-based logical
block index is `t = 8R + j + 1` and its pair slot is C. The key indices are
`2C` and `2C+1`. Conversely, for block t and within-block word position a in
`0..W-1`:

```text
R = floor((t-1)/8); j = (t-1) mod 8
C = floor(a/2); h = a mod 2
i = 8W*R + 16C + 8h + j
partner_position(a) = a XOR 1
partner_word(i) = i+8 if h=0, otherwise i-8
byte_offset(i) = 16i
```

Decode each input word from its existing bytes; missing bytes are zero. A
pair is included exactly when its first word has at least one existing byte.
If its partner is absent, include the partner key with zero message word. If
the first word is absent, omit the entire product, including both keys. No
terminator, key-only padded pair or extra coefficient is appended. The
full-region pair loads are at `256C + 16j` and `256C + 128 + 16j`. The same
two key words are used in all eight lanes and every region.

For byte length `ell`, write `ell = Rbytes*Q + r` with `Rbytes = 8B` and
`0 <= r < Rbytes`:

```text
p(0)   = 1
p(ell) = 8Q                        if ell > 0 and r = 0
         8Q + min(8, ceil(r/16))   if r > 0
```

Lengths 1, 17, 33, 113, 256, 2048 and 2049 have 1, 2, 3, 8, 8, 8 and 8
blocks; 4097 bytes have nine. The empty message has a single empty block
with raw value zero.

The C domain is `0 <= ell < 2^64`, each call's length representable by
`size_t`. The mathematical definition extends to `ell < q`; the C API
supports only the smaller domain. Input can be `NULL` only for zero length.
There are no alignment or readable-padding requirements. Streaming updates
must not overflow the `uint64_t` total length; an assertion checks this
precondition, which also applies under `NDEBUG`.

## Key and expanded layout

The key is exactly **128 independent uniformly random bytes**, read as
eight little-endian field words, from which the block key words are
expanded:

```text
s, y, c0, c1, c2, c3, c4, tau
kappa[a] = s^(a+1) in F,  0 <= a < W
```

`chainhash128_key_from_bytes` implements this. No key is rejected; `s = 0`
and `y = 0` are valid, and y and the finalizer parameters are independent
of s. The function itself is defined on the `W+7 = 39` words

```text
kappa[0..W-1], y, c0, c1, c2, c3, c4, tau
```

and `chainhash128_key_from_words` accepts them directly; the proofs go
through this form (with all 39 words independent, as an internal lemma) and
the tests exercise it. `chainhash128_key_from_seed` expands sixteen
SplitMix64 outputs from a 64-bit seed into 128 key bytes, low byte first;
it is a benchmark adapter and does not supply the random bytes the
collision bound assumes.

The resident `chainhash128_key` holds `ph[a] = kappa[a]`, `yp[i] = y^i`
and `yh[i] = 0x87 * y^i` for `i = 0..8`, then `c[0..4]` and `tau`; so
`yp[0] = 1` and `yh[0] = 0x87`. It occupies `16(W+24) = 896` bytes. The
expanded struct is a cache, not a serialized key format. Setup uses
portable arithmetic. The key must remain unchanged for every evaluation
and outlive associated streams.

## Formal three-level definition

For each block t let

```text
C_t = XOR over its present first words i of
      clmul128(w_i XOR kappa[2C(i)], w_(i+8) XOR kappa[2C(i)+1])
b_t = C_t mod (X^128 + X^7 + X^2 + X + 1)
P_0 = ell
P_t = y*P_(t-1) XOR b_t,  t = 1..p
V   = ell*y^p XOR XOR_(t=1..p) b_t*y^(p-t)
```

`C_t` is a raw 256-bit polynomial of degree at most 254; products are XOR
accumulated before reduction. Length is a single leading coefficient, never
a message-dependent multiplier or a mask on a block value.

Interpret V as an unsigned 128-bit integer and compute
`v = (V + tau) mod 2^128`, including the low-to-high limb carry. Reinterpret
v as a field element and evaluate the twist/quintic circuit:

```text
qv = v*v
rv = (qv XOR c0)*(v XOR qv XOR c1)
H  = (v XOR c2)*(rv XOR c3) XOR c4
```

All products here are in F. The c words are circuit parameters, not
monomial coefficients. `chainhash128_store` serializes H as 16
little-endian bytes. This is an almost-universal keyed hash; no
cryptographic digest or MAC claim is made.

## Exact-count k-chain evaluation and lookahead

Include the length as coefficient `a_0 = ell` and set `a_t = b_t` for
`t >= 1`. Put `N = p+1`, `m = min(k, N)`. For `j = 0..m-1`:

```text
R_j = a_j
index = j
while index + k < N:            # test existence BEFORE advancing the chain
    R_j = R_j*y^k XOR a_(index+k)
    index += k
e_j = (p-j) mod k
V = XOR_j R_j*y^e_j             # XOR directly when e_j = 0
```

Lookahead is in coefficient indices. It grants no permission to read ahead
of the byte object. A partial final group must not be filled with fictitious
zero coefficients, which would introduce extra powers of y. The schedule
performs exactly `N-m` update multiplications and `m-1` nontrivial weighting
multiplications: exactly p in total, including when `p < k` and when `y = 0`.
[`test/128/schedule.c`](../test/128/schedule.c) checks these counts
and identities.

For a raw representative `U = lo + X^128*hi`, a lazy update is

```text
U <- clmul128(lo, y^k) XOR clmul128(hi, 0x87*y^k) XOR C_t
```

Reduction gives precisely the corresponding field update since `X^128 = 0x87`
in F. Both limbs may be noncanonical, so reduction placement cannot change H.
Schoolbook uses four 64×64 products with CLMUL immediates 00, 11, 01, 10.
Karatsuba uses low-low, high-high and `(lo XOR hi)*(lo XOR hi)`, then
combines the middle coefficient. The implementation keeps three component
accumulators and reconstructs the raw two-limb result once per block or
update. A raw product's middle reconstruction is not a change in comb
pairing.

The generic streaming evaluator excludes length until finalization. Block
index i, zero-based, belongs to chain `i mod k`; the first coefficient
initializes its chain directly and subsequent coefficients update with
`y^k`. At the end, weight chain j by `y^((p-1-j) mod k)`, omitting unused
chains, then add `ell*y^p` once. An exponent-zero weight is XORed directly.
This is exact for `y = 0`; there is no inversion. It is not the same
operation-count schedule as including `a_0` in the lanes, because it
computes the length power separately.

The optimized ZMM and NEON one-shot loops use `k = 4`, initialize chain 3 to
ell and the other chains to zero, and advance each chain twice per complete
region, first for blocks 0..3 and then 4..7. The XMM and YMM loops use
`k = 8`, initialize chain 7 to ell and advance each chain once per region.
Final weights are `[y^3, y^2, y, 1]` and `[y^7, ..., y, 1]` respectively. In
both cases Q regions contribute exactly `ell*y^(8Q)`. A tail contributes
only its actually present blocks through serial Horner. These regular SIMD
loops include some multiplications by zero or one; the exact-count theorem
does not claim those instructions are eliminated from them.

For 1..128 bytes every partner word is absent and every block has one pair.
Put `r = ceil(ell/16)`, `A_j = w_j XOR kappa[0]`, and let `H_y(A)` be the
usual length-r Horner polynomial with coefficients `A_0..A_(r-1)`. Then

```text
V = ell*y^r XOR kappa[1]*H_y(A)
```

The short kernel uses this factorization, a precomputed `y^r` and a 64×128
length product. It omits no block or key contribution; the empty input
still has `V = 0`. This optimization is shared by all hardware backends and
checked by [`test/128/short.c`](../test/128/short.c).

## Streaming and two-thread concatenation

```c
chainhash128_stream s;
chainhash128_init(&s, &key, 4, 1, chainhash128_backend(), 1);
chainhash128_update(&s, first, first_len);
chainhash128_update(&s, second, second_len);
ch128_word h = chainhash128_final(&s);
```

The arguments after the key are stride k (1..8), the lazy flag, the backend
and the schoolbook flag (0 = Karatsuba, 1 = schoolbook). Any byte chunking
and empty updates are valid. At most one incomplete region is buffered.
`partial` and `final` consume the stream; do not update or finalize it again
without reinitialization. Separate streams may share one immutable key
across threads.

`chainhash128_partial` returns only the message polynomial, excludes
length and finalizer, and reports its block count in `s.blocks`. It creates
the single empty-block sentinel when the entire stream is empty. For an
empty parallel partition bypass it and use `(value, blocks) = (0, 0)`.

Independent raw-byte partitions start at region boundaries, multiples of
`8B` bytes. Only the final partition may end within a region. For partial
values A and D, with D containing `p_D` actual blocks,

```text
join(A, D, p_D) = A*y^(p_D) XOR D
```

is `chainhash128_join`. Sum actual partition block counts, replace a zero
total by one for the whole empty message, add `ell*y^p`, and finalize once
(`ch128_finish`). Arbitrary within-region byte splits cannot be
independently hashed: logical blocks are interleaved. No invertibility
assumption is used.

## Portability, dispatch and evaluation identity

`chainhash128_portable` is serial eager C99. `chainhash128_evaluate`
exposes all evaluation choices, `chainhash128_with_backend` selects the
specialized one-shot kernels, and `chainhash128` uses runtime dispatch.
`chainhash128_selftest` is a smoke test; the full matrix is
[test/128](../test/128/README.md).

Backend IDs: `CH128_PORTABLE = 0`, `CH128_XMM = 1`, `CH128_YMM = 2`,
`CH128_ZMM = 3`, `CH128_NEON = 4`. Explicit hardware calls require
`chainhash128_has_backend(id)`. x86 target attributes permit baseline
compilation without global ISA flags. CPUID and XGETBV require AVX/PCLMUL
and XMM/YMM OS state for XMM, AVX2/VPCLMULQDQ for YMM, and AVX512F with ZMM
OS state for ZMM. Detection caching uses relaxed atomics. The 128-bit path
uses VEX PCLMUL; the wider paths use lane-parallel VPCLMULQDQ.

AArch64 requires crypto instructions enabled at compilation
(`-march=native+crypto` on Apple, `-march=armv8-a+crypto` generally).
PMULL/PMULL2 and the message LD1 loads are pinned by inline assembly. This
is a compile-time CPU capability contract on ARM, not a Linux HWCAP probe.
Big-endian ARM and other platforms use portable C. `CHAINHASH128_PORTABLE`
omits all hardware paths.

The polynomial above is the definition. SIMD width, `k = 1/2/4/8`,
eager/lazy reduction, schoolbook/Karatsuba multiplication, byte chunking
and legal thread splits all evaluate the same function, for every key
including `y = 0`. There is no architecture-dependent comb permutation,
block order, key period or length placement. Changing the comb, pair
presence, block order or block size changes the function.
