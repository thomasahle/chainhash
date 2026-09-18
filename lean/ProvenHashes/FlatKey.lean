import ProvenHashes.ChainHash256

noncomputable section
namespace ProvenHashes.ChainHash256
open Carryless ChainEncoding

abbrev FlatKey := Fin 41 → Word 64

/-- Code layout: k[0..31], u,y,z at 32..34, c[0..4] at 35..39,
and the integer twist word at 40. No seed expansion is part of the ideal key. -/
def decodeFlat {F : Type*} [AddGroup F] (e : Word 64 ≃+ F) (k : FlatKey) : IdealKey F :=
  ((fun i => k ⟨i.val, by omega⟩, fun i => e (k ⟨32 + i.val, by omega⟩)),
    (integerEquiv 64 (k 40), fun i => e (k ⟨35 + i.val, by omega⟩)))

def encodeFlat {F : Type*} [AddGroup F] (e : Word 64 ≃+ F) (k : IdealKey F) : FlatKey := fun i =>
  if h0 : i.val < 32 then k.1.1 ⟨i.val, h0⟩
  else if h1 : i.val < 35 then e.symm (k.1.2 ⟨i.val - 32, by omega⟩)
  else if h2 : i.val < 40 then e.symm (k.2.2 ⟨i.val - 35, by omega⟩)
  else (integerEquiv 64).symm k.2.1

theorem encode_decode_flat {F : Type*} [AddGroup F] (e : Word 64 ≃+ F) (k : FlatKey) :
    encodeFlat e (decodeFlat e k) = k := by
  funext i
  fin_cases i <;> simp [encodeFlat, decodeFlat]

theorem decode_encode_flat {F : Type*} [AddGroup F] (e : Word 64 ≃+ F) (k : IdealKey F) :
    decodeFlat e (encodeFlat e k) = k := by
  refine Prod.ext (Prod.ext ?_ ?_) (Prod.ext ?_ ?_)
  · funext i
    fin_cases i <;> simp [decodeFlat, encodeFlat]
  · funext i
    fin_cases i <;> simp [decodeFlat, encodeFlat]
  · change (integerEquiv 64) ((integerEquiv 64).symm k.2.1) = k.2.1
    exact (integerEquiv 64).apply_symm_apply _
  · funext i
    fin_cases i <;> simp [decodeFlat, encodeFlat]

def keyEquiv {F : Type*} [AddGroup F] (e : Word 64 ≃+ F) : FlatKey ≃ IdealKey F where
  toFun := decodeFlat e
  invFun := encodeFlat e
  left_inv := encode_decode_flat e
  right_inv := decode_encode_flat e

theorem flatKey_card : Fintype.card FlatKey = 2 ^ (64 * 41) := by
  change Fintype.card (Fin 41 → Word 64) = _
  rw [Fintype.card_fun, Fintype.card_fin, word_card, ← pow_mul]

def hashFlat {F : Type*} [Field F] (e : Word 64 ≃+ F) (k : FlatKey) (m : Bytes) : F :=
  hash e (keyEquiv e k) m

theorem collision_bound_flat {F : Type*} [Field F] [Fintype F]
    (e : Word 64 ≃+ F) (L : ℕ) (hL : 8 * L < 2 ^ 64)
    (m m' : Bytes) (hm : m.length ≤ 8 * L) (hm' : m'.length ≤ 8 * L) (hne : m ≠ m') :
    uniformProb (fun k : FlatKey => hashFlat e k m = hashFlat e k m') ≤ epsilon L := by
  unfold hashFlat
  rw [uniformProb_equiv (keyEquiv e) (fun k => hash e k m = hash e k m')]
  exact collision_bound e L hL m m' hm hm' hne

end ProvenHashes.ChainHash256
