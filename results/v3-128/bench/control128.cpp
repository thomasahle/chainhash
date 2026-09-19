#include "Platform.h"
#include "Hashlib.h"

#include "../chainhash128.h"
static thread_local chainhash128_key key;
static uintptr_t seed_init(seed_t s) { key=chainhash128_key_from_splitmix64(s); return (uintptr_t)&key; }
static void hash(const void *in,size_t len,seed_t s,void *out) { chainhash128_store(out,chainhash128((const chainhash128_key *)(uintptr_t)s,in,len)); }
static bool selftest() { return chainhash128_selftest()!=0; }
REGISTER_FAMILY(chainhash_128, $.src_status=HashFamilyInfo::SRC_ACTIVE);
REGISTER_HASH(chainhash_128,
 $.desc="ChainHash-128: 512-byte blocks, 3-product Karatsuba (benchmark seed expansion outside theorem)",
 $.impl=CHAINHASH128_BACKEND,
 $.hash_flags=FLAG_HASH_CLMUL_BASED | FLAG_HASH_ENDIAN_INDEPENDENT,
 $.impl_flags=FLAG_IMPL_LICENSE_MIT | FLAG_IMPL_CANONICAL_BOTH,
 $.bits=128,
 $.verification_LE=0x742DE5A5, $.verification_BE=0x742DE5A5,
 $.seedfn=seed_init, $.initfn=selftest,
 $.hashfn_native=hash, $.hashfn_bswap=hash);
