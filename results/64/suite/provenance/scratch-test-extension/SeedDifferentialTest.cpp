/*
 * SMHasher3
 * Copyright (C) 2026  Thomas Dybdahl Ahle
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see
 * <https://www.gnu.org/licenses/>.
 */
#include "Platform.h"
#include "Hashinfo.h"
#include "TestGlobals.h"
#include "Random.h"
#include "Instantiate.h"
#include "VCode.h"

#include "SeedDifferentialTest.h"

#include <math.h>
#include <algorithm>

//-----------------------------------------------------------------------------
// Seed differential tests
//
// The threat model is a hidden, uniformly random seed and an attacker who
// picks the messages. For a fixed message pair (m, m') the figure of merit
// is Pr_seed[ hash(m) == hash(m') ]; an ideal hash gives 2^-hashbits.
//
// The message pairs come from the differential analysis of the 64x64->128
// multiply-fold used by wyhash, rapidhash, XXH3 and MUM: complementing one
// or both 64-bit words that feed a fold gives a collision with probability
// ~2^-27 for XOR-folds (2^37 times the ideal), and MUM's add-fold has a
// key-free two-word differential (probability 1 for every seed).
//
// For each key length a random base message m is built with w1 == ~w0
// (the second 64-bit word is the complement of the first; this is the
// configuration that maximizes the first-fold bias). The differentials
// applied to get m' are:
//
//   ~w0~w1   complement words 0 and 1        (the first-fold pair)
//   ~w0      complement word 0 only
//   ~w1      complement word 1 only
//   ~wi~wi+1 complement an adjacent pair of interior words, i = 1..3
//   ~wi      complement an interior word alone, i = 2..3 (i = 1 is ~w1)
//
// For every (length, differential) N uniformly random seeds are drawn and
// the seeds with hash(m) == hash(m') on the full output are counted. The
// expected count is E = N * 2^-hashbits; a row fails when its count exceeds
// max(3, E + 6*sqrt(E)), i.e. "more than 3 collisions" for 64-bit hashes.
//
// Default tier: N = 2^24 seeds per pair at every length, which detects rates
// >= ~2^-21 (MUM's key-free rate 1 and its single-word rate 1/2). Extended
// tier (--extra): N = 2^30 on the first-fold pairs at 32, 64, 128 and 240
// bytes and the adjacent interior pairs at 32 bytes, which detects the
// ~2^-27 rates of wyhash, rapidhash and XXH3.
//
// The seeds are shared across the differentials of one (length, tier): for
// each seed hash(m) is computed once and compared against hash(m') for every
// differential. Each pair still sees N fresh uniform seeds, so the per-row
// statistics are unchanged, and this saves ~half of the hash calls.

struct Differential {
    const char * name;
    unsigned     nwords;
    unsigned     word[2];
};

static const Differential alldiffs[] = {
    { "~w0~w1", 2, { 0, 1 } },
    { "~w0",    1, { 0, 0 } },
    { "~w1",    1, { 1, 0 } },
    { "~w1~w2", 2, { 1, 2 } },
    { "~w2~w3", 2, { 2, 3 } },
    { "~w3~w4", 2, { 3, 4 } },
    { "~w2",    1, { 2, 0 } },
    { "~w3",    1, { 3, 0 } },
};
static constexpr unsigned numalldiffs = sizeof(alldiffs) / sizeof(alldiffs[0]);

// Indices into alldiffs[] for the extended tier
static const unsigned extradiffs_32[]    = { 0, 1, 3, 4, 5 };
static const unsigned extradiffs_other[] = { 0, 1 };

static const unsigned testlens[]  = { 16, 24, 32, 48, 64, 100, 128, 160, 200, 240, 256, 1024 };
static const unsigned extralens[] = { 32, 64, 128, 240 };

//-----------------------------------------------------------------------------
// Count, for seeds [0, nseeds) of this thread's own RNG stream, how many
// seeds make hash(base) equal hash(alts[d]) for each differential d.

template <typename hashtype>
static void SeedDifferentialThread( const HashInfo * hinfo, const uint8_t * base, const uint8_t * alts,
        const unsigned keybytes, const unsigned ndiffs, const uint64_t nseeds, const unsigned log2n,
        const unsigned tid, const bool smallseed, uint64_t * counts ) {
    const HashFn hash = hinfo->hashFn(g_hashEndian);
    // A distinct stream per (key length, tier, thread)
    Rand r( 261307, keybytes, log2n, tid );

    hashtype A( 0 ), B( 0 );

    for (uint64_t n = 0; n < nseeds; n++) {
        seed_t iseed = (seed_t)r.rand_u64();
        if (smallseed) {
            iseed &= UINT64_C(0xffffffff);
        }
        iseed = hinfo->getFixedSeed(iseed);
        const seed_t hseed = hinfo->Seed(iseed, HashInfo::SEED_FORCED, 1);

        hash(base, keybytes, hseed, &A);
        for (unsigned d = 0; d < ndiffs; d++) {
            hash(&alts[d * keybytes], keybytes, hseed, &B);
            if (A == B) {
                counts[d]++;
            }
        }
    }
}

//-----------------------------------------------------------------------------

static void PrintTableHeader( void ) {
    printf("   len  differential   collisions / seeds     log2 rate\n");
}

template <typename hashtype>
static bool SeedDifferentialImpl( const HashInfo * hinfo, const unsigned keybytes, const unsigned log2n,
        const unsigned * diffidxs, const unsigned ndiffs, const bool extratier, flags_t flags ) {
    const uint64_t nseeds    = UINT64_C(1) << log2n;
    const bool     smallseed = hinfo->is32BitSeed();

    // Base message: random bytes, with word 1 the complement of word 0
    Rand r( 174229, keybytes );
    std::vector<uint8_t> base( keybytes );
    r.rand_n(&base[0], keybytes);
    for (unsigned b = 0; b < 8; b++) {
        base[8 + b] = ~base[b];
    }

    // One modified message per differential
    std::vector<uint8_t> alts( ndiffs * keybytes );
    for (unsigned d = 0; d < ndiffs; d++) {
        const Differential & diff = alldiffs[diffidxs[d]];
        uint8_t * alt = &alts[d * keybytes];
        memcpy(alt, &base[0], keybytes);
        for (unsigned w = 0; w < diff.nwords; w++) {
            for (unsigned b = 0; b < 8; b++) {
                alt[diff.word[w] * 8 + b] ^= 0xff;
            }
        }
    }

    // Since this is threaded, only the test parameters go into the VCode
    addVCodeInput(&base[0], keybytes);
    addVCodeInput(&alts[0], ndiffs * keybytes);
    addVCodeInput(nseeds);

    if (REPORT(VERBOSE, flags)) {
        printf("Testing %4d-byte keys, 2^%d seeds x %d differentials, %d thread%s\n",
                keybytes, log2n, ndiffs, g_NCPU, (g_NCPU == 1) ? "" : "s");
    }

    //----------

    std::vector<uint64_t> counts( g_NCPU * ndiffs, 0 );

    if (g_NCPU == 1) {
        SeedDifferentialThread<hashtype>(hinfo, &base[0], &alts[0], keybytes, ndiffs,
                nseeds, log2n, 0, smallseed, &counts[0]);
    } else {
#if defined(HAVE_THREADS)
        std::vector<std::thread> t( g_NCPU );
        const uint64_t per = nseeds / g_NCPU;
        for (unsigned i = 0; i < g_NCPU; i++) {
            const uint64_t cnt = (i < (g_NCPU - 1)) ? per : nseeds - per * (g_NCPU - 1);
            t[i] = std::thread {
                SeedDifferentialThread<hashtype>, hinfo, &base[0], &alts[0], keybytes, ndiffs,
                cnt, log2n, i, smallseed, &counts[i * ndiffs]
            };
        }
        for (unsigned i = 0; i < g_NCPU; i++) {
            t[i].join();
        }
        for (unsigned i = 1; i < g_NCPU; i++) {
            for (unsigned d = 0; d < ndiffs; d++) {
                counts[d] += counts[i * ndiffs + d];
            }
        }
#endif
    }

    //----------

    const double expected = (double)nseeds * exp2(-(double)hashtype::bitlen);
    const double limit    = std::max(3.0, expected + 6.0 * sqrt(expected));
    bool         result   = true;

    for (unsigned d = 0; d < ndiffs; d++) {
        const uint64_t count = counts[d];
        const bool     ok    = ((double)count <= limit);

        printf("  %4d  %-9s %14" PRIu64 " / 2^%-2d   ", keybytes, alldiffs[diffidxs[d]].name, count, log2n);
        if (count > 0) {
            printf("  %7.1f", log2((double)count / (double)nseeds));
        } else {
            printf("  <%6.1f", -(double)log2n);
        }
        printf("%s\n", ok ? "" : "   !!!!!");

        result &= ok;
    }

    addVCodeResult(result);

    char testname[32];
    snprintf(testname, sizeof(testname), "%u%s", keybytes, extratier ? " (extra)" : "");
    recordTestResult(result, "SeedDifferential", testname);

    return result;
}

//-----------------------------------------------------------------------------

template <typename hashtype>
bool SeedDifferentialTest( const HashInfo * hinfo, bool extra, flags_t flags ) {
    bool result = true;

    printf("[[[ Seed Differential Tests ]]]\n\n");

    // Slow hashes get fewer seeds; the rates this tier targets are large
    const unsigned log2n = hinfo->isVerySlow() ? 16 : hinfo->isSlow() ? 20 : 24;

    printf("Fixed message pairs (m, m'), uniformly random seeds; counting seeds with hash(m) == hash(m').\n"
           "Base message has w1 == ~w0; ~wi means 64-bit word i of m is complemented in m'.\n"
           "Ideal rate is 2^-%d per seed; a row fails above max(3, E + 6*sqrt(E)), E = seeds * 2^-%d.\n\n",
            (int)hashtype::bitlen, (int)hashtype::bitlen);

    printf("Default tier: 2^%d seeds per pair\n", log2n);
    PrintTableHeader();
    for (unsigned keybytes: testlens) {
        const unsigned words = keybytes / 8;
        unsigned diffidxs[numalldiffs];
        unsigned ndiffs = 0;
        for (unsigned i = 0; i < numalldiffs; i++) {
            const Differential & diff = alldiffs[i];
            if (diff.word[diff.nwords - 1] < words) {
                diffidxs[ndiffs++] = i;
            }
        }
        result &= SeedDifferentialImpl<hashtype>(hinfo, keybytes, log2n, diffidxs, ndiffs, false, flags);
    }
    printf("\n");

    if (extra && !hinfo->isSlow()) {
        printf("Extended tier: 2^30 seeds per pair on the first-fold pairs and the 32-byte interior pairs\n");
        PrintTableHeader();
        for (unsigned keybytes: extralens) {
            const unsigned   words    = keybytes / 8;
            const unsigned * cand     = (keybytes == 32) ? extradiffs_32 : extradiffs_other;
            const unsigned   ncand    = (keybytes == 32) ?
                    sizeof(extradiffs_32) / sizeof(extradiffs_32[0]) :
                    sizeof(extradiffs_other) / sizeof(extradiffs_other[0]);
            unsigned diffidxs[numalldiffs];
            unsigned ndiffs = 0;
            for (unsigned i = 0; i < ncand; i++) {
                const Differential & diff = alldiffs[cand[i]];
                if (diff.word[diff.nwords - 1] < words) {
                    diffidxs[ndiffs++] = cand[i];
                }
            }
            result &= SeedDifferentialImpl<hashtype>(hinfo, keybytes, 30, diffidxs, ndiffs, true, flags);
        }
        printf("\n");
    }

    printf("%s\n", result ? "PASS" : g_failstr);

    return result;
}

INSTANTIATE(SeedDifferentialTest, HASHTYPELIST);
