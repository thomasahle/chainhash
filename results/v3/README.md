# v3 evidence index

[REPORT.md](REPORT.md) and [speeds_chainhash_v3.json](speeds_chainhash_v3.json)
are the supplied measured implementation's unmodified report and aggregation.
“The hash definition is unchanged” in that report means unchanged from the
D3 design during tuning; v3 is a different function from v1 and v2.

- [out/Xeon](out/Xeon/): Speed passes, alignment/short RDTSC CSVs, Sanity,
  Zeroes, property, compiler, sanitizer and alignment records.
- [out/M2Pro](out/M2Pro/): three-pass Speed data, short-input CSVs and
  outlier flags, load gates, Sanity, property and guarded-tail records.
  `archive-scalar-tail` contains superseded timings, excluded from the final
  aggregation rather than silently deleted.
- [audit](audit/): full and excerpted object-code disassembly, instruction
  inventories, audit wrapper and NEON extraction script.
- [bench](bench/): original timing programs, SMHasher3 registration,
  collectors and sequencing scripts. Their [README](bench/README.md)
  describes the original build environment and control objects.
- [chainhash_v3.h](chainhash_v3.h): **archived measured source**, SHA-256
  `402e3c31638aec9154bd896e2269736119d7be2c530a934f3625abd80ccf1825`.
  The three neighboring shipped/x86/strided headers are the archived timing
  controls. Applications should use [include/chainhash3.h](../../include/chainhash3.h).
- [INTEGRATION.md](INTEGRATION.md): fresh public-repository checks, toolchain
  limitations and scope, with their separate logs.

The archive is evidence, not an automatically runnable SMHasher3 distribution.
Its scripts retain the original host paths, compiler invocations and external
SMHasher3/control/timer dependencies; adapt paths to a separately configured
checkout to rerun timings. The integrated tests are under
[test/v3](../../test/v3/README.md), replacing the original `tests/` location.
No original prompts or conversation logs are included. No fresh timing or
full v3 SMHasher3 suite is claimed by this integration.

All **26 raw Speed run files** referenced by the aggregation were checked
against their recorded SHA-256 values during integration. The exact measured
header matches the aggregation's source hash. The public header differs only
in documentation comments (specification path, vector-generator path and
attribution); its non-comment code is identical. v1's public header is
byte-identical to the pre-integration Git version.

The design memo's expected resident size and small-message speed were
predictions: the actual resident v3 key is 448 bytes, and the measured short
path regresses. See [the normative specification](../../docs/SPEC_v3.md)
and [the written theorem](../../docs/THEOREM_v3.md), whose Lean status is
**in progress**.

Raw logs and disassembly retain their original whitespace, including trailing
spaces and blank lines, so recorded content hashes remain verifiable. The
authored-code/documentation whitespace check excludes these raw artifacts.
