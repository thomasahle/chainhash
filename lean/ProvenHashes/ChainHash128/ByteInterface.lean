import ProvenHashes.ChainHash128.ByteEncoding

noncomputable section
namespace ProvenHashes.ChainHash128
open ProvenHashes.ChainHash

/-- Native byte strings as messages: each `UInt8` becomes its eight bits. -/
def bytesToMessage (m : List UInt8) : Message := m.map (fun b => bitsOfBitVec b.toBitVec)

theorem bytesToMessage_injective : Function.Injective bytesToMessage := by
  apply List.map_injective_iff.mpr
  intro a b h
  exact UInt8.toBitVec_inj.mp (bitsOfBitVec_injective 8 h)

end ProvenHashes.ChainHash128
