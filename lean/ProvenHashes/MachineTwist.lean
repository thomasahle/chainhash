import ProvenHashes.FlatKey

noncomputable section
namespace ProvenHashes.ChainEncoding
open Carryless

/-- The integer interpretation respects BitVec's addition modulo 2^64. -/
theorem integerEquiv_add_bits (v t : BitVec 64) :
    integerEquiv 64 ((bitsEquiv 64) (v + t)) =
      integerEquiv 64 ((bitsEquiv 64) v) + integerEquiv 64 ((bitsEquiv 64) t) := by
  simp only [integerEquiv, Equiv.trans_apply, Equiv.symm_apply_apply]
  change (ZMod.finEquiv (2 ^ 64)) (BitVec.equivFin (v + t)) =
    (ZMod.finEquiv (2 ^ 64)) (BitVec.equivFin v) +
      (ZMod.finEquiv (2 ^ 64)) (BitVec.equivFin t)
  rw [map_add, map_add]

/-- The abstractly transported twist is precisely the machine's integer
addition on 64-bit words, including its carry chain and wraparound. -/
theorem field_twist_matches {F : Type*} [AddGroup F] (e : Word 64 ≃+ F)
    (v t : BitVec 64) :
    Finalizer.twist (ChainHash256.fieldInteger e) (integerEquiv 64 ((bitsEquiv 64) t))
      (e ((bitsEquiv 64) v)) = e ((bitsEquiv 64) (v + t)) := by
  apply (ChainHash256.fieldInteger e).injective
  change (ChainHash256.fieldInteger e)
    ((ChainHash256.fieldInteger e).symm
      ((ChainHash256.fieldInteger e) (e ((bitsEquiv 64) v)) +
        integerEquiv 64 ((bitsEquiv 64) t))) = _
  rw [Equiv.apply_symm_apply]
  change integerEquiv 64 (e.symm (e ((bitsEquiv 64) v))) +
    integerEquiv 64 ((bitsEquiv 64) t) =
      integerEquiv 64 (e.symm (e ((bitsEquiv 64) (v + t))))
  rw [e.symm_apply_apply, e.symm_apply_apply]
  exact (integerEquiv_add_bits v t).symm

/-- The max/ceiling definition agrees with the reference code's empty-input branch. -/
theorem blockCount_matches_reference (n : ℕ) :
    blockCount n = if n = 0 then 1 else (n + 255) / 256 := by
  unfold blockCount
  split_ifs <;> omega

/-- Every block before the last one is full, as in the code's outer loop. -/
theorem remaining_before_last {n t : ℕ} (ht : t + 1 < blockCount n) :
    remaining n t = 256 := by
  unfold remaining blockCount at *
  omega

end ProvenHashes.ChainEncoding
