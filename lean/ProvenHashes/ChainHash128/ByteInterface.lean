import ProvenHashes.ChainHash128.ReferenceChainHash

noncomputable section
namespace ProvenHashes.ChainHash128
open ProvenHashes.ChainHash

def bytesToMessage (m : List UInt8) : Message := m.map (fun b => bitsOfBitVec b.toBitVec)

theorem bytesToMessage_injective : Function.Injective bytesToMessage := by
  apply List.map_injective_iff.mpr
  intro a b h
  exact UInt8.toBitVec_inj.mp (bitsOfBitVec_injective 8 h)

/-- Native-byte interface and full BitVec 128 output, with the same ideal 41-word key. -/
def hashBytes (k : Key41) (m : List UInt8) : BitVec 128 :=
  bitVecOfBits (referenceHash k (bytesToMessage m))

theorem hashBytes_eq_iff (k : Key41) (m m' : List UInt8) :
    hashBytes k m = hashBytes k m' ↔
      referenceHash k (bytesToMessage m) = referenceHash k (bytesToMessage m') := by
  exact (bitsEquivBitVec 128).injective.eq_iff

/-- The final theorem stated directly for byte strings and full BitVec 128 outputs. -/
theorem collision_bound_bytes (L : ℕ) (hL : 16 * L + 511 < 2 ^ 128)
    (m m' : List UInt8) (hm : m.length ≤ 16 * L) (hm' : m'.length ≤ 16 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key41 => hashBytes k m = hashBytes k m') ≤
      ((max 1 ((L + 31) / 32) + 2 : ℕ) : ℚ≥0) / (2 : ℚ≥0) ^ 128 := by
  simp_rw [hashBytes_eq_iff]
  apply reference_collision_bound L hL
  · simpa only [bytesToMessage, List.length_map] using hm
  · simpa only [bytesToMessage, List.length_map] using hm'
  · exact fun h => hne (bytesToMessage_injective h)

end ProvenHashes.ChainHash128
