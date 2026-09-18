#include "chainhash.h"
#include <assert.h>
int main(void) {
    uint64_t w[41]={0},c[5]={0};
    uint8_t b[80]={0};
    const char message[]="C99 API";
    chainhash_key keys[6];unsigned i;
    keys[0]=chainhash_key_from_words(w);
    keys[1]=chainhash_key_from_80_bytes(b);
    keys[2]=chainhash_key_from_seed2(0,0,c);
    keys[3]=chainhash_key_from_seed(0,c);
    keys[4]=chainhash_key_from_single_word_reference(0);
    keys[5]=chainhash_key_from_bytes(b);
    for(i=0;i<6;++i)
        assert(chainhash(&keys[i],message,sizeof(message))==
               chainhash_portable(&keys[i],message,sizeof(message)));
    return 0;
}
