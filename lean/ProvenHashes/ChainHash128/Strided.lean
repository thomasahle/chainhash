import ProvenHashes.ChainHash128.ModelA
import ProvenHashes.ChainHash128.ByteInterface
import ProvenHashes.FinalizerIndependence

noncomputable section
namespace ProvenHashes.ChainHash128.Strided
open ProvenHashes.ChainHash

abbrev F := BinaryQuotient

theorem modulus_irreducible : Irreducible
    (Polynomial.X ^ 128 + (Polynomial.X ^ 7 + Polynomial.X ^ 2 + Polynomial.X + 1) :
      Polynomial (ZMod 2)) := ChainHash128.modulus_irreducible

theorem field_card : Fintype.card F = 2 ^ 128 := ChainHash128.field_card fieldRepr

theorem block_difference_bound (s : Finset (Fin 16))
    (m m' : Fin 16 × Bool → Word 128)
    (hne : ∃ i ∈ s, ∃ b, m (i,b) ≠ m' (i,b)) (C : BitsPolynomial) :
    uniformProb (fun k : BlockKey => clnh s m k - clnh s m' k = C) ≤
      1 / (2 : ℚ≥0)^128 := clnh_difference_bound s m m' hne C

theorem raw_block_degree (s : Finset (Fin 16)) (m k : Fin 16 × Bool → Word 128) :
    (clnh s m k).natDegree ≤ 254 := clnh_natDegree_le s m k

theorem recurrence_injective : Function.Injective (@Recurrence.keyPolynomial F _) :=
  Recurrence.keyPolynomial_injective

theorem twist_bijective (tau : F) :
    Function.Bijective (integerTwist fieldIntegerEquiv tau) :=
  integerTwist_bijective fieldIntegerEquiv tau

theorem finalizer_fivewise (v : Fin 5 → F) (hv : Function.Injective v) (r : Fin 5 → F) :
    uniformProb (fun c : Fin 5 → F => (fun i => chain5 c (v i)) = r) =
      1 / ((2 : ℚ≥0)^128)^5 := by
  have h := chain5_fivewise_exact v hv r
  simpa only [field_card, Nat.cast_pow, Nat.cast_ofNat] using h

/-- Exactly sixteen bytes, least significant byte first. -/
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

/-- Full mathematical byte-length domain; all 41 words independently uniform. -/
theorem ideal_bound (n : ℕ) (m m' : Message)
    (hm : m.length < 2^128) (hm' : m'.length < 2^128) (hne : m ≠ m')
    (hn : blockCount m ≤ n) (hn' : blockCount m' ≤ n) :
    uniformProb (fun k : Key41 => referenceHash k m = referenceHash k m') ≤
      min 1 (((n+2 : ℕ) : ℚ≥0) / 2^128) := by
  apply le_min (ModelA.probability_le_one _) _
  simp_rw [referenceHash_matches]
  have he : (fun k : Key41 => chainHash k m = chainHash k m') =
      (fun k => hash fieldRepr fieldIntegerEquiv (keyEquiv fieldRepr k) m =
        hash fieldRepr fieldIntegerEquiv (keyEquiv fieldRepr k) m') := by
    funext k
    exact propext fieldRepr.symm.injective.eq_iff
  rw [he]
  have hp := uniformProb_equiv (keyEquiv fieldRepr) (fun k : IdealKey F =>
    hash fieldRepr fieldIntegerEquiv k m = hash fieldRepr fieldIntegerEquiv k m')
  rw [hp]
  exact collision_bound_model fieldRepr fieldIntegerEquiv n m m' hm hm' hne hn hn'

/-- UInt8 input, full 128-bit output, with no rounding-overflow hypothesis. -/
theorem ideal_bound_bytes (n : ℕ) (m m' : List UInt8)
    (hm : m.length < 2^128) (hm' : m'.length < 2^128) (hne : m ≠ m')
    (hn : max 1 ((m.length+511)/512) ≤ n)
    (hn' : max 1 ((m'.length+511)/512) ≤ n) :
    uniformProb (fun k : Key41 => hashBytes k m = hashBytes k m') ≤
      min 1 (((n+2 : ℕ) : ℚ≥0) / 2^128) := by
  simp_rw [hashBytes_eq_iff]
  apply ideal_bound n (bytesToMessage m) (bytesToMessage m')
  · simpa [bytesToMessage] using hm
  · simpa [bytesToMessage] using hm'
  · exact fun h => hne (bytesToMessage_injective h)
  · simpa [blockCount, bytesToMessage] using hn
  · simpa [blockCount, bytesToMessage] using hn'

/-- Model A samples ten independent 128-bit words and expands only the PH seed. -/
theorem modelA_bound_bytes (L : ℕ) (hL : 0 < L) (hcap : 16*L < 2^128)
    (m m' : List UInt8) (hm : m.length ≤ 16*L) (hm' : m'.length ≤ 16*L)
    (hne : m ≠ m') :
    uniformProb (fun k : ModelA.Key =>
      hashBytes (ModelA.expandedKey k) m = hashBytes (ModelA.expandedKey k) m') ≤
      ModelA.epsilonAtMost L := by
  simp_rw [hashBytes_eq_iff]
  apply ModelA.reference_collision_bound_atMost L hL hcap
  · simpa [bytesToMessage] using hm
  · simpa [bytesToMessage] using hm'
  · exact fun h => hne (bytesToMessage_injective h)

/-- The convenient all-length model-A envelope (n+2W-1)/q, W=32. -/
theorem modelA_coarse_bound (n : ℕ) (m m' : Message)
    (hm : m.length < 2^128) (hm' : m'.length < 2^128) (hne : m ≠ m')
    (hn : blockCount m ≤ n) (hn' : blockCount m' ≤ n) :
    uniformProb (fun k : ModelA.Key => ModelA.hash k m = ModelA.hash k m') ≤
      min 1 (((n+63 : ℕ) : ℚ≥0) / 2^128) := by
  apply le_min (ModelA.probability_le_one _) _
  by_cases hc : blockCount m = blockCount m'
  · have h := ModelA.collision_bound_common_blocks 8 (by decide) (by decide) m m'
      hm hm' hne hc (ModelA.blockGroups_properties m _).1
      (ModelA.blockGroups_properties m' _).1
    apply h.trans
    apply div_le_div_of_nonneg_right _ (by positivity)
    apply Nat.cast_le.mpr
    unfold ModelA.countBudget
    split_ifs <;> omega
  · have h := (ModelA.collision_bound_different_blocks n m m' hc hn hn').trans
      (min_le_right _ _)
    apply h.trans
    apply div_le_div_of_nonneg_right _ (by positivity)
    exact_mod_cast (by omega : n+2 ≤ n+63)

theorem ideal_score_numerator (L : ℕ) (hL : 0 < L) :
    max 1 ((L+31)/32) + 2 ≤ 3*L := by omega

theorem modelA_score_numerator (L : ℕ) (hL : 0 < L) :
    ModelA.envelopeNumerator L ≤ 8*L := by
  unfold ModelA.envelopeNumerator ModelA.lastGroups ModelA.remainingWords ModelA.wordBlocks
  split_ifs <;> omega

theorem modelA_fixed_score_numerator (L : ℕ) (hL : 0 < L) :
    ModelA.degreeBudget L + ModelA.wordBlocks L + 1 ≤ 3*L := by
  unfold ModelA.degreeBudget ModelA.wordBlocks
  split_ifs <;> omega

theorem score_at_one : max 1 ((1+31)/32) + 2 = 3 ∧
    ModelA.envelopeNumerator 1 = 8 := by decide

end ProvenHashes.ChainHash128.Strided
