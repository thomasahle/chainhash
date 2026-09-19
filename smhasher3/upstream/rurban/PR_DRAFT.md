Title: Register ChainHash and ChainHash-128

Add two keyed noncryptographic hashes with a proved collision bound, using
the published MIT-licensed headers with their portable implementations and
accelerated backends: chainhash (64-bit digest, 256-byte blocks over
GF(2^64)) and chainhash-128 (128-bit digest, 512-byte blocks over
GF(2^128)). The patch adds the sources, CMake entry, verification values and
registry rows. The classic 32-bit seed is zero-extended into the same
documented SplitMix64 expansion as the SMHasher3 registration. Thread-local
caching preserves seed changes while avoiding repeated setup for fixed-seed
speed tests.

The source README documents the seed expansion, the portable and hardware
paths, and the distinction between empirical seeded-adapter tests and the
theorem's random-key model.

Validation: both registrations pass --test=Sanity with the stated
verification values; the full `All,BIC` Xeon results for chainhash are
recorded in the ChainHash repository under results/64/suite/
(https://github.com/thomasahle/chainhash/tree/main/results/64/suite).
