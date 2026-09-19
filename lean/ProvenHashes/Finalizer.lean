import ProvenHashes.NH
import ProvenHashes.Composition

namespace ProvenHashes.ChainHash
open scoped BigOperators

/-- The three multiplications in `chainhash_ref::chain<5>`, in gate order. -/
def chain5 {F : Type*} [CommRing F] (c : Fin 5 → F) (v : F) : F :=
  let y := v * v
  let z := (y + c 0) * (v + y + c 1)
  (v + c 2) * (z + c 3) + c 4

/-- Low-to-high quinticCoefficients of the monic quintic. -/
def quinticCoefficients {F : Type*} [CommRing F] (c : Fin 5 → F) : Fin 5 → F :=
  ![c 4 + c 2 * (c 0 * c 1 + c 3),
    c 0 * c 1 + c 3 + c 0 * c 2,
    c 0 + c 2 * (c 0 + c 1),
    c 0 + c 1 + c 2,
    1 + c 2]

/-- Explicit descending unit-pivot decoder. In characteristic two subtraction is XOR. -/
def decodeQuinticCoefficients {F : Type*} [CommRing F] (e : Fin 5 → F) : Fin 5 → F :=
  let c2 := e 4 - 1
  let b := e 3 - c2
  let c0 := e 2 - c2 * b
  let c1 := b - c0
  let c3 := e 1 - c0 * c1 - c0 * c2
  let c4 := e 0 - c2 * (c0 * c1 + c3)
  ![c0, c1, c2, c3, c4]

theorem decode_quinticCoefficients {F : Type*} [CommRing F] (c : Fin 5 → F) :
    decodeQuinticCoefficients (quinticCoefficients c) = c := by
  funext i
  fin_cases i <;> simp [decodeQuinticCoefficients, quinticCoefficients]
  all_goals ring

theorem quinticCoefficients_decode {F : Type*} [CommRing F] (e : Fin 5 → F) :
    quinticCoefficients (decodeQuinticCoefficients e) = e := by
  funext i
  fin_cases i <;> simp [decodeQuinticCoefficients, quinticCoefficients]
  all_goals ring

def quinticCoefficientEquiv (F : Type*) [CommRing F] : (Fin 5 → F) ≃ (Fin 5 → F) where
  toFun := quinticCoefficients
  invFun := decodeQuinticCoefficients
  left_inv := decode_quinticCoefficients
  right_inv := quinticCoefficients_decode

theorem chain5_expansion {F : Type*} [CommRing F] (c : Fin 5 → F) (v : F) :
    chain5 c v = v ^ 5 + ∑ i : Fin 5, quinticCoefficients c i * v ^ (i : ℕ) := by
  simp [chain5, quinticCoefficients, Fin.sum_univ_succ]
  ring

theorem chain5_collision_exact {F : Type*} [Field F] [Fintype F]
    (v w : F) (hne : v ≠ w) :
    uniformProb (fun c : Fin 5 → F => chain5 c v = chain5 c w) =
      1 / Fintype.card F := by
  have he (c : Fin 5 → F) :
      chain5 c v - chain5 c w =
        v ^ 5 - w ^ 5 + ∑ i : Fin 5, (v ^ (i : ℕ) - w ^ (i : ℕ)) * quinticCoefficients c i := by
    rw [chain5_expansion, chain5_expansion]
    simp only [Finset.sum_sub_distrib, sub_mul]
    simp_rw [mul_comm _ (quinticCoefficients c _)]
    ring
  have hp : (fun c : Fin 5 → F => chain5 c v = chain5 c w) =
      (fun c => v ^ 5 - w ^ 5 + ∑ i : Fin 5,
        (v ^ (i : ℕ) - w ^ (i : ℕ)) * quinticCoefficientEquiv F c i = 0) := by
    funext c
    exact propext ((sub_eq_zero.symm).trans (by rw [he]; rfl))
  rw [hp]
  calc
    _ = uniformProb (fun e : Fin 5 → F => v ^ 5 - w ^ 5 +
        ∑ i : Fin 5, (v ^ (i : ℕ) - w ^ (i : ℕ)) * e i = 0) :=
      uniformProb_equiv (quinticCoefficientEquiv F) _
    _ = _ := affine_sum_uniform _ _ ⟨1, by simpa using sub_ne_zero.mpr hne⟩ _

/-- Input relabelling costs no collision probability, for each fixed twist key. -/
theorem chain5_twisted_collision_exact {F : Type*} [Field F] [Fintype F]
    (ψ : F → F) (hψ : Function.Injective ψ) (v w : F) (hne : v ≠ w) :
    uniformProb (fun c : Fin 5 → F => chain5 c (ψ v) = chain5 c (ψ w)) =
      1 / Fintype.card F :=
  chain5_collision_exact _ _ (fun h => hne (hψ h))

/-- Integer addition modulo `N` (`2^64` for ChainHash, `2^128` for
ChainHash-128), transported by an explicit word representation. -/
def integerTwist {F : Type*} {N : ℕ} (word : F ≃ ZMod N) (τ v : F) : F :=
  word.symm (word v + word τ)

theorem integerTwist_bijective {F : Type*} {N : ℕ} (word : F ≃ ZMod N) (τ : F) :
    Function.Bijective (integerTwist word τ) := by
  constructor
  · intro v w h
    exact word.injective (add_right_cancel (word.symm.injective h))
  · intro v
    refine ⟨word.symm (word v - word τ), ?_⟩
    unfold integerTwist
    rw [Equiv.apply_symm_apply, sub_add_cancel, Equiv.symm_apply_apply]


/-- The last stage: an integer twist by an independent word followed by the quintic with
five independent coefficients collides on distinct inputs with probability exactly `1/q`. -/
theorem finalStage_collision_bound {F : Type*} [Field F] [Fintype F] {N : ℕ}
    (word : F ≃ ZMod N) (v v' : F) (hne : v ≠ v') :
    uniformProb (fun j : F × (Fin 5 → F) =>
      chain5 j.2 (integerTwist word j.1 v) = chain5 j.2 (integerTwist word j.1 v')) ≤
        1 / Fintype.card F := by
  apply uniformProb_prod_le
  intro τ
  exact (chain5_twisted_collision_exact _ (integerTwist_bijective word τ).1 v v' hne).le

end ProvenHashes.ChainHash
