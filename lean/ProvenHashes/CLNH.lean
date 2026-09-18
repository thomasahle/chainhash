/-
Level 1 of ChainHash: the UNREDUCED carry-less NH (CLNH) block hash over `R = GF(2)[X]`,
with the full `2b`-bit (degree < 2b-1) value kept.

This is the appendix's Lemma `lem:ph:clnh` ("CLNH is 2^-64-XOR-universal on 128 bits"),
NOT the field-NH statement of `NH.lean`: no reduction modulo the irreducible polynomial
takes place, so values live in the polynomial ring `GF(2)[X]`, an integral domain that is
not a field, and the proof may not divide.
-/
import ProvenHashes.Composition

namespace ProvenHashes
namespace CLNH

open scoped BigOperators
open Polynomial

/-! ### General uniform-probability tools -/

/-- An event with at most one satisfying key has probability at most `1/|K|`. -/
lemma uniformProb_le_one_div {K : Type*} [Fintype K] (E : K → Prop)
    (h : ∀ a b, E a → E b → a = b) : uniformProb E ≤ 1 / (Fintype.card K : ℚ≥0) := by
  classical
  have hc : (Finset.univ.filter E).card ≤ 1 := by
    rw [Finset.card_le_one]
    intro a ha b hb
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at ha hb
    exact h a b ha hb
  have hc' : ((Finset.univ.filter E).card : ℚ≥0) ≤ 1 := by exact_mod_cast hc
  unfold uniformProb
  exact div_le_div_of_nonneg_right hc' (by positivity)

lemma uniformProb_eq_zero {K : Type*} [Fintype K] (E : K → Prop) (h : ∀ k, ¬ E k) :
    uniformProb E = 0 := by
  classical
  have he : (Finset.univ.filter E) = ∅ := by
    ext k
    simp [h k]
  unfold uniformProb
  rw [he]
  simp

/-- Complementary events. -/
lemma uniformProb_compl {K : Type*} [Fintype K] [Nonempty K] (E : K → Prop) :
    uniformProb (fun k => ¬ E k) + uniformProb E = 1 := by
  classical
  have hK : (Fintype.card K : ℚ≥0) ≠ 0 := by exact_mod_cast Fintype.card_ne_zero
  have hcard : ∀ s t : Finset K, (∀ k, k ∈ s ↔ ¬ E k) → (∀ k, k ∈ t ↔ E k) →
      s.card + t.card = Fintype.card K := by
    intro s t hs ht
    have hst : s = tᶜ := by
      ext k
      simp [hs, ht]
    have hle : t.card ≤ Fintype.card K := by
      simpa [Finset.card_univ] using Finset.card_le_card (Finset.subset_univ t)
    rw [hst]
    exact Finset.card_compl_add_card t
  unfold uniformProb
  rw [← add_div, ← Nat.cast_add,
    hcard _ _ (by intro k; simp) (by intro k; simp)]
  exact div_self hK

/-- **The counting step.** If the value `f k` is an injective function of the single key
coordinate `i` whenever `P` holds, and `P` never looks at coordinate `i`, then pinning `f`
down to `t` costs a factor `1/|V|` on top of `P`. -/
theorem uniformProb_and_le_of_injective_update {I V W : Type*}
    [Fintype I] [DecidableEq I] [Fintype V] [Nonempty V]
    (f : (I → V) → W) (P : (I → V) → Prop) (i : I) (t : W)
    (hP : ∀ k v, P (Function.update k i v) ↔ P k)
    (hinj : ∀ k, P k → Function.Injective fun v => f (Function.update k i v)) :
    uniformProb (fun k => f k = t ∧ P k) ≤ uniformProb P / (Fintype.card V : ℚ≥0) := by
  classical
  let split := Equiv.funSplitAt i V
  let v₀ : V := Classical.arbitrary V
  let e : ({j // j ≠ i} → V) × V ≃ (I → V) := (Equiv.prodComm _ _).trans split.symm
  have hu : ∀ (r : {j // j ≠ i} → V) (v : V),
      e (r, v) = Function.update (split.symm (v₀, r)) i v := by
    intro r v
    funext j
    by_cases hj : j = i
    · subst j
      simp [e, split]
    · simp [e, split, Function.update, hj]
  have key : ∀ r : {j // j ≠ i} → V,
      uniformProb (fun v => f (e (r, v)) = t ∧ P (e (r, v)))
        ≤ uniformProb (fun v => P (e (r, v))) / (Fintype.card V : ℚ≥0) := by
    intro r
    by_cases hp : P (split.symm (v₀, r))
    · have hall : ∀ v, P (e (r, v)) := by
        intro v
        rw [hu r v, hP]
        exact hp
      have h1 : (fun v => P (e (r, v))) = fun _ => True :=
        funext fun v => propext ⟨fun _ => trivial, fun _ => hall v⟩
      rw [h1, uniformProb_const, if_pos trivial]
      apply uniformProb_le_one_div
      intro a b ha hb
      apply hinj (split.symm (v₀, r)) hp
      show f (Function.update (split.symm (v₀, r)) i a)
          = f (Function.update (split.symm (v₀, r)) i b)
      rw [← hu r a, ← hu r b, ha.1, hb.1]
    · have hnone : ∀ v, ¬ (f (e (r, v)) = t ∧ P (e (r, v))) := by
        intro v hv
        refine hp ?_
        rw [← hP _ v, ← hu r v]
        exact hv.2
      rw [uniformProb_eq_zero _ hnone]
      positivity
  calc uniformProb (fun k => f k = t ∧ P k)
      = uniformProb (fun q : ({j // j ≠ i} → V) × V => f (e q) = t ∧ P (e q)) :=
        (uniformProb_equiv e _).symm
    _ = (∑ r : {j // j ≠ i} → V,
          uniformProb (fun v => f (e (r, v)) = t ∧ P (e (r, v)))) /
            (Fintype.card ({j // j ≠ i} → V) : ℚ≥0) := uniformProb_prod _
    _ ≤ (∑ r : {j // j ≠ i} → V,
          uniformProb (fun v => P (e (r, v))) / (Fintype.card V : ℚ≥0)) /
            (Fintype.card ({j // j ≠ i} → V) : ℚ≥0) :=
        div_le_div_of_nonneg_right (Finset.sum_le_sum fun r _ => key r) (by positivity)
    _ = ((∑ r : {j // j ≠ i} → V, uniformProb (fun v => P (e (r, v)))) /
            (Fintype.card ({j // j ≠ i} → V) : ℚ≥0)) / (Fintype.card V : ℚ≥0) := by
        rw [← Finset.sum_div, div_div, div_div, mul_comm]
    _ = uniformProb P / (Fintype.card V : ℚ≥0) := by
        rw [← uniformProb_prod (fun q : ({j // j ≠ i} → V) × V => P (e q)), uniformProb_equiv]

/-- The unconditional form of the counting step. -/
theorem uniformProb_le_of_injective_update {I V W : Type*}
    [Fintype I] [DecidableEq I] [Fintype V] [Nonempty V]
    (f : (I → V) → W) (i : I) (t : W)
    (hinj : ∀ k, Function.Injective fun v => f (Function.update k i v)) :
    uniformProb (fun k => f k = t) ≤ 1 / (Fintype.card V : ℚ≥0) := by
  have h := uniformProb_and_le_of_injective_update f (fun _ => True) i t
    (fun k v => Iff.rfl) (fun k _ => hinj k)
  have h1 : (fun k : I → V => f k = t ∧ True) = fun k => f k = t := by
    funext k
    simp
  rw [h1] at h
  rwa [uniformProb_const, if_pos trivial] at h

/-- Every coordinate of a uniform key in a function space is itself uniform: this is how the
appendix uses that each key segment `κ^(i)` is uniform on its own. -/
lemma uniformProb_coord {I A : Type*} [Fintype I] [DecidableEq I] [Fintype A] [Nonempty A]
    (i : I) (E : A → Prop) :
    uniformProb (fun k : I → A => E (k i)) = uniformProb E := by
  classical
  let split := Equiv.funSplitAt i A
  have h1 : uniformProb (fun k : I → A => E (k i))
      = uniformProb (fun q : A × ({j // j ≠ i} → A) => E ((split.symm q) i)) :=
    (uniformProb_equiv split.symm _).symm
  have h2 : (fun q : A × ({j // j ≠ i} → A) => E ((split.symm q) i))
      = fun q : A × ({j // j ≠ i} → A) => E q.1 := by
    funext q
    congr 1
    simp [split]
  rw [h1, h2, uniformProb_prod_fst]

/-! ### Words and the carry-less product -/

/-- The coefficient field `F₂`. -/
abbrev Bit := ZMod 2

/-- `R = F₂[X]`, the ring `𝓡` of the appendix. Addition is XOR. -/
abbrev R := Polynomial Bit

/-- A `b`-bit machine word; bit `i` is the coefficient of `X^i`. -/
abbrev Word (b : ℕ) := Fin b → Bit

/-- The appendix's identification of `b`-bit words with `𝓡_{<b}`. -/
def wordPoly {b : ℕ} (w : Word b) : R := Polynomial.ofFn b w

lemma wordPoly_injective {b : ℕ} : Function.Injective (wordPoly (b := b)) :=
  Polynomial.injective_ofFn b

@[simp] lemma wordPoly_add {b : ℕ} (x y : Word b) :
    wordPoly (x + y) = wordPoly x + wordPoly y := map_add _ _ _

@[simp] lemma wordPoly_zero {b : ℕ} : wordPoly (0 : Word b) = 0 := map_zero _

/-- XOR of two words is zero exactly when they are equal (characteristic two). -/
lemma wordPoly_add_eq_zero_iff {b : ℕ} {x y : Word b} :
    wordPoly x + wordPoly y = 0 ↔ x = y := by
  constructor
  · intro h
    apply wordPoly_injective
    rwa [← sub_eq_zero, CharTwo.sub_eq_add]
  · rintro rfl
    exact CharTwo.add_self_eq_zero _

/-- Words land in `𝓡_{<b}`. -/
lemma wordPoly_degree_lt {b : ℕ} (w : Word b) : (wordPoly w).degree < (b : ℕ) :=
  Polynomial.ofFn_degree_lt w

/-- ... and cover all of `𝓡_{<b}`: a uniform word is a uniform element of `𝓡_{<b}`. -/
lemma wordPoly_surjective {b : ℕ} {p : R} (hp : p.degree < (b : ℕ)) :
    ∃ w : Word b, wordPoly w = p := by
  classical
  by_cases h0 : p = 0
  · exact ⟨0, by simp [h0]⟩
  · exact ⟨Polynomial.toFn b p,
      Polynomial.ofFn_comp_toFn_eq_id_of_natDegree_lt
        ((Polynomial.natDegree_lt_iff_degree_lt h0).mpr hp)⟩

@[simp] lemma card_word (b : ℕ) : Fintype.card (Word b) = 2 ^ b := by simp

lemma card_word_cast (b : ℕ) : ((Fintype.card (Word b) : ℚ≥0)) = (2 ^ b : ℚ≥0) := by
  rw [card_word]
  push_cast
  ring

lemma natDegree_wordPoly_le {b : ℕ} (w : Word b) : (wordPoly w).natDegree ≤ b - 1 := by
  by_cases h : wordPoly w = 0
  · simp [h]
  · have := (Polynomial.natDegree_lt_iff_degree_lt h).mpr (wordPoly_degree_lt w)
    omega

/-! ### CLNH

`np` is the number of key word *pairs* of a key segment (the appendix's `W_s/2`); a
sub-block has `w ≤ np` pairs, and `(s, false)`, `(s, true)` are the appendix's word
positions `2s`, `2s+1`. -/

/-- The unreduced carry-less NH value, `eq:ph:clnh`: the XOR of the `w` carry-less products
`(g_{2s} + k_{2s})(g_{2s+1} + k_{2s+1})`, taken in `GF(2)[X]` with no reduction. -/
noncomputable def clnh {b np : ℕ} (k : Fin np × Bool → Word b) {w : ℕ} (hw : w ≤ np)
    (g : Fin w × Bool → Word b) : R :=
  ∑ s : Fin w,
    (wordPoly (g (s, false)) + wordPoly (k (s.castLE hw, false))) *
      (wordPoly (g (s, true)) + wordPoly (k (s.castLE hw, true)))

/-- An empty sub-block contributes the empty sum. -/
@[simp] lemma clnh_empty {b np : ℕ} (k : Fin np × Bool → Word b) (hw : 0 ≤ np)
    (g : Fin 0 × Bool → Word b) : clnh k hw g = 0 := by
  simp [clnh]

/-- Every carry-less product has degree `< 2b-1`, hence so has the block value: for `b = 64`
this is the appendix's `𝓡_{<127} ⊆ 𝓡_{<128}`, the full unreduced 128-bit width. -/
lemma clnh_natDegree_le {b np w : ℕ} (k : Fin np × Bool → Word b) (hw : w ≤ np)
    (g : Fin w × Bool → Word b) : (clnh k hw g).natDegree ≤ 2 * (b - 1) := by
  apply Polynomial.natDegree_sum_le_of_forall_le
  intro s _
  refine Polynomial.natDegree_mul_le.trans ?_
  have h1 : (wordPoly (g (s, false)) + wordPoly (k (s.castLE hw, false))).natDegree ≤ b - 1 := by
    rw [← wordPoly_add]
    exact natDegree_wordPoly_le _
  have h2 : (wordPoly (g (s, true)) + wordPoly (k (s.castLE hw, true))).natDegree ≤ b - 1 := by
    rw [← wordPoly_add]
    exact natDegree_wordPoly_le _
  omega

lemma clnh_degree_lt {b np w : ℕ} (hb : 0 < b) (k : Fin np × Bool → Word b) (hw : w ≤ np)
    (g : Fin w × Bool → Word b) : (clnh k hw g).degree < ((2 * b - 1 : ℕ) : ℕ) := by
  by_cases h : clnh k hw g = 0
  · rw [h, Polynomial.degree_zero]
    exact WithBot.bot_lt_coe _
  · rw [← Polynomial.natDegree_lt_iff_degree_lt h]
    have := clnh_natDegree_le k hw g
    omega

/-! ### XOR-universality -/

/-- Updating one key word: only the `s`-th product changes, and the updated word is one of
its two factors. -/
lemma clnh_update {b np w : ℕ} (hw : w ≤ np) (g : Fin w × Bool → Word b) (s : Fin w) (c : Bool)
    (k : Fin np × Bool → Word b) (v : Word b) :
    clnh (Function.update k (s.castLE hw, c) v) hw g
      = (wordPoly (g (s, c)) + wordPoly v) *
          (wordPoly (g (s, !c)) + wordPoly (k (s.castLE hw, !c)))
        + ∑ x ∈ Finset.univ.erase s,
            (wordPoly (g (x, false)) + wordPoly (k (x.castLE hw, false))) *
              (wordPoly (g (x, true)) + wordPoly (k (x.castLE hw, true))) := by
  classical
  unfold clnh
  rw [← Finset.add_sum_erase _ _ (Finset.mem_univ s)]
  congr 1
  · cases c with
    | false =>
        simp only [Bool.not_false]
        rw [Function.update_self, Function.update_of_ne (by simp)]
    | true =>
        simp only [Bool.not_true]
        rw [Function.update_self, Function.update_of_ne (by simp)]
        ring
  · refine Finset.sum_congr rfl fun x hx => ?_
    have hxs : x ≠ s := (Finset.mem_erase.mp hx).1
    have hne : ∀ d : Bool, ((x.castLE hw : Fin np), d) ≠ ((s.castLE hw : Fin np), c) := by
      intro d hd
      exact hxs (Fin.castLE_injective hw (congrArg Prod.fst hd))
    rw [Function.update_of_ne (hne false), Function.update_of_ne (hne true)]

/-- A key word that no pair of the sub-block uses cannot change its value. -/
lemma clnh_update_of_le {b np w : ℕ} (hw : w ≤ np) (g : Fin w × Bool → Word b)
    (k : Fin np × Bool → Word b) (jj : Fin np) (hjj : w ≤ (jj : ℕ)) (d : Bool) (v : Word b) :
    clnh (Function.update k (jj, d) v) hw g = clnh k hw g := by
  classical
  unfold clnh
  refine Finset.sum_congr rfl fun x _ => ?_
  have hne : ∀ d' : Bool, ((x.castLE hw : Fin np), d') ≠ (jj, d) := by
    intro d' hd
    have h1 : (x.castLE hw : Fin np) = jj := congrArg Prod.fst hd
    have h2 : (x : ℕ) = (jj : ℕ) := by simpa using congrArg Fin.val h1
    have h3 := x.isLt
    omega
  rw [Function.update_of_ne (hne false), Function.update_of_ne (hne true)]

/-- The appendix's key computation: as a function of the key word `k_{2s+1-c}`, the XOR of
the two CLNH values is `δ·k + const` with `δ = g_{2s+c} + g'_{2s+c}`; the `k k'` terms cancel
because the characteristic is two. -/
lemma clnh_sum_update_sub {b np w : ℕ} (hw : w ≤ np) (g g' : Fin w × Bool → Word b)
    (s : Fin w) (c : Bool) (k : Fin np × Bool → Word b) (v₁ v₂ : Word b) :
    (clnh (Function.update k (s.castLE hw, !c) v₁) hw g
        + clnh (Function.update k (s.castLE hw, !c) v₁) hw g')
      - (clnh (Function.update k (s.castLE hw, !c) v₂) hw g
        + clnh (Function.update k (s.castLE hw, !c) v₂) hw g')
      = (wordPoly (g (s, c)) + wordPoly (g' (s, c))) * (wordPoly v₁ - wordPoly v₂) := by
  rw [clnh_update hw g s (!c) k v₁, clnh_update hw g' s (!c) k v₁,
      clnh_update hw g s (!c) k v₂, clnh_update hw g' s (!c) k v₂, Bool.not_not]
  have hchar : wordPoly (k (s.castLE hw, c)) + wordPoly (k (s.castLE hw, c)) = 0 :=
    CharTwo.add_self_eq_zero _
  linear_combination (wordPoly v₁ - wordPoly v₂) * hchar

/-- **Lemma `lem:ph:clnh`(i).** Unreduced CLNH is `2^{-b}`-XOR-universal at full width, for
every constant `C`, on two sub-blocks of the same pair count. -/
theorem clnh_xor_universal_equal_pairs {b np w : ℕ} (hw : w ≤ np)
    (g g' : Fin w × Bool → Word b) (hne : g ≠ g') (C : R) :
    uniformProb (fun k : Fin np × Bool → Word b => clnh k hw g + clnh k hw g' = C)
      ≤ 1 / (2 ^ b : ℚ≥0) := by
  classical
  obtain ⟨⟨s, c⟩, hsc⟩ := Function.ne_iff.mp hne
  have hδ : wordPoly (g (s, c)) + wordPoly (g' (s, c)) ≠ 0 :=
    fun h => hsc (wordPoly_add_eq_zero_iff.mp h)
  rw [← card_word_cast b]
  refine uniformProb_le_of_injective_update
    (fun k : Fin np × Bool → Word b => clnh k hw g + clnh k hw g')
    ((s.castLE hw : Fin np), !c) C ?_
  intro k v₁ v₂ hv
  have hv' : clnh (Function.update k ((s.castLE hw : Fin np), !c) v₁) hw g
      + clnh (Function.update k ((s.castLE hw : Fin np), !c) v₁) hw g'
      = clnh (Function.update k ((s.castLE hw : Fin np), !c) v₂) hw g
      + clnh (Function.update k ((s.castLE hw : Fin np), !c) v₂) hw g' := hv
  have hsub := clnh_sum_update_sub hw g g' s c k v₁ v₂
  rw [hv', sub_self] at hsub
  rcases mul_eq_zero.mp hsub.symm with h' | h'
  · exact absurd h' hδ
  · exact wordPoly_injective (sub_eq_zero.mp h')

/-- The inductive step of `lem:ph:clnh`(ii), in the abstract form the proof uses: `D` is the
difference after `t` pairs, `Dprev` the difference after `t-1` pairs, `i₀`, `i₁` the two key
words of the `t`-th pair, which `Dprev` does not use. -/
lemma clnh_step {b np : ℕ} (D Dprev : (Fin np × Bool → Word b) → R) (C : R)
    (i₀ i₁ : Fin np × Bool) (hi : i₀ ≠ i₁) (c : Word b) (B : R)
    (hDprev₀ : ∀ k v, Dprev (Function.update k i₀ v) = Dprev k)
    (hDprev₁ : ∀ k v, Dprev (Function.update k i₁ v) = Dprev k)
    (hD : ∀ k, D k = Dprev k + (wordPoly c + wordPoly (k i₀)) * (B + wordPoly (k i₁)))
    (hprev : uniformProb (fun k => Dprev k = C) ≤ 1 / (2 ^ b : ℚ≥0)) :
    uniformProb (fun k => D k = C) ≤ 1 / (2 ^ b : ℚ≥0) := by
  classical
  -- (a) the keys with `k i₀ ≠ c`: the last product is a nonzero multiple of `k i₁`
  have hb1 : uniformProb (fun k => D k = C ∧ k i₀ ≠ c)
      ≤ uniformProb (fun k : Fin np × Bool → Word b => k i₀ ≠ c) / (2 ^ b : ℚ≥0) := by
    rw [← card_word_cast b]
    refine uniformProb_and_le_of_injective_update D (fun k => k i₀ ≠ c) i₁ C ?_ ?_
    · intro k v
      simp [Function.update_of_ne hi]
    · intro k hk v₁ v₂ hv
      have e₁ : ∀ v, D (Function.update k i₁ v)
          = Dprev k + (wordPoly c + wordPoly (k i₀)) * (B + wordPoly v) := by
        intro v
        rw [hD, hDprev₁, Function.update_of_ne hi, Function.update_self]
      have hv' : D (Function.update k i₁ v₁) = D (Function.update k i₁ v₂) := hv
      rw [e₁ v₁, e₁ v₂] at hv'
      have hδ : wordPoly c + wordPoly (k i₀) ≠ 0 :=
        fun h => hk (wordPoly_add_eq_zero_iff.mp h).symm
      exact wordPoly_injective (add_left_cancel (mul_left_cancel₀ hδ (add_left_cancel hv')))
  -- (b) the keys with `k i₀ = c`: the last product vanishes, and `k i₀` costs `1/|V|`
  have hb2 : uniformProb (fun k => D k = C ∧ k i₀ = c)
      ≤ (1 / (2 ^ b : ℚ≥0)) / (2 ^ b : ℚ≥0) := by
    have hsub : uniformProb (fun k => D k = C ∧ k i₀ = c)
        ≤ uniformProb (fun k : Fin np × Bool → Word b => k i₀ = c ∧ Dprev k = C) := by
      apply uniformProb_mono
      intro k hk
      refine ⟨hk.2, ?_⟩
      have hDk : D k = Dprev k := by
        rw [hD, hk.2, CharTwo.add_self_eq_zero, zero_mul, add_zero]
      rw [← hDk]
      exact hk.1
    refine hsub.trans ((?_ : _ ≤ uniformProb (fun k : Fin np × Bool → Word b => Dprev k = C)
        / (2 ^ b : ℚ≥0)).trans (div_le_div_of_nonneg_right hprev (by positivity)))
    rw [← card_word_cast b]
    refine uniformProb_and_le_of_injective_update (fun k => k i₀) (fun k => Dprev k = C) i₀ c
      ?_ ?_
    · intro k v
      simp only [hDprev₀]
    · intro k _ v₁ v₂ hv
      simp only [Function.update_self] at hv
      exact hv
  -- (c) add the two cases
  have hsplit : uniformProb (fun k => D k = C)
      ≤ uniformProb (fun k => D k = C ∧ k i₀ ≠ c)
        + uniformProb (fun k => D k = C ∧ k i₀ = c) := by
    refine le_trans (uniformProb_mono ?_) (uniformProb_or_le _ _)
    intro k hk
    by_cases h : k i₀ = c
    · exact Or.inr ⟨hk, h⟩
    · exact Or.inl ⟨hk, h⟩
  have hone : uniformProb (fun k : Fin np × Bool → Word b => k i₀ = c) = 1 / (2 ^ b : ℚ≥0) := by
    rw [← card_word_cast b]
    refine uniformProb_of_bijective_update (fun k => k i₀) i₀ (fun k => ?_) c
    simpa using Function.bijective_id
  have hcompl : uniformProb (fun k : Fin np × Bool → Word b => k i₀ ≠ c) + 1 / (2 ^ b : ℚ≥0)
      = 1 := by
    rw [← hone]
    exact uniformProb_compl _
  calc uniformProb (fun k => D k = C)
      ≤ uniformProb (fun k : Fin np × Bool → Word b => k i₀ ≠ c) / (2 ^ b : ℚ≥0)
        + (1 / (2 ^ b : ℚ≥0)) / (2 ^ b : ℚ≥0) := le_trans hsplit (add_le_add hb1 hb2)
    _ = (uniformProb (fun k : Fin np × Bool → Word b => k i₀ ≠ c) + 1 / (2 ^ b : ℚ≥0))
          / (2 ^ b : ℚ≥0) := by rw [← add_div]
    _ = 1 / (2 ^ b : ℚ≥0) := by rw [hcompl]

/-- The first `w` pairs of a sub-block of `w+1` pairs. -/
def init {b w : ℕ} (g : Fin (w + 1) × Bool → Word b) : Fin w × Bool → Word b :=
  fun x => g (x.1.castSucc, x.2)

/-- Peeling the last pair off a sub-block. -/
lemma clnh_succ {b np w : ℕ} (hw1 : w + 1 ≤ np) (g : Fin (w + 1) × Bool → Word b)
    (k : Fin np × Bool → Word b) :
    clnh k hw1 g = clnh k (Nat.le_of_succ_le hw1) (init g)
      + (wordPoly (g (Fin.last w, false))
          + wordPoly (k (((Fin.last w).castLE hw1 : Fin np), false))) *
        (wordPoly (g (Fin.last w, true))
          + wordPoly (k (((Fin.last w).castLE hw1 : Fin np), true))) := by
  unfold clnh
  rw [Fin.sum_univ_castSucc]
  congr 1

/-- **Lemma `lem:ph:clnh`(ii).** With a nonzero constant `C` the bound survives a longer
second sub-block: the key products of the extra pairs cannot be cancelled. -/
theorem clnh_xor_universal_extra_pairs {b np w : ℕ} (g : Fin w × Bool → Word b) :
    ∀ (w' : ℕ) (hww' : w ≤ w') (hw' : w' ≤ np) (g' : Fin w' × Bool → Word b) (C : R), C ≠ 0 →
      uniformProb (fun k : Fin np × Bool → Word b =>
        clnh k (hww'.trans hw') g + clnh k hw' g' = C) ≤ 1 / (2 ^ b : ℚ≥0) := by
  intro w' hww'
  induction w', hww' using Nat.le_induction with
  | base =>
      intro hw' g' C hC
      by_cases hg : g = g'
      · subst hg
        rw [uniformProb_eq_zero]
        · positivity
        · intro k hk
          rw [CharTwo.add_self_eq_zero] at hk
          exact hC hk.symm
      · exact clnh_xor_universal_equal_pairs hw' g g' hg C
  | succ w' hww' ih =>
      intro hw'1 g' C hC
      have hw' : w' ≤ np := Nat.le_of_succ_le hw'1
      have hjval : (((Fin.last w').castLE hw'1 : Fin np) : ℕ) = w' := by simp
      have hindep : ∀ (d : Bool) (k : Fin np × Bool → Word b) (v : Word b),
          clnh (Function.update k (((Fin.last w').castLE hw'1 : Fin np), d) v)
              (hww'.trans hw') g
            + clnh (Function.update k (((Fin.last w').castLE hw'1 : Fin np), d) v) hw' (init g')
          = clnh k (hww'.trans hw') g + clnh k hw' (init g') := by
        intro d k v
        rw [clnh_update_of_le (hww'.trans hw') g k _ (by omega) d v,
          clnh_update_of_le hw' (init g') k _ (by omega) d v]
      refine clnh_step
        (fun k => clnh k ((Nat.le_succ_of_le hww').trans hw'1) g + clnh k hw'1 g')
        (fun k => clnh k (hww'.trans hw') g + clnh k hw' (init g'))
        C (((Fin.last w').castLE hw'1 : Fin np), false)
        (((Fin.last w').castLE hw'1 : Fin np), true) (by simp)
        (g' (Fin.last w', false)) (wordPoly (g' (Fin.last w', true)))
        ?_ ?_ ?_ (ih hw' (init g') C hC)
      · intro k v
        exact hindep false k v
      · intro k v
        exact hindep true k v
      · intro k
        simp only [clnh_succ hw'1 g' k]
        ring

/-! ### The equal-length multi-block form (level 1 of `lem:ph:stream`) -/

/-- Sub-block `t` sits at position `pos t` of its block and is keyed by the segment
`κ^(pos t)`; the `S` segments are independent and uniform. If two messages have sub-blocks
of the same pair counts and differ in some sub-block, their CLNH values agree everywhere
with probability at most `2^{-b}`. -/
theorem clnh_stream_equal_lengths {b np S p : ℕ} (pos : Fin p → Fin S) (w : Fin p → ℕ)
    (hw : ∀ t, w t ≤ np) (m m' : (t : Fin p) → Fin (w t) × Bool → Word b) (hne : m ≠ m') :
    uniformProb (fun k : Fin S → Fin np × Bool → Word b =>
        ∀ t : Fin p, clnh (k (pos t)) (hw t) (m t) = clnh (k (pos t)) (hw t) (m' t))
      ≤ 1 / (2 ^ b : ℚ≥0) := by
  classical
  obtain ⟨t, ht⟩ := Function.ne_iff.mp hne
  calc uniformProb (fun k : Fin S → Fin np × Bool → Word b =>
        ∀ t : Fin p, clnh (k (pos t)) (hw t) (m t) = clnh (k (pos t)) (hw t) (m' t))
      ≤ uniformProb (fun k : Fin S → Fin np × Bool → Word b =>
          clnh (k (pos t)) (hw t) (m t) + clnh (k (pos t)) (hw t) (m' t) = 0) := by
        refine uniformProb_mono ?_
        intro k hk
        rw [hk t]
        exact CharTwo.add_self_eq_zero _
    _ = uniformProb (fun k : Fin np × Bool → Word b =>
          clnh k (hw t) (m t) + clnh k (hw t) (m' t) = 0) :=
        uniformProb_coord (I := Fin S) (A := Fin np × Bool → Word b) (pos t)
          (fun a => clnh a (hw t) (m t) + clnh a (hw t) (m' t) = 0)
    _ ≤ 1 / (2 ^ b : ℚ≥0) := clnh_xor_universal_equal_pairs (hw t) (m t) (m' t) ht 0

/-- The level-1 content of the different-length cases (b), (c) of `lem:ph:stream`: whatever
the earlier sub-blocks do, a nonzero constant `C` on the last pair costs `2^{-b}`, whether or
not the two last sub-blocks have the same pair count. `Rest` stands for the conditions on the
earlier sub-blocks, which the bound does not use. -/
theorem clnh_last_subblock_constant {b np S : ℕ} (i : Fin S) {w w' : ℕ}
    (hww' : w ≤ w') (hw' : w' ≤ np) (g : Fin w × Bool → Word b)
    (g' : Fin w' × Bool → Word b) (C : R) (hC : C ≠ 0)
    (Rest : (Fin S → Fin np × Bool → Word b) → Prop) :
    uniformProb (fun k : Fin S → Fin np × Bool → Word b =>
        Rest k ∧ clnh (k i) (hww'.trans hw') g + clnh (k i) hw' g' = C)
      ≤ 1 / (2 ^ b : ℚ≥0) := by
  classical
  calc uniformProb (fun k : Fin S → Fin np × Bool → Word b =>
        Rest k ∧ clnh (k i) (hww'.trans hw') g + clnh (k i) hw' g' = C)
      ≤ uniformProb (fun k : Fin S → Fin np × Bool → Word b =>
          clnh (k i) (hww'.trans hw') g + clnh (k i) hw' g' = C) :=
        uniformProb_mono fun k hk => hk.2
    _ = uniformProb (fun k : Fin np × Bool → Word b =>
          clnh k (hww'.trans hw') g + clnh k hw' g' = C) :=
        uniformProb_coord (I := Fin S) (A := Fin np × Bool → Word b) i
          (fun a => clnh a (hww'.trans hw') g + clnh a hw' g' = C)
    _ ≤ 1 / (2 ^ b : ℚ≥0) := clnh_xor_universal_extra_pairs g w' hww' hw' g' C hC

/-! ### Sharpness: the hypothesis `C ≠ 0` of part (ii) cannot be dropped -/

/-- Inclusion-exclusion for two events. -/
lemma uniformProb_union_add_inter {K : Type*} [Fintype K] (E D : K → Prop) :
    uniformProb (fun k => E k ∨ D k) + uniformProb (fun k => E k ∧ D k)
      = uniformProb E + uniformProb D := by
  classical
  have hcard : ∀ s t u v : Finset K, (∀ k, k ∈ s ↔ (E k ∨ D k)) → (∀ k, k ∈ t ↔ (E k ∧ D k)) →
      (∀ k, k ∈ u ↔ E k) → (∀ k, k ∈ v ↔ D k) → s.card + t.card = u.card + v.card := by
    intro s t u v hs ht hu hv
    have h1 : s = u ∪ v := by
      ext k
      simp [hs, hu, hv]
    have h2 : t = u ∩ v := by
      ext k
      simp [ht, hu, hv]
    rw [h1, h2]
    exact Finset.card_union_add_card_inter u v
  unfold uniformProb
  rw [← add_div, ← add_div, ← Nat.cast_add, ← Nat.cast_add]
  congr 1
  norm_cast
  apply hcard <;> (intro k; simp)

lemma uniformProb_singleton {K : Type*} [Fintype K] (k₀ : K) :
    uniformProb (fun k => k = k₀) = 1 / (Fintype.card K : ℚ≥0) := by
  classical
  have hcard : ∀ s : Finset K, (∀ k, k ∈ s ↔ k = k₀) → s.card = 1 := by
    intro s hs
    have hs' : s = {k₀} := by
      ext k
      simp [hs]
    rw [hs']
    simp
  unfold uniformProb
  rw [hcard _ (by intro k; simp)]
  norm_num

/-- The appendix's remark: with `w = 0`, `w' = 1` and `C = 0` the event is
`{k₀ = g'₀} ∪ {k₁ = g'₁}`, whose probability is `2/2^b - 1/2^{2b}` (stated without
truncated subtraction). For `b = 64` this is `2^-63 - 2^-128`. -/
theorem clnh_extra_pairs_zero_constant {b : ℕ} (g : Fin 0 × Bool → Word b)
    (g' : Fin 1 × Bool → Word b) :
    uniformProb (fun k : Fin 1 × Bool → Word b =>
        clnh k (Nat.zero_le 1) g + clnh k le_rfl g' = 0)
      + 1 / ((2 ^ b : ℚ≥0) * (2 ^ b : ℚ≥0)) = 1 / (2 ^ b : ℚ≥0) + 1 / (2 ^ b : ℚ≥0) := by
  classical
  have h0 : ((0 : Fin 1).castLE (le_refl 1) : Fin 1) = 0 := Subsingleton.elim _ _
  have hev : (fun k : Fin 1 × Bool → Word b =>
      clnh k (Nat.zero_le 1) g + clnh k le_rfl g' = 0)
      = fun k : Fin 1 × Bool → Word b =>
        (k (0, false) = g' (0, false) ∨ k (0, true) = g' (0, true)) := by
    funext k
    rw [eq_iff_iff, clnh_empty, zero_add]
    simp only [clnh, Fin.sum_univ_one, h0]
    rw [mul_eq_zero, wordPoly_add_eq_zero_iff, wordPoly_add_eq_zero_iff]
    constructor
    · rintro (h | h)
      · exact Or.inl h.symm
      · exact Or.inr h.symm
    · rintro (h | h)
      · exact Or.inl h.symm
      · exact Or.inr h.symm
  have hA : uniformProb (fun k : Fin 1 × Bool → Word b => k (0, false) = g' (0, false))
      = 1 / (2 ^ b : ℚ≥0) := by
    rw [← card_word_cast b]
    refine uniformProb_of_bijective_update (fun k => k (0, false)) (0, false) (fun k => ?_) _
    simpa using Function.bijective_id
  have hB : uniformProb (fun k : Fin 1 × Bool → Word b => k (0, true) = g' (0, true))
      = 1 / (2 ^ b : ℚ≥0) := by
    rw [← card_word_cast b]
    refine uniformProb_of_bijective_update (fun k => k (0, true)) (0, true) (fun k => ?_) _
    simpa using Function.bijective_id
  have hAB : uniformProb (fun k : Fin 1 × Bool → Word b =>
      k (0, false) = g' (0, false) ∧ k (0, true) = g' (0, true))
      = 1 / ((2 ^ b : ℚ≥0) * (2 ^ b : ℚ≥0)) := by
    have hfun : (fun k : Fin 1 × Bool → Word b =>
        k (0, false) = g' (0, false) ∧ k (0, true) = g' (0, true))
        = fun k : Fin 1 × Bool → Word b => k = g' := by
      funext k
      rw [eq_iff_iff]
      constructor
      · rintro ⟨h1, h2⟩
        funext x
        obtain ⟨i, d⟩ := x
        have hi : i = 0 := Subsingleton.elim _ _
        subst hi
        cases d
        · exact h1
        · exact h2
      · rintro rfl
        exact ⟨rfl, rfl⟩
    have hcard : Fintype.card (Fin 1 × Bool → Word b) = 2 ^ b * 2 ^ b := by
      rw [Fintype.card_fun, card_word, Fintype.card_prod, Fintype.card_fin, Fintype.card_bool]
      ring
    rw [hfun, uniformProb_singleton, hcard]
    push_cast
    ring
  have hIE := uniformProb_union_add_inter
    (fun k : Fin 1 × Bool → Word b => k (0, false) = g' (0, false))
    (fun k : Fin 1 × Bool → Word b => k (0, true) = g' (0, true))
  rw [hA, hB, hAB] at hIE
  rw [hev]
  exact hIE

/-- ... so the `2^{-b}` bound itself fails at `C = 0`. -/
theorem clnh_extra_pairs_zero_constant_exceeds {b : ℕ} (hb : 0 < b)
    (g : Fin 0 × Bool → Word b) (g' : Fin 1 × Bool → Word b) :
    1 / (2 ^ b : ℚ≥0) < uniformProb (fun k : Fin 1 × Bool → Word b =>
        clnh k (Nat.zero_le 1) g + clnh k le_rfl g' = 0) := by
  have key := clnh_extra_pairs_zero_constant g g'
  have hN : (1 : ℚ≥0) < (2 ^ b : ℚ≥0) := one_lt_pow₀ one_lt_two (by omega)
  have hNpos : (0 : ℚ≥0) < (2 ^ b : ℚ≥0) := lt_trans zero_lt_one hN
  have hgt : (2 ^ b : ℚ≥0) < (2 ^ b : ℚ≥0) * (2 ^ b : ℚ≥0) := by
    have h := mul_lt_mul_of_pos_left hN hNpos
    rwa [mul_one] at h
  have hlt : 1 / ((2 ^ b : ℚ≥0) * (2 ^ b : ℚ≥0)) < 1 / (2 ^ b : ℚ≥0) := by
    exact div_lt_div_of_pos_left one_pos hNpos hgt
  by_contra hle
  push_neg at hle
  have hcontra : 1 / (2 ^ b : ℚ≥0) + 1 / (2 ^ b : ℚ≥0)
      < 1 / (2 ^ b : ℚ≥0) + 1 / (2 ^ b : ℚ≥0) := by
    calc 1 / (2 ^ b : ℚ≥0) + 1 / (2 ^ b : ℚ≥0)
        = uniformProb (fun k : Fin 1 × Bool → Word b =>
            clnh k (Nat.zero_le 1) g + clnh k le_rfl g' = 0)
          + 1 / ((2 ^ b : ℚ≥0) * (2 ^ b : ℚ≥0)) := key.symm
      _ < 1 / (2 ^ b : ℚ≥0) + 1 / (2 ^ b : ℚ≥0) := add_lt_add_of_le_of_lt hle hlt
  exact lt_irrefl _ hcontra

/-! ### The shipped strided pairing

`eq:ph:clnh` pairs adjacent words.  `ph_block` of `chainhash.cpp` pairs the four words of a
32-byte group `j` as `(w_{4j}, w_{4j+2})` and `(w_{4j+1}, w_{4j+3})`, every word XORed with
the key word of its OWN position; that is the adjacent pairing composed with the appendix's
fixed involution `π`, applied to key and data alike.  Since the assignment of word positions
to pair slots is a bijection, a uniform key on the positions is a uniform key on the slots and
the bounds carry over verbatim. -/

/-- Pair `s = 2j + e` of a block holds the word positions `4j + e` and `4j + e + 2`: the
strided pairing of the shipped code. -/
def posStrided {G : ℕ} (x : Fin (2 * G) × Bool) : Fin (4 * G) :=
  ⟨4 * ((x.1 : ℕ) / 2) + (x.1 : ℕ) % 2 + (if x.2 then 2 else 0), by
    have h := x.1.isLt
    by_cases hx : x.2 = true <;> simp [hx] <;> omega⟩

lemma posStrided_injective {G : ℕ} : Function.Injective (posStrided (G := G)) := by
  rintro ⟨s, d⟩ ⟨t, e⟩ h
  have hs := s.isLt
  have ht := t.isLt
  have h' : 4 * ((s : ℕ) / 2) + (s : ℕ) % 2 + (if d then 2 else 0)
      = 4 * ((t : ℕ) / 2) + (t : ℕ) % 2 + (if e then 2 else 0) := congrArg Fin.val h
  have hval : (s : ℕ) = (t : ℕ) ∧ d = e := by
    cases d <;> cases e <;> simp at h' ⊢ <;> omega
  obtain ⟨h1, h2⟩ := hval
  subst h2
  have hst : s = t := Fin.val_inj.mp h1
  subst hst
  rfl

lemma posStrided_bijective {G : ℕ} : Function.Bijective (posStrided (G := G)) := by
  refine (Fintype.bijective_iff_injective_and_card _).mpr ⟨posStrided_injective, ?_⟩
  simp only [Fintype.card_prod, Fintype.card_fin, Fintype.card_bool]
  ring

/-- The strided pairing as a bijection between pair slots and word positions. -/
noncomputable def posStridedEquiv (G : ℕ) : Fin (2 * G) × Bool ≃ Fin (4 * G) :=
  Equiv.ofBijective _ posStrided_bijective

@[simp] lemma posStridedEquiv_apply {G : ℕ} (x : Fin (2 * G) × Bool) :
    posStridedEquiv G x = posStrided x := rfl

/-- A uniform key indexed by word positions is a uniform key indexed by pair slots. -/
lemma uniformProb_relabel {b np : ℕ} {I : Type*} [Fintype I] [DecidableEq I]
    (σ : Fin np × Bool ≃ I) (E : (Fin np × Bool → Word b) → Prop) :
    uniformProb (fun k : I → Word b => E (fun x => k (σ x))) = uniformProb E := by
  classical
  let e : (I → Word b) ≃ (Fin np × Bool → Word b) :=
    { toFun := fun k x => k (σ x)
      invFun := fun κ i => κ (σ.symm i)
      left_inv := by
        intro k
        funext i
        simp
      right_inv := by
        intro κ
        funext x
        simp }
  exact uniformProb_equiv e E

/-- **The shipped block hash, `ph_block`.** A block of `4G` words, the strided pairing, one
uniform key word per word position: distinct blocks land at any fixed XOR difference `C` of
the full unreduced value with probability at most `2^{-b}`. -/
theorem clnh_strided_xor_universal {b G : ℕ} (m m' : Fin (4 * G) → Word b) (hne : m ≠ m')
    (C : R) :
    uniformProb (fun k : Fin (4 * G) → Word b =>
        (∑ s : Fin (2 * G),
            (wordPoly (m (posStrided (s, false))) + wordPoly (k (posStrided (s, false)))) *
              (wordPoly (m (posStrided (s, true))) + wordPoly (k (posStrided (s, true)))))
          + (∑ s : Fin (2 * G),
            (wordPoly (m' (posStrided (s, false))) + wordPoly (k (posStrided (s, false)))) *
              (wordPoly (m' (posStrided (s, true))) + wordPoly (k (posStrided (s, true)))))
          = C)
      ≤ 1 / (2 ^ b : ℚ≥0) := by
  classical
  have hg : (fun x : Fin (2 * G) × Bool => m (posStrided x))
      ≠ fun x : Fin (2 * G) × Bool => m' (posStrided x) := by
    intro h
    apply hne
    funext i
    obtain ⟨x, hx⟩ := posStrided_bijective.surjective i
    rw [← hx]
    exact congrFun h x
  have key := clnh_xor_universal_equal_pairs (le_refl (2 * G))
    (fun x : Fin (2 * G) × Bool => m (posStrided x))
    (fun x : Fin (2 * G) × Bool => m' (posStrided x)) hg C
  rw [← uniformProb_relabel (posStridedEquiv G)] at key
  exact key

/-- The same, for two last sub-blocks of different group counts and a nonzero constant. -/
theorem clnh_strided_extra_pairs {b G G' : ℕ} (hG : G' ≤ G)
    (m : Fin (4 * G') → Word b) (m' : Fin (4 * G) → Word b) (C : R) (hC : C ≠ 0) :
    uniformProb (fun k : Fin (4 * G) → Word b =>
        (∑ s : Fin (2 * G'),
            (wordPoly (m (posStrided (s, false)))
                + wordPoly (k ((posStrided (s, false)).castLE (by omega)))) *
              (wordPoly (m (posStrided (s, true)))
                + wordPoly (k ((posStrided (s, true)).castLE (by omega)))))
          + (∑ s : Fin (2 * G),
            (wordPoly (m' (posStrided (s, false))) + wordPoly (k (posStrided (s, false)))) *
              (wordPoly (m' (posStrided (s, true))) + wordPoly (k (posStrided (s, true)))))
          = C)
      ≤ 1 / (2 ^ b : ℚ≥0) := by
  classical
  have key := clnh_xor_universal_extra_pairs (np := 2 * G)
    (fun x : Fin (2 * G') × Bool => m (posStrided x)) (2 * G) (by omega) (le_refl (2 * G))
    (fun x : Fin (2 * G) × Bool => m' (posStrided x)) C hC
  rw [← uniformProb_relabel (posStridedEquiv G)] at key
  exact key

/-! ### The shipped 64-bit instantiation -/

/-- `lem:ph:clnh`(i) for the shipped word size: `2^-64`-XOR-universality of the unreduced
128-bit CLNH value. -/
theorem clnh_xor_universal_equal_pairs_64 {np w : ℕ} (hw : w ≤ np)
    (g g' : Fin w × Bool → Word 64) (hne : g ≠ g') (C : R) :
    uniformProb (fun k : Fin np × Bool → Word 64 => clnh k hw g + clnh k hw g' = C)
      ≤ 1 / (2 ^ 64 : ℚ≥0) :=
  clnh_xor_universal_equal_pairs hw g g' hne C

/-- `lem:ph:clnh`(ii) for the shipped word size. -/
theorem clnh_xor_universal_extra_pairs_64 {np w w' : ℕ} (hww' : w ≤ w') (hw' : w' ≤ np)
    (g : Fin w × Bool → Word 64) (g' : Fin w' × Bool → Word 64) (C : R) (hC : C ≠ 0) :
    uniformProb (fun k : Fin np × Bool → Word 64 =>
      clnh k (hww'.trans hw') g + clnh k hw' g' = C) ≤ 1 / (2 ^ 64 : ℚ≥0) :=
  clnh_xor_universal_extra_pairs g w' hww' hw' g' C hC

/-- Every carry-less product is 127 bits wide, and so is the block value: the unreduced
value of the appendix, kept in full by the stream. -/
lemma clnh_degree_lt_127 {np w : ℕ} (k : Fin np × Bool → Word 64) (hw : w ≤ np)
    (g : Fin w × Bool → Word 64) : (clnh k hw g).degree < (127 : ℕ) :=
  clnh_degree_lt (by norm_num) k hw g

/-- The shipped `chainhash-256` geometry (`BLOCK_WORDS = 32`, `S = 1`): one key segment of
32 words = 16 pairs, sub-blocks of at most 16 pairs, 64-bit words. -/
theorem clnh_chainhash256_equal_pairs {w : ℕ} (hw : w ≤ 16)
    (g g' : Fin w × Bool → Word 64) (hne : g ≠ g') (C : R) :
    uniformProb (fun k : Fin 16 × Bool → Word 64 => clnh k hw g + clnh k hw g' = C)
      ≤ 1 / (2 ^ 64 : ℚ≥0) :=
  clnh_xor_universal_equal_pairs hw g g' hne C

/-- The same geometry, for two last sub-blocks of different pair counts. -/
theorem clnh_chainhash256_extra_pairs {w w' : ℕ} (hww' : w ≤ w') (hw' : w' ≤ 16)
    (g : Fin w × Bool → Word 64) (g' : Fin w' × Bool → Word 64) (C : R) (hC : C ≠ 0) :
    uniformProb (fun k : Fin 16 × Bool → Word 64 =>
      clnh k (hww'.trans hw') g + clnh k hw' g' = C) ≤ 1 / (2 ^ 64 : ℚ≥0) :=
  clnh_xor_universal_extra_pairs g w' hww' hw' g' C hC

/-- The shipped `chainhash-1k` geometry (`BLOCK_WORDS = 128`, `S = 2`): each of the two key
segments has 64 words = 32 pairs, and the two sub-blocks of a block use segment `0` and
segment `1`. -/
theorem clnh_chainhash1k_stream {p : ℕ} (pos : Fin p → Fin 2) (w : Fin p → ℕ)
    (hw : ∀ t, w t ≤ 32) (m m' : (t : Fin p) → Fin (w t) × Bool → Word 64) (hne : m ≠ m') :
    uniformProb (fun k : Fin 2 → Fin 32 × Bool → Word 64 =>
        ∀ t : Fin p, clnh (k (pos t)) (hw t) (m t) = clnh (k (pos t)) (hw t) (m' t))
      ≤ 1 / (2 ^ 64 : ℚ≥0) :=
  clnh_stream_equal_lengths pos w hw m m' hne

/-- The appendix's numbers at the shipped word size: the probability of the `C = 0` event is
`2^-63 - 2^-128`, above the `2^-64` bound. -/
theorem clnh_extra_pairs_zero_constant_64 (g : Fin 0 × Bool → Word 64)
    (g' : Fin 1 × Bool → Word 64) :
    uniformProb (fun k : Fin 1 × Bool → Word 64 =>
        clnh k (Nat.zero_le 1) g + clnh k le_rfl g' = 0)
      + 1 / (2 ^ 128 : ℚ≥0) = 1 / (2 ^ 63 : ℚ≥0) := by
  have h := clnh_extra_pairs_zero_constant g g'
  have h1 : ((2 : ℚ≥0) ^ 64 * 2 ^ 64) = 2 ^ 128 := by
    rw [← pow_add]
  have h2 : (1 : ℚ≥0) / 2 ^ 64 + 1 / 2 ^ 64 = 1 / 2 ^ 63 := by
    rw [← add_div]
    norm_num [pow_succ]
  rw [h1, h2] at h
  exact h

end CLNH
end ProvenHashes
