/* Executable check of SPEC_v3's exact-count schedule, including lookahead. */
#define main property_main
#include "property.c"
#undef main

int main(void) {
    uint64_t rng = 42, a[258], powers[17], lanes[16];
    unsigned trial, p, k, i, j;
    for (trial = 0; trial < 6; ++trial) {
        uint64_t y = trial < 2 ? trial : rnd(&rng);
        powers[0] = 1;
        for (i = 1; i <= 16; ++i) powers[i] = imul(powers[i - 1], y);
        for (p = 1; p <= 257; ++p) {
            uint64_t serial;
            for (i = 0; i <= p; ++i) a[i] = rnd(&rng);
            serial = a[0];
            for (i = 1; i <= p; ++i) serial = imul(serial, y) ^ a[i];
            for (k = 1; k <= 16; ++k) {
                unsigned active = k < p + 1 ? k : p + 1, count = 0;
                uint64_t got = 0;
                for (j = 0; j < active; ++j) {
                    lanes[j] = a[j];
                    /* Look ahead before multiplying: never advance an exhausted lane. */
                    for (i = j; i + k <= p; i += k) {
                        lanes[j] = imul(lanes[j], powers[k]) ^ a[i + k];
                        ++count;
                    }
                    i = (p - j) % k;
                    if (i) { got ^= imul(lanes[j], powers[i]); ++count; }
                    else got ^= lanes[j];
                }
                if (got != serial || count != p) {
                    fprintf(stderr, "FAIL schedule p=%u k=%u count=%u\n", p, k, count);
                    return 1;
                }
            }
        }
    }
    puts("PASS exact p multiplications with lookahead, k=1..16, p=1..257, y=0/1/random");
    return 0;
}
