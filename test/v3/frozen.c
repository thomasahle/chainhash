#include "chainhash3.h"
#include <stdio.h>

int main(void) {
    static const size_t lengths[] = {0, 1, 17, 64, 256, 1024, 2048};
    static const uint64_t digests[] = {
        UINT64_C(0xede120e3ad6ec193), UINT64_C(0x452b0eaf71d3c5ed),
        UINT64_C(0x97c346f5999acee9), UINT64_C(0x5c8ad2d9c3070f33),
        UINT64_C(0x7447331b371f34d9), UINT64_C(0xf3897c02083c9f82),
        UINT64_C(0xa309e28472bb24cb)
    };
    uint8_t message[2048];
    chainhash_v3_key key = chainhash_v3_key_from_seed(123);
    size_t i, n;
    int b, lazy;
    unsigned stride;
    for (i = 0; i < sizeof(message); ++i) message[i] = (uint8_t)i;
    for (i = 0; i < sizeof(lengths) / sizeof(lengths[0]); ++i) {
        n = lengths[i];
        if (chainhash_v3_portable(&key, message, n) != digests[i]) return 1;
        for (b = 0; b <= 4; ++b) if (chainhash_v3_has_backend(b)) {
            if (chainhash_v3_with_backend(&key, message, n, b) != digests[i]) return 2;
            for (stride = 1; stride <= 8; ++stride) for (lazy = 0; lazy <= 1; ++lazy) {
                chainhash_v3_stream stream;
                size_t pos = 0;
                chainhash_v3_init(&stream, &key, stride, lazy, b);
                while (pos < n) {
                    size_t take = n - pos < 17 ? n - pos : 17;
                    chainhash_v3_update(&stream, message + pos, take);
                    chainhash_v3_update(&stream, NULL, 0);
                    pos += take;
                }
                if (chainhash_v3_final(&stream) != digests[i]) return 3;
            }
        }
    }
    puts("PASS seven frozen vectors, every backend, strides 1..8, eager/lazy streaming");
    return 0;
}
