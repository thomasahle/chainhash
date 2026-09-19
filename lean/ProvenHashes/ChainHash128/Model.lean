import ProvenHashes.ChainHash128.PH
import ProvenHashes.ChainHash128.Horner
import ProvenHashes.Finalizer

/-! The complete ChainHash-128 hash: comb PH blocks, level-2 Horner in `y` with the byte
length as leading coefficient, the integer twist modulo `2^128`, and the structured quintic.
Key spaces, envelopes, and their arithmetic. -/
noncomputable section
namespace ProvenHashes.ChainHash128
open ProvenHashes.ChainHash
open Polynomial
open scoped BigOperators

/-- Ideal key: `kappa[0..31]`, `y`, `tau`, `c0..c4` as independent uniform field words. -/
abbrev IdealKey := ((Slot → F) × F) × (F × (Fin 5 → F))
/-- The key: `s`, `y`, `tau`, `c0..c4`; the PH table is `kappa[a] = s^(a+1)`. -/
abbrev Key := (F × F) × (F × (Fin 5 → F))

def lengthField (n : ℕ) : F := fieldRepr (lengthWord n)

/-- Coefficient `i` is block `p-1-i`, so index equals the Horner exponent. -/
def coefficientsAt (m : Message) (p : ℕ) (k : Slot → F) : Fin p → F :=
  fun i => let t := p - 1 - i.val
           reducedPH (active m t) (data m t) k

def coefficients (m : Message) (k : Slot → F) := coefficientsAt m (blocks m.length) k

def hash (k : IdealKey) (m : Message) : F :=
  chain5 k.2.2 (integerTwist fieldIntegerEquiv k.2.1
    (hornerValue (lengthField m.length) (coefficients m k.1.1) k.1.2))

def expandKey (k : Key) : IdealKey := ((powerKey k.1.1, k.1.2), k.2)
def chainHash (k : Key) (m : Message) : F := hash (expandKey k) m

/-- `d_B(L)`: `1` for `L ≤ 16` (at most 128 bytes), else `min W (2⌈L/32⌉)` with `W = 32`. -/
def degreeBudget (L : ℕ) : ℕ := if L ≤ 16 then 1 else min 32 (2 * ((L + 31) / 32))

/-- Envelope numerators for messages of at most `8L` bytes (`L` counts 64-bit words). -/
def idealKeyNumerator (L : ℕ) : ℕ := blocks (8*L) + 1
/-- `p_B(L) + d_B(L)`. -/
def numerator (L : ℕ) : ℕ := blocks (8*L) + degreeBudget L
/-- Coarse all-length envelope numerator `p + W`. -/
def coarseNumerator (L : ℕ) : ℕ := blocks (8*L) + 32

def idealKeyEpsilon (L : ℕ) : ℚ≥0 := min 1 ((idealKeyNumerator L : ℚ≥0)/2^128)
def epsilon (L : ℕ) : ℚ≥0 := min 1 ((numerator L : ℚ≥0)/2^128)
def coarseEpsilon (L : ℕ) : ℚ≥0 := min 1 ((coarseNumerator L : ℚ≥0)/2^128)

theorem idealKey_card : Fintype.card IdealKey = (2^128)^39 := by
  simp only [IdealKey, Slot, Fintype.card_prod, Fintype.card_fun, Fintype.card_fin,
    Fintype.card_bool, field_card fieldRepr]
  norm_num
-- checkpoint: idealKey_card

theorem key_card : Fintype.card Key = (2^128)^8 := by
  simp only [Key, Fintype.card_prod, Fintype.card_fun, Fintype.card_fin,
    field_card fieldRepr]
  norm_num
-- checkpoint: key_card

theorem lengthField_injective {n m : ℕ} (hn : n < 2^128) (hm : m < 2^128)
    (h : lengthField n = lengthField m) : n = m := by
  exact lengthWord_injective hn hm (fieldRepr.injective h)
-- checkpoint: lengthField_injective

theorem blocks_le_words (L : ℕ) (hL : 0 < L) : blocks (8*L) ≤ L := by
  unfold blocks
  split_ifs <;> omega
-- checkpoint: blocks_le_words

theorem degreeBudget_pos (L : ℕ) : 1 ≤ degreeBudget L := by
  unfold degreeBudget
  split_ifs <;> omega
-- checkpoint: degreeBudget_pos

theorem degreeBudget_le (L : ℕ) : degreeBudget L ≤ 32 := by
  unfold degreeBudget
  split_ifs <;> omega
-- checkpoint: degreeBudget_le

theorem idealKey_envelope_arithmetic (L : ℕ) (hL : 0 < L) : idealKeyNumerator L ≤ 2*L := by
  unfold idealKeyNumerator blocks
  split_ifs <;> omega
-- checkpoint: idealKey_envelope_arithmetic

theorem envelope_arithmetic (L : ℕ) (hL : 0 < L) : numerator L ≤ 2*L := by
  unfold numerator degreeBudget blocks
  split_ifs <;> omega
-- checkpoint: envelope_arithmetic

theorem coarse_envelope_arithmetic (L : ℕ) (hL : 0 < L) : coarseNumerator L ≤ 33*L := by
  unfold coarseNumerator blocks
  split_ifs <;> omega
-- checkpoint: coarse_envelope_arithmetic

/-- The refined envelope is dominated by the coarse one. -/
theorem epsilon_le_coarse (L : ℕ) : epsilon L ≤ coarseEpsilon L := by
  apply min_le_min_left
  apply div_le_div_of_nonneg_right _ (by positivity)
  exact_mod_cast Nat.add_le_add_left (degreeBudget_le L) _
-- checkpoint: epsilon_le_coarse

theorem idealKey_score_ratio (L : ℕ) (hL : 0 < L) :
    idealKeyEpsilon L ≤ (L : ℚ≥0)/2^127 := by
  have h : (idealKeyNumerator L : ℚ≥0) ≤ 2*L := by
    exact_mod_cast idealKey_envelope_arithmetic L hL
  apply (min_le_right _ _).trans
  calc
    _ ≤ (2*(L : ℚ≥0))/2^128 := div_le_div_of_nonneg_right h (by positivity)
    _ = _ := by norm_num; ring
-- checkpoint: idealKey_score_ratio

theorem score_ratio (L : ℕ) (hL : 0 < L) :
    epsilon L ≤ (L : ℚ≥0)/2^127 := by
  have h : (numerator L : ℚ≥0) ≤ 2*L := by
    exact_mod_cast envelope_arithmetic L hL
  apply (min_le_right _ _).trans
  calc
    _ ≤ (2*(L : ℚ≥0))/2^128 := div_le_div_of_nonneg_right h (by positivity)
    _ = _ := by norm_num; ring
-- checkpoint: score_ratio

theorem coarse_score_ratio (L : ℕ) (hL : 0 < L) :
    coarseEpsilon L ≤ 33*(L : ℚ≥0)/2^128 := by
  have h : (coarseNumerator L : ℚ≥0) ≤ 33*L := by
    exact_mod_cast coarse_envelope_arithmetic L hL
  apply (min_le_right _ _).trans
  exact div_le_div_of_nonneg_right h (by positivity)
-- checkpoint: coarse_score_ratio

theorem numerators_at_one : idealKeyNumerator 1 = 2 ∧ numerator 1 = 2 ∧ coarseNumerator 1 = 33 := by
  decide
-- checkpoint: numerators_at_one

theorem score_attained : idealKeyEpsilon 1 = 1/2^127 ∧ epsilon 1 = 1/2^127 ∧
    coarseEpsilon 1 = 33/2^128 := by
  have h2 : ((2 : ℕ) : ℚ≥0)/2^128 = 1/2^127 := by
    rw [div_eq_div_iff (by positivity) (by positivity)]
    norm_num
  refine ⟨?_, ?_, ?_⟩
  · rw [idealKeyEpsilon, numerators_at_one.1, min_eq_right (div_le_one_of_le₀ (by norm_num) (by positivity)), h2]
  · rw [epsilon, numerators_at_one.2.1, min_eq_right (div_le_one_of_le₀ (by norm_num) (by positivity)), h2]
  · rw [coarseEpsilon, numerators_at_one.2.2, min_eq_right (div_le_one_of_le₀ (by norm_num) (by positivity))]
    norm_num
-- checkpoint: score_attained

theorem idealKeyEpsilon_pos (L : ℕ) : 0 < idealKeyEpsilon L := by
  apply lt_min one_pos
  unfold idealKeyNumerator
  positivity
-- checkpoint: idealKeyEpsilon_pos

theorem epsilon_pos (L : ℕ) : 0 < epsilon L := by
  apply lt_min one_pos
  have hp := blocks_pos (8*L)
  unfold numerator
  positivity
-- checkpoint: epsilon_pos

theorem coarseEpsilon_pos (L : ℕ) : 0 < coarseEpsilon L := by
  apply lt_min one_pos
  unfold coarseNumerator
  positivity
-- checkpoint: coarseEpsilon_pos

end ProvenHashes.ChainHash128
