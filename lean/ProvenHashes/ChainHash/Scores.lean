import ProvenHashes.ChainHash.Keys

noncomputable section
namespace ProvenHashes.ChainHash

def score (epsilon : ℕ → ℚ≥0) (L : ℕ) : ℝ := Real.logb 2 ((L : ℝ)/(epsilon L : ℝ))

theorem score_lower_bound (epsilon : ℕ → ℚ≥0) (L : ℕ)
    (hpos : 0 < epsilon L) (hbound : epsilon L ≤ (L : ℚ≥0)/2^63) :
    63 ≤ score epsilon L := by
  have he : (0 : ℝ) < (epsilon L : ℝ) := by exact_mod_cast hpos
  have hb : (epsilon L : ℝ) ≤ (L : ℝ)/2^63 := by
    simpa only [NNRat.cast_div, NNRat.cast_natCast, NNRat.cast_pow, NNRat.cast_ofNat]
      using (NNRat.cast_le (K := ℝ)).mpr hbound
  have hl : 0 < (L : ℝ) := by
    have h := lt_of_lt_of_le he hb
    exact (div_pos_iff_of_pos_right (by positivity)).mp h
  have hr : (2 : ℝ)^63 ≤ (L : ℝ)/(epsilon L : ℝ) := by
    apply (le_div_iff₀ he).mpr
    have h := (le_div_iff₀ (by positivity : (0 : ℝ)<2^63)).mp hb
    nlinarith
  have h := (Real.logb_le_logb (by norm_num : (1 : ℝ)<2)
    (by positivity : (0 : ℝ)<2^63) (div_pos hl he)).mpr hr
  simpa only [Real.logb_pow, Real.logb_self_eq_one (by norm_num : (1 : ℝ) < 2), mul_one, Nat.cast_ofNat, score] using h
-- checkpoint: score_lower_bound

theorem idealKey_score (L : ℕ) (hL : 0 < L) : 63 ≤ score idealKeyEpsilon L := by
  apply score_lower_bound _ L ?_ (idealKey_score_ratio L hL)
  unfold idealKeyEpsilon
  positivity
-- checkpoint: idealKey_score

theorem epsilon_score (L : ℕ) (hL : 0 < L) : 63 ≤ score epsilon L := by
  apply score_lower_bound _ L ?_ (score_ratio L hL)
  have hp := blocks_pos (8*L)
  unfold epsilon
  positivity
-- checkpoint: epsilon_score

theorem scores_at_one : score idealKeyEpsilon 1 = 63 ∧ score epsilon 1 = 63 := by
  have hs (epsilon : ℕ → ℚ≥0) (he : epsilon 1=1/2^63) : score epsilon 1=63 := by
    simp only [score, he, Nat.cast_one, NNRat.cast_div, NNRat.cast_one,
      NNRat.cast_pow, NNRat.cast_ofNat, one_div_one_div, Real.logb_pow,
      Real.logb_self_eq_one (by norm_num : (1 : ℝ)<2), mul_one]
    norm_num
  exact ⟨hs idealKeyEpsilon score_attained.1, hs epsilon score_attained.2⟩
-- checkpoint: scores_at_one

/-- Exact minimum of the ideal-key certified envelope score. -/
theorem ideal_key_score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score idealKeyEpsilon L.val)) 63 := by
  constructor
  · exact ⟨⟨1,by decide⟩,scores_at_one.1⟩
  · rintro _ ⟨L,rfl⟩
    exact idealKey_score L.val L.property
-- checkpoint: ideal_key_score_minimum

/-- Exact minimum of the certified envelope score for 64 random key bytes: 63 bits at `L = 1`. -/
theorem score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score epsilon L.val)) 63 := by
  constructor
  · exact ⟨⟨1,by decide⟩,scores_at_one.2⟩
  · rintro _ ⟨L,rfl⟩
    exact epsilon_score L.val L.property
-- checkpoint: score_minimum

theorem envelope_table :
    ([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20].map
      (fun L => degreeBudget L+blocks (8*L))) =
      [2,3,4,4,5,5,6,6,8,8,8,8,8,8,8,8,10,12,12,12] := by decide
-- checkpoint: envelope_table

theorem envelope_large_examples :
    ([32,121,128,129,1024,131072].map (fun L => degreeBudget L+blocks (8*L))) =
      [12,36,36,37,64,4128] := by decide
-- checkpoint: envelope_large_examples

end ProvenHashes.ChainHash
