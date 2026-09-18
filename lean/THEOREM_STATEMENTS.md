# Exported theorem statements

Verbatim source signatures; namespace and source are given for each.
Variables declared at module/section scope remain implicit here; see the linked module for their context.

## [BinaryRabin.lean](ProvenHashes/BinaryRabin.lean)

`ProvenHashes.ChainHash.irreducible_dvd_frobenius_iff`

```lean
theorem irreducible_dvd_frobenius_iff (g : BitsPolynomial) (hg : Irreducible g) (n : ℕ) :
    g ∣ X ^ (2 ^ n) - X ↔ g.natDegree ∣ n
```

`ProvenHashes.ChainHash.binary_rabin64`

```lean
theorem binary_rabin64 (p : BitsPolynomial) (hp : p.Monic) (hdeg : p.natDegree = 64)
    (h64 : p ∣ X ^ (2 ^ 64) - X) (h32 : IsCoprime p (X ^ (2 ^ 32) - X)) :
    Irreducible p
```

## [ByteEncoding.lean](ProvenHashes/ByteEncoding.lean)

`ProvenHashes.ChainHash.wordAt_read_byte`

```lean
theorem wordAt_read_byte (m : Message) (j : ℕ) (b : Fin 8) :
    wordAt m (j / 8) ⟨8 * (j % 8) + b.val, by omega⟩ = byteAt m j b
```

`ProvenHashes.ChainHash.byte_words_injective`

```lean
theorem byte_words_injective (m m' : Message) (hlen : m.length = m'.length)
    (hwords : ∀ j, 8 * j < m.length → wordAt m j = wordAt m' j) : m = m'
```

`ProvenHashes.ChainHash.unpair_pairPosition`

```lean
theorem unpair_pairPosition (j : Fin 16 × Bool) : unpairPosition (pairPosition j) = j
```

`ProvenHashes.ChainHash.pair_unpairPosition`

```lean
theorem pair_unpairPosition (j : Fin 32) : pairPosition (unpairPosition j) = j
```

`ProvenHashes.ChainHash.activePairs_comparable`

```lean
theorem activePairs_comparable (m m' : Message) (t t' : ℕ) :
    activePairs m t ⊆ activePairs m' t' ∨ activePairs m' t' ⊆ activePairs m t
```

`ProvenHashes.ChainHash.block_encoding_injective`

```lean
theorem block_encoding_injective (m m' : Message) (hlen : m.length = m'.length)
    (hblocks : ∀ t, t < blockCount m → ∀ s ∈ activePairs m t, ∀ b,
      blockData m t (s, b) = blockData m' t (s, b)) : m = m'
```

`ProvenHashes.ChainHash.bitsOfBitVec_injective`

```lean
theorem bitsOfBitVec_injective (w : ℕ) : Function.Injective (@bitsOfBitVec w)
```

`ProvenHashes.ChainHash.lengthWord_injective`

```lean
theorem lengthWord_injective {n n' : ℕ} (hn : n < 2 ^ 64) (hn' : n' < 2 ^ 64)
    (h : lengthWord n = lengthWord n') : n = n'
```

## [ByteInterface.lean](ProvenHashes/ByteInterface.lean)

`ProvenHashes.ChainHash.bytesToMessage_injective`

```lean
theorem bytesToMessage_injective : Function.Injective bytesToMessage
```

`ProvenHashes.ChainHash.hashBytes_eq_iff`

```lean
theorem hashBytes_eq_iff (k : Key41) (m m' : List UInt8) :
    hashBytes k m = hashBytes k m' ↔
      referenceHash k (bytesToMessage m) = referenceHash k (bytesToMessage m')
```

`ProvenHashes.ChainHash.collision_bound_bytes`

```lean
theorem collision_bound_bytes (L : ℕ) (hL : 8 * L + 255 < 2 ^ 64)
    (m m' : List UInt8) (hm : m.length ≤ 8 * L) (hm' : m'.length ≤ 8 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key41 => hashBytes k m = hashBytes k m') ≤
      ((max 1 ((L + 31) / 32) + 2 : ℕ) : ℚ≥0) / (2 : ℚ≥0) ^ 64
```

## [CLNH.lean](ProvenHashes/CLNH.lean)

`ProvenHashes.CLNH.uniformProb_le_one_div`

```lean
lemma uniformProb_le_one_div {K : Type*} [Fintype K] (E : K → Prop)
    (h : ∀ a b, E a → E b → a = b) : uniformProb E ≤ 1 / (Fintype.card K : ℚ≥0)
```

`ProvenHashes.CLNH.uniformProb_eq_zero`

```lean
lemma uniformProb_eq_zero {K : Type*} [Fintype K] (E : K → Prop) (h : ∀ k, ¬ E k) :
    uniformProb E = 0
```

`ProvenHashes.CLNH.uniformProb_compl`

```lean
lemma uniformProb_compl {K : Type*} [Fintype K] [Nonempty K] (E : K → Prop) :
    uniformProb (fun k => ¬ E k) + uniformProb E = 1
```

`ProvenHashes.CLNH.uniformProb_and_le_of_injective_update`

```lean
theorem uniformProb_and_le_of_injective_update {I V W : Type*}
    [Fintype I] [DecidableEq I] [Fintype V] [Nonempty V]
    (f : (I → V) → W) (P : (I → V) → Prop) (i : I) (t : W)
    (hP : ∀ k v, P (Function.update k i v) ↔ P k)
    (hinj : ∀ k, P k → Function.Injective fun v => f (Function.update k i v)) :
    uniformProb (fun k => f k = t ∧ P k) ≤ uniformProb P / (Fintype.card V : ℚ≥0)
```

`ProvenHashes.CLNH.uniformProb_le_of_injective_update`

```lean
theorem uniformProb_le_of_injective_update {I V W : Type*}
    [Fintype I] [DecidableEq I] [Fintype V] [Nonempty V]
    (f : (I → V) → W) (i : I) (t : W)
    (hinj : ∀ k, Function.Injective fun v => f (Function.update k i v)) :
    uniformProb (fun k => f k = t) ≤ 1 / (Fintype.card V : ℚ≥0)
```

`ProvenHashes.CLNH.uniformProb_coord`

```lean
lemma uniformProb_coord {I A : Type*} [Fintype I] [DecidableEq I] [Fintype A] [Nonempty A]
    (i : I) (E : A → Prop) :
    uniformProb (fun k : I → A => E (k i)) = uniformProb E
```

`ProvenHashes.CLNH.wordPoly_injective`

```lean
lemma wordPoly_injective {b : ℕ} : Function.Injective (wordPoly (b
```

`ProvenHashes.CLNH.wordPoly_add`

```lean
lemma wordPoly_add {b : ℕ} (x y : Word b) :
    wordPoly (x + y) = wordPoly x + wordPoly y
```

`ProvenHashes.CLNH.wordPoly_zero`

```lean
lemma wordPoly_zero {b : ℕ} : wordPoly (0 : Word b) = 0
```

`ProvenHashes.CLNH.wordPoly_add_eq_zero_iff`

```lean
lemma wordPoly_add_eq_zero_iff {b : ℕ} {x y : Word b} :
    wordPoly x + wordPoly y = 0 ↔ x = y
```

`ProvenHashes.CLNH.wordPoly_degree_lt`

```lean
lemma wordPoly_degree_lt {b : ℕ} (w : Word b) : (wordPoly w).degree < (b : ℕ)
```

`ProvenHashes.CLNH.wordPoly_surjective`

```lean
lemma wordPoly_surjective {b : ℕ} {p : R} (hp : p.degree < (b : ℕ)) :
    ∃ w : Word b, wordPoly w = p
```

`ProvenHashes.CLNH.card_word`

```lean
lemma card_word (b : ℕ) : Fintype.card (Word b) = 2 ^ b
```

`ProvenHashes.CLNH.card_word_cast`

```lean
lemma card_word_cast (b : ℕ) : ((Fintype.card (Word b) : ℚ≥0)) = (2 ^ b : ℚ≥0)
```

`ProvenHashes.CLNH.natDegree_wordPoly_le`

```lean
lemma natDegree_wordPoly_le {b : ℕ} (w : Word b) : (wordPoly w).natDegree ≤ b - 1
```

`ProvenHashes.CLNH.clnh_empty`

```lean
lemma clnh_empty {b np : ℕ} (k : Fin np × Bool → Word b) (hw : 0 ≤ np)
    (g : Fin 0 × Bool → Word b) : clnh k hw g = 0
```

`ProvenHashes.CLNH.clnh_natDegree_le`

```lean
lemma clnh_natDegree_le {b np w : ℕ} (k : Fin np × Bool → Word b) (hw : w ≤ np)
    (g : Fin w × Bool → Word b) : (clnh k hw g).natDegree ≤ 2 * (b - 1)
```

`ProvenHashes.CLNH.clnh_degree_lt`

```lean
lemma clnh_degree_lt {b np w : ℕ} (hb : 0 < b) (k : Fin np × Bool → Word b) (hw : w ≤ np)
    (g : Fin w × Bool → Word b) : (clnh k hw g).degree < ((2 * b - 1 : ℕ) : ℕ)
```

`ProvenHashes.CLNH.clnh_update`

```lean
lemma clnh_update {b np w : ℕ} (hw : w ≤ np) (g : Fin w × Bool → Word b) (s : Fin w) (c : Bool)
    (k : Fin np × Bool → Word b) (v : Word b) :
    clnh (Function.update k (s.castLE hw, c) v) hw g
      = (wordPoly (g (s, c)) + wordPoly v) *
          (wordPoly (g (s, !c)) + wordPoly (k (s.castLE hw, !c)))
        + ∑ x ∈ Finset.univ.erase s,
            (wordPoly (g (x, false)) + wordPoly (k (x.castLE hw, false))) *
              (wordPoly (g (x, true)) + wordPoly (k (x.castLE hw, true)))
```

`ProvenHashes.CLNH.clnh_update_of_le`

```lean
lemma clnh_update_of_le {b np w : ℕ} (hw : w ≤ np) (g : Fin w × Bool → Word b)
    (k : Fin np × Bool → Word b) (jj : Fin np) (hjj : w ≤ (jj : ℕ)) (d : Bool) (v : Word b) :
    clnh (Function.update k (jj, d) v) hw g = clnh k hw g
```

`ProvenHashes.CLNH.clnh_sum_update_sub`

```lean
lemma clnh_sum_update_sub {b np w : ℕ} (hw : w ≤ np) (g g' : Fin w × Bool → Word b)
    (s : Fin w) (c : Bool) (k : Fin np × Bool → Word b) (v₁ v₂ : Word b) :
    (clnh (Function.update k (s.castLE hw, !c) v₁) hw g
        + clnh (Function.update k (s.castLE hw, !c) v₁) hw g')
      - (clnh (Function.update k (s.castLE hw, !c) v₂) hw g
        + clnh (Function.update k (s.castLE hw, !c) v₂) hw g')
      = (wordPoly (g (s, c)) + wordPoly (g' (s, c))) * (wordPoly v₁ - wordPoly v₂)
```

`ProvenHashes.CLNH.clnh_xor_universal_equal_pairs`

```lean
theorem clnh_xor_universal_equal_pairs {b np w : ℕ} (hw : w ≤ np)
    (g g' : Fin w × Bool → Word b) (hne : g ≠ g') (C : R) :
    uniformProb (fun k : Fin np × Bool → Word b => clnh k hw g + clnh k hw g' = C)
      ≤ 1 / (2 ^ b : ℚ≥0)
```

`ProvenHashes.CLNH.clnh_step`

```lean
lemma clnh_step {b np : ℕ} (D Dprev : (Fin np × Bool → Word b) → R) (C : R)
    (i₀ i₁ : Fin np × Bool) (hi : i₀ ≠ i₁) (c : Word b) (B : R)
    (hDprev₀ : ∀ k v, Dprev (Function.update k i₀ v) = Dprev k)
    (hDprev₁ : ∀ k v, Dprev (Function.update k i₁ v) = Dprev k)
    (hD : ∀ k, D k = Dprev k + (wordPoly c + wordPoly (k i₀)) * (B + wordPoly (k i₁)))
    (hprev : uniformProb (fun k => Dprev k = C) ≤ 1 / (2 ^ b : ℚ≥0)) :
    uniformProb (fun k => D k = C) ≤ 1 / (2 ^ b : ℚ≥0)
```

`ProvenHashes.CLNH.clnh_succ`

```lean
lemma clnh_succ {b np w : ℕ} (hw1 : w + 1 ≤ np) (g : Fin (w + 1) × Bool → Word b)
    (k : Fin np × Bool → Word b) :
    clnh k hw1 g = clnh k (Nat.le_of_succ_le hw1) (init g)
      + (wordPoly (g (Fin.last w, false))
          + wordPoly (k (((Fin.last w).castLE hw1 : Fin np), false))) *
        (wordPoly (g (Fin.last w, true))
          + wordPoly (k (((Fin.last w).castLE hw1 : Fin np), true)))
```

`ProvenHashes.CLNH.clnh_xor_universal_extra_pairs`

```lean
theorem clnh_xor_universal_extra_pairs {b np w : ℕ} (g : Fin w × Bool → Word b) :
    ∀ (w' : ℕ) (hww' : w ≤ w') (hw' : w' ≤ np) (g' : Fin w' × Bool → Word b) (C : R), C ≠ 0 →
      uniformProb (fun k : Fin np × Bool → Word b =>
        clnh k (hww'.trans hw') g + clnh k hw' g' = C) ≤ 1 / (2 ^ b : ℚ≥0)
```

`ProvenHashes.CLNH.clnh_stream_equal_lengths`

```lean
theorem clnh_stream_equal_lengths {b np S p : ℕ} (pos : Fin p → Fin S) (w : Fin p → ℕ)
    (hw : ∀ t, w t ≤ np) (m m' : (t : Fin p) → Fin (w t) × Bool → Word b) (hne : m ≠ m') :
    uniformProb (fun k : Fin S → Fin np × Bool → Word b =>
        ∀ t : Fin p, clnh (k (pos t)) (hw t) (m t) = clnh (k (pos t)) (hw t) (m' t))
      ≤ 1 / (2 ^ b : ℚ≥0)
```

`ProvenHashes.CLNH.clnh_last_subblock_constant`

```lean
theorem clnh_last_subblock_constant {b np S : ℕ} (i : Fin S) {w w' : ℕ}
    (hww' : w ≤ w') (hw' : w' ≤ np) (g : Fin w × Bool → Word b)
    (g' : Fin w' × Bool → Word b) (C : R) (hC : C ≠ 0)
    (Rest : (Fin S → Fin np × Bool → Word b) → Prop) :
    uniformProb (fun k : Fin S → Fin np × Bool → Word b =>
        Rest k ∧ clnh (k i) (hww'.trans hw') g + clnh (k i) hw' g' = C)
      ≤ 1 / (2 ^ b : ℚ≥0)
```

`ProvenHashes.CLNH.uniformProb_union_add_inter`

```lean
lemma uniformProb_union_add_inter {K : Type*} [Fintype K] (E D : K → Prop) :
    uniformProb (fun k => E k ∨ D k) + uniformProb (fun k => E k ∧ D k)
      = uniformProb E + uniformProb D
```

`ProvenHashes.CLNH.uniformProb_singleton`

```lean
lemma uniformProb_singleton {K : Type*} [Fintype K] (k₀ : K) :
    uniformProb (fun k => k = k₀) = 1 / (Fintype.card K : ℚ≥0)
```

`ProvenHashes.CLNH.clnh_extra_pairs_zero_constant`

```lean
theorem clnh_extra_pairs_zero_constant {b : ℕ} (g : Fin 0 × Bool → Word b)
    (g' : Fin 1 × Bool → Word b) :
    uniformProb (fun k : Fin 1 × Bool → Word b =>
        clnh k (Nat.zero_le 1) g + clnh k le_rfl g' = 0)
      + 1 / ((2 ^ b : ℚ≥0) * (2 ^ b : ℚ≥0)) = 1 / (2 ^ b : ℚ≥0) + 1 / (2 ^ b : ℚ≥0)
```

`ProvenHashes.CLNH.clnh_extra_pairs_zero_constant_exceeds`

```lean
theorem clnh_extra_pairs_zero_constant_exceeds {b : ℕ} (hb : 0 < b)
    (g : Fin 0 × Bool → Word b) (g' : Fin 1 × Bool → Word b) :
    1 / (2 ^ b : ℚ≥0) < uniformProb (fun k : Fin 1 × Bool → Word b =>
        clnh k (Nat.zero_le 1) g + clnh k le_rfl g' = 0)
```

`ProvenHashes.CLNH.posStrided_injective`

```lean
lemma posStrided_injective {G : ℕ} : Function.Injective (posStrided (G
```

`ProvenHashes.CLNH.posStrided_bijective`

```lean
lemma posStrided_bijective {G : ℕ} : Function.Bijective (posStrided (G
```

`ProvenHashes.CLNH.posStridedEquiv_apply`

```lean
lemma posStridedEquiv_apply {G : ℕ} (x : Fin (2 * G) × Bool) :
    posStridedEquiv G x = posStrided x
```

`ProvenHashes.CLNH.uniformProb_relabel`

```lean
lemma uniformProb_relabel {b np : ℕ} {I : Type*} [Fintype I] [DecidableEq I]
    (σ : Fin np × Bool ≃ I) (E : (Fin np × Bool → Word b) → Prop) :
    uniformProb (fun k : I → Word b => E (fun x => k (σ x))) = uniformProb E
```

`ProvenHashes.CLNH.clnh_strided_xor_universal`

```lean
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
      ≤ 1 / (2 ^ b : ℚ≥0)
```

`ProvenHashes.CLNH.clnh_strided_extra_pairs`

```lean
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
      ≤ 1 / (2 ^ b : ℚ≥0)
```

`ProvenHashes.CLNH.clnh_xor_universal_equal_pairs_64`

```lean
theorem clnh_xor_universal_equal_pairs_64 {np w : ℕ} (hw : w ≤ np)
    (g g' : Fin w × Bool → Word 64) (hne : g ≠ g') (C : R) :
    uniformProb (fun k : Fin np × Bool → Word 64 => clnh k hw g + clnh k hw g' = C)
      ≤ 1 / (2 ^ 64 : ℚ≥0)
```

`ProvenHashes.CLNH.clnh_xor_universal_extra_pairs_64`

```lean
theorem clnh_xor_universal_extra_pairs_64 {np w w' : ℕ} (hww' : w ≤ w') (hw' : w' ≤ np)
    (g : Fin w × Bool → Word 64) (g' : Fin w' × Bool → Word 64) (C : R) (hC : C ≠ 0) :
    uniformProb (fun k : Fin np × Bool → Word 64 =>
      clnh k (hww'.trans hw') g + clnh k hw' g' = C) ≤ 1 / (2 ^ 64 : ℚ≥0)
```

`ProvenHashes.CLNH.clnh_degree_lt_127`

```lean
lemma clnh_degree_lt_127 {np w : ℕ} (k : Fin np × Bool → Word 64) (hw : w ≤ np)
    (g : Fin w × Bool → Word 64) : (clnh k hw g).degree < (127 : ℕ)
```

`ProvenHashes.CLNH.clnh_chainhash256_equal_pairs`

```lean
theorem clnh_chainhash256_equal_pairs {w : ℕ} (hw : w ≤ 16)
    (g g' : Fin w × Bool → Word 64) (hne : g ≠ g') (C : R) :
    uniformProb (fun k : Fin 16 × Bool → Word 64 => clnh k hw g + clnh k hw g' = C)
      ≤ 1 / (2 ^ 64 : ℚ≥0)
```

`ProvenHashes.CLNH.clnh_chainhash256_extra_pairs`

```lean
theorem clnh_chainhash256_extra_pairs {w w' : ℕ} (hww' : w ≤ w') (hw' : w' ≤ 16)
    (g : Fin w × Bool → Word 64) (g' : Fin w' × Bool → Word 64) (C : R) (hC : C ≠ 0) :
    uniformProb (fun k : Fin 16 × Bool → Word 64 =>
      clnh k (hww'.trans hw') g + clnh k hw' g' = C) ≤ 1 / (2 ^ 64 : ℚ≥0)
```

`ProvenHashes.CLNH.clnh_chainhash1k_stream`

```lean
theorem clnh_chainhash1k_stream {p : ℕ} (pos : Fin p → Fin 2) (w : Fin p → ℕ)
    (hw : ∀ t, w t ≤ 32) (m m' : (t : Fin p) → Fin (w t) × Bool → Word 64) (hne : m ≠ m') :
    uniformProb (fun k : Fin 2 → Fin 32 × Bool → Word 64 =>
        ∀ t : Fin p, clnh (k (pos t)) (hw t) (m t) = clnh (k (pos t)) (hw t) (m' t))
      ≤ 1 / (2 ^ 64 : ℚ≥0)
```

`ProvenHashes.CLNH.clnh_extra_pairs_zero_constant_64`

```lean
theorem clnh_extra_pairs_zero_constant_64 (g : Fin 0 × Bool → Word 64)
    (g' : Fin 1 × Bool → Word 64) :
    uniformProb (fun k : Fin 1 × Bool → Word 64 =>
        clnh k (Nat.zero_le 1) g + clnh k le_rfl g' = 0)
      + 1 / (2 ^ 128 : ℚ≥0) = 1 / (2 ^ 63 : ℚ≥0)
```

## [Carryless.lean](ProvenHashes/Carryless.lean)

`ProvenHashes.ChainHash.pack_injective`

```lean
theorem pack_injective (w : ℕ) : Function.Injective (pack w)
```

`ProvenHashes.ChainHash.word_card`

```lean
theorem word_card (w : ℕ) : Fintype.card (Word w) = 2 ^ w
```

`ProvenHashes.ChainHash.clnh_update`

```lean
theorem clnh_update {I : Type*} [DecidableEq I] {w : ℕ} (s : Finset I)
    (m k : I × Bool → Word w) (i : I) (hi : i ∈ s) (b : Bool) (v : Word w) :
    clnh s m (Function.update k (i, b) v) =
      (pack w (m (i, !b)) + pack w (k (i, !b))) *
        (pack w (m (i, b)) + pack w v) + clnh (s.erase i) m k
```

`ProvenHashes.ChainHash.clnh_difference_bound`

```lean
theorem clnh_difference_bound {I : Type*} [Fintype I] [DecidableEq I] {w : ℕ}
    (s : Finset I) (m m' : I × Bool → Word w)
    (hne : ∃ i ∈ s, ∃ b, m (i, b) ≠ m' (i, b)) (C : BitsPolynomial) :
    uniformProb (fun k : I × Bool → Word w => clnh s m k - clnh s m' k = C) ≤
      1 / (2 : ℚ≥0) ^ w
```

`ProvenHashes.ChainHash.append_product_bound`

```lean
theorem append_product_bound {K : Type*} [Fintype K] [Nonempty K] {w : ℕ}
    (f : K → BitsPolynomial) (a b : Word w) (C : BitsPolynomial)
    (h : uniformProb (fun k => f k = C) ≤ 1 / Fintype.card (Word w)) :
    uniformProb (fun k : Word w × (K × Word w) =>
      f k.2.1 + pack w (a + k.1) * pack w (b + k.2.2) = C) ≤
      1 / Fintype.card (Word w)
```

`ProvenHashes.ChainHash.clnh_natDegree_le`

```lean
theorem clnh_natDegree_le {I : Type*} [DecidableEq I]
    (s : Finset I) (m k : I × Bool → Word 64) : (clnh s m k).natDegree ≤ 126
```

## [CarrylessBlock.lean](ProvenHashes/CarrylessBlock.lean)

`ProvenHashes.Carryless.active_mono`

```lean
theorem active_mono {N p q : ℕ} (h : p ≤ q) : active N p ⊆ active N q
```

`ProvenHashes.Carryless.block_equal_count_bound`

```lean
theorem block_equal_count_bound {N w p : ℕ}
    (m m' : Fin N × Bool → Word w)
    (hne : ∃ i : Fin N, i.val < p ∧ ∃ b, m (i, b) ≠ m' (i, b))
    (C : (ZMod 2)[X]) :
    uniformProb (fun k => block p m k + block p m' k = C) ≤
      1 / (2 : ℚ≥0) ^ w
```

`ProvenHashes.Carryless.block_nonzero_target_bound`

```lean
theorem block_nonzero_target_bound {N w p q : ℕ} (hpq : p ≤ q)
    (m m' : Fin N × Bool → Word w) (C : (ZMod 2)[X]) (hC : C ≠ 0) :
    uniformProb (fun k => block p m k + block q m' k = C) ≤
      1 / (2 : ℚ≥0) ^ w
```

`ProvenHashes.Carryless.block_degree_lt_128`

```lean
theorem block_degree_lt_128 {N p : ℕ} (m k : Fin N × Bool → Word 64) :
    (block p m k).degree < 128
```

## [CarrylessVariable.lean](ProvenHashes/CarrylessVariable.lean)

`ProvenHashes.ChainHash.clnh_pairKey_irrelevant`

```lean
theorem clnh_pairKey_irrelevant {I : Type*} [DecidableEq I] {w : ℕ}
    (s : Finset I) (m : I × Bool → Word w) (i : I) (hi : i ∉ s)
    (r : {j : I // j ≠ i} × Bool → Word w) (x y : Word w) :
    clnh s m ((pairKeyEquiv i).symm (x, r, y)) =
      clnh s m ((pairKeyEquiv i).symm (0, r, 0))
```

`ProvenHashes.ChainHash.clnh_insert`

```lean
theorem clnh_insert {I : Type*} [DecidableEq I] {w : ℕ}
    (s : Finset I) (m k : I × Bool → Word w) (i : I) (hi : i ∉ s) :
    clnh (insert i s) m k = clnh s m k +
      pack w (m (i, false) + k (i, false)) * pack w (m (i, true) + k (i, true))
```

`ProvenHashes.ChainHash.clnh_fresh_pair_bound`

```lean
theorem clnh_fresh_pair_bound {I : Type*} [Fintype I] [DecidableEq I] {w : ℕ}
    (s t : Finset I) (m m' : I × Bool → Word w) (i : I) (his : i ∉ s) (hit : i ∉ t)
    (C : BitsPolynomial)
    (h : uniformProb (fun k => clnh s m k + clnh t m' k = C) ≤
      1 / Fintype.card (Word w)) :
    uniformProb (fun k => clnh s m k + clnh (insert i t) m' k = C) ≤
      1 / Fintype.card (Word w)
```

`ProvenHashes.ChainHash.clnh_nested_nonzero_bound`

```lean
theorem clnh_nested_nonzero_bound {I : Type*} [Fintype I] [DecidableEq I] {w : ℕ}
    (s t : Finset I) (hst : s ⊆ t) (m m' : I × Bool → Word w)
    (C : BitsPolynomial) (hC : C ≠ 0) :
    uniformProb (fun k => clnh s m k + clnh t m' k = C) ≤ 1 / (2 : ℚ≥0) ^ w
```

`ProvenHashes.ChainHash.clnh_comparable_nonzero_bound`

```lean
theorem clnh_comparable_nonzero_bound {I : Type*} [Fintype I] [DecidableEq I] {w : ℕ}
    (s t : Finset I) (hst : s ⊆ t ∨ t ⊆ s) (m m' : I × Bool → Word w)
    (C : BitsPolynomial) (hC : C ≠ 0) :
    uniformProb (fun k => clnh s m k + clnh t m' k = C) ≤ 1 / (2 : ℚ≥0) ^ w
```

## [ChainHash256.lean](ProvenHashes/ChainHash256.lean)

`ProvenHashes.ChainHash256.fieldStream_length`

```lean
theorem fieldStream_length {F : Type*} [AddGroup F] (e : Word 64 ≃+ F) (m : Bytes) (k : BlockKey) :
    (fieldStream e m k).length = blockCount m.length
```

`ProvenHashes.ChainHash256.fieldStream_eq_iff`

```lean
theorem fieldStream_eq_iff {F : Type*} [AddGroup F] (e : Word 64 ≃+ F)
    (m m' : Bytes) (k : BlockKey) : fieldStream e m k = fieldStream e m' k ↔ stream m k = stream m' k
```

`ProvenHashes.ChainHash256.field_card`

```lean
theorem field_card {F : Type*} [AddGroup F] [Fintype F] (e : Word 64 ≃+ F) :
    Fintype.card F = 2 ^ 64
```

`ProvenHashes.ChainHash256.collision_bound`

```lean
theorem collision_bound {F : Type*} [Field F] [Fintype F]
    (e : Word 64 ≃+ F) (L : ℕ) (hL : 8 * L < 2 ^ 64)
    (m m' : Bytes) (hm : m.length ≤ 8 * L) (hm' : m'.length ≤ 8 * L) (hne : m ≠ m') :
    uniformProb (fun k : IdealKey F => hash e k m = hash e k m') ≤ epsilon L
```

## [ChainHashModel.lean](ProvenHashes/ChainHashModel.lean)

`ProvenHashes.ChainHash.field_card`

```lean
theorem field_card {F : Type*} [AddGroup F] [Fintype F] (repr : Word 64 ≃+ F) :
    Fintype.card F = 2 ^ 64
```

`ProvenHashes.ChainHash.idealKey_card`

```lean
theorem idealKey_card {F : Type*} [AddGroup F] [Fintype F] (repr : Word 64 ≃+ F) :
    Fintype.card (IdealKey F) = (2 ^ 64) ^ 41
```

`ProvenHashes.ChainHash.finalStage_collision_bound`

```lean
theorem finalStage_collision_bound {F : Type*} [Field F] [Fintype F]
    (word : F ≃ ZMod (2 ^ 64)) (v v' : F) (hne : v ≠ v') :
    uniformProb (fun j : F × (Fin 5 → F) =>
      chain5 j.2 (integerTwist word j.1 v) = chain5 j.2 (integerTwist word j.1 v')) ≤
        1 / Fintype.card F
```

`ProvenHashes.ChainHash.collision_bound_model`

```lean
theorem collision_bound_model {F : Type*} [Field F] [Fintype F]
    (repr : Word 64 ≃+ F) (word : F ≃ ZMod (2 ^ 64))
    (p : ℕ) (m m' : Message) (hm : m.length < 2 ^ 64) (hm' : m'.length < 2 ^ 64)
    (hne : m ≠ m') (hp : blockCount m ≤ p) (hp' : blockCount m' ≤ p) :
    uniformProb (fun k : IdealKey F => hash repr word k m = hash repr word k m') ≤
      ((p + 2 : ℕ) : ℚ≥0) / (2 : ℚ≥0) ^ 64
```

`ProvenHashes.ChainHash.collision_bound_words_model`

```lean
theorem collision_bound_words_model {F : Type*} [Field F] [Fintype F]
    (repr : Word 64 ≃+ F) (word : F ≃ ZMod (2 ^ 64)) (L : ℕ) (hL : 8 * L < 2 ^ 64)
    (m m' : Message) (hm : m.length ≤ 8 * L) (hm' : m'.length ≤ 8 * L) (hne : m ≠ m') :
    uniformProb (fun k : IdealKey F => hash repr word k m = hash repr word k m') ≤ epsilon L
```

## [Composition.lean](ProvenHashes/Composition.lean)

`ProvenHashes.uniformProb_mono`

```lean
lemma uniformProb_mono {K : Type*} [Fintype K] {E D : K → Prop}
    (h : ∀ k, E k → D k) : uniformProb E ≤ uniformProb D
```

`ProvenHashes.uniformProb_or_le`

```lean
lemma uniformProb_or_le {K : Type*} [Fintype K] (E D : K → Prop) :
    uniformProb (fun k => E k ∨ D k) ≤ uniformProb E + uniformProb D
```

`ProvenHashes.uniformProb_const`

```lean
lemma uniformProb_const {K : Type*} [Fintype K] [Nonempty K] (p : Prop) [Decidable p] :
    uniformProb (fun _ : K => p) = if p then 1 else 0
```

`ProvenHashes.uniformProb_prod`

```lean
lemma uniformProb_prod {K J : Type*} [Fintype K] [Fintype J] (E : K × J → Prop) :
    uniformProb E = (∑ k, uniformProb (fun j => E (k, j))) / Fintype.card K
```

`ProvenHashes.uniformProb_prod_fst`

```lean
lemma uniformProb_prod_fst {K J : Type*} [Fintype K] [Fintype J] [Nonempty J]
    (E : K → Prop) : uniformProb (fun p : K × J => E p.1) = uniformProb E
```

`ProvenHashes.uniformProb_prod_le`

```lean
lemma uniformProb_prod_le {K J : Type*} [Fintype K] [Fintype J] [Nonempty K]
    (E : K × J → Prop) (b : ℚ≥0) (h : ∀ k, uniformProb (fun j => E (k, j)) ≤ b) :
    uniformProb E ≤ b
```

`ProvenHashes.compose_collision_bound`

```lean
theorem compose_collision_bound {K J M R : Type*}
    [Fintype K] [Fintype J] [Nonempty K] [Nonempty J]
    (s s' : K → M) (g : J → M → R) (a b : ℚ≥0)
    (hs : uniformProb (fun k => s k = s' k) ≤ a)
    (hg : ∀ k, s k ≠ s' k → uniformProb (fun j => g j (s k) = g j (s' k)) ≤ b) :
    uniformProb (fun k : K × J => g k.2 (s k.1) = g k.2 (s' k.1)) ≤ a + b
```

`ProvenHashes.chainhash_equal_length_from_stages`

```lean
theorem chainhash_equal_length_from_stages {F K J : Type*}
    [Field F] [Fintype F] [Fintype K] [Fintype J] [Nonempty K] [Nonempty J]
    (p : ℕ) (s s' : K → List (F × F)) (g : J → F → F)
    (hlen : ∀ k, (s k).length = (s' k).length)
    (hmax : ∀ k, (s k).length ≤ p)
    (hstream : uniformProb (fun k => s k = s' k) ≤ 1 / Fintype.card F)
    (hfinal : ∀ v v', v ≠ v' → uniformProb (fun j => g j v = g j v') ≤ 1 / Fintype.card F) :
    uniformProb (fun k : (K × (Fin 3 → F)) × J =>
      g k.2 (Recurrence.hash (s k.1.1) k.1.2) =
        g k.2 (Recurrence.hash (s' k.1.1) k.1.2)) ≤
      ((p + 2 : ℕ) : ℚ≥0) / Fintype.card F
```

`ProvenHashes.chainhash_different_lengths_from_stages`

```lean
theorem chainhash_different_lengths_from_stages {F K J : Type*}
    [Field F] [Fintype F] [Fintype K] [Fintype J] [Nonempty K] [Nonempty J]
    (p : ℕ) (s s' : K → List (F × F)) (g : J → F → F)
    (hlen : ∀ k, (s k).length ≠ (s' k).length)
    (hmax : ∀ k, max (s k).length (s' k).length ≤ p)
    (hfinal : ∀ v v', v ≠ v' → uniformProb (fun j => g j v = g j v') ≤ 1 / Fintype.card F) :
    uniformProb (fun k : (K × (Fin 3 → F)) × J =>
      g k.2 (Recurrence.hash (s k.1.1) k.1.2) =
        g k.2 (Recurrence.hash (s' k.1.1) k.1.2)) ≤
      ((p + 2 : ℕ) : ℚ≥0) / Fintype.card F
```

## [ConcreteChainHash.lean](ProvenHashes/ConcreteChainHash.lean)

`ProvenHashes.ChainHash.chainHash_collision_bound`

```lean
theorem chainHash_collision_bound (L : ℕ) (hL : 8 * L < 2 ^ 64)
    (m m' : Message) (hm : m.length ≤ 8 * L) (hm' : m'.length ≤ 8 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key41 => chainHash k m = chainHash k m') ≤ epsilon L
```

`ProvenHashes.ChainHash.chainHash_collision_bound_no_overflow`

```lean
theorem chainHash_collision_bound_no_overflow (L : ℕ) (hL : 8 * L + 255 < 2 ^ 64)
    (m m' : Message) (hm : m.length ≤ 8 * L) (hm' : m'.length ≤ 8 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key41 => chainHash k m = chainHash k m') ≤ epsilon L
```

## [ConcreteWords.lean](ProvenHashes/ConcreteWords.lean)

`ProvenHashes.ChainHash.modulus_ne_one`

```lean
theorem modulus_ne_one : modulus ≠ 1
```

`ProvenHashes.ChainHash.quotient_remainder_degree`

```lean
theorem quotient_remainder_degree (a : BinaryQuotient) :
    (AdjoinRoot.modByMonicHom modulus_monic a).natDegree < 64
```

`ProvenHashes.ChainHash.fieldRepr_mul`

```lean
theorem fieldRepr_mul (v w : Word 64) :
    fieldRepr.symm (fieldRepr v * fieldRepr w) =
      lowWord ((pack 64 v * pack 64 w) %ₘ modulus)
```

## [Counting.lean](ProvenHashes/Counting.lean)

`ProvenHashes.uniformProb_injective_le`

```lean
theorem uniformProb_injective_le {V R : Type*} [Fintype V]
    (f : V → R) (hf : Function.Injective f) (t : R) :
    uniformProb (fun v => f v = t) ≤ 1 / Fintype.card V
```

`ProvenHashes.uniformProb_of_injective_update`

```lean
theorem uniformProb_of_injective_update {I V R : Type*}
    [Fintype I] [Fintype V] [Nonempty V] [DecidableEq I]
    (f : (I → V) → R) (i : I)
    (h : ∀ k, Function.Injective (fun v => f (Function.update k i v))) (t : R) :
    uniformProb (fun k => f k = t) ≤ 1 / Fintype.card V
```

`ProvenHashes.uniformProb_prod_snd`

```lean
theorem uniformProb_prod_snd {A B : Type*} [Fintype A] [Fintype B] [Nonempty A]
    (E : B → Prop) : uniformProb (fun p : A × B => E p.2) = uniformProb E
```

## [Decoder.lean](ProvenHashes/Decoder.lean)

`ProvenHashes.Recurrence.seed_monic`

```lean
lemma seed_monic (m : List (F × F)) : (encode m).seed.Monic
```

`ProvenHashes.Recurrence.seed_degree`

```lean
lemma seed_degree (m : List (F × F)) : (encode m).seed.natDegree = m.length
```

`ProvenHashes.Recurrence.seed_top`

```lean
lemma seed_top (m : List (F × F)) : (encode m).seed.coeff m.length = 1
```

`ProvenHashes.Recurrence.data_coeff_zero`

```lean
lemma data_coeff_zero (m : List (F × F)) (k : ℕ) (hk : m.length ≤ k) :
    (encode m).data.coeff k = 0
```

`ProvenHashes.Recurrence.shift_coeff_zero`

```lean
lemma shift_coeff_zero (m : List (F × F)) (k : ℕ) (hk : m.length < k) :
    (encode m).shift.coeff k = 0
```

`ProvenHashes.Recurrence.shift_top`

```lean
lemma shift_top (m : List (F × F)) :
    (encode m).shift.coeff m.length = if m.length = 0 then 0 else 1
```

`ProvenHashes.Recurrence.head_a`

```lean
lemma head_a (a b : F) (m : List (F × F)) :
    (encode ((a, b) :: m)).data.coeff m.length = a
```

`ProvenHashes.Recurrence.head_b`

```lean
lemma head_b (a b : F) (m : List (F × F)) :
    headB m.length (encode ((a, b) :: m)) = b
```

`ProvenHashes.Recurrence.peel_encode`

```lean
lemma peel_encode (a b : F) (m : List (F × F)) :
    peel m.length (encode ((a, b) :: m)) = encode m
```

`ProvenHashes.Recurrence.decode_encode`

```lean
theorem decode_encode (m : List (F × F)) : decode m.length (encode m) = m
```

`ProvenHashes.Recurrence.encode_injective`

```lean
theorem encode_injective : Function.Injective (encode (F
```

## [Encoding.lean](ProvenHashes/Encoding.lean)

`ProvenHashes.Encoding.le_ceil_mul`

```lean
lemma le_ceil_mul {B ℓ : ℕ} (hB : 0 < B) : ℓ ≤ (ℓ + B - 1) / B * B
```

`ProvenHashes.Encoding.blockCount_pos`

```lean
lemma blockCount_pos {Ws S ℓ : ℕ} : 0 < blockCount Ws S ℓ
```

`ProvenHashes.Encoding.subBlockCount_pos`

```lean
lemma subBlockCount_pos {Ws S ℓ : ℕ} (hS : 0 < S) : 0 < subBlockCount Ws S ℓ
```

`ProvenHashes.Encoding.le_subBlockCount_mul`

```lean
lemma le_subBlockCount_mul {Ws S ℓ : ℕ} (hWs : 0 < Ws) (hS : 0 < S) :
    ℓ ≤ subBlockCount Ws S ℓ * (8 * Ws)
```

`ProvenHashes.Encoding.blockCount_le`

```lean
lemma blockCount_le {Ws S ℓ n : ℕ} (hWs : 0 < Ws) (hS : 0 < S) (hn : 0 < n)
    (h : ℓ ≤ n * (S * (8 * Ws))) : blockCount Ws S ℓ ≤ n
```

`ProvenHashes.Encoding.subBlockCount_le`

```lean
lemma subBlockCount_le {Ws S ℓ n : ℕ} (hWs : 0 < Ws) (hS : 0 < S) (hn : 0 < n)
    (h : ℓ ≤ n * (S * (8 * Ws))) : subBlockCount Ws S ℓ ≤ S * n
```

`ProvenHashes.Encoding.wordCount_le`

```lean
lemma wordCount_le {Ws ℓ t : ℕ} (h4 : 4 ∣ Ws) : wordCount Ws ℓ t ≤ Ws
```

`ProvenHashes.Encoding.two_mul_pairCount_le`

```lean
theorem two_mul_pairCount_le {Ws ℓ t : ℕ} (h4 : 4 ∣ Ws) : 2 * pairCount Ws ℓ t ≤ Ws
```

`ProvenHashes.Encoding.swapMid_involutive`

```lean
lemma swapMid_involutive (j : ℕ) : swapMid (swapMid j) = j
```

`ProvenHashes.Encoding.swapMid_lt`

```lean
lemma swapMid_lt {j G : ℕ} (h : j < 4 * G) : swapMid j < 4 * G
```

`ProvenHashes.Encoding.getD_map_range`

```lean
lemma getD_map_range {α : Type*} (f : ℕ → α) {p t : ℕ} (d : α) (ht : t < p) :
    ((List.range p).map f).getD t d = f t
```

`ProvenHashes.Encoding.subBlock_eq_map`

```lean
lemma subBlock_eq_map (enc : (Fin 8 → Byte) → F) (Ws : ℕ) (m : List Byte) (t : ℕ) :
    subBlock enc Ws m t =
      (List.range (wordCount Ws m.length t)).map fun j => enc (wordAt m (t * Ws + swapMid j))
```

`ProvenHashes.Encoding.subBlock_length`

```lean
lemma subBlock_length (enc : (Fin 8 → Byte) → F) (Ws : ℕ) (m : List Byte) (t : ℕ) :
    (subBlock enc Ws m t).length = 2 * pairCount Ws m.length t
```

`ProvenHashes.Encoding.subBlocks_length`

```lean
lemma subBlocks_length (enc : (Fin 8 → Byte) → F) (Ws S : ℕ) (m : List Byte) :
    (subBlocks enc Ws S m).length = subBlockCount Ws S m.length
```

`ProvenHashes.Encoding.subBlock_eq_nil_of_pairCount_zero`

```lean
lemma subBlock_eq_nil_of_pairCount_zero (enc : (Fin 8 → Byte) → F) {Ws : ℕ} {m : List Byte}
    {t : ℕ} (h : pairCount Ws m.length t = 0) : subBlock enc Ws m t = []
```

`ProvenHashes.Encoding.subBlocks_eq_of_forall`

```lean
lemma subBlocks_eq_of_forall (enc : (Fin 8 → Byte) → F) {Ws S : ℕ} {m m' : List Byte}
    (hlen : m.length = m'.length)
    (h : ∀ t < subBlockCount Ws S m.length, subBlock enc Ws m t = subBlock enc Ws m' t) :
    subBlocks enc Ws S m = subBlocks enc Ws S m'
```

`ProvenHashes.Encoding.subBlock_eq_of_subBlocks_eq`

```lean
lemma subBlock_eq_of_subBlocks_eq {enc : (Fin 8 → Byte) → F} {Ws S : ℕ} {m m' : List Byte}
    (hp : subBlockCount Ws S m.length = subBlockCount Ws S m'.length)
    (h : subBlocks enc Ws S m = subBlocks enc Ws S m')
    {t : ℕ} (ht : t < subBlockCount Ws S m.length) :
    subBlock enc Ws m t = subBlock enc Ws m' t
```

`ProvenHashes.Encoding.eq_of_subBlocks_eq`

```lean
theorem eq_of_subBlocks_eq {enc : (Fin 8 → Byte) → F} (hinj : Function.Injective enc)
    {Ws S : ℕ} (hWs : 0 < Ws) (hS : 0 < S) {m m' : List Byte}
    (hlen : m.length = m'.length) (h : subBlocks enc Ws S m = subBlocks enc Ws S m') :
    m = m'
```

`ProvenHashes.Encoding.encoding_injective`

```lean
theorem encoding_injective {enc : (Fin 8 → Byte) → F} (hinj : Function.Injective enc)
    {Ws S : ℕ} (hWs : 0 < Ws) (hS : 0 < S) :
    Function.Injective (fun m : List Byte => (m.length, subBlocks enc Ws S m))
```

`ProvenHashes.Encoding.exists_subBlock_ne`

```lean
theorem exists_subBlock_ne {enc : (Fin 8 → Byte) → F} (hinj : Function.Injective enc)
    {Ws S : ℕ} (hWs : 0 < Ws) (hS : 0 < S) {m m' : List Byte}
    (hlen : m.length = m'.length) (hne : m ≠ m') :
    ∃ t < subBlockCount Ws S m.length,
      0 < pairCount Ws m.length t ∧ subBlock enc Ws m t ≠ subBlock enc Ws m' t
```

`ProvenHashes.Encoding.stream_length`

```lean
lemma stream_length (enc : (Fin 8 → Byte) → F) (Ws S : ℕ) (bh : ℕ → List F → F × F)
    (len : ℕ → F) (m : List Byte) :
    (stream enc Ws S bh len m).length = subBlockCount Ws S m.length
```

`ProvenHashes.Encoding.stream_length_le`

```lean
lemma stream_length_le {enc : (Fin 8 → Byte) → F} {Ws S : ℕ} {bh : ℕ → List F → F × F}
    {len : ℕ → F} {m : List Byte} {n : ℕ} (hWs : 0 < Ws) (hS : 0 < S) (hn : 0 < n)
    (hm : m.length ≤ n * (S * (8 * Ws))) :
    (stream enc Ws S bh len m).length ≤ S * n
```

`ProvenHashes.Encoding.stream_length_eq`

```lean
lemma stream_length_eq {enc : (Fin 8 → Byte) → F} {Ws S : ℕ} {bh : ℕ → List F → F × F}
    {len : ℕ → F} {m m' : List Byte}
    (h : blockCount Ws S m.length = blockCount Ws S m'.length) :
    (stream enc Ws S bh len m).length = (stream enc Ws S bh len m').length
```

`ProvenHashes.Encoding.stream_length_ne`

```lean
lemma stream_length_ne {enc : (Fin 8 → Byte) → F} {Ws S : ℕ} {bh : ℕ → List F → F × F}
    {len : ℕ → F} {m m' : List Byte} (hS : 0 < S)
    (h : blockCount Ws S m.length ≠ blockCount Ws S m'.length) :
    (stream enc Ws S bh len m).length ≠ (stream enc Ws S bh len m').length
```

`ProvenHashes.Encoding.subBlockCount_eq_of_stream_eq`

```lean
lemma subBlockCount_eq_of_stream_eq {enc : (Fin 8 → Byte) → F} {Ws S : ℕ}
    {bh : ℕ → List F → F × F} {len : ℕ → F} {m m' : List Byte}
    (hs : stream enc Ws S bh len m = stream enc Ws S bh len m') :
    subBlockCount Ws S m.length = subBlockCount Ws S m'.length
```

`ProvenHashes.Encoding.streamPair_eq_of_stream_eq`

```lean
lemma streamPair_eq_of_stream_eq {enc : (Fin 8 → Byte) → F} {Ws S : ℕ}
    {bh : ℕ → List F → F × F} {len : ℕ → F} {m m' : List Byte}
    (hs : stream enc Ws S bh len m = stream enc Ws S bh len m') {t : ℕ}
    (ht : t < subBlockCount Ws S m.length) :
    streamPair enc Ws S bh len m t = streamPair enc Ws S bh len m' t
```

`ProvenHashes.Encoding.blockHash_eq_of_stream_eq`

```lean
lemma blockHash_eq_of_stream_eq {enc : (Fin 8 → Byte) → F} {Ws S : ℕ}
    {bh : ℕ → List F → F × F} {len : ℕ → F} {m m' : List Byte}
    (hL : m.length = m'.length)
    (hs : stream enc Ws S bh len m = stream enc Ws S bh len m') {t : ℕ}
    (ht : t < subBlockCount Ws S m.length) :
    bh (t % S) (subBlock enc Ws m t) = bh (t % S) (subBlock enc Ws m' t)
```

`ProvenHashes.Encoding.last_blockHash_sub_of_stream_eq`

```lean
lemma last_blockHash_sub_of_stream_eq {enc : (Fin 8 → Byte) → F} {Ws S : ℕ}
    {bh : ℕ → List F → F × F} {len : ℕ → F} {m m' : List Byte} (hS : 0 < S)
    (hs : stream enc Ws S bh len m = stream enc Ws S bh len m') :
    bh ((subBlockCount Ws S m.length - 1) % S)
        (subBlock enc Ws m (subBlockCount Ws S m.length - 1)) -
      bh ((subBlockCount Ws S m.length - 1) % S)
        (subBlock enc Ws m' (subBlockCount Ws S m.length - 1)) =
      (len m'.length - len m.length, len m'.length - len m.length)
```

`ProvenHashes.Encoding.stream_ne_of_subBlocks_eq`

```lean
theorem stream_ne_of_subBlocks_eq {enc : (Fin 8 → Byte) → F} {Ws S : ℕ}
    {bh : ℕ → List F → F × F} {len : ℕ → F} {m m' : List Byte} (hS : 0 < S)
    (hsub : subBlocks enc Ws S m = subBlocks enc Ws S m')
    (hL : len m.length ≠ len m'.length) :
    stream enc Ws S bh len m ≠ stream enc Ws S bh len m'
```

`ProvenHashes.Encoding.byteAt_append_zero`

```lean
lemma byteAt_append_zero (m : List Byte) (i : ℕ) : byteAt (m ++ [0]) i = byteAt m i
```

`ProvenHashes.Encoding.wordAt_append_zero`

```lean
lemma wordAt_append_zero (m : List Byte) (i : ℕ) : wordAt (m ++ [0]) i = wordAt m i
```

`ProvenHashes.Encoding.groupCount_succ`

```lean
lemma groupCount_succ {Ws ℓ t : ℕ} (hd : 32 ∣ 8 * Ws) (h : ¬ (32 ∣ ℓ)) :
    groupCount Ws (ℓ + 1) t = groupCount Ws ℓ t
```

`ProvenHashes.Encoding.blockCount_succ`

```lean
lemma blockCount_succ {Ws S ℓ : ℕ} (hWs : 0 < Ws) (hS : 0 < S) (hd : 32 ∣ 8 * Ws)
    (h : ¬ (32 ∣ ℓ)) : blockCount Ws S (ℓ + 1) = blockCount Ws S ℓ
```

`ProvenHashes.Encoding.subBlock_append_zero`

```lean
lemma subBlock_append_zero {enc : (Fin 8 → Byte) → F} {Ws : ℕ} (hd : 32 ∣ 8 * Ws)
    {m : List Byte} (h : ¬ (32 ∣ m.length)) (t : ℕ) :
    subBlock enc Ws (m ++ [0]) t = subBlock enc Ws m t
```

`ProvenHashes.Encoding.subBlocks_append_zero`

```lean
theorem subBlocks_append_zero {enc : (Fin 8 → Byte) → F} {Ws S : ℕ} (hWs : 0 < Ws) (hS : 0 < S)
    (hd : 32 ∣ 8 * Ws) {m : List Byte} (h : ¬ (32 ∣ m.length)) :
    subBlocks enc Ws S (m ++ [0]) = subBlocks enc Ws S m
```

`ProvenHashes.Encoding.stream_ne_append_zero`

```lean
theorem stream_ne_append_zero [Field F] {enc : (Fin 8 → Byte) → F} {Ws S : ℕ}
    {bh : ℕ → List F → F × F} {len : ℕ → F} (hWs : 0 < Ws) (hS : 0 < S) (hd : 32 ∣ 8 * Ws)
    {m : List Byte} (h : ¬ (32 ∣ m.length)) (hlen : len (m.length + 1) ≠ len m.length) :
    stream enc Ws S bh len (m ++ [0]) ≠ stream enc Ws S bh len m
```

`ProvenHashes.Encoding.uniformProb_le_of_not`

```lean
lemma uniformProb_le_of_not {K : Type*} [Fintype K] [Nonempty K] {E : K → Prop}
    (h : ∀ k, ¬ E k) (b : ℚ≥0) : uniformProb E ≤ b
```

`ProvenHashes.Encoding.stream_collision_bound`

```lean
theorem stream_collision_bound {K : Type*} [Fintype K] [Nonempty K]
    {enc : (Fin 8 → Byte) → F} (hinj : Function.Injective enc)
    {Ws S : ℕ} (hWs : 0 < Ws) (hS : 0 < S) (h4 : 4 ∣ Ws)
    {bh : K → ℕ → List F → F × F} {len : ℕ → F}
    (hu : BlockHashUniversal Ws bh) (hu' : BlockHashUniversalLt Ws bh)
    {m m' : List Byte} (hne : m ≠ m')
    (hlen : m.length ≠ m'.length → len m.length ≠ len m'.length) :
    uniformProb (fun κ => stream enc Ws S (bh κ) len m = stream enc Ws S (bh κ) len m')
      ≤ 1 / Fintype.card F
```

`ProvenHashes.Encoding.chainhash_bytes_collision_bound`

```lean
theorem chainhash_bytes_collision_bound {K J : Type*} [Fintype K] [Fintype J]
    [Nonempty K] [Nonempty J]
    {enc : (Fin 8 → Byte) → F} (hinj : Function.Injective enc)
    {Ws S : ℕ} (hWs : 0 < Ws) (hS : 0 < S) (h4 : 4 ∣ Ws)
    {bh : K → ℕ → List F → F × F} {len : ℕ → F}
    (hu : BlockHashUniversal Ws bh) (hu' : BlockHashUniversalLt Ws bh)
    (fin : J → F → F)
    (hfin : ∀ v v', v ≠ v' → uniformProb (fun j => fin j v = fin j v') ≤ 1 / Fintype.card F)
    {n : ℕ} (hn : 0 < n) {m m' : List Byte}
    (hm : m.length ≤ n * (S * (8 * Ws))) (hm' : m'.length ≤ n * (S * (8 * Ws)))
    (hne : m ≠ m')
    (hlen : m.length ≠ m'.length → len m.length ≠ len m'.length) :
    uniformProb (fun k : (K × (Fin 3 → F)) × J =>
      fin k.2 (Recurrence.hash (stream enc Ws S (bh k.1.1) len m) k.1.2) =
        fin k.2 (Recurrence.hash (stream enc Ws S (bh k.1.1) len m') k.1.2)) ≤
      ((S * n + 2 : ℕ) : ℚ≥0) / Fintype.card F
```

`ProvenHashes.Encoding.card_word`

```lean
theorem card_word : Fintype.card (Fin 8 → Byte) = 2 ^ 64
```

`ProvenHashes.Encoding.exists_injective_enc`

```lean
theorem exists_injective_enc {F : Type*} [Fintype F] (h : 2 ^ 64 ≤ Fintype.card F) :
    ∃ enc : (Fin 8 → Byte) → F, Function.Injective enc
```

`ProvenHashes.Encoding.swapMid_group`

```lean
theorem swapMid_group : swapMid 0 = 0 ∧ swapMid 1 = 2 ∧ swapMid 2 = 1 ∧ swapMid 3 = 3
```

`ProvenHashes.Encoding.subBlockOctets_getElem`

```lean
theorem subBlockOctets_getElem {Ws : ℕ} {m : List Byte} {t j : ℕ}
    (h : j < wordCount Ws m.length t) :
    (subBlockOctets Ws m t)[j]'(by simpa [subBlockOctets] using h) =
      wordAt m (t * Ws + swapMid j)
```

`ProvenHashes.Encoding.subBlockOctets_first_group`

```lean
theorem subBlockOctets_first_group {Ws : ℕ} {m : List Byte} (h : 4 ≤ wordCount Ws m.length 0) :
    (subBlockOctets Ws m 0).take 4 = [wordAt m 0, wordAt m 2, wordAt m 1, wordAt m 3]
```

`ProvenHashes.Encoding.subBlockCount_256`

```lean
theorem subBlockCount_256 (ℓ : ℕ) : subBlockCount 32 1 ℓ = max 1 ((ℓ + 255) / 256)
```

`ProvenHashes.Encoding.subBlockCount_zero`

```lean
theorem subBlockCount_zero {Ws S : ℕ} (hWs : 0 < Ws) (hS : 0 < S) :
    subBlockCount Ws S 0 = S
```

`ProvenHashes.Encoding.pairCount_zero_length`

```lean
theorem pairCount_zero_length (Ws t : ℕ) : pairCount Ws 0 t = 0
```

`ProvenHashes.Encoding.pairCount_le_sixteen`

```lean
theorem pairCount_le_sixteen {ℓ : ℕ} (h1 : 1 ≤ ℓ) (h2 : ℓ ≤ 16) : pairCount 32 ℓ 0 = 2
```

`ProvenHashes.Encoding.pairCount_full`

```lean
theorem pairCount_full {ℓ t : ℕ} (h : (t + 1) * 256 ≤ ℓ) : pairCount 32 ℓ t = 16
```

## [FieldStream.lean](ProvenHashes/FieldStream.lean)

`ProvenHashes.ChainHash.splitWords_injective`

```lean
theorem splitWords_injective {p q : BitsPolynomial} (hp : p.natDegree < 128)
    (hq : q.natDegree < 128)
    (hl : lowWord p = lowWord q) (hh : highWord p = highWord q) : p = q
```

`ProvenHashes.ChainHash.lengthMask_natDegree_le`

```lean
theorem lengthMask_natDegree_le (n : ℕ) : (lengthMask n).natDegree ≤ 127
```

`ProvenHashes.ChainHash.rawDigest_natDegree_lt`

```lean
theorem rawDigest_natDegree_lt (m : Message) (k : BlockKey) (t : ℕ) :
    (rawDigest m k t).natDegree < 128
```

`ProvenHashes.ChainHash.splitField_injective`

```lean
theorem splitField_injective {F : Type*} [AddGroup F] (repr : Word 64 ≃+ F)
    {p q : BitsPolynomial} (hp : p.natDegree < 128) (hq : q.natDegree < 128)
    (h : splitField repr p = splitField repr q) : p = q
```

`ProvenHashes.ChainHash.stream_length`

```lean
theorem stream_length {F : Type*} [AddGroup F] (repr : Word 64 ≃+ F)
    (m : Message) (k : BlockKey) : (stream repr m k).length = blockCount m
```

`ProvenHashes.ChainHash.stream_eq_rawStream`

```lean
theorem stream_eq_rawStream {F : Type*} [AddGroup F] (repr : Word 64 ≃+ F)
    (m m' : Message) (k : BlockKey) (h : stream repr m k = stream repr m' k) :
    rawStream m k = rawStream m' k
```

`ProvenHashes.ChainHash.stream_collision_bound`

```lean
theorem stream_collision_bound {F : Type*} [AddGroup F] (repr : Word 64 ≃+ F)
    (m m' : Message) (hm : m.length < 2 ^ 64) (hm' : m'.length < 2 ^ 64) (hne : m ≠ m') :
    uniformProb (fun k => stream repr m k = stream repr m' k) ≤ 1 / (2 : ℚ≥0) ^ 64
```

## [Finalizer.lean](ProvenHashes/Finalizer.lean)

`ProvenHashes.ChainHash.decode_coefficients`

```lean
theorem decode_coefficients {F : Type*} [CommRing F] (c : Fin 5 → F) :
    decodeCoefficients (coefficients c) = c
```

`ProvenHashes.ChainHash.coefficients_decode`

```lean
theorem coefficients_decode {F : Type*} [CommRing F] (e : Fin 5 → F) :
    coefficients (decodeCoefficients e) = e
```

`ProvenHashes.ChainHash.chain5_expansion`

```lean
theorem chain5_expansion {F : Type*} [CommRing F] (c : Fin 5 → F) (v : F) :
    chain5 c v = v ^ 5 + ∑ i : Fin 5, coefficients c i * v ^ (i : ℕ)
```

`ProvenHashes.ChainHash.chain5_collision_exact`

```lean
theorem chain5_collision_exact {F : Type*} [Field F] [Fintype F]
    (v w : F) (hne : v ≠ w) :
    uniformProb (fun c : Fin 5 → F => chain5 c v = chain5 c w) =
      1 / Fintype.card F
```

`ProvenHashes.ChainHash.chain5_twisted_collision_exact`

```lean
theorem chain5_twisted_collision_exact {F : Type*} [Field F] [Fintype F]
    (ψ : F → F) (hψ : Function.Injective ψ) (v w : F) (hne : v ≠ w) :
    uniformProb (fun c : Fin 5 → F => chain5 c (ψ v) = chain5 c (ψ w)) =
      1 / Fintype.card F
```

`ProvenHashes.ChainHash.integerTwist_bijective`

```lean
theorem integerTwist_bijective {F : Type*} (word : F ≃ ZMod (2 ^ 64)) (τ : F) :
    Function.Bijective (integerTwist word τ)
```

## [FinalizerIndependence.lean](ProvenHashes/FinalizerIndependence.lean)

`ProvenHashes.ChainHash.decode_quinticValues`

```lean
theorem decode_quinticValues {F : Type*} [Field F] [DecidableEq F]
    (v : Fin 5 → F) (hv : Function.Injective v) (e : Fin 5 → F) :
    decodeValues v (quinticValues v e) = e
```

`ProvenHashes.ChainHash.quinticValues_decode`

```lean
theorem quinticValues_decode {F : Type*} [Field F] [DecidableEq F]
    (v : Fin 5 → F) (hv : Function.Injective v) (r : Fin 5 → F) :
    quinticValues v (decodeValues v r) = r
```

`ProvenHashes.ChainHash.chain5_values`

```lean
theorem chain5_values {F : Type*} [Field F] [DecidableEq F] (c v : Fin 5 → F) :
    (fun i => chain5 c (v i)) = quinticValues v (coefficients c)
```

`ProvenHashes.ChainHash.chain5_fivewise_exact`

```lean
theorem chain5_fivewise_exact {F : Type*} [Field F] [Fintype F]
    (v : Fin 5 → F) (hv : Function.Injective v) (r : Fin 5 → F) :
    uniformProb (fun c : Fin 5 → F => (fun i => chain5 c (v i)) = r) =
      1 / (Fintype.card F : ℚ≥0) ^ 5
```

`ProvenHashes.ChainHash.chain5_twisted_fivewise_exact`

```lean
theorem chain5_twisted_fivewise_exact {F : Type*} [Field F] [Fintype F]
    (ψ : F → F) (hψ : Function.Injective ψ) (v : Fin 5 → F)
    (hv : Function.Injective v) (r : Fin 5 → F) :
    uniformProb (fun c : Fin 5 → F => (fun i => chain5 c (ψ (v i))) = r) =
      1 / (Fintype.card F : ℚ≥0) ^ 5
```

## [FinalizerKwise.lean](ProvenHashes/FinalizerKwise.lean)

`ProvenHashes.uniformProb_surjective_addHom`

```lean
theorem uniformProb_surjective_addHom {A B : Type*}
    [AddGroup A] [AddGroup B] [Fintype A] [Fintype B]
    (f : A →+ B) (hf : Function.Surjective f) (t : B) :
    uniformProb (fun a => f a = t) = 1 / Fintype.card B
```

`ProvenHashes.Finalizer.evalHom_surjective`

```lean
theorem evalHom_surjective {F : Type*} [Field F] {t : ℕ} (ht : t ≤ 5)
    (v : Fin t → F) (hv : Function.Injective v) : Function.Surjective (evalHom v)
```

`ProvenHashes.Finalizer.kwise_uniform`

```lean
theorem kwise_uniform {F : Type*} [Field F] [Fintype F] {t : ℕ} (ht : t ≤ 5)
    (v : Fin t → F) (hv : Function.Injective v) (r : Fin t → F) :
    uniformProb (fun c : Fin 5 → F => (fun j => circuit c (v j)) = r) =
      1 / (Fintype.card F : ℚ≥0) ^ t
```

`ProvenHashes.Finalizer.twisted_kwise_uniform`

```lean
theorem twisted_kwise_uniform {F : Type*} [Field F] [Fintype F] {t : ℕ}
    (ht : t ≤ 5) (word : F ≃ ZMod (2 ^ 64)) (τ : ZMod (2 ^ 64))
    (v : Fin t → F) (hv : Function.Injective v) (r : Fin t → F) :
    uniformProb (fun c : Fin 5 → F => (fun j => circuit c (twist word τ (v j))) = r) =
      1 / (Fintype.card F : ℚ≥0) ^ t
```

## [FlatKey.lean](ProvenHashes/FlatKey.lean)

`ProvenHashes.ChainHash256.encode_decode_flat`

```lean
theorem encode_decode_flat {F : Type*} [AddGroup F] (e : Word 64 ≃+ F) (k : FlatKey) :
    encodeFlat e (decodeFlat e k) = k
```

`ProvenHashes.ChainHash256.decode_encode_flat`

```lean
theorem decode_encode_flat {F : Type*} [AddGroup F] (e : Word 64 ≃+ F) (k : IdealKey F) :
    decodeFlat e (encodeFlat e k) = k
```

`ProvenHashes.ChainHash256.flatKey_card`

```lean
theorem flatKey_card : Fintype.card FlatKey = 2 ^ (64 * 41)
```

`ProvenHashes.ChainHash256.collision_bound_flat`

```lean
theorem collision_bound_flat {F : Type*} [Field F] [Fintype F]
    (e : Word 64 ≃+ F) (L : ℕ) (hL : 8 * L < 2 ^ 64)
    (m m' : Bytes) (hm : m.length ≤ 8 * L) (hm' : m'.length ≤ 8 * L) (hne : m ≠ m') :
    uniformProb (fun k : FlatKey => hashFlat e k m = hashFlat e k m') ≤ epsilon L
```

## [GF64Bezout.lean](ProvenHashes/GF64Bezout.lean)

`ProvenHashes.GF64Certificate.bezout32`

```lean
theorem bezout32 : (X ^ 60 + X ^ 57 + X ^ 48 + X ^ 46 + X ^ 41 + X ^ 38 + X ^ 37 + X ^ 35 + X ^ 32 + X ^ 26 + X ^ 25 + X ^ 22 + X ^ 21 + X ^ 20 + X ^ 18 + X ^ 17 + X ^ 15 + X ^ 12 + X ^ 11 + X ^ 7 + X ^ 5 + X ^ 3 + X ^ 2) * modulus + (X ^ 62 + X ^ 60 + X ^ 57 + X ^ 56 + X ^ 55 + X ^ 54 + X ^ 51 + X ^ 49 + X ^ 47 + X ^ 46 + X ^ 44 + X ^ 40 + X ^ 38 + X ^ 37 + X ^ 32 + X ^ 31 + X ^ 29 + X ^ 28 + X ^ 27 + X ^ 26 + X ^ 25 + X ^ 24 + X ^ 22 + X ^ 20 + X ^ 19 + X ^ 17 + X ^ 15 + X ^ 11 + X ^ 8 + X ^ 7 + X ^ 6 + X ^ 2 + X + 1) * (r32 + X) = 1
```

## [GF64Certificate.lean](ProvenHashes/GF64Certificate.lean)

`ProvenHashes.GF64Certificate.square_eval`

```lean
lemma square_eval {A : Type*} [CommRing A] [Algebra (ZMod 2) A]
    (x : A) (hx : aeval x modulus = 0) {p q s : (ZMod 2)[X]}
    (h : p ^ 2 = q + modulus * s) : (aeval x p) ^ 2 = aeval x q
```

`ProvenHashes.GF64Certificate.root_pow32`

```lean
theorem root_pow32 {A : Type*} [CommRing A] [Algebra (ZMod 2) A]
    (x : A) (hx : aeval x modulus = 0) :
    x ^ (2 ^ 32) = aeval x r32
```

`ProvenHashes.GF64Certificate.root_pow64`

```lean
theorem root_pow64 {A : Type*} [CommRing A] [Algebra (ZMod 2) A]
    (x : A) (hx : aeval x modulus = 0) :
    x ^ (2 ^ 64) = aeval x r64
```

`ProvenHashes.GF64Certificate.root_frobenius64`

```lean
theorem root_frobenius64 {A : Type*} [CommRing A] [Algebra (ZMod 2) A]
    (x : A) (hx : aeval x modulus = 0) : x ^ (2 ^ 64) = x
```

`ProvenHashes.GF64Certificate.root_not_frobenius32`

```lean
theorem root_not_frobenius32 {A : Type*} [CommRing A] [Nontrivial A]
    [Algebra (ZMod 2) A] [CharP A 2]
    (x : A) (hx : aeval x modulus = 0) : x ^ (2 ^ 32) ≠ x
```

## [GF64CertificateData.lean](ProvenHashes/GF64CertificateData.lean)

`ProvenHashes.GF64Certificate.modulus_monic`

```lean
theorem modulus_monic : modulus.Monic
```

`ProvenHashes.GF64Certificate.modulus_degree`

```lean
theorem modulus_degree : modulus.degree = 64
```

`ProvenHashes.GF64Certificate.modulus_natDegree`

```lean
theorem modulus_natDegree : modulus.natDegree = 64
```

## [GF64Irreducible.lean](ProvenHashes/GF64Irreducible.lean)

`ProvenHashes.GF64Certificate.proper_divisor_64`

```lean
lemma proper_divisor_64 {d : ℕ} (hd : d ≤ 32) (h : d ∣ 64) : d ∣ 32
```

`ProvenHashes.GF64Certificate.no_small_irreducible_factor`

```lean
theorem no_small_irreducible_factor (g : (ZMod 2)[X])
    (hgi : Irreducible g) (hdiv : g ∣ modulus) : 32 < g.natDegree
```

`ProvenHashes.GF64Certificate.modulus_irreducible`

```lean
theorem modulus_irreducible : Irreducible modulus
```

## [GF64Representation.lean](ProvenHashes/GF64Representation.lean)

`ProvenHashes.GF64Implementation.toWord_ofWord`

```lean
theorem toWord_ofWord (w : Word 64) : toWord (ofWord w) = w
```

`ProvenHashes.GF64Implementation.representative_degree`

```lean
theorem representative_degree (x : F64) :
    (AdjoinRoot.modByMonicHom modulus_monic x).degree < 64
```

`ProvenHashes.GF64Implementation.ofWord_toWord`

```lean
theorem ofWord_toWord (x : F64) : ofWord (toWord x) = x
```

`ProvenHashes.GF64Implementation.field_card`

```lean
theorem field_card : Fintype.card F64 = 2 ^ 64
```

`ProvenHashes.GF64Implementation.reduce_eq_toWord`

```lean
theorem reduce_eq_toWord (p : (ZMod 2)[X]) : reduce p = toWord (AdjoinRoot.mk modulus p)
```

`ProvenHashes.GF64Implementation.multiplication_matches`

```lean
theorem multiplication_matches (a b : Word 64) :
    wordEquiv.symm (wordEquiv a * wordEquiv b) = reduce (toPoly a * toPoly b)
```

`ProvenHashes.GF64Implementation.addition_matches`

```lean
theorem addition_matches (a b : Word 64) :
    wordEquiv.symm (wordEquiv a + wordEquiv b) = a + b
```

## [GF64Square0.lean](ProvenHashes/GF64Square0.lean)

`ProvenHashes.GF64Certificate.square_0`

```lean
theorem square_0 : r0 ^ 2 = r1 + modulus * 0
```

`ProvenHashes.GF64Certificate.square_1`

```lean
theorem square_1 : r1 ^ 2 = r2 + modulus * 0
```

`ProvenHashes.GF64Certificate.square_2`

```lean
theorem square_2 : r2 ^ 2 = r3 + modulus * 0
```

`ProvenHashes.GF64Certificate.square_3`

```lean
theorem square_3 : r3 ^ 2 = r4 + modulus * 0
```

`ProvenHashes.GF64Certificate.square_4`

```lean
theorem square_4 : r4 ^ 2 = r5 + modulus * 0
```

`ProvenHashes.GF64Certificate.square_5`

```lean
theorem square_5 : r5 ^ 2 = r6 + modulus * (1)
```

`ProvenHashes.GF64Certificate.square_6`

```lean
theorem square_6 : r6 ^ 2 = r7 + modulus * 0
```

`ProvenHashes.GF64Certificate.square_7`

```lean
theorem square_7 : r7 ^ 2 = r8 + modulus * 0
```

## [GF64Square1.lean](ProvenHashes/GF64Square1.lean)

`ProvenHashes.GF64Certificate.square_8`

```lean
theorem square_8 : r8 ^ 2 = r9 + modulus * 0
```

`ProvenHashes.GF64Certificate.square_9`

```lean
theorem square_9 : r9 ^ 2 = r10 + modulus * (1)
```

`ProvenHashes.GF64Certificate.square_10`

```lean
theorem square_10 : r10 ^ 2 = r11 + modulus * (X ^ 32)
```

`ProvenHashes.GF64Certificate.square_11`

```lean
theorem square_11 : r11 ^ 2 = r12 + modulus * (X ^ 8 + X ^ 6 + X ^ 2)
```

`ProvenHashes.GF64Certificate.square_12`

```lean
theorem square_12 : r12 ^ 2 = r13 + modulus * 0
```

`ProvenHashes.GF64Certificate.square_13`

```lean
theorem square_13 : r13 ^ 2 = r14 + modulus * (1)
```

`ProvenHashes.GF64Certificate.square_14`

```lean
theorem square_14 : r14 ^ 2 = r15 + modulus * (X ^ 24 + X ^ 16 + 1)
```

`ProvenHashes.GF64Certificate.square_15`

```lean
theorem square_15 : r15 ^ 2 = r16 + modulus * (X ^ 48 + X ^ 16 + 1)
```

## [GF64Square2.lean](ProvenHashes/GF64Square2.lean)

`ProvenHashes.GF64Certificate.square_16`

```lean
theorem square_16 : r16 ^ 2 = r17 + modulus * (X ^ 48 + X ^ 44 + X ^ 40 + X ^ 38 + X ^ 36 + X ^ 34 + X ^ 32 + X ^ 16 + X ^ 12 + X ^ 4)
```

`ProvenHashes.GF64Certificate.square_17`

```lean
theorem square_17 : r17 ^ 2 = r18 + modulus * (X ^ 40 + X ^ 38 + X ^ 34 + X ^ 30 + X ^ 26 + X ^ 22 + X ^ 20 + X ^ 16 + X ^ 12 + X ^ 2 + 1)
```

`ProvenHashes.GF64Certificate.square_18`

```lean
theorem square_18 : r18 ^ 2 = r19 + modulus * (X ^ 32 + X ^ 24 + X ^ 22 + X ^ 20 + X ^ 14 + X ^ 12 + X ^ 10 + X ^ 6 + X ^ 4 + X ^ 2 + 1)
```

`ProvenHashes.GF64Certificate.square_19`

```lean
theorem square_19 : r19 ^ 2 = r20 + modulus * (X ^ 60 + X ^ 56 + X ^ 52 + X ^ 44 + X ^ 40 + X ^ 36 + X ^ 32 + X ^ 24 + X ^ 20 + X ^ 12 + X ^ 8 + X ^ 6 + X ^ 4 + X ^ 2 + 1)
```

`ProvenHashes.GF64Certificate.square_20`

```lean
theorem square_20 : r20 ^ 2 = r21 + modulus * (X ^ 62 + X ^ 58 + X ^ 56 + X ^ 54 + X ^ 50 + X ^ 46 + X ^ 44 + X ^ 42 + X ^ 40 + X ^ 32 + X ^ 30 + X ^ 26 + X ^ 24 + X ^ 22 + X ^ 20 + X ^ 18 + X ^ 14 + X ^ 10 + X ^ 8 + X ^ 6 + X ^ 4 + X)
```

`ProvenHashes.GF64Certificate.square_21`

```lean
theorem square_21 : r21 ^ 2 = r22 + modulus * (X ^ 62 + X ^ 58 + X ^ 56 + X ^ 46 + X ^ 44 + X ^ 42 + X ^ 38 + X ^ 36 + X ^ 34 + X ^ 32 + X ^ 28 + X ^ 24 + X ^ 18 + X ^ 16 + X ^ 6 + X ^ 4 + X ^ 2 + X + 1)
```

`ProvenHashes.GF64Certificate.square_22`

```lean
theorem square_22 : r22 ^ 2 = r23 + modulus * (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 50 + X ^ 40 + X ^ 36 + X ^ 34 + X ^ 32 + X ^ 22 + X ^ 18 + X ^ 16 + X ^ 12 + X)
```

`ProvenHashes.GF64Certificate.square_23`

```lean
theorem square_23 : r23 ^ 2 = r24 + modulus * (X ^ 60 + X ^ 54 + X ^ 42 + X ^ 40 + X ^ 38 + X ^ 22 + X ^ 20 + X ^ 18 + X ^ 16 + X ^ 14 + X ^ 12 + X ^ 8 + X ^ 2 + 1)
```

## [GF64Square3.lean](ProvenHashes/GF64Square3.lean)

`ProvenHashes.GF64Certificate.square_24`

```lean
theorem square_24 : r24 ^ 2 = r25 + modulus * (X ^ 62 + X ^ 58 + X ^ 56 + X ^ 52 + X ^ 50 + X ^ 46 + X ^ 44 + X ^ 40 + X ^ 36 + X ^ 32 + X ^ 26 + X ^ 24 + X ^ 20 + X ^ 16 + X ^ 14 + X ^ 12 + X ^ 4 + X ^ 2 + X + 1)
```

`ProvenHashes.GF64Certificate.square_25`

```lean
theorem square_25 : r25 ^ 2 = r26 + modulus * (X ^ 62 + X ^ 58 + X ^ 52 + X ^ 50 + X ^ 46 + X ^ 44 + X ^ 40 + X ^ 38 + X ^ 36 + X ^ 34 + X ^ 32 + X ^ 28 + X ^ 26 + X ^ 22 + X ^ 18 + X ^ 16 + X ^ 14 + X ^ 10 + X ^ 6 + X)
```

`ProvenHashes.GF64Certificate.square_26`

```lean
theorem square_26 : r26 ^ 2 = r27 + modulus * (X ^ 62 + X ^ 58 + X ^ 56 + X ^ 54 + X ^ 48 + X ^ 46 + X ^ 44 + X ^ 40 + X ^ 38 + X ^ 36 + X ^ 34 + X ^ 32 + X ^ 26 + X ^ 24 + X ^ 22 + X ^ 16 + X ^ 12 + X ^ 4 + X + 1)
```

`ProvenHashes.GF64Certificate.square_27`

```lean
theorem square_27 : r27 ^ 2 = r28 + modulus * (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 48 + X ^ 46 + X ^ 38 + X ^ 26 + X ^ 22 + X ^ 4 + X)
```

`ProvenHashes.GF64Certificate.square_28`

```lean
theorem square_28 : r28 ^ 2 = r29 + modulus * (X ^ 56 + X ^ 54 + X ^ 38 + X ^ 36 + X ^ 32 + X ^ 30 + X ^ 20 + X ^ 18 + X ^ 14 + X ^ 8 + X ^ 4 + 1)
```

`ProvenHashes.GF64Certificate.square_29`

```lean
theorem square_29 : r29 ^ 2 = r30 + modulus * (X ^ 56 + X ^ 54 + X ^ 46 + X ^ 40 + X ^ 36 + X ^ 28 + X ^ 24 + X ^ 20 + X ^ 18 + X ^ 12 + X ^ 10 + X ^ 6 + X ^ 4)
```

`ProvenHashes.GF64Certificate.square_30`

```lean
theorem square_30 : r30 ^ 2 = r31 + modulus * (X ^ 60 + X ^ 54 + X ^ 52 + X ^ 46 + X ^ 44 + X ^ 36 + X ^ 34 + X ^ 32 + X ^ 30 + X ^ 22 + X ^ 18 + X ^ 16 + X ^ 14 + X ^ 12 + X ^ 10 + X ^ 8 + X ^ 4 + 1)
```

`ProvenHashes.GF64Certificate.square_31`

```lean
theorem square_31 : r31 ^ 2 = r32 + modulus * (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 50 + X ^ 48 + X ^ 42 + X ^ 40 + X ^ 34 + X ^ 32 + X ^ 26 + X ^ 24 + X ^ 14 + X ^ 2 + X + 1)
```

## [GF64Square4.lean](ProvenHashes/GF64Square4.lean)

`ProvenHashes.GF64Certificate.square_32`

```lean
theorem square_32 : r32 ^ 2 = r33 + modulus * (X ^ 60 + X ^ 56 + X ^ 54 + X ^ 52 + X ^ 44 + X ^ 42 + X ^ 34 + X ^ 26 + X ^ 18 + X ^ 16 + X ^ 12 + X ^ 10 + X ^ 4 + X ^ 2)
```

`ProvenHashes.GF64Certificate.square_33`

```lean
theorem square_33 : r33 ^ 2 = r34 + modulus * (X ^ 62 + X ^ 58 + X ^ 56 + X ^ 54 + X ^ 48 + X ^ 44 + X ^ 42 + X ^ 36 + X ^ 30 + X ^ 28 + X ^ 24 + X ^ 22 + X ^ 20 + X ^ 12 + X ^ 10 + X ^ 6 + X ^ 2 + X)
```

`ProvenHashes.GF64Certificate.square_34`

```lean
theorem square_34 : r34 ^ 2 = r35 + modulus * (X ^ 62 + X ^ 58 + X ^ 56 + X ^ 52 + X ^ 48 + X ^ 46 + X ^ 38 + X ^ 34 + X ^ 30 + X ^ 28 + X ^ 22 + X ^ 16 + X ^ 14 + X ^ 10 + X)
```

`ProvenHashes.GF64Certificate.square_35`

```lean
theorem square_35 : r35 ^ 2 = r36 + modulus * (X ^ 62 + X ^ 58 + X ^ 56 + X ^ 50 + X ^ 48 + X ^ 46 + X ^ 44 + X ^ 42 + X ^ 40 + X ^ 38 + X ^ 36 + X ^ 30 + X ^ 28 + X ^ 18 + X ^ 14 + X ^ 10 + X ^ 6 + X + 1)
```

`ProvenHashes.GF64Certificate.square_36`

```lean
theorem square_36 : r36 ^ 2 = r37 + modulus * (X ^ 62 + X ^ 58 + X ^ 56 + X ^ 50 + X ^ 44 + X ^ 42 + X ^ 36 + X ^ 28 + X ^ 16 + X ^ 10 + X ^ 8 + X ^ 4 + X)
```

`ProvenHashes.GF64Certificate.square_37`

```lean
theorem square_37 : r37 ^ 2 = r38 + modulus * (X ^ 62 + X ^ 58 + X ^ 56 + X ^ 50 + X ^ 48 + X ^ 44 + X ^ 42 + X ^ 40 + X ^ 38 + X ^ 36 + X ^ 30 + X ^ 28 + X ^ 24 + X ^ 22 + X ^ 14 + X ^ 12 + X ^ 10 + X ^ 8 + X ^ 4 + X ^ 2 + X + 1)
```

`ProvenHashes.GF64Certificate.square_38`

```lean
theorem square_38 : r38 ^ 2 = r39 + modulus * (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 50 + X ^ 44 + X ^ 42 + X ^ 36 + X ^ 34 + X ^ 32 + X ^ 30 + X ^ 28 + X ^ 24 + X ^ 10 + X)
```

`ProvenHashes.GF64Certificate.square_39`

```lean
theorem square_39 : r39 ^ 2 = r40 + modulus * (X ^ 54 + X ^ 42 + X ^ 38 + X ^ 36 + X ^ 30 + X ^ 22 + X ^ 20 + X ^ 16 + X ^ 14 + X ^ 12 + X ^ 4 + 1)
```

## [GF64Square5.lean](ProvenHashes/GF64Square5.lean)

`ProvenHashes.GF64Certificate.square_40`

```lean
theorem square_40 : r40 ^ 2 = r41 + modulus * (X ^ 56 + X ^ 50 + X ^ 48 + X ^ 46 + X ^ 36 + X ^ 28 + X ^ 26 + X ^ 22 + X ^ 18 + X ^ 12 + X ^ 10 + X ^ 4 + X ^ 2)
```

`ProvenHashes.GF64Certificate.square_41`

```lean
theorem square_41 : r41 ^ 2 = r42 + modulus * (X ^ 60 + X ^ 54 + X ^ 50 + X ^ 48 + X ^ 44 + X ^ 42 + X ^ 40 + X ^ 36 + X ^ 32 + X ^ 30 + X ^ 28 + X ^ 20 + X ^ 16 + X ^ 14 + X ^ 12 + X ^ 10)
```

`ProvenHashes.GF64Certificate.square_42`

```lean
theorem square_42 : r42 ^ 2 = r43 + modulus * (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 52 + X ^ 50 + X ^ 46 + X ^ 44 + X ^ 42 + X ^ 34 + X ^ 32 + X ^ 30 + X ^ 18 + X ^ 16 + X ^ 14 + X ^ 12 + X ^ 10 + X ^ 8 + X ^ 6 + X ^ 4 + X ^ 2 + X + 1)
```

`ProvenHashes.GF64Certificate.square_43`

```lean
theorem square_43 : r43 ^ 2 = r44 + modulus * (X ^ 56 + X ^ 54 + X ^ 46 + X ^ 44 + X ^ 40 + X ^ 38 + X ^ 34 + X ^ 32 + X ^ 28 + X ^ 22 + X ^ 10 + 1)
```

`ProvenHashes.GF64Certificate.square_44`

```lean
theorem square_44 : r44 ^ 2 = r45 + modulus * (X ^ 60 + X ^ 54 + X ^ 52 + X ^ 46 + X ^ 44 + X ^ 36 + X ^ 34 + X ^ 28 + X ^ 26 + X ^ 22 + X ^ 16 + X ^ 14 + X ^ 10 + X ^ 8 + X ^ 4 + X ^ 2 + 1)
```

`ProvenHashes.GF64Certificate.square_45`

```lean
theorem square_45 : r45 ^ 2 = r46 + modulus * (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 56 + X ^ 50 + X ^ 44 + X ^ 42 + X ^ 34 + X ^ 26 + X ^ 16 + X ^ 14 + X ^ 12 + X ^ 8 + X ^ 6 + X ^ 4 + X ^ 2 + X)
```

`ProvenHashes.GF64Certificate.square_46`

```lean
theorem square_46 : r46 ^ 2 = r47 + modulus * (X ^ 60 + X ^ 56 + X ^ 52 + X ^ 50 + X ^ 48 + X ^ 42 + X ^ 40 + X ^ 38 + X ^ 32 + X ^ 30 + X ^ 24 + X ^ 22 + X ^ 20 + X ^ 16 + X ^ 10 + X ^ 8 + X ^ 6 + X ^ 4 + 1)
```

`ProvenHashes.GF64Certificate.square_47`

```lean
theorem square_47 : r47 ^ 2 = r48 + modulus * (X ^ 62 + X ^ 58 + X ^ 54 + X ^ 52 + X ^ 50 + X ^ 46 + X ^ 36 + X ^ 34 + X ^ 28 + X ^ 26 + X ^ 24 + X ^ 16 + X ^ 14 + X ^ 8 + X ^ 6 + X ^ 4 + X ^ 2 + X)
```

## [GF64Square6.lean](ProvenHashes/GF64Square6.lean)

`ProvenHashes.GF64Certificate.square_48`

```lean
theorem square_48 : r48 ^ 2 = r49 + modulus * (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 56 + X ^ 54 + X ^ 50 + X ^ 44 + X ^ 40 + X ^ 38 + X ^ 34 + X ^ 30 + X ^ 28 + X ^ 20 + X ^ 14 + X ^ 8 + X ^ 6 + X ^ 2 + X + 1)
```

`ProvenHashes.GF64Certificate.square_49`

```lean
theorem square_49 : r49 ^ 2 = r50 + modulus * (X ^ 60 + X ^ 56 + X ^ 46 + X ^ 42 + X ^ 38 + X ^ 32 + X ^ 30 + X ^ 26 + X ^ 22 + X ^ 20 + X ^ 16 + X ^ 14 + X ^ 12 + X ^ 10 + X ^ 8 + X ^ 6 + X ^ 2 + 1)
```

`ProvenHashes.GF64Certificate.square_50`

```lean
theorem square_50 : r50 ^ 2 = r51 + modulus * (X ^ 62 + X ^ 58 + X ^ 54 + X ^ 52 + X ^ 50 + X ^ 48 + X ^ 36 + X ^ 34 + X ^ 30 + X ^ 28 + X ^ 26 + X ^ 24 + X ^ 22 + X ^ 20 + X ^ 18 + X ^ 16 + X ^ 14 + X ^ 12 + X ^ 6 + X ^ 2 + X)
```

`ProvenHashes.GF64Certificate.square_51`

```lean
theorem square_51 : r51 ^ 2 = r52 + modulus * (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 56 + X ^ 54 + X ^ 52 + X ^ 50 + X ^ 44 + X ^ 34 + X ^ 20 + X ^ 16 + X ^ 14 + X ^ 6 + X)
```

`ProvenHashes.GF64Certificate.square_52`

```lean
theorem square_52 : r52 ^ 2 = r53 + modulus * (X ^ 48 + X ^ 40 + X ^ 38 + X ^ 36 + X ^ 30 + X ^ 26 + X ^ 24 + X ^ 12 + X ^ 10 + X ^ 6 + X ^ 4)
```

`ProvenHashes.GF64Certificate.square_53`

```lean
theorem square_53 : r53 ^ 2 = r54 + modulus * (X ^ 38 + X ^ 34 + X ^ 32 + X ^ 28 + X ^ 24 + X ^ 22 + X ^ 10 + X ^ 8 + X ^ 4 + X ^ 2 + 1)
```

`ProvenHashes.GF64Certificate.square_54`

```lean
theorem square_54 : r54 ^ 2 = r55 + modulus * (X ^ 60 + X ^ 56 + X ^ 52 + X ^ 48 + X ^ 40 + X ^ 36 + X ^ 32 + X ^ 20 + X ^ 18 + X ^ 16 + X ^ 14 + X ^ 10 + X ^ 4 + X ^ 2)
```

`ProvenHashes.GF64Certificate.square_55`

```lean
theorem square_55 : r55 ^ 2 = r56 + modulus * (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 56 + X ^ 54 + X ^ 52 + X ^ 50 + X ^ 46 + X ^ 44 + X ^ 42 + X ^ 40 + X ^ 38 + X ^ 34 + X ^ 32 + X ^ 28 + X ^ 24 + X ^ 22 + X ^ 18 + X ^ 16 + X ^ 14 + X ^ 10 + X ^ 8 + X ^ 6 + X + 1)
```

## [GF64Square7.lean](ProvenHashes/GF64Square7.lean)

`ProvenHashes.GF64Certificate.square_56`

```lean
theorem square_56 : r56 ^ 2 = r57 + modulus * (X ^ 48 + X ^ 38 + X ^ 34 + X ^ 28 + X ^ 24 + X ^ 16 + X ^ 14 + X ^ 10 + X ^ 4 + X ^ 2)
```

`ProvenHashes.GF64Certificate.square_57`

```lean
theorem square_57 : r57 ^ 2 = r58 + modulus * (X ^ 60 + X ^ 56 + X ^ 52 + X ^ 48 + X ^ 44 + X ^ 40 + X ^ 38 + X ^ 34 + X ^ 32 + X ^ 28 + X ^ 24 + X ^ 18 + X ^ 14 + X ^ 10 + X ^ 6 + X ^ 4 + 1)
```

`ProvenHashes.GF64Certificate.square_58`

```lean
theorem square_58 : r58 ^ 2 = r59 + modulus * (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 56 + X ^ 54 + X ^ 52 + X ^ 50 + X ^ 48 + X ^ 46 + X ^ 44 + X ^ 42 + X ^ 40 + X ^ 38 + X ^ 36 + X ^ 34 + X ^ 32 + X ^ 30 + X ^ 26 + X ^ 22 + X ^ 20 + X ^ 14 + X ^ 12 + X ^ 10 + X ^ 4 + X + 1)
```

`ProvenHashes.GF64Certificate.square_59`

```lean
theorem square_59 : r59 ^ 2 = r60 + modulus * (X ^ 60 + X ^ 56 + X ^ 52 + X ^ 48 + X ^ 44 + X ^ 40 + X ^ 36 + X ^ 32 + X ^ 20 + X ^ 12 + X ^ 4 + 1)
```

`ProvenHashes.GF64Certificate.square_60`

```lean
theorem square_60 : r60 ^ 2 = r61 + modulus * (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 56 + X ^ 54 + X ^ 52 + X ^ 50 + X ^ 48 + X ^ 46 + X ^ 44 + X ^ 42 + X ^ 40 + X ^ 38 + X ^ 36 + X ^ 34 + X ^ 32 + X ^ 30 + X ^ 26 + X ^ 22 + X ^ 20 + X ^ 18 + X ^ 16 + X ^ 14 + X ^ 10 + X ^ 6 + X ^ 4 + X)
```

`ProvenHashes.GF64Certificate.square_61`

```lean
theorem square_61 : r61 ^ 2 = r62 + modulus * (X ^ 28 + X ^ 24 + X ^ 20 + X ^ 16)
```

`ProvenHashes.GF64Certificate.square_62`

```lean
theorem square_62 : r62 ^ 2 = r63 + modulus * (X ^ 60 + X ^ 56 + X ^ 52 + X ^ 48 + X ^ 44 + X ^ 40 + X ^ 36 + X ^ 32 + 1)
```

`ProvenHashes.GF64Certificate.square_63`

```lean
theorem square_63 : r63 ^ 2 = r64 + modulus * (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 56 + X ^ 54 + X ^ 52 + X ^ 50 + X ^ 48 + X ^ 46 + X ^ 44 + X ^ 42 + X ^ 40 + X ^ 38 + X ^ 36 + X ^ 34 + X ^ 32 + X ^ 30 + X ^ 28 + X ^ 26 + X ^ 24 + X ^ 22 + X ^ 20 + X ^ 18 + X ^ 16 + X ^ 14 + X ^ 12 + X ^ 10 + X ^ 8 + X ^ 6 + X ^ 4 + X)
```

## [KeyLayout.lean](ProvenHashes/KeyLayout.lean)

`ProvenHashes.ChainHash.encode_decodeKey`

```lean
theorem encode_decodeKey {F : Type*} [AddGroup F] (repr : Word 64 ≃+ F) (k : Key41) :
    encodeKey repr (decodeKey repr k) = k
```

`ProvenHashes.ChainHash.decode_encodeKey`

```lean
theorem decode_encodeKey {F : Type*} [AddGroup F] (repr : Word 64 ≃+ F) (k : IdealKey F) :
    decodeKey repr (encodeKey repr k) = k
```

## [MachineTwist.lean](ProvenHashes/MachineTwist.lean)

`ProvenHashes.ChainEncoding.integerEquiv_add_bits`

```lean
theorem integerEquiv_add_bits (v t : BitVec 64) :
    integerEquiv 64 ((bitsEquiv 64) (v + t)) =
      integerEquiv 64 ((bitsEquiv 64) v) + integerEquiv 64 ((bitsEquiv 64) t)
```

`ProvenHashes.ChainEncoding.field_twist_matches`

```lean
theorem field_twist_matches {F : Type*} [AddGroup F] (e : Word 64 ≃+ F)
    (v t : BitVec 64) :
    Finalizer.twist (ChainHash256.fieldInteger e) (integerEquiv 64 ((bitsEquiv 64) t))
      (e ((bitsEquiv 64) v)) = e ((bitsEquiv 64) (v + t))
```

`ProvenHashes.ChainEncoding.blockCount_matches_reference`

```lean
theorem blockCount_matches_reference (n : ℕ) :
    blockCount n = if n = 0 then 1 else (n + 255) / 256
```

`ProvenHashes.ChainEncoding.remaining_before_last`

```lean
theorem remaining_before_last {n t : ℕ} (ht : t + 1 < blockCount n) :
    remaining n t = 256
```

## [MaskedNH.lean](ProvenHashes/MaskedNH.lean)

`ProvenHashes.affine_embedded_sum_bound`

```lean
theorem affine_embedded_sum_bound {I W R : Type*}
    [Fintype I] [DecidableEq I] [Fintype W] [Nonempty W]
    [CommRing R] [IsDomain R]
    (e : W → R) (he : Function.Injective e) (c : I → R) (d : R)
    (hc : ∃ i, c i ≠ 0) (t : R) :
    uniformProb (fun k : I → W => d + ∑ i, c i * e (k i) = t) ≤
      1 / Fintype.card W
```

`ProvenHashes.maskedNH_affine`

```lean
lemma maskedNH_affine {I W R : Type*} [Fintype I] [DecidableEq I] [CommRing R]
    (e : W → R) (s : Finset I) (m : I × Bool → W) (l r : I → W) :
    maskedNH e s m (l, r) =
      (∑ i, maskedSlope e s m l i * e (m (i, true))) +
        ∑ i, maskedSlope e s m l i * e (r i)
```

`ProvenHashes.maskedNH_difference_affine`

```lean
lemma maskedNH_difference_affine {I W R : Type*}
    [Fintype I] [DecidableEq I] [CommRing R]
    (e : W → R) (s t : Finset I) (m m' : I × Bool → W) (l r : I → W) :
    maskedNH e s m (l, r) - maskedNH e t m' (l, r) =
      (∑ i, (maskedSlope e s m l i * e (m (i, true)) -
        maskedSlope e t m' l i * e (m' (i, true)))) +
      ∑ i, (maskedSlope e s m l i - maskedSlope e t m' l i) * e (r i)
```

`ProvenHashes.maskedNH_overlap_left_bound`

```lean
theorem maskedNH_overlap_left_bound {I W R : Type*}
    [Fintype I] [DecidableEq I] [Fintype W] [Nonempty W] [CommRing R] [IsDomain R]
    (e : W → R) (he : Function.Injective e) (s t : Finset I)
    (m m' : I × Bool → W) (i : I) (hs : i ∈ s) (ht : i ∈ t)
    (hi : m (i, false) ≠ m' (i, false)) (C : R) :
    uniformProb (fun k => maskedNH e s m k - maskedNH e t m' k = C) ≤
      1 / Fintype.card W
```

`ProvenHashes.maskedNH_swap`

```lean
lemma maskedNH_swap {I W R : Type*} [Fintype I] [DecidableEq I] [CommRing R]
    (e : W → R) (s : Finset I) (m : I × Bool → W) (l r : I → W) :
    maskedNH e s (fun j => m (j.1, !j.2)) (r, l) = maskedNH e s m (l, r)
```

`ProvenHashes.maskedNH_overlap_bound`

```lean
theorem maskedNH_overlap_bound {I W R : Type*}
    [Fintype I] [DecidableEq I] [Fintype W] [Nonempty W] [CommRing R] [IsDomain R]
    (e : W → R) (he : Function.Injective e) (s t : Finset I)
    (m m' : I × Bool → W) (i : I) (hs : i ∈ s) (ht : i ∈ t)
    (hi : ∃ b, m (i, b) ≠ m' (i, b)) (C : R) :
    uniformProb (fun k => maskedNH e s m k - maskedNH e t m' k = C) ≤
      1 / Fintype.card W
```

`ProvenHashes.maskedNH_nonzero_bound`

```lean
theorem maskedNH_nonzero_bound {I W R : Type*}
    [Fintype I] [DecidableEq I] [Fintype W] [Nonempty W] [CommRing R] [IsDomain R]
    (e : W → R) (he : Function.Injective e) (s : Finset I)
    (m : I × Bool → W) (C : R) (hC : C ≠ 0) :
    uniformProb (fun k => maskedNH e s m k = C) ≤ 1 / Fintype.card W
```

`ProvenHashes.maskedNH_difference_of_agree`

```lean
lemma maskedNH_difference_of_agree {I W R : Type*}
    [Fintype I] [DecidableEq I] [CommRing R]
    (e : W → R) (s t : Finset I) (hst : s ⊆ t)
    (m m' : I × Bool → W) (h : ∀ i ∈ s, ∀ b, m (i, b) = m' (i, b))
    (k : (I → W) × (I → W)) :
    maskedNH e s m k - maskedNH e t m' k = -maskedNH e (t \ s) m' k
```

`ProvenHashes.maskedNH_difference_nonzero_bound`

```lean
theorem maskedNH_difference_nonzero_bound {I W R : Type*}
    [Fintype I] [DecidableEq I] [Fintype W] [Nonempty W] [CommRing R] [IsDomain R]
    (e : W → R) (he : Function.Injective e) (s t : Finset I) (hst : s ⊆ t)
    (m m' : I × Bool → W) (C : R) (hC : C ≠ 0) :
    uniformProb (fun k => maskedNH e s m k - maskedNH e t m' k = C) ≤
      1 / Fintype.card W
```

## [Modulus.lean](ProvenHashes/Modulus.lean)

`ProvenHashes.ChainHash.modulus_tail_degree`

```lean
theorem modulus_tail_degree : (X ^ 4 + X ^ 3 + X + 1 : BitsPolynomial).degree < 64
```

`ProvenHashes.ChainHash.modulus_monic`

```lean
theorem modulus_monic : modulus.Monic
```

`ProvenHashes.ChainHash.modulus_degree`

```lean
theorem modulus_degree : modulus.natDegree = 64
```

`ProvenHashes.ChainHash.square_test`

```lean
theorem square_test : ((X + 1 : BitsPolynomial) ^ 2) = X ^ 2 + 1
```

## [ModulusCertificate.lean](ProvenHashes/ModulusCertificate.lean)

`ProvenHashes.ChainHash.residue_bezout`

```lean
theorem residue_bezout : modulus * (sparse [2, 3, 5, 7, 11, 12, 15, 17, 18, 20, 21, 22, 25, 26, 32, 35, 37, 38, 41, 46, 48, 57, 60]) + (residue_32 - X) * (sparse [0, 1, 2, 6, 7, 8, 11, 15, 17, 19, 20, 22, 24, 25, 26, 27, 28, 29, 31, 32, 37, 38, 40, 44, 46, 47, 49, 51, 54, 55, 56, 57, 60, 62]) = 1
```

## [ModulusIrreducible.lean](ProvenHashes/ModulusIrreducible.lean)

`ProvenHashes.ChainHash.residue_power_step`

```lean
theorem residue_power_step (i : ℕ) (r s q : BitsPolynomial)
    (hs : r ^ 2 = s + modulus * q)
    (hr : AdjoinRoot.root modulus ^ (2 ^ i) = AdjoinRoot.mk modulus r) :
    AdjoinRoot.root modulus ^ (2 ^ (i + 1)) = AdjoinRoot.mk modulus s
```

`ProvenHashes.ChainHash.modulus_frobenius_certificates`

```lean
theorem modulus_frobenius_certificates :
    modulus ∣ X ^ (2 ^ 64) - X ∧ modulus ∣ X ^ (2 ^ 32) - residue_32
```

`ProvenHashes.ChainHash.modulus_irreducible`

```lean
theorem modulus_irreducible : Irreducible modulus
```

## [ModulusResidues.lean](ProvenHashes/ModulusResidues.lean)

`ProvenHashes.ChainHash.poly_num_2`

```lean
theorem poly_num_2 : (2 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_3`

```lean
theorem poly_num_3 : (3 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_4`

```lean
theorem poly_num_4 : (4 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_5`

```lean
theorem poly_num_5 : (5 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_6`

```lean
theorem poly_num_6 : (6 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_7`

```lean
theorem poly_num_7 : (7 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_8`

```lean
theorem poly_num_8 : (8 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_9`

```lean
theorem poly_num_9 : (9 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_10`

```lean
theorem poly_num_10 : (10 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_11`

```lean
theorem poly_num_11 : (11 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_12`

```lean
theorem poly_num_12 : (12 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_13`

```lean
theorem poly_num_13 : (13 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_14`

```lean
theorem poly_num_14 : (14 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_15`

```lean
theorem poly_num_15 : (15 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_16`

```lean
theorem poly_num_16 : (16 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_17`

```lean
theorem poly_num_17 : (17 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_18`

```lean
theorem poly_num_18 : (18 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_19`

```lean
theorem poly_num_19 : (19 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_20`

```lean
theorem poly_num_20 : (20 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_21`

```lean
theorem poly_num_21 : (21 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_22`

```lean
theorem poly_num_22 : (22 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_23`

```lean
theorem poly_num_23 : (23 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_24`

```lean
theorem poly_num_24 : (24 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_25`

```lean
theorem poly_num_25 : (25 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_26`

```lean
theorem poly_num_26 : (26 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_27`

```lean
theorem poly_num_27 : (27 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_28`

```lean
theorem poly_num_28 : (28 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_29`

```lean
theorem poly_num_29 : (29 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_30`

```lean
theorem poly_num_30 : (30 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_31`

```lean
theorem poly_num_31 : (31 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_32`

```lean
theorem poly_num_32 : (32 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_33`

```lean
theorem poly_num_33 : (33 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_34`

```lean
theorem poly_num_34 : (34 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_35`

```lean
theorem poly_num_35 : (35 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_36`

```lean
theorem poly_num_36 : (36 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_37`

```lean
theorem poly_num_37 : (37 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_38`

```lean
theorem poly_num_38 : (38 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_39`

```lean
theorem poly_num_39 : (39 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_40`

```lean
theorem poly_num_40 : (40 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_41`

```lean
theorem poly_num_41 : (41 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_42`

```lean
theorem poly_num_42 : (42 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_43`

```lean
theorem poly_num_43 : (43 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_44`

```lean
theorem poly_num_44 : (44 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_45`

```lean
theorem poly_num_45 : (45 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_46`

```lean
theorem poly_num_46 : (46 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_47`

```lean
theorem poly_num_47 : (47 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_48`

```lean
theorem poly_num_48 : (48 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_49`

```lean
theorem poly_num_49 : (49 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_50`

```lean
theorem poly_num_50 : (50 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_51`

```lean
theorem poly_num_51 : (51 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_52`

```lean
theorem poly_num_52 : (52 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_53`

```lean
theorem poly_num_53 : (53 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_54`

```lean
theorem poly_num_54 : (54 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_55`

```lean
theorem poly_num_55 : (55 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_56`

```lean
theorem poly_num_56 : (56 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_57`

```lean
theorem poly_num_57 : (57 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_58`

```lean
theorem poly_num_58 : (58 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_59`

```lean
theorem poly_num_59 : (59 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_60`

```lean
theorem poly_num_60 : (60 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_61`

```lean
theorem poly_num_61 : (61 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_62`

```lean
theorem poly_num_62 : (62 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash.poly_num_63`

```lean
theorem poly_num_63 : (63 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash.poly_num_64`

```lean
theorem poly_num_64 : (64 : BitsPolynomial) = 0
```

## [ModulusSteps0.lean](ProvenHashes/ModulusSteps0.lean)

`ProvenHashes.ChainHash.residue_step_0`

```lean
theorem residue_step_0 : residue_0 ^ 2 = residue_1 + modulus * (sparse [])
```

`ProvenHashes.ChainHash.residue_step_1`

```lean
theorem residue_step_1 : residue_1 ^ 2 = residue_2 + modulus * (sparse [])
```

`ProvenHashes.ChainHash.residue_step_2`

```lean
theorem residue_step_2 : residue_2 ^ 2 = residue_3 + modulus * (sparse [])
```

`ProvenHashes.ChainHash.residue_step_3`

```lean
theorem residue_step_3 : residue_3 ^ 2 = residue_4 + modulus * (sparse [])
```

`ProvenHashes.ChainHash.residue_step_4`

```lean
theorem residue_step_4 : residue_4 ^ 2 = residue_5 + modulus * (sparse [])
```

`ProvenHashes.ChainHash.residue_step_5`

```lean
theorem residue_step_5 : residue_5 ^ 2 = residue_6 + modulus * (sparse [0])
```

`ProvenHashes.ChainHash.residue_step_6`

```lean
theorem residue_step_6 : residue_6 ^ 2 = residue_7 + modulus * (sparse [])
```

`ProvenHashes.ChainHash.residue_step_7`

```lean
theorem residue_step_7 : residue_7 ^ 2 = residue_8 + modulus * (sparse [])
```

## [ModulusSteps1.lean](ProvenHashes/ModulusSteps1.lean)

`ProvenHashes.ChainHash.residue_step_8`

```lean
theorem residue_step_8 : residue_8 ^ 2 = residue_9 + modulus * (sparse [])
```

`ProvenHashes.ChainHash.residue_step_9`

```lean
theorem residue_step_9 : residue_9 ^ 2 = residue_10 + modulus * (sparse [0])
```

`ProvenHashes.ChainHash.residue_step_10`

```lean
theorem residue_step_10 : residue_10 ^ 2 = residue_11 + modulus * (sparse [32])
```

`ProvenHashes.ChainHash.residue_step_11`

```lean
theorem residue_step_11 : residue_11 ^ 2 = residue_12 + modulus * (sparse [2, 6, 8])
```

`ProvenHashes.ChainHash.residue_step_12`

```lean
theorem residue_step_12 : residue_12 ^ 2 = residue_13 + modulus * (sparse [])
```

`ProvenHashes.ChainHash.residue_step_13`

```lean
theorem residue_step_13 : residue_13 ^ 2 = residue_14 + modulus * (sparse [0])
```

`ProvenHashes.ChainHash.residue_step_14`

```lean
theorem residue_step_14 : residue_14 ^ 2 = residue_15 + modulus * (sparse [0, 16, 24])
```

`ProvenHashes.ChainHash.residue_step_15`

```lean
theorem residue_step_15 : residue_15 ^ 2 = residue_16 + modulus * (sparse [0, 16, 48])
```

## [ModulusSteps2.lean](ProvenHashes/ModulusSteps2.lean)

`ProvenHashes.ChainHash.residue_step_16`

```lean
theorem residue_step_16 : residue_16 ^ 2 = residue_17 + modulus * (sparse [4, 12, 16, 32, 34, 36, 38, 40, 44, 48])
```

`ProvenHashes.ChainHash.residue_step_17`

```lean
theorem residue_step_17 : residue_17 ^ 2 = residue_18 + modulus * (sparse [0, 2, 12, 16, 20, 22, 26, 30, 34, 38, 40])
```

`ProvenHashes.ChainHash.residue_step_18`

```lean
theorem residue_step_18 : residue_18 ^ 2 = residue_19 + modulus * (sparse [0, 2, 4, 6, 10, 12, 14, 20, 22, 24, 32])
```

`ProvenHashes.ChainHash.residue_step_19`

```lean
theorem residue_step_19 : residue_19 ^ 2 = residue_20 + modulus * (sparse [0, 2, 4, 6, 8, 12, 20, 24, 32, 36, 40, 44, 52, 56, 60])
```

`ProvenHashes.ChainHash.residue_step_20`

```lean
theorem residue_step_20 : residue_20 ^ 2 = residue_21 + modulus * (sparse [1, 4, 6, 8, 10, 14, 18, 20, 22, 24, 26, 30, 32, 40, 42, 44, 46, 50, 54, 56, 58, 62])
```

`ProvenHashes.ChainHash.residue_step_21`

```lean
theorem residue_step_21 : residue_21 ^ 2 = residue_22 + modulus * (sparse [0, 1, 2, 4, 6, 16, 18, 24, 28, 32, 34, 36, 38, 42, 44, 46, 56, 58, 62])
```

`ProvenHashes.ChainHash.residue_step_22`

```lean
theorem residue_step_22 : residue_22 ^ 2 = residue_23 + modulus * (sparse [1, 12, 16, 18, 22, 32, 34, 36, 40, 50, 58, 60, 62])
```

`ProvenHashes.ChainHash.residue_step_23`

```lean
theorem residue_step_23 : residue_23 ^ 2 = residue_24 + modulus * (sparse [0, 2, 8, 12, 14, 16, 18, 20, 22, 38, 40, 42, 54, 60])
```

## [ModulusSteps3.lean](ProvenHashes/ModulusSteps3.lean)

`ProvenHashes.ChainHash.residue_step_24`

```lean
theorem residue_step_24 : residue_24 ^ 2 = residue_25 + modulus * (sparse [0, 1, 2, 4, 12, 14, 16, 20, 24, 26, 32, 36, 40, 44, 46, 50, 52, 56, 58, 62])
```

`ProvenHashes.ChainHash.residue_step_25`

```lean
theorem residue_step_25 : residue_25 ^ 2 = residue_26 + modulus * (sparse [1, 6, 10, 14, 16, 18, 22, 26, 28, 32, 34, 36, 38, 40, 44, 46, 50, 52, 58, 62])
```

`ProvenHashes.ChainHash.residue_step_26`

```lean
theorem residue_step_26 : residue_26 ^ 2 = residue_27 + modulus * (sparse [0, 1, 4, 12, 16, 22, 24, 26, 32, 34, 36, 38, 40, 44, 46, 48, 54, 56, 58, 62])
```

`ProvenHashes.ChainHash.residue_step_27`

```lean
theorem residue_step_27 : residue_27 ^ 2 = residue_28 + modulus * (sparse [1, 4, 22, 26, 38, 46, 48, 58, 60, 62])
```

`ProvenHashes.ChainHash.residue_step_28`

```lean
theorem residue_step_28 : residue_28 ^ 2 = residue_29 + modulus * (sparse [0, 4, 8, 14, 18, 20, 30, 32, 36, 38, 54, 56])
```

`ProvenHashes.ChainHash.residue_step_29`

```lean
theorem residue_step_29 : residue_29 ^ 2 = residue_30 + modulus * (sparse [4, 6, 10, 12, 18, 20, 24, 28, 36, 40, 46, 54, 56])
```

`ProvenHashes.ChainHash.residue_step_30`

```lean
theorem residue_step_30 : residue_30 ^ 2 = residue_31 + modulus * (sparse [0, 4, 8, 10, 12, 14, 16, 18, 22, 30, 32, 34, 36, 44, 46, 52, 54, 60])
```

`ProvenHashes.ChainHash.residue_step_31`

```lean
theorem residue_step_31 : residue_31 ^ 2 = residue_32 + modulus * (sparse [0, 1, 2, 14, 24, 26, 32, 34, 40, 42, 48, 50, 58, 60, 62])
```

## [ModulusSteps4.lean](ProvenHashes/ModulusSteps4.lean)

`ProvenHashes.ChainHash.residue_step_32`

```lean
theorem residue_step_32 : residue_32 ^ 2 = residue_33 + modulus * (sparse [2, 4, 10, 12, 16, 18, 26, 34, 42, 44, 52, 54, 56, 60])
```

`ProvenHashes.ChainHash.residue_step_33`

```lean
theorem residue_step_33 : residue_33 ^ 2 = residue_34 + modulus * (sparse [1, 2, 6, 10, 12, 20, 22, 24, 28, 30, 36, 42, 44, 48, 54, 56, 58, 62])
```

`ProvenHashes.ChainHash.residue_step_34`

```lean
theorem residue_step_34 : residue_34 ^ 2 = residue_35 + modulus * (sparse [1, 10, 14, 16, 22, 28, 30, 34, 38, 46, 48, 52, 56, 58, 62])
```

`ProvenHashes.ChainHash.residue_step_35`

```lean
theorem residue_step_35 : residue_35 ^ 2 = residue_36 + modulus * (sparse [0, 1, 6, 10, 14, 18, 28, 30, 36, 38, 40, 42, 44, 46, 48, 50, 56, 58, 62])
```

`ProvenHashes.ChainHash.residue_step_36`

```lean
theorem residue_step_36 : residue_36 ^ 2 = residue_37 + modulus * (sparse [1, 4, 8, 10, 16, 28, 36, 42, 44, 50, 56, 58, 62])
```

`ProvenHashes.ChainHash.residue_step_37`

```lean
theorem residue_step_37 : residue_37 ^ 2 = residue_38 + modulus * (sparse [0, 1, 2, 4, 8, 10, 12, 14, 22, 24, 28, 30, 36, 38, 40, 42, 44, 48, 50, 56, 58, 62])
```

`ProvenHashes.ChainHash.residue_step_38`

```lean
theorem residue_step_38 : residue_38 ^ 2 = residue_39 + modulus * (sparse [1, 10, 24, 28, 30, 32, 34, 36, 42, 44, 50, 58, 60, 62])
```

`ProvenHashes.ChainHash.residue_step_39`

```lean
theorem residue_step_39 : residue_39 ^ 2 = residue_40 + modulus * (sparse [0, 4, 12, 14, 16, 20, 22, 30, 36, 38, 42, 54])
```

## [ModulusSteps5.lean](ProvenHashes/ModulusSteps5.lean)

`ProvenHashes.ChainHash.residue_step_40`

```lean
theorem residue_step_40 : residue_40 ^ 2 = residue_41 + modulus * (sparse [2, 4, 10, 12, 18, 22, 26, 28, 36, 46, 48, 50, 56])
```

`ProvenHashes.ChainHash.residue_step_41`

```lean
theorem residue_step_41 : residue_41 ^ 2 = residue_42 + modulus * (sparse [10, 12, 14, 16, 20, 28, 30, 32, 36, 40, 42, 44, 48, 50, 54, 60])
```

`ProvenHashes.ChainHash.residue_step_42`

```lean
theorem residue_step_42 : residue_42 ^ 2 = residue_43 + modulus * (sparse [0, 1, 2, 4, 6, 8, 10, 12, 14, 16, 18, 30, 32, 34, 42, 44, 46, 50, 52, 58, 60, 62])
```

`ProvenHashes.ChainHash.residue_step_43`

```lean
theorem residue_step_43 : residue_43 ^ 2 = residue_44 + modulus * (sparse [0, 10, 22, 28, 32, 34, 38, 40, 44, 46, 54, 56])
```

`ProvenHashes.ChainHash.residue_step_44`

```lean
theorem residue_step_44 : residue_44 ^ 2 = residue_45 + modulus * (sparse [0, 2, 4, 8, 10, 14, 16, 22, 26, 28, 34, 36, 44, 46, 52, 54, 60])
```

`ProvenHashes.ChainHash.residue_step_45`

```lean
theorem residue_step_45 : residue_45 ^ 2 = residue_46 + modulus * (sparse [1, 2, 4, 6, 8, 12, 14, 16, 26, 34, 42, 44, 50, 56, 58, 60, 62])
```

`ProvenHashes.ChainHash.residue_step_46`

```lean
theorem residue_step_46 : residue_46 ^ 2 = residue_47 + modulus * (sparse [0, 4, 6, 8, 10, 16, 20, 22, 24, 30, 32, 38, 40, 42, 48, 50, 52, 56, 60])
```

`ProvenHashes.ChainHash.residue_step_47`

```lean
theorem residue_step_47 : residue_47 ^ 2 = residue_48 + modulus * (sparse [1, 2, 4, 6, 8, 14, 16, 24, 26, 28, 34, 36, 46, 50, 52, 54, 58, 62])
```

## [ModulusSteps6.lean](ProvenHashes/ModulusSteps6.lean)

`ProvenHashes.ChainHash.residue_step_48`

```lean
theorem residue_step_48 : residue_48 ^ 2 = residue_49 + modulus * (sparse [0, 1, 2, 6, 8, 14, 20, 28, 30, 34, 38, 40, 44, 50, 54, 56, 58, 60, 62])
```

`ProvenHashes.ChainHash.residue_step_49`

```lean
theorem residue_step_49 : residue_49 ^ 2 = residue_50 + modulus * (sparse [0, 2, 6, 8, 10, 12, 14, 16, 20, 22, 26, 30, 32, 38, 42, 46, 56, 60])
```

`ProvenHashes.ChainHash.residue_step_50`

```lean
theorem residue_step_50 : residue_50 ^ 2 = residue_51 + modulus * (sparse [1, 2, 6, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 34, 36, 48, 50, 52, 54, 58, 62])
```

`ProvenHashes.ChainHash.residue_step_51`

```lean
theorem residue_step_51 : residue_51 ^ 2 = residue_52 + modulus * (sparse [1, 6, 14, 16, 20, 34, 44, 50, 52, 54, 56, 58, 60, 62])
```

`ProvenHashes.ChainHash.residue_step_52`

```lean
theorem residue_step_52 : residue_52 ^ 2 = residue_53 + modulus * (sparse [4, 6, 10, 12, 24, 26, 30, 36, 38, 40, 48])
```

`ProvenHashes.ChainHash.residue_step_53`

```lean
theorem residue_step_53 : residue_53 ^ 2 = residue_54 + modulus * (sparse [0, 2, 4, 8, 10, 22, 24, 28, 32, 34, 38])
```

`ProvenHashes.ChainHash.residue_step_54`

```lean
theorem residue_step_54 : residue_54 ^ 2 = residue_55 + modulus * (sparse [2, 4, 10, 14, 16, 18, 20, 32, 36, 40, 48, 52, 56, 60])
```

`ProvenHashes.ChainHash.residue_step_55`

```lean
theorem residue_step_55 : residue_55 ^ 2 = residue_56 + modulus * (sparse [0, 1, 6, 8, 10, 14, 16, 18, 22, 24, 28, 32, 34, 38, 40, 42, 44, 46, 50, 52, 54, 56, 58, 60, 62])
```

## [ModulusSteps7.lean](ProvenHashes/ModulusSteps7.lean)

`ProvenHashes.ChainHash.residue_step_56`

```lean
theorem residue_step_56 : residue_56 ^ 2 = residue_57 + modulus * (sparse [2, 4, 10, 14, 16, 24, 28, 34, 38, 48])
```

`ProvenHashes.ChainHash.residue_step_57`

```lean
theorem residue_step_57 : residue_57 ^ 2 = residue_58 + modulus * (sparse [0, 4, 6, 10, 14, 18, 24, 28, 32, 34, 38, 40, 44, 48, 52, 56, 60])
```

`ProvenHashes.ChainHash.residue_step_58`

```lean
theorem residue_step_58 : residue_58 ^ 2 = residue_59 + modulus * (sparse [0, 1, 4, 10, 12, 14, 20, 22, 26, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 62])
```

`ProvenHashes.ChainHash.residue_step_59`

```lean
theorem residue_step_59 : residue_59 ^ 2 = residue_60 + modulus * (sparse [0, 4, 12, 20, 32, 36, 40, 44, 48, 52, 56, 60])
```

`ProvenHashes.ChainHash.residue_step_60`

```lean
theorem residue_step_60 : residue_60 ^ 2 = residue_61 + modulus * (sparse [1, 4, 6, 10, 14, 16, 18, 20, 22, 26, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 62])
```

`ProvenHashes.ChainHash.residue_step_61`

```lean
theorem residue_step_61 : residue_61 ^ 2 = residue_62 + modulus * (sparse [16, 20, 24, 28])
```

`ProvenHashes.ChainHash.residue_step_62`

```lean
theorem residue_step_62 : residue_62 ^ 2 = residue_63 + modulus * (sparse [0, 32, 36, 40, 44, 48, 52, 56, 60])
```

`ProvenHashes.ChainHash.residue_step_63`

```lean
theorem residue_step_63 : residue_63 ^ 2 = residue_64 + modulus * (sparse [1, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 62])
```

## [MultiplyShift.lean](ProvenHashes/MultiplyShift.lean)

`ProvenHashes.same_bucket_close`

```lean
lemma same_bucket_close {r s B : ℕ} (hB : 0 < B) (h : r / B = s / B) :
    r < s + B ∧ s < r + B
```

`ProvenHashes.multiplyShift_collision_close`

```lean
theorem multiplyShift_collision_close (w ℓ : ℕ) (a : OddMultiplier w)
    (x y : Fin (2 ^ w)) (h : multiplyShift w ℓ a x = multiplyShift w ℓ a y) :
    a.val.val * x.val % 2 ^ (2 * w) <
        a.val.val * y.val % 2 ^ (2 * w) + 2 ^ (2 * w - ℓ) ∧
    a.val.val * y.val % 2 ^ (2 * w) <
        a.val.val * x.val % 2 ^ (2 * w) + 2 ^ (2 * w - ℓ)
```

`ProvenHashes.odd_mul_mod_injective`

```lean
theorem odd_mul_mod_injective (N a : ℕ) (ha : Odd a) :
    Function.Injective (fun x : Fin (2 ^ N) => a * x.val % 2 ^ N)
```

## [NH.lean](ProvenHashes/NH.lean)

`ProvenHashes.affine_bijective`

```lean
lemma affine_bijective {F : Type*} [Field F] (a b : F) (ha : a ≠ 0) :
    Function.Bijective (fun v : F => a * v + b)
```

`ProvenHashes.sum_mul_update`

```lean
lemma sum_mul_update {I F : Type*} [Fintype I] [DecidableEq I] [CommRing F]
    (c k : I → F) (i : I) (v : F) :
    (∑ j, c j * Function.update k i v j) =
      c i * v + ∑ j ∈ Finset.univ.erase i, c j * k j
```

`ProvenHashes.affine_sum_uniform`

```lean
theorem affine_sum_uniform {I F : Type*} [Fintype I] [DecidableEq I] [Field F] [Fintype F]
    (c : I → F) (d : F) (hc : ∃ i, c i ≠ 0) (t : F) :
    uniformProb (fun k : I → F => d + ∑ i, c i * k i = t) =
      1 / Fintype.card F
```

`ProvenHashes.nh_difference`

```lean
lemma nh_difference {F : Type*} [CommRing F] {n : ℕ}
    (m m' k : Fin n × Bool → F) :
    nhHash m k - nhHash m' k =
      nhConstant m m' + ∑ j, nhCoefficient m m' j * k j
```

`ProvenHashes.nh_difference_uniform`

```lean
theorem nh_difference_uniform {F : Type*} [Field F] [Fintype F] {n : ℕ}
    (m m' : Fin n × Bool → F) (hne : m ≠ m') (t : F) :
    uniformProb (fun k : Fin n × Bool → F => nhHash m k - nhHash m' k = t) =
      1 / Fintype.card F
```

`ProvenHashes.nh_collision_bound`

```lean
theorem nh_collision_bound {F : Type*} [Field F] [Fintype F] {n : ℕ}
    (m m' : Fin n × Bool → F) (hne : m ≠ m') :
    uniformProb (fun k : Fin n × Bool → F => nhHash m k = nhHash m' k) ≤
      1 / Fintype.card F
```

## [OpusFinalizer.lean](ProvenHashes/OpusFinalizer.lean)

`ProvenHashes.OpusFinalizer.chain5_eq`

```lean
theorem chain5_eq (c : Fin 5 → F) (v : F) :
    chain5 c v = v ^ 5 + coeffMap c 4 * v ^ 4 + coeffMap c 3 * v ^ 3
      + coeffMap c 2 * v ^ 2 + coeffMap c 1 * v + coeffMap c 0
```

`ProvenHashes.OpusFinalizer.coeffDecode_coeffMap`

```lean
theorem coeffDecode_coeffMap (c : Fin 5 → F) : coeffDecode (coeffMap c) = c
```

`ProvenHashes.OpusFinalizer.coeffMap_coeffDecode`

```lean
theorem coeffMap_coeffDecode (e : Fin 5 → F) : coeffMap (coeffDecode e) = e
```

`ProvenHashes.OpusFinalizer.coeffMap_bijective`

```lean
theorem coeffMap_bijective :
    Function.Bijective (coeffMap : (Fin 5 → F) → (Fin 5 → F))
```

`ProvenHashes.OpusFinalizer.eval_chainPoly`

```lean
theorem eval_chainPoly (c : Fin 5 → F) (v : F) :
    (chainPoly c).eval v = chain5 c v
```

`ProvenHashes.OpusFinalizer.chainPoly_eq`

```lean
theorem chainPoly_eq (c : Fin 5 → F) :
    chainPoly c = X ^ 5 + C (coeffMap c 4) * X ^ 4 + C (coeffMap c 3) * X ^ 3
      + C (coeffMap c 2) * X ^ 2 + C (coeffMap c 1) * X + C (coeffMap c 0)
```

`ProvenHashes.OpusFinalizer.chainPoly_monic`

```lean
theorem chainPoly_monic [Nontrivial F] (c : Fin 5 → F) : (chainPoly c).Monic
```

`ProvenHashes.OpusFinalizer.chainPoly_natDegree`

```lean
theorem chainPoly_natDegree [Nontrivial F] (c : Fin 5 → F) :
    (chainPoly c).natDegree = 5
```

`ProvenHashes.OpusFinalizer.chainPoly_eq_sum`

```lean
theorem chainPoly_eq_sum (c : Fin 5 → F) :
    chainPoly c = X ^ 5 + ∑ i : Fin 5, C (coeffMap c i) * X ^ (i : ℕ)
```

`ProvenHashes.OpusFinalizer.chainPoly_coeff`

```lean
theorem chainPoly_coeff (c : Fin 5 → F) (i : Fin 5) :
    (chainPoly c).coeff (i : ℕ) = coeffMap c i
```

`ProvenHashes.OpusFinalizer.chainPoly_coeff_bijective`

```lean
theorem chainPoly_coeff_bijective :
    Function.Bijective (fun (c : Fin 5 → F) (i : Fin 5) => (chainPoly c).coeff (i : ℕ))
```

`ProvenHashes.OpusFinalizer.chain5_update_three`

```lean
theorem chain5_update_three (k : Fin 5 → F) (x v : F) :
    chain5 (Function.update k 3 x) v
      = (v + k 2) * ((v * v + k 0) * (v + v * v + k 1) + x) + k 4
```

`ProvenHashes.OpusFinalizer.chain5_collision_exact`

```lean
theorem chain5_collision_exact [Fintype F] {v v' : F} (h : v ≠ v') :
    uniformProb (fun c : Fin 5 → F => chain5 c v = chain5 c v') = 1 / Fintype.card F
```

`ProvenHashes.OpusFinalizer.twist_apply`

```lean
theorem twist_apply {N : ℕ} (enc : F ≃ ZMod N) (τ : ZMod N) (v : F) :
    twist enc τ v = enc.symm (enc v + τ)
```

`ProvenHashes.OpusFinalizer.chain5_collision_twisted`

```lean
theorem chain5_collision_twisted [Fintype F] (ψ : F → F) (hψ : Function.Injective ψ)
    {v v' : F} (h : v ≠ v') :
    uniformProb (fun c : Fin 5 → F => chain5 c (ψ v) = chain5 c (ψ v'))
      = 1 / Fintype.card F
```

`ProvenHashes.OpusFinalizer.finalizer_stage_bound`

```lean
theorem finalizer_stage_bound [Fintype F] (ψ : F → F) (hψ : Function.Injective ψ)
    (v v' : F) (h : v ≠ v') :
    uniformProb (fun c : Fin 5 → F => finalizer ψ c v = finalizer ψ c v')
      ≤ 1 / Fintype.card F
```

`ProvenHashes.OpusFinalizer.chainhash_equal_length_finalized`

```lean
theorem chainhash_equal_length_finalized {K : Type*} [Fintype F] [Fintype K] [Nonempty K]
    (p : ℕ) (s s' : K → List (F × F)) (ψ : F → F) (hψ : Function.Injective ψ)
    (hlen : ∀ k, (s k).length = (s' k).length)
    (hmax : ∀ k, (s k).length ≤ p)
    (hstream : uniformProb (fun k => s k = s' k) ≤ 1 / Fintype.card F) :
    uniformProb (fun k : (K × (Fin 3 → F)) × (Fin 5 → F) =>
        finalizer ψ k.2 (Recurrence.hash (s k.1.1) k.1.2) =
          finalizer ψ k.2 (Recurrence.hash (s' k.1.1) k.1.2)) ≤
      ((p + 2 : ℕ) : ℚ≥0) / Fintype.card F
```

`ProvenHashes.OpusFinalizer.chainhash_different_lengths_finalized`

```lean
theorem chainhash_different_lengths_finalized {K : Type*} [Fintype F] [Fintype K] [Nonempty K]
    (p : ℕ) (s s' : K → List (F × F)) (ψ : F → F) (hψ : Function.Injective ψ)
    (hlen : ∀ k, (s k).length ≠ (s' k).length)
    (hmax : ∀ k, max (s k).length (s' k).length ≤ p) :
    uniformProb (fun k : (K × (Fin 3 → F)) × (Fin 5 → F) =>
        finalizer ψ k.2 (Recurrence.hash (s k.1.1) k.1.2) =
          finalizer ψ k.2 (Recurrence.hash (s' k.1.1) k.1.2)) ≤
      ((p + 2 : ℕ) : ℚ≥0) / Fintype.card F
```

`ProvenHashes.OpusFinalizer.chain5_collision_gf64`

```lean
theorem chain5_collision_gf64 (ψ : GaloisField 2 64 → GaloisField 2 64)
    (hψ : Function.Injective ψ) {v v' : GaloisField 2 64} (h : v ≠ v') :
    uniformProb (fun c : Fin 5 → GaloisField 2 64 =>
      chain5 c (ψ v) = chain5 c (ψ v')) = 1 / 2 ^ 64
```

`ProvenHashes.OpusFinalizer.twist_gf64_bijective`

```lean
theorem twist_gf64_bijective (enc : GaloisField 2 64 ≃ ZMod (2 ^ 64)) (τ : ZMod (2 ^ 64)) :
    Function.Bijective (twist enc τ)
```

`ProvenHashes.OpusFinalizer.chain5_eq_sum`

```lean
theorem chain5_eq_sum (c : Fin 5 → F) (v : F) :
    chain5 c v = v ^ 5 + ∑ i : Fin 5, coeffMap c i * v ^ (i : ℕ)
```

`ProvenHashes.OpusFinalizer.evalLower_apply`

```lean
theorem evalLower_apply {t : ℕ} (v : Fin t → F) (e : Fin 5 → F) (j : Fin t) :
    evalLower v e j = ∑ i : Fin 5, e i * v j ^ (i : ℕ)
```

`ProvenHashes.OpusFinalizer.evalLower_interpKey`

```lean
theorem evalLower_interpKey {t : ℕ} (ht : t ≤ 5) (v : Fin t → F)
    (hv : Function.Injective v) (w : Fin t → F) : evalLower v (interpKey v w) = w
```

`ProvenHashes.OpusFinalizer.uniformProb_of_linear_section`

```lean
theorem uniformProb_of_linear_section {A B : Type*}
    [AddCommGroup A] [Module F A] [AddCommGroup B] [Module F B]
    [Fintype A] [Fintype B] [Nonempty B]
    (Φ : A →ₗ[F] B) (σ : B →ₗ[F] A) (hσ : ∀ b, Φ (σ b) = b) (w : B) :
    uniformProb (fun a => Φ a = w) = 1 / Fintype.card B
```

`ProvenHashes.OpusFinalizer.chain5_kwise_uniform`

```lean
theorem chain5_kwise_uniform [Fintype F] {t : ℕ} (ht : t ≤ 5) (v : Fin t → F)
    (hv : Function.Injective v) (w : Fin t → F) :
    uniformProb (fun c : Fin 5 → F => (fun j => chain5 c (v j)) = w)
      = 1 / (Fintype.card F : ℚ≥0) ^ t
```

`ProvenHashes.OpusFinalizer.chain5_kwise_uniform_twisted`

```lean
theorem chain5_kwise_uniform_twisted [Fintype F] (ψ : F → F) (hψ : Function.Injective ψ)
    {t : ℕ} (ht : t ≤ 5) (v : Fin t → F) (hv : Function.Injective v) (w : Fin t → F) :
    uniformProb (fun c : Fin 5 → F => (fun j => finalizer ψ c (v j)) = w)
      = 1 / (Fintype.card F : ℚ≥0) ^ t
```

`ProvenHashes.OpusFinalizer.chain5_kwise_uniform_gf64`

```lean
theorem chain5_kwise_uniform_gf64 (ψ : GaloisField 2 64 → GaloisField 2 64)
    (hψ : Function.Injective ψ) {t : ℕ} (ht : t ≤ 5) (v : Fin t → GaloisField 2 64)
    (hv : Function.Injective v) (w : Fin t → GaloisField 2 64) :
    uniformProb (fun c : Fin 5 → GaloisField 2 64 =>
        (fun j => chain5 c (ψ (v j))) = w) = 1 / (2 ^ 64 : ℚ≥0) ^ t
```

`ProvenHashes.OpusFinalizer.exists_word_encoding_gf64`

```lean
theorem exists_word_encoding_gf64 : Nonempty (GaloisField 2 64 ≃ ZMod (2 ^ 64))
```

## [PiecesByteEncoding.lean](ProvenHashes/PiecesByteEncoding.lean)

`ProvenHashes.ChainEncoding.bits_injective`

```lean
theorem bits_injective (w : ℕ) : Function.Injective (@bits w)
```

`ProvenHashes.ChainEncoding.lengthWord_injective_below`

```lean
theorem lengthWord_injective_below {n m : ℕ}
    (hn : n < 2 ^ 64) (hm : m < 2 ^ 64) (h : lengthWord n = lengthWord m) : n = m
```

`ProvenHashes.ChainEncoding.readWord_byte`

```lean
theorem readWord_byte (m : Bytes) (j : ℕ) (t b : Fin 8) :
    readWord m j ⟨8 * t.val + b.val, by omega⟩ =
      m.getD (8 * j + t.val) 0 b
```

`ProvenHashes.ChainEncoding.readWords_injective`

```lean
theorem readWords_injective (m m' : Bytes) (hlen : m.length = m'.length)
    (hwords : ∀ j, readWord m j = readWord m' j) : m = m'
```

`ProvenHashes.ChainEncoding.blockCount_pos`

```lean
theorem blockCount_pos (n : ℕ) : 0 < blockCount n
```

`ProvenHashes.ChainEncoding.pairCount_le`

```lean
theorem pairCount_le (n t : ℕ) : pairCount n t ≤ 16
```

`ProvenHashes.ChainEncoding.pairCount_even`

```lean
theorem pairCount_even (n t : ℕ) : Even (pairCount n t)
```

`ProvenHashes.ChainEncoding.blockCount_covers`

```lean
theorem blockCount_covers (n : ℕ) : n ≤ 256 * blockCount n
```

`ProvenHashes.ChainEncoding.blockCount_bound`

```lean
theorem blockCount_bound {n L : ℕ} (hn : n ≤ 8 * L) :
    blockCount n ≤ max 1 ((L + 31) / 32)
```

## [PiecesConcreteChainHash.lean](ProvenHashes/PiecesConcreteChainHash.lean)

`ProvenHashes.ConcreteChainHash.key_card`

```lean
theorem key_card : Fintype.card Key = 2 ^ (64 * 41)
```

`ProvenHashes.ConcreteChainHash.collision_bound`

```lean
theorem collision_bound (L : ℕ) (hL : 8 * L + 255 < 2 ^ 64)
    (m m' : ByteString) (hm : m.length ≤ 8 * L) (hm' : m'.length ≤ 8 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key => hash k m = hash k m') ≤
      ((max 1 ((L + 31) / 32) + 2 : ℕ) : ℚ≥0) / (2 : ℚ≥0) ^ 64
```

## [PiecesFinalizer.lean](ProvenHashes/PiecesFinalizer.lean)

`ProvenHashes.Finalizer.decode_coefficients`

```lean
theorem decode_coefficients {F : Type*} [CommRing F] (c : Fin 5 → F) :
    decode (coefficients c) = c
```

`ProvenHashes.Finalizer.coefficients_decode`

```lean
theorem coefficients_decode {F : Type*} [CommRing F] (e : Fin 5 → F) :
    coefficients (decode e) = e
```

`ProvenHashes.Finalizer.circuit_eq_monicEval`

```lean
theorem circuit_eq_monicEval {F : Type*} [CommRing F] (c : Fin 5 → F) (v : F) :
    circuit c v = monicEval (coefficients c) v
```

`ProvenHashes.Finalizer.monicEval_difference`

```lean
lemma monicEval_difference {F : Type*} [CommRing F] (e : Fin 5 → F) (v w : F) :
    monicEval e v - monicEval e w =
      (v ^ 5 - w ^ 5) + ∑ i, (v ^ i.val - w ^ i.val) * e i
```

`ProvenHashes.Finalizer.difference_uniform`

```lean
theorem difference_uniform {F : Type*} [Field F] [Fintype F]
    (v w : F) (hvw : v ≠ w) (t : F) :
    uniformProb (fun c : Fin 5 → F => circuit c v - circuit c w = t) =
      1 / Fintype.card F
```

`ProvenHashes.Finalizer.collision_exact`

```lean
theorem collision_exact {F : Type*} [Field F] [Fintype F]
    (v w : F) (hvw : v ≠ w) :
    uniformProb (fun c : Fin 5 → F => circuit c v = circuit c w) =
      1 / Fintype.card F
```

`ProvenHashes.Finalizer.twist_bijective`

```lean
theorem twist_bijective {F : Type*} (word : F ≃ ZMod (2 ^ 64)) (τ : ZMod (2 ^ 64)) :
    Function.Bijective (twist word τ)
```

`ProvenHashes.Finalizer.twisted_collision_exact`

```lean
theorem twisted_collision_exact {F : Type*} [Field F] [Fintype F]
    (word : F ≃ ZMod (2 ^ 64)) (τ : ZMod (2 ^ 64)) (v w : F) (hvw : v ≠ w) :
    uniformProb (fun c : Fin 5 → F => circuit c (twist word τ v) =
      circuit c (twist word τ w)) = 1 / Fintype.card F
```

`ProvenHashes.Finalizer.keyed_twisted_collision_exact`

```lean
theorem keyed_twisted_collision_exact {F : Type*} [Field F] [Fintype F]
    (word : F ≃ ZMod (2 ^ 64)) (v w : F) (hvw : v ≠ w) :
    uniformProb (fun k : ZMod (2 ^ 64) × (Fin 5 → F) =>
      circuit k.2 (twist word k.1 v) = circuit k.2 (twist word k.1 w)) =
      1 / Fintype.card F
```

## [PiecesStream.lean](ProvenHashes/PiecesStream.lean)

`ProvenHashes.ChainEncoding.stream_length`

```lean
theorem stream_length (m : Bytes) (k : BlockKey) : (stream m k).length = blockCount m.length
```

`ProvenHashes.ChainEncoding.streamPair_of_equal`

```lean
theorem streamPair_of_equal (m m' : Bytes) (k : BlockKey)
    (hlen : blockCount m.length = blockCount m'.length)
    (h : stream m k = stream m' k) (t : ℕ) (ht : t < blockCount m.length) :
    streamPair m t k = streamPair m' t k
```

`ProvenHashes.ChainEncoding.streams_ne_of_blockCount_ne`

```lean
theorem streams_ne_of_blockCount_ne (m m' : Bytes)
    (hn : blockCount m.length ≠ blockCount m'.length) (k : BlockKey) :
    stream m k ≠ stream m' k
```

`ProvenHashes.ChainEncoding.stream_equal_byte_length_bound`

```lean
theorem stream_equal_byte_length_bound (m m' : Bytes)
    (hlen : m.length = m'.length) (hne : m ≠ m') :
    uniformProb (fun k : BlockKey => stream m k = stream m' k) ≤ 1 / (2 : ℚ≥0) ^ 64
```

`ProvenHashes.ChainEncoding.blockValue_nonzero_target_bound`

```lean
theorem blockValue_nonzero_target_bound (m m' : Bytes) (t : ℕ)
    (C : (ZMod 2)[X]) (hC : C ≠ 0) :
    uniformProb (fun k => blockValue m t k + blockValue m' t k = C) ≤ 1 / (2 : ℚ≥0) ^ 64
```

`ProvenHashes.ChainEncoding.stream_different_byte_length_bound`

```lean
theorem stream_different_byte_length_bound (m m' : Bytes)
    (hn : m.length < 2 ^ 64) (hn' : m'.length < 2 ^ 64)
    (hlen : m.length ≠ m'.length)
    (hblocks : blockCount m.length = blockCount m'.length) :
    uniformProb (fun k : BlockKey => stream m k = stream m' k) ≤ 1 / (2 : ℚ≥0) ^ 64
```

`ProvenHashes.ChainEncoding.stream_collision_bound`

```lean
theorem stream_collision_bound (m m' : Bytes)
    (hn : m.length < 2 ^ 64) (hn' : m'.length < 2 ^ 64) (hne : m ≠ m') :
    uniformProb (fun k : BlockKey => stream m k = stream m' k) ≤ 1 / (2 : ℚ≥0) ^ 64
```

## [Polynomial.lean](ProvenHashes/Polynomial.lean)

`ProvenHashes.polynomialHash_eq_eval`

```lean
lemma polynomialHash_eq_eval [DecidableEq F] {n : ℕ} (m : Fin n → F) (x : F) :
    polynomialHash m x = (Polynomial.ofFn n m).eval x
```

`ProvenHashes.polynomial_zero_count`

```lean
theorem polynomial_zero_count [DecidableEq F] (p : F[X]) (hp : p ≠ 0) :
    (Finset.univ.filter fun x : F => p.eval x = 0).card ≤ p.natDegree
```

`ProvenHashes.polynomial_collision_bound`

```lean
theorem polynomial_collision_bound {n L : ℕ} (hnL : n ≤ L)
    (m m' : Fin n → F) (hne : m ≠ m') :
    uniformProb (fun x : F => polynomialHash m x = polynomialHash m' x) ≤
      ((L - 1 : ℕ) : ℚ≥0) / Fintype.card F
```

`ProvenHashes.polynomial_collision_zmod`

```lean
theorem polynomial_collision_zmod (p : ℕ) [Fact p.Prime]
    {n L : ℕ} (hnL : n ≤ L) (m m' : Fin n → ZMod p) (hne : m ≠ m') :
    uniformProb (fun x : ZMod p => polynomialHash m x = polynomialHash m' x) ≤
      ((L - 1 : ℕ) : ℚ≥0) / p
```

`ProvenHashes.gf64_card`

```lean
lemma gf64_card : Fintype.card (GaloisField 2 64) = 2 ^ 64
```

`ProvenHashes.polynomial_collision_gf64`

```lean
theorem polynomial_collision_gf64 {n L : ℕ} (hnL : n ≤ L)
    (m m' : Fin n → GaloisField 2 64) (hne : m ≠ m') :
    uniformProb (fun x : GaloisField 2 64 => polynomialHash m x = polynomialHash m' x) ≤
      ((L - 1 : ℕ) : ℚ≥0) / 2 ^ 64
```

## [Probability.lean](ProvenHashes/Probability.lean)

`ProvenHashes.uniformProb_equiv`

```lean
theorem uniformProb_equiv {K J : Type*} [Fintype K] [Fintype J]
    (e : K ≃ J) (event : J → Prop) :
    uniformProb (fun k => event (e k)) = uniformProb event
```

`ProvenHashes.uniformProb_fst`

```lean
lemma uniformProb_fst {A B : Type*} [Fintype A] [Fintype B]
    [Nonempty A] [Nonempty B] (t : A) :
    uniformProb (fun p : A × B => p.1 = t) = 1 / Fintype.card A
```

`ProvenHashes.uniformProb_of_bijective_slices`

```lean
lemma uniformProb_of_bijective_slices {A R : Type*}
    [Fintype A] [Fintype R] [Nonempty A] [Nonempty R]
    (f : A × R → A) (h : ∀ r, Function.Bijective (fun a => f (a, r))) (t : A) :
    uniformProb (fun k => f k = t) = 1 / Fintype.card A
```

`ProvenHashes.uniformProb_of_bijective_update`

```lean
theorem uniformProb_of_bijective_update {I V : Type*}
    [Fintype I] [Fintype V] [Nonempty V] [DecidableEq I]
    (f : (I → V) → V) (i : I)
    (h : ∀ k, Function.Bijective (fun v => f (Function.update k i v))) (t : V) :
    uniformProb (fun k => f k = t) = 1 / Fintype.card V
```

## [Recurrence.lean](ProvenHashes/Recurrence.lean)

`ProvenHashes.Recurrence.slice_lift`

```lean
lemma slice_lift (u z : F) (p : F[X]) : slice u z (liftY p) = p
```

`ProvenHashes.Recurrence.slice_X`

```lean
lemma slice_X (u z : F) (i : Fin 3) :
    slice u z (MvPolynomial.X i) = ![Polynomial.C u, Polynomial.X, Polynomial.C z] i
```

`ProvenHashes.Recurrence.extract_keyPolynomial`

```lean
lemma extract_keyPolynomial (m : List (F × F)) :
    extract (keyPolynomial m) = encode m
```

`ProvenHashes.Recurrence.decode_keyPolynomial`

```lean
theorem decode_keyPolynomial (m : List (F × F)) :
    decodePolynomial (keyPolynomial m) = m
```

`ProvenHashes.Recurrence.keyPolynomial_injective`

```lean
theorem keyPolynomial_injective : Function.Injective (keyPolynomial (F
```

`ProvenHashes.Recurrence.keyCoefficients_injective`

```lean
theorem keyCoefficients_injective :
    Function.Injective (fun m : List (F × F) =>
      fun d : Fin 3 →₀ ℕ => MvPolynomial.coeff d (keyPolynomial m))
```

`ProvenHashes.Recurrence.fold_expansion`

```lean
lemma fold_expansion (m : List (F × F)) (u y z : F) :
    m.foldl (fun p ab => ab.1 + (ab.2 + y) * (p + u)) z =
      (encode m).data.eval y + z * (encode m).seed.eval y + u * (encode m).shift.eval y
```

`ProvenHashes.Recurrence.eval_lift`

```lean
lemma eval_lift (k : Fin 3 → F) (p : F[X]) :
    MvPolynomial.eval k (liftY p) = p.eval (k 1)
```

`ProvenHashes.Recurrence.eval_keyPolynomial`

```lean
theorem eval_keyPolynomial (m : List (F × F)) (k : Fin 3 → F) :
    MvPolynomial.eval k (keyPolynomial m) = hash m k
```

`ProvenHashes.Recurrence.lift_degree`

```lean
lemma lift_degree (p : F[X]) : (liftY p).totalDegree ≤ p.natDegree
```

`ProvenHashes.Recurrence.component_difference_degrees`

```lean
lemma component_difference_degrees (m m' : List (F × F)) (hlen : m.length = m'.length) :
    ((encode m).data - (encode m').data).natDegree ≤ m.length - 1 ∧
    ((encode m).seed - (encode m').seed).natDegree ≤ m.length - 1 ∧
    ((encode m).shift - (encode m').shift).natDegree ≤ m.length - 1
```

`ProvenHashes.Recurrence.keyPolynomial_difference_degree`

```lean
theorem keyPolynomial_difference_degree (m m' : List (F × F))
    (hlen : m.length = m'.length) (hn : 0 < m.length) :
    (keyPolynomial m - keyPolynomial m').totalDegree ≤ m.length
```

`ProvenHashes.Recurrence.collision_bound`

```lean
theorem collision_bound [Fintype F] (m m' : List (F × F))
    (hlen : m.length = m'.length) (hne : m ≠ m') :
    uniformProb (fun k : Fin 3 → F => hash m k = hash m' k) ≤
      (m.length : ℚ≥0) / Fintype.card F
```

`ProvenHashes.Recurrence.collision_bound_gf64`

```lean
theorem collision_bound_gf64 (m m' : List (GaloisField 2 64 × GaloisField 2 64))
    (hlen : m.length = m'.length) (hne : m ≠ m') :
    uniformProb (fun k : Fin 3 → GaloisField 2 64 => hash m k = hash m' k) ≤
      (m.length : ℚ≥0) / 2 ^ 64
```

`ProvenHashes.Recurrence.keyPolynomial_degree`

```lean
lemma keyPolynomial_degree (m : List (F × F)) :
    (keyPolynomial m).totalDegree ≤ m.length + 1
```

`ProvenHashes.Recurrence.collision_bound_any_length`

```lean
theorem collision_bound_any_length [Fintype F] (m m' : List (F × F)) (hne : m ≠ m') :
    uniformProb (fun k : Fin 3 → F => hash m k = hash m' k) ≤
      ((max m.length m'.length + 1 : ℕ) : ℚ≥0) / Fintype.card F
```

## [ReferenceChainHash.lean](ProvenHashes/ReferenceChainHash.lean)

`ProvenHashes.ChainHash.wordStream_matches`

```lean
theorem wordStream_matches (m : Message) (k : BlockKey) :
    (wordStream m k).map (fun ab => (fieldRepr ab.1, fieldRepr ab.2)) = stream fieldRepr m k
```

`ProvenHashes.ChainHash.wordAdd_matches`

```lean
theorem wordAdd_matches (a b : Word 64) :
    fieldRepr (wordAdd a b) = integerTwist fieldIntegerEquiv (fieldRepr b) (fieldRepr a)
```

`ProvenHashes.ChainHash.referenceHash_matches`

```lean
theorem referenceHash_matches (k : Key41) (m : Message) : referenceHash k m = chainHash k m
```

`ProvenHashes.ChainHash.reference_collision_bound`

```lean
theorem reference_collision_bound (L : ℕ) (hL : 8 * L + 255 < 2 ^ 64)
    (m m' : Message) (hm : m.length ≤ 8 * L) (hm' : m'.length ≤ 8 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key41 => referenceHash k m = referenceHash k m') ≤
      ((max 1 ((L + 31) / 32) + 2 : ℕ) : ℚ≥0) / (2 : ℚ≥0) ^ 64
```

## [ReferenceOperations.lean](ProvenHashes/ReferenceOperations.lean)

`ProvenHashes.ChainHash.fieldRepr_wordMul`

```lean
theorem fieldRepr_wordMul (a b : Word 64) :
    fieldRepr (wordMul a b) = fieldRepr a * fieldRepr b
```

`ProvenHashes.ChainHash.wordChain5_matches`

```lean
theorem wordChain5_matches (c : Fin 5 → Word 64) (v : Word 64) :
    fieldRepr (wordChain5 c v) = chain5 (fun i => fieldRepr (c i)) (fieldRepr v)
```

`ProvenHashes.ChainHash.lowWord_add`

```lean
theorem lowWord_add (p q : BitsPolynomial) : lowWord (p + q) = lowWord p + lowWord q
```

`ProvenHashes.ChainHash.highWord_add`

```lean
theorem highWord_add (p q : BitsPolynomial) : highWord (p + q) = highWord p + highWord q
```

`ProvenHashes.ChainHash.lengthMask_low`

```lean
theorem lengthMask_low (n : ℕ) : lowWord (lengthMask n) = lengthWord n
```

`ProvenHashes.ChainHash.lengthMask_high`

```lean
theorem lengthMask_high (n : ℕ) : highWord (lengthMask n) = lengthWord n
```

`ProvenHashes.ChainHash.wordDigest_matches`

```lean
theorem wordDigest_matches (m : Message) (k : BlockKey) (t : ℕ) :
    (lowWord (rawDigest m k t), highWord (rawDigest m k t)) = wordDigest m k t
```

`ProvenHashes.ChainHash.wordFold_matches`

```lean
theorem wordFold_matches (u y : Word 64) (s : List (Word 64 × Word 64)) (p : Word 64) :
    fieldRepr (wordFold u y s p) =
      (s.map fun ab => (fieldRepr ab.1, fieldRepr ab.2)).foldl
        (fun p ab => ab.1 + (ab.2 + fieldRepr y) * (p + fieldRepr u)) (fieldRepr p)
```

## [SeededPH.lean](ProvenHashes/SeededPH.lean)

`ProvenHashes.ChainHash.ModelA.eval_phPoly`

```lean
theorem eval_phPoly {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m : Slot → F) (s : F) : (phPoly a m).eval s = ph a m s
```

`ProvenHashes.ChainHash.ModelA.partnerExponent_injective`

```lean
theorem partnerExponent_injective : Function.Injective (fun j => exponent (partner j))
```

`ProvenHashes.ChainHash.ModelA.phPoly_difference`

```lean
theorem phPoly_difference {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m m' : Slot → F) (t : F) :
    phPoly a m - phPoly a m' - C t = differencePoly a m m' t
```

## [Stream.lean](ProvenHashes/Stream.lean)

`ProvenHashes.ChainHash.lengthMask_injective`

```lean
theorem lengthMask_injective {n n' : ℕ} (hn : n < 2 ^ 64) (hn' : n' < 2 ^ 64)
    (h : lengthMask n = lengthMask n') : n = n'
```

`ProvenHashes.ChainHash.rawStream_length`

```lean
theorem rawStream_length (m : Message) (k : BlockKey) :
    (rawStream m k).length = blockCount m
```

`ProvenHashes.ChainHash.rawStream_eq_digest`

```lean
theorem rawStream_eq_digest (m m' : Message) (k : BlockKey)
    (h : rawStream m k = rawStream m' k) (t : ℕ)
    (ht : t < blockCount m) (ht' : t < blockCount m') :
    rawDigest m k t = rawDigest m' k t
```

`ProvenHashes.ChainHash.rawStream_different_counts`

```lean
theorem rawStream_different_counts (m m' : Message) (k : BlockKey)
    (h : blockCount m ≠ blockCount m') : rawStream m k ≠ rawStream m' k
```

`ProvenHashes.ChainHash.rawStream_equal_length_bound`

```lean
theorem rawStream_equal_length_bound (m m' : Message)
    (hlen : m.length = m'.length) (hne : m ≠ m') :
    uniformProb (fun k => rawStream m k = rawStream m' k) ≤ 1 / (2 : ℚ≥0) ^ 64
```

`ProvenHashes.ChainHash.rawStream_different_length_bound`

```lean
theorem rawStream_different_length_bound (m m' : Message)
    (hm : m.length < 2 ^ 64) (hm' : m'.length < 2 ^ 64)
    (hlen : m.length ≠ m'.length) (hc : blockCount m = blockCount m') :
    uniformProb (fun k => rawStream m k = rawStream m' k) ≤ 1 / (2 : ℚ≥0) ^ 64
```

`ProvenHashes.ChainHash.rawStream_collision_bound`

```lean
theorem rawStream_collision_bound (m m' : Message)
    (hm : m.length < 2 ^ 64) (hm' : m'.length < 2 ^ 64) (hne : m ≠ m') :
    uniformProb (fun k => rawStream m k = rawStream m' k) ≤ 1 / (2 : ℚ≥0) ^ 64
```

## [Subblocks.lean](ProvenHashes/Subblocks.lean)

`ProvenHashes.ChainEncoding.readWord_at_byte`

```lean
lemma readWord_at_byte (m : Bytes) (i : ℕ) (b : Fin 8) :
    readWord m (i / 8) ⟨8 * (i % 8) + b.val, by have
```

`ProvenHashes.ChainEncoding.byte_block_lt`

```lean
lemma byte_block_lt {n i : ℕ} (hi : i < n) : i / 256 < blockCount n
```

`ProvenHashes.ChainEncoding.byte_pair_active`

```lean
lemma byte_pair_active {n i : ℕ} (hi : i < n) :
    (stridedPosition.symm ⟨(i % 256) / 8, by omega⟩).1.val < pairCount n (i / 256)
```

`ProvenHashes.ChainEncoding.subblocks_injective`

```lean
theorem subblocks_injective (m m' : Bytes) (hlen : m.length = m'.length)
    (hblocks : ∀ t < blockCount m.length, ∀ j : Fin 16 × Bool,
      j.1.val < pairCount m.length t → subblock m t j = subblock m' t j) : m = m'
```

`ProvenHashes.ChainEncoding.exists_different_active_word`

```lean
theorem exists_different_active_word (m m' : Bytes) (hlen : m.length = m'.length)
    (hne : m ≠ m') :
    ∃ t, t < blockCount m.length ∧ ∃ i : Fin 16,
      i.val < pairCount m.length t ∧ ∃ b,
        subblock m t (i, b) ≠ subblock m' t (i, b)
```

## [Tabulation.lean](ProvenHashes/Tabulation.lean)

`ProvenHashes.tabulation_difference_uniform`

```lean
theorem tabulation_difference_uniform {I A G : Type*}
    [Fintype I] [Fintype A] [DecidableEq I] [DecidableEq A] [AddCommGroup G] [Fintype G]
    (x x' : I → A) (hne : x ≠ x') (t : G) :
    uniformProb (fun T : I × A → G => tabulationHash x T - tabulationHash x' T = t) =
      1 / Fintype.card G
```

`ProvenHashes.tabulation_collision_exact`

```lean
theorem tabulation_collision_exact {I A : Type*} [Fintype I] [Fintype A] [DecidableEq I] [DecidableEq A]
    (w : ℕ) (x x' : I → A) (hne : x ≠ x') :
    uniformProb (fun T : I × A → XorWord w => tabulationHash x T = tabulationHash x' T) =
      1 / (2 : ℚ≥0) ^ w
```

## [UnreducedNH.lean](ProvenHashes/UnreducedNH.lean)

`ProvenHashes.sum_mul_embedded_update`

```lean
lemma sum_mul_embedded_update {I W R : Type*}
    [Fintype I] [DecidableEq I] [CommRing R]
    (e : W → R) (c : I → R) (k : I → W) (i : I) (v : W) :
    (∑ j, c j * e (Function.update k i v j)) =
      c i * e v + ∑ j ∈ Finset.univ.erase i, c j * e (k j)
```

`ProvenHashes.embeddedNH_difference_bound`

```lean
theorem embeddedNH_difference_bound {W R : Type*}
    [Fintype W] [Nonempty W] [CommRing R] [IsDomain R] {n : ℕ}
    (e : W → R) (he : Function.Injective e)
    (m m' : Fin n × Bool → W) (hne : m ≠ m') (t : R) :
    uniformProb (fun k => embeddedNH e m k - embeddedNH e m' k = t) ≤
      1 / Fintype.card W
```

`ProvenHashes.Carryless.toPoly_injective`

```lean
theorem toPoly_injective (w : ℕ) : Function.Injective (@toPoly w)
```

`ProvenHashes.Carryless.word_card`

```lean
theorem word_card (w : ℕ) : Fintype.card (Word w) = 2 ^ w
```

`ProvenHashes.Carryless.xor_difference_bound`

```lean
theorem xor_difference_bound {w n : ℕ}
    (m m' : Fin n × Bool → Word w) (hne : m ≠ m') (t : (ZMod 2)[X]) :
    uniformProb (fun k => nh m k + nh m' k = t) ≤ 1 / (2 : ℚ≥0) ^ w
```

`ProvenHashes.Carryless.collision_bound`

```lean
theorem collision_bound {w n : ℕ}
    (m m' : Fin n × Bool → Word w) (hne : m ≠ m') :
    uniformProb (fun k => nh m k = nh m' k) ≤ 1 / (2 : ℚ≥0) ^ w
```

## [WordRepresentation.lean](ProvenHashes/WordRepresentation.lean)

`ProvenHashes.ChainHash.bitsOfBitVec_bitVecOfBits`

```lean
theorem bitsOfBitVec_bitVecOfBits {w : ℕ} (v : Word w) : bitsOfBitVec (bitVecOfBits v) = v
```

`ProvenHashes.ChainHash.bitVecOfBits_bitsOfBitVec`

```lean
theorem bitVecOfBits_bitsOfBitVec {w : ℕ} (v : BitVec w) : bitVecOfBits (bitsOfBitVec v) = v
```

`ProvenHashes.ChainHash.wordIntegerEquiv_length`

```lean
theorem wordIntegerEquiv_length (n : ℕ) : wordIntegerEquiv 64 (lengthWord n) = (n : ZMod (2 ^ 64))
```

## [WordSplit.lean](ProvenHashes/WordSplit.lean)

`ProvenHashes.ChainEncoding.unpack_pack`

```lean
theorem unpack_pack (v : Word 64 × Word 64) : unpack (pack v) = v
```

`ProvenHashes.ChainEncoding.pack_injective`

```lean
theorem pack_injective : Function.Injective pack
```

`ProvenHashes.ChainEncoding.pack_unpack`

```lean
theorem pack_unpack (p : (ZMod 2)[X]) (hp : p.degree < 128) : pack (unpack p) = p
```

`ProvenHashes.ChainEncoding.length_target_ne_zero`

```lean
theorem length_target_ne_zero {n m : ℕ}
    (hn : n < 2 ^ 64) (hm : m < 2 ^ 64) (hne : n ≠ m) :
    pack (lengthTag n + lengthTag m) ≠ 0
```

`ProvenHashes.ChainEncoding.tagged_equality_target`

```lean
theorem tagged_equality_target (p q : (ZMod 2)[X]) (hp : p.degree < 128) (hq : q.degree < 128)
    (n m : ℕ) (h : unpack p + lengthTag n = unpack q + lengthTag m) :
    p + q = pack (lengthTag n + lengthTag m)
```

