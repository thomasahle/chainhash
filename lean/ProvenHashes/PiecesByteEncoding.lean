import ProvenHashes.FinalizerKwise

noncomputable section
namespace ProvenHashes.ChainEncoding
open Carryless

abbrev Byte := Word 8
abbrev Bytes := List Byte

/-- Binary digits, with bit zero the coefficient of X^0. -/
def bits {w : ℕ} (v : BitVec w) : Word w :=
  fun i => if v.getLsbD i.val then 1 else 0

theorem bits_injective (w : ℕ) : Function.Injective (@bits w) := by
  intro v v' h
  apply BitVec.eq_of_getLsbD_eq
  intro i hi
  have hb := congrFun h ⟨i, hi⟩
  change (if v.getLsbD i then (1 : ZMod 2) else 0) =
    (if v'.getLsbD i then 1 else 0) at hb
  cases hv : v.getLsbD i <;> cases hv' : v'.getLsbD i <;> simp_all

def bitsEquiv (w : ℕ) : BitVec w ≃ Word w := by
  letI : Fintype (BitVec w) := Fintype.ofEquiv (Fin (2 ^ w)) BitVec.equivFin.symm.toEquiv
  apply Equiv.ofBijective bits
  apply (Fintype.bijective_iff_injective_and_card _).mpr
  refine ⟨bits_injective w, ?_⟩
  rw [Fintype.card_congr BitVec.equivFin.toEquiv, Fintype.card_fin, word_card]

/-- The exact integer interpretation of a polynomial-bit word. -/
def integerEquiv (w : ℕ) : Word w ≃ ZMod (2 ^ w) :=
  (bitsEquiv w).symm.trans (BitVec.equivFin.toEquiv.trans (ZMod.finEquiv (2 ^ w)).toEquiv)

def lengthWord (n : ℕ) : Word 64 := bits (BitVec.ofNat 64 n)

theorem lengthWord_injective_below {n m : ℕ}
    (hn : n < 2 ^ 64) (hm : m < 2 ^ 64) (h : lengthWord n = lengthWord m) : n = m := by
  have hb := bits_injective 64 h
  have hval := congrArg BitVec.toNat hb
  simpa only [BitVec.toNat_ofNat, Nat.mod_eq_of_lt hn, Nat.mod_eq_of_lt hm] using hval

/-- Little-endian word assembly with implicit zero bytes past the end. -/
def readWord (m : Bytes) (j : ℕ) : Word 64 := fun i =>
  (m.getD (8 * j + i.val / 8) 0) ⟨i.val % 8, Nat.mod_lt _ (by decide)⟩

theorem readWord_byte (m : Bytes) (j : ℕ) (t b : Fin 8) :
    readWord m j ⟨8 * t.val + b.val, by omega⟩ =
      m.getD (8 * j + t.val) 0 b := by
  have hd : (8 * t.val + b.val) / 8 = t.val := by omega
  have hm : (8 * t.val + b.val) % 8 = b.val := by omega
  simp [readWord, hd, hm]

/-- Equal-length byte strings are recovered from their zero-padded words. -/
theorem readWords_injective (m m' : Bytes) (hlen : m.length = m'.length)
    (hwords : ∀ j, readWord m j = readWord m' j) : m = m' := by
  apply List.ext_getElem hlen
  intro i hi hi'
  funext b
  have h := congrFun (hwords (i / 8))
    (⟨8 * (i % 8) + b.val, by have := b.isLt; omega⟩ : Fin 64)
  have he : 8 * (i / 8) + i % 8 = i := by omega
  rw [readWord_byte m (i / 8) ⟨i % 8, Nat.mod_lt _ (by decide)⟩ b,
    readWord_byte m' (i / 8) ⟨i % 8, Nat.mod_lt _ (by decide)⟩ b] at h
  simpa [he, List.getD_eq_getElem, hi, hi'] using h

/-- The code's pair s is (word alpha(s), word alpha(s)+2). -/
def stridedPosition : (Fin 16 × Bool) ≃ Fin 32 where
  toFun j := ⟨4 * (j.1.val / 2) + j.1.val % 2 + (if j.2 then 2 else 0), by
    have := j.1.isLt
    split <;> omega⟩
  invFun i := (⟨2 * (i.val / 4) + i.val % 2, by have := i.isLt; omega⟩,
    decide (2 ≤ i.val % 4))
  left_inv := by
    rintro ⟨i, b⟩
    fin_cases i <;> cases b <;> decide
  right_inv := by
    intro i
    fin_cases i <;> decide

def blockCount (n : ℕ) : ℕ := max 1 ((n + 255) / 256)
def remaining (n t : ℕ) : ℕ := min 256 (n - 256 * t)
def pairCount (n t : ℕ) : ℕ := 2 * ((remaining n t + 31) / 32)

def subblock (m : Bytes) (t : ℕ) : Fin 16 × Bool → Word 64 :=
  fun j => readWord m (32 * t + (stridedPosition j).val)

theorem blockCount_pos (n : ℕ) : 0 < blockCount n := by
  unfold blockCount
  omega

theorem pairCount_le (n t : ℕ) : pairCount n t ≤ 16 := by
  unfold pairCount remaining
  omega

theorem pairCount_even (n t : ℕ) : Even (pairCount n t) := by
  exact even_two_mul _

theorem blockCount_covers (n : ℕ) : n ≤ 256 * blockCount n := by
  unfold blockCount
  omega

theorem blockCount_bound {n L : ℕ} (hn : n ≤ 8 * L) :
    blockCount n ≤ max 1 ((L + 31) / 32) := by
  unfold blockCount
  omega

end ProvenHashes.ChainEncoding
