import ProvenHashes.Counting
import ProvenHashes.NH

noncomputable section
namespace ProvenHashes
open scoped BigOperators
open Polynomial

/-- NH with independently sampled finite words embedded in an integral domain.
No reduction of the products or sum is performed. -/
def embeddedNH {W R : Type*} [CommRing R] {n : ℕ}
    (e : W → R) (m k : Fin n × Bool → W) : R :=
  nhHash (e ∘ m) (e ∘ k)

lemma sum_mul_embedded_update {I W R : Type*}
    [Fintype I] [DecidableEq I] [CommRing R]
    (e : W → R) (c : I → R) (k : I → W) (i : I) (v : W) :
    (∑ j, c j * e (Function.update k i v j)) =
      c i * e v + ∑ j ∈ Finset.univ.erase i, c j * e (k j) := by
  classical
  rw [← Finset.sum_erase_add _ _ (Finset.mem_univ i)]
  rw [Function.update_self, add_comm]
  congr 1
  apply Finset.sum_congr rfl
  intro j hj
  rw [Function.update_of_ne (Finset.mem_erase.mp hj).1]

/-- Integral-domain NH: every full-width target difference has probability at
most the reciprocal of the number of possible words. -/
theorem embeddedNH_difference_bound {W R : Type*}
    [Fintype W] [Nonempty W] [CommRing R] [IsDomain R] {n : ℕ}
    (e : W → R) (he : Function.Injective e)
    (m m' : Fin n × Bool → W) (hne : m ≠ m') (t : R) :
    uniformProb (fun k => embeddedNH e m k - embeddedNH e m' k = t) ≤
      1 / Fintype.card W := by
  classical
  have hne' : e ∘ m ≠ e ∘ m' := fun h => hne (funext fun j => he (congrFun h j))
  have hc : ∃ j, nhCoefficient (e ∘ m) (e ∘ m') j ≠ 0 := by
    obtain ⟨⟨i, b⟩, hi⟩ := Function.ne_iff.mp hne'
    cases b with
    | false => exact ⟨(i, true), by simpa [nhCoefficient] using sub_ne_zero.mpr hi⟩
    | true => exact ⟨(i, false), by simpa [nhCoefficient] using sub_ne_zero.mpr hi⟩
  obtain ⟨j, hj⟩ := hc
  unfold embeddedNH
  simp_rw [nh_difference]
  apply uniformProb_of_injective_update _ j
  intro k v w hvw
  simp only [Function.comp_apply, sum_mul_embedded_update] at hvw
  exact he (mul_left_cancel₀ hj (add_right_cancel (add_left_cancel hvw)))

namespace Carryless

/-- A word is its vector of bits, in increasing polynomial degree. -/
abbrev Word (w : ℕ) := Fin w → ZMod 2

def toPoly {w : ℕ} (v : Word w) : (ZMod 2)[X] := Polynomial.ofFn w v

theorem toPoly_injective (w : ℕ) : Function.Injective (@toPoly w) :=
  Polynomial.injective_ofFn w

theorem word_card (w : ℕ) : Fintype.card (Word w) = 2 ^ w := by
  simp [Word]

/-- XOR of unreduced carry-less products, with no finite-field quotient. -/
def nh {w n : ℕ} (m k : Fin n × Bool → Word w) : (ZMod 2)[X] :=
  embeddedNH toPoly m k

/-- Full polynomial-output XOR-difference bound, including arbitrary targets. -/
theorem xor_difference_bound {w n : ℕ}
    (m m' : Fin n × Bool → Word w) (hne : m ≠ m') (t : (ZMod 2)[X]) :
    uniformProb (fun k => nh m k + nh m' k = t) ≤ 1 / (2 : ℚ≥0) ^ w := by
  simpa only [nh, sub_eq_add_neg, CharTwo.neg_eq, word_card, Nat.cast_pow,
    Nat.cast_ofNat] using embeddedNH_difference_bound toPoly (toPoly_injective w) m m' hne t

theorem collision_bound {w n : ℕ}
    (m m' : Fin n × Bool → Word w) (hne : m ≠ m') :
    uniformProb (fun k => nh m k = nh m' k) ≤ 1 / (2 : ℚ≥0) ^ w := by
  simpa only [nh, word_card, Nat.cast_pow, Nat.cast_ofNat, sub_eq_zero] using
    embeddedNH_difference_bound toPoly (toPoly_injective w) m m' hne 0

end Carryless
end ProvenHashes
