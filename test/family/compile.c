/* Every ChainHash header in one translation unit (C and C++): no name clashes, and each width hashes
 * the same message identically through the one-shot, streaming and reference entry points. */
#include <stdio.h>
#include "chainhash.h"
#include "chainhash128.h"
#include "chainhash128v2.h"
#include "chainhash256.h"
#include "chainhash512.h"
#include "chainhash192.h"
static chainhash128v2_key k128;
static chainhash128v2_stream s128;
static chainhash256_key k256;
static chainhash256_stream s256;
static chainhash512_key k512;
static chainhash512_stream s512;
static chainhash192_key k192;
static chainhash192_stream s192;
int main(void) {
    static uint8_t msg[70000]; uint8_t a[64], b[64], c[64]; size_t i; int bad = 0;
    for (i = 0; i < sizeof msg; i++) msg[i] = (uint8_t)(i * 131 + 7);
    chainhash128v2_key_from_seed(&k128, 1);
    chainhash256_key_from_seed(&k256, 1);
    chainhash512_key_from_seed(&k512, 1);
    chainhash192_key_from_seed(&k192, 1);
    chainhash128v2_init(&s128, &k128, chainhash128v2_backend());
    chainhash128v2_update(&s128, msg, 1000); chainhash128v2_update(&s128, msg + 1000, sizeof msg - 1000);
    bad += !ch128_equal(chainhash128v2(&k128, msg, sizeof msg), chainhash128v2_final(&s128));
    bad += !ch128_equal(chainhash128v2(&k128, msg, sizeof msg), chainhash128v2_reference(&k128, msg, sizeof msg));
    chainhash256(&k256, msg, sizeof msg, a); chainhash256_reference(&k256, msg, sizeof msg, b);
    chainhash256_init(&s256, &k256); chainhash256_update(&s256, msg, 1000); chainhash256_update(&s256, msg + 1000, sizeof msg - 1000); chainhash256_final(&s256, c);
    bad += memcmp(a, b, 32) != 0; bad += memcmp(a, c, 32) != 0;
    chainhash512(&k512, msg, sizeof msg, a); chainhash512_reference(&k512, msg, sizeof msg, b);
    chainhash512_init(&s512, &k512); chainhash512_update(&s512, msg, 1000); chainhash512_update(&s512, msg + 1000, sizeof msg - 1000); chainhash512_final(&s512, c);
    bad += memcmp(a, b, 64) != 0; bad += memcmp(a, c, 64) != 0;
    chainhash192(&k192, msg, sizeof msg, a); chainhash192_reference(&k192, msg, sizeof msg, b);
    chainhash192_init(&s192, &k192); chainhash192_update(&s192, msg, 1000); chainhash192_update(&s192, msg + 1000, sizeof msg - 1000); chainhash192_final(&s192, c);
    bad += memcmp(a, b, 24) != 0; bad += memcmp(a, c, 24) != 0;
    printf("%s: all six headers in one translation unit; backends 128v2=%d 256=%d 512=%d 192=%d\n", bad ? "FAIL" : "PASS",
           chainhash128v2_backend(), chainhash256_backend(), chainhash512_backend(), chainhash192_backend());
    return bad != 0;
}
