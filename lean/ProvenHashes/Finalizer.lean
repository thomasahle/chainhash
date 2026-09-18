import ProvenHashes.NH
import ProvenHashes.Composition

namespace ProvenHashes.ChainHash
open scoped BigOperators

/-- The three multiplications in `chainhash_ref::chain<5>`, in gate order. -/
def chain5 {F : Type*} [CommRing F] (c : Fin 5 → F) (v : F) : F :=
  let y := v * v
  let z := (y + c 0) * (v + y + c 1)
  (v + c 2) * (z + c 3) + c 4

/-- Low-to-high coefficients of the monic quintic. -/
def coefficients {F : Type*} [CommRing F] (c : Fin 5 → F) : Fin 5 → F :=
  ![c 4 + c 2 * (c 0 * c 1 + c 3),
    c 0 * c 1 + c 3 + c 0 * c 2,
    c 0 + c 2 * (c 0 + c 1),
    c 0 + c 1 + c 2,
    1 + c 2]

/-- Explicit descending unit-pivot decoder. In characteristic two subtraction is XOR. -/
def decodeCoefficients {F : Type*} [CommRing F] (e : Fin 5 → F) : Fin 5 → F :=
  let c2 := e 4 - 1
  let b := e 3 - c2
  let c0 := e 2 - c2 * b
  let c1 := b - c0
  let c3 := e 1 - c0 * c1 - c0 * c2
  let c4 := e 0 - c2 * (c0 * c1 + c3)
  ![c0, c1, c2, c3, c4]

theorem decode_coefficients {F : Type*} [CommRing F] (c : Fin 5 → F) :
    decodeCoefficients (coefficients c) = c := by
  funext i
  fin_cases i <;> simp [decodeCoefficients, coefficients]
  all_goals ring

theorem coefficients_decode {F : Type*} [CommRing F] (e : Fin 5 → F) :
    coefficients (decodeCoefficients e) = e := by
  funext i
  fin_cases i <;> simp [decodeCoefficients, coefficients]
  all_goals ring

def coefficientEquiv (F : Type*) [CommRing F] : (Fin 5 → F) ≃ (Fin 5 → F) where
  toFun := coefficients
  invFun := decodeCoefficients
  left_inv := decode_coefficients
  right_inv := coefficients_decode

theorem chain5_expansion {F : Type*} [CommRing F] (c : Fin 5 → F) (v : F) :
    chain5 c v = v ^ 5 + ∑ i : Fin 5, coefficients c i * v ^ (i : ℕ) := by
  simp [chain5, coefficients, Fin.sum_univ_succ]
  ring

theorem chain5_collision_exact {F : Type*} [Field F] [Fintype F]
    (v w : F) (hne : v ≠ w) :
    uniformProb (fun c : Fin 5 → F => chain5 c v = chain5 c w) =
      1 / Fintype.card F := by
  have he (c : Fin 5 → F) :
      chain5 c v - chain5 c w =
        v ^ 5 - w ^ 5 + ∑ i : Fin 5, (v ^ (i : ℕ) - w ^ (i : ℕ)) * coefficients c i := by
    rw [chain5_expansion, chain5_expansion]
    simp only [Finset.sum_sub_distrib, sub_mul]
    simp_rw [mul_comm _ (coefficients c _)]
    ring
  have hp : (fun c : Fin 5 → F => chain5 c v = chain5 c w) =
      (fun c => v ^ 5 - w ^ 5 + ∑ i : Fin 5,
        (v ^ (i : ℕ) - w ^ (i : ℕ)) * coefficientEquiv F c i = 0) := by
    funext c
    exact propext ((sub_eq_zero.symm).trans (by rw [he]; rfl))
  rw [hp]
  calc
    _ = uniformProb (fun e : Fin 5 → F => v ^ 5 - w ^ 5 +
        ∑ i : Fin 5, (v ^ (i : ℕ) - w ^ (i : ℕ)) * e i = 0) :=
      uniformProb_equiv (coefficientEquiv F) _
    _ = _ := affine_sum_uniform _ _ ⟨1, by simpa using sub_ne_zero.mpr hne⟩ _

/-- Input relabelling costs no collision probability, for each fixed twist key. -/
theorem chain5_twisted_collision_exact {F : Type*} [Field F] [Fintype F]
    (ψ : F → F) (hψ : Function.Injective ψ) (v w : F) (hne : v ≠ w) :
    uniformProb (fun c : Fin 5 → F => chain5 c (ψ v) = chain5 c (ψ w)) =
      1 / Fintype.card F :=
  chain5_collision_exact _ _ (fun h => hne (hψ h))

/-- Integer addition modulo 2^64, transported by an explicit word representation. -/
def integerTwist {F : Type*} (word : F ≃ ZMod (2 ^ 64)) (τ v : F) : F :=
  word.symm (word v + word τ)

theorem integerTwist_bijective {F : Type*} (word : F ≃ ZMod (2 ^ 64)) (τ : F) :
    Function.Bijective (integerTwist word τ) := by
  constructor
  · intro v w h
    exact word.injective (add_right_cancel (word.symm.injective h))
  · intro v
    refine ⟨word.symm (word v - word τ), ?_⟩
    unfold integerTwist
    rw [Equiv.apply_symm_apply, sub_add_cancel, Equiv.symm_apply_apply]

end ProvenHashes.ChainHash
