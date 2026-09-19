#include "Platform.h"
#include "Hashlib.h"

#include "../chainhash128.h" /* control-128: the control construction's header of the measurement lane, not include/chainhash128.h and not part of this repository */
static thread_local chainhash128_key key;
static uintptr_t seed_init(seed_t s) { key=chainhash128_key_from_splitmix64(s); return (uintptr_t)&key; }
static void hash(const void *in,size_t len,seed_t s,void *out) { chainhash128_store(out,chainhash128((const chainhash128_key *)(uintptr_t)s,in,len)); }
static bool selftest() { return chainhash128_selftest()!=0; }
REGISTER_FAMILY(control_128, $.src_status=HashFamilyInfo::SRC_ACTIVE);
REGISTER_HASH(control_128,
 $.desc="control-128: a different 128-bit CLMUL construction timed as a control, not shipped (benchmark seed expansion outside theorem)",
 $.impl=CHAINHASH128_BACKEND,
 $.hash_flags=FLAG_HASH_CLMUL_BASED | FLAG_HASH_ENDIAN_INDEPENDENT,
 $.impl_flags=FLAG_IMPL_LICENSE_MIT | FLAG_IMPL_CANONICAL_BOTH,
 $.bits=128,
 $.verification_LE=0x742DE5A5, $.verification_BE=0x742DE5A5,
 $.seedfn=seed_init, $.initfn=selftest,
 $.hashfn_native=hash, $.hashfn_bswap=hash);
