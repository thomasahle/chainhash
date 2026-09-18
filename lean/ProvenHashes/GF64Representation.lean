import ProvenHashes.GF64CertificateData
import ProvenHashes.WordSplit

noncomputable section
namespace ProvenHashes.GF64Implementation
open Polynomial Carryless GF64Certificate

/-- The actual polynomial quotient used by gfmul; the basis is fixed by bits. -/
abbrev F64 := AdjoinRoot modulus

def ofWord : Word 64 →+ F64 :=
  (AdjoinRoot.mk modulus).toAddMonoidHom.comp (Polynomial.ofFn 64).toAddMonoidHom

def toWord : F64 →+ Word 64 :=
  (Polynomial.toFn 64).toAddMonoidHom.comp
    (AdjoinRoot.modByMonicHom modulus_monic).toAddMonoidHom

theorem toWord_ofWord (w : Word 64) : toWord (ofWord w) = w := by
  change Polynomial.toFn 64 (Polynomial.ofFn 64 w %ₘ modulus) = w
  rw [(Polynomial.modByMonic_eq_self_iff modulus_monic).mpr (by
    rw [modulus_degree]
    exact Polynomial.ofFn_degree_lt w)]
  exact Polynomial.toFn_comp_ofFn_eq_id 64 w

theorem representative_degree (x : F64) :
    (AdjoinRoot.modByMonicHom modulus_monic x).degree < 64 := by
  refine AdjoinRoot.induction_on modulus x ?_
  intro p
  rw [AdjoinRoot.modByMonicHom_mk, ← modulus_degree]
  exact Polynomial.degree_modByMonic_lt p modulus_monic

theorem ofWord_toWord (x : F64) : ofWord (toWord x) = x := by
  let p := AdjoinRoot.modByMonicHom modulus_monic x
  have hn : p.natDegree < 64 := by
    by_cases hp : p = 0
    · simp only [hp, Polynomial.natDegree_zero]; decide
    · exact (Polynomial.natDegree_lt_iff_degree_lt hp).mpr (representative_degree x)
  change AdjoinRoot.mk modulus (Polynomial.ofFn 64 (Polynomial.toFn 64 p)) = x
  rw [Polynomial.ofFn_comp_toFn_eq_id_of_natDegree_lt hn]
  exact AdjoinRoot.mk_leftInverse modulus_monic x

/-- This is the canonical polynomial-basis encoding, not a chosen arbitrary basis. -/
def wordEquiv : Word 64 ≃+ F64 where
  toFun := ofWord
  invFun := toWord
  left_inv := toWord_ofWord
  right_inv := ofWord_toWord
  map_add' := ofWord.map_add

instance fieldFintype : Fintype F64 := Fintype.ofEquiv (Word 64) wordEquiv.toEquiv

theorem field_card : Fintype.card F64 = 2 ^ 64 := by
  rw [← Fintype.card_congr wordEquiv.toEquiv, word_card]

/-- Remainder modulo Pi is exactly the 64-bit reduction operation. -/
def reduce (p : (ZMod 2)[X]) : Word 64 := Polynomial.toFn 64 (p %ₘ modulus)

theorem reduce_eq_toWord (p : (ZMod 2)[X]) : reduce p = toWord (AdjoinRoot.mk modulus p) := rfl

/-- Field multiplication on word inputs is an unreduced carry-less product
followed by remainder modulo the implementation's Pi. -/
theorem multiplication_matches (a b : Word 64) :
    wordEquiv.symm (wordEquiv a * wordEquiv b) = reduce (toPoly a * toPoly b) := by
  change toWord (AdjoinRoot.mk modulus (toPoly a) * AdjoinRoot.mk modulus (toPoly b)) = _
  rw [← map_mul]
  rfl

theorem addition_matches (a b : Word 64) :
    wordEquiv.symm (wordEquiv a + wordEquiv b) = a + b := by
  rw [← map_add, wordEquiv.symm_apply_apply]

end ProvenHashes.GF64Implementation
