import ProvenHashes.ChainHash128.BinaryField
import ProvenHashes.Polynomial
import ProvenHashes.NH

/-! ChainHash-128 (B = 512): the comb layout of `chainhash128.h` / SPEC-128.md.
Words are 16 bytes; a region is 4096 bytes = 256 words holding eight logical blocks of
32 words each; word `i = 256R + 16C + 8h + j` belongs to block `t = 8R + j` (zero-based
here), pair slot `C`, half `h`; the first half (`h = 0`) pairs with word `i + 8`. -/
noncomputable section
namespace ProvenHashes.ChainHash128
open ProvenHashes.ChainHash
open Polynomial
open scoped BigOperators

abbrev F := BinaryQuotient

/-- Pair slot `C` in `0..15` and half `h` (`false` = first word, `true` = partner). -/
abbrev Slot := Fin 16 × Bool

def partner (j : Slot) : Slot := (j.1, !j.2)
/-- Key exponent: `kappa[2C] = s^(2C+1)` for the first word, `kappa[2C+1] = s^(2C+2)`. -/
def exponent (j : Slot) : ℕ := 2 * j.1.val + (if j.2 then 2 else 1)
/-- Index map `i = 8W*R + 16C + 8h + j` with `W = 32` and zero-based block `t = 8R + j`. -/
def wordIndex (t : ℕ) (j : Slot) : ℕ :=
  256 * (t / 8) + 16 * j.1.val + (if j.2 then 8 else 0) + t % 8

def blockOf (i : ℕ) : ℕ := 8 * (i / 256) + i % 8
def slotOf (i : ℕ) : Slot := (⟨(i % 256) / 16, by omega⟩, decide (8 ≤ i % 16))

/-- Block count `p(ell)`: `p(0) = 1`; `ell = 4096Q + r` gives `8Q` if `r = 0`, else `8Q + min 8 ⌈r/16⌉`. -/
def blocks (n : ℕ) : ℕ :=
  if n = 0 then 1 else 8 * ((n - 1) / 4096) + min 8 (((n - 1) % 4096) / 16 + 1)

/-- A pair is present exactly when its first word has an existing byte. -/
def active (m : Message) (t : ℕ) : Finset (Fin 16) :=
  Finset.univ.filter fun i => 16 * wordIndex t (i, false) < m.length

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

theorem blockOf_lt (i n : ℕ) (hi : 16 * i < n) : blockOf i < blocks n := by
  unfold blockOf blocks
  split_ifs <;> omega
-- checkpoint: blockOf_lt

theorem slotOf_active (m : Message) (i : ℕ) (hi : 16 * i < m.length) :
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

/-- Examples: lengths 1,17,33,113,256,2048 have 1,2,3,8,8,8 blocks; 2049 has 8 for B=512. -/
theorem blocks_examples :
    ([0,1,17,33,113,256,2048,2049,4096,4097].map blocks) = [1,1,2,3,8,8,8,8,8,9] := by decide
-- checkpoint: blocks_examples

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

end ProvenHashes.ChainHash128
