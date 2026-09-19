import ProvenHashes.ChainHash128.ModulusIrreducible
import ProvenHashes.ChainHash128.ConcreteWords
import ProvenHashes.ChainHash128.WordRepresentation

/-! `GF(2)[X]/(X^128+X^7+X^2+X+1)` is a field, and its elements read as 128-bit integers. -/
noncomputable section
namespace ProvenHashes.ChainHash128
open ProvenHashes.ChainHash

instance : Fact (Irreducible modulus) := ⟨modulus_irreducible⟩

/-- The same polynomial-basis bits, interpreted as a 128-bit integer for the twist. -/
def fieldIntegerEquiv : BinaryQuotient ≃ ZMod (2 ^ 128) :=
  fieldRepr.symm.toEquiv.trans (wordIntegerEquiv 128)

end ProvenHashes.ChainHash128
