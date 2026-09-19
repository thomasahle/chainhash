import ProvenHashes.ChainHash128.Keys

/-! Scores `log2(L/ε(L))` of the certified envelopes over positive `L` (64-bit words):
127 for the ideal-key certificate and for the certificate with 128 random key bytes;
`128 - log2 33` for the coarse envelope `(p+W)/2^128`. -/
noncomputable section
namespace ProvenHashes.ChainHash128
open ProvenHashes.ChainHash

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

theorem idealKey_score (L : ℕ) (hL : 0 < L) : 127 ≤ score idealKeyEpsilon L :=
  score_lower_bound _ L (idealKeyEpsilon_pos L) (idealKey_score_ratio L hL)
-- checkpoint: idealKey_score

theorem epsilon_score (L : ℕ) (hL : 0 < L) : 127 ≤ score epsilon L :=
  score_lower_bound _ L (epsilon_pos L) (score_ratio L hL)
-- checkpoint: epsilon_score

theorem coarse_score (L : ℕ) (hL : 0 < L) : 128 - Real.logb 2 33 ≤ score coarseEpsilon L :=
  score_lower_bound_coarse _ L (coarseEpsilon_pos L) (coarse_score_ratio L hL)
-- checkpoint: coarse_score

theorem scores_at_one : score idealKeyEpsilon 1 = 127 ∧ score epsilon 1 = 127 := by
  have hs (epsilon : ℕ → ℚ≥0) (he : epsilon 1=1/2^127) : score epsilon 1=127 := by
    simp only [score, he, Nat.cast_one, NNRat.cast_div, NNRat.cast_one,
      NNRat.cast_pow, NNRat.cast_ofNat, one_div_one_div, Real.logb_pow,
      Real.logb_self_eq_one (by norm_num : (1 : ℝ)<2), mul_one]
    norm_num
  exact ⟨hs idealKeyEpsilon score_attained.1, hs epsilon score_attained.2.1⟩
-- checkpoint: scores_at_one

theorem coarse_score_at_one : score coarseEpsilon 1 = 128 - Real.logb 2 33 := by
  simp only [score, score_attained.2.2, Nat.cast_one, NNRat.cast_div, NNRat.cast_pow,
    NNRat.cast_ofNat, one_div, inv_div, Real.logb_div (by norm_num : (2:ℝ)^128 ≠ 0) (by norm_num : (33:ℝ) ≠ 0),
    Real.logb_pow, Real.logb_self_eq_one (by norm_num : (1 : ℝ)<2), mul_one]
  norm_num
-- checkpoint: coarse_score_at_one

/-- Exact minimum of the ideal-key certified envelope score: 127 bits, attained at `L = 1`. -/
theorem ideal_key_score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score idealKeyEpsilon L.val)) 127 := by
  constructor
  · exact ⟨⟨1,by decide⟩,scores_at_one.1⟩
  · rintro _ ⟨L,rfl⟩
    exact idealKey_score L.val L.property
-- checkpoint: ideal_key_score_minimum

/-- Exact minimum of the certified envelope score for 128 random key bytes: 127 bits at `L = 1`. -/
theorem score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score epsilon L.val)) 127 := by
  constructor
  · exact ⟨⟨1,by decide⟩,scores_at_one.2⟩
  · rintro _ ⟨L,rfl⟩
    exact epsilon_score L.val L.property
-- checkpoint: score_minimum

/-- Scoring only the coarse envelope `(p+W)/q` reports `128 - log2(W+1)`,
`W = 32`, i.e. `128 - log2 33 = 122.955606...` bits; exact minimum at `L = 1`. -/
theorem coarse_score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score coarseEpsilon L.val))
      (128 - Real.logb 2 33) := by
  constructor
  · exact ⟨⟨1,by decide⟩,coarse_score_at_one⟩
  · rintro _ ⟨L,rfl⟩
    exact coarse_score L.val L.property
-- checkpoint: coarse_score_minimum

/-- `p_B(L) + d_B(L)` for `L = 1..20`. -/
theorem envelope_table :
    ([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20].map numerator) =
      [2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,10,10] := by decide
-- checkpoint: envelope_table

/-- Examples: 1 KiB (`L = 128`): ideal key 9, coarse 40, refined 16;
1 MiB (`L = 131072`): `p = 2048`, ideal key 2049, coarse 2080, refined 2080. -/
theorem envelope_large_examples :
    ([128, 131072].map (fun L => (idealKeyNumerator L, coarseNumerator L, numerator L))) =
      [(9, 40, 16), (2049, 2080, 2080)] := by decide
-- checkpoint: envelope_large_examples

end ProvenHashes.ChainHash128
