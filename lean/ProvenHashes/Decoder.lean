import Mathlib

namespace ProvenHashes.Recurrence
open Polynomial
noncomputable section

variable {F : Type*} [Field F]

/-- Coefficients of 1, z and u, respectively, as univariate polynomials in y. -/
@[ext] structure Triple (F : Type*) [Field F] where
  data : F[X]
  seed : F[X]
  shift : F[X]
  deriving DecidableEq

/-- Suffix-product expansion of the recurrence. The list is in processing order. -/
def encode : List (F × F) → Triple F
  | [] => ⟨0, 1, 0⟩
  | (a, b) :: m =>
    let c := encode m
    ⟨C a * c.seed + c.data, (X + C b) * c.seed,
      (X + C b) * c.seed + c.shift⟩

lemma seed_monic (m : List (F × F)) : (encode m).seed.Monic := by
  induction m with
  | nil => exact monic_one
  | cons ab m ih => exact (monic_X_add_C ab.2).mul ih

@[simp] lemma seed_degree (m : List (F × F)) : (encode m).seed.natDegree = m.length := by
  induction m with
  | nil => simp [encode]
  | cons ab m ih =>
    change ((X + C ab.2) * (encode m).seed).natDegree = m.length + 1
    rw [natDegree_mul (monic_X_add_C _).ne_zero (seed_monic _).ne_zero,
      natDegree_X_add_C, ih]
    omega

@[simp] lemma seed_top (m : List (F × F)) : (encode m).seed.coeff m.length = 1 := by
  rw [← seed_degree m, coeff_natDegree]
  exact seed_monic m

lemma data_coeff_zero (m : List (F × F)) (k : ℕ) (hk : m.length ≤ k) :
    (encode m).data.coeff k = 0 := by
  induction m with
  | nil => simp [encode]
  | cons ab m ih =>
    have hs : (encode m).seed.coeff k = 0 := coeff_eq_zero_of_natDegree_lt (by
      rw [seed_degree]
      simpa using hk)
    have hd := ih (by simpa using (Nat.le_of_succ_le hk))
    simp [encode, hs, hd]

lemma shift_coeff_zero (m : List (F × F)) (k : ℕ) (hk : m.length < k) :
    (encode m).shift.coeff k = 0 := by
  induction m with
  | nil => simp [encode]
  | cons ab m ih =>
    change ((encode (ab :: m)).seed + (encode m).shift).coeff k = 0
    rw [coeff_add, coeff_eq_zero_of_natDegree_lt (by simpa using hk),
      ih (by simp only [List.length_cons] at hk; omega), add_zero]

@[simp] lemma shift_top (m : List (F × F)) :
    (encode m).shift.coeff m.length = if m.length = 0 then 0 else 1 := by
  cases m with
  | nil => simp [encode]
  | cons ab m =>
    change ((encode (ab :: m)).seed + (encode m).shift).coeff (m.length + 1) = _
    rw [coeff_add, show (encode (ab :: m)).seed.coeff (m.length + 1) = 1 from seed_top _,
      shift_coeff_zero m _ (by omega)]
    simp

@[simp] lemma head_a (a b : F) (m : List (F × F)) :
    (encode ((a, b) :: m)).data.coeff m.length = a := by
  change (C a * (encode m).seed + (encode m).data).coeff m.length = a
  rw [coeff_add, coeff_C_mul, seed_top, data_coeff_zero m _ le_rfl]
  ring

/-- Recover b₁ from the next-to-leading coefficients, including the n=1,2
edge cases in the paper. The argument is the remaining suffix length. -/
def headB (n : ℕ) (c : Triple F) : F :=
  if n = 0 then c.seed.coeff 0
  else c.seed.coeff n - (c.shift - c.seed).coeff (n - 1) + (if n = 1 then 0 else 1)

@[simp] lemma head_b (a b : F) (m : List (F × F)) :
    headB m.length (encode ((a, b) :: m)) = b := by
  cases m with
  | nil => simp [headB, encode]
  | cons ab m =>
    have hs : (encode ((a, b) :: ab :: m)).shift -
        (encode ((a, b) :: ab :: m)).seed = (encode (ab :: m)).shift := by
      change ((X + C b) * (encode (ab :: m)).seed + (encode (ab :: m)).shift) -
        (X + C b) * (encode (ab :: m)).seed = _
      ring
    simp only [headB, List.length_cons, Nat.add_eq_zero_iff, one_ne_zero,
      and_false, ↓reduceIte, Nat.add_sub_cancel]
    rw [hs]
    change (((X + C b) * (encode (ab :: m)).seed).coeff (m.length + 1) -
      ((encode (ab :: m)).seed + (encode m).shift).coeff m.length + _) = b
    rw [add_mul, coeff_add, coeff_X_mul, coeff_C_mul,
      show (encode (ab :: m)).seed.coeff (m.length + 1) = 1 from seed_top _,
      coeff_add, shift_top]
    by_cases hm : m.length = 0
    · simp [hm]
    · simp [hm]

/-- One explicit synthetic-division step of the paper's decoder. -/
noncomputable def peel (n : ℕ) (c : Triple F) : Triple F := by
  classical
  let b := headB n c
  let a := c.data.coeff n
  let q := c.seed /ₘ (X + C b)
  exact ⟨c.data - C a * q, q, c.shift - c.seed⟩

@[simp] lemma peel_encode (a b : F) (m : List (F × F)) :
    peel m.length (encode ((a, b) :: m)) = encode m := by
  classical
  have hq : (encode ((a, b) :: m)).seed /ₘ (X + C b) = (encode m).seed :=
    mul_divByMonic_cancel_left _ (monic_X_add_C b)
  apply Triple.ext <;> simp only [peel, head_a, head_b, hq]
  · change (C a * (encode m).seed + (encode m).data) - C a * (encode m).seed = _
    ring
  · change ((X + C b) * (encode m).seed + (encode m).shift) -
      (X + C b) * (encode m).seed = _
    ring

noncomputable def decode : ℕ → Triple F → List (F × F)
  | 0, _ => []
  | n + 1, c => (c.data.coeff n, headB n c) :: decode n (peel n c)

/-- Correctness of the explicit coefficient decoder; no search over messages. -/
theorem decode_encode (m : List (F × F)) : decode m.length (encode m) = m := by
  induction m with
  | nil => rfl
  | cons ab m ih =>
    rcases ab with ⟨a, b⟩
    simp only [List.length_cons, decode, head_a, head_b, peel_encode, ih]

/-- The coefficient triple even determines the length, via its monic seed component. -/
theorem encode_injective : Function.Injective (encode (F := F)) := by
  intro m m' h
  have hn : m.length = m'.length := by
    simpa using congrArg (fun c : Triple F => c.seed.natDegree) h
  rw [← decode_encode m, h, hn, decode_encode m']

end
end ProvenHashes.Recurrence
