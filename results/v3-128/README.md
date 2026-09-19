# ChainHash-128 v3 evidence index

[REPORT.md](REPORT.md) is the source lane's measurement report and
[speeds_chainhash128_v3.json](speeds_chainhash128_v3.json) its machine-readable
aggregation of every retained SMHasher3 run on both hosts, in the layout of
the [64-bit v3 aggregation](../v3/speeds_chainhash_v3.json). The shipped
header [include/chainhash128_v3.h](../../include/chainhash128_v3.h) was
shipped **byte-identical** to the measured final header, SHA-256
`6c31b6f3638d545f3d95c95bd4edd7483a8964a429957fb1ab3111d9b107a455`, which
is the `header_sha256` recorded in the aggregation and in the M2 default
build provenance. Its two comment pointers, `SPEC.md` and `tests/vectors.c`,
mean [docs/SPEC_v3_128.md](../../docs/SPEC_v3_128.md) and
[test/v3-128/vectors.c](../../test/v3-128/vectors.c) in this repository.

After those measurements, the robustness audit of 2026-09-19 changed nine
lines of the header: the x86 load/store helpers now name their unaligned
vector pointer types (`__m128i_u`, `__m256i_u`; the 512-bit intrinsics take
`void *`). The generated code is identical (the disassembly of gcc 11 `-O3`
and clang 21 `-O3` builds does not change), every digest, frozen vector and
checksum in this directory is unchanged, and the shipped header's SHA-256 is
now `4e3edbfb4bbfdeb729178c9ab97bbf1ddb90c27b27360e72ebf89667a4f65194`; the
measured header remains the `6c31b6f3…` recorded in the aggregation.

## Selected function and headline measurements

ChainHash-128 v3, 512-byte family, schoolbook bulk products on XMM, ZMM and
NEON, Karatsuba on YMM and portable. SMHasher3 verification value
`0x1FCA728C` (both product methods, both byte-order entry points); the
256-byte comparison family is `0x0F709CAD`.

| Registration | Xeon 8375C, B/TSC | M2 Pro, B/calibrated cycle | 1–31 B, Xeon / M2 cycles per hash |
| --- | ---: | ---: | --- |
| `chainhash128-v3.512school` (forced schoolbook = the selected function) | **14.43** | **10.26** | 175.93 / 167.89 |
| `chainhash128-v3.512` (forced Karatsuba) | 13.91 | 9.39 | 175.86 / 170.19 |
| `chainhash128-v3` (public entry point, final header) | 14.45, one of two passes | 10.13 | 156.37 / 169.90 |
| `chainhash-128` (previous strided ChainHash-128, control) | 8.14 | 10.07 | 165.07 / 165.47 |
| `chainhash-v3` (64-bit ChainHash-Horner v3, control) | 28.25 | 25.10 | 155.90 / 89.24 |
| XXH3-128 | 19.82 | 12.53 | 34.94 / 30.94 |

Xeon: two complete `--test=Speed` passes on CPUs 16–23, higher fixed-262144-byte
bulk and lower 1–31-byte average selected independently. M2: three gated
passes (no SMHasher3 process, one-minute load below 4.5), medians taken
independently; no run deviated more than 15% from its median (largest v3
spread 1.75%). Xeon “cycles” are invariant-TSC ticks and M2 “cycles” are
SMHasher3's calibrated estimates; neither is a core-cycle measurement and
cross-host ratios are not meaningful. Key expansion is outside timing. The
M2 public-default row is a rebuild after NEON was switched to schoolbook;
the three earlier public-default runs (9.41 B/cycle, Karatsuba dispatch) are
retained under `evidence/M2/` and recorded as `superseded` in the JSON. The
Xeon public-default pass ran on the pre-selection header (SHA-256
`71b3be69…`, archived as [evidence/chainhash128_v3.h.pre-selection](evidence/chainhash128_v3.h.pre-selection));
ZMM already dispatched to schoolbook, so the Xeon default is unaffected.

The standalone RDTSC harness (`bench/rdtsc.c`, 262144 bytes, eight
alignments, median of three 512-call samples) measured 14.156 B/TSC for
512/schoolbook on ZMM against 13.711 for Karatsuba, 8.215/8.189 on XMM/YMM
schoolbook and 7.272/9.534 Karatsuba (`evidence/rdtsc-final512.csv`).

Short inputs regress against XXH3-128 (168–176 versus 31–35 cycles per hash)
and remain slightly above the previous ChainHash-128 (165); no small-key
parity is claimed. No full SMHasher3 quality suite is claimed for any
128-bit registration: the retained evidence is Sanity, append/prepend
zeroes and thread-safety on both hosts.

## Validation evidence

| Record | Result |
| --- | --- |
| `evidence/validation/property-final512.log`, `property-clang512.log` | Xeon GCC and Clang, 20,000 inputs, **64 configurations** (portable/XMM/YMM/ZMM × k=1/2/4/8 × eager/lazy × schoolbook/Karatsuba), checksum `11b7726e88284e6d` |
| `evidence/validation/property-aarch64-fixed512.log`, `property-aarch64-sha3512.log` | AArch64 under QEMU on the Xeon, 32 configurations, with and without SHA3 `EOR3`, same checksum |
| `evidence/validation/m2-check512.log`, `m2-check512-final.log` | Native M2 suite before and after the NEON selection, 32 configurations, same checksum |
| `evidence/validation/vectors512.csv`, `m2-vectors512.csv` | Nine known-answer vectors from the independent oracle, byte-identical on x86 and M2; archived as [test/v3-128/vectors.csv](../../test/v3-128/vectors.csv) |
| `evidence/validation/arithmetic.log`, `schedule.log`, `edges512.log`, `edges-aarch64.log`, `guard-aarch64.log` | 10,000 raw products; 5,140 exact-count schedules; zero/one/all-ones/high-bit keys; protected-page tails |
| `evidence/validation/sanitize-final.log`, `guard-sanitize.log` | ASan/UBSan property (1,000 inputs, 64 configurations) and guard runs |
| `evidence/validation/cpp-build.log`, `portable-build.log`, `compact-code.log` | C++11 inclusion, hardware-free C99 build, byte-identical ARM object checks |
| `evidence/M2-default/chainhash128-v3.sanity.txt`, `evidence/Xeon-final/sanity-final.txt`, `evidence/M2/*.sanity.txt` | SMHasher3 Sanity, zeroes and thread-safety, verification `0x1FCA728C` |
| `evidence/M2/gate.jsonl`, `evidence/M2-default/gate.jsonl`, `evidence/Xeon*/gate.jsonl` | Launch gates: load and process checks before every timed run |

The 256-byte comparison family's records (`*256*`, checksum
`d89b27f10573768d`) are retained alongside. The fresh checks made when
integrating into this repository, on the Mac and on the Xeon, are in
[INTEGRATION.md](INTEGRATION.md).

## Directory map

- [evidence/Xeon](evidence/Xeon/): explicit-registration Speed passes (two
  per hash) and gate log; [evidence/Xeon-final](evidence/Xeon-final/): the
  public-default pass and Sanity; [evidence/Xeon-design](evidence/Xeon-design/)
  and `xeon-design-summary.json`: the earlier design-comparison passes.
- [evidence/M2](evidence/M2/): all registrations, three gated passes each,
  Sanity records; [evidence/M2-default](evidence/M2-default/): the rebuilt
  public default; `M2-pilot`, `M2-asm-pilot`, `M2-fixed-pilot`: superseded
  compiler-scheduled and pilot NEON timings, retained rather than deleted.
- [evidence/validation](evidence/validation/): the logs and CSVs above.
- `evidence/rdtsc-*.csv`, `rdtsc-controls-final.csv`, `ports-final.csv`:
  standalone Xeon RDTSC harness output (alignment, 1..256-byte and generic
  k/lazy evaluations; controls; CLMUL/shuffle port probe).
- `evidence/*-provenance.json`: compiler, flags, reused SMHasher3 object
  hashes, registration source hashes, header and binary SHA-256 per build.
- [bench/](bench/README.md): RDTSC harnesses, SMHasher3 registration
  sources (`registration.inc`, `chainhash128_v3*.cpp`, controls), build and
  run scripts, and `package_results.py`, which assembled the JSON. They are
  archived evidence, not a runnable distribution: the control programs
  include the previous 128-bit and 64-bit headers by their lane paths, and
  the SMHasher3 scripts need a separately configured checkout.
- [audit/](audit/): NEON hot-loop disassembly of the 512-byte family
  (Karatsuba and schoolbook, plus the superseded pilots) and the
  instruction-count JSON behind the report's instruction tables.
- [chainhash128_strided.h](chainhash128_strided.h): **archived measured
  control**, the previous strided ChainHash-128 (512-byte blocks, S=1,
  verification `0x742DE5A5`), SHA-256
  `329f3181135ffba9816577bc5292f03bfbc6b7bfc6f9be041e0ac3cedd9f5481`. It
  was never a public header of this repository; it is kept here so that the
  `chainhash-128` control rows can be reproduced. Its digests differ from
  ChainHash-128 v3.

Host and path placeholders: the x86 host is `<xeon-host>` (Intel Xeon
Platinum 8375C, GCC 11.5, `taskset` pinning as recorded per run) and every
working directory was a scratch checkout, `<scratch>`. Raw logs retain
their original whitespace so recorded SHA-256 values remain verifiable.
