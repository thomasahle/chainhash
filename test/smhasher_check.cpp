/* Compiles the unmodified fork source in the scratch include directory.
 * Only its registration macros are disabled by the scratch Hashlib.h.
 * Calls the actual seed initializer and native 256-byte hash template. */
#define chainhash_key smh_key
#include "smhasher_chainhash.cpp"
#undef chainhash_key
#include "chainhash.h"
#include "vendor/chainhash_ref.h"
#include "vectors.h"
#include <cstdio>
#include <cstdlib>
#include <vector>
#ifdef CHECK_BENCH
extern "C" uint64_t bench_hash(const uint64_t *,const void *,size_t);
#endif
static size_t cases=0;
static void check(const chainhash_key &key,const uint8_t *p,size_t n,uintptr_t seed) {
    uint8_t actual[8],expected[8];
    ChainHash<32,5,1,false>(p,n,(seed_t)seed,actual);
    uint64_t h=chainhash(&key,p,n);
    for(unsigned j=0;j<8;++j) expected[j]=(uint8_t)(h>>(8*j));
    if(std::memcmp(actual,expected,8)) {
        std::fprintf(stderr,"SMHasher3 mismatch len=%zu case=%zu\n",n,cases); std::exit(1);
    }
#ifdef CHECK_BENCH
    if(bench_hash(key.words,p,n)!=h) {std::fprintf(stderr,"benchmark mismatch\n");std::exit(1);}
#endif
    ++cases;
}
int main() {
    std::vector<uint8_t> data(262144+64);
    for(size_t i=0;i<data.size();++i) data[i]=(uint8_t)(i*131+17);
    for(const auto &v:vectors) {
        chainhash_key k=chainhash_key_from_seed(v.seed);
        uintptr_t s=chainhash_seed_init<32,5>(v.seed);
        check(k,data.data(),v.len,s);
        uint8_t out[8]; ChainHash<32,5,1,false>(data.data(),v.len,(seed_t)s,out);
        if(ch_load64(out)!=v.hash) {std::fprintf(stderr,"frozen vector mismatch\n");return 1;}
        const auto &sk=*(const smh_key<32,5> *)s;
        for(int j=0;j<32;++j) if(sk.k[j]!=k.words[j]) return 1;
        if(sk.u!=k.words[32]||sk.y!=k.words[33]||sk.z!=k.words[34]||sk.t_in!=k.words[40]) return 1;
        for(int j=0;j<5;++j) if(sk.c[j]!=k.words[35+j]) return 1;
    }
    uint64_t rng=UINT64_C(0x123456789abcdef0);
    for(auto &v:data) v=(uint8_t)ch_splitmix64(&rng);
    for(unsigned ki=0;ki<6;++ki) {
        uint8_t raw[328];
        for(auto &v:raw) v=ki==0?0:ki==1?255:(uint8_t)ch_splitmix64(&rng);
        chainhash_key k=chainhash_key_from_bytes(raw);
        smh_key<32,5> sk;
        for(unsigned j=0;j<32;++j) sk.k[j]=k.words[j];
        sk.u=k.words[32];sk.y=k.words[33];sk.z=k.words[34];sk.t_in=k.words[40];
        for(unsigned j=0;j<5;++j) sk.c[j]=k.words[j+35];
        chainhash_key_setup(sk);
        check(k,NULL,0,(uintptr_t)&sk);
        for(size_t n=0;n<=1024;++n) check(k,data.data()+n%32,n,(uintptr_t)&sk);
        for(size_t n:{size_t(4095),size_t(4096),size_t(4097),size_t(262143),size_t(262144)}) check(k,data.data()+ki,n,(uintptr_t)&sk);
    }
    std::printf("PASS %zu byte-for-byte cases against unmodified SMHasher3 chainhash_256; all 92 reference vectors; SMHasher3 backend=%s\n",cases,CHAINHASH_IMPL_STR);
#ifdef CHECK_BENCH
    std::puts("PASS same cases against original PMULL benchmark chainhash.h");
#endif
}
