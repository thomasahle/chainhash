import ProvenHashes.CarrylessBlock

noncomputable section
namespace ProvenHashes.Finalizer
open scoped BigOperators

/-- The shipped three-multiplication degree-5 circuit, in code gate order. -/
def circuit {F : Type*} [CommRing F] (c : Fin 5 → F) (v : F) : F :=
  let y := v * v
  let z := (y + c 0) * (v + y + c 1)
  (v + c 2) * (z + c 3) + c 4

/-- The five non-leading coefficients, in increasing degree order. -/
def coefficients {F : Type*} [CommRing F] (c : Fin 5 → F) : Fin 5 → F :=
  ![c 4 + c 2 * (c 0 * c 1 + c 3),
    c 0 * c 1 + c 3 + c 0 * c 2,
    c 0 + c 2 * (c 0 + c 1), c 0 + c 1 + c 2, 1 + c 2]

/-- Explicit inverse to the circuit's coefficient map. Subtraction makes
the decoder valid over every commutative ring, including characteristic two. -/
def decode {F : Type*} [CommRing F] (e : Fin 5 → F) : Fin 5 → F :=
  let c2 := e 4 - 1
  let b := e 3 - c2
  let c0 := e 2 - c2 * b
  let c1 := b - c0
  let c3 := e 1 - c0 * c1 - c0 * c2
  let c4 := e 0 - c2 * (c0 * c1 + c3)
  ![c0, c1, c2, c3, c4]

theorem decode_coefficients {F : Type*} [CommRing F] (c : Fin 5 → F) :
    decode (coefficients c) = c := by
  funext i
  fin_cases i <;> simp [decode, coefficients]
  all_goals ring

theorem coefficients_decode {F : Type*} [CommRing F] (e : Fin 5 → F) :
    coefficients (decode e) = e := by
  funext i
  fin_cases i <;> simp [decode, coefficients]
  all_goals ring

def coefficientEquiv (F : Type*) [CommRing F] : (Fin 5 → F) ≃ (Fin 5 → F) where
  toFun := coefficients
  invFun := decode
  left_inv := decode_coefficients
  right_inv := coefficients_decode

def monicEval {F : Type*} [CommRing F] (e : Fin 5 → F) (v : F) : F :=
  v ^ 5 + ∑ i, e i * v ^ i.val

theorem circuit_eq_monicEval {F : Type*} [CommRing F] (c : Fin 5 → F) (v : F) :
    circuit c v = monicEval (coefficients c) v := by
  simp [circuit, monicEval, coefficients, Fin.sum_univ_succ]
  ring

lemma monicEval_difference {F : Type*} [CommRing F] (e : Fin 5 → F) (v w : F) :
    monicEval e v - monicEval e w =
      (v ^ 5 - w ^ 5) + ∑ i, (v ^ i.val - w ^ i.val) * e i := by
  unfold monicEval
  simp_rw [sub_mul, Finset.sum_sub_distrib]
  have hv : (∑ i : Fin 5, e i * v ^ i.val) = ∑ i : Fin 5, v ^ i.val * e i := by
    apply Finset.sum_congr rfl
    intro i _
    ring
  have hw : (∑ i : Fin 5, e i * w ^ i.val) = ∑ i : Fin 5, w ^ i.val * e i := by
    apply Finset.sum_congr rfl
    intro i _
    ring
  rw [hv, hw]
  ring

/-- Exact difference-universality of the concrete degree-5 circuit. -/
theorem difference_uniform {F : Type*} [Field F] [Fintype F]
    (v w : F) (hvw : v ≠ w) (t : F) :
    uniformProb (fun c : Fin 5 → F => circuit c v - circuit c w = t) =
      1 / Fintype.card F := by
  simp_rw [circuit_eq_monicEval]
  change uniformProb (fun c =>
    monicEval (coefficientEquiv F c) v - monicEval (coefficientEquiv F c) w = t) = _
  rw [uniformProb_equiv (coefficientEquiv F) (fun e => monicEval e v - monicEval e w = t)]
  simp_rw [monicEval_difference]
  apply affine_sum_uniform
  exact ⟨1, by simpa using sub_ne_zero.mpr hvw⟩

theorem collision_exact {F : Type*} [Field F] [Fintype F]
    (v w : F) (hvw : v ≠ w) :
    uniformProb (fun c : Fin 5 → F => circuit c v = circuit c w) =
      1 / Fintype.card F := by
  simpa only [sub_eq_zero] using difference_uniform v w hvw 0

/-- The twist is addition in ZMod(2^64), transported through the word
representation. It is integer addition with carries, not field addition. -/
def twist {F : Type*} (word : F ≃ ZMod (2 ^ 64)) (τ : ZMod (2 ^ 64)) (v : F) : F :=
  word.symm (word v + τ)

theorem twist_bijective {F : Type*} (word : F ≃ ZMod (2 ^ 64)) (τ : ZMod (2 ^ 64)) :
    Function.Bijective (twist word τ) := by
  constructor
  · intro v w h
    exact word.injective (add_right_cancel (word.symm.injective h))
  · intro v
    refine ⟨word.symm (word v - τ), ?_⟩
    unfold twist
    rw [word.apply_symm_apply, sub_add_cancel, word.symm_apply_apply]

theorem twisted_collision_exact {F : Type*} [Field F] [Fintype F]
    (word : F ≃ ZMod (2 ^ 64)) (τ : ZMod (2 ^ 64)) (v w : F) (hvw : v ≠ w) :
    uniformProb (fun c : Fin 5 → F => circuit c (twist word τ v) =
      circuit c (twist word τ w)) = 1 / Fintype.card F :=
  collision_exact _ _ ((twist_bijective word τ).1.ne hvw)

/-- The twist key is also sampled independently and uniformly. -/
theorem keyed_twisted_collision_exact {F : Type*} [Field F] [Fintype F]
    (word : F ≃ ZMod (2 ^ 64)) (v w : F) (hvw : v ≠ w) :
    uniformProb (fun k : ZMod (2 ^ 64) × (Fin 5 → F) =>
      circuit k.2 (twist word k.1 v) = circuit k.2 (twist word k.1 w)) =
      1 / Fintype.card F := by
  rw [uniformProb_prod]
  simp_rw [twisted_collision_exact word _ v w hvw]
  simp

end ProvenHashes.Finalizer
