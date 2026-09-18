import ProvenHashes.GF64Irreducible
import ProvenHashes.GF64Representation
import ProvenHashes.MachineTwist

noncomputable section
namespace ProvenHashes.GF64Implementation

instance modulusIrreducible : Fact (Irreducible GF64Certificate.modulus) :=
  ⟨GF64Certificate.modulus_irreducible⟩

end ProvenHashes.GF64Implementation

namespace ProvenHashes.ConcreteChainHash
open Carryless ChainEncoding GF64Implementation

abbrev ByteString := List (BitVec 8)
abbrev Key := Fin 41 → BitVec 64

instance machineWordFintype : Fintype (BitVec 64) :=
  Fintype.ofEquiv (Word 64) (bitsEquiv 64).symm

def keyEquiv : Key ≃ ChainHash256.FlatKey where
  toFun k := fun i => (bitsEquiv 64) (k i)
  invFun k := fun i => (bitsEquiv 64).symm (k i)
  left_inv k := by funext i; exact (bitsEquiv 64).symm_apply_apply (k i)
  right_inv k := by funext i; exact (bitsEquiv 64).apply_symm_apply (k i)

def bytes (m : ByteString) : Bytes := m.map bits

/-- ChainHash-256, full 64-bit output. All 41 key words are used directly,
in their shipped order, with the implementation's polynomial modulus. -/
def hash (k : Key) (m : ByteString) : BitVec 64 :=
  (bitsEquiv 64).symm (wordEquiv.symm
    (ChainHash256.hashFlat wordEquiv (keyEquiv k) (bytes m)))

theorem key_card : Fintype.card Key = 2 ^ (64 * 41) := by
  rw [Fintype.card_congr keyEquiv]
  exact ChainHash256.flatKey_card

/-- Concrete paper theorem for the shipped 256-byte blocks and 41-word
uniform ideal key. There are no stage-bound or representation hypotheses.
`L` counts 8-byte words; inputs may have any byte length at most `8*L`.
The 255-byte margin keeps the code's block-count addition from overflowing. -/
theorem collision_bound (L : ℕ) (hL : 8 * L + 255 < 2 ^ 64)
    (m m' : ByteString) (hm : m.length ≤ 8 * L) (hm' : m'.length ≤ 8 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key => hash k m = hash k m') ≤
      ((max 1 ((L + 31) / 32) + 2 : ℕ) : ℚ≥0) / (2 : ℚ≥0) ^ 64 := by
  have hmB : (bytes m).length ≤ 8 * L := by simpa only [bytes, List.length_map] using hm
  have hmB' : (bytes m').length ≤ 8 * L := by simpa only [bytes, List.length_map] using hm'
  have hneB : bytes m ≠ bytes m' := by
    intro h
    exact hne ((List.map_injective_iff.mpr (bits_injective 8)) h)
  have h := ChainHash256.collision_bound_flat wordEquiv L (by omega) (bytes m) (bytes m') hmB hmB' hneB
  rw [← uniformProb_equiv keyEquiv] at h
  simpa only [hash, Equiv.apply_eq_iff_eq, AddEquiv.apply_eq_iff_eq, ChainHash256.epsilon] using h

end ProvenHashes.ConcreteChainHash
