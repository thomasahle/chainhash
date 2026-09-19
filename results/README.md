# Measurements and evidence

- [64/](64/README.md): ChainHash. SMHasher3 Speed runs on an Intel Xeon
  Platinum 8375C and an Apple M2 Pro, a standalone RDTSC harness, the
  object-code audit of the hot loops, and the correctness, sanitizer and
  build logs from both hosts.
- [128/](128/README.md): ChainHash-128. The same protocol on both hosts,
  the schoolbook-versus-Karatsuba comparison behind the product-method
  dispatch,
  NEON disassembly, and the validation logs.

Each directory's `speeds.json` aggregates every retained SMHasher3 run
(raw file, SHA-256, launch load, both bulk sections, per-length small-key
costs, deviations) with the selection rule in `meta`. Raw logs keep their
original content and whitespace so the recorded hashes stay verifiable.
Units: Xeon "cycles" are invariant-TSC reference ticks and M2 "cycles" are
SMHasher3's calibrated estimates from its monotonic timer; neither is a
core-cycle measurement, cross-host ratios are not meaningful, and printed
GiB/s assume 3.5 GHz. Key expansion is outside every timed region. Host
placeholders: `<xeon>` is the Xeon host and `<scratch>` a scratch checkout.
