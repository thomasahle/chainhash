/* mkvec.c -- prints the conformance vectors "key n digest" (reference definition, portable backend) */
#include "chainhash192.h"
#include <stdio.h>
int main(void) {
    static const size_t lens[] = {0, 1, 7, 8, 9, 15, 16, 17, 31, 32, 63, 64, 65, 100, 191, 192, 193, 255, 256, 383, 384, 385, 1000, 1024, 3839, 3840, 3841, 4000, 4095, 4096, 4097, 8192, 12289, 16384, 28672, 32767, 32768, 32769, 36864, 65536, 69633, 135000};
    static const char *keys[] = {"0", "1", "42", "R"}; size_t maxn = 135000;
    uint8_t *m = malloc(maxn); for (size_t j = 0; j < maxn; j++) m[j] = (uint8_t)(137 * j + 29);
    uint8_t raw[216]; for (int i = 0; i < 216; i++) raw[i] = (uint8_t)(73 * i + 11);
    static chainhash192_key k;
    for (int ki = 0; ki < 4; ki++) {
        if (keys[ki][0] == 'R') chainhash192_key_from_bytes_with_backend(&k, raw, CH192_PORTABLE); else chainhash192_key_from_seed_with_backend(&k, strtoull(keys[ki], 0, 10), CH192_PORTABLE);
        for (size_t i = 0; i < sizeof lens / sizeof *lens; i++) { uint8_t o[24]; chainhash192_reference(&k, m, lens[i], o);
            printf("%s %zu ", keys[ki], lens[i]); for (int b = 0; b < 24; b++) printf("%02x", o[b]); printf("\n"); } }
    return 0; }
