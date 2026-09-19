import ProvenHashes.ChainHash128.ModulusIrreducible
import ProvenHashes.ChainHash128.ConcreteWords
import ProvenHashes.ChainHash128.WordRepresentation
import ProvenHashes.ChainHash128.KeyLayout

noncomputable section
namespace ProvenHashes.ChainHash128
open ProvenHashes.ChainHash

instance : Fact (Irreducible modulus) := ⟨modulus_irreducible⟩

/-- The same polynomial-basis bits, interpreted as a 128-bit integer for the twist. -/
def fieldIntegerEquiv : BinaryQuotient ≃ ZMod (2 ^ 128) :=
  fieldRepr.symm.toEquiv.trans (wordIntegerEquiv 128)

/-- ChainHash-128 with 512-byte blocks: the full 128-bit result, with the shipped 41-word key layout. -/
def chainHash (k : Key41) (m : Message) : Word 128 :=
  fieldRepr.symm (hash fieldRepr fieldIntegerEquiv (decodeKey fieldRepr k) m)

/-- Concrete byte-string collision theorem for independent uniform ideal keys.
L counts 16-byte words; no assumptions about a stream or finalizer remain. -/
theorem chainHash_collision_bound (L : ℕ) (hL : 16 * L < 2 ^ 128)
    (m m' : Message) (hm : m.length ≤ 16 * L) (hm' : m'.length ≤ 16 * L) (hne : m ≠ m') :
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

/-- A cap that also rules out overflow in the reference's `len + 511` rounding. -/
theorem chainHash_collision_bound_no_overflow (L : ℕ) (hL : 16 * L + 511 < 2 ^ 128)
    (m m' : Message) (hm : m.length ≤ 16 * L) (hm' : m'.length ≤ 16 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key41 => chainHash k m = chainHash k m') ≤ epsilon L :=
  chainHash_collision_bound L (by omega) m m' hm hm' hne

end ProvenHashes.ChainHash128
