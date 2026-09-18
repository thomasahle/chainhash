#include "chainhash.h"
#include <assert.h>
int main(void) {
    uint64_t w[41]={0},c[5]={0};
    uint8_t b[CHAINHASH_RANDOM_BYTES];
    const char message[]="C99 API";
    chainhash_key keys[6];unsigned i;
    assert(CHAINHASH_RANDOM_BYTES==328);
    for(i=0;i<sizeof b;++i) b[i]=(uint8_t)i;
    keys[0]=chainhash_key_from_words(w);
    keys[1]=chainhash_key_from_80_bytes(b);
    keys[2]=chainhash_key_from_seed2(0,0,c);
    keys[3]=chainhash_key_from_seed(0,c);
    keys[4]=chainhash_key_from_single_word_reference(0);
    keys[5]=chainhash_key_from_bytes(b);
    /* Check direct decoding at both ends of the 328-byte input. */
    assert(keys[5].words[0]==UINT64_C(0x0706050403020100));
    assert(keys[5].words[40]==UINT64_C(0x4746454443424140));
    for(i=0;i<6;++i)
        assert(chainhash(&keys[i],message,sizeof(message))==
               chainhash_portable(&keys[i],message,sizeof(message)));
    return 0;
}
