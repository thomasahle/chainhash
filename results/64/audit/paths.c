#include "chainhash.h"
#ifdef CH_X86
CH_T128 void audit_xmm(const chainhash_key *k,const uint8_t *p,ch_raw out[4]) { ch_region128(k,p,out); }
CH_T256 void audit_ymm(const chainhash_key *k,const uint8_t *p,ch_raw out[4]) { ch_region256(k,p,out); }
CH_T512 void audit_zmm(const chainhash_key *k,const uint8_t *p,ch_raw out[4]) { ch_region512(k,p,out); }
#endif
#ifdef CH_ARM
void audit_neon(const chainhash_key *k,const uint8_t *p,ch_raw out[4]) { ch_region_neon(k,p,out); }
#endif
uint64_t audit_hash(const chainhash_key *k,const uint8_t *p,size_t n) { return chainhash(k,p,n); }
