# Timing and evidence

`rdtsc.c` evaluates both multiplication methods and all three x86 widths.
Build with `cc -O3 -std=c99` and explicitly set
`CHAINHASH128_V3_BLOCK_BYTES=256` or `512`. Run with `taskset -c 16-23`.
The fixed 262144-byte test uses eight alignments, three samples per alignment,
512 calls per sample after warmup, and the median sample. The result is the
arithmetic mean of eight alignment throughputs. Supplying any argument also
measures lengths 1..256 with three 2048-call samples and the generic
k=1/2/4/8 × eager/lazy evaluations. Call overhead remains included.
`rdtsc_controls.c` uses the same protocol for the supplied 64-bit v3 and
previous ChainHash-128 headers; compile it with `-march=native` to enable
the previous header's compile-time dispatch. `ports.c` measures independent
wide CLMULs, lane shuffles, and their mixture. Its units are TSC ticks.

`build.py SOURCE BASE_BUILD OUTPUT` adds scratch registrations to a new
SMHasher3 executable, reusing the baseline timer, main object, and control
libraries unchanged. SOURCE is the matching SMHasher3 source checkout;
BASE_BUILD contains its generated include directory and object libraries.
The script records compiler flags and input/output hashes without recording
machine-specific directories. The benchmark seed adapter expands a 64-bit
seed and is outside the independent-key probability theorems.

The explicit candidate registrations identify their block size and bulk
multiplication method. `chainhash128-v3` calls the public selected default.
`.256` and `.school` force 256-byte blocks;
`.512` and `.512school` force 512-byte blocks. This makes both families
measurable even if the public header's selected default changes. The common
short-input path uses Karatsuba for all registrations. The 64-bit v3 and
previous 128-bit controls are separate translation units.

`run_speed.py BINARY OUTPUT --names ...` runs the unmodified
`SMHasher3 NAME --test=Speed` protocol. Xeon uses CPUs 16–23 and two passes.
Select the higher fixed-262144-byte bulk average and the lower 1..31-byte
small-key average independently. M2 uses three passes and independent
medians for those summaries. Every M2 launch waits for no exact-name
SMHasher3 process and one-minute load below 4.5. The gate has no timeout or
bypass; waiting, launch state, completion state, hashes, and raw output are
retained. It controls launch conditions and cannot prevent another job
starting later. All completed final repetitions are retained, with summary
deviations exceeding 15% flagged rather than deleted.

Each Speed run includes a second bulk section with random lengths near
262144. It remains in the raw files but does not replace the post's fixed
262144-byte chart metric. The small metric is the arithmetic mean of the
31 separately measured byte lengths. Raw files also retain alignment and
per-length values. `summarize.py` parses the designated sections and records
every repetition. Exploratory pilot runs are separate from final results.

Xeon “cycles” are invariant-TSC reference ticks. M2 “cycles” are SMHasher3's
calibrated estimates from its monotonic timer. Neither is a measurement of
instantaneous core cycles. The printed GiB/s conversion assumes 3.5 GHz;
it is not measured memory bandwidth. Key expansion is excluded from timing.

Retained raw results: `evidence/Xeon/` (explicit registrations, two passes),
`evidence/Xeon-final/` (public default, one completed pass), `evidence/M2/`
(all registrations, three passes; its public-default runs predate the NEON
selection and are superseded), `evidence/M2-default/` (public default from the
final header, three passes). `package_results.py` assembles
`speeds_chainhash128_v3.json` from these folders and their provenance files.
