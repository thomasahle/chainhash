import ProvenHashes.ModelA
import ProvenHashes.NH

noncomputable section
namespace ProvenHashes.ChainHash.V3
open Polynomial
open scoped BigOperators

abbrev F := BinaryQuotient

abbrev Slot := Fin 16 × Bool

def partner (j : Slot) : Slot := (j.1, !j.2)
def exponent (j : Slot) : ℕ := 2 * j.1.val + (if j.2 then 2 else 1)
def wordIndex (t : ℕ) (j : Slot) : ℕ :=
  128 * (t / 4) + 16 * (j.1.val / 2) + (if j.2 then 8 else 0) +
    2 * (t % 4) + j.1.val % 2

def blockOf (i : ℕ) : ℕ := 4 * (i / 128) + (i % 8) / 2
def slotOf (i : ℕ) : Slot :=
  (⟨2 * ((i % 128) / 16) + i % 2, by omega⟩, decide (8 ≤ i % 16))

def blocks (n : ℕ) : ℕ :=
  if n = 0 then 1 else 4 * ((n - 1) / 1024) + min 4 (((n - 1) % 1024) / 16 + 1)

def active (m : Message) (t : ℕ) : Finset (Fin 16) :=
  Finset.univ.filter fun i => 8 * wordIndex t (i, false) < m.length

def data (m : Message) (t : ℕ) (j : Slot) : F := fieldRepr (wordAt m (wordIndex t j))

theorem partnerExponent_injective : Function.Injective (fun j => exponent (partner j)) := by
  rintro ⟨i,b⟩ ⟨i',b'⟩ h
  cases b <;> cases b' <;> simp_all [partner, exponent]
  all_goals first | exact Fin.ext (by omega) | omega
-- checkpoint: partnerExponent_injective

theorem wordIndex_decode (i : ℕ) : wordIndex (blockOf i) (slotOf i) = i := by
  simp only [wordIndex, blockOf, slotOf, decide_eq_true_eq]
  split_ifs <;> omega
-- checkpoint: wordIndex_decode

theorem blockOf_lt (i n : ℕ) (hi : 8 * i < n) : blockOf i < blocks n := by
  unfold blockOf blocks
  split_ifs <;> omega
-- checkpoint: blockOf_lt

theorem slotOf_active (m : Message) (i : ℕ) (hi : 8 * i < m.length) :
    (slotOf i).1 ∈ active m (blockOf i) := by
  simp only [active, Finset.mem_filter, Finset.mem_univ, true_and]
  have h := wordIndex_decode i
  simp only [wordIndex, Bool.false_eq_true, ↓reduceIte, add_zero] at h ⊢
  split_ifs at h <;> omega
-- checkpoint: slotOf_active

theorem comb_encoding_injective (m m' : Message) (hlen : m.length = m'.length)
    (h : ∀ t, t < blocks m.length → ∀ j : Slot, j.1 ∈ active m t → data m t j = data m' t j) :
    m = m' := by
  apply byte_words_injective m m' hlen
  intro i hi
  have he := h (blockOf i) (blockOf_lt i m.length hi) (slotOf i) (slotOf_active m i hi)
  simpa only [data, wordIndex_decode, fieldRepr.injective.eq_iff] using he
-- checkpoint: comb_encoding_injective

theorem blocks_pos (n : ℕ) : 0 < blocks n := by
  unfold blocks
  split_ifs <;> omega
-- checkpoint: blocks_pos

theorem blocks_mono {n m : ℕ} (h : n ≤ m) : blocks n ≤ blocks m := by
  unfold blocks
  split_ifs <;> omega
-- checkpoint: blocks_mono

/-- A finite field of characteristic two has injective squaring. -/
theorem square_injective {K : Type*} [Field K] [CharP K 2] :
    Function.Injective (fun x : K => x ^ 2) := by
  exact frobenius_inj K 2
-- checkpoint: square_injective

/-- Count distinct roots after Frobenius composition without multiplying the bound by two. -/
theorem frobenius_root_count {K : Type*} [Field K] [Fintype K] [CharP K 2]
    [DecidableEq K] (h : K[X]) (hne : h ≠ 0) :
    (Finset.univ.filter fun x : K => (h.comp (X^2)).eval x = 0).card ≤ h.natDegree := by
  classical
  apply le_trans (Finset.card_le_card_of_injOn (fun x : K => x^2) ?_ ?_)
    (polynomial_zero_count h hne)
  · intro x hx
    simpa [eval_comp] using hx
  · exact square_injective.injOn
-- checkpoint: frobenius_root_count

end ProvenHashes.ChainHash.V3
