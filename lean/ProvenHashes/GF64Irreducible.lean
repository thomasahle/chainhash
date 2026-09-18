import ProvenHashes.GF64Certificate

noncomputable section
namespace ProvenHashes.GF64Certificate
open Polynomial

lemma proper_divisor_64 {d : ℕ} (hd : d ≤ 32) (h : d ∣ 64) : d ∣ 32 := by
  interval_cases d <;> norm_num at *

/-- A root of an irreducible factor generates its finite extension. The
certificate fixes the 64th Frobenius power and excludes the 32nd, so the
factor cannot have degree at most 32. -/
theorem no_small_irreducible_factor (g : (ZMod 2)[X])
    (hgi : Irreducible g) (hdiv : g ∣ modulus) : 32 < g.natDegree := by
  letI : Fact (Irreducible g) := ⟨hgi⟩
  letI : CharP (AdjoinRoot g) 2 :=
    charP_of_injective_algebraMap' (ZMod 2) (AdjoinRoot g) 2
  letI : Finite (AdjoinRoot g) := Finite.of_equiv (Fin g.natDegree → ZMod 2)
    (AdjoinRoot.powerBasis hgi.ne_zero).basis.equivFun.symm.toEquiv
  let φ := FiniteField.frobeniusAlgHom (ZMod 2) (AdjoinRoot g)
  let x := AdjoinRoot.root g
  have hx : aeval x modulus = 0 := by
    rw [AdjoinRoot.aeval_eq, AdjoinRoot.mk_eq_zero]
    exact hdiv
  have hφ64 : φ ^ 64 = 1 := by
    apply AdjoinRoot.algHom_ext
    simpa only [φ, AlgHom.coe_pow, FiniteField.coe_frobeniusAlgHom,
      pow_iterate, ZMod.card, AlgHom.one_apply] using root_frobenius64 x hx
  have hdegree : orderOf φ = g.natDegree := by
    rw [FiniteField.orderOf_frobeniusAlgHom, (AdjoinRoot.powerBasis hgi.ne_zero).finrank]
    rfl
  have hd64 : g.natDegree ∣ 64 := hdegree ▸ orderOf_dvd_of_pow_eq_one hφ64
  by_contra hsmall
  have hd32 := proper_divisor_64 (Nat.le_of_not_gt hsmall) hd64
  have hφ32 : φ ^ 32 = 1 := orderOf_dvd_iff_pow_eq_one.mp (hdegree.symm ▸ hd32)
  have hx32 : x ^ (2 ^ 32) = x := by
    have h := DFunLike.congr_fun hφ32 x
    simpa only [φ, AlgHom.coe_pow, FiniteField.coe_frobeniusAlgHom,
      pow_iterate, ZMod.card, AlgHom.one_apply] using h
  exact root_not_frobenius32 x hx hx32

/-- Kernel-checked irreducibility of X^64 + X^4 + X^3 + X + 1. -/
theorem modulus_irreducible : Irreducible modulus := by
  have hn1 : modulus ≠ 1 := by
    intro h
    have hd := modulus_degree
    rw [h, degree_one] at hd
    norm_num at hd
  apply (modulus_monic.irreducible_iff_degree_lt hn1).mpr
  intro q hqdeg hqdiv
  by_contra hunit
  obtain ⟨g, _hg, hgi, hgq⟩ := Polynomial.exists_monic_irreducible_factor q hunit
  have hq0 : q ≠ 0 := by
    intro hq
    rw [hq, zero_dvd_iff] at hqdiv
    exact modulus_monic.ne_zero hqdiv
  have hq32 : q.natDegree ≤ 32 := by
    apply Polynomial.natDegree_le_iff_degree_le.mpr
    simpa only [modulus_natDegree, Nat.reduceDiv] using hqdeg
  have hg32 : g.natDegree ≤ 32 := (Polynomial.natDegree_le_of_dvd hgq hq0).trans hq32
  exact (no_small_irreducible_factor g hgi (hgq.trans hqdiv)).not_ge hg32

end ProvenHashes.GF64Certificate
