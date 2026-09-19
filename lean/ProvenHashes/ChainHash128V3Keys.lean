import ProvenHashes.ChainHash128V3Seeded
import ProvenHashes.ChainHash128.ByteInterface
import ProvenHashes.ChainHash128.Strided

/-! Key layouts of `chainhash128_v3.h`: the paper model is 39 little-endian 128-bit words
`kappa[0..31], y, c0..c4, tau` (`key_from_words` / 624 bytes `key_from_ideal_bytes`);
model A is exactly 128 random bytes `s, y, c0..c4, tau` (`key_from_bytes`). Native
`List UInt8` messages and the full 128-bit digest. -/
noncomputable section
namespace ProvenHashes.ChainHash.V3_128
open ProvenHashes.ChainHash128

/-- `kappa[2C]` keys the first word of slot `C`, `kappa[2C+1]` its partner. -/
def position (j : Slot) : Fin 32 := ⟨2*j.1.val + if j.2 then 1 else 0, by split_ifs <;> omega⟩
def unposition (i : Fin 32) : Slot := (⟨i.val/2, by omega⟩, decide (i.val%2=1))

theorem unposition_position (j : Slot) : unposition (position j) = j := by
  rcases j with ⟨i,b⟩
  apply Prod.ext
  · apply Fin.ext
    cases b <;> simp [position, unposition] <;> omega
  · cases b <;> simp [position, unposition] <;> omega
-- checkpoint: unposition_position

theorem position_unposition (i : Fin 32) : position (unposition i) = i := by
  apply Fin.ext
  simp only [position, unposition, decide_eq_true_eq]
  split_ifs <;> omega
-- checkpoint: position_unposition

abbrev Key39 := Fin 39 → Word 128
abbrev Key8 := Fin 8 → Word 128

def decodeIdeal (k : Key39) : IdealKey :=
  ((fun j => fieldRepr (k ⟨(position j).val, by have := (position j).isLt; omega⟩),
    fieldRepr (k 32)),
    (fieldRepr (k 38), fun i => fieldRepr (k ⟨33+i.val, by omega⟩)))

def encodeIdeal (k : IdealKey) : Key39 := fun i =>
  if h : i.val < 32 then fieldRepr.symm (k.1.1 (unposition ⟨i.val,h⟩))
  else if i.val=32 then fieldRepr.symm k.1.2
  else if h : i.val < 38 then fieldRepr.symm (k.2.2 ⟨i.val-33,by omega⟩)
  else fieldRepr.symm k.2.1

theorem encode_decodeIdeal (k : Key39) : encodeIdeal (decodeIdeal k) = k := by
  funext i
  unfold encodeIdeal decodeIdeal
  split_ifs with h₀ h₁ h₂
  · simp only [position_unposition, AddEquiv.symm_apply_apply]
  · simp only [AddEquiv.symm_apply_apply]; congr 1; apply Fin.ext; omega
  · simp only [AddEquiv.symm_apply_apply]
    congr 1
    apply Fin.ext
    change 33+(i.val-33)=i.val
    omega
  · simp only [AddEquiv.symm_apply_apply]; congr 1; apply Fin.ext; omega
-- checkpoint: encode_decodeIdeal

theorem decode_encodeIdeal (k : IdealKey) : decodeIdeal (encodeIdeal k) = k := by
  apply Prod.ext
  · apply Prod.ext
    · funext j
      have hj := (position j).isLt
      simp [decodeIdeal, encodeIdeal, hj, unposition_position]
    · simp [decodeIdeal, encodeIdeal]
  · apply Prod.ext
    · simp [decodeIdeal, encodeIdeal]
    · funext i
      have h₀ : ¬ 33+i.val < 32 := by omega
      have h₁ : ¬ 33+i.val=32 := by omega
      have h₂ : 33+i.val<38 := by omega
      simp [decodeIdeal, encodeIdeal, h₀, h₁, h₂]
-- checkpoint: decode_encodeIdeal

def idealKeyEquiv : Key39 ≃ IdealKey where
  toFun := decodeIdeal
  invFun := encodeIdeal
  left_inv := encode_decodeIdeal
  right_inv := decode_encodeIdeal

def decodeModelA (k : Key8) : ModelAKey :=
  ((fieldRepr (k 0),fieldRepr (k 1)),
    (fieldRepr (k 7), fun i => fieldRepr (k ⟨2+i.val, by omega⟩)))

def encodeModelA (k : ModelAKey) : Key8 := fun i =>
  if i.val=0 then fieldRepr.symm k.1.1 else if i.val=1 then fieldRepr.symm k.1.2
  else if h : i.val<7 then fieldRepr.symm (k.2.2 ⟨i.val-2,by omega⟩)
  else fieldRepr.symm k.2.1

theorem encode_decodeModelA (k : Key8) : encodeModelA (decodeModelA k) = k := by
  funext i
  unfold encodeModelA decodeModelA
  split_ifs <;> simp only [AddEquiv.symm_apply_apply] <;> congr 1 <;> apply Fin.ext <;> dsimp <;> omega
-- checkpoint: encode_decodeModelA

theorem decode_encodeModelA (k : ModelAKey) : decodeModelA (encodeModelA k) = k := by
  apply Prod.ext
  · apply Prod.ext <;> simp [decodeModelA, encodeModelA]
  · apply Prod.ext
    · simp [decodeModelA, encodeModelA]
    · funext i
      have h₀ : ¬ 2+i.val=0 := by omega
      have h₁ : ¬ 2+i.val=1 := by omega
      have h₂ : 2+i.val<7 := by omega
      simp [decodeModelA, encodeModelA, h₀, h₁, h₂]
-- checkpoint: decode_encodeModelA

def modelAKeyEquiv : Key8 ≃ ModelAKey where
  toFun := decodeModelA
  invFun := encodeModelA
  left_inv := encode_decodeModelA
  right_inv := decode_encodeModelA

def expandedWords (k : ModelAKey) : Key39 := encodeIdeal (expandKey k)

/-- `kappa[a] = s^(a+1)` in the shipped 39-word layout. -/
theorem expandedWords_power (k : ModelAKey) (j : Fin 32) :
    fieldRepr (expandedWords k ⟨j.val,by omega⟩) = k.1.1^(j.val+1) := by
  have he : exponent (unposition j) = j.val+1 := by
    simp only [exponent, unposition, decide_eq_true_eq]
    split_ifs <;> omega
  simp only [expandedWords, encodeIdeal, j.isLt, ↓reduceDIte, AddEquiv.apply_symm_apply,
    expandKey, powerKey, he]
-- checkpoint: expandedWords_power

/-- Canonical little-endian 16-byte words, with no entropy expansion. -/
def decodeKeyBytes (n : ℕ) (b : Fin (16*n) → Byte) : Fin n → Word 128 :=
  fun i j => b ⟨16*i.val+j.val/8,by omega⟩ ⟨j.val%8,by omega⟩

def encodeKeyBytes (n : ℕ) (w : Fin n → Word 128) : Fin (16*n) → Byte :=
  fun i j => w ⟨i.val/16,by omega⟩ ⟨8*(i.val%16)+j.val,by omega⟩

theorem encode_decodeKeyBytes (n : ℕ) (b : Fin (16*n) → Byte) :
    encodeKeyBytes n (decodeKeyBytes n b) = b := by
  funext i j
  unfold encodeKeyBytes decodeKeyBytes
  congr 2 <;> simp only [Fin.ext_iff] <;> omega
-- checkpoint: encode_decodeKeyBytes

theorem decode_encodeKeyBytes (n : ℕ) (w : Fin n → Word 128) :
    decodeKeyBytes n (encodeKeyBytes n w) = w := by
  funext i j
  change w ⟨(16*i.val+j.val/8)/16,by omega⟩
    ⟨8*((16*i.val+j.val/8)%16)+j.val%8,by omega⟩ = w i j
  have hi : (⟨(16*i.val+j.val/8)/16,by omega⟩ : Fin n) = i := Fin.ext (by dsimp; omega)
  have hj : (⟨8*((16*i.val+j.val/8)%16)+j.val%8,by omega⟩ : Fin 128) = j := Fin.ext (by dsimp; omega)
  rw [hi, hj]
-- checkpoint: decode_encodeKeyBytes

def keyBytesEquiv (n : ℕ) : (Fin (16*n) → Byte) ≃ (Fin n → Word 128) where
  toFun := decodeKeyBytes n
  invFun := encodeKeyBytes n
  left_inv := encode_decodeKeyBytes n
  right_inv := decode_encodeKeyBytes n

/-- The full 128-bit digest, bit `i` = coefficient of `X^i`. -/
def digestWord (v : F) : BitVec 128 := bitVecOfBits (fieldRepr.symm v)
/-- The 16 little-endian output bytes of `chainhash128_v3_store`. -/
def digestBytes (v : F) : List Byte := ChainHash128.Strided.outputBytes (fieldRepr.symm v)

def hashBytes (k : Key39) (m : List UInt8) : BitVec 128 :=
  digestWord (hash (decodeIdeal k) (bytesToMessage m))

def hashIdealKeyBytes (k : Fin 624 → Byte) (m : List UInt8) : BitVec 128 :=
  hashBytes (decodeKeyBytes 39 k) m

def modelAHashBytes (k : Fin 128 → Byte) (m : List UInt8) : BitVec 128 :=
  digestWord (modelAHash (decodeModelA (decodeKeyBytes 8 k)) (bytesToMessage m))

def hashOutput (k : Key39) (m : List UInt8) : List Byte :=
  digestBytes (hash (decodeIdeal k) (bytesToMessage m))

theorem digestWord_injective : Function.Injective digestWord := by
  intro a b h
  exact fieldRepr.symm.injective ((bitsEquivBitVec 128).injective h)
-- checkpoint: digestWord_injective

theorem digestBytes_injective : Function.Injective digestBytes := by
  intro a b h
  exact fieldRepr.symm.injective (ChainHash128.Strided.outputBytes_injective h)
-- checkpoint: digestBytes_injective

/-- Paper model, byte interface: `ε ≤ min 1 ((p_B(L)+1)/2^128)` for distinct byte strings
of at most `8L` bytes, over 39 independent uniform key words. -/
theorem paper_collision_bound_bytes (L : ℕ) (hL : 8*L < 2^128)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Key39 => hashBytes k m = hashBytes k m') ≤ paperEpsilon L := by
  simp only [hashBytes, digestWord_injective.eq_iff]
  change uniformProb (fun k => hash (idealKeyEquiv k) (bytesToMessage m) =
    hash (idealKeyEquiv k) (bytesToMessage m')) ≤ _
  rw [uniformProb_equiv idealKeyEquiv (fun k => hash k (bytesToMessage m) = hash k (bytesToMessage m'))]
  apply chainHashHorner_collision_bound L hL
  · simpa only [bytesToMessage, List.length_map] using hm
  · simpa only [bytesToMessage, List.length_map] using hm'
  · exact fun h => hne (bytesToMessage_injective h)
-- checkpoint: paper_collision_bound_bytes

/-- The same bound for the 624-byte `key_from_ideal_bytes` layout. -/
theorem paper_collision_bound_key_bytes (L : ℕ) (hL : 8*L < 2^128)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Fin 624 → Byte => hashIdealKeyBytes k m = hashIdealKeyBytes k m') ≤
      paperEpsilon L := by
  change uniformProb (fun k => hashBytes (keyBytesEquiv 39 k) m = hashBytes (keyBytesEquiv 39 k) m') ≤ _
  rw [uniformProb_equiv (keyBytesEquiv 39) (fun k => hashBytes k m = hashBytes k m')]
  exact paper_collision_bound_bytes L hL m m' hm hm' hne
-- checkpoint: paper_collision_bound_key_bytes

/-- The same bound for the 16 serialized output bytes. -/
theorem paper_collision_bound_output (L : ℕ) (hL : 8*L < 2^128)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Key39 => hashOutput k m = hashOutput k m') ≤ paperEpsilon L := by
  have he : (fun k : Key39 => hashOutput k m = hashOutput k m') =
      (fun k : Key39 => hashBytes k m = hashBytes k m') := by
    funext k
    simp only [hashOutput, hashBytes, digestBytes_injective.eq_iff, digestWord_injective.eq_iff]
  rw [he]
  exact paper_collision_bound_bytes L hL m m' hm hm' hne
-- checkpoint: paper_collision_bound_output

/-- Model A, byte interface: exactly 128 independent uniform key bytes, SPEC envelope
`min 1 (E_A(L)/2^128)`, distinct byte strings of at most `8L` bytes. -/
theorem modelA_collision_bound_bytes (L : ℕ) (hL : 0 < L) (hcap : 8*L < 2^128)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Fin 128 → Byte => modelAHashBytes k m = modelAHashBytes k m') ≤
      modelAEpsilon L := by
  simp only [modelAHashBytes, digestWord_injective.eq_iff]
  change uniformProb (fun k => modelAHash (((keyBytesEquiv 8).trans modelAKeyEquiv) k) (bytesToMessage m) =
    modelAHash (((keyBytesEquiv 8).trans modelAKeyEquiv) k) (bytesToMessage m')) ≤ _
  rw [uniformProb_equiv ((keyBytesEquiv 8).trans modelAKeyEquiv)
    (fun k => modelAHash k (bytesToMessage m) = modelAHash k (bytesToMessage m'))]
  apply chainHashHorner_modelA_collision_bound L hL hcap
  · simpa only [bytesToMessage, List.length_map] using hm
  · simpa only [bytesToMessage, List.length_map] using hm'
  · exact fun h => hne (bytesToMessage_injective h)
-- checkpoint: modelA_collision_bound_bytes

/-- Model A, byte interface, SPEC coarse envelope `min 1 ((p+W)/2^128)`. -/
theorem modelA_coarse_bound_bytes (L : ℕ) (hL : 0 < L) (hcap : 8*L < 2^128)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Fin 128 → Byte => modelAHashBytes k m = modelAHashBytes k m') ≤
      modelACoarseEpsilon L :=
  (modelA_collision_bound_bytes L hL hcap m m' hm hm' hne).trans (modelA_le_coarse L)
-- checkpoint: modelA_coarse_bound_bytes

/-- SPEC paper certificate in block form on the byte interface. -/
theorem paper_collision_bound_bytes_blocks (p : ℕ) (m m' : List UInt8)
    (hm : m.length < 2^128) (hm' : m'.length < 2^128) (hne : m ≠ m')
    (hp : blocks m.length ≤ p) (hp' : blocks m'.length ≤ p) :
    uniformProb (fun k : Key39 => hashBytes k m = hashBytes k m') ≤
      min 1 (((p+1 : ℕ) : ℚ≥0)/2^128) := by
  simp only [hashBytes, digestWord_injective.eq_iff]
  change uniformProb (fun k => hash (idealKeyEquiv k) (bytesToMessage m) =
    hash (idealKeyEquiv k) (bytesToMessage m')) ≤ _
  rw [uniformProb_equiv idealKeyEquiv (fun k => hash k (bytesToMessage m) = hash k (bytesToMessage m'))]
  apply chainHashHorner_collision_bound_blocks p
  · simpa only [bytesToMessage, List.length_map] using hm
  · simpa only [bytesToMessage, List.length_map] using hm'
  · exact fun h => hne (bytesToMessage_injective h)
  · simpa only [bytesToMessage, List.length_map] using hp
  · simpa only [bytesToMessage, List.length_map] using hp'
-- checkpoint: paper_collision_bound_bytes_blocks

/-- SPEC coarse model A envelope in block form on the byte interface (128 random key bytes). -/
theorem modelA_coarse_bound_bytes_blocks (p : ℕ) (m m' : List UInt8)
    (hm : m.length < 2^128) (hm' : m'.length < 2^128) (hne : m ≠ m')
    (hp : blocks m.length ≤ p) (hp' : blocks m'.length ≤ p) :
    uniformProb (fun k : Fin 128 → Byte => modelAHashBytes k m = modelAHashBytes k m') ≤
      min 1 (((p+32 : ℕ) : ℚ≥0)/2^128) := by
  simp only [modelAHashBytes, digestWord_injective.eq_iff]
  change uniformProb (fun k => modelAHash (((keyBytesEquiv 8).trans modelAKeyEquiv) k) (bytesToMessage m) =
    modelAHash (((keyBytesEquiv 8).trans modelAKeyEquiv) k) (bytesToMessage m')) ≤ _
  rw [uniformProb_equiv ((keyBytesEquiv 8).trans modelAKeyEquiv)
    (fun k => modelAHash k (bytesToMessage m) = modelAHash k (bytesToMessage m'))]
  apply chainHashHorner_modelA_coarse_bound_blocks p
  · simpa only [bytesToMessage, List.length_map] using hm
  · simpa only [bytesToMessage, List.length_map] using hm'
  · exact fun h => hne (bytesToMessage_injective h)
  · simpa only [bytesToMessage, List.length_map] using hp
  · simpa only [bytesToMessage, List.length_map] using hp'
-- checkpoint: modelA_coarse_bound_bytes_blocks

end ProvenHashes.ChainHash.V3_128
