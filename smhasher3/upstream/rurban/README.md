# Draft rurban SMHasher registration

Local author patch only; no pull request has been opened or sent.

Base: `2688c165595ad68a0543f96940617adc5e22d87e` from
<https://github.com/rurban/smhasher>. Apply the numbered patch with `git am`.
It adds `ChainHash.cpp/.h`, entries in `main.cpp` and `CMakeLists.txt`, the
two unchanged public headers under `chainhash/`, the MIT LICENSE, and the
seed-model documentation in `chainhash/README.md`.

| Registration | Digest | Verification |
| --- | --- | --- |
| chainhash | 64 bits | `66672BD6` |
| chainhash-128 | 128 bits | `1FCA728C` |

Output bytes are explicitly little-endian. The classic `pfHash` API supplies
**32 bits of seed**, zero-extended and passed to the headers' own seed
constructors, the same SplitMix64 expansion the SMHasher3 draft uses (eight
words into the 64 ChainHash key bytes `s, y, c0..c4, tau`, sixteen into the
128 ChainHash-128 key bytes). Every change of seed rebuilds the key; a
thread-local last-seed cache avoids repeated key setup for fixed-seed speed
tests without ignoring seed changes. The theorem assumes uniformly random
key bytes, so it does not cover this seeded adapter. See
`chainhash/README.md` in the patch.

```sh
git am /path/to/0001-*.patch
git submodule update --init --recursive
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j8
SMHASHER_WORDS=/usr/share/dict/words taskset -c 8-15 nice -n 10 \
  build/SMHasher --test=All,BIC chainhash
```

Repeat for `chainhash-128`. Explicit `BIC` matters: this revision's default
`All` does not include BIC for 64-bit hashes. `LongNeighbors` is disabled in
upstream source and has no enabled test option. `--extra` is the separate
extended torture mode, including scanning the 32-bit seed space, and is not
used for the standard full-suite run. The suite has no SMHasher3-style
aggregate pass counter; the report labels its section-level counts
separately.

The SMHasher3 arm64 `family.cmake` issue and its fix are documented in
`../smhasher3/README.md`; rurban is tested on the Xeon.

## Validation

On the Xeon (GCC 11.5, Release), `git am` of the patch onto the pinned base
builds, and `SMHasher --test=Sanity chainhash` and
`SMHasher --test=Sanity chainhash-128` print the verification values above.
The full `All,BIC` Xeon run for `chainhash` is recorded in the ChainHash
repository under `results/64/suite/`
(<https://github.com/thomasahle/chainhash/tree/main/results/64/suite>), with
the raw log and the per-run summary.

## Notes for filing

* The two `g_hashes[]` rows are inserted at the top of the table for easy
  review; upstream groups hashes loosely by family and quality, so move the
  rows next to the other GOOD hashes if the maintainer prefers.
* The embedded headers are the ChainHash repository's `include/chainhash.h`
  (SHA-256 `a5730797bc9aafbf8ff11f6a2c4919d2f1622c55a3a40d439f50242d4b10ee6e`)
  and `include/chainhash128.h` (SHA-256
  `370ea4ba5d3b96a1a930487db8ab5f547d56696b9482157c79843a8780b00a9d`),
  copied unchanged.
