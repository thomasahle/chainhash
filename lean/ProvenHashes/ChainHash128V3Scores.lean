import ProvenHashes.ChainHash128V3Keys

/-! Chart scores `log2(L/ε(L))` of the certified envelopes over positive `L` (64-bit words):
127 for the paper certificate and the refined model A certificate; `128 - log2 33` for the
coarse model A envelope `(p+W)/2^128`, exactly as SPEC states. -/
noncomputable section
namespace ProvenHashes.ChainHash.V3_128
open ProvenHashes.ChainHash128

def score (epsilon : ℕ → ℚ≥0) (L : ℕ) : ℝ := Real.logb 2 ((L : ℝ)/(epsilon L : ℝ))

theorem score_lower_bound (epsilon : ℕ → ℚ≥0) (L : ℕ)
    (hpos : 0 < epsilon L) (hbound : epsilon L ≤ (L : ℚ≥0)/2^127) :
    127 ≤ score epsilon L := by
  have he : (0 : ℝ) < (epsilon L : ℝ) := by exact_mod_cast hpos
  have hb : (epsilon L : ℝ) ≤ (L : ℝ)/2^127 := by
    simpa only [NNRat.cast_div, NNRat.cast_natCast, NNRat.cast_pow, NNRat.cast_ofNat]
      using (NNRat.cast_le (K := ℝ)).mpr hbound
  have hl : 0 < (L : ℝ) := by
    have h := lt_of_lt_of_le he hb
    exact (div_pos_iff_of_pos_right (by positivity)).mp h
  have hr : (2 : ℝ)^127 ≤ (L : ℝ)/(epsilon L : ℝ) := by
    apply (le_div_iff₀ he).mpr
    have h := (le_div_iff₀ (by positivity : (0 : ℝ)<2^127)).mp hb
    nlinarith
  have h := (Real.logb_le_logb (by norm_num : (1 : ℝ)<2)
    (by positivity : (0 : ℝ)<2^127) (div_pos hl he)).mpr hr
  simpa only [Real.logb_pow, Real.logb_self_eq_one (by norm_num : (1 : ℝ) < 2), mul_one, Nat.cast_ofNat, score] using h
-- checkpoint: score_lower_bound

theorem score_lower_bound_coarse (epsilon : ℕ → ℚ≥0) (L : ℕ)
    (hpos : 0 < epsilon L) (hbound : epsilon L ≤ 33*(L : ℚ≥0)/2^128) :
    128 - Real.logb 2 33 ≤ score epsilon L := by
  have he : (0 : ℝ) < (epsilon L : ℝ) := by exact_mod_cast hpos
  have hb : (epsilon L : ℝ) ≤ 33*(L : ℝ)/2^128 := by
    simpa only [NNRat.cast_div, NNRat.cast_mul, NNRat.cast_natCast, NNRat.cast_pow, NNRat.cast_ofNat]
      using (NNRat.cast_le (K := ℝ)).mpr hbound
  have hl : 0 < (L : ℝ) := by
    have h := lt_of_lt_of_le he hb
    have h' := (div_pos_iff_of_pos_right (by positivity : (0 : ℝ) < 2^128)).mp h
    nlinarith
  have hr : (2 : ℝ)^128/33 ≤ (L : ℝ)/(epsilon L : ℝ) := by
    rw [div_le_div_iff₀ (by norm_num) he]
    have h := (le_div_iff₀ (by positivity : (0 : ℝ)<2^128)).mp hb
    nlinarith
  have h := (Real.logb_le_logb (by norm_num : (1 : ℝ)<2)
    (by positivity : (0 : ℝ)<2^128/33) (div_pos hl he)).mpr hr
  rw [Real.logb_div (by norm_num) (by norm_num), Real.logb_pow,
    Real.logb_self_eq_one (by norm_num : (1 : ℝ) < 2)] at h
  simpa only [mul_one, Nat.cast_ofNat, score] using h
-- checkpoint: score_lower_bound_coarse

theorem paper_score (L : ℕ) (hL : 0 < L) : 127 ≤ score paperEpsilon L :=
  score_lower_bound _ L (paperEpsilon_pos L) (paper_score_ratio L hL)
-- checkpoint: paper_score

theorem modelA_score (L : ℕ) (hL : 0 < L) : 127 ≤ score modelAEpsilon L :=
  score_lower_bound _ L (modelAEpsilon_pos L) (modelA_score_ratio L hL)
-- checkpoint: modelA_score

theorem coarse_score (L : ℕ) (hL : 0 < L) : 128 - Real.logb 2 33 ≤ score modelACoarseEpsilon L :=
  score_lower_bound_coarse _ L (coarseEpsilon_pos L) (coarse_score_ratio L hL)
-- checkpoint: coarse_score

theorem scores_at_one : score paperEpsilon 1 = 127 ∧ score modelAEpsilon 1 = 127 := by
  have hs (epsilon : ℕ → ℚ≥0) (he : epsilon 1=1/2^127) : score epsilon 1=127 := by
    simp only [score, he, Nat.cast_one, NNRat.cast_div, NNRat.cast_one,
      NNRat.cast_pow, NNRat.cast_ofNat, one_div_one_div, Real.logb_pow,
      Real.logb_self_eq_one (by norm_num : (1 : ℝ)<2), mul_one]
    norm_num
  exact ⟨hs paperEpsilon score_attained.1, hs modelAEpsilon score_attained.2.1⟩
-- checkpoint: scores_at_one

theorem coarse_score_at_one : score modelACoarseEpsilon 1 = 128 - Real.logb 2 33 := by
  simp only [score, score_attained.2.2, Nat.cast_one, NNRat.cast_div, NNRat.cast_pow,
    NNRat.cast_ofNat, one_div, inv_div, Real.logb_div (by norm_num : (2:ℝ)^128 ≠ 0) (by norm_num : (33:ℝ) ≠ 0),
    Real.logb_pow, Real.logb_self_eq_one (by norm_num : (1 : ℝ)<2), mul_one]
  norm_num
-- checkpoint: coarse_score_at_one

/-- Exact minimum of the paper-model certified envelope score: 127 bits, attained at `L = 1`. -/
theorem paper_score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score paperEpsilon L.val)) 127 := by
  constructor
  · exact ⟨⟨1,by decide⟩,scores_at_one.1⟩
  · rintro _ ⟨L,rfl⟩
    exact paper_score L.val L.property
-- checkpoint: paper_score_minimum

/-- Exact minimum of the refined model A certified envelope score: 127 bits at `L = 1`. -/
theorem modelA_score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score modelAEpsilon L.val)) 127 := by
  constructor
  · exact ⟨⟨1,by decide⟩,scores_at_one.2⟩
  · rintro _ ⟨L,rfl⟩
    exact modelA_score L.val L.property
-- checkpoint: modelA_score_minimum

/-- SPEC: scoring only the coarse model A envelope `(p+W)/q` reports `128 - log2(W+1)`,
`W = 32`, i.e. `128 - log2 33 = 122.955606...` bits; exact minimum at `L = 1`. -/
theorem modelA_coarse_score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score modelACoarseEpsilon L.val))
      (128 - Real.logb 2 33) := by
  constructor
  · exact ⟨⟨1,by decide⟩,coarse_score_at_one⟩
  · rintro _ ⟨L,rfl⟩
    exact coarse_score L.val L.property
-- checkpoint: modelA_coarse_score_minimum

/-- SPEC's `E_A(L) = p_B(L) + d_B(L)` for `L = 1..20`. -/
theorem envelope_table :
    ([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20].map modelANumerator) =
      [2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,10,10] := by decide
-- checkpoint: envelope_table

/-- SPEC examples: 1 KiB (`L = 128`): paper 9, coarse 40, refined 16;
1 MiB (`L = 131072`): `p = 2048`, paper 2049, coarse 2080, refined 2080. -/
theorem envelope_large_examples :
    ([128, 131072].map (fun L => (paperNumerator L, coarseNumerator L, modelANumerator L))) =
      [(9, 40, 16), (2049, 2080, 2080)] := by decide
-- checkpoint: envelope_large_examples

end ProvenHashes.ChainHash.V3_128
