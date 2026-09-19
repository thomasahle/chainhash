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

ChainHash-128 v3 (`include/chainhash128_v3.h`) has **no Lean theorem in this
repository**; its written bounds in [THEOREM_v3_128.md](THEOREM_v3_128.md)
transfer the Lean-proved 64-bit v3 theorem to `GF(2^128)`, and the Lean port
is in progress. The earlier strided ChainHash-128 has a complete Lean proof
in the paper repository's proof lane, which is not shipped here.
