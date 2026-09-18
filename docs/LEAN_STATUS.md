# Current Lean status

The default’s complete concrete 41-independent-word theorem and the alternative
80-byte model-A fixed-length and at-most-length bounds are proved and shipped in
[../lean/](../lean/README.md), with Xeon build and axiom-audit evidence.
The older assembly report's partial status is historical and superseded.

Model A includes the exact `E_A(L)` envelope and reference-hash correspondence.
All shipped header paths and the Lean encoding use strided pairs.
Model B (56 bytes) has a written proof in
[SEEDED_THEOREMS.md](SEEDED_THEOREMS.md), but no complete Lean collision theorem.
Exact formal statements, scope, and remaining claims are listed in
[lean/README.md](../lean/README.md).
