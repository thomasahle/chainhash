# ChainHash-192 collision bound

**Proof status: paper proof and machine-checked certificates; not in Lean.** The argument is below; the exact
computations it relies on are run by [`test/192/cert/certs.sh`](../test/192/cert/certs.sh) (listed at the end). Nothing here is
checked by a proof assistant. The outer stage and the finalizer are ChainHash-256's
([THEOREM-256.md](THEOREM-256.md)), over GF(2^192); only level 1 (the block) is new.

## Statement

Let `q = 2^192` and let L be an integer with `1 <= L <= 2^61-1`. Fix two distinct byte strings m, m', each at most 8L
bytes long, independently of the key. The key is 216 uniformly random bytes ([SPEC-192.md](SPEC-192.md) section 2):
nine elements of GF(2^192), of which s generates the 176 block masks s^1..s^176. Then

```text
Pr[ chainhash192(key, m) = chainhash192(key, m') ] <= min(1, N(L) / 2^192),
N(L) = max( d(8L) + E(p(8L)) + 1,  m'(p(8L)) + 1 ).
```

L counts 8-byte words: messages of up to n bytes use L = ⌈n/8⌉. The probability is over the key alone; the messages are
chosen without seeing the key or any hash value (not adaptive; not a MAC). The event is equality of all 192 output
bits; empty messages, partial blocks and unequal lengths are included.

- `p(ℓ)` is the block count of an ℓ-byte message: `p(0) = 1`, `p(ℓ) = ⌈ℓ/4096⌉`. Write `m = p(8L)` and `m' = ⌈m/8⌉`.
- `E(m) = 8 + m' − 1` if `m' >= 2`, and `E(m) = 2 floor(m/2)` if `m' = 1`.
- `d(n)` is the level-1 root count for n-byte messages. With `G = floor((n−1)/384)` and
  `P(n) = 8G + min(8, ceil((n − 384G)/8))` the highest (1-based) pair index that can carry message bytes:
  `d(n) = P(n)` for `n <= 192`, `d(n) = 2 P(n)` for `192 < n < 4096`, and `d(n) = 176` from one full block on
  (`d(0) = 1`).

| Message limit | L | `d(8L)` | `N(L)` |
| --- | ---: | ---: | ---: |
| 8 bytes | 1 | 1 | 2 |
| 16 bytes | 2 | 2 | 3 |
| 64 bytes | 8 | 8 | 9 |
| 192 bytes | 24 | 8 | 9 |
| 256 bytes | 32 | 16 | 17 |
| 1 KiB | 128 | 48 | 49 |
| 4 KiB | 512 | 176 | 177 |
| 16 KiB | 2048 | 176 | 181 |
| 64 KiB | 8192 | 176 | 186 |
| 1 MiB | 131072 | 176 | 216 |
| 16 MiB | 2097152 | 176 | 696 |
| 1 GiB | 134217728 | 176 | 32952 |
| 2^40 bytes | 137438953472 | 176 | 33554616 |

Divide by 2^192. These are upper bounds; they are not claimed to be attained. The seed constructor is a different key
distribution and the bound is not asserted for it.

## Score

The strength score `min_L log2(L / epsilon(L))` with `epsilon(L) = N(L)/2^192`, L in 8-byte words, is **191 bits**:
`N(L) <= 2L` for every L, with equality only at L = 1 (`N(1) = 2`). [`test/192/cert/bounds.py`](../test/192/cert/bounds.py)
checks this for every L < 2^20 and in ±3000 windows around 2^20..2^61 (1,300,575 values of L).

## Proof outline

1. **Level 1** (power key). Pairs i = 0..87 of a block (SPEC section 3) give the block value
   `c(s) = Σ_i (x_i + s^(2i+1))(y_i + s^(2i+2))`. Expanded,
   `c(s) = Σ x_i y_i + Σ (x_i s^(2i+2) + y_i s^(2i+1)) + Σ s^(4i+3)`: every data word is one limb of one element and every
   element owns one exponent (x_i → 2i+2, y_i → 2i+1, all distinct, in 1..176), and every data × data term sits at `s^0`.
   For two differing blocks the difference `Δc(s) = Σ Δ(x_i y_i) + Σ (Δx_i s^(2i+2) + Δy_i s^(2i+1))` is therefore a
   nonzero polynomial of degree at most `2P`, P the highest 1-based pair index holding message bytes, so it has at most
   `2P` roots s, and at most 176 for a full block. The pairs 80..87 have zero top limbs, which changes neither the
   exponents nor the degree. When only x words can carry bytes (n ≤ 192: the x rows of the first chunk; y = 0 for both
   messages), `Δc = Σ Δx_i s^(2i+2) = (Σ √Δx_i s^(i+1))²` (Frobenius is additive and bijective in characteristic 2) has at
   most `P` roots, and a 1–8-byte difference is `Δx s²` with the single root s = 0. Hence `d(n)` above. s is uniform and
   independent of y, z and the finalizer key.
2. **Lemma A** (region; as ChainHash-256). For region values `a ≠ a'` with the same q, `Δc(y)` is a nonzero polynomial of
   degree at most 2f: each paired value has its own linear exponent in 1..2f, and every data × data term, together with
   the bare value, sits at `y^0`.
3. **Lemma B** (chain; as ChainHash-256). For equal lengths, the first differing region's `Δc` is the leading
   z-coefficient of a polynomial of degree at most m′ − 1. For unequal lengths, the `z^{m'}` coefficient is a nonzero
   constant (the length or the length difference): at most m′ roots. y and z are independent of the masks and of each
   other.
4. **Finalizer** (as ChainHash-256, [THEOREM.md](THEOREM.md) step 4: the argument holds over any characteristic-two field). The integer
   twist is a bijection for fixed tau, and the degree-5 finalizer adds at most `1/2^192`.

Union bound: equal lengths give `(d + E + 1)/q` (first differing block: d; then its region: 2f ≤ 8 when m′ ≥ 2, 2⌊m/2⌋
when m′ = 1; then the chain: m′ − 1; finalizer: 1); unequal lengths give `(m′ + 1)/q`.

## Machine-checked certificates

`make certs` runs [`test/192/cert/certs.sh`](../test/192/cert/certs.sh), which checks, on the as-built header:

- **field** ([`field.py`](../test/192/cert/field.py)): Rabin irreducibility of `x^192 + x^7 + x^2 + x + 1` (x^(2^192) ≡ x;
  gcd with x^(2^96) − x and with x^(2^64) − x both 1), rejecting four negative controls: x^192 + 1, a product of two
  degree-96 irreducibles (fails only the gcd with x^(2^96) − x), a product of three degree-64 irreducibles (fails only
  the gcd with x^(2^64) − x), and x^192 + x^7 + x^2 + x. The C field product agrees with an independent
  Python product on 300 products ([`oracle.py`](../test/192/cert/oracle.py), dump from `cert_pk.c -DDUMP`);
- **level 1** ([`cert_pk.c`](../test/192/cert/cert_pk.c)): the as-built block value (the header's `C192_DERIVE` (four interleaved power chains) +
  `c192_block_ref`, applied to a 4096-byte block), as a polynomial in s over GF(2^192), is interpolated from 352 nodes
  (degree ≤ 351) and checked at 8 more; it must equal the exponent-class expansion above coefficient by coefficient,
  with x_i, y_i read from the bytes by the certificate's own reading of the layout (so the byte layout of SPEC section 3,
  including the zero-top-limb pairs 80..87, is certified too). Adversarial differences (single words at pairs 1, 2, 8,
  9, 41, 48, 73, 80, 81, 84, 88 in every present slot, a full pair, several words, dense, x-only) give nonzero difference
  polynomials of degree ≤ 176 with the predicted coefficients (the x-only difference is a square); the 1-word
  difference is exactly `Δw s²`. A negative control (a derivation with colliding exponents, `l_j = k_j`) is rejected;
- **level 2** ([`cert_2l.c`](../test/192/cert/cert_2l.c), adapted from ChainHash-256's): the region polynomial equals Lemma A's
  expansion for every q = 1..8, including adversarial differences; the outer polynomial in z is length-leading with the
  region values as coefficients, for m′ = 1..4 with odd last q; the ≤ 1-block path through the full hash; a negative
  control (colliding exponents) is rejected;
- **bound** ([`bounds.py`](../test/192/cert/bounds.py)): `N(L) <= 2L`, equality only at L = 1, score 191.

The vectors in [`test/192/vectors.txt`](../test/192/vectors.txt) are reproduced by the independent Python implementation
([`test/192/pyref.py`](../test/192/pyref.py)), the reference and every backend (`make test-192`).

**Gaps.** Lemmas A and B and the composition are proved on paper (ChainHash-256's argument, unchanged) and backed by the
exact computations above; none of it is formalized in Lean. The bound needs the 216 key bytes to be uniform; the seed
constructor is not covered.
