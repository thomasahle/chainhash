import ProvenHashes.ChainHashModel

namespace ProvenHashes.ChainHash

abbrev Key41 := Fin 41 → Word 64

/-- Actual key indices: k[0..31], u=32, y=33, z=34, c[0..4]=35..39, twist=40.
The CLNH keys undergo the same strided permutation as the message words. -/
def decodeKey {F : Type*} [AddGroup F] (repr : Word 64 ≃+ F) (k : Key41) : IdealKey F :=
  ((fun j => k ⟨(pairPosition j).val, by have := (pairPosition j).isLt; omega⟩,
    fun i => repr (k ⟨32 + i.val, by omega⟩)),
   (repr (k 40), fun i => repr (k ⟨35 + i.val, by omega⟩)))

def encodeKey {F : Type*} [AddGroup F] (repr : Word 64 ≃+ F) (k : IdealKey F) : Key41 :=
  fun j => if h₀ : j.val < 32 then k.1.1 (unpairPosition ⟨j.val, h₀⟩)
    else if h₁ : j.val < 35 then repr.symm (k.1.2 ⟨j.val - 32, by omega⟩)
    else if h₂ : j.val < 40 then repr.symm (k.2.2 ⟨j.val - 35, by omega⟩)
    else repr.symm k.2.1

theorem encode_decodeKey {F : Type*} [AddGroup F] (repr : Word 64 ≃+ F) (k : Key41) :
    encodeKey repr (decodeKey repr k) = k := by
  funext j
  unfold encodeKey decodeKey
  split_ifs with h₀ h₁ h₂
  · simp only [pair_unpairPosition]
  · simp only [AddEquiv.symm_apply_apply]
    congr 1
    apply Fin.ext
    change 32 + (j.val - 32) = j.val
    omega
  · simp only [AddEquiv.symm_apply_apply]
    congr 1
    apply Fin.ext
    change 35 + (j.val - 35) = j.val
    omega
  · simp only [AddEquiv.symm_apply_apply]
    congr 1
    apply Fin.ext
    omega

theorem decode_encodeKey {F : Type*} [AddGroup F] (repr : Word 64 ≃+ F) (k : IdealKey F) :
    decodeKey repr (encodeKey repr k) = k := by
  apply Prod.ext
  · apply Prod.ext
    · funext j
      simp [decodeKey, encodeKey, unpair_pairPosition]
    · funext i
      have h₀ : ¬ 32 + i.val < 32 := by omega
      have h₁ : 32 + i.val < 35 := by omega
      simp [decodeKey, encodeKey, h₁]
  · apply Prod.ext
    · simp [decodeKey, encodeKey]
    · funext i
      have h₀ : ¬ 35 + i.val < 32 := by omega
      have h₁ : ¬ 35 + i.val < 35 := by omega
      have h₂ : 35 + i.val < 40 := by omega
      simp [decodeKey, encodeKey, h₀, h₂]

def keyEquiv {F : Type*} [AddGroup F] (repr : Word 64 ≃+ F) : Key41 ≃ IdealKey F where
  toFun := decodeKey repr
  invFun := encodeKey repr
  left_inv := encode_decodeKey repr
  right_inv := decode_encodeKey repr

end ProvenHashes.ChainHash
