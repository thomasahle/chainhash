/* The nine archived known-answer vectors (vectors.csv), checked through every
 * public API: reference, dispatch, each available backend with both product
 * methods, and strides 1..8 with eager/lazy streaming in 17-byte chunks. */
#include "chainhash128.h"
#include <stdio.h>
#ifdef NDEBUG
#error "Tests must be compiled with assertions enabled"
#endif
int main(void) {
    static const size_t lengths[9] = {0, 1, 17, 128, 129, 2048, 2049, 4096, 4097};
    static const uint64_t hi[9] = {
        UINT64_C(0xcb2a7994d9c3a248), UINT64_C(0x2c37ccfdfc17e0a1), UINT64_C(0xfd15779069b8d199),
        UINT64_C(0xcc089eb688f50415), UINT64_C(0x59bcf8a135a4bc27), UINT64_C(0x39342423b450aa51),
        UINT64_C(0x756d75e371f7f634), UINT64_C(0x784695c32aea8d46), UINT64_C(0x2d5fefb92a353b42)};
    static const uint64_t lo[9] = {
        UINT64_C(0x66be5c470e2ee79f), UINT64_C(0x9c82c1f4e3d90cd2), UINT64_C(0x2b2f07c62c4ea752),
        UINT64_C(0x53dbcb208bb1c888), UINT64_C(0xfda35bd4ad61bee7), UINT64_C(0xd1a737bc96f68060),
        UINT64_C(0xa298054ce47e3d7d), UINT64_C(0x0f995c1d19e27e91), UINT64_C(0xbc3d15f99b5223c8)};
    uint8_t m[4097]; unsigned i, stride; int b, lazy, school; size_t n, pos;
    chainhash128_key key = chainhash128_key_from_seed(123);
#if CHAINHASH128_BLOCK_BYTES != 512
#error "vectors.csv is the 512-byte family"
#endif
    for (i = 0; i < sizeof m; i++) m[i] = (uint8_t)(i * 137 + 29);
    for (i = 0; i < 9; i++) {
        ch128_word want = ch128_make(lo[i], hi[i]);
        n = lengths[i];
        assert(ch128_equal(chainhash128_portable(&key, m, n), want));
        assert(ch128_equal(chainhash128(&key, m, n), want));
        for (b = 0; b <= 4; b++) if (chainhash128_has_backend(b)) for (school = 0; school < 2; school++) {
            assert(ch128_equal(chainhash128_with_backend(&key, m, n, b, school), want));
            for (stride = 1; stride <= 8; stride++) for (lazy = 0; lazy < 2; lazy++) {
                chainhash128_stream s;
                chainhash128_init(&s, &key, stride, lazy, b, school);
                for (pos = 0; pos < n; pos += 17) {
                    chainhash128_update(&s, m + pos, n - pos < 17 ? n - pos : 17);
                    chainhash128_update(&s, NULL, 0);
                }
                assert(ch128_equal(chainhash128_final(&s), want));
            }
        }
    }
    puts("PASS nine frozen vectors: reference, dispatch, every backend x product, strides 1..8 eager/lazy");
    return 0;
}
