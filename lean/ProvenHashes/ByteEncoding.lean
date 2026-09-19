import ProvenHashes.Carryless

namespace ProvenHashes.ChainHash

abbrev Byte := Word 8
abbrev Message := List Byte

/-- Out-of-range reads supply padding zeroes, as `word_at` in the reference. -/
def byteAt (m : Message) (j : ℕ) : Byte := m[j]?.getD 0

/-- Little endian: bit b of byte t becomes bit 8*t+b of the word. -/
def wordAt (m : Message) (j : ℕ) : Word 64 := fun i =>
  byteAt m (8 * j + i.val / 8) ⟨i.val % 8, Nat.mod_lt _ (by omega)⟩

theorem wordAt_read_byte (m : Message) (j : ℕ) (b : Fin 8) :
    wordAt m (j / 8) ⟨8 * (j % 8) + b.val, by omega⟩ = byteAt m j b := by
  unfold wordAt
  have hdiv : (8 * (j % 8) + b.val) / 8 = j % 8 := by omega
  have hmod : (8 * (j % 8) + b.val) % 8 = b.val := by omega
  have hidx : 8 * (j / 8) + j % 8 = j := by omega
  simp only [hdiv, hmod, hidx]

/-- The decoder reads each byte back at its quotient/remainder word address. -/
theorem byte_words_injective (m m' : Message) (hlen : m.length = m'.length)
    (hwords : ∀ j, 8 * j < m.length → wordAt m j = wordAt m' j) : m = m' := by
  apply List.ext_getElem hlen
  intro j hj hj'
  funext b
  have hw := congrFun (hwords (j / 8) (by omega))
    ⟨8 * (j % 8) + b.val, by omega⟩
  rw [wordAt_read_byte, wordAt_read_byte] at hw
  simpa [byteAt, List.getElem?_eq_getElem hj, List.getElem?_eq_getElem hj'] using hw

/-- Words past the message are zero: out-of-range reads supply padding zeroes. -/
theorem wordAt_zero (m : Message) (j : ℕ) (hj : m.length ≤ 8 * j) : wordAt m j = 0 := by
  funext i
  have h : m[8 * j + i.val / 8]? = none := List.getElem?_eq_none (by omega)
  simp [wordAt, byteAt, h]

/-- Concrete binary encoding of a bounded integer. -/
def bitsOfBitVec {w : ℕ} (v : BitVec w) : Word w :=
  fun i => if v.getLsbD i.val then 1 else 0

theorem bitsOfBitVec_injective (w : ℕ) : Function.Injective (@bitsOfBitVec w) := by
  intro v v' h
  apply BitVec.eq_of_getLsbD_eq
  intro i hi
  have he := congrFun h ⟨i, hi⟩
  cases hv : v.getLsbD i <;> cases hv' : v'.getLsbD i <;>
    simp_all [bitsOfBitVec]

def lengthWord (n : ℕ) : Word 64 := bitsOfBitVec (BitVec.ofNat 64 n)

theorem lengthWord_injective {n n' : ℕ} (hn : n < 2 ^ 64) (hn' : n' < 2 ^ 64)
    (h : lengthWord n = lengthWord n') : n = n' := by
  have hv := bitsOfBitVec_injective 64 h
  have hnat := congrArg BitVec.toNat hv
  simpa only [BitVec.toNat_ofNat, Nat.mod_eq_of_lt hn, Nat.mod_eq_of_lt hn'] using hnat

end ProvenHashes.ChainHash
