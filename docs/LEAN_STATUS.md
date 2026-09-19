# Current Lean status

The default 80-byte model-A fixed-length and at-most-length bounds and the
complete concrete 41-independent-word theorem are proved and shipped in
[../lean/](../lean/README.md), with Xeon build and axiom-audit evidence.
The older assembly report's partial status is historical and superseded.

Model A includes the exact `E_A(L)` envelope and reference-hash correspondence.
All shipped header paths and the Lean encoding use strided pairs.
Model B (56 bytes) has a written proof in
[SEEDED_THEOREMS.md](SEEDED_THEOREMS.md), but no complete Lean collision theorem.
Exact formal statements, scope, and remaining claims are listed in
[lean/README.md](../lean/README.md).

ChainHash-128 v3 (`include/chainhash128_v3.h`) is **Lean-proved** in
`ProvenHashes.ChainHash.V3_128` (116 theorems): the paper and model-A byte
collision bounds over the GCM field, evaluation independence for every
positive stride and the lazy state, and the exact score minima 127, 127 and
`128 - log2 33`. Exact signatures are in [THEOREM_v3_128.md](THEOREM_v3_128.md);
the integration and reproduction record is
[lean/V3_128_INTEGRATION.md](../lean/V3_128_INTEGRATION.md). The 128-bit
base it stands on, including the earlier strided ChainHash-128 theorems
(`ProvenHashes.ChainHash128.Strided`) and the GCM modulus irreducibility
certificate, is shipped under `lean/ProvenHashes/ChainHash128/`.
