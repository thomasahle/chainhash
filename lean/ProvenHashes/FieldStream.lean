import ProvenHashes.Stream

noncomputable section
namespace ProvenHashes.ChainHash
open Polynomial

def lowWord (p : BitsPolynomial) : Word 64 := fun i => p.coeff i.val
def highWord (p : BitsPolynomial) : Word 64 := fun i => p.coeff (i.val + 64)

theorem splitWords_injective {p q : BitsPolynomial} (hp : p.natDegree < 128)
    (hq : q.natDegree < 128)
    (hl : lowWord p = lowWord q) (hh : highWord p = highWord q) : p = q := by
  ext i
  by_cases hi : i < 64
  · exact congrFun hl ⟨i, hi⟩
  · by_cases hi' : i < 128
    · have he := congrFun hh ⟨i - 64, by omega⟩
      simpa only [highWord, Nat.sub_add_cancel (by omega : 64 ≤ i)] using he
    · have hp' : p.coeff i = 0 := coeff_eq_zero_of_natDegree_lt (by omega)
      have hq' : q.coeff i = 0 := coeff_eq_zero_of_natDegree_lt (by omega)
      rw [hp', hq']

theorem lengthMask_natDegree_le (n : ℕ) : (lengthMask n).natDegree ≤ 127 := by
  have hp := Polynomial.ofFn_natDegree_lt (R := ZMod 2) (by omega : 1 ≤ 64) (lengthWord n)
  have hq : (1 + X ^ 64 : BitsPolynomial).natDegree ≤ 64 := by
    exact Polynomial.natDegree_add_le_of_degree_le (by simp) (by simp)
  apply Polynomial.natDegree_mul_le.trans
  change (Polynomial.ofFn 64 (lengthWord n)).natDegree + _ ≤ 127
  omega

theorem rawDigest_natDegree_lt (m : Message) (k : BlockKey) (t : ℕ) :
    (rawDigest m k t).natDegree < 128 := by
  unfold rawDigest
  apply lt_of_le_of_lt (Polynomial.natDegree_add_le _ _)
  have h₁ := clnh_natDegree_le (activePairs m t) (blockData m t) k
  have h₂ := lengthMask_natDegree_le m.length
  split_ifs <;> simp_all only [Polynomial.natDegree_zero, max_lt_iff] <;> omega

def splitField {F : Type*} [AddGroup F] (repr : Word 64 ≃+ F) (p : BitsPolynomial) : F × F :=
  (repr (lowWord p), repr (highWord p))

theorem splitField_injective {F : Type*} [AddGroup F] (repr : Word 64 ≃+ F)
    {p q : BitsPolynomial} (hp : p.natDegree < 128) (hq : q.natDegree < 128)
    (h : splitField repr p = splitField repr q) : p = q :=
  splitWords_injective hp hq (repr.injective (congrArg Prod.fst h))
    (repr.injective (congrArg Prod.snd h))

def stream {F : Type*} [AddGroup F] (repr : Word 64 ≃+ F) (m : Message) (k : BlockKey) :
    List (F × F) := (rawStream m k).map (splitField repr)

theorem stream_length {F : Type*} [AddGroup F] (repr : Word 64 ≃+ F)
    (m : Message) (k : BlockKey) : (stream repr m k).length = blockCount m := by
  simp [stream, rawStream_length]

theorem stream_eq_rawStream {F : Type*} [AddGroup F] (repr : Word 64 ≃+ F)
    (m m' : Message) (k : BlockKey) (h : stream repr m k = stream repr m' k) :
    rawStream m k = rawStream m' k := by
  have hc : blockCount m = blockCount m' := by
    simpa only [stream_length] using congrArg List.length h
  apply List.ext_getElem (by simp only [rawStream_length, hc])
  intro i hi hi'
  have ht : i < blockCount m := by simpa only [rawStream_length] using hi
  have ht' : i < blockCount m' := by simpa only [rawStream_length] using hi'
  have he := congrArg (fun l : List (F × F) => l[i]?) h
  have he' : splitField repr (rawDigest m k i) = splitField repr (rawDigest m' k i) := by
    simpa [stream, rawStream, ht, ht'] using he
  have he'' := splitField_injective repr (rawDigest_natDegree_lt m k i)
    (rawDigest_natDegree_lt m' k i) he'
  simpa only [rawStream, List.getElem_ofFn] using he''

theorem stream_collision_bound {F : Type*} [AddGroup F] (repr : Word 64 ≃+ F)
    (m m' : Message) (hm : m.length < 2 ^ 64) (hm' : m'.length < 2 ^ 64) (hne : m ≠ m') :
    uniformProb (fun k => stream repr m k = stream repr m' k) ≤ 1 / (2 : ℚ≥0) ^ 64 :=
  (uniformProb_mono (fun k hk => stream_eq_rawStream repr m m' k hk)).trans
    (rawStream_collision_bound m m' hm hm' hne)

end ProvenHashes.ChainHash
