import ProvenHashes.PiecesFinalizer

noncomputable section
namespace ProvenHashes
open scoped BigOperators

/-- A surjective homomorphism sends a uniform finite group element to a
uniform element; fibres are translates of the kernel. -/
theorem uniformProb_surjective_addHom {A B : Type*}
    [AddGroup A] [AddGroup B] [Fintype A] [Fintype B]
    (f : A →+ B) (hf : Function.Surjective f) (t : B) :
    uniformProb (fun a => f a = t) = 1 / Fintype.card B := by
  classical
  have hc (b : B) : Fintype.card {a : A // f a = b} = Fintype.card f.ker :=
    Fintype.card_congr (AddMonoidHom.fiberEquivKerOfSurjective hf b)
  have hall : Fintype.card A = Fintype.card B * Fintype.card f.ker := by
    calc
      _ = Fintype.card (Σ b : B, {a : A // f a = b}) :=
        Fintype.card_congr (Equiv.sigmaFiberEquiv f).symm
      _ = ∑ b : B, Fintype.card {a : A // f a = b} := Fintype.card_sigma
      _ = _ := by simp_rw [hc]; simp
  have hker : (Fintype.card f.ker : ℚ≥0) ≠ 0 := by
    exact_mod_cast Fintype.card_ne_zero
  unfold uniformProb
  rw [← Fintype.card_subtype (fun a => f a = t), hc, hall, Nat.cast_mul]
  field_simp

namespace Finalizer
open Polynomial

def evalHom {F : Type*} [Field F] {t : ℕ} (v : Fin t → F) :
    (Fin 5 → F) →+ (Fin t → F) where
  toFun e := fun j => ∑ i, e i * v j ^ i.val
  map_zero' := by ext j; simp
  map_add' e e' := by ext j; simp [add_mul, Finset.sum_add_distrib]

/-- Interpolation at at most five distinct points fits in the five random
coefficients below the fixed monic leading term. -/
theorem evalHom_surjective {F : Type*} [Field F] {t : ℕ} (ht : t ≤ 5)
    (v : Fin t → F) (hv : Function.Injective v) : Function.Surjective (evalHom v) := by
  classical
  intro r
  let p := Lagrange.interpolate Finset.univ v r
  have hp : p.degree < 5 := by
    have h := Lagrange.degree_interpolate_lt (s := Finset.univ) r hv.injOn
    apply lt_of_lt_of_le h
    simpa using (show (t : WithBot ℕ) ≤ (5 : WithBot ℕ) from by exact_mod_cast ht)
  have hn : p.natDegree < 5 := by
    by_cases h : p = 0
    · simp [h]
    · exact (Polynomial.natDegree_lt_iff_degree_lt h).mpr hp
  refine ⟨Polynomial.toFn 5 p, ?_⟩
  funext j
  change polynomialHash (Polynomial.toFn 5 p) (v j) = r j
  rw [polynomialHash_eq_eval, Polynomial.ofFn_comp_toFn_eq_id_of_natDegree_lt hn]
  exact Lagrange.eval_interpolate_at_node r hv.injOn (Finset.mem_univ j)

/-- The exact five-wise independence statement, expressed by the probability
of every prescribed output vector on any `t ≤ 5` distinct inputs. -/
theorem kwise_uniform {F : Type*} [Field F] [Fintype F] {t : ℕ} (ht : t ≤ 5)
    (v : Fin t → F) (hv : Function.Injective v) (r : Fin t → F) :
    uniformProb (fun c : Fin 5 → F => (fun j => circuit c (v j)) = r) =
      1 / (Fintype.card F : ℚ≥0) ^ t := by
  classical
  simp_rw [circuit_eq_monicEval]
  change uniformProb (fun c => (fun j => monicEval (coefficientEquiv F c) (v j)) = r) = _
  rw [uniformProb_equiv (coefficientEquiv F) (fun e => (fun j => monicEval e (v j)) = r)]
  have he (e : Fin 5 → F) : ((fun j => monicEval e (v j)) = r) ↔
      evalHom v e = fun j => r j - v j ^ 5 := by
    simp only [funext_iff, monicEval, evalHom, AddMonoidHom.coe_mk, ZeroHom.coe_mk]
    exact forall_congr' fun j => by constructor <;> intro h <;> linear_combination h
  simp_rw [he]
  rw [uniformProb_surjective_addHom (evalHom v) (evalHom_surjective ht v hv)]
  simp

theorem twisted_kwise_uniform {F : Type*} [Field F] [Fintype F] {t : ℕ}
    (ht : t ≤ 5) (word : F ≃ ZMod (2 ^ 64)) (τ : ZMod (2 ^ 64))
    (v : Fin t → F) (hv : Function.Injective v) (r : Fin t → F) :
    uniformProb (fun c : Fin 5 → F => (fun j => circuit c (twist word τ (v j))) = r) =
      1 / (Fintype.card F : ℚ≥0) ^ t :=
  kwise_uniform ht _ ((twist_bijective word τ).1.comp hv) r

end Finalizer
end ProvenHashes
