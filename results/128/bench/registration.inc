#include "Platform.h"
#include "Hashlib.h"
#include "chainhash128.h"
static uintptr_t chainhash128_seed(seed_t s) { static thread_local chainhash128_key k; k=chainhash128_key_from_seed(s); return (uintptr_t)&k; }
static void chainhash128_hash(const void *p,size_t n,seed_t s,void *out) {
#ifdef USE_PUBLIC
chainhash128_store(out,chainhash128((const chainhash128_key *)(uintptr_t)s,p,n));
#else
chainhash128_store(out,chainhash128_with_backend((const chainhash128_key *)(uintptr_t)s,p,n,chainhash128_backend(),SCHOOL));
#endif
}
static bool chainhash128_init() { return chainhash128_selftest()!=0; }
#if CHAINHASH128_BLOCK_BYTES == 512
#define VERIFY 0x1FCA728C
#else
#define VERIFY 0x0F709CAD
#endif
#define EXPAND_FAMILY(N,...) REGISTER_FAMILY(N,__VA_ARGS__)
#define EXPAND_HASH(N,...) REGISTER_HASH(N,__VA_ARGS__)
EXPAND_FAMILY(REG, $.src_status=HashFamilyInfo::SRC_ACTIVE);
EXPAND_HASH(REG, $.desc="ChainHash-128: comb CLNH blocks, Horner chain over GF(2^128), twisted quintic finalizer", $.impl="lazy-comb", $.hash_flags=FLAG_HASH_CLMUL_BASED | FLAG_HASH_ENDIAN_INDEPENDENT, $.impl_flags=FLAG_IMPL_LICENSE_MIT | FLAG_IMPL_CANONICAL_BOTH, $.bits=128, $.verification_LE=VERIFY, $.verification_BE=VERIFY, $.initfn=chainhash128_init, $.seedfn=chainhash128_seed, $.hashfn_native=chainhash128_hash, $.hashfn_bswap=chainhash128_hash);
