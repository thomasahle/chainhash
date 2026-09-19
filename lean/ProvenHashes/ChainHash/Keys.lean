import ProvenHashes.ChainHash.Seeded
import ProvenHashes.ByteInterface

noncomputable section
namespace ProvenHashes.ChainHash

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

abbrev Key39 := Fin 39 → Word 64
abbrev Key8 := Fin 8 → Word 64

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

def decodeKey (k : Key8) : Key :=
  ((fieldRepr (k 0),fieldRepr (k 1)),
    (fieldRepr (k 7), fun i => fieldRepr (k ⟨2+i.val, by omega⟩)))

def encodeKey (k : Key) : Key8 := fun i =>
  if i.val=0 then fieldRepr.symm k.1.1 else if i.val=1 then fieldRepr.symm k.1.2
  else if h : i.val<7 then fieldRepr.symm (k.2.2 ⟨i.val-2,by omega⟩)
  else fieldRepr.symm k.2.1

theorem encode_decodeKey (k : Key8) : encodeKey (decodeKey k) = k := by
  funext i
  unfold encodeKey decodeKey
  split_ifs <;> simp only [AddEquiv.symm_apply_apply] <;> congr 1 <;> apply Fin.ext <;> dsimp <;> omega
-- checkpoint: encode_decodeKey

theorem decode_encodeKey (k : Key) : decodeKey (encodeKey k) = k := by
  apply Prod.ext
  · apply Prod.ext <;> simp [decodeKey, encodeKey]
  · apply Prod.ext
    · simp [decodeKey, encodeKey]
    · funext i
      have h₀ : ¬ 2+i.val=0 := by omega
      have h₁ : ¬ 2+i.val=1 := by omega
      have h₂ : 2+i.val<7 := by omega
      simp [decodeKey, encodeKey, h₀, h₁, h₂]
-- checkpoint: decode_encodeKey

def keyEquiv : Key8 ≃ Key where
  toFun := decodeKey
  invFun := encodeKey
  left_inv := encode_decodeKey
  right_inv := decode_encodeKey

def expandedWords (k : Key) : Key39 := encodeIdeal (expandKey k)

theorem expandedWords_power (k : Key) (j : Fin 32) :
    fieldRepr (expandedWords k ⟨j.val,by omega⟩) = k.1.1^(j.val+1) := by
  have he : exponent (unposition j) = j.val+1 := by
    simp only [exponent, unposition, decide_eq_true_eq]
    split_ifs <;> omega
  simp only [expandedWords, encodeIdeal, j.isLt, ↓reduceDIte, AddEquiv.apply_symm_apply,
    expandKey, powerKey, he]
-- checkpoint: expandedWords_power

/-- Canonical little-endian 8-byte words, with no entropy expansion. -/
def decodeKeyBytes (n : ℕ) (b : Fin (8*n) → Byte) : Fin n → Word 64 :=
  fun i j => b ⟨8*i.val+j.val/8,by omega⟩ ⟨j.val%8,by omega⟩

def encodeKeyBytes (n : ℕ) (w : Fin n → Word 64) : Fin (8*n) → Byte :=
  fun i j => w ⟨i.val/8,by omega⟩ ⟨8*(i.val%8)+j.val,by omega⟩

theorem encode_decodeKeyBytes (n : ℕ) (b : Fin (8*n) → Byte) :
    encodeKeyBytes n (decodeKeyBytes n b) = b := by
  funext i j
  unfold encodeKeyBytes decodeKeyBytes
  congr 2 <;> simp only [Fin.ext_iff] <;> omega
-- checkpoint: encode_decodeKeyBytes

theorem decode_encodeKeyBytes (n : ℕ) (w : Fin n → Word 64) :
    decodeKeyBytes n (encodeKeyBytes n w) = w := by
  funext i j
  change w ⟨(8*i.val+j.val/8)/8,by omega⟩
    ⟨8*((8*i.val+j.val/8)%8)+j.val%8,by omega⟩ = w i j
  have hi : (⟨(8*i.val+j.val/8)/8,by omega⟩ : Fin n) = i := Fin.ext (by dsimp; omega)
  have hj : (⟨8*((8*i.val+j.val/8)%8)+j.val%8,by omega⟩ : Fin 64) = j := Fin.ext (by dsimp; omega)
  rw [hi, hj]
-- checkpoint: decode_encodeKeyBytes

def keyBytesEquiv (n : ℕ) : (Fin (8*n) → Byte) ≃ (Fin n → Word 64) where
  toFun := decodeKeyBytes n
  invFun := encodeKeyBytes n
  left_inv := encode_decodeKeyBytes n
  right_inv := decode_encodeKeyBytes n

def digestWord (v : F) : UInt64 := ⟨bitVecOfBits (fieldRepr.symm v)⟩

def idealHashBytes (k : Key39) (m : List UInt8) : UInt64 :=
  digestWord (hash (decodeIdeal k) (bytesToMessage m))

def chainHashBytes (k : Fin 64 → Byte) (m : List UInt8) : UInt64 :=
  digestWord (chainHash (decodeKey (decodeKeyBytes 8 k)) (bytesToMessage m))

theorem digestWord_injective : Function.Injective digestWord := by
  intro a b h
  have he := UInt64.toBitVec_inj.mpr h
  exact fieldRepr.symm.injective ((bitsEquivBitVec 64).injective he)
-- checkpoint: digestWord_injective

theorem ideal_key_collision_bound (L : ℕ) (hL : 8*L < 2^64)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Key39 => idealHashBytes k m = idealHashBytes k m') ≤ idealKeyEpsilon L := by
  simp only [idealHashBytes, digestWord_injective.eq_iff]
  change uniformProb (fun k => hash (idealKeyEquiv k) (bytesToMessage m) =
    hash (idealKeyEquiv k) (bytesToMessage m')) ≤ _
  rw [uniformProb_equiv idealKeyEquiv (fun k => hash k (bytesToMessage m) = hash k (bytesToMessage m'))]
  apply idealKey_collision_bound_message L hL
  · simpa only [bytesToMessage, List.length_map] using hm
  · simpa only [bytesToMessage, List.length_map] using hm'
  · exact fun h => hne (bytesToMessage_injective h)
-- checkpoint: ideal_key_collision_bound

theorem collision_bound (L : ℕ) (hL : 0 < L) (hcap : 8*L < 2^64)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Fin 64 → Byte => chainHashBytes k m = chainHashBytes k m') ≤ epsilon L := by
  simp only [chainHashBytes, digestWord_injective.eq_iff]
  change uniformProb (fun k => chainHash (((keyBytesEquiv 8).trans keyEquiv) k) (bytesToMessage m) =
    chainHash (((keyBytesEquiv 8).trans keyEquiv) k) (bytesToMessage m')) ≤ _
  rw [uniformProb_equiv ((keyBytesEquiv 8).trans keyEquiv)
    (fun k => chainHash k (bytesToMessage m) = chainHash k (bytesToMessage m'))]
  apply collision_bound_message L hL hcap
  · simpa only [bytesToMessage, List.length_map] using hm
  · simpa only [bytesToMessage, List.length_map] using hm'
  · exact fun h => hne (bytesToMessage_injective h)
-- checkpoint: collision_bound

end ProvenHashes.ChainHash
