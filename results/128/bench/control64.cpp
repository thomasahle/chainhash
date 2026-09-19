#include "Platform.h"
#include "Hashlib.h"
#include "chainhash.h"
static uintptr_t chainhash_seed(seed_t seed) { static thread_local chainhash_key k; k=chainhash_key_from_seed(seed); return (uintptr_t)&k; }
template <bool swap> static void chainhash_hash(const void *p,size_t n,seed_t seed,void *out) { uint64_t h=chainhash((const chainhash_key *)(uintptr_t)seed,p,n); PUT_U64<swap>(h,(uint8_t *)out,0); }
REGISTER_FAMILY(chainhash, $.src_status=HashFamilyInfo::SRC_ACTIVE);
REGISTER_HASH(chainhash, $.desc="ChainHash: comb CLNH blocks, Horner chain over GF(2^64), twisted quintic finalizer (64-bit control in the ChainHash-128 binaries)", $.impl="lazy-k4", $.hash_flags=FLAG_HASH_CLMUL_BASED, $.impl_flags=FLAG_IMPL_LICENSE_MIT, $.bits=64, $.verification_LE=0x66672BD6, $.verification_BE=0xFA8A8D3B, $.seedfn=chainhash_seed, $.hashfn_native=chainhash_hash<false>, $.hashfn_bswap=chainhash_hash<true>);
