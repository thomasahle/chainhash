# ChainHash v3 proof integration

**Result: PASS, 2026-09-19 UTC.** The complete Lake build finished
(7434 jobs); all 672 exported theorem/lemma audits passed with only the
allowed standard axioms, source scans found no forbidden tokens, and all
464 C/Lean vectors matched the source-lane output SHA-256.

The public proof project adds 89 theorems in ten unchanged `ChainHashV3*`
modules, in namespace `ProvenHashes.ChainHash.V3`. The complete generated
audit covers 672 exported theorems/lemmas across 79 proof modules. The
[principal signatures](../docs/THEOREM_v3.md#formalization-and-limits),
[complete source catalogue](THEOREM_STATEMENTS.md), and
[verification transcript](VERIFICATION.txt) describe the checked result.

## Source and scope

The proof source is `lean-chainhash-v3-64` commit
`54410e433a1d9f79cd4104dc9fc2cdea72164f07`, based on model-A commit
`a3939c01b87d962ae170776b656a154300d5f3ca`. A subsequent source-lane commit,
`c757ccca1f9f8160413806f9dd4c7fd4e8c916e6`, records completion documentation;
the ten proof modules are unchanged from the specified proof commit.
[PROVENANCE.json](PROVENANCE.json) records the source and integrated SHA-256
of every module and the two vector sources. [SOURCE_HEADS.txt](SOURCE_HEADS.txt)
keeps the original lane identities without private machine locations.

| Module | Checked contribution |
| --- | --- |
| `ChainHashV3Comb` | Comb byte encoding, active pairs, partner exponents, Frobenius roots |
| `ChainHashV3PH` | Seeded difference polynomials and reduced CLNH difference universality |
| `ChainHashV3Horner` | Horner degree, leading coefficients, root count and composition |
| `ChainHashV3Model` | Complete hash, key cardinalities, length injection and envelopes |
| `ChainHashV3Bytes` | Unconditional paper bound and unequal-length separation |
| `ChainHashV3Seeded` | Short-message Frobenius improvement and complete model-A bound |
| `ChainHashV3Keys` | Word/byte key bijections and `List UInt8` / `UInt64` endpoints |
| `ChainHashV3Evaluation` | Serial Horner equals the physical exact-count schedule |
| `ChainHashV3Lazy` | Bounded raw state, lazy reduction and complete function equalities |
| `ChainHashV3Scores` | Exact real-log score minima of 63 and envelope tables |

The paper distribution has 39 independent uniform words (312 bytes).
Model A has exactly 64 independent uniform bytes. The byte endpoints require
`8*L < 2^64`, and model A also requires `0 < L`. The evaluation theorem holds
for every positive natural stride and all multiplier values, including zero.
The scores describe certified upper envelopes, not necessarily attained
collision probabilities. No stage-bound hypotheses remain in the endpoints.

The shared dependency files already match the source lane except `NH.lean`,
where the public project retains its stronger `CommRing` statements and its
previous counting-lemma deduplication. No inherited proof was replaced.
The integrated build checks V3 against those existing dependencies.

## Audit and verification

`ProvenHashes.lean` imports all ten modules; `ChainHash.lean` imports that
aggregate. `generate_verification.py` regenerates `Verification.lean` and the
signature catalogue, and requires all five principal V3 endpoints, all ten
modules and at least 89 V3 declarations. `verify.sh` regenerates the audit
before hashing or building. `check_verification.py` requires exactly the
expected theorem names and allows only `propext`, `Classical.choice` and
`Quot.sound`. The source scan also rejects `sorry`, `admit`, `native_decide`,
`unsafe` and custom axiom declarations.

Lean is pinned to 4.24.0 and Mathlib to
`f897ebcf72cd16f89ab4577d0c826cd14afaafc7`. The Xeon verification uses an
isolated checkout and a copy of the earlier integration's `.lake` cache.
The source lanes are preserved. The transcript records the base public
commit and SHA-256 manifest of the verified working tree; its base commit
is intentionally the parent of this integration, since the evidence is
included in the integration commit itself.

Reproduce on a Linux Xeon with elan, Python 3, a C99 compiler and the pinned
Mathlib cache available:

```sh
ssh <xeon-host>
cd <xeon-work>/chainhash/lean
export LEAN_NUM_THREADS=32
nice -n 10 taskset -c 0-31 ./verify.sh
```

The script also applies `nice -n 10` and the affinity internally. Because
the recorded invocation wraps the driver too, nested heavy commands reach
Linux niceness 19. All remain restricted to CPUs 0–31 with 32 Lean threads.
For the recorded host, certificate discovery requires the system CA bundle:

```sh
export SSL_CERT_FILE=/etc/pki/tls/certs/ca-bundle.crt
export CURL_CA_BUNDLE="$SSL_CERT_FILE"
```

An initial cache-fetch attempt without that configuration encountered
OpenSSL `STORE routines::unregistered scheme` errors. It was stopped before
the build; [V3_CACHE_FAILURE.txt](V3_CACHE_FAILURE.txt) retains a sanitized
excerpt. The completed verification uses the existing source-lane toolchain
and cache environment, including the CA configuration above. The failure
was environmental and required no proof changes.

## Vector evidence and limits

The source lane reported 464 passing vectors and a successful axiom audit.
The [89 source checkpoint records](V3_SOURCE_BUILDS.txt) retain source-prefix
and build-log hashes plus each successful build result; their prefix hashes
were recomputed against the imported modules. These are retained builds,
not 89 fresh integration runs. Its [elaborated signatures and axioms](V3_SOURCE_AUDIT.txt) and
[vector summary](V3_SOURCE_VECTORS.txt) are retained as source evidence,
separate from the fresh integrated [VERIFICATION.txt](VERIFICATION.txt) and
[V3_VECTORS.txt](V3_VECTORS.txt).

`vectors/V3.lean` is copied unchanged. `../test/lean_vectors_v3.c` changes
only the include name to the public `chainhash3.h`. `check_vectors_v3.py`
retains the original corpus construction and seed `0x43485633`, adapting
paths, CPU affinity and thread count. It generates 464 inputs for both key
models, zero keys, zero/one multipliers and random keys; lengths include
0–33, word/pair/block/region boundaries and inputs through 4096 bytes.
It compares every available C backend at strides 1–8 in eager and lazy modes,
plus dispatched one-shot evaluation, with the independent bit-serial Lean
reference. Both outputs must have 464 rows and agree byte-for-byte.

The generated inputs, executable, backend log and both output files are
under `build/v3-vectors/` and can be regenerated. The recorded
[backend log](V3_BACKENDS.txt) identifies the exercised C backends. The expected source-lane
output SHA-256 is
`732b082f59e860e8171016c6919be1d863320cfbafe358ab3f52900de6017103`.
The retained source header had SHA-256
`402e3c31638aec9154bd896e2269736119d7be2c530a934f3625abd80ccf1825`;
the integration transcript hashes the public header actually tested.

The original source lane used eight threads on CPUs 48–55 with nice priority
10; the fresh integration uses 32 threads on CPUs 0–31. Portable, XMM, YMM
and ZMM are available on the verification Xeon; NEON is not exercised there.
These vectors establish finite cross-language consistency, not a formal
C/compiler/SIMD refinement or memory-safety proof. Streaming and parallel
join implementation tests remain in the existing C test suite. No new full
SMHasher3 run, adaptive-input guarantee or SplitMix64-key theorem is claimed.
