# ChainHash v3: ChainHash-Horner specification

This defines the function in [`include/chainhash3.h`](../include/chainhash3.h).
It is a new digest family. [`chainhash.h`](../include/chainhash.h) retains v1,
the paper's function. The adjacent-pair 1 KiB x86 function is v2. Neither is
bit-compatible with v3. The [design record](DESIGN_MEMO_v3.md) explains the
choice; this specification resolves its implementation details and supersedes
its estimates. “Block” below always means a logical 256-byte comb block.

## Representation and domain

Let `F = GF(2)[X]/(X^64 + X^4 + X^3 + X + 1)` and `q=2^64`.
The bits of a numerical 64-bit word are polynomial coefficients, bit zero
being the constant coefficient. Field addition is XOR; multiplication is
carry-less multiplication followed by reduction. In F, `X^64=27` (`0x1b`).
Only the final integer twist uses addition with carries.

A message has `ell` bytes, `0 <= ell < 2^64`. Set
`L = ell/8 + (ell%8 != 0)`. Word `w_i` is bytes `8i..8i+7`, little endian,
with missing final bytes zero. An entirely absent word is zero. A partial
word is present if at least one of its bytes is present. No terminator or
extra length word is appended. Key byte strings are also little endian.
The result is a numerical `uint64_t`; serialize its low byte first for a
canonical eight-byte digest. Input alignment does not change the result.

The C API requires a valid key and a readable object of `len` bytes, with
`len` representable by `size_t`. `data=NULL` is allowed for zero bytes.
Streaming's accumulated length must remain below `2^64`; its update asserts
against overflow, and callers must meet that precondition even with NDEBUG.
Block counts use quotient/remainder rather than an overflowing rounded length.

## Comb layout: every index map

For a zero-based word index i, uniquely decompose

```text
R = floor(i/128)          region, 1024 consecutive bytes
C = floor((i%128)/16)     chunk within region, 0..7
h = floor((i%16)/8)       half of chunk, 0..1
j = floor((i%8)/2)        comb lane, 0..3
e = i%2                  word within the lane's half, 0..1
i = 128R + 16C + 8h + 2j + e
```

Every present first word (`h=0`, `i<L`) defines the pair `(w_i,w_(i+8))`.
Its one-based block index is `t=4R+j+1`, its pair slot is `pi=2C+e`
(`0..15`), and its within-block positions are `2pi` (first) and `2pi+1`
(partner). Conversely, given block t and position a (`0..31`),

```text
R = floor((t-1)/4); j = (t-1)%4
pi = floor(a/2); h = a%2
C = floor(pi/2); e = pi%2
i = 128R + 16C + 8h + 2j + e
partner_position(a) = a XOR 1
partner_word(i) = i+8 if h=0, i-8 if h=1
```

Thus a complete logical block has 32 words (256 bytes), gathered from eight
chunks across a 1 KiB region. It is **not** a contiguous 256-byte slice.
Four such blocks are ordered by j within each region, then by R.

For `ell=1024Q+r`, `0<=r<1024`, the exact block count is

```text
p(ell) = 1                              if ell=0
         4Q                             if ell>0 and r=0
         4Q + min(4, 1+floor((r-1)/16)) if r>0
```

There are no gaps in the block indices. For example, lengths 1, 17, 33,
49, 256, 1024, 1025 have block counts 1, 2, 3, 4, 4, 4, 5 respectively.
The empty message has one empty block with value zero.

## Keys and physical schedule

The ideal, or paper, key model for **this new function** samples 39 independent
uniform words in this order:

```text
kappa[0..31], y, c0, c1, c2, c3, c4, tau
```

`chainhash_v3_key_from_words(words39)` accepts numerical words;
`chainhash_v3_key_from_ideal_bytes(bytes312)` decodes 312 bytes in that order.
The default **model A** takes exactly 64 independent random bytes:

```text
s, y, c0, c1, c2, c3, c4, tau
kappa[m] = s^(m+1) in F, m=0..31
```

Use `chainhash_v3_key_from_bytes(bytes64)`. Zero values, including `s=0`
and `y=0`, are valid; no rejection, division, or inverse is used.
The convenience `chainhash_v3_key_from_seed(seed)` expands eight successive
SplitMix64 outputs into those 64 bytes. It has only 64 bits of seed entropy
and does not inherit the model-A theorem.

The resident `chainhash_v3_key` is 56 words / 448 bytes, with ordinary
`uint64_t` alignment. Its fields are:

```text
ph[4C..4C+3] = [kappa[4C], kappa[4C+2], kappa[4C+1], kappa[4C+3]]
yp[i] = y^i       for i=0..8, yp[0]=1
yh[i] = 27*y^i    for i=0..8, yh[0]=27
c[0..4], tau
```

The first-half load at byte offset `128C+16j` receives key words
`[kappa[4C],kappa[4C+2]]`; its partner load at `128C+64+16j` receives
`[kappa[4C+1],kappa[4C+3]]`. Wider vectors broadcast this same pattern to
each 128-bit lane. The resident layout is a cache, not a serialized key ABI.

## Levels 1, 2 and 3

For each block t, reduce the XOR of its present keyed pair products:

```text
C_t = XOR over i<L with h(i)=0 and t(i)=t of
      clmul64(w_i XOR kappa[2*pi(i)],
              w_(i+8) XOR kappa[2*pi(i)+1])
b_t = C_t mod (X^64+X^4+X^3+X+1)
```

`C_t` is a 128-bit polynomial representative; `b_t` is a field word (called
`c_t` in the design memo). If a pair's first word is absent, omit the entire
product, including its keys. If only its partner is absent, keep the partner
key and substitute zero for that message word. Padding the entire region
with zeroes and hashing every pair would define a different function.

Level 2 is ordinary Horner, with the **byte length as leading coefficient**:

```text
P_0 = ell
P_t = y*P_(t-1) XOR b_t, t=1..p
V = P_p = ell*y^p XOR XOR_(t=1..p) b_t*y^(p-t)
```

Interpret V as an unsigned integer for `v=(V+tau) mod 2^64`. Reinterpret v
as a field word and evaluate the unchanged finalizer circuit:

```text
qv = v*v
rv = (qv XOR c0)*(v XOR qv XOR c1)
H  = (v XOR c2)*(rv XOR c3) XOR c4
```

All three products are in F. The five c words are **circuit parameters**,
not the five monomial coefficients of a quintic. Empty input yields V=0
regardless of y; its digest is the finalizer applied to the integer tau.

## Evaluation-choice guarantee and exact-count k-lane schedule

The polynomial above is the definition. Changing SIMD width, accumulator
count, reduction placement, stride k, or a valid partition changes only its
evaluation. This identity holds for every key, including y=0, and does not
rely on a probability claim. Changing the comb, pair presence, block order,
key period, or length placement changes the function.

Here is an exact-count schedule for any integer `k>=1`. Include the length
as coefficient `a_0=ell`; set `a_i=b_i` for `1<=i<=p`. Let `N=p+1` and
`m=min(k,N)`. Initialize each active lane j to `a_j`, `j=0..m-1`. It owns
coefficients `a_j,a_(j+k),a_(j+2k),...`:

```text
for j = 0 .. m-1:
    R_j = a_j
    i = j
    while i+k < N:                  # look ahead before advancing this lane
        R_j = R_j*y^k XOR a_(i+k)
        i += k
    e_j = (p-j) mod k
V = XOR_j R_j*y^e_j                  # XOR directly when e_j=0
```

The lookahead is in **coefficient indices**, not an unchecked memory load.
A lane whose next coefficient does not exist must not be multiplied again.
In particular, a short final group is not padded with fictitious zero
coefficients: that would add powers of y. Never read beyond the input object.

There are exactly `N-m` lane-update field multiplications and `m-1` nontrivial
weight multiplications, hence **p field multiplications**, the serial Horner
count. This excludes level 1, key-power preprocessing, and the finalizer.
There is exactly one zero final exponent. This count describes the eager
algebraic schedule; a lazy update uses two raw 64x64 products and reductions
have their own instruction cost. It is not a claim that the shipped regular
SIMD loops eliminate every multiplication by zero or one. The executable
[`schedule.c`](../test/v3/schedule.c) checks the identity and count, including
`p<k`, all residues, and `y=0/1`.

The generic streaming implementation instead starts k lanes at zero,
omits `a_0`, and sends zero-based **block** index i to lane `i mod k`:
`R_j <- y^k*R_j XOR b_(i+1)`. After p blocks its message polynomial is
`XOR_j R_j*y^((p-1-j) mod k)`, omitting unused lanes; add `ell*y^p` once.
The API supports k=1..8, with lazy either 0 or 1.

For a lazy representative `U=lo+X^64*hi`, use

```text
U <- clmul64(lo,y^k) XOR clmul64(hi,27*y^k) XOR C_t
```

Its reduction is exactly the eager lane update because `X^64=27` in F.
There is no requirement that U be the canonical representative. XOR
accumulation and intermediate reductions therefore commute with the final
field calculation. The shipped full-region kernels use k=4, initialize
lane 3 to ell and the other lanes to zero, then combine with weights
`[y^3,y^2,y,1]`. After Q full regions, that length contribution is
`ell*y^(4Q)`. The remaining r bytes contribute exactly p(r) more Horner
steps. With no complete region the initial scalar state is ell.

## Streaming, partial values and parallel joins

```c
chainhash_v3_stream stream;
chainhash_v3_init(&stream, &key, 4, 1, chainhash_v3_backend());
chainhash_v3_update(&stream, first, first_len);
chainhash_v3_update(&stream, second, second_len);
uint64_t digest = chainhash_v3_final(&stream);
```

The key must outlive the stream and remain unchanged. The stream is mutable
and is not shared concurrently. Updates concatenate bytes; arbitrary chunk
boundaries and empty updates are allowed. Only an unfinished 1024-byte region
is buffered. Finalization processes its actually present blocks, inserts the
total length, and applies the finalizer. `final` or `partial` consumes the
stream: do not update or finalize it again without reinitialization.

`chainhash_v3_partial(&stream)` returns only the message polynomial,
without the length term or finalizer. It updates `stream.blocks` to its
block count. Like whole-message finalization, calling it on an empty stream
creates the one-empty-block sentinel. **For an empty partition, bypass it
and use `(value,blocks)=(0,0)`.** This is the convention used by the tests.

Independent raw-byte partitions must start at multiples of 1024 bytes from
the original message start; only the last partition may end inside a region.
For partial values A, B, where B contains p_B actual blocks,

```text
join(A,B,p_B) = A*y^p_B XOR B
```

is `chainhash_v3_join`. Sum partition block counts, replace a total of zero
by one only for the whole empty message, add `ell*y^p`, and apply the finalizer
once. Intra-region raw-byte splits cannot be independently hashed because
blocks are interleaved. No nonzero-y assumption or inverse is needed.

## Portable and SIMD APIs

`chainhash_v3_portable` is serial eager Horner. `chainhash_v3` selects a
backend. `chainhash_v3_evaluate` exposes stride, lazy/eager and backend;
`chainhash_v3_with_backend` exposes the specialized one-shot paths.
`chainhash_v3_selftest()` returns nonzero on success.

Backend IDs are `CHV3_PORTABLE=0`, `CHV3_XMM=1`, `CHV3_YMM=2`,
`CHV3_ZMM=3`, `CHV3_NEON=4`. Explicit backend calls require a successful
`chainhash_v3_has_backend(id)` check. GCC/Clang x86 target attributes allow
baseline compilation with no global ISA flags; CPUID and XGETBV check
instruction and OS state support. XMM needs AVX and PCLMUL, YMM additionally
AVX2 and VPCLMULQDQ, ZMM additionally AVX512F and enabled ZMM state.
The detection cache uses relaxed atomics. AArch64 NEON needs crypto
instructions enabled at build time; use `-march=native+crypto` on Apple or
`-march=armv8-a+crypto` on other AArch64 hosts. Other/big-endian targets use
portable C. `CHAINHASH_V3_PORTABLE` removes all SIMD code.

The long-input loop structure is inspired by Orson Peters's
[PolymurHash](https://github.com/orlp/polymur-hash#how-it-works-and-why-its-fast):
keyed pair products and a running polynomial state. ChainHash-Horner's
binary field, comb layout, length placement and finalizer are defined here.
