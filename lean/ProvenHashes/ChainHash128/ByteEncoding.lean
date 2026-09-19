import ProvenHashes.Carryless

namespace ProvenHashes.ChainHash128
open ProvenHashes.ChainHash

abbrev Byte := Word 8
abbrev Message := List Byte

/-- Out-of-range reads supply padding zeroes, as `word_at` in the reference. -/
def byteAt (m : Message) (j : ℕ) : Byte := m[j]?.getD 0

/-- Little endian: bit b of byte t becomes bit 8*t+b of the word. -/
def wordAt (m : Message) (j : ℕ) : Word 128 := fun i =>
  byteAt m (16 * j + i.val / 8) ⟨i.val % 8, Nat.mod_lt _ (by omega)⟩

theorem wordAt_read_byte (m : Message) (j : ℕ) (b : Fin 8) :
    wordAt m (j / 16) ⟨8 * (j % 16) + b.val, by omega⟩ = byteAt m j b := by
  unfold wordAt
  have hdiv : (8 * (j % 16) + b.val) / 8 = j % 16 := by omega
  have hmod : (8 * (j % 16) + b.val) % 8 = b.val := by omega
  have hidx : 16 * (j / 16) + j % 16 = j := by omega
  simp only [hdiv, hmod, hidx]

/-- The decoder reads each byte back at its quotient/remainder word address. -/
theorem byte_words_injective (m m' : Message) (hlen : m.length = m'.length)
    (hwords : ∀ j, 16 * j < m.length → wordAt m j = wordAt m' j) : m = m' := by
  apply List.ext_getElem hlen
  intro j hj hj'
  funext b
  have hw := congrFun (hwords (j / 16) (by omega))
    ⟨8 * (j % 16) + b.val, by omega⟩
  rw [wordAt_read_byte, wordAt_read_byte] at hw
  simpa [byteAt, List.getElem?_eq_getElem hj, List.getElem?_eq_getElem hj'] using hw

/-- Words past the message are zero: out-of-range reads supply padding zeroes. -/
theorem wordAt_zero (m : Message) (j : ℕ) (hj : m.length ≤ 16 * j) : wordAt m j = 0 := by
  funext i
  have h : m[16 * j + i.val / 8]? = none := List.getElem?_eq_none (by omega)
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

def lengthWord (n : ℕ) : Word 128 := bitsOfBitVec (BitVec.ofNat 128 n)

theorem lengthWord_injective {n n' : ℕ} (hn : n < 2 ^ 128) (hn' : n' < 2 ^ 128)
    (h : lengthWord n = lengthWord n') : n = n' := by
  have hv := bitsOfBitVec_injective 128 h
  have hnat := congrArg BitVec.toNat hv
  simpa only [BitVec.toNat_ofNat, Nat.mod_eq_of_lt hn, Nat.mod_eq_of_lt hn'] using hnat

/-- The sixteen little-endian output bytes of a 128-bit digest. -/
def outputBytes (w : Word 128) : List Byte :=
  List.ofFn fun i : Fin 16 => fun b : Fin 8 => w ⟨8*i.val+b.val, by omega⟩

theorem outputBytes_length (w : Word 128) : (outputBytes w).length = 16 := by
  simp [outputBytes]

theorem outputBytes_decode (w : Word 128) : wordAt (outputBytes w) 0 = w := by
  funext i
  have hi : i.val / 8 < 16 := by omega
  simp only [wordAt, byteAt, outputBytes, Nat.mul_zero, Nat.zero_add,
    List.getElem?_ofFn, hi, ↓reduceDIte, Option.getD_some]
  congr 1
  apply Fin.ext
  dsimp only
  omega

theorem outputBytes_injective : Function.Injective outputBytes := by
  intro v w h
  have he := congrArg (fun m => wordAt m 0) h
  simpa only [outputBytes_decode] using he

end ProvenHashes.ChainHash128
