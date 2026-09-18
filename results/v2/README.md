# v2 comparison provenance

v2 means the adjacent-pair **1024-byte, S=1** function using the original
three-key recurrence and finalizer. It is distinct from the strided S=2
1 KiB control and the paper's strided 256-byte v1. Its ideal key has 137
independent words (1096 bytes); the written certificate is
`(ceil(L/128)+2)/2^64`, giving fixed/at-most scores `64-log2(3)`.
No model-A score for v2 is established by this integration.

- [Xeon report snapshot](XEON_REPORT.txt): 24.77 and 24.86 B/TSC in two
  SMHasher3 Speed passes; selected 24.86. Adjacent 1 KiB ZMM implementation.
- [M2 report snapshot](M2_REPORT.txt): EXT K1, adjacent 1 KiB, 17.56, 17.45,
  17.43 B/calibrated cycle; median **17.45**. Same function, ARM evaluator.
- [M2 measurement archive](speeds_m2_adjacent_ext.json): run metadata,
  correctness records, load gates, all controls and all alternative kernels.

These reports came from the adjacent x86 and M2 EXT implementation work.
They are retained historical text, not new measurements. References inside
the report snapshots describe their original work directories; those entire
work directories are not part of this v3 integration. In particular, do not
substitute the strided 1 KiB M2 result (18.85 in that run) for adjacent v2.
