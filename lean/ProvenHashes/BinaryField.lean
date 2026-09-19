import ProvenHashes.ModulusIrreducible
import ProvenHashes.ConcreteWords
import ProvenHashes.WordRepresentation

/-! `GF(2)[X]/(X^64+X^4+X^3+X+1)` is a field, and its elements read as 64-bit integers. -/
noncomputable section
namespace ProvenHashes.ChainHash

instance : Fact (Irreducible modulus) := ⟨modulus_irreducible⟩

/-- The same polynomial-basis bits, interpreted as a 64-bit integer for the twist. -/
def fieldIntegerEquiv : BinaryQuotient ≃ ZMod (2 ^ 64) :=
  fieldRepr.symm.toEquiv.trans (wordIntegerEquiv 64)

end ProvenHashes.ChainHash
