// Inputs for lean/VectorAgreement.lean; every result is checked against each
// available shipped path before being emitted. No golden values are updated.
#include "chainhash.h"
#include "vendor/chainhash_ref.h"
#include "vectors.h"
#include <cstdio>
#include <cstdlib>
#include <vector>
static void emit(const chainhash_key &k, size_t n, uint64_t frozen=0, bool has_frozen=false) {
    std::vector<uint8_t> m(n+1);
    for (size_t i=0;i<n;++i) m[i]=(uint8_t)(131*i+17);
    chainhash_ref::Key<> r;
    for (int i=0;i<32;++i) r.k[i]=k.words[i];
    r.u=k.words[32]; r.y=k.words[33]; r.z=k.words[34];
    for (int i=0;i<5;++i) r.c[i]=k.words[35+i];
    r.t_in=k.words[40];
    uint64_t h=chainhash_ref::hash(r,m.data(),n);
    auto check=[&](uint64_t actual) { if(actual!=h) {std::fprintf(stderr,"pairing/vector mismatch at %zu\n",n);std::exit(1);} };
    if(has_frozen) check(frozen);
    check(chainhash_portable(&k,m.data(),n));
    check(chainhash(&k,m.data(),n));
#if CHAINHASH_HARDWARE
    check(chainhash_hardware(&k,m.data(),n));
#endif
#if defined(CHAINHASH_RUNTIME_WIDE)
    if(n>256 && ch_x86_width()>=1) {
        check(chainhash_narrow(&k,m.data(),n));
        check(chainhash_wide256(&k,m.data(),n));
        if(ch_x86_width()>=2) check(chainhash_wide512(&k,m.data(),n));
    }
#endif
    std::printf("%zu %llu",n,(unsigned long long)h);
    for(auto x:k.words) std::printf(" %llu",(unsigned long long)x);
    std::putchar('\n');
}
int main() {
    for(auto v:vectors) if(v.len<=1025)
        emit(chainhash_key_from_splitmix64_legacy(v.seed),v.len,v.hash,true);
    const uint64_t seeds[]={0,1,2,UINT64_MAX,UINT64_C(0x123456789abcdef0)};
    const size_t lengths[]={0,1,2,7,8,9,15,16,17,23,24,25,31,32,33,39,40,47,48,63,64,65,127,128,129,223,224,225,231,232,233,239,240,241,247,248,249,255,256,257,287,288,289,511,512,513,1024,1025};
    for(auto s:seeds) {
        uint8_t bytes[80]; uint64_t rng=s;
        for(unsigned i=0;i<10;++i) {
            uint64_t v=i?ch_splitmix64(&rng):s;
            for(unsigned j=0;j<8;++j) bytes[8*i+j]=(uint8_t)(v>>(8*j));
        }
        auto k=chainhash_key_from_80_bytes(bytes);
        for(auto n:lengths) emit(k,n);
    }
#if defined(CHAINHASH_RUNTIME_WIDE)
    std::fprintf(stderr,"x86 runtime width: %d (0=baseline, 1=YMM, 2=ZMM)\n",ch_x86_width());
#endif
}
