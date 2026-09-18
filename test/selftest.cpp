#include "chainhash.h"
#include "vendor/chainhash_ref.h"
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>
#if defined(__unix__) || defined(__APPLE__)
#include <sys/mman.h>
#include <unistd.h>
#endif
#include "vectors.h"
static size_t cases = 0;
static void require(bool ok, const char *what) {
    if (!ok) { std::fprintf(stderr,"FAIL: %s\n",what); std::exit(1); }
}
static chainhash_ref::Key<> refkey(const chainhash_key &k) {
    chainhash_ref::Key<> r;
    for (int i=0;i<32;++i) r.k[i]=k.words[i];
    r.u=k.words[32]; r.y=k.words[33]; r.z=k.words[34];
    for (int i=0;i<5;++i) r.c[i]=k.words[35+i];
    r.t_in=k.words[40]; return r;
}
static void check(const chainhash_key &k, const void *p, size_t n) {
    uint64_t expected=chainhash_ref::hash(refkey(k),p,n);
    require(chainhash_portable(&k,p,n)==expected,"portable vs paper reference");
    require(chainhash(&k,p,n)==expected,"selected path vs paper reference");
#if CHAINHASH_HARDWARE
    require(chainhash_hardware(&k,p,n)==expected,"hardware vs portable");
#endif
#if defined(CHAINHASH_RUNTIME_WIDE)
    if (n>256) {
        const int width=ch_x86_width();
        if (width>=1) {
            require(chainhash_narrow(&k,p,n)==expected,"pipelined XMM vs paper reference");
            require(chainhash_wide256(&k,p,n)==expected,"YMM vs paper reference");
        }
        if (width>=2)
            require(chainhash_wide512(&k,p,n)==expected,"ZMM vs paper reference");
    }
#endif
    ++cases;
}
int main() {
    static_assert(sizeof(chainhash_key)==328,"key must be exactly 41 words");
    std::vector<uint8_t> data(262144+64);
    uint64_t rng=UINT64_C(0x123456789abcdef0);
    for (auto &x:data) x=(uint8_t)ch_splitmix64(&rng);
    for (unsigned ki=0;ki<6;++ki) {
        uint8_t raw[328];
        for (unsigned j=0;j<328;++j) raw[j]=ki==0?0:ki==1?255:(uint8_t)ch_splitmix64(&rng);
        chainhash_key k=chainhash_key_from_328_bytes(raw);
        for(unsigned j=0;j<41;++j) require(k.words[j]==ch_load64(raw+8*j),"byte key order");
        check(k,NULL,0);
        for(size_t n=0;n<=1024;++n) check(k,data.data()+(n%32),n);
        for(size_t n: {size_t(2047),size_t(2048),size_t(2049),size_t(4095),size_t(4096),size_t(4097),size_t(262143),size_t(262144)}) check(k,data.data()+ki,n);
    }
    chainhash_key k=chainhash_key_from_splitmix64_legacy(42);
    for(unsigned i=0;i<200;++i) check(k,data.data()+(i%32),ch_splitmix64(&rng)%8193);
    /* Fresh messages and raw keys; at least 10,000 inputs enter every
     * available bulk path, independently of the CPU's dispatch preference. */
    size_t random_bulk=0;
    for(unsigned i=0;i<12000;++i) {
        const size_t n=ch_splitmix64(&rng)%4097;
        const size_t off=ch_splitmix64(&rng)%64;
        for(size_t j=0;j<n;++j) data[off+j]=(uint8_t)ch_splitmix64(&rng);
        chainhash_key random_key;
        for(auto &word:random_key.words) word=ch_splitmix64(&rng);
        check(random_key,data.data()+off,n);
        if(n>256) ++random_bulk;
    }
    require(random_bulk>=10000,"at least 10000 randomized bulk inputs");
    std::memset(data.data(),0,data.size());
    for(size_t n=0;n<=1024;++n) check(k,data.data(),n);
    for(size_t i=0;i<data.size();++i) data[i]=(uint8_t)(i*131+17);
    for(const auto &v: vectors) {
        k=chainhash_key_from_splitmix64_legacy(v.seed);
        require(chainhash(&k,data.data(),v.len)==v.hash,"frozen reference vector");
        auto r=chainhash_ref::Key<>::from_seed(v.seed);
        auto s=refkey(k);
        require(std::memcmp(&r,&s,sizeof(r))==0,"seed expansion vs paper reference");
    }
    /* SMHasher3 HashInfo::_ComputedVerifyImpl, canonical LE serialization. */
    uint8_t input[256]={0}, hashes[2048];
    for(unsigned i=0;i<256;++i) {
        k=chainhash_key_from_splitmix64_legacy(256-i);
        uint64_t h=chainhash(&k,input,i);
        for(unsigned j=0;j<8;++j) hashes[8*i+j]=(uint8_t)(h>>(8*j));
        input[i]=(uint8_t)i;
    }
    k=chainhash_key_from_splitmix64_legacy(0);
    uint32_t verification=(uint32_t)chainhash(&k,hashes,sizeof(hashes));
    require(verification==UINT32_C(0xAA4E2A3B),"SMHasher3 verification code");
#if defined(__unix__) || defined(__APPLE__)
    size_t page=(size_t)sysconf(_SC_PAGESIZE);
    uint8_t *map=(uint8_t *)mmap(NULL,3*page,PROT_NONE,MAP_PRIVATE|MAP_ANON,-1,0);
    require(map!=MAP_FAILED,"mmap");
    require(mprotect(map+page,page,PROT_READ|PROT_WRITE)==0,"mprotect");
    std::memset(map+page,0xa5,page);
    for(size_t n=0;n<=1024;++n) {
        check(k,map+2*page-n,n); /* immediately before inaccessible page */
        check(k,map+page,n);    /* immediately after inaccessible page */
    }
    munmap(map,3*page);
#endif
    std::printf("PASS %zu differential cases; %zu frozen vectors; backend=%s; verification=0x%08X\n",cases,sizeof(vectors)/sizeof(vectors[0]),CHAINHASH_BACKEND,verification);
    std::printf("PASS 12000 randomized messages/keys/lengths; %zu bulk inputs\n",random_bulk);
#if defined(CHAINHASH_RUNTIME_WIDE)
    std::printf("x86 runtime width=%d (0=PCLMUL, 1=YMM, 2=ZMM); prefer128=%d; direct bulk paths=PCLMUL%s%s\n",
                ch_x86_width(),ch_x86_prefer128(),
                ch_x86_width()>=1?", pipelined XMM, YMM":"",
                ch_x86_width()>=2?", ZMM":"");
#endif
}
