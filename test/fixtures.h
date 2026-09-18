/* Deterministic test data and SMHasher3 vector keys. These helpers belong
 * only to the test harness: they do not generate independent random keys.
 */
#ifndef CHAINHASH_TEST_FIXTURES_H
#define CHAINHASH_TEST_FIXTURES_H
#include "chainhash.h"

static inline uint64_t test_random_word(uint64_t *state) {
    uint64_t z = (*state += UINT64_C(0x9E3779B97F4A7C15));
    z = (z ^ (z >> 30)) * UINT64_C(0xBF58476D1CE4E5B9);
    z = (z ^ (z >> 27)) * UINT64_C(0x94D049BB133111EB);
    return z ^ (z >> 31);
}

/* Recreate the fixed benchmark keys in word order: k, u, y, z, c, tau. */
static inline chainhash_key test_fixture_key(uint64_t seed) {
    uint64_t words[CHAINHASH_KEY_WORDS];
    unsigned i;
    for (i = 0; i < CHAINHASH_KEY_WORDS; ++i) words[i] = test_random_word(&seed);
    return chainhash_key_from_words(words);
}
#endif
