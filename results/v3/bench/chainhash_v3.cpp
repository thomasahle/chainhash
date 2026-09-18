#include "Platform.h"
#include "Hashlib.h"
#include "chainhash_v3.h"
static uintptr_t v3_seed(seed_t seed) { static thread_local chainhash_v3_key k; k=chainhash_v3_key_from_seed(seed); return (uintptr_t)&k; }
template <bool swap> static void v3_hash(const void *p,size_t n,seed_t seed,void *out) { uint64_t h=chainhash_v3((const chainhash_v3_key *)(uintptr_t)seed,p,n); PUT_U64<swap>(h,(uint8_t *)out,0); }
REGISTER_FAMILY(chainhash_v3, $.src_status=HashFamilyInfo::SRC_ACTIVE);
REGISTER_HASH(chainhash_v3, $.desc="ChainHash v3 Horner, comb 256-byte blocks", $.impl="lazy-k4", $.hash_flags=FLAG_HASH_CLMUL_BASED, $.impl_flags=FLAG_IMPL_LICENSE_MIT, $.bits=64, $.verification_LE=0x66672BD6, $.verification_BE=0xFA8A8D3B, $.seedfn=v3_seed, $.hashfn_native=v3_hash<false>, $.hashfn_bswap=v3_hash<true>);
