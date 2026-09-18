#include "chainhash.h"
#include <cassert>
#include <cstdio>
#include <cstring>
#include <vector>

static uint64_t rng_state = UINT64_C(0x534545444544);
static uint64_t random_word() { return ch_splitmix64(&rng_state); }
static void put64(uint8_t *p, uint64_t v) {
    for (unsigned i=0;i<8;++i) p[i]=(uint8_t)(v>>(8*i));
}
static void verify_key(const chainhash_key& k, const uint64_t *expected) {
    assert(std::memcmp(k.words,expected,328)==0);
    auto copy=chainhash_key_from_words(expected);
    uint8_t bytes[328];
    for (unsigned i=0;i<41;++i) put64(bytes+8*i,expected[i]);
    auto decoded=chainhash_key_from_328_bytes(bytes);
    assert(std::memcmp(&copy,&decoded,328)==0);
}
int main(int argc,char**) {
    assert(sizeof(chainhash_key)==328);
    assert(chainhash_schedule_mul(UINT64_C(1)<<63,2)==27);
    for (unsigned i=0;i<10000;++i) {
        uint64_t a=random_word(),b=random_word();
        assert(chainhash_schedule_mul(a,b)==ch_mul(a,b));
    }
    std::vector<uint8_t> message(1024*1024+16);
    for (size_t i=0;i<message.size();++i) message[i]=(uint8_t)(37*i+11);
    const size_t lengths[]={0,1,7,8,9,15,16,17,23,24,25,31,32,33,63,64,65,
        127,128,129,255,256,257,511,512,513,1023,1024,1025,4096,1024*1024};
    const uint64_t seeds[]={0,1,2,UINT64_C(0x8000000000000000),
        UINT64_C(0x0123456789abcdef),UINT64_C(0xffffffffffffffff)};
    unsigned hash_checks=0;
    for (uint64_t s:seeds) {
        uint64_t words[41],c[5],t=UINT64_C(0xfedcba9876543210);
        for (unsigned i=0;i<5;++i) c[i]=UINT64_C(0x1122334455667788)*(i+1);
        uint64_t power=s;
        for (unsigned i=0;i<32;++i) {words[i]=power;power=ch_mul(power,s);}
        uint8_t bytes[81]; // Deliberately unaligned input.
        put64(bytes+1,s);
        for (unsigned i=1;i<10;++i) put64(bytes+1+8*i,UINT64_C(0x123456789abcdef)*i);
        auto a=chainhash_key_from_80_bytes(bytes+1);
        for (unsigned i=0;i<9;++i) words[32+i]=ch_load64(bytes+1+8*(i+1));
        verify_key(a,words);
        auto recommended=chainhash_key_from_bytes(bytes+1);
        assert(std::memcmp(&a,&recommended,sizeof a)==0);
        auto b=chainhash_key_from_seed2(s,t,c);
        words[32]=ch_mul(t,t);words[33]=ch_mul(words[32],t);words[34]=t;
        for (unsigned i=0;i<5;++i) words[35+i]=c[i];
        words[40]=words[3];verify_key(b,words);
        auto cc=chainhash_key_from_seed(s,c);
        words[32]=words[1];words[33]=words[2];words[34]=s;verify_key(cc,words);
        auto d=chainhash_key_from_single_word_reference(s);
        for (unsigned i=0;i<5;++i) {words[35+i]=power;power=ch_mul(power,s);}
        words[40]=power;verify_key(d,words);
        for (auto key:{a,b,cc,d}) for (size_t len:lengths) {
            auto h=chainhash(&key,message.data()+1,len);
            assert(h==chainhash_portable(&key,message.data()+1,len));
            ++hash_checks;
        }
        if (argc>1) {
            std::printf("s=%016llx\n",(unsigned long long)s);
            const char *names[]={"A","B","C","D"}; unsigned j=0;
            for(auto key:{a,b,cc,d}) {
                std::printf("%s words",names[j++]);
                for(auto w:key.words) std::printf(" %016llx",(unsigned long long)w);
                std::printf("\nhashes");
                for(size_t n:{size_t(0),size_t(8),size_t(256),size_t(1024)})
                    std::printf(" %zu:%016llx",n,(unsigned long long)chainhash(&key,message.data()+1,n));
                std::printf("\n");
            }
        }
    }
    std::printf("PASS: 10000 field products; six edge seeds; %u hash comparisons; backend=%s\n",hash_checks,CHAINHASH_BACKEND);
}
