import ProvenHashes.ModulusIrreducible
import ProvenHashes.ConcreteWords
import ProvenHashes.WordRepresentation
import ProvenHashes.KeyLayout

noncomputable section
namespace ProvenHashes.ChainHash

instance : Fact (Irreducible modulus) := ⟨modulus_irreducible⟩

/-- The same polynomial-basis bits, interpreted as a 64-bit integer for the twist. -/
def fieldIntegerEquiv : BinaryQuotient ≃ ZMod (2 ^ 64) :=
  fieldRepr.symm.toEquiv.trans (wordIntegerEquiv 64)

/-- ChainHash-256: the full 64-bit result, with the shipped 41-word key layout. -/
def chainHash (k : Key41) (m : Message) : Word 64 :=
  fieldRepr.symm (hash fieldRepr fieldIntegerEquiv (decodeKey fieldRepr k) m)

/-- Concrete byte-string collision theorem for independent uniform ideal keys.
L counts 8-byte words; no assumptions about a stream or finalizer remain. -/
theorem chainHash_collision_bound (L : ℕ) (hL : 8 * L < 2 ^ 64)
    (m m' : Message) (hm : m.length ≤ 8 * L) (hm' : m'.length ≤ 8 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key41 => chainHash k m = chainHash k m') ≤ epsilon L := by
  have he : (fun k : Key41 => chainHash k m = chainHash k m') =
      (fun k => hash fieldRepr fieldIntegerEquiv (keyEquiv fieldRepr k) m =
        hash fieldRepr fieldIntegerEquiv (keyEquiv fieldRepr k) m') := by
    funext k
    exact propext fieldRepr.symm.injective.eq_iff
  rw [he]
  have hp := uniformProb_equiv (keyEquiv fieldRepr) (fun k : IdealKey BinaryQuotient =>
    hash fieldRepr fieldIntegerEquiv k m = hash fieldRepr fieldIntegerEquiv k m')
  rw [hp]
  exact collision_bound_words_model fieldRepr fieldIntegerEquiv L hL m m' hm hm' hne

/-- A cap that also rules out overflow in the reference's `len + 255` rounding. -/
theorem chainHash_collision_bound_no_overflow (L : ℕ) (hL : 8 * L + 255 < 2 ^ 64)
    (m m' : Message) (hm : m.length ≤ 8 * L) (hm' : m'.length ≤ 8 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key41 => chainHash k m = chainHash k m') ≤ epsilon L :=
  chainHash_collision_bound L (by omega) m m' hm hm' hne

end ProvenHashes.ChainHash
