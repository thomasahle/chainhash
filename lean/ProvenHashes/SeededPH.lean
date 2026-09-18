import ProvenHashes.ConcreteChainHash

/-! The field-power PH schedule, with the reference's strided pairing.
Only the reduction of the whole raw polynomial is used. -/
noncomputable section
namespace ProvenHashes.ChainHash.ModelA
open Polynomial
open scoped BigOperators

abbrev Slot := Fin 16 × Bool

def exponent (j : Slot) : ℕ := (pairPosition j).val + 1
def partner (j : Slot) : Slot := (j.1, !j.2)

def powerKey {F : Type*} [Monoid F] (s : F) (j : Slot) : F := s ^ exponent j

def pairPoly {F : Type*} [CommRing F] (m : Slot → F) (i : Fin 16) : F[X] :=
  (X ^ exponent (i, false) + C (m (i, false))) *
    (X ^ exponent (i, true) + C (m (i, true)))

def phPoly {F : Type*} [CommRing F] (a : Finset (Fin 16)) (m : Slot → F) : F[X] :=
  ∑ i ∈ a, pairPoly m i

def ph {F : Type*} [CommRing F] (a : Finset (Fin 16)) (m : Slot → F) (s : F) : F :=
  ∑ i ∈ a, (m (i, false) + powerKey s (i, false)) *
    (m (i, true) + powerKey s (i, true))

theorem eval_phPoly {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m : Slot → F) (s : F) : (phPoly a m).eval s = ph a m s := by
  simp [phPoly, pairPoly, ph, powerKey, Polynomial.eval_finset_sum, add_comm]
-- checkpoint: eval_phPoly

theorem partnerExponent_injective : Function.Injective (fun j => exponent (partner j)) := by
  intro j k h
  have hp : pairPosition (partner j) = pairPosition (partner k) :=
    Fin.ext (Nat.add_right_cancel h)
  have he := pairPositionEquiv.injective hp
  rcases j with ⟨i, b⟩
  rcases k with ⟨i', b'⟩
  simpa [partner] using congrArg partner he
-- checkpoint: partnerExponent_injective

def constantDiff {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m m' : Slot → F) (t : F) : F :=
  (∑ i ∈ a, (m (i, false) * m (i, true) - m' (i, false) * m' (i, true))) - t

def differencePoly {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m m' : Slot → F) (t : F) : F[X] :=
  C (constantDiff a m m' t) +
    ∑ j : Slot, if j.1 ∈ a then monomial (exponent (partner j)) (m j - m' j) else 0

theorem phPoly_difference {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m m' : Slot → F) (t : F) :
    phPoly a m - phPoly a m' - C t = differencePoly a m m' t := by
  classical
  simp only [phPoly, differencePoly, constantDiff, map_sub, map_sum,
    Fintype.sum_prod_type, Fintype.sum_bool, partner, Bool.not_false, Bool.not_true,
    Finset.sum_ite_irrel, Finset.sum_const_zero]
  rw [Finset.sum_ite_mem, ← Finset.sum_sub_distrib, ← Finset.sum_add_distrib]
  congr 1
  apply Finset.sum_congr rfl
  intro i hi
  simp only [pairPoly, ← C_mul_X_pow_eq_monomial, map_sub, map_mul]
  ring
-- checkpoint: phPoly_difference

end ProvenHashes.ChainHash.ModelA
