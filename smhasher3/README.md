# SMHasher3 registration

`chainhash.cpp` registers both functions with
[SMHasher3](https://gitlab.com/fwojcik/smhasher3):

| Registration | Digest | Verification value |
| --- | --- | --- |
| `chainhash` | 64 bits | LE `0x66672BD6`, BE `0xFA8A8D3B` |
| `chainhash-128` | 128 bits | `0x1FCA728C` (endian independent) |

## Installing

In an SMHasher3 checkout:

```sh
cp smhasher3/chainhash.cpp hashes/
mkdir -p hashes/chainhash
cp include/chainhash.h include/chainhash128.h LICENSE hashes/chainhash/
```

Add `hashes/chainhash.cpp` to `HASH_SRC_FILES` in `hashes/Hashsrc.cmake`,
then build and run:

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j8
build/SMHasher3 chainhash --test=Sanity
build/SMHasher3 chainhash-128 --test=Sanity
build/SMHasher3 chainhash --test=All
```

The headers select their hardware paths themselves: x86 builds need no
global ISA flags (the PCLMUL/VPCLMULQDQ paths use target attributes and are
dispatched at run time), and AArch64 needs crypto instructions enabled
(`-march=armv8-a+crypto`, or `-march=native+crypto` on Apple). Without
them the headers use their portable paths and produce the same digests.
The registration's `initfn` runs each header's self-test before any test.

## Validation

ChainHash-128 (`chainhash-128`, 0x1FCA728C): all 188 SMHasher3 tests pass on the Xeon; record in [results/128/suite/](../results/128/suite/README.md).

`chainhash` passes the complete suite (`--test=All`, 200 tests: upstream's
188 plus a 12-case SeedDifferential family) on an Intel Xeon 8375C and an
Apple M2 Pro with identical diagnostics; the logs, run metadata and the
tested header's SHA-256 are in
[results/64/suite/](../results/64/suite/README.md). Sanity, zeroes and
thread-safety records for both registrations on both hosts are under
[results/64/out/](../results/64/out/) and
[results/128/evidence/](../results/128/evidence/).

## Seed expansion

SMHasher3 supplies a 64-bit seed. The registrations pass it to the headers'
own seed constructors, `chainhash_key_from_seed` and
`chainhash128_key_from_seed`. Starting from the seed, each SplitMix64 step
adds `0x9e3779b97f4a7c15` modulo `2^64` and returns

```text
z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9
z = (z ^ (z >> 27)) * 0x94d049bb133111eb
z ^ (z >> 31)
```

with wrapping multiplication. ChainHash takes eight outputs, encoded
little-endian, as the 64 key bytes `s, y, c0, c1, c2, c3, c4, tau`;
ChainHash-128 takes sixteen outputs as its 128 key bytes, two per 128-bit
word in the same order. The key constructor then expands the block keys as
`kappa[m] = s^(m+1)` in the field and precomputes the Horner powers. This
expansion defines the verification values above.

A 64-bit seed carries 64 bits of entropy. The collision bound in
[docs/THEOREM.md](../docs/THEOREM.md) and [docs/THEOREM-128.md](../docs/THEOREM-128.md)
assumes 64 (resp. 128) uniformly random key bytes; the benchmark adapter is
outside that assumption, and statistical suite results describe the adapter,
not the theorem.

The seed callback prepares a thread-local key and returns its address; the
hash function uses that pointer and no shared mutable state. Message words
are canonical little-endian in every registration. The byte-swapped 64-bit
registration changes only the serialization of the digest, which is why its
BE value differs; the 128-bit digest is always its 16 canonical
little-endian bytes, so both of its values coincide.
