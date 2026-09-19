# Draft SMHasher3 registration

Local author patch files only; no pull request has been opened or sent.

Base: `3de870c7ab449ad11cf450848d9270e3f54102d1` from
<https://gitlab.com/fwojcik/smhasher3>, the pinned test revision used by
the benchmark lanes. The GitHub mirror's inspected head was
`3b619371047761408406991685da1c2b3f751899`.

Apply the two numbered patches with `git am` in order. The second patch adds
`hashes/chainhash.cpp`, the `Hashsrc.cmake` entry, the two unchanged public
headers under `hashes/chainhash/`, the MIT LICENSE, and the seed expansion
and key model in `hashes/chainhash/README.md`. All code needed by the
registrations is included. The first patch is a separately reviewable build
fix.

## Registrations and verification values

| Registration | Digest | LE verification | BE verification |
| --- | --- | --- | --- |
| chainhash | 64 bits | `66672BD6` | `FA8A8D3B` |
| chainhash-128 | 128 bits | `1FCA728C` | `1FCA728C` |

The suite's 64-bit seed goes to the headers' own seed constructors:
SplitMix64 outputs, encoded little-endian, become the 64 key bytes of
ChainHash (`s, y, c0..c4, tau`) and the 128 key bytes of ChainHash-128.
A 64-bit seed carries 64 bits of entropy; the collision bound assumes 64
(resp. 128) uniformly random key bytes and says nothing about this adapter.
See the included source README for the exact arithmetic and order.

Message bytes stay canonical little-endian. The byte-swapped 64-bit
registration changes only the digest serialization; the 128-bit digest is
always its 16 canonical little-endian bytes, so both of its values coincide.
Each registration's `initfn` runs the header's self-test.

## Apple arm64 and the pinned revision

CMake on Apple Silicon reports `arm64`. The pinned `family.cmake`
recognizes only `arm` and `aarch64`, classifies the M2 as `Other`, and skips
NEON/ACLE detection. Patch 0001 adds `arm64` to that family branch. The
inspected current GitHub head already contains an equivalent fix: omit 0001
when rebasing onto a revision which has it. Use a fresh build directory;
cached failed feature probes can otherwise survive.

The pinned revision additionally has a macOS C++ type mismatch in
`util/Random.cpp`: `threefry` requires `uint64_t &`, while `offset_rounds`
was `size_t`. Apply `prerequisites/random-counter-type.patch` with `git apply`
for an Apple build. It is kept separate because upstream requires Hashlib
and Testlib changes to be submitted separately. It changes the variable
type, not random values on these 64-bit hosts. This prerequisite is not part
of the hash PR.

Example Apple build of this pinned source:

```sh
git am /path/to/0001-*.patch /path/to/0002-*.patch
git apply /path/to/prerequisites/random-counter-type.patch
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  '-DCMAKE_CXX_FLAGS=-Xclang -target-feature -Xclang +aes' \
  -DENDIAN_DETECT_BUILDTIME=OFF -DDETECTED_LITTLE_ENDIAN=ON
cmake --build build -j4
nice -n 10 build/SMHasher3 --test=All --ncpu=8 --noexit-on-failure \
  --exit-code-on-failure chainhash
```

Repeat for `chainhash-128`. The CMake policy option handles CMake 4's
removal of compatibility below 3.5; the endian options avoid the old
missing `TestEndianess.c.in` template. Neither is a hash definition change.
On x86 the headers need no global ISA flags (PCLMUL/VPCLMULQDQ paths use
target attributes and run-time dispatch); on AArch64 enable crypto
instructions for PMULL, otherwise the headers use their portable paths.

## Validation

On the Xeon (GCC 11.5, Release), `git am` of both patches onto the pinned
base builds, and `SMHasher3 chainhash --test=Sanity` and
`SMHasher3 chainhash-128 --test=Sanity` print the verification values above
and pass every sanity check. The full `--test=All` suite for `chainhash`
(200/200 on the Xeon and on an M2 Pro, identical diagnostics on both hosts)
is recorded in the ChainHash repository under `results/64/suite/`
(<https://github.com/thomasahle/chainhash/tree/main/results/64/suite>), with
the raw logs, the per-run summaries and the header provenance. These drafts
make no claim of upstream acceptance. The author must review upstream's DCO before
submission; no sign-off is inserted by these draft files.

## Header revision

The headers embedded in patch 0002 are the ChainHash repository's
`include/chainhash.h` (SHA-256
`a5730797bc9aafbf8ff11f6a2c4919d2f1622c55a3a40d439f50242d4b10ee6e`) and
`include/chainhash128.h` (SHA-256
`370ea4ba5d3b96a1a930487db8ab5f547d56696b9482157c79843a8780b00a9d`),
copied unchanged; the adapter is the repository's `smhasher3/chainhash.cpp`.
