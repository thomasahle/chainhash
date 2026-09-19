#include <initializer_list>
#include <cstdio>
#include <cstdint>
#include <cstring>
#include "../provenance/chainhash.h"
#include "../provenance/chainhash3.h"
#include "common.inc"
static void hash(bool v3, bool swap, const void *p, size_t n, uint64_t seed, uint8_t *out) {
 uint64_t h;
 if(v3) { auto k=chainhash_v3_key_from_seed(seed); h=chainhash_v3(&k,p,n); }
 else { auto k=chainhash_paper_key(seed); h=chainhash(&k,p,n); }
 for(unsigned j=0;j<8;j++)out[j]=(uint8_t)(h>>(8*(swap?7-j:j)));
}
int main() {
 for(bool v3:{true,false})for(bool swap:{false,true}) {
  uint8_t p[256]={0}, hashes[2048], out[8];
  for(unsigned i=0;i<256;i++){p[i]=i;hash(v3,swap,p,i,256-i,hashes+8*i);}
  hash(v3,swap,hashes,2048,0,out);
  uint32_t v=0;for(unsigned i=0;i<4;i++)v|=uint32_t(out[i])<<(8*i);
  std::printf("%s %s %08X\n",v3?"chainhash-v3":"chainhash-256",swap?"BE":"LE",v);
 }
}
