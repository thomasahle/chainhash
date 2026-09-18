# Assembly records, 2026-09-18

- `mac-test.txt`, `xeon-test.txt`: PMULL/PCLMUL and forced-portable tests,
  including unchanged paper reference, frozen vectors, guard pages, C99 API.
- `*-original*.txt`: byte-for-byte comparisons against unmodified original
  SMHasher3 source; the Mac hardware run also checks the original benchmark.
- `*-speed.txt`: fresh measurements of this standalone header. Mac numbers
  use estimated cycles; Xeon numbers use invariant TSC reference cycles.
- `verify5.txt`: symbolic coefficient/decoder identities, random round trips,
  and small-field sanity checks from the copied original script. These do
  not complete the Lean proof.
- Sanitizer logs and the Mac startup sample document both failed runtime
  attempts and successful runs; see `../REPORT.md` for the final status.

The SMHasher3 historical 200/200 verdict is recorded separately in
`../docs/smhasher-record.json`; it was not obtained by rerunning that suite.
