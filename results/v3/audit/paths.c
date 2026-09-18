#include "../chainhash_v3.h"
#ifdef CHV3_X86
CHV3_T128 void audit_xmm(const chainhash_v3_key *k,const uint8_t *p,chv3_raw out[4]) { chv3_region128(k,p,out); }
CHV3_T256 void audit_ymm(const chainhash_v3_key *k,const uint8_t *p,chv3_raw out[4]) { chv3_region256(k,p,out); }
CHV3_T512 void audit_zmm(const chainhash_v3_key *k,const uint8_t *p,chv3_raw out[4]) { chv3_region512(k,p,out); }
#endif
#ifdef CHV3_ARM
void audit_neon(const chainhash_v3_key *k,const uint8_t *p,chv3_raw out[4]) { chv3_region_neon(k,p,out); }
#endif
uint64_t audit_hash(const chainhash_v3_key *k,const uint8_t *p,size_t n) { return chainhash_v3(k,p,n); }
