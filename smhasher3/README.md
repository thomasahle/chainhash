# SMHasher3 adapter

`chainhash.cpp` is the optimized registration for the author's SMHasher3 fork.
It provides `chainhash-256` and `chainhash-1k` (the latter has two 512-byte
recurrence sub-blocks per 1 KB block). It retains legacy SplitMix64 seeding,
short-input caches, and native/swapped byte interpretations. The public
`include/chainhash.h` API specifies canonical little-endian 256-byte blocks.

Copy this source over `hashes/chainhash.cpp` in a configured fork checkout and
rebuild its SMHasher3 target. Run:

```sh
./build/SMHasher3 chainhash-256 --test=Sanity
./build/SMHasher3 chainhash-1k --test=Sanity
./build/SMHasher3 chainhash-256 --test=Sanity --endian=nondefault
./build/SMHasher3 chainhash-1k --test=Sanity --endian=nondefault
```

Native verification values are `AA4E2A3B` / `7A1ED2E0`; swapped values are
`11037F6F` / `85B2F299`. Sanity results and source/binary provenance for this
integration are in `results/vpclmul/` and the root `REPORT.md`.
