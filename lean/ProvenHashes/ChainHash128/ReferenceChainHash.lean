import ProvenHashes.ChainHash128.ConcreteChainHash
import ProvenHashes.ChainHash128.ReferenceOperations

noncomputable section
namespace ProvenHashes.ChainHash128
open ProvenHashes.ChainHash

def referenceBlockKey (k : Key41) : BlockKey := fun j =>
  k ⟨(pairPosition j).val, by have := (pairPosition j).isLt; omega⟩

def wordStream (m : Message) (k : BlockKey) : List (Word 128 × Word 128) :=
  List.ofFn fun i : Fin (blockCount m) => wordDigest m k i.val

/-- A direct word-operation transcription of `chainhash128_portable`.
`+` on Word is XOR; `wordAdd` is reserved for the integer-add twist. -/
def referenceHash (k : Key41) (m : Message) : Word 128 :=
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

theorem wordAdd_matches (a b : Word 128) :
    fieldRepr (wordAdd a b) = integerTwist fieldIntegerEquiv (fieldRepr b) (fieldRepr a) := by
  simp [wordAdd, integerTwist, fieldIntegerEquiv]

theorem referenceHash_matches (k : Key41) (m : Message) : referenceHash k m = chainHash k m := by
  apply fieldRepr.injective
  unfold referenceHash chainHash
  rw [AddEquiv.apply_symm_apply, wordChain5_matches, wordAdd_matches, wordFold_matches,
    wordStream_matches]
  rfl

/-- Full-output bound for the direct reference transcription and all 41 uniform words.
The cap prevents overflow in `len + 511` as well as in the 128-bit length encoding. -/
theorem reference_collision_bound (L : ℕ) (hL : 16 * L + 511 < 2 ^ 128)
    (m m' : Message) (hm : m.length ≤ 16 * L) (hm' : m'.length ≤ 16 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key41 => referenceHash k m = referenceHash k m') ≤
      ((max 1 ((L + 31) / 32) + 2 : ℕ) : ℚ≥0) / (2 : ℚ≥0) ^ 128 := by
  simp_rw [referenceHash_matches]
  exact chainHash_collision_bound_no_overflow L hL m m' hm hm' hne

end ProvenHashes.ChainHash128
