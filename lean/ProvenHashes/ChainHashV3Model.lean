import ProvenHashes.ChainHashV3PH
import ProvenHashes.ChainHashV3Horner

noncomputable section
namespace ProvenHashes.ChainHash.V3
open Polynomial
open scoped BigOperators

abbrev IdealKey := ((Slot → F) × F) × (F × (Fin 5 → F))
abbrev ModelAKey := (F × F) × (F × (Fin 5 → F))

def lengthField (n : ℕ) : F := fieldRepr (lengthWord n)

def coefficientsAt (m : Message) (p : ℕ) (k : Slot → F) : Fin p → F :=
  fun i => let t := p - 1 - i.val
           reducedPH (active m t) (data m t) k

def coefficients (m : Message) (k : Slot → F) := coefficientsAt m (blocks m.length) k

def hash (k : IdealKey) (m : Message) : F :=
  chain5 k.2.2 (integerTwist fieldIntegerEquiv k.2.1
    (hornerValue (lengthField m.length) (coefficients m k.1.1) k.1.2))

def expandKey (k : ModelAKey) : IdealKey := ((powerKey k.1.1, k.1.2), k.2)
def modelAHash (k : ModelAKey) (m : Message) : F := hash (expandKey k) m

def degreeBudget (L : ℕ) : ℕ :=
  if L=0 then 0 else if L=1 then 1 else if L≤8 then 2 else if L≤16 then 4 else
    min 32 (4*((L-1)/16) + if (L-1)%16=0 then 2 else 4)

def paperEpsilon (L : ℕ) : ℚ≥0 := ((blocks (8*L)+1 : ℕ) : ℚ≥0)/2^64
def modelAEpsilon (L : ℕ) : ℚ≥0 := ((degreeBudget L+blocks (8*L) : ℕ) : ℚ≥0)/2^64

theorem idealKey_card : Fintype.card IdealKey = (2^64)^39 := by
  simp only [IdealKey, Slot, Fintype.card_prod, Fintype.card_fun, Fintype.card_fin,
    Fintype.card_bool, field_card fieldRepr]
  norm_num
-- checkpoint: idealKey_card

theorem modelAKey_card : Fintype.card ModelAKey = (2^64)^8 := by
  simp only [ModelAKey, Fintype.card_prod, Fintype.card_fun, Fintype.card_fin,
    field_card fieldRepr]
  norm_num
-- checkpoint: modelAKey_card

theorem lengthField_injective {n m : ℕ} (hn : n < 2^64) (hm : m < 2^64)
    (h : lengthField n = lengthField m) : n = m := by
  exact lengthWord_injective hn hm (fieldRepr.injective h)
-- checkpoint: lengthField_injective

theorem paper_envelope_arithmetic (L : ℕ) (hL : 0 < L) : blocks (8*L)+1 ≤ 2*L := by
  unfold blocks
  split_ifs <;> omega
-- checkpoint: paper_envelope_arithmetic

theorem modelA_envelope_arithmetic (L : ℕ) (hL : 0 < L) :
    degreeBudget L + blocks (8*L) ≤ 2*L := by
  unfold degreeBudget blocks
  split_ifs <;> omega
-- checkpoint: modelA_envelope_arithmetic

theorem paper_score_ratio (L : ℕ) (hL : 0 < L) :
    paperEpsilon L ≤ (L : ℚ≥0)/2^63 := by
  have h : ((blocks (8*L)+1 : ℕ) : ℚ≥0) ≤ 2*L := by
    exact_mod_cast paper_envelope_arithmetic L hL
  unfold paperEpsilon
  calc
    _ ≤ (2*(L : ℚ≥0))/2^64 := div_le_div_of_nonneg_right h (by positivity)
    _ = _ := by norm_num; ring
-- checkpoint: paper_score_ratio

theorem modelA_score_ratio (L : ℕ) (hL : 0 < L) :
    modelAEpsilon L ≤ (L : ℚ≥0)/2^63 := by
  have h : ((degreeBudget L+blocks (8*L) : ℕ) : ℚ≥0) ≤ 2*L := by
    exact_mod_cast modelA_envelope_arithmetic L hL
  unfold modelAEpsilon
  calc
    _ ≤ (2*(L : ℚ≥0))/2^64 := div_le_div_of_nonneg_right h (by positivity)
    _ = _ := by norm_num; ring
-- checkpoint: modelA_score_ratio

theorem score_attained : paperEpsilon 1 = 1/2^63 ∧ modelAEpsilon 1 = 1/2^63 := by
  norm_num [paperEpsilon, modelAEpsilon, blocks, degreeBudget]
-- checkpoint: score_attained

end ProvenHashes.ChainHash.V3
