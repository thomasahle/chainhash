Title: Register ChainHash and ChainHash-128

Add two keyed noncryptographic hashes with a proved collision bound, using
the published MIT-licensed headers with their portable implementations and
accelerated backends: chainhash (64-bit digest, 256-byte blocks over
GF(2^64)) and chainhash-128 (128-bit digest, 512-byte blocks over
GF(2^128)). Each compresses blocks with carry-less multiplications, chains
the block digests with Horner's rule in an independent key, and finishes
with an integer twist and a quintic finalizer.

The registration includes the seed callbacks, self-test init functions,
verification values, Hashsrc.cmake entry, license and attribution. The
accompanying README specifies the SplitMix64 seed expansion and separates it
from the theorem's random-key assumption. Input bytes are canonical
little-endian, with separate digest serialization for the suite's LE/BE
paths of the 64-bit hash; the 128-bit digest is endian independent.

Validation: both registrations pass --test=Sanity with the stated
verification values; the full --test=All results for chainhash (200/200 on
x86-64 and on arm64) are recorded in the ChainHash repository under
results/64/suite/ (https://github.com/thomasahle/chainhash/tree/main/results/64/suite). The arm64 CMake classifier patch is independently
reviewable and unnecessary on newer bases which already contain the fix. The
pinned source's random counter type prerequisite belongs in a separate
Testlib submission.
