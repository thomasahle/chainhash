import ProvenHashes.ChainHash128.ByteEncoding

namespace ProvenHashes.ChainHash128
open ProvenHashes.ChainHash

/-- Assemble a machine bit vector from its low-to-high coefficient bits. -/
def bitVecOfBits {w : ℕ} (v : Word w) : BitVec w :=
  (BitVec.ofBoolListLE (List.ofFn fun i : Fin w => decide (v i = 1))).cast
    List.length_ofFn

theorem bitsOfBitVec_bitVecOfBits {w : ℕ} (v : Word w) : bitsOfBitVec (bitVecOfBits v) = v := by
  funext i
  simp only [bitsOfBitVec, bitVecOfBits, BitVec.getLsbD_cast, BitVec.getLsbD_ofBoolListLE]
  simp only [List.getD_eq_getElem?_getD, List.getElem?_ofFn, i.isLt, ↓reduceDIte,
    Option.getD_some, decide_eq_true_eq]
  have h : v i = 0 ∨ v i = 1 := by
    have hv := (v i).val_lt
    have hv' : (v i).val = 0 ∨ (v i).val = 1 := by norm_num at hv; omega
    rcases hv' with hv' | hv'
    · left; exact ZMod.val_injective _ hv'
    · right; exact ZMod.val_injective _ hv'
  rcases h with h | h <;> simp [h]

theorem bitVecOfBits_bitsOfBitVec {w : ℕ} (v : BitVec w) : bitVecOfBits (bitsOfBitVec v) = v :=
  bitsOfBitVec_injective w (bitsOfBitVec_bitVecOfBits _)

def bitsEquivBitVec (w : ℕ) : Word w ≃ BitVec w where
  toFun := bitVecOfBits
  invFun := bitsOfBitVec
  left_inv := bitsOfBitVec_bitVecOfBits
  right_inv := bitVecOfBits_bitsOfBitVec

/-- Integer interpretation of the same little-endian bits; addition here has carries. -/
def wordIntegerEquiv (w : ℕ) : Word w ≃ ZMod (2 ^ w) :=
  (bitsEquivBitVec w).trans (BitVec.equivFin.toEquiv.trans (ZMod.finEquiv (2 ^ w)).toEquiv)

theorem wordIntegerEquiv_length (n : ℕ) : wordIntegerEquiv 128 (lengthWord n) = (n : ZMod (2 ^ 128)) := by
  simp only [wordIntegerEquiv, Equiv.trans_apply, bitsEquivBitVec, Equiv.coe_fn_mk,
    lengthWord, bitVecOfBits_bitsOfBitVec]
  rfl

end ProvenHashes.ChainHash128
