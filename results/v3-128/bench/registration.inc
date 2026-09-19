#include "Platform.h"
#include "Hashlib.h"
#include "../chainhash128_v3.h"
static uintptr_t v3_seed(seed_t s) { static thread_local chainhash128_v3_key k; k=chainhash128_v3_key_from_seed(s); return (uintptr_t)&k; }
static void v3_hash(const void *p,size_t n,seed_t s,void *out) {
#ifdef USE_PUBLIC
chainhash128_v3_store(out,chainhash128_v3((const chainhash128_v3_key *)(uintptr_t)s,p,n));
#else
chainhash128_v3_store(out,chainhash128_v3_with_backend((const chainhash128_v3_key *)(uintptr_t)s,p,n,chainhash128_v3_backend(),SCHOOL));
#endif
}
static bool v3_selftest() { return chainhash128_v3_selftest()!=0; }
#if CHAINHASH128_V3_BLOCK_BYTES == 512
#define V3_VERIFY 0x1FCA728C
#else
#define V3_VERIFY 0x0F709CAD
#endif
#define EXPAND_FAMILY(N,...) REGISTER_FAMILY(N,__VA_ARGS__)
#define EXPAND_HASH(N,...) REGISTER_HASH(N,__VA_ARGS__)
EXPAND_FAMILY(REG, $.src_status=HashFamilyInfo::SRC_ACTIVE);
EXPAND_HASH(REG, $.desc="ChainHash-128 v3 comb Horner", $.impl="lazy-comb", $.hash_flags=FLAG_HASH_CLMUL_BASED | FLAG_HASH_ENDIAN_INDEPENDENT, $.impl_flags=FLAG_IMPL_LICENSE_MIT | FLAG_IMPL_CANONICAL_BOTH, $.bits=128, $.verification_LE=V3_VERIFY, $.verification_BE=V3_VERIFY, $.initfn=v3_selftest, $.seedfn=v3_seed, $.hashfn_native=v3_hash, $.hashfn_bswap=v3_hash);
