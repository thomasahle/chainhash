import ProvenHashes.CarrylessVariable
import ProvenHashes.ByteEncoding

noncomputable section
namespace ProvenHashes.ChainHash
open Polynomial

/-- XOR the byte length into both 64-bit halves of the final digest. -/
def lengthMask (n : ℕ) : BitsPolynomial := pack 64 (lengthWord n) * (1 + X ^ 64)

theorem lengthMask_injective {n n' : ℕ} (hn : n < 2 ^ 64) (hn' : n' < 2 ^ 64)
    (h : lengthMask n = lengthMask n') : n = n' := by
  have hm : (1 + X ^ 64 : BitsPolynomial) ≠ 0 := by
    intro hz
    have hc := congrArg (fun p : BitsPolynomial => p.coeff 64) hz
    norm_num [Polynomial.coeff_one] at hc
  exact lengthWord_injective hn hn' (pack_injective 64 (mul_right_cancel₀ hm h))

abbrev BlockKey := Fin 16 × Bool → Word 64

def rawDigest (m : Message) (k : BlockKey) (t : ℕ) : BitsPolynomial :=
  clnh (activePairs m t) (blockData m t) k +
    if t + 1 = blockCount m then lengthMask m.length else 0

def rawStream (m : Message) (k : BlockKey) : List BitsPolynomial :=
  List.ofFn fun i : Fin (blockCount m) => rawDigest m k i.val

theorem rawStream_length (m : Message) (k : BlockKey) :
    (rawStream m k).length = blockCount m := by simp [rawStream]

theorem rawStream_eq_digest (m m' : Message) (k : BlockKey)
    (h : rawStream m k = rawStream m' k) (t : ℕ)
    (ht : t < blockCount m) (ht' : t < blockCount m') :
    rawDigest m k t = rawDigest m' k t := by
  have he := congrArg (fun l : List BitsPolynomial => l[t]?.getD 0) h
  simpa [rawStream, ht, ht'] using he

theorem rawStream_different_counts (m m' : Message) (k : BlockKey)
    (h : blockCount m ≠ blockCount m') : rawStream m k ≠ rawStream m' k := by
  intro he
  apply h
  simpa only [rawStream_length] using congrArg List.length he

theorem rawStream_equal_length_bound (m m' : Message)
    (hlen : m.length = m'.length) (hne : m ≠ m') :
    uniformProb (fun k => rawStream m k = rawStream m' k) ≤ 1 / (2 : ℚ≥0) ^ 64 := by
  classical
  have hex : ∃ t, t < blockCount m ∧ ∃ s ∈ activePairs m t, ∃ b,
      blockData m t (s, b) ≠ blockData m' t (s, b) := by
    by_contra! h
    exact hne (block_encoding_injective m m' hlen h)
  obtain ⟨t, ht, s, hs, b, hb⟩ := hex
  have hc : blockCount m = blockCount m' := by simp [blockCount, hlen]
  have ha : activePairs m t = activePairs m' t := by simp [activePairs, blockBytes, hlen]
  refine (uniformProb_mono (D := fun k =>
    clnh (activePairs m t) (blockData m t) k -
      clnh (activePairs m t) (blockData m' t) k = 0) ?_).trans
        (clnh_difference_bound _ _ _ ⟨s, hs, b, hb⟩ 0)
  intro k hk
  have he := rawStream_eq_digest m m' k hk t ht (hc ▸ ht)
  unfold rawDigest at he
  rw [← hc, ← ha, ← hlen] at he
  exact sub_eq_zero.mpr (add_right_cancel he)

theorem rawStream_different_length_bound (m m' : Message)
    (hm : m.length < 2 ^ 64) (hm' : m'.length < 2 ^ 64)
    (hlen : m.length ≠ m'.length) (hc : blockCount m = blockCount m') :
    uniformProb (fun k => rawStream m k = rawStream m' k) ≤ 1 / (2 : ℚ≥0) ^ 64 := by
  classical
  let t := blockCount m - 1
  have hpos : 0 < blockCount m := by unfold blockCount; omega
  have ht : t < blockCount m := by omega
  have hlast : t + 1 = blockCount m := by omega
  let C := lengthMask m.length + lengthMask m'.length
  have hC : C ≠ 0 := by
    intro h
    exact hlen (lengthMask_injective hm hm' (CharTwo.add_eq_zero.mp h))
  refine (uniformProb_mono (D := fun k =>
    clnh (activePairs m t) (blockData m t) k +
      clnh (activePairs m' t) (blockData m' t) k = C) ?_).trans
        (clnh_comparable_nonzero_bound _ _ (activePairs_comparable m m' t t) _ _ C hC)
  intro k hk
  have he := rawStream_eq_digest m m' k hk t ht (hc ▸ ht)
  simp only [rawDigest, hlast, ← hc, if_true] at he
  apply CharTwo.add_eq_zero.mp
  change (_ + _) + (lengthMask m.length + lengthMask m'.length) = 0
  calc
    _ = (clnh (activePairs m t) (blockData m t) k + lengthMask m.length) +
        (clnh (activePairs m' t) (blockData m' t) k + lengthMask m'.length) := by abel
    _ = 0 := by rw [he, CharTwo.add_self_eq_zero]

theorem rawStream_collision_bound (m m' : Message)
    (hm : m.length < 2 ^ 64) (hm' : m'.length < 2 ^ 64) (hne : m ≠ m') :
    uniformProb (fun k => rawStream m k = rawStream m' k) ≤ 1 / (2 : ℚ≥0) ^ 64 := by
  classical
  by_cases hc : blockCount m = blockCount m'
  · by_cases hl : m.length = m'.length
    · exact rawStream_equal_length_bound m m' hl hne
    · exact rawStream_different_length_bound m m' hm hm' hl hc
  · have he : (fun k => rawStream m k = rawStream m' k) = (fun _ : BlockKey => False) := by
      funext k
      exact propext (iff_false_intro (rawStream_different_counts m m' k hc))
    rw [he]
    simp [uniformProb]

end ProvenHashes.ChainHash
