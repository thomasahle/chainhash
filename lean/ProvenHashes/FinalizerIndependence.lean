import ProvenHashes.Finalizer
import Mathlib.LinearAlgebra.Lagrange

noncomputable section
namespace ProvenHashes.ChainHash
open Polynomial
open scoped BigOperators

def quinticValues {F : Type*} [Field F] [DecidableEq F] (v e : Fin 5 → F) : Fin 5 → F :=
  fun i => v i ^ 5 + Polynomial.eval (v i) (Polynomial.ofFn 5 e)

/-- Explicit interpolation decoder for five distinct finalizer inputs. -/
def decodeValues {F : Type*} [Field F] [DecidableEq F] (v r : Fin 5 → F) : Fin 5 → F :=
  Polynomial.toFn 5 (Lagrange.interpolate Finset.univ v (fun i => r i - v i ^ 5))

theorem decode_quinticValues {F : Type*} [Field F] [DecidableEq F]
    (v : Fin 5 → F) (hv : Function.Injective v) (e : Fin 5 → F) :
    decodeValues v (quinticValues v e) = e := by
  have hi : Set.InjOn v (Finset.univ : Finset (Fin 5)) := hv.injOn
  have hp : Polynomial.ofFn 5 e = Lagrange.interpolate Finset.univ v
      (fun i => quinticValues v e i - v i ^ 5) := by
    apply Lagrange.eq_interpolate_of_eval_eq _ hi
    · simpa using Polynomial.ofFn_degree_lt e
    · intro i _; simp [quinticValues]
  unfold decodeValues
  rw [← hp, Polynomial.toFn_comp_ofFn_eq_id]

theorem quinticValues_decode {F : Type*} [Field F] [DecidableEq F]
    (v : Fin 5 → F) (hv : Function.Injective v) (r : Fin 5 → F) :
    quinticValues v (decodeValues v r) = r := by
  have hi : Set.InjOn v (Finset.univ : Finset (Fin 5)) := hv.injOn
  let p := Lagrange.interpolate Finset.univ v (fun i => r i - v i ^ 5)
  have hdeg : p.natDegree < 5 := by
    by_cases hp : p = 0
    · simp [hp]
    · apply (Polynomial.natDegree_lt_iff_degree_lt hp).mpr
      simpa only [Finset.card_univ, Fintype.card_fin] using
        Lagrange.degree_interpolate_lt (s := Finset.univ) (v := v)
          (fun i => r i - v i ^ 5) hi
  funext i
  change v i ^ 5 + Polynomial.eval (v i) (Polynomial.ofFn 5 (Polynomial.toFn 5 p)) = r i
  rw [Polynomial.ofFn_comp_toFn_eq_id_of_natDegree_lt hdeg]
  have he : Polynomial.eval (v i) p = r i - v i ^ 5 :=
    Lagrange.eval_interpolate_at_node _ hi (Finset.mem_univ i)
  rw [he]
  ring

def quinticValuesEquiv {F : Type*} [Field F] [DecidableEq F]
    (v : Fin 5 → F) (hv : Function.Injective v) : (Fin 5 → F) ≃ (Fin 5 → F) where
  toFun := quinticValues v
  invFun := decodeValues v
  left_inv := decode_quinticValues v hv
  right_inv := quinticValues_decode v hv

theorem chain5_values {F : Type*} [Field F] [DecidableEq F] (c v : Fin 5 → F) :
    (fun i => chain5 c (v i)) = quinticValues v (quinticCoefficients c) := by
  funext i
  rw [chain5_expansion]
  unfold quinticValues
  rw [Polynomial.ofFn_eq_sum_monomial, Polynomial.eval_finset_sum]
  simp only [Polynomial.eval_monomial]

/-- Every prescribed five-output tuple has exactly the independent uniform probability.
The inverse used in the proof is Lagrange interpolation followed by the unit-pivot decoder. -/
theorem chain5_fivewise_exact {F : Type*} [Field F] [Fintype F]
    (v : Fin 5 → F) (hv : Function.Injective v) (r : Fin 5 → F) :
    uniformProb (fun c : Fin 5 → F => (fun i => chain5 c (v i)) = r) =
      1 / (Fintype.card F : ℚ≥0) ^ 5 := by
  classical
  let e := (quinticCoefficientEquiv F).trans (quinticValuesEquiv v hv)
  have he : (fun c : Fin 5 → F => (fun i => chain5 c (v i)) = r) = (fun c => e c = r) := by
    funext c
    rw [chain5_values]
    rfl
  rw [he, uniformProb_equiv e (fun x => x = r)]
  have hp := uniformProb_fst (A := Fin 5 → F) (B := Unit) r
  rw [uniformProb_prod_fst (J := Unit) (fun x : Fin 5 → F => x = r)] at hp
  simpa only [Fintype.card_fun, Fintype.card_fin, Nat.cast_pow] using hp

theorem chain5_twisted_fivewise_exact {F : Type*} [Field F] [Fintype F]
    (ψ : F → F) (hψ : Function.Injective ψ) (v : Fin 5 → F)
    (hv : Function.Injective v) (r : Fin 5 → F) :
    uniformProb (fun c : Fin 5 → F => (fun i => chain5 c (ψ (v i))) = r) =
      1 / (Fintype.card F : ℚ≥0) ^ 5 :=
  chain5_fivewise_exact (ψ ∘ v) (hψ.comp hv) r

end ProvenHashes.ChainHash
