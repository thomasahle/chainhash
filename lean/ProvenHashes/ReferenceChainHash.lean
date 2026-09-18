import ProvenHashes.ConcreteChainHash
import ProvenHashes.ReferenceOperations

noncomputable section
namespace ProvenHashes.ChainHash

def referenceBlockKey (k : Key41) : BlockKey := fun j =>
  k ⟨(pairPosition j).val, by have := (pairPosition j).isLt; omega⟩

def wordStream (m : Message) (k : BlockKey) : List (Word 64 × Word 64) :=
  List.ofFn fun i : Fin (blockCount m) => wordDigest m k i.val

/-- A direct word-operation transcription of `chainhash_ref::hash<32,5,1>`.
`+` on Word is XOR; `wordAdd` is reserved for the integer-add twist. -/
def referenceHash (k : Key41) (m : Message) : Word 64 :=
  let s := wordStream m (referenceBlockKey k)
  let p := wordFold (k 32) (k 33) s (k 34)
  wordChain5 (fun i => k ⟨35 + i.val, by omega⟩) (wordAdd p (k 40))

theorem wordStream_matches (m : Message) (k : BlockKey) :
    (wordStream m k).map (fun ab => (fieldRepr ab.1, fieldRepr ab.2)) = stream fieldRepr m k := by
  simp only [wordStream, stream, rawStream, List.map_ofFn]
  congr 1
  funext i
  dsimp only [Function.comp_def]
  rw [← wordDigest_matches]
  rfl

theorem wordAdd_matches (a b : Word 64) :
    fieldRepr (wordAdd a b) = integerTwist fieldIntegerEquiv (fieldRepr b) (fieldRepr a) := by
  simp [wordAdd, integerTwist, fieldIntegerEquiv]

theorem referenceHash_matches (k : Key41) (m : Message) : referenceHash k m = chainHash k m := by
  apply fieldRepr.injective
  unfold referenceHash chainHash
  rw [AddEquiv.apply_symm_apply, wordChain5_matches, wordAdd_matches, wordFold_matches,
    wordStream_matches]
  rfl

/-- Full-output bound for the direct reference transcription and all 41 uniform words.
The cap prevents overflow in `len + 255` as well as in the 64-bit length encoding. -/
theorem reference_collision_bound (L : ℕ) (hL : 8 * L + 255 < 2 ^ 64)
    (m m' : Message) (hm : m.length ≤ 8 * L) (hm' : m'.length ≤ 8 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key41 => referenceHash k m = referenceHash k m') ≤
      ((max 1 ((L + 31) / 32) + 2 : ℕ) : ℚ≥0) / (2 : ℚ≥0) ^ 64 := by
  simp_rw [referenceHash_matches]
  exact chainHash_collision_bound_no_overflow L hL m m' hm hm' hne

end ProvenHashes.ChainHash
