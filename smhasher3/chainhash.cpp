/*
 * MIT License
 *
 * Copyright (c) 2026 Thomas Dybdahl Ahle
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
#include "Platform.h"
#include "Hashlib.h"
#include "chainhash/chainhash.h"
#include "chainhash/chainhash128.h"

// The suite's 64-bit seed is expanded by the headers' own seed constructors:
// SplitMix64 outputs, encoded little-endian, become the key bytes
// s, y, c0..c4, tau (eight 64-bit words for ChainHash, eight 128-bit words for
// ChainHash-128). A 64-bit seed carries 64 bits of entropy; the collision
// bound assumes 64 (resp. 128) uniformly random key bytes and is not a claim
// about this benchmark adapter.
static uintptr_t chainhash_seed(const seed_t seed) {
    static thread_local chainhash_key key;
    key = chainhash_key_from_seed((uint64_t)seed);
    return (uintptr_t)&key;
}

static uintptr_t chainhash128_seed(const seed_t seed) {
    static thread_local chainhash128_key key;
    key = chainhash128_key_from_seed((uint64_t)seed);
    return (uintptr_t)&key;
}

// Message words are canonical little-endian in every registration. The
// byte-swapped 64-bit registration changes only the digest serialization;
// the 128-bit digest is always its 16 canonical little-endian bytes.
template <bool bswap>
static void ChainHash(const void * in, const size_t len, const seed_t seed, void * out) {
    const uint64_t h = chainhash((const chainhash_key *)(uintptr_t)seed, in, len);
    PUT_U64<bswap>(h, (uint8_t *)out, 0);
}

static void ChainHash128(const void * in, const size_t len, const seed_t seed, void * out) {
    chainhash128_store(out, chainhash128((const chainhash128_key *)(uintptr_t)seed, in, len));
}

static bool chainhash_init(void) { return chainhash_selftest() != 0; }
static bool chainhash128_init(void) { return chainhash128_selftest() != 0; }

REGISTER_FAMILY(chainhash,
   $.src_url    = "https://github.com/thomasahle/chainhash",
   $.src_status = HashFamilyInfo::SRC_ACTIVE
 );

REGISTER_HASH(chainhash,
   $.desc            = "ChainHash: comb CLNH blocks, Horner chain over GF(2^64), twisted quintic finalizer",
   $.hash_flags      = FLAG_HASH_CLMUL_BASED,
   $.impl_flags      = FLAG_IMPL_LICENSE_MIT,
   $.bits            = 64,
   $.verification_LE = 0x66672BD6,
   $.verification_BE = 0xFA8A8D3B,
   $.initfn          = chainhash_init,
   $.seedfn          = chainhash_seed,
   $.hashfn_native   = ChainHash<false>,
   $.hashfn_bswap    = ChainHash<true>
 );

REGISTER_HASH(chainhash_128,
   $.desc            = "ChainHash-128: comb CLNH blocks, Horner chain over GF(2^128), twisted quintic finalizer",
   $.hash_flags      = FLAG_HASH_CLMUL_BASED | FLAG_HASH_ENDIAN_INDEPENDENT,
   $.impl_flags      = FLAG_IMPL_LICENSE_MIT | FLAG_IMPL_CANONICAL_BOTH,
   $.bits            = 128,
   $.verification_LE = 0x1FCA728C,
   $.verification_BE = 0x1FCA728C,
   $.initfn          = chainhash128_init,
   $.seedfn          = chainhash128_seed,
   $.hashfn_native   = ChainHash128,
   $.hashfn_bswap    = ChainHash128
 );
