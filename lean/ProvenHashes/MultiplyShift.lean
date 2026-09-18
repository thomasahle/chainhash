import ProvenHashes.Probability

namespace ProvenHashes

/-- Exactly the odd 2w-bit multipliers, each occurring once. -/
abbrev OddMultiplier (w : ℕ) := {a : Fin (2 ^ (2 * w)) // Odd a.val}

/-- Natural division by 2^(2w-ℓ) is logical right shift by that many bits. -/
def multiplyShift (w ℓ : ℕ) (a : OddMultiplier w) (x : Fin (2 ^ w)) : ℕ :=
  (a.val.val * x.val % 2 ^ (2 * w)) / 2 ^ (2 * w - ℓ)

/-- The requested statement, recorded as a proposition ONLY; it is not proved. -/
def MultiplyShiftBound : Prop :=
  ∀ (w ℓ : ℕ), 0 < w → ℓ ≤ 2 * w →
    ∀ (x y : Fin (2 ^ w)), x ≠ y →
      uniformProb (fun a : OddMultiplier w => multiplyShift w ℓ a x = multiplyShift w ℓ a y) ≤
        2 / (2 : ℚ≥0) ^ ℓ

/-- A deterministic necessary condition for landing in the same shifted bucket. -/
lemma same_bucket_close {r s B : ℕ} (hB : 0 < B) (h : r / B = s / B) :
    r < s + B ∧ s < r + B := by
  have hr := Nat.mod_lt r hB
  have hs := Nat.mod_lt s hB
  have er := Nat.mod_add_div r B
  have es := Nat.mod_add_div s B
  have he : B * (r / B) = B * (s / B) := congrArg (fun q => B * q) h
  omega

/-- This compiled reduction does not assert a collision probability. -/
theorem multiplyShift_collision_close (w ℓ : ℕ) (a : OddMultiplier w)
    (x y : Fin (2 ^ w)) (h : multiplyShift w ℓ a x = multiplyShift w ℓ a y) :
    a.val.val * x.val % 2 ^ (2 * w) <
        a.val.val * y.val % 2 ^ (2 * w) + 2 ^ (2 * w - ℓ) ∧
    a.val.val * y.val % 2 ^ (2 * w) <
        a.val.val * x.val % 2 ^ (2 * w) + 2 ^ (2 * w - ℓ) :=
  same_bucket_close (by positivity) h

/-- The bijection step used in the standard multiply-shift argument. -/
theorem odd_mul_mod_injective (N a : ℕ) (ha : Odd a) :
    Function.Injective (fun x : Fin (2 ^ N) => a * x.val % 2 ^ N) := by
  intro x y h
  have hc : Nat.Coprime a (2 ^ N) := ha.coprime_two_right.pow_right N
  have he : x.val ≡ y.val [MOD 2 ^ N] := Nat.ModEq.cancel_left_of_coprime hc.symm h
  apply Fin.ext
  simpa only [Nat.ModEq, Nat.mod_eq_of_lt x.isLt, Nat.mod_eq_of_lt y.isLt] using he

end ProvenHashes
