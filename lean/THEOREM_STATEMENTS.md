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

`ProvenHashes.ChainHash.binary_rabin128`

```lean
theorem binary_rabin128 (p : BitsPolynomial) (hp : p.Monic) (hdeg : p.natDegree = 128)
    (h128 : p ∣ X ^ (2 ^ 128) - X) (h64 : IsCoprime p (X ^ (2 ^ 64) - X)) :
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
lemma wordPoly_injective {b : ℕ} : Function.Injective (wordPoly (b := b))
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
lemma posStrided_injective {G : ℕ} : Function.Injective (posStrided (G := G))
```

`ProvenHashes.CLNH.posStrided_bijective`

```lean
lemma posStrided_bijective {G : ℕ} : Function.Bijective (posStrided (G := G))
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

`ProvenHashes.ChainHash.clnh_natDegree_le_width`

```lean
theorem clnh_natDegree_le_width {I : Type*} [DecidableEq I] {w : ℕ} (hw : 1 ≤ w)
    (s : Finset I) (m k : I × Bool → Word w) : (clnh s m k).natDegree ≤ 2 * w - 2
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

## [ChainHash128/ByteEncoding.lean](ProvenHashes/ChainHash128/ByteEncoding.lean)

`ProvenHashes.ChainHash128.wordAt_read_byte`

```lean
theorem wordAt_read_byte (m : Message) (j : ℕ) (b : Fin 8) :
    wordAt m (j / 16) ⟨8 * (j % 16) + b.val, by omega⟩ = byteAt m j b
```

`ProvenHashes.ChainHash128.byte_words_injective`

```lean
theorem byte_words_injective (m m' : Message) (hlen : m.length = m'.length)
    (hwords : ∀ j, 16 * j < m.length → wordAt m j = wordAt m' j) : m = m'
```

`ProvenHashes.ChainHash128.unpair_pairPosition`

```lean
theorem unpair_pairPosition (j : Fin 16 × Bool) : unpairPosition (pairPosition j) = j
```

`ProvenHashes.ChainHash128.pair_unpairPosition`

```lean
theorem pair_unpairPosition (j : Fin 32) : pairPosition (unpairPosition j) = j
```

`ProvenHashes.ChainHash128.activePairs_comparable`

```lean
theorem activePairs_comparable (m m' : Message) (t t' : ℕ) :
    activePairs m t ⊆ activePairs m' t' ∨ activePairs m' t' ⊆ activePairs m t
```

`ProvenHashes.ChainHash128.block_encoding_injective`

```lean
theorem block_encoding_injective (m m' : Message) (hlen : m.length = m'.length)
    (hblocks : ∀ t, t < blockCount m → ∀ s ∈ activePairs m t, ∀ b,
      blockData m t (s, b) = blockData m' t (s, b)) : m = m'
```

`ProvenHashes.ChainHash128.bitsOfBitVec_injective`

```lean
theorem bitsOfBitVec_injective (w : ℕ) : Function.Injective (@bitsOfBitVec w)
```

`ProvenHashes.ChainHash128.lengthWord_injective`

```lean
theorem lengthWord_injective {n n' : ℕ} (hn : n < 2 ^ 128) (hn' : n' < 2 ^ 128)
    (h : lengthWord n = lengthWord n') : n = n'
```

## [ChainHash128/ByteInterface.lean](ProvenHashes/ChainHash128/ByteInterface.lean)

`ProvenHashes.ChainHash128.bytesToMessage_injective`

```lean
theorem bytesToMessage_injective : Function.Injective bytesToMessage
```

`ProvenHashes.ChainHash128.hashBytes_eq_iff`

```lean
theorem hashBytes_eq_iff (k : Key41) (m m' : List UInt8) :
    hashBytes k m = hashBytes k m' ↔
      referenceHash k (bytesToMessage m) = referenceHash k (bytesToMessage m')
```

`ProvenHashes.ChainHash128.collision_bound_bytes`

```lean
theorem collision_bound_bytes (L : ℕ) (hL : 16 * L + 511 < 2 ^ 128)
    (m m' : List UInt8) (hm : m.length ≤ 16 * L) (hm' : m'.length ≤ 16 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key41 => hashBytes k m = hashBytes k m') ≤
      ((max 1 ((L + 31) / 32) + 2 : ℕ) : ℚ≥0) / (2 : ℚ≥0) ^ 128
```

## [ChainHash128/ChainHashModel.lean](ProvenHashes/ChainHash128/ChainHashModel.lean)

`ProvenHashes.ChainHash128.field_card`

```lean
theorem field_card {F : Type*} [AddGroup F] [Fintype F] (repr : Word 128 ≃+ F) :
    Fintype.card F = 2 ^ 128
```

`ProvenHashes.ChainHash128.idealKey_card`

```lean
theorem idealKey_card {F : Type*} [AddGroup F] [Fintype F] (repr : Word 128 ≃+ F) :
    Fintype.card (IdealKey F) = (2 ^ 128) ^ 41
```

`ProvenHashes.ChainHash128.finalStage_collision_bound`

```lean
theorem finalStage_collision_bound {F : Type*} [Field F] [Fintype F]
    (word : F ≃ ZMod (2 ^ 128)) (v v' : F) (hne : v ≠ v') :
    uniformProb (fun j : F × (Fin 5 → F) =>
      chain5 j.2 (integerTwist word j.1 v) = chain5 j.2 (integerTwist word j.1 v')) ≤
        1 / Fintype.card F
```

`ProvenHashes.ChainHash128.collision_bound_model`

```lean
theorem collision_bound_model {F : Type*} [Field F] [Fintype F]
    (repr : Word 128 ≃+ F) (word : F ≃ ZMod (2 ^ 128))
    (p : ℕ) (m m' : Message) (hm : m.length < 2 ^ 128) (hm' : m'.length < 2 ^ 128)
    (hne : m ≠ m') (hp : blockCount m ≤ p) (hp' : blockCount m' ≤ p) :
    uniformProb (fun k : IdealKey F => hash repr word k m = hash repr word k m') ≤
      ((p + 2 : ℕ) : ℚ≥0) / (2 : ℚ≥0) ^ 128
```

`ProvenHashes.ChainHash128.collision_bound_words_model`

```lean
theorem collision_bound_words_model {F : Type*} [Field F] [Fintype F]
    (repr : Word 128 ≃+ F) (word : F ≃ ZMod (2 ^ 128)) (L : ℕ) (hL : 16 * L < 2 ^ 128)
    (m m' : Message) (hm : m.length ≤ 16 * L) (hm' : m'.length ≤ 16 * L) (hne : m ≠ m') :
    uniformProb (fun k : IdealKey F => hash repr word k m = hash repr word k m') ≤ epsilon L
```

## [ChainHash128/ConcreteChainHash.lean](ProvenHashes/ChainHash128/ConcreteChainHash.lean)

`ProvenHashes.ChainHash128.chainHash_collision_bound`

```lean
theorem chainHash_collision_bound (L : ℕ) (hL : 16 * L < 2 ^ 128)
    (m m' : Message) (hm : m.length ≤ 16 * L) (hm' : m'.length ≤ 16 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key41 => chainHash k m = chainHash k m') ≤ epsilon L
```

`ProvenHashes.ChainHash128.chainHash_collision_bound_no_overflow`

```lean
theorem chainHash_collision_bound_no_overflow (L : ℕ) (hL : 16 * L + 511 < 2 ^ 128)
    (m m' : Message) (hm : m.length ≤ 16 * L) (hm' : m'.length ≤ 16 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key41 => chainHash k m = chainHash k m') ≤ epsilon L
```

## [ChainHash128/ConcreteWords.lean](ProvenHashes/ChainHash128/ConcreteWords.lean)

`ProvenHashes.ChainHash128.modulus_ne_one`

```lean
theorem modulus_ne_one : modulus ≠ 1
```

`ProvenHashes.ChainHash128.quotient_remainder_degree`

```lean
theorem quotient_remainder_degree (a : BinaryQuotient) :
    (AdjoinRoot.modByMonicHom modulus_monic a).natDegree < 128
```

`ProvenHashes.ChainHash128.fieldRepr_mul`

```lean
theorem fieldRepr_mul (v w : Word 128) :
    fieldRepr.symm (fieldRepr v * fieldRepr w) =
      lowWord ((pack 128 v * pack 128 w) %ₘ modulus)
```

## [ChainHash128/FieldStream.lean](ProvenHashes/ChainHash128/FieldStream.lean)

`ProvenHashes.ChainHash128.splitWords_injective`

```lean
theorem splitWords_injective {p q : BitsPolynomial} (hp : p.natDegree < 256)
    (hq : q.natDegree < 256)
    (hl : lowWord p = lowWord q) (hh : highWord p = highWord q) : p = q
```

`ProvenHashes.ChainHash128.lengthMask_natDegree_le`

```lean
theorem lengthMask_natDegree_le (n : ℕ) : (lengthMask n).natDegree ≤ 255
```

`ProvenHashes.ChainHash128.clnh_natDegree_le`

```lean
theorem clnh_natDegree_le {I : Type*} [DecidableEq I]
    (s : Finset I) (m k : I × Bool → Word 128) : (clnh s m k).natDegree ≤ 254
```

`ProvenHashes.ChainHash128.rawDigest_natDegree_lt`

```lean
theorem rawDigest_natDegree_lt (m : Message) (k : BlockKey) (t : ℕ) :
    (rawDigest m k t).natDegree < 256
```

`ProvenHashes.ChainHash128.splitField_injective`

```lean
theorem splitField_injective {F : Type*} [AddGroup F] (repr : Word 128 ≃+ F)
    {p q : BitsPolynomial} (hp : p.natDegree < 256) (hq : q.natDegree < 256)
    (h : splitField repr p = splitField repr q) : p = q
```

`ProvenHashes.ChainHash128.stream_length`

```lean
theorem stream_length {F : Type*} [AddGroup F] (repr : Word 128 ≃+ F)
    (m : Message) (k : BlockKey) : (stream repr m k).length = blockCount m
```

`ProvenHashes.ChainHash128.stream_eq_rawStream`

```lean
theorem stream_eq_rawStream {F : Type*} [AddGroup F] (repr : Word 128 ≃+ F)
    (m m' : Message) (k : BlockKey) (h : stream repr m k = stream repr m' k) :
    rawStream m k = rawStream m' k
```

`ProvenHashes.ChainHash128.stream_collision_bound`

```lean
theorem stream_collision_bound {F : Type*} [AddGroup F] (repr : Word 128 ≃+ F)
    (m m' : Message) (hm : m.length < 2 ^ 128) (hm' : m'.length < 2 ^ 128) (hne : m ≠ m') :
    uniformProb (fun k => stream repr m k = stream repr m' k) ≤ 1 / (2 : ℚ≥0) ^ 128
```

## [ChainHash128/KeyLayout.lean](ProvenHashes/ChainHash128/KeyLayout.lean)

`ProvenHashes.ChainHash128.encode_decodeKey`

```lean
theorem encode_decodeKey {F : Type*} [AddGroup F] (repr : Word 128 ≃+ F) (k : Key41) :
    encodeKey repr (decodeKey repr k) = k
```

`ProvenHashes.ChainHash128.decode_encodeKey`

```lean
theorem decode_encodeKey {F : Type*} [AddGroup F] (repr : Word 128 ≃+ F) (k : IdealKey F) :
    decodeKey repr (encodeKey repr k) = k
```

## [ChainHash128/ModelA.lean](ProvenHashes/ChainHash128/ModelA.lean)

`ProvenHashes.ChainHash128.ModelA.chainhash_equal_length_from_seeded_stages`

```lean
theorem chainhash_equal_length_from_seeded_stages {F K J : Type*}
    [Field F] [Fintype F] [Fintype K] [Fintype J] [Nonempty K] [Nonempty J]
    (D p : ℕ) (s s' : K → List (F × F)) (g : J → F → F)
    (hlen : ∀ k, (s k).length = (s' k).length)
    (hmax : ∀ k, (s k).length ≤ p)
    (hstream : uniformProb (fun k => s k = s' k) ≤ (D : ℚ≥0) / Fintype.card F)
    (hfinal : ∀ v v', v ≠ v' → uniformProb (fun j => g j v = g j v') ≤ 1 / Fintype.card F) :
    uniformProb (fun k : (K × (Fin 3 → F)) × J =>
      g k.2 (Recurrence.hash (s k.1.1) k.1.2) =
        g k.2 (Recurrence.hash (s' k.1.1) k.1.2)) ≤
      ((D + p + 1 : ℕ) : ℚ≥0) / Fintype.card F
```

`ProvenHashes.ChainHash128.ModelA.key_card`

```lean
theorem key_card : Fintype.card Key = (2 ^ 128) ^ 10
```

`ProvenHashes.ChainHash128.ModelA.expandedKey_power`

```lean
theorem expandedKey_power (k : Key) (j : Fin 32) :
    fieldRepr (expandedKey k ⟨j.val, by omega⟩) = k.1.1 ^ (j.val + 1)
```

`ProvenHashes.ChainHash128.ModelA.referenceHash_expanded`

```lean
theorem referenceHash_expanded (k : Key) (m : Message) :
    referenceHash (expandedKey k) m = fieldRepr.symm (hash k m)
```

`ProvenHashes.ChainHash128.ModelA.probability_le_one`

```lean
theorem probability_le_one {K : Type*} [Fintype K] [Nonempty K] (E : K → Prop) :
    uniformProb E ≤ 1
```

`ProvenHashes.ChainHash128.ModelA.collision_bound_fixed`

```lean
theorem collision_bound_fixed (L : ℕ) (hL : 0 < L) (m m' : Message)
    (hm : m.length = 16 * L) (hm' : m'.length = 16 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key => hash k m = hash k m') ≤ epsilonFixed L
```

`ProvenHashes.ChainHash128.ModelA.reference_collision_bound_fixed`

```lean
theorem reference_collision_bound_fixed (L : ℕ) (hL : 0 < L)
    (m m' : Message) (hm : m.length = 16 * L) (hm' : m'.length = 16 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key => referenceHash (expandedKey k) m = referenceHash (expandedKey k) m') ≤
      epsilonFixed L
```

`ProvenHashes.ChainHash128.ModelA.collision_bound_different_blocks`

```lean
theorem collision_bound_different_blocks (p : ℕ) (m m' : Message)
    (hlen : blockCount m ≠ blockCount m') (hm : blockCount m ≤ p) (hm' : blockCount m' ≤ p) :
    uniformProb (fun k : Key => hash k m = hash k m') ≤
      min 1 (((p + 2 : ℕ) : ℚ≥0) / 2 ^ 128)
```

`ProvenHashes.ChainHash128.ModelA.envelope_arithmetic`

```lean
theorem envelope_arithmetic (L : ℕ) (hL : 0 < L) :
    0 < wordBlocks L ∧ 0 < lastGroups L ∧ lastGroups L ≤ 8 ∧
      wordBlocks L + 2 ≤ envelopeNumerator L ∧
      countBudget (wordBlocks L) (lastGroups L) + wordBlocks L + 1 ≤ envelopeNumerator L ∧
      ∀ k, 0 < k → k < wordBlocks L → countBudget k 8 + k + 1 ≤ envelopeNumerator L
```

`ProvenHashes.ChainHash128.ModelA.message_cap_arithmetic`

```lean
theorem message_cap_arithmetic (L : ℕ) (hL : 0 < L) (m : Message) (hm : m.length ≤ 16 * L) :
    blockCount m ≤ wordBlocks L ∧
      (blockCount m = wordBlocks L → blockGroups m (blockCount m - 1) ≤ lastGroups L)
```

`ProvenHashes.ChainHash128.ModelA.collision_bound_common_blocks`

```lean
theorem collision_bound_common_blocks (G : ℕ) (hG : 0 < G) (hG8 : G ≤ 8)
    (m m' : Message) (hm : m.length < 2 ^ 128) (hm' : m'.length < 2 ^ 128)
    (hne : m ≠ m') (hc : blockCount m = blockCount m')
    (hg : blockGroups m (blockCount m - 1) ≤ G)
    (hg' : blockGroups m' (blockCount m - 1) ≤ G) :
    uniformProb (fun k : Key => hash k m = hash k m') ≤
      ((countBudget (blockCount m) G + blockCount m + 1 : ℕ) : ℚ≥0) / 2 ^ 128
```

`ProvenHashes.ChainHash128.ModelA.collision_bound_atMost`

```lean
theorem collision_bound_atMost (L : ℕ) (hL : 0 < L) (hcap : 16 * L < 2 ^ 128)
    (m m' : Message) (hm : m.length ≤ 16 * L) (hm' : m'.length ≤ 16 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key => hash k m = hash k m') ≤ epsilonAtMost L
```

`ProvenHashes.ChainHash128.ModelA.reference_collision_bound_atMost`

```lean
theorem reference_collision_bound_atMost (L : ℕ) (hL : 0 < L) (hcap : 16 * L < 2 ^ 128)
    (m m' : Message) (hm : m.length ≤ 16 * L) (hm' : m'.length ≤ 16 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key => referenceHash (expandedKey k) m = referenceHash (expandedKey k) m') ≤
      epsilonAtMost L
```

## [ChainHash128/ModelAStream.lean](ProvenHashes/ChainHash128/ModelAStream.lean)

`ProvenHashes.ChainHash128.ModelA.wordAt_zero`

```lean
theorem wordAt_zero (m : Message) (j : ℕ) (hj : m.length ≤ 16 * j) : wordAt m j = 0
```

`ProvenHashes.ChainHash128.ModelA.reduce_seeded_clnh`

```lean
theorem reduce_seeded_clnh (a : Finset (Fin 16)) (m : Slot → Word 128) (s : F) :
    AdjoinRoot.mk modulus (clnh a m (seededKey s)) =
      ph a (fun j => fieldRepr (m j)) s
```

`ProvenHashes.ChainHash128.ModelA.seededStream_equal_length_component`

```lean
theorem seededStream_equal_length_component (m m' : Message) (hl : m.length = m'.length)
    (t : ℕ) (ht : t < blockCount m) (s : F)
    (hs : seededStream m s = seededStream m' s) :
    ph (activePairs m t) (fun j => fieldRepr (blockData m t j)) s =
      ph (activePairs m t) (fun j => fieldRepr (blockData m' t j)) s
```

`ProvenHashes.ChainHash128.ModelA.partner_exponent_budget`

```lean
theorem partner_exponent_budget (L : ℕ) (hL : 3 ≤ L) (j : Slot)
    (hj : (pairPosition j).val < L) : exponent (partner j) ≤ degreeBudget L
```

`ProvenHashes.ChainHash128.ModelA.seededStream_fixed_bound`

```lean
theorem seededStream_fixed_bound (L : ℕ) (hL : 0 < L) (m m' : Message)
    (hm : m.length = 16 * L) (hm' : m'.length = 16 * L) (hne : m ≠ m') :
    uniformProb (fun s : F => seededStream m s = seededStream m' s) ≤
      (degreeBudget L : ℚ≥0) / Fintype.card F
```

`ProvenHashes.ChainHash128.ModelA.reduced_lengthMask_injective`

```lean
theorem reduced_lengthMask_injective {n n' : ℕ} (hn : n < 2 ^ 128) (hn' : n' < 2 ^ 128)
    (h : AdjoinRoot.mk modulus (lengthMask n) = AdjoinRoot.mk modulus (lengthMask n')) :
    n = n'
```

`ProvenHashes.ChainHash128.ModelA.blockGroups_properties`

```lean
theorem blockGroups_properties (m : Message) (t : ℕ) :
    blockGroups m t ≤ 8 ∧ activePairs m t = groupPairs (blockGroups m t)
```

`ProvenHashes.ChainHash128.ModelA.seededStream_last_component`

```lean
theorem seededStream_last_component (m m' : Message) (hc : blockCount m = blockCount m')
    (s : F) (hs : seededStream m s = seededStream m' s) :
    let t := blockCount m - 1
    ph (activePairs m t) (fun j => fieldRepr (blockData m t j)) s -
      ph (activePairs m' t) (fun j => fieldRepr (blockData m' t j)) s =
      AdjoinRoot.mk modulus (lengthMask m'.length) - AdjoinRoot.mk modulus (lengthMask m.length)
```

`ProvenHashes.ChainHash128.ModelA.seededStream_common_count_bound`

```lean
theorem seededStream_common_count_bound (G : ℕ) (hG : 0 < G) (hG8 : G ≤ 8)
    (m m' : Message) (hm : m.length < 2 ^ 128) (hm' : m'.length < 2 ^ 128)
    (hne : m ≠ m') (hc : blockCount m = blockCount m')
    (hg : blockGroups m (blockCount m - 1) ≤ G)
    (hg' : blockGroups m' (blockCount m - 1) ≤ G) :
    uniformProb (fun s : F => seededStream m s = seededStream m' s) ≤
      (countBudget (blockCount m) G : ℚ≥0) / Fintype.card F
```

## [ChainHash128/Modulus.lean](ProvenHashes/ChainHash128/Modulus.lean)

`ProvenHashes.ChainHash128.modulus_tail_degree`

```lean
theorem modulus_tail_degree : (X ^ 7 + X ^ 2 + X + 1 : BitsPolynomial).degree < 128
```

`ProvenHashes.ChainHash128.modulus_monic`

```lean
theorem modulus_monic : modulus.Monic
```

`ProvenHashes.ChainHash128.modulus_degree`

```lean
theorem modulus_degree : modulus.natDegree = 128
```

`ProvenHashes.ChainHash128.square_test`

```lean
theorem square_test : ((X + 1 : BitsPolynomial) ^ 2) = X ^ 2 + 1
```

## [ChainHash128/ModulusCertificate.lean](ProvenHashes/ChainHash128/ModulusCertificate.lean)

`ProvenHashes.ChainHash128.residue_bezout`

```lean
theorem residue_bezout : modulus * (sparse [0, 1, 3, 4, 5, 6, 10, 12, 14, 16, 17, 21, 22, 23, 24, 25, 28, 29, 30, 32, 33, 34, 35, 36, 40, 42, 46, 47, 49, 50, 51, 54, 56, 61, 65, 66, 68, 69, 75, 76, 78, 83, 85, 86, 88, 89, 91, 92, 93, 94, 95, 96, 98, 101, 103, 104, 107, 108, 112, 113, 116, 117, 118, 119, 122, 124, 125]) + (residue_64 - X) * (sparse [3, 4, 12, 13, 15, 16, 18, 20, 23, 26, 27, 29, 32, 34, 35, 36, 37, 38, 39, 41, 43, 46, 47, 51, 53, 55, 56, 62, 65, 67, 71, 72, 73, 79, 82, 83, 84, 85, 87, 88, 90, 91, 92, 94, 95, 99, 101, 104, 107, 108, 109, 110, 111, 113, 115, 118, 121, 122, 123, 124, 127]) = 1
```

## [ChainHash128/ModulusIrreducible.lean](ProvenHashes/ChainHash128/ModulusIrreducible.lean)

`ProvenHashes.ChainHash128.residue_power_step`

```lean
theorem residue_power_step (i : ℕ) (r s q : BitsPolynomial)
    (hs : r ^ 2 = s + modulus * q)
    (hr : AdjoinRoot.root modulus ^ (2 ^ i) = AdjoinRoot.mk modulus r) :
    AdjoinRoot.root modulus ^ (2 ^ (i + 1)) = AdjoinRoot.mk modulus s
```

`ProvenHashes.ChainHash128.modulus_frobenius_certificates`

```lean
theorem modulus_frobenius_certificates :
    modulus ∣ X ^ (2 ^ 128) - X ∧ modulus ∣ X ^ (2 ^ 64) - residue_64
```

`ProvenHashes.ChainHash128.modulus_irreducible`

```lean
theorem modulus_irreducible : Irreducible modulus
```

## [ChainHash128/ModulusResidues.lean](ProvenHashes/ChainHash128/ModulusResidues.lean)

`ProvenHashes.ChainHash128.poly_num_2`

```lean
theorem poly_num_2 : (2 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_3`

```lean
theorem poly_num_3 : (3 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_4`

```lean
theorem poly_num_4 : (4 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_5`

```lean
theorem poly_num_5 : (5 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_6`

```lean
theorem poly_num_6 : (6 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_7`

```lean
theorem poly_num_7 : (7 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_8`

```lean
theorem poly_num_8 : (8 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_9`

```lean
theorem poly_num_9 : (9 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_10`

```lean
theorem poly_num_10 : (10 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_11`

```lean
theorem poly_num_11 : (11 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_12`

```lean
theorem poly_num_12 : (12 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_13`

```lean
theorem poly_num_13 : (13 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_14`

```lean
theorem poly_num_14 : (14 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_15`

```lean
theorem poly_num_15 : (15 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_16`

```lean
theorem poly_num_16 : (16 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_17`

```lean
theorem poly_num_17 : (17 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_18`

```lean
theorem poly_num_18 : (18 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_19`

```lean
theorem poly_num_19 : (19 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_20`

```lean
theorem poly_num_20 : (20 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_21`

```lean
theorem poly_num_21 : (21 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_22`

```lean
theorem poly_num_22 : (22 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_23`

```lean
theorem poly_num_23 : (23 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_24`

```lean
theorem poly_num_24 : (24 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_25`

```lean
theorem poly_num_25 : (25 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_26`

```lean
theorem poly_num_26 : (26 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_27`

```lean
theorem poly_num_27 : (27 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_28`

```lean
theorem poly_num_28 : (28 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_29`

```lean
theorem poly_num_29 : (29 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_30`

```lean
theorem poly_num_30 : (30 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_31`

```lean
theorem poly_num_31 : (31 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_32`

```lean
theorem poly_num_32 : (32 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_33`

```lean
theorem poly_num_33 : (33 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_34`

```lean
theorem poly_num_34 : (34 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_35`

```lean
theorem poly_num_35 : (35 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_36`

```lean
theorem poly_num_36 : (36 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_37`

```lean
theorem poly_num_37 : (37 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_38`

```lean
theorem poly_num_38 : (38 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_39`

```lean
theorem poly_num_39 : (39 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_40`

```lean
theorem poly_num_40 : (40 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_41`

```lean
theorem poly_num_41 : (41 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_42`

```lean
theorem poly_num_42 : (42 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_43`

```lean
theorem poly_num_43 : (43 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_44`

```lean
theorem poly_num_44 : (44 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_45`

```lean
theorem poly_num_45 : (45 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_46`

```lean
theorem poly_num_46 : (46 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_47`

```lean
theorem poly_num_47 : (47 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_48`

```lean
theorem poly_num_48 : (48 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_49`

```lean
theorem poly_num_49 : (49 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_50`

```lean
theorem poly_num_50 : (50 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_51`

```lean
theorem poly_num_51 : (51 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_52`

```lean
theorem poly_num_52 : (52 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_53`

```lean
theorem poly_num_53 : (53 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_54`

```lean
theorem poly_num_54 : (54 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_55`

```lean
theorem poly_num_55 : (55 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_56`

```lean
theorem poly_num_56 : (56 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_57`

```lean
theorem poly_num_57 : (57 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_58`

```lean
theorem poly_num_58 : (58 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_59`

```lean
theorem poly_num_59 : (59 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_60`

```lean
theorem poly_num_60 : (60 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_61`

```lean
theorem poly_num_61 : (61 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_62`

```lean
theorem poly_num_62 : (62 : BitsPolynomial) = 0
```

`ProvenHashes.ChainHash128.poly_num_63`

```lean
theorem poly_num_63 : (63 : BitsPolynomial) = 1
```

`ProvenHashes.ChainHash128.poly_num_64`

```lean
theorem poly_num_64 : (64 : BitsPolynomial) = 0
```

## [ChainHash128/ModulusSteps0.lean](ProvenHashes/ChainHash128/ModulusSteps0.lean)

`ProvenHashes.ChainHash128.residue_step_0`

```lean
theorem residue_step_0 : residue_0 ^ 2 = residue_1 + modulus * (sparse [])
```

## [ChainHash128/ModulusSteps1.lean](ProvenHashes/ChainHash128/ModulusSteps1.lean)

`ProvenHashes.ChainHash128.residue_step_1`

```lean
theorem residue_step_1 : residue_1 ^ 2 = residue_2 + modulus * (sparse [])
```

## [ChainHash128/ModulusSteps10.lean](ProvenHashes/ChainHash128/ModulusSteps10.lean)

`ProvenHashes.ChainHash128.residue_step_10`

```lean
theorem residue_step_10 : residue_10 ^ 2 = residue_11 + modulus * (sparse [])
```

## [ChainHash128/ModulusSteps100.lean](ProvenHashes/ChainHash128/ModulusSteps100.lean)

`ProvenHashes.ChainHash128.residue_step_100`

```lean
theorem residue_step_100 : residue_100 ^ 2 = residue_101 + modulus * (sparse [5, 10, 12, 14, 16, 18, 22, 24, 28, 32, 36, 40, 42, 44, 46, 48, 56, 58, 62, 64, 66, 72, 74, 82, 86, 88, 98, 106, 108, 112, 114, 118, 126])
```

## [ChainHash128/ModulusSteps101.lean](ProvenHashes/ChainHash128/ModulusSteps101.lean)

`ProvenHashes.ChainHash128.residue_step_101`

```lean
theorem residue_step_101 : residue_101 ^ 2 = residue_102 + modulus * (sparse [0, 1, 4, 5, 6, 10, 12, 14, 20, 22, 24, 28, 30, 32, 34, 36, 38, 46, 48, 58, 62, 64, 70, 76, 82, 84, 86, 88, 90, 108, 114, 116, 122, 126])
```

## [ChainHash128/ModulusSteps102.lean](ProvenHashes/ChainHash128/ModulusSteps102.lean)

`ProvenHashes.ChainHash128.residue_step_102`

```lean
theorem residue_step_102 : residue_102 ^ 2 = residue_103 + modulus * (sparse [3, 5, 8, 10, 20, 42, 46, 48, 52, 56, 58, 62, 64, 66, 72, 76, 84, 88, 90, 96, 106, 112, 114, 116, 124, 126])
```

## [ChainHash128/ModulusSteps103.lean](ProvenHashes/ChainHash128/ModulusSteps103.lean)

`ProvenHashes.ChainHash128.residue_step_103`

```lean
theorem residue_step_103 : residue_103 ^ 2 = residue_104 + modulus * (sparse [1, 3, 4, 5, 6, 8, 10, 14, 16, 20, 24, 26, 28, 30, 36, 38, 42, 48, 50, 52, 60, 62, 72, 78, 86, 88, 92, 102, 104, 106, 110, 114, 118, 120, 122, 124, 126])
```

## [ChainHash128/ModulusSteps104.lean](ProvenHashes/ChainHash128/ModulusSteps104.lean)

`ProvenHashes.ChainHash128.residue_step_104`

```lean
theorem residue_step_104 : residue_104 ^ 2 = residue_105 + modulus * (sparse [0, 6, 8, 10, 16, 18, 20, 24, 28, 32, 40, 42, 46, 50, 52, 56, 62, 70, 76, 78, 80, 82, 86, 88, 90, 96, 98, 102, 104, 106, 108, 110, 118, 120])
```

## [ChainHash128/ModulusSteps105.lean](ProvenHashes/ChainHash128/ModulusSteps105.lean)

`ProvenHashes.ChainHash128.residue_step_105`

```lean
theorem residue_step_105 : residue_105 ^ 2 = residue_106 + modulus * (sparse [1, 3, 4, 5, 8, 10, 14, 24, 28, 30, 34, 40, 42, 44, 52, 54, 56, 58, 62, 70, 72, 84, 86, 92, 98, 100, 102, 106, 110, 114, 122, 124, 126])
```

## [ChainHash128/ModulusSteps106.lean](ProvenHashes/ChainHash128/ModulusSteps106.lean)

`ProvenHashes.ChainHash128.residue_step_106`

```lean
theorem residue_step_106 : residue_106 ^ 2 = residue_107 + modulus * (sparse [0, 1, 2, 4, 5, 8, 10, 14, 18, 20, 26, 28, 30, 32, 36, 40, 42, 44, 46, 54, 56, 60, 64, 74, 76, 78, 80, 82, 84, 90, 92, 94, 96, 98, 100, 102, 104, 106, 108, 112, 114, 116, 118, 120, 122, 126])
```

## [ChainHash128/ModulusSteps107.lean](ProvenHashes/ChainHash128/ModulusSteps107.lean)

`ProvenHashes.ChainHash128.residue_step_107`

```lean
theorem residue_step_107 : residue_107 ^ 2 = residue_108 + modulus * (sparse [0, 1, 2, 3, 4, 6, 8, 14, 22, 24, 26, 30, 40, 46, 48, 50, 58, 60, 62, 64, 68, 76, 80, 84, 88, 94, 100, 104, 106, 116, 120, 122, 124])
```

## [ChainHash128/ModulusSteps108.lean](ProvenHashes/ChainHash128/ModulusSteps108.lean)

`ProvenHashes.ChainHash128.residue_step_108`

```lean
theorem residue_step_108 : residue_108 ^ 2 = residue_109 + modulus * (sparse [1, 4, 5, 6, 8, 14, 22, 26, 32, 34, 38, 42, 44, 46, 50, 54, 60, 68, 80, 82, 84, 92, 94, 96, 98, 100, 104, 106, 108, 112, 114, 120, 122, 126])
```

## [ChainHash128/ModulusSteps109.lean](ProvenHashes/ChainHash128/ModulusSteps109.lean)

`ProvenHashes.ChainHash128.residue_step_109`

```lean
theorem residue_step_109 : residue_109 ^ 2 = residue_110 + modulus * (sparse [0, 4, 6, 10, 12, 20, 22, 24, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 54, 58, 62, 64, 66, 68, 72, 78, 80, 84, 90, 94, 100, 104, 108, 110, 112, 116, 118])
```

## [ChainHash128/ModulusSteps11.lean](ProvenHashes/ChainHash128/ModulusSteps11.lean)

`ProvenHashes.ChainHash128.residue_step_11`

```lean
theorem residue_step_11 : residue_11 ^ 2 = residue_12 + modulus * (sparse [96])
```

## [ChainHash128/ModulusSteps110.lean](ProvenHashes/ChainHash128/ModulusSteps110.lean)

`ProvenHashes.ChainHash128.residue_step_110`

```lean
theorem residue_step_110 : residue_110 ^ 2 = residue_111 + modulus * (sparse [1, 6, 14, 20, 22, 24, 28, 34, 40, 46, 48, 52, 62, 66, 68, 72, 76, 82, 86, 88, 90, 92, 98, 102, 112, 118, 120, 122])
```

## [ChainHash128/ModulusSteps111.lean](ProvenHashes/ChainHash128/ModulusSteps111.lean)

`ProvenHashes.ChainHash128.residue_step_111`

```lean
theorem residue_step_111 : residue_111 ^ 2 = residue_112 + modulus * (sparse [0, 1, 3, 5, 6, 16, 22, 24, 26, 28, 30, 36, 44, 46, 54, 56, 60, 62, 64, 66, 68, 72, 76, 78, 82, 84, 90, 98, 112, 114, 116, 118, 122, 124, 126])
```

## [ChainHash128/ModulusSteps112.lean](ProvenHashes/ChainHash128/ModulusSteps112.lean)

`ProvenHashes.ChainHash128.residue_step_112`

```lean
theorem residue_step_112 : residue_112 ^ 2 = residue_113 + modulus * (sparse [0, 2, 3, 5, 12, 14, 16, 20, 22, 26, 36, 44, 48, 50, 52, 56, 64, 66, 70, 72, 80, 82, 92, 98, 102, 104, 106, 108, 112, 114, 116, 124, 126])
```

## [ChainHash128/ModulusSteps113.lean](ProvenHashes/ChainHash128/ModulusSteps113.lean)

`ProvenHashes.ChainHash128.residue_step_113`

```lean
theorem residue_step_113 : residue_113 ^ 2 = residue_114 + modulus * (sparse [0, 1, 2, 4, 5, 6, 8, 16, 20, 24, 26, 30, 32, 34, 38, 40, 44, 46, 48, 50, 52, 58, 64, 68, 78, 80, 84, 86, 94, 96, 100, 104, 106, 108, 110, 114, 118, 122, 126])
```

## [ChainHash128/ModulusSteps114.lean](ProvenHashes/ChainHash128/ModulusSteps114.lean)

`ProvenHashes.ChainHash128.residue_step_114`

```lean
theorem residue_step_114 : residue_114 ^ 2 = residue_115 + modulus * (sparse [0, 1, 5, 10, 12, 14, 20, 22, 24, 28, 30, 32, 34, 36, 40, 44, 48, 52, 54, 56, 58, 60, 62, 66, 76, 78, 82, 84, 90, 92, 96, 98, 100, 106, 110, 114, 116, 118, 120, 122, 126])
```

## [ChainHash128/ModulusSteps115.lean](ProvenHashes/ChainHash128/ModulusSteps115.lean)

`ProvenHashes.ChainHash128.residue_step_115`

```lean
theorem residue_step_115 : residue_115 ^ 2 = residue_116 + modulus * (sparse [0, 1, 2, 3, 4, 10, 12, 18, 20, 24, 26, 30, 32, 36, 40, 44, 48, 50, 52, 58, 60, 68, 74, 76, 78, 82, 84, 94, 96, 98, 102, 110, 112, 120, 122, 124])
```

## [ChainHash128/ModulusSteps116.lean](ProvenHashes/ChainHash128/ModulusSteps116.lean)

`ProvenHashes.ChainHash128.residue_step_116`

```lean
theorem residue_step_116 : residue_116 ^ 2 = residue_117 + modulus * (sparse [0, 1, 2, 3, 4, 5, 6, 10, 12, 20, 24, 26, 28, 30, 34, 36, 50, 52, 54, 62, 64, 66, 68, 70, 72, 74, 80, 82, 84, 90, 92, 94, 98, 106, 110, 112, 114, 118, 122, 124, 126])
```

## [ChainHash128/ModulusSteps117.lean](ProvenHashes/ChainHash128/ModulusSteps117.lean)

`ProvenHashes.ChainHash128.residue_step_117`

```lean
theorem residue_step_117 : residue_117 ^ 2 = residue_118 + modulus * (sparse [2, 5, 6, 16, 24, 26, 28, 30, 36, 38, 40, 42, 46, 50, 58, 60, 62, 66, 74, 82, 86, 88, 94, 96, 100, 102, 106, 108, 114, 118, 120, 126])
```

## [ChainHash128/ModulusSteps118.lean](ProvenHashes/ChainHash128/ModulusSteps118.lean)

`ProvenHashes.ChainHash128.residue_step_118`

```lean
theorem residue_step_118 : residue_118 ^ 2 = residue_119 + modulus * (sparse [0, 1, 2, 8, 10, 16, 18, 20, 22, 32, 34, 38, 46, 52, 58, 60, 64, 66, 68, 76, 96, 98, 104, 110, 120, 122])
```

## [ChainHash128/ModulusSteps119.lean](ProvenHashes/ChainHash128/ModulusSteps119.lean)

`ProvenHashes.ChainHash128.residue_step_119`

```lean
theorem residue_step_119 : residue_119 ^ 2 = residue_120 + modulus * (sparse [3, 4, 5, 8, 10, 14, 18, 22, 26, 36, 38, 40, 52, 56, 66, 68, 70, 72, 76, 78, 80, 92, 100, 106, 108, 112, 114, 116, 118, 120, 124, 126])
```

## [ChainHash128/ModulusSteps12.lean](ProvenHashes/ChainHash128/ModulusSteps12.lean)

`ProvenHashes.ChainHash128.residue_step_12`

```lean
theorem residue_step_12 : residue_12 ^ 2 = residue_13 + modulus * (sparse [0, 64, 66, 68, 78])
```

## [ChainHash128/ModulusSteps120.lean](ProvenHashes/ChainHash128/ModulusSteps120.lean)

`ProvenHashes.ChainHash128.residue_step_120`

```lean
theorem residue_step_120 : residue_120 ^ 2 = residue_121 + modulus * (sparse [0, 6, 8, 10, 12, 14, 16, 20, 22, 32, 34, 38, 42, 46, 52, 56, 58, 64, 70, 74, 76, 80, 84, 90, 92, 96, 106, 118])
```

## [ChainHash128/ModulusSteps121.lean](ProvenHashes/ChainHash128/ModulusSteps121.lean)

`ProvenHashes.ChainHash128.residue_step_121`

```lean
theorem residue_step_121 : residue_121 ^ 2 = residue_122 + modulus * (sparse [0, 1, 3, 12, 16, 22, 24, 38, 40, 42, 46, 58, 64, 68, 70, 72, 78, 86, 88, 98, 100, 110, 112, 122, 124])
```

## [ChainHash128/ModulusSteps122.lean](ProvenHashes/ChainHash128/ModulusSteps122.lean)

`ProvenHashes.ChainHash128.residue_step_122`

```lean
theorem residue_step_122 : residue_122 ^ 2 = residue_123 + modulus * (sparse [0, 1, 10, 12, 18, 20, 22, 26, 28, 36, 42, 46, 48, 50, 58, 60, 62, 70, 72, 74, 76, 82, 86, 92, 94, 98, 104, 106, 110, 116, 118, 122])
```

## [ChainHash128/ModulusSteps123.lean](ProvenHashes/ChainHash128/ModulusSteps123.lean)

`ProvenHashes.ChainHash128.residue_step_123`

```lean
theorem residue_step_123 : residue_123 ^ 2 = residue_124 + modulus * (sparse [1, 2, 6, 10, 12, 14, 18, 22, 30, 34, 40, 46, 50, 52, 62, 72, 74, 80, 84, 86, 92, 96, 98, 104, 108, 110, 116, 120, 122])
```

## [ChainHash128/ModulusSteps124.lean](ProvenHashes/ChainHash128/ModulusSteps124.lean)

`ProvenHashes.ChainHash128.residue_step_124`

```lean
theorem residue_step_124 : residue_124 ^ 2 = residue_125 + modulus * (sparse [3, 4, 5, 8, 10, 12, 18, 20, 22, 24, 30, 36, 42, 54, 64, 66, 76, 78, 80, 88, 90, 92, 100, 102, 104, 112, 114, 116, 124, 126])
```

## [ChainHash128/ModulusSteps125.lean](ProvenHashes/ChainHash128/ModulusSteps125.lean)

`ProvenHashes.ChainHash128.residue_step_125`

```lean
theorem residue_step_125 : residue_125 ^ 2 = residue_126 + modulus * (sparse [1, 2, 3, 5, 6, 8, 12, 14, 18, 20, 24, 26, 30, 34, 36, 38, 42, 46, 48, 50, 54, 58, 60, 62, 64, 66, 70, 72, 74, 76, 78, 82, 84, 86, 88, 90, 94, 98, 100, 102, 106, 110, 112, 114, 118, 122, 124, 126])
```

## [ChainHash128/ModulusSteps126.lean](ProvenHashes/ChainHash128/ModulusSteps126.lean)

`ProvenHashes.ChainHash128.residue_step_126`

```lean
theorem residue_step_126 : residue_126 ^ 2 = residue_127 + modulus * (sparse [5, 10, 12, 22, 24, 34, 36, 46, 48, 58, 60, 66, 70, 72, 78, 82, 84, 90, 94, 96, 102, 106, 108, 114, 118, 120, 126])
```

## [ChainHash128/ModulusSteps127.lean](ProvenHashes/ChainHash128/ModulusSteps127.lean)

`ProvenHashes.ChainHash128.residue_step_127`

```lean
theorem residue_step_127 : residue_127 ^ 2 = residue_128 + modulus * (sparse [1, 2, 8, 14, 20, 26, 32, 38, 44, 50, 56, 62, 68, 74, 80, 86, 92, 98, 104, 110, 116, 122])
```

## [ChainHash128/ModulusSteps13.lean](ProvenHashes/ChainHash128/ModulusSteps13.lean)

`ProvenHashes.ChainHash128.residue_step_13`

```lean
theorem residue_step_13 : residue_13 ^ 2 = residue_14 + modulus * (sparse [2, 6, 10, 12, 14, 18, 22, 28, 30, 32, 42])
```

## [ChainHash128/ModulusSteps14.lean](ProvenHashes/ChainHash128/ModulusSteps14.lean)

`ProvenHashes.ChainHash128.residue_step_14`

```lean
theorem residue_step_14 : residue_14 ^ 2 = residue_15 + modulus * (sparse [])
```

## [ChainHash128/ModulusSteps15.lean](ProvenHashes/ChainHash128/ModulusSteps15.lean)

`ProvenHashes.ChainHash128.residue_step_15`

```lean
theorem residue_step_15 : residue_15 ^ 2 = residue_16 + modulus * (sparse [4, 8, 12, 20, 28, 40, 44, 48, 68])
```

## [ChainHash128/ModulusSteps16.lean](ProvenHashes/ChainHash128/ModulusSteps16.lean)

`ProvenHashes.ChainHash128.residue_step_16`

```lean
theorem residue_step_16 : residue_16 ^ 2 = residue_17 + modulus * (sparse [0, 10, 12, 16, 22, 32, 40, 48, 56, 64, 72, 96, 120])
```

## [ChainHash128/ModulusSteps17.lean](ProvenHashes/ChainHash128/ModulusSteps17.lean)

`ProvenHashes.ChainHash128.residue_step_17`

```lean
theorem residue_step_17 : residue_17 ^ 2 = residue_18 + modulus * (sparse [0, 2, 4, 5, 12, 14, 18, 20, 30, 36, 40, 52, 56, 60, 66, 72, 76, 78, 92, 96, 114, 116, 126])
```

## [ChainHash128/ModulusSteps18.lean](ProvenHashes/ChainHash128/ModulusSteps18.lean)

`ProvenHashes.ChainHash128.residue_step_18`

```lean
theorem residue_step_18 : residue_18 ^ 2 = residue_19 + modulus * (sparse [5, 16, 20, 26, 28, 32, 36, 38, 42, 48, 56, 58, 64, 66, 70, 72, 78, 88, 92, 96, 102, 106, 108, 112, 114, 118, 126])
```

## [ChainHash128/ModulusSteps19.lean](ProvenHashes/ChainHash128/ModulusSteps19.lean)

`ProvenHashes.ChainHash128.residue_step_19`

```lean
theorem residue_step_19 : residue_19 ^ 2 = residue_20 + modulus * (sparse [0, 1, 5, 6, 8, 12, 16, 20, 26, 28, 32, 36, 40, 42, 44, 48, 50, 52, 56, 58, 62, 66, 68, 70, 76, 80, 86, 88, 92, 96, 100, 104, 112, 114, 116, 120, 122, 126])
```

## [ChainHash128/ModulusSteps2.lean](ProvenHashes/ChainHash128/ModulusSteps2.lean)

`ProvenHashes.ChainHash128.residue_step_2`

```lean
theorem residue_step_2 : residue_2 ^ 2 = residue_3 + modulus * (sparse [])
```

## [ChainHash128/ModulusSteps20.lean](ProvenHashes/ChainHash128/ModulusSteps20.lean)

`ProvenHashes.ChainHash128.residue_step_20`

```lean
theorem residue_step_20 : residue_20 ^ 2 = residue_21 + modulus * (sparse [2, 4, 6, 8, 12, 14, 16, 18, 20, 22, 24, 28, 34, 36, 38, 40, 44, 48, 50, 56, 60, 62, 64, 66, 68, 70, 72, 74, 76, 78, 82, 84, 86, 88, 92, 94, 96, 98, 100, 102, 106, 110, 112])
```

## [ChainHash128/ModulusSteps21.lean](ProvenHashes/ChainHash128/ModulusSteps21.lean)

`ProvenHashes.ChainHash128.residue_step_21`

```lean
theorem residue_step_21 : residue_21 ^ 2 = residue_22 + modulus * (sparse [2, 12, 16, 20, 24, 28, 32, 34, 40, 46, 54, 56, 60, 64, 66, 80, 82, 90, 94, 100, 104, 106, 110, 112, 120])
```

## [ChainHash128/ModulusSteps22.lean](ProvenHashes/ChainHash128/ModulusSteps22.lean)

`ProvenHashes.ChainHash128.residue_step_22`

```lean
theorem residue_step_22 : residue_22 ^ 2 = residue_23 + modulus * (sparse [2, 5, 8, 14, 16, 18, 20, 24, 28, 34, 38, 40, 44, 46, 50, 52, 54, 56, 62, 64, 66, 68, 72, 76, 80, 82, 88, 96, 100, 106, 110, 112, 114, 126])
```

## [ChainHash128/ModulusSteps23.lean](ProvenHashes/ChainHash128/ModulusSteps23.lean)

`ProvenHashes.ChainHash128.residue_step_23`

```lean
theorem residue_step_23 : residue_23 ^ 2 = residue_24 + modulus * (sparse [2, 4, 5, 6, 8, 12, 14, 16, 20, 22, 24, 26, 30, 34, 46, 48, 52, 56, 62, 66, 68, 72, 74, 76, 78, 80, 88, 94, 96, 100, 102, 106, 110, 112, 114, 126])
```

## [ChainHash128/ModulusSteps24.lean](ProvenHashes/ChainHash128/ModulusSteps24.lean)

`ProvenHashes.ChainHash128.residue_step_24`

```lean
theorem residue_step_24 : residue_24 ^ 2 = residue_25 + modulus * (sparse [3, 4, 5, 6, 12, 16, 26, 28, 32, 36, 38, 42, 46, 50, 52, 56, 60, 64, 66, 68, 72, 84, 90, 94, 102, 104, 106, 108, 110, 112, 114, 116, 124, 126])
```

## [ChainHash128/ModulusSteps25.lean](ProvenHashes/ChainHash128/ModulusSteps25.lean)

`ProvenHashes.ChainHash128.residue_step_25`

```lean
theorem residue_step_25 : residue_25 ^ 2 = residue_26 + modulus * (sparse [0, 1, 2, 4, 5, 10, 14, 16, 22, 24, 30, 32, 36, 40, 42, 44, 48, 52, 56, 62, 66, 68, 72, 74, 76, 78, 80, 82, 86, 92, 100, 110, 112, 114, 118, 120, 122, 126])
```

## [ChainHash128/ModulusSteps26.lean](ProvenHashes/ChainHash128/ModulusSteps26.lean)

`ProvenHashes.ChainHash128.residue_step_26`

```lean
theorem residue_step_26 : residue_26 ^ 2 = residue_27 + modulus * (sparse [0, 1, 4, 6, 16, 20, 24, 26, 32, 42, 44, 50, 52, 64, 68, 70, 72, 74, 86, 88, 92, 94, 96, 98, 102, 104, 106, 116, 118, 122])
```

## [ChainHash128/ModulusSteps27.lean](ProvenHashes/ChainHash128/ModulusSteps27.lean)

`ProvenHashes.ChainHash128.residue_step_27`

```lean
theorem residue_step_27 : residue_27 ^ 2 = residue_28 + modulus * (sparse [1, 2, 8, 10, 18, 24, 26, 28, 30, 32, 34, 36, 44, 46, 48, 50, 56, 60, 64, 66, 74, 84, 86, 88, 90, 92, 94, 98, 100, 104, 106, 108, 110, 116, 122])
```

## [ChainHash128/ModulusSteps28.lean](ProvenHashes/ChainHash128/ModulusSteps28.lean)

`ProvenHashes.ChainHash128.residue_step_28`

```lean
theorem residue_step_28 : residue_28 ^ 2 = residue_29 + modulus * (sparse [2, 14, 16, 18, 20, 22, 24, 28, 32, 34, 40, 42, 44, 46, 50, 52, 56, 64, 66, 76, 84, 88, 90, 98, 100, 102, 112, 116, 120])
```

## [ChainHash128/ModulusSteps29.lean](ProvenHashes/ChainHash128/ModulusSteps29.lean)

`ProvenHashes.ChainHash128.residue_step_29`

```lean
theorem residue_step_29 : residue_29 ^ 2 = residue_30 + modulus * (sparse [0, 2, 3, 5, 6, 14, 18, 26, 32, 36, 38, 42, 48, 50, 52, 60, 62, 64, 66, 70, 72, 74, 78, 82, 84, 86, 90, 92, 98, 100, 106, 108, 110, 112, 114, 118, 124, 126])
```

## [ChainHash128/ModulusSteps3.lean](ProvenHashes/ChainHash128/ModulusSteps3.lean)

`ProvenHashes.ChainHash128.residue_step_3`

```lean
theorem residue_step_3 : residue_3 ^ 2 = residue_4 + modulus * (sparse [])
```

## [ChainHash128/ModulusSteps30.lean](ProvenHashes/ChainHash128/ModulusSteps30.lean)

`ProvenHashes.ChainHash128.residue_step_30`

```lean
theorem residue_step_30 : residue_30 ^ 2 = residue_31 + modulus * (sparse [2, 3, 4, 5, 10, 12, 22, 26, 32, 34, 36, 38, 44, 46, 50, 60, 64, 66, 72, 74, 76, 80, 82, 84, 90, 94, 96, 104, 106, 112, 114, 120, 124, 126])
```

## [ChainHash128/ModulusSteps31.lean](ProvenHashes/ChainHash128/ModulusSteps31.lean)

`ProvenHashes.ChainHash128.residue_step_31`

```lean
theorem residue_step_31 : residue_31 ^ 2 = residue_32 + modulus * (sparse [1, 2, 3, 8, 14, 20, 22, 24, 26, 28, 30, 32, 40, 42, 44, 46, 50, 56, 60, 62, 68, 74, 76, 78, 82, 84, 86, 88, 92, 94, 100, 102, 104, 108, 110, 122, 124])
```

## [ChainHash128/ModulusSteps32.lean](ProvenHashes/ChainHash128/ModulusSteps32.lean)

`ProvenHashes.ChainHash128.residue_step_32`

```lean
theorem residue_step_32 : residue_32 ^ 2 = residue_33 + modulus * (sparse [1, 3, 6, 8, 24, 26, 30, 32, 34, 40, 44, 46, 48, 52, 54, 56, 60, 64, 70, 72, 78, 82, 86, 96, 100, 102, 106, 118, 120, 122, 124])
```

## [ChainHash128/ModulusSteps33.lean](ProvenHashes/ChainHash128/ModulusSteps33.lean)

`ProvenHashes.ChainHash128.residue_step_33`

```lean
theorem residue_step_33 : residue_33 ^ 2 = residue_34 + modulus * (sparse [2, 3, 4, 5, 6, 16, 18, 24, 26, 32, 38, 40, 42, 46, 50, 52, 56, 58, 66, 74, 90, 96, 98, 108, 110, 114, 116, 118, 124, 126])
```

## [ChainHash128/ModulusSteps34.lean](ProvenHashes/ChainHash128/ModulusSteps34.lean)

`ProvenHashes.ChainHash128.residue_step_34`

```lean
theorem residue_step_34 : residue_34 ^ 2 = residue_35 + modulus * (sparse [2, 3, 4, 5, 6, 8, 12, 18, 22, 24, 28, 34, 40, 48, 54, 64, 68, 70, 72, 76, 78, 82, 88, 90, 94, 96, 104, 108, 110, 114, 118, 124, 126])
```

## [ChainHash128/ModulusSteps35.lean](ProvenHashes/ChainHash128/ModulusSteps35.lean)

`ProvenHashes.ChainHash128.residue_step_35`

```lean
theorem residue_step_35 : residue_35 ^ 2 = residue_36 + modulus * (sparse [2, 3, 4, 5, 10, 18, 20, 22, 40, 42, 44, 52, 54, 60, 74, 76, 78, 80, 82, 84, 88, 90, 96, 100, 104, 106, 108, 110, 112, 114, 120, 124, 126])
```

## [ChainHash128/ModulusSteps36.lean](ProvenHashes/ChainHash128/ModulusSteps36.lean)

`ProvenHashes.ChainHash128.residue_step_36`

```lean
theorem residue_step_36 : residue_36 ^ 2 = residue_37 + modulus * (sparse [1, 6, 20, 22, 24, 26, 30, 32, 40, 44, 46, 48, 60, 62, 64, 74, 76, 78, 82, 90, 104, 106, 110, 122])
```

## [ChainHash128/ModulusSteps37.lean](ProvenHashes/ChainHash128/ModulusSteps37.lean)

`ProvenHashes.ChainHash128.residue_step_37`

```lean
theorem residue_step_37 : residue_37 ^ 2 = residue_38 + modulus * (sparse [2, 4, 6, 10, 14, 20, 22, 26, 30, 32, 34, 40, 42, 44, 50, 54, 56, 60, 64, 66, 68, 76, 82, 84, 86, 88, 98, 106, 108, 116, 118, 120])
```

## [ChainHash128/ModulusSteps38.lean](ProvenHashes/ChainHash128/ModulusSteps38.lean)

`ProvenHashes.ChainHash128.residue_step_38`

```lean
theorem residue_step_38 : residue_38 ^ 2 = residue_39 + modulus * (sparse [0, 1, 2, 3, 5, 10, 12, 14, 16, 18, 20, 22, 26, 42, 46, 54, 56, 58, 62, 70, 72, 76, 82, 86, 88, 90, 96, 98, 102, 106, 110, 114, 118, 122, 124, 126])
```

## [ChainHash128/ModulusSteps39.lean](ProvenHashes/ChainHash128/ModulusSteps39.lean)

`ProvenHashes.ChainHash128.residue_step_39`

```lean
theorem residue_step_39 : residue_39 ^ 2 = residue_40 + modulus * (sparse [0, 2, 3, 5, 10, 14, 18, 24, 30, 32, 36, 46, 52, 54, 56, 58, 60, 62, 68, 70, 72, 76, 82, 84, 86, 90, 94, 98, 100, 102, 104, 106, 108, 110, 112, 114, 116, 118, 120, 124, 126])
```

## [ChainHash128/ModulusSteps4.lean](ProvenHashes/ChainHash128/ModulusSteps4.lean)

`ProvenHashes.ChainHash128.residue_step_4`

```lean
theorem residue_step_4 : residue_4 ^ 2 = residue_5 + modulus * (sparse [])
```

## [ChainHash128/ModulusSteps40.lean](ProvenHashes/ChainHash128/ModulusSteps40.lean)

`ProvenHashes.ChainHash128.residue_step_40`

```lean
theorem residue_step_40 : residue_40 ^ 2 = residue_41 + modulus * (sparse [2, 4, 6, 14, 18, 20, 22, 24, 28, 30, 36, 40, 42, 44, 46, 50, 52, 56, 58, 62, 64, 66, 70, 78, 84, 88, 92, 100, 104, 108, 118, 120])
```

## [ChainHash128/ModulusSteps41.lean](ProvenHashes/ChainHash128/ModulusSteps41.lean)

`ProvenHashes.ChainHash128.residue_step_41`

```lean
theorem residue_step_41 : residue_41 ^ 2 = residue_42 + modulus * (sparse [0, 1, 4, 5, 6, 10, 12, 16, 18, 24, 26, 30, 40, 48, 50, 52, 54, 58, 62, 70, 74, 76, 82, 84, 86, 88, 90, 94, 96, 100, 102, 104, 108, 110, 112, 114, 116, 122, 126])
```

## [ChainHash128/ModulusSteps42.lean](ProvenHashes/ChainHash128/ModulusSteps42.lean)

`ProvenHashes.ChainHash128.residue_step_42`

```lean
theorem residue_step_42 : residue_42 ^ 2 = residue_43 + modulus * (sparse [2, 3, 5, 8, 10, 14, 20, 22, 28, 32, 34, 40, 42, 46, 48, 52, 56, 58, 60, 82, 84, 86, 98, 108, 110, 112, 114, 116, 124, 126])
```

## [ChainHash128/ModulusSteps43.lean](ProvenHashes/ChainHash128/ModulusSteps43.lean)

`ProvenHashes.ChainHash128.residue_step_43`

```lean
theorem residue_step_43 : residue_43 ^ 2 = residue_44 + modulus * (sparse [0, 1, 2, 3, 4, 5, 6, 20, 24, 32, 38, 40, 42, 46, 50, 54, 56, 58, 60, 64, 70, 72, 76, 80, 82, 84, 90, 94, 96, 98, 100, 104, 108, 110, 114, 116, 118, 122, 124, 126])
```

## [ChainHash128/ModulusSteps44.lean](ProvenHashes/ChainHash128/ModulusSteps44.lean)

`ProvenHashes.ChainHash128.residue_step_44`

```lean
theorem residue_step_44 : residue_44 ^ 2 = residue_45 + modulus * (sparse [3, 5, 6, 12, 18, 20, 24, 30, 32, 34, 42, 46, 50, 52, 56, 60, 62, 64, 70, 72, 76, 78, 80, 84, 86, 88, 90, 92, 110, 112, 114, 120, 124, 126])
```

## [ChainHash128/ModulusSteps45.lean](ProvenHashes/ChainHash128/ModulusSteps45.lean)

`ProvenHashes.ChainHash128.residue_step_45`

```lean
theorem residue_step_45 : residue_45 ^ 2 = residue_46 + modulus * (sparse [1, 2, 3, 6, 10, 12, 18, 20, 32, 34, 38, 40, 44, 48, 50, 52, 60, 62, 64, 66, 68, 70, 72, 76, 80, 84, 94, 96, 98, 102, 104, 106, 108, 110, 116, 122, 124])
```

## [ChainHash128/ModulusSteps46.lean](ProvenHashes/ChainHash128/ModulusSteps46.lean)

`ProvenHashes.ChainHash128.residue_step_46`

```lean
theorem residue_step_46 : residue_46 ^ 2 = residue_47 + modulus * (sparse [1, 2, 3, 4, 12, 16, 22, 24, 30, 32, 34, 38, 40, 42, 46, 48, 54, 56, 62, 66, 68, 70, 72, 74, 80, 86, 98, 102, 112, 120, 122, 124])
```

## [ChainHash128/ModulusSteps47.lean](ProvenHashes/ChainHash128/ModulusSteps47.lean)

`ProvenHashes.ChainHash128.residue_step_47`

```lean
theorem residue_step_47 : residue_47 ^ 2 = residue_48 + modulus * (sparse [0, 1, 5, 6, 12, 14, 16, 26, 30, 36, 44, 56, 58, 60, 64, 70, 72, 76, 78, 80, 82, 84, 90, 92, 98, 108, 110, 112, 114, 116, 118, 122, 126])
```

## [ChainHash128/ModulusSteps48.lean](ProvenHashes/ChainHash128/ModulusSteps48.lean)

`ProvenHashes.ChainHash128.residue_step_48`

```lean
theorem residue_step_48 : residue_48 ^ 2 = residue_49 + modulus * (sparse [0, 1, 3, 5, 6, 8, 18, 34, 40, 46, 50, 56, 58, 60, 64, 66, 68, 72, 82, 84, 88, 90, 94, 98, 100, 104, 112, 114, 122, 124, 126])
```

## [ChainHash128/ModulusSteps49.lean](ProvenHashes/ChainHash128/ModulusSteps49.lean)

`ProvenHashes.ChainHash128.residue_step_49`

```lean
theorem residue_step_49 : residue_49 ^ 2 = residue_50 + modulus * (sparse [1, 3, 4, 5, 8, 10, 12, 14, 20, 22, 30, 36, 38, 42, 52, 60, 66, 68, 70, 72, 84, 86, 94, 96, 98, 100, 102, 108, 110, 112, 114, 118, 120, 122, 124, 126])
```

## [ChainHash128/ModulusSteps5.lean](ProvenHashes/ChainHash128/ModulusSteps5.lean)

`ProvenHashes.ChainHash128.residue_step_5`

```lean
theorem residue_step_5 : residue_5 ^ 2 = residue_6 + modulus * (sparse [])
```

## [ChainHash128/ModulusSteps50.lean](ProvenHashes/ChainHash128/ModulusSteps50.lean)

`ProvenHashes.ChainHash128.residue_step_50`

```lean
theorem residue_step_50 : residue_50 ^ 2 = residue_51 + modulus * (sparse [0, 3, 4, 10, 12, 14, 16, 20, 22, 24, 26, 30, 32, 40, 42, 46, 54, 58, 60, 62, 66, 70, 72, 76, 82, 84, 86, 94, 98, 104, 106, 112, 116, 118, 124])
```

## [ChainHash128/ModulusSteps51.lean](ProvenHashes/ChainHash128/ModulusSteps51.lean)

`ProvenHashes.ChainHash128.residue_step_51`

```lean
theorem residue_step_51 : residue_51 ^ 2 = residue_52 + modulus * (sparse [0, 2, 3, 4, 8, 10, 12, 14, 20, 30, 36, 40, 42, 46, 50, 52, 54, 58, 60, 62, 64, 70, 74, 84, 86, 94, 96, 100, 104, 106, 108, 112, 116, 118, 124])
```

## [ChainHash128/ModulusSteps52.lean](ProvenHashes/ChainHash128/ModulusSteps52.lean)

`ProvenHashes.ChainHash128.residue_step_52`

```lean
theorem residue_step_52 : residue_52 ^ 2 = residue_53 + modulus * (sparse [0, 4, 6, 10, 12, 22, 26, 28, 32, 34, 36, 40, 42, 44, 46, 54, 58, 60, 62, 66, 72, 76, 78, 82, 84, 90, 94, 96, 100, 102, 104, 106, 108, 112, 118])
```

## [ChainHash128/ModulusSteps53.lean](ProvenHashes/ChainHash128/ModulusSteps53.lean)

`ProvenHashes.ChainHash128.residue_step_53`

```lean
theorem residue_step_53 : residue_53 ^ 2 = residue_54 + modulus * (sparse [1, 2, 3, 4, 8, 10, 20, 24, 26, 44, 48, 50, 52, 60, 62, 64, 72, 76, 80, 82, 94, 102, 108, 122, 124])
```

## [ChainHash128/ModulusSteps54.lean](ProvenHashes/ChainHash128/ModulusSteps54.lean)

`ProvenHashes.ChainHash128.residue_step_54`

```lean
theorem residue_step_54 : residue_54 ^ 2 = residue_55 + modulus * (sparse [1, 2, 4, 6, 8, 10, 14, 16, 18, 24, 26, 30, 34, 40, 46, 48, 50, 52, 60, 62, 68, 74, 78, 84, 88, 102, 104, 108, 116, 118, 120, 122])
```

## [ChainHash128/ModulusSteps55.lean](ProvenHashes/ChainHash128/ModulusSteps55.lean)

`ProvenHashes.ChainHash128.residue_step_55`

```lean
theorem residue_step_55 : residue_55 ^ 2 = residue_56 + modulus * (sparse [1, 3, 4, 5, 6, 12, 20, 28, 30, 34, 40, 44, 48, 50, 54, 62, 64, 68, 76, 78, 82, 88, 94, 96, 100, 102, 104, 106, 108, 110, 114, 116, 120, 122, 124, 126])
```

## [ChainHash128/ModulusSteps56.lean](ProvenHashes/ChainHash128/ModulusSteps56.lean)

`ProvenHashes.ChainHash128.residue_step_56`

```lean
theorem residue_step_56 : residue_56 ^ 2 = residue_57 + modulus * (sparse [0, 1, 2, 3, 8, 14, 16, 20, 22, 24, 26, 30, 36, 40, 42, 52, 56, 60, 64, 66, 76, 82, 88, 92, 98, 116, 120, 122, 124])
```

## [ChainHash128/ModulusSteps57.lean](ProvenHashes/ChainHash128/ModulusSteps57.lean)

`ProvenHashes.ChainHash128.residue_step_57`

```lean
theorem residue_step_57 : residue_57 ^ 2 = residue_58 + modulus * (sparse [0, 1, 2, 5, 14, 16, 18, 20, 26, 28, 36, 40, 56, 58, 62, 64, 72, 80, 82, 100, 104, 106, 108, 112, 114, 116, 120, 122, 126])
```

## [ChainHash128/ModulusSteps58.lean](ProvenHashes/ChainHash128/ModulusSteps58.lean)

`ProvenHashes.ChainHash128.residue_step_58`

```lean
theorem residue_step_58 : residue_58 ^ 2 = residue_59 + modulus * (sparse [0, 10, 14, 18, 20, 30, 32, 34, 36, 38, 46, 50, 60, 68, 72, 74, 76, 80, 82, 84, 90, 92, 94, 100, 106, 110, 116, 120])
```

## [ChainHash128/ModulusSteps59.lean](ProvenHashes/ChainHash128/ModulusSteps59.lean)

`ProvenHashes.ChainHash128.residue_step_59`

```lean
theorem residue_step_59 : residue_59 ^ 2 = residue_60 + modulus * (sparse [4, 5, 6, 10, 16, 18, 20, 24, 26, 28, 30, 32, 36, 40, 42, 46, 48, 50, 52, 58, 60, 62, 66, 70, 76, 84, 88, 92, 94, 96, 98, 100, 112, 114, 116, 118, 120, 126])
```

## [ChainHash128/ModulusSteps6.lean](ProvenHashes/ChainHash128/ModulusSteps6.lean)

`ProvenHashes.ChainHash128.residue_step_6`

```lean
theorem residue_step_6 : residue_6 ^ 2 = residue_7 + modulus * (sparse [0])
```

## [ChainHash128/ModulusSteps60.lean](ProvenHashes/ChainHash128/ModulusSteps60.lean)

`ProvenHashes.ChainHash128.residue_step_60`

```lean
theorem residue_step_60 : residue_60 ^ 2 = residue_61 + modulus * (sparse [1, 2, 3, 10, 14, 16, 18, 28, 36, 38, 40, 42, 50, 54, 56, 58, 60, 66, 78, 82, 84, 86, 98, 100, 102, 104, 106, 118, 120, 122, 124])
```

## [ChainHash128/ModulusSteps61.lean](ProvenHashes/ChainHash128/ModulusSteps61.lean)

`ProvenHashes.ChainHash128.residue_step_61`

```lean
theorem residue_step_61 : residue_61 ^ 2 = residue_62 + modulus * (sparse [0, 2, 4, 5, 8, 12, 16, 18, 30, 32, 38, 46, 48, 50, 54, 56, 58, 64, 68, 70, 72, 74, 76, 78, 88, 90, 92, 94, 98, 100, 104, 108, 110, 114, 116, 118, 120, 126])
```

## [ChainHash128/ModulusSteps62.lean](ProvenHashes/ChainHash128/ModulusSteps62.lean)

`ProvenHashes.ChainHash128.residue_step_62`

```lean
theorem residue_step_62 : residue_62 ^ 2 = residue_63 + modulus * (sparse [0, 1, 4, 8, 10, 12, 16, 18, 20, 24, 28, 32, 34, 36, 38, 40, 42, 50, 52, 54, 56, 58, 60, 64, 66, 72, 84, 86, 90, 92, 100, 104, 108, 110, 112, 116, 118, 120, 122])
```

## [ChainHash128/ModulusSteps63.lean](ProvenHashes/ChainHash128/ModulusSteps63.lean)

`ProvenHashes.ChainHash128.residue_step_63`

```lean
theorem residue_step_63 : residue_63 ^ 2 = residue_64 + modulus * (sparse [1, 3, 4, 5, 14, 16, 30, 32, 42, 46, 48, 66, 68, 70, 74, 80, 82, 86, 90, 98, 100, 102, 108, 114, 116, 120, 122, 124, 126])
```

## [ChainHash128/ModulusSteps64.lean](ProvenHashes/ChainHash128/ModulusSteps64.lean)

`ProvenHashes.ChainHash128.residue_step_64`

```lean
theorem residue_step_64 : residue_64 ^ 2 = residue_65 + modulus * (sparse [0, 1, 3, 6, 8, 10, 14, 18, 24, 26, 38, 40, 44, 48, 50, 54, 58, 60, 66, 70, 74, 76, 78, 80, 82, 84, 86, 88, 96, 100, 106, 108, 112, 122, 124])
```

## [ChainHash128/ModulusSteps65.lean](ProvenHashes/ChainHash128/ModulusSteps65.lean)

`ProvenHashes.ChainHash128.residue_step_65`

```lean
theorem residue_step_65 : residue_65 ^ 2 = residue_66 + modulus * (sparse [0, 1, 2, 3, 12, 14, 16, 18, 22, 28, 30, 44, 48, 52, 54, 58, 60, 62, 66, 68, 74, 76, 78, 88, 90, 96, 100, 102, 104, 110, 116, 118, 120, 122, 124])
```

## [ChainHash128/ModulusSteps66.lean](ProvenHashes/ChainHash128/ModulusSteps66.lean)

`ProvenHashes.ChainHash128.residue_step_66`

```lean
theorem residue_step_66 : residue_66 ^ 2 = residue_67 + modulus * (sparse [2, 3, 5, 8, 12, 18, 20, 24, 26, 28, 30, 32, 34, 36, 38, 42, 50, 54, 56, 60, 62, 64, 72, 74, 82, 84, 86, 88, 90, 92, 96, 100, 108, 110, 114, 124, 126])
```

## [ChainHash128/ModulusSteps67.lean](ProvenHashes/ChainHash128/ModulusSteps67.lean)

`ProvenHashes.ChainHash128.residue_step_67`

```lean
theorem residue_step_67 : residue_67 ^ 2 = residue_68 + modulus * (sparse [1, 2, 3, 4, 5, 6, 8, 10, 12, 14, 18, 20, 22, 30, 32, 34, 36, 38, 40, 42, 46, 52, 56, 60, 62, 70, 74, 78, 80, 84, 86, 90, 94, 96, 100, 106, 112, 114, 122, 124, 126])
```

## [ChainHash128/ModulusSteps68.lean](ProvenHashes/ChainHash128/ModulusSteps68.lean)

`ProvenHashes.ChainHash128.residue_step_68`

```lean
theorem residue_step_68 : residue_68 ^ 2 = residue_69 + modulus * (sparse [1, 5, 6, 8, 10, 12, 14, 20, 22, 24, 26, 28, 30, 40, 56, 58, 60, 62, 64, 72, 78, 84, 92, 102, 110, 112, 114, 116, 118, 120, 122, 126])
```

## [ChainHash128/ModulusSteps69.lean](ProvenHashes/ChainHash128/ModulusSteps69.lean)

`ProvenHashes.ChainHash128.residue_step_69`

```lean
theorem residue_step_69 : residue_69 ^ 2 = residue_70 + modulus * (sparse [0, 1, 3, 6, 10, 12, 14, 16, 18, 20, 28, 32, 44, 52, 54, 58, 60, 68, 70, 76, 78, 80, 88, 90, 92, 94, 96, 98, 100, 102, 108, 116, 120, 122, 124])
```

## [ChainHash128/ModulusSteps7.lean](ProvenHashes/ChainHash128/ModulusSteps7.lean)

`ProvenHashes.ChainHash128.residue_step_7`

```lean
theorem residue_step_7 : residue_7 ^ 2 = residue_8 + modulus * (sparse [])
```

## [ChainHash128/ModulusSteps70.lean](ProvenHashes/ChainHash128/ModulusSteps70.lean)

`ProvenHashes.ChainHash128.residue_step_70`

```lean
theorem residue_step_70 : residue_70 ^ 2 = residue_71 + modulus * (sparse [0, 1, 2, 3, 4, 5, 6, 10, 12, 14, 20, 22, 24, 30, 34, 38, 40, 42, 46, 48, 50, 54, 56, 58, 60, 64, 72, 82, 86, 92, 96, 100, 102, 106, 112, 114, 116, 120, 122, 124, 126])
```

## [ChainHash128/ModulusSteps71.lean](ProvenHashes/ChainHash128/ModulusSteps71.lean)

`ProvenHashes.ChainHash128.residue_step_71`

```lean
theorem residue_step_71 : residue_71 ^ 2 = residue_72 + modulus * (sparse [0, 1, 6, 12, 14, 16, 18, 20, 24, 28, 30, 36, 38, 40, 44, 46, 50, 52, 56, 60, 66, 68, 70, 74, 76, 88, 90, 92, 96, 102, 104, 106, 108, 110, 112, 120, 122])
```

## [ChainHash128/ModulusSteps72.lean](ProvenHashes/ChainHash128/ModulusSteps72.lean)

`ProvenHashes.ChainHash128.residue_step_72`

```lean
theorem residue_step_72 : residue_72 ^ 2 = residue_73 + modulus * (sparse [0, 3, 4, 5, 8, 10, 12, 14, 16, 18, 24, 32, 34, 38, 44, 50, 52, 54, 58, 60, 62, 64, 68, 70, 72, 80, 82, 84, 86, 96, 100, 102, 104, 106, 108, 110, 114, 118, 124, 126])
```

## [ChainHash128/ModulusSteps73.lean](ProvenHashes/ChainHash128/ModulusSteps73.lean)

`ProvenHashes.ChainHash128.residue_step_73`

```lean
theorem residue_step_73 : residue_73 ^ 2 = residue_74 + modulus * (sparse [0, 3, 4, 5, 6, 12, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 48, 50, 54, 56, 58, 64, 66, 68, 72, 74, 80, 82, 98, 100, 104, 106, 110, 114, 116, 124, 126])
```

## [ChainHash128/ModulusSteps74.lean](ProvenHashes/ChainHash128/ModulusSteps74.lean)

`ProvenHashes.ChainHash128.residue_step_74`

```lean
theorem residue_step_74 : residue_74 ^ 2 = residue_75 + modulus * (sparse [1, 3, 4, 5, 6, 8, 10, 14, 16, 30, 32, 36, 38, 40, 46, 50, 68, 70, 72, 74, 76, 84, 96, 98, 102, 108, 112, 114, 118, 120, 122, 124, 126])
```

## [ChainHash128/ModulusSteps75.lean](ProvenHashes/ChainHash128/ModulusSteps75.lean)

`ProvenHashes.ChainHash128.residue_step_75`

```lean
theorem residue_step_75 : residue_75 ^ 2 = residue_76 + modulus * (sparse [3, 8, 10, 14, 18, 28, 30, 34, 38, 42, 44, 54, 60, 64, 66, 70, 72, 76, 80, 82, 92, 98, 104, 116, 118, 120, 124])
```

## [ChainHash128/ModulusSteps76.lean](ProvenHashes/ChainHash128/ModulusSteps76.lean)

`ProvenHashes.ChainHash128.residue_step_76`

```lean
theorem residue_step_76 : residue_76 ^ 2 = residue_77 + modulus * (sparse [0, 2, 3, 4, 5, 8, 12, 20, 24, 28, 30, 34, 36, 40, 44, 46, 50, 52, 58, 60, 68, 76, 80, 94, 100, 104, 106, 110, 114, 116, 118, 120, 124, 126])
```

## [ChainHash128/ModulusSteps77.lean](ProvenHashes/ChainHash128/ModulusSteps77.lean)

`ProvenHashes.ChainHash128.residue_step_77`

```lean
theorem residue_step_77 : residue_77 ^ 2 = residue_78 + modulus * (sparse [2, 6, 10, 12, 20, 22, 26, 34, 38, 44, 46, 48, 60, 62, 68, 72, 80, 82, 96, 98, 100, 102, 110, 116, 118, 120])
```

## [ChainHash128/ModulusSteps78.lean](ProvenHashes/ChainHash128/ModulusSteps78.lean)

`ProvenHashes.ChainHash128.residue_step_78`

```lean
theorem residue_step_78 : residue_78 ^ 2 = residue_79 + modulus * (sparse [1, 5, 6, 8, 12, 16, 18, 20, 22, 30, 32, 34, 38, 40, 44, 46, 48, 50, 52, 66, 70, 74, 82, 86, 88, 90, 92, 94, 100, 104, 110, 114, 118, 122, 126])
```

## [ChainHash128/ModulusSteps79.lean](ProvenHashes/ChainHash128/ModulusSteps79.lean)

`ProvenHashes.ChainHash128.residue_step_79`

```lean
theorem residue_step_79 : residue_79 ^ 2 = residue_80 + modulus * (sparse [1, 5, 6, 14, 16, 18, 20, 22, 24, 26, 28, 34, 38, 44, 46, 48, 54, 60, 64, 66, 68, 70, 72, 82, 86, 88, 96, 100, 102, 106, 108, 110, 114, 118, 120, 122, 126])
```

## [ChainHash128/ModulusSteps8.lean](ProvenHashes/ChainHash128/ModulusSteps8.lean)

`ProvenHashes.ChainHash128.residue_step_8`

```lean
theorem residue_step_8 : residue_8 ^ 2 = residue_9 + modulus * (sparse [])
```

## [ChainHash128/ModulusSteps80.lean](ProvenHashes/ChainHash128/ModulusSteps80.lean)

`ProvenHashes.ChainHash128.residue_step_80`

```lean
theorem residue_step_80 : residue_80 ^ 2 = residue_81 + modulus * (sparse [0, 1, 2, 3, 4, 8, 10, 12, 16, 22, 26, 30, 36, 38, 40, 44, 46, 52, 56, 58, 62, 66, 72, 74, 80, 84, 88, 92, 94, 96, 98, 106, 110, 112, 118, 120, 122, 124])
```

## [ChainHash128/ModulusSteps81.lean](ProvenHashes/ChainHash128/ModulusSteps81.lean)

`ProvenHashes.ChainHash128.residue_step_81`

```lean
theorem residue_step_81 : residue_81 ^ 2 = residue_82 + modulus * (sparse [2, 3, 5, 6, 8, 10, 16, 22, 28, 30, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 66, 68, 72, 74, 76, 78, 82, 86, 88, 92, 94, 100, 104, 106, 108, 114, 118, 124, 126])
```

## [ChainHash128/ModulusSteps82.lean](ProvenHashes/ChainHash128/ModulusSteps82.lean)

`ProvenHashes.ChainHash128.residue_step_82`

```lean
theorem residue_step_82 : residue_82 ^ 2 = residue_83 + modulus * (sparse [2, 5, 8, 10, 12, 16, 24, 26, 28, 34, 42, 46, 48, 52, 56, 64, 70, 72, 82, 88, 90, 92, 94, 96, 98, 104, 108, 110, 114, 120, 126])
```

## [ChainHash128/ModulusSteps83.lean](ProvenHashes/ChainHash128/ModulusSteps83.lean)

`ProvenHashes.ChainHash128.residue_step_83`

```lean
theorem residue_step_83 : residue_83 ^ 2 = residue_84 + modulus * (sparse [0, 2, 4, 16, 18, 24, 26, 30, 32, 36, 38, 44, 52, 54, 58, 60, 64, 72, 74, 78, 80, 84, 90, 96, 100, 106, 112, 116])
```

## [ChainHash128/ModulusSteps84.lean](ProvenHashes/ChainHash128/ModulusSteps84.lean)

`ProvenHashes.ChainHash128.residue_step_84`

```lean
theorem residue_step_84 : residue_84 ^ 2 = residue_85 + modulus * (sparse [0, 3, 6, 8, 14, 16, 18, 22, 24, 28, 46, 52, 60, 64, 68, 74, 76, 78, 84, 92, 106, 110, 112, 118, 120, 124])
```

## [ChainHash128/ModulusSteps85.lean](ProvenHashes/ChainHash128/ModulusSteps85.lean)

`ProvenHashes.ChainHash128.residue_step_85`

```lean
theorem residue_step_85 : residue_85 ^ 2 = residue_86 + modulus * (sparse [2, 3, 4, 5, 6, 10, 12, 14, 20, 24, 26, 30, 32, 34, 38, 40, 54, 56, 58, 60, 64, 70, 72, 76, 86, 94, 100, 106, 108, 114, 116, 120, 124, 126])
```

## [ChainHash128/ModulusSteps86.lean](ProvenHashes/ChainHash128/ModulusSteps86.lean)

`ProvenHashes.ChainHash128.residue_step_86`

```lean
theorem residue_step_86 : residue_86 ^ 2 = residue_87 + modulus * (sparse [0, 1, 4, 6, 8, 18, 20, 28, 30, 32, 38, 44, 46, 58, 62, 64, 72, 76, 84, 90, 92, 98, 100, 106, 118, 122])
```

## [ChainHash128/ModulusSteps87.lean](ProvenHashes/ChainHash128/ModulusSteps87.lean)

`ProvenHashes.ChainHash128.residue_step_87`

```lean
theorem residue_step_87 : residue_87 ^ 2 = residue_88 + modulus * (sparse [1, 3, 4, 8, 10, 12, 14, 16, 18, 24, 26, 28, 30, 38, 40, 42, 44, 58, 64, 66, 68, 74, 76, 80, 82, 84, 92, 98, 100, 110, 116, 118, 120, 122, 124])
```

## [ChainHash128/ModulusSteps88.lean](ProvenHashes/ChainHash128/ModulusSteps88.lean)

`ProvenHashes.ChainHash128.residue_step_88`

```lean
theorem residue_step_88 : residue_88 ^ 2 = residue_89 + modulus * (sparse [4, 5, 6, 10, 14, 16, 18, 26, 28, 42, 44, 46, 50, 54, 56, 58, 68, 72, 74, 80, 82, 84, 86, 92, 94, 108, 110, 114, 120, 126])
```

## [ChainHash128/ModulusSteps89.lean](ProvenHashes/ChainHash128/ModulusSteps89.lean)

`ProvenHashes.ChainHash128.residue_step_89`

```lean
theorem residue_step_89 : residue_89 ^ 2 = residue_90 + modulus * (sparse [0, 2, 3, 4, 8, 10, 16, 18, 20, 24, 28, 30, 36, 38, 40, 42, 44, 50, 54, 60, 62, 68, 70, 72, 74, 76, 90, 94, 100, 104, 106, 108, 112, 116, 120, 124])
```

## [ChainHash128/ModulusSteps9.lean](ProvenHashes/ChainHash128/ModulusSteps9.lean)

`ProvenHashes.ChainHash128.residue_step_9`

```lean
theorem residue_step_9 : residue_9 ^ 2 = residue_10 + modulus * (sparse [])
```

## [ChainHash128/ModulusSteps90.lean](ProvenHashes/ChainHash128/ModulusSteps90.lean)

`ProvenHashes.ChainHash128.residue_step_90`

```lean
theorem residue_step_90 : residue_90 ^ 2 = residue_91 + modulus * (sparse [1, 4, 5, 6, 8, 12, 14, 16, 18, 28, 30, 32, 34, 38, 44, 48, 54, 62, 64, 66, 68, 76, 80, 82, 84, 90, 94, 96, 100, 102, 106, 110, 112, 114, 118, 120, 122, 126])
```

## [ChainHash128/ModulusSteps91.lean](ProvenHashes/ChainHash128/ModulusSteps91.lean)

`ProvenHashes.ChainHash128.residue_step_91`

```lean
theorem residue_step_91 : residue_91 ^ 2 = residue_92 + modulus * (sparse [1, 2, 6, 14, 18, 22, 26, 34, 36, 40, 42, 44, 46, 50, 52, 56, 62, 72, 84, 88, 90, 94, 96, 100, 102, 106, 108, 118, 120, 122])
```

## [ChainHash128/ModulusSteps92.lean](ProvenHashes/ChainHash128/ModulusSteps92.lean)

`ProvenHashes.ChainHash128.residue_step_92`

```lean
theorem residue_step_92 : residue_92 ^ 2 = residue_93 + modulus * (sparse [1, 3, 4, 5, 10, 18, 30, 36, 42, 44, 48, 50, 56, 60, 76, 80, 84, 92, 96, 98, 102, 104, 108, 110, 112, 114, 116, 118, 122, 124, 126])
```

## [ChainHash128/ModulusSteps93.lean](ProvenHashes/ChainHash128/ModulusSteps93.lean)

`ProvenHashes.ChainHash128.residue_step_93`

```lean
theorem residue_step_93 : residue_93 ^ 2 = residue_94 + modulus * (sparse [4, 5, 6, 12, 20, 26, 28, 34, 36, 38, 42, 44, 46, 52, 54, 58, 60, 66, 68, 72, 76, 84, 98, 108, 114, 116, 126])
```

## [ChainHash128/ModulusSteps94.lean](ProvenHashes/ChainHash128/ModulusSteps94.lean)

`ProvenHashes.ChainHash128.residue_step_94`

```lean
theorem residue_step_94 : residue_94 ^ 2 = residue_95 + modulus * (sparse [2, 4, 5, 10, 12, 20, 22, 24, 26, 28, 30, 38, 40, 42, 44, 52, 54, 64, 68, 70, 82, 90, 96, 100, 106, 108, 112, 114, 116, 118, 120, 126])
```

## [ChainHash128/ModulusSteps95.lean](ProvenHashes/ChainHash128/ModulusSteps95.lean)

`ProvenHashes.ChainHash128.residue_step_95`

```lean
theorem residue_step_95 : residue_95 ^ 2 = residue_96 + modulus * (sparse [1, 2, 3, 8, 10, 16, 20, 22, 24, 26, 28, 38, 50, 52, 54, 56, 60, 64, 74, 78, 84, 90, 96, 104, 106, 116, 118, 122, 124])
```

## [ChainHash128/ModulusSteps96.lean](ProvenHashes/ChainHash128/ModulusSteps96.lean)

`ProvenHashes.ChainHash128.residue_step_96`

```lean
theorem residue_step_96 : residue_96 ^ 2 = residue_97 + modulus * (sparse [2, 3, 6, 12, 14, 22, 24, 30, 34, 36, 48, 52, 60, 64, 76, 78, 80, 82, 84, 86, 88, 92, 94, 98, 106, 108, 110, 124])
```

## [ChainHash128/ModulusSteps97.lean](ProvenHashes/ChainHash128/ModulusSteps97.lean)

`ProvenHashes.ChainHash128.residue_step_97`

```lean
theorem residue_step_97 : residue_97 ^ 2 = residue_98 + modulus * (sparse [0, 1, 2, 6, 8, 12, 14, 24, 26, 28, 30, 32, 34, 40, 48, 54, 64, 68, 72, 74, 76, 82, 86, 90, 92, 94, 96, 98, 102, 104, 106, 108, 112, 122])
```

## [ChainHash128/ModulusSteps98.lean](ProvenHashes/ChainHash128/ModulusSteps98.lean)

`ProvenHashes.ChainHash128.residue_step_98`

```lean
theorem residue_step_98 : residue_98 ^ 2 = residue_99 + modulus * (sparse [2, 4, 10, 14, 16, 18, 24, 26, 28, 30, 34, 46, 48, 50, 52, 54, 62, 64, 68, 72, 74, 76, 84, 86, 88, 94, 100, 102, 108, 110, 118, 120])
```

## [ChainHash128/ModulusSteps99.lean](ProvenHashes/ChainHash128/ModulusSteps99.lean)

`ProvenHashes.ChainHash128.residue_step_99`

```lean
theorem residue_step_99 : residue_99 ^ 2 = residue_100 + modulus * (sparse [0, 1, 2, 4, 5, 8, 12, 14, 18, 20, 24, 26, 30, 34, 38, 40, 42, 46, 50, 52, 54, 56, 58, 64, 68, 72, 78, 86, 94, 96, 102, 104, 106, 108, 110, 114, 122, 126])
```

## [ChainHash128/ReferenceChainHash.lean](ProvenHashes/ChainHash128/ReferenceChainHash.lean)

`ProvenHashes.ChainHash128.wordStream_matches`

```lean
theorem wordStream_matches (m : Message) (k : BlockKey) :
    (wordStream m k).map (fun ab => (fieldRepr ab.1, fieldRepr ab.2)) = stream fieldRepr m k
```

`ProvenHashes.ChainHash128.wordAdd_matches`

```lean
theorem wordAdd_matches (a b : Word 128) :
    fieldRepr (wordAdd a b) = integerTwist fieldIntegerEquiv (fieldRepr b) (fieldRepr a)
```

`ProvenHashes.ChainHash128.referenceHash_matches`

```lean
theorem referenceHash_matches (k : Key41) (m : Message) : referenceHash k m = chainHash k m
```

`ProvenHashes.ChainHash128.reference_collision_bound`

```lean
theorem reference_collision_bound (L : ℕ) (hL : 16 * L + 511 < 2 ^ 128)
    (m m' : Message) (hm : m.length ≤ 16 * L) (hm' : m'.length ≤ 16 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key41 => referenceHash k m = referenceHash k m') ≤
      ((max 1 ((L + 31) / 32) + 2 : ℕ) : ℚ≥0) / (2 : ℚ≥0) ^ 128
```

## [ChainHash128/ReferenceOperations.lean](ProvenHashes/ChainHash128/ReferenceOperations.lean)

`ProvenHashes.ChainHash128.fieldRepr_wordMul`

```lean
theorem fieldRepr_wordMul (a b : Word 128) :
    fieldRepr (wordMul a b) = fieldRepr a * fieldRepr b
```

`ProvenHashes.ChainHash128.wordChain5_matches`

```lean
theorem wordChain5_matches (c : Fin 5 → Word 128) (v : Word 128) :
    fieldRepr (wordChain5 c v) = chain5 (fun i => fieldRepr (c i)) (fieldRepr v)
```

`ProvenHashes.ChainHash128.lowWord_add`

```lean
theorem lowWord_add (p q : BitsPolynomial) : lowWord (p + q) = lowWord p + lowWord q
```

`ProvenHashes.ChainHash128.highWord_add`

```lean
theorem highWord_add (p q : BitsPolynomial) : highWord (p + q) = highWord p + highWord q
```

`ProvenHashes.ChainHash128.lengthMask_low`

```lean
theorem lengthMask_low (n : ℕ) : lowWord (lengthMask n) = lengthWord n
```

`ProvenHashes.ChainHash128.lengthMask_high`

```lean
theorem lengthMask_high (n : ℕ) : highWord (lengthMask n) = lengthWord n
```

`ProvenHashes.ChainHash128.wordDigest_matches`

```lean
theorem wordDigest_matches (m : Message) (k : BlockKey) (t : ℕ) :
    (lowWord (rawDigest m k t), highWord (rawDigest m k t)) = wordDigest m k t
```

`ProvenHashes.ChainHash128.wordFold_matches`

```lean
theorem wordFold_matches (u y : Word 128) (s : List (Word 128 × Word 128)) (p : Word 128) :
    fieldRepr (wordFold u y s p) =
      (s.map fun ab => (fieldRepr ab.1, fieldRepr ab.2)).foldl
        (fun p ab => ab.1 + (ab.2 + fieldRepr y) * (p + fieldRepr u)) (fieldRepr p)
```

## [ChainHash128/SeededPH.lean](ProvenHashes/ChainHash128/SeededPH.lean)

`ProvenHashes.ChainHash128.ModelA.eval_phPoly`

```lean
theorem eval_phPoly {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m : Slot → F) (s : F) : (phPoly a m).eval s = ph a m s
```

`ProvenHashes.ChainHash128.ModelA.partnerExponent_injective`

```lean
theorem partnerExponent_injective : Function.Injective (fun j => exponent (partner j))
```

`ProvenHashes.ChainHash128.ModelA.phPoly_difference`

```lean
theorem phPoly_difference {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m m' : Slot → F) (t : F) :
    phPoly a m - phPoly a m' - C t = differencePoly a m m' t
```

`ProvenHashes.ChainHash128.ModelA.differencePoly_coeff`

```lean
theorem differencePoly_coeff {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m m' : Slot → F) (t : F) (j : Slot) (hj : j.1 ∈ a) :
    (differencePoly a m m' t).coeff (exponent (partner j)) = m j - m' j
```

`ProvenHashes.ChainHash128.ModelA.differencePoly_nonzero_degree`

```lean
theorem differencePoly_nonzero_degree {F : Type*} [Field F]
    (a : Finset (Fin 16)) (m m' : Slot → F) (t : F) (D : ℕ)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j)
    (hD : ∀ j : Slot, j.1 ∈ a → m j ≠ m' j → exponent (partner j) ≤ D) :
    differencePoly a m m' t ≠ 0 ∧ (differencePoly a m m' t).natDegree ≤ D
```

`ProvenHashes.ChainHash128.ModelA.polynomial_probability_le`

```lean
theorem polynomial_probability_le {F : Type*} [Field F] [Fintype F]
    (p : F[X]) (hp : p ≠ 0) (D : ℕ) (hd : p.natDegree ≤ D) :
    uniformProb (fun s : F => p.eval s = 0) ≤ (D : ℚ≥0) / Fintype.card F
```

`ProvenHashes.ChainHash128.ModelA.ph_equal_groups_bound`

```lean
theorem ph_equal_groups_bound {F : Type*} [Field F] [Fintype F]
    (a : Finset (Fin 16)) (m m' : Slot → F) (t : F) (D : ℕ)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j)
    (hD : ∀ j : Slot, j.1 ∈ a → m j ≠ m' j → exponent (partner j) ≤ D) :
    uniformProb (fun s : F => ph a m s - ph a m' s = t) ≤
      (D : ℚ≥0) / Fintype.card F
```

`ProvenHashes.ChainHash128.ModelA.pairPoly_monic_degree`

```lean
theorem pairPoly_monic_degree {F : Type*} [Field F] (m : Slot → F) (i : Fin 16) :
    (pairPoly m i).Monic ∧
      (pairPoly m i).natDegree = 8 * (i.val / 2) + 2 * (i.val % 2) + 4
```

`ProvenHashes.ChainHash128.ModelA.phPoly_group_degree`

```lean
theorem phPoly_group_degree {F : Type*} [Field F] (g : ℕ) (hg : 0 < g)
    (hg8 : g ≤ 8) (m : Slot → F) :
    (phPoly (groupPairs g) m).natDegree = 8 * g - 2 ∧
      (phPoly (groupPairs g) m).Monic
```

`ProvenHashes.ChainHash128.ModelA.ph_unequal_groups_polynomial`

```lean
theorem ph_unequal_groups_polynomial {F : Type*} [Field F]
    (g h : ℕ) (hgh : g < h) (hh : h ≤ 8) (m m' : Slot → F) (t : F) :
    let p := phPoly (groupPairs g) m - phPoly (groupPairs h) m' - C t
    p ≠ 0 ∧ p.natDegree = 8 * h - 2
```

`ProvenHashes.ChainHash128.ModelA.ph_unequal_groups_bound`

```lean
theorem ph_unequal_groups_bound {F : Type*} [Field F] [Fintype F]
    (g h : ℕ) (hgh : g < h) (hh : h ≤ 8) (m m' : Slot → F) (t : F) :
    uniformProb (fun s : F => ph (groupPairs g) m s - ph (groupPairs h) m' s = t) ≤
      ((8 * h - 2 : ℕ) : ℚ≥0) / Fintype.card F
```

`ProvenHashes.ChainHash128.ModelA.cubic_linear_probability`

```lean
theorem cubic_linear_probability {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    (a b : F) (hne : a ≠ 0 ∨ b ≠ 0) :
    uniformProb (fun s : F => s ^ 3 * (a + b * s) = 0) ≤
      ((if b = 0 then 1 else 2 : ℕ) : ℚ≥0) / Fintype.card F
```

`ProvenHashes.ChainHash128.ModelA.ph_small_bound`

```lean
theorem ph_small_bound {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    (m m' : Slot → F)
    (hpad : ∀ i : Fin 16, i.val < 2 → m (i, true) = 0 ∧ m' (i, true) = 0)
    (hne : m (0, false) ≠ m' (0, false) ∨ m (1, false) ≠ m' (1, false)) :
    uniformProb (fun s : F => ph (groupPairs 1) m s = ph (groupPairs 1) m' s) ≤
      ((if m (1, false) = m' (1, false) then 1 else 2 : ℕ) : ℚ≥0) / Fintype.card F
```

`ProvenHashes.ChainHash128.ModelA.ph_nonzero_target_bound`

```lean
theorem ph_nonzero_target_bound {F : Type*} [Field F] [Fintype F]
    (g h G : ℕ) (hg : g ≤ G) (hh : h ≤ G) (hG : 0 < G) (hG8 : G ≤ 8)
    (m m' : Slot → F) (t : F) (ht : t ≠ 0) :
    uniformProb (fun s : F => ph (groupPairs g) m s - ph (groupPairs h) m' s = t) ≤
      ((8 * G - 2 : ℕ) : ℚ≥0) / Fintype.card F
```

## [ChainHash128/Stream.lean](ProvenHashes/ChainHash128/Stream.lean)

`ProvenHashes.ChainHash128.lengthMask_injective`

```lean
theorem lengthMask_injective {n n' : ℕ} (hn : n < 2 ^ 128) (hn' : n' < 2 ^ 128)
    (h : lengthMask n = lengthMask n') : n = n'
```

`ProvenHashes.ChainHash128.rawStream_length`

```lean
theorem rawStream_length (m : Message) (k : BlockKey) :
    (rawStream m k).length = blockCount m
```

`ProvenHashes.ChainHash128.rawStream_eq_digest`

```lean
theorem rawStream_eq_digest (m m' : Message) (k : BlockKey)
    (h : rawStream m k = rawStream m' k) (t : ℕ)
    (ht : t < blockCount m) (ht' : t < blockCount m') :
    rawDigest m k t = rawDigest m' k t
```

`ProvenHashes.ChainHash128.rawStream_different_counts`

```lean
theorem rawStream_different_counts (m m' : Message) (k : BlockKey)
    (h : blockCount m ≠ blockCount m') : rawStream m k ≠ rawStream m' k
```

`ProvenHashes.ChainHash128.rawStream_equal_length_bound`

```lean
theorem rawStream_equal_length_bound (m m' : Message)
    (hlen : m.length = m'.length) (hne : m ≠ m') :
    uniformProb (fun k => rawStream m k = rawStream m' k) ≤ 1 / (2 : ℚ≥0) ^ 128
```

`ProvenHashes.ChainHash128.rawStream_different_length_bound`

```lean
theorem rawStream_different_length_bound (m m' : Message)
    (hm : m.length < 2 ^ 128) (hm' : m'.length < 2 ^ 128)
    (hlen : m.length ≠ m'.length) (hc : blockCount m = blockCount m') :
    uniformProb (fun k => rawStream m k = rawStream m' k) ≤ 1 / (2 : ℚ≥0) ^ 128
```

`ProvenHashes.ChainHash128.rawStream_collision_bound`

```lean
theorem rawStream_collision_bound (m m' : Message)
    (hm : m.length < 2 ^ 128) (hm' : m'.length < 2 ^ 128) (hne : m ≠ m') :
    uniformProb (fun k => rawStream m k = rawStream m' k) ≤ 1 / (2 : ℚ≥0) ^ 128
```

## [ChainHash128/Strided.lean](ProvenHashes/ChainHash128/Strided.lean)

`ProvenHashes.ChainHash128.Strided.modulus_irreducible`

```lean
theorem modulus_irreducible : Irreducible
    (Polynomial.X ^ 128 + (Polynomial.X ^ 7 + Polynomial.X ^ 2 + Polynomial.X + 1) :
      Polynomial (ZMod 2))
```

`ProvenHashes.ChainHash128.Strided.field_card`

```lean
theorem field_card : Fintype.card F = 2 ^ 128
```

`ProvenHashes.ChainHash128.Strided.block_difference_bound`

```lean
theorem block_difference_bound (s : Finset (Fin 16))
    (m m' : Fin 16 × Bool → Word 128)
    (hne : ∃ i ∈ s, ∃ b, m (i,b) ≠ m' (i,b)) (C : BitsPolynomial) :
    uniformProb (fun k : BlockKey => clnh s m k - clnh s m' k = C) ≤
      1 / (2 : ℚ≥0)^128
```

`ProvenHashes.ChainHash128.Strided.raw_block_degree`

```lean
theorem raw_block_degree (s : Finset (Fin 16)) (m k : Fin 16 × Bool → Word 128) :
    (clnh s m k).natDegree ≤ 254
```

`ProvenHashes.ChainHash128.Strided.recurrence_injective`

```lean
theorem recurrence_injective : Function.Injective (@Recurrence.keyPolynomial F _)
```

`ProvenHashes.ChainHash128.Strided.twist_bijective`

```lean
theorem twist_bijective (tau : F) :
    Function.Bijective (integerTwist fieldIntegerEquiv tau)
```

`ProvenHashes.ChainHash128.Strided.finalizer_fivewise`

```lean
theorem finalizer_fivewise (v : Fin 5 → F) (hv : Function.Injective v) (r : Fin 5 → F) :
    uniformProb (fun c : Fin 5 → F => (fun i => chain5 c (v i)) = r) =
      1 / ((2 : ℚ≥0)^128)^5
```

`ProvenHashes.ChainHash128.Strided.outputBytes_length`

```lean
theorem outputBytes_length (w : Word 128) : (outputBytes w).length = 16
```

`ProvenHashes.ChainHash128.Strided.outputBytes_decode`

```lean
theorem outputBytes_decode (w : Word 128) : wordAt (outputBytes w) 0 = w
```

`ProvenHashes.ChainHash128.Strided.outputBytes_injective`

```lean
theorem outputBytes_injective : Function.Injective outputBytes
```

`ProvenHashes.ChainHash128.Strided.ideal_bound`

```lean
theorem ideal_bound (n : ℕ) (m m' : Message)
    (hm : m.length < 2^128) (hm' : m'.length < 2^128) (hne : m ≠ m')
    (hn : blockCount m ≤ n) (hn' : blockCount m' ≤ n) :
    uniformProb (fun k : Key41 => referenceHash k m = referenceHash k m') ≤
      min 1 (((n+2 : ℕ) : ℚ≥0) / 2^128)
```

`ProvenHashes.ChainHash128.Strided.ideal_bound_bytes`

```lean
theorem ideal_bound_bytes (n : ℕ) (m m' : List UInt8)
    (hm : m.length < 2^128) (hm' : m'.length < 2^128) (hne : m ≠ m')
    (hn : max 1 ((m.length+511)/512) ≤ n)
    (hn' : max 1 ((m'.length+511)/512) ≤ n) :
    uniformProb (fun k : Key41 => hashBytes k m = hashBytes k m') ≤
      min 1 (((n+2 : ℕ) : ℚ≥0) / 2^128)
```

`ProvenHashes.ChainHash128.Strided.modelA_bound_bytes`

```lean
theorem modelA_bound_bytes (L : ℕ) (hL : 0 < L) (hcap : 16*L < 2^128)
    (m m' : List UInt8) (hm : m.length ≤ 16*L) (hm' : m'.length ≤ 16*L)
    (hne : m ≠ m') :
    uniformProb (fun k : ModelA.Key =>
      hashBytes (ModelA.expandedKey k) m = hashBytes (ModelA.expandedKey k) m') ≤
      ModelA.epsilonAtMost L
```

`ProvenHashes.ChainHash128.Strided.modelA_coarse_bound`

```lean
theorem modelA_coarse_bound (n : ℕ) (m m' : Message)
    (hm : m.length < 2^128) (hm' : m'.length < 2^128) (hne : m ≠ m')
    (hn : blockCount m ≤ n) (hn' : blockCount m' ≤ n) :
    uniformProb (fun k : ModelA.Key => ModelA.hash k m = ModelA.hash k m') ≤
      min 1 (((n+63 : ℕ) : ℚ≥0) / 2^128)
```

`ProvenHashes.ChainHash128.Strided.ideal_score_numerator`

```lean
theorem ideal_score_numerator (L : ℕ) (hL : 0 < L) :
    max 1 ((L+31)/32) + 2 ≤ 3*L
```

`ProvenHashes.ChainHash128.Strided.modelA_score_numerator`

```lean
theorem modelA_score_numerator (L : ℕ) (hL : 0 < L) :
    ModelA.envelopeNumerator L ≤ 8*L
```

`ProvenHashes.ChainHash128.Strided.modelA_fixed_score_numerator`

```lean
theorem modelA_fixed_score_numerator (L : ℕ) (hL : 0 < L) :
    ModelA.degreeBudget L + ModelA.wordBlocks L + 1 ≤ 3*L
```

`ProvenHashes.ChainHash128.Strided.score_at_one`

```lean
theorem score_at_one : max 1 ((1+31)/32) + 2 = 3 ∧
    ModelA.envelopeNumerator 1 = 8
```

## [ChainHash128/WordRepresentation.lean](ProvenHashes/ChainHash128/WordRepresentation.lean)

`ProvenHashes.ChainHash128.bitsOfBitVec_bitVecOfBits`

```lean
theorem bitsOfBitVec_bitVecOfBits {w : ℕ} (v : Word w) : bitsOfBitVec (bitVecOfBits v) = v
```

`ProvenHashes.ChainHash128.bitVecOfBits_bitsOfBitVec`

```lean
theorem bitVecOfBits_bitsOfBitVec {w : ℕ} (v : BitVec w) : bitVecOfBits (bitsOfBitVec v) = v
```

`ProvenHashes.ChainHash128.wordIntegerEquiv_length`

```lean
theorem wordIntegerEquiv_length (n : ℕ) : wordIntegerEquiv 128 (lengthWord n) = (n : ZMod (2 ^ 128))
```

## [ChainHash128V3Bytes.lean](ProvenHashes/ChainHash128V3Bytes.lean)

`ProvenHashes.ChainHash.V3_128.coefficientsAt_collision`

```lean
theorem coefficientsAt_collision (m m' : Message) (hlen : m.length = m'.length)
    (hne : m ≠ m') :
    uniformProb (fun k : Slot → F => coefficientsAt m (blocks m.length) k =
      coefficientsAt m' (blocks m.length) k) ≤ 1/Fintype.card F
```

`ProvenHashes.ChainHash.V3_128.paper_collision_equal_length`

```lean
theorem paper_collision_equal_length (m m' : Message) (hlen : m.length = m'.length)
    (hne : m ≠ m') :
    uniformProb (fun k : IdealKey => hash k m = hash k m') ≤
      ((blocks m.length+1 : ℕ) : ℚ≥0)/2^128
```

`ProvenHashes.ChainHash.V3_128.lengthField_zero`

```lean
theorem lengthField_zero : lengthField 0 = 0
```

`ProvenHashes.ChainHash.V3_128.lengthField_ne_zero`

```lean
theorem lengthField_ne_zero {n : ℕ} (hn : n < 2^128) (hpos : 0 < n) : lengthField n ≠ 0
```

`ProvenHashes.ChainHash.V3_128.byte_polynomial_ne`

```lean
theorem byte_polynomial_ne (m m' : Message) (hm : m.length < 2^128) (hm' : m'.length < 2^128)
    (hne : m.length ≠ m'.length) (k : Slot → F) :
    hornerPoly (lengthField m.length) (coefficients m k) -
      hornerPoly (lengthField m'.length) (coefficients m' k) ≠ 0
```

`ProvenHashes.ChainHash.V3_128.horner_collision_of_nonzero`

```lean
theorem horner_collision_of_nonzero {K : Type*} [Field K] [Fintype K] {p q : ℕ}
    (ell ell' : K) (c : Fin p → K) (d : Fin q → K)
    (hne : hornerPoly ell c - hornerPoly ell' d ≠ 0) :
    uniformProb (fun y : K => hornerValue ell c y = hornerValue ell' d y) ≤
      ((max p q : ℕ) : ℚ≥0)/Fintype.card K
```

`ProvenHashes.ChainHash.V3_128.family_collision_unequal_length`

```lean
theorem family_collision_unequal_length {A : Type*} [Fintype A] [Nonempty A]
    (expand : A → Slot → F) (m m' : Message)
    (hm : m.length < 2^128) (hm' : m'.length < 2^128) (hne : m.length ≠ m'.length) :
    uniformProb (fun k : (A × F) × (F × (Fin 5 → F)) =>
      hash ((expand k.1.1,k.1.2),k.2) m = hash ((expand k.1.1,k.1.2),k.2) m') ≤
      ((max (blocks m.length) (blocks m'.length)+1 : ℕ) : ℚ≥0)/2^128
```

`ProvenHashes.ChainHash.V3_128.chainHashHorner_collision_bound`

```lean
theorem chainHashHorner_collision_bound (L : ℕ) (hL : 8*L < 2^128)
    (m m' : Message) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : IdealKey => hash k m = hash k m') ≤ paperEpsilon L
```

`ProvenHashes.ChainHash.V3_128.chainHashHorner_collision_bound_blocks`

```lean
theorem chainHashHorner_collision_bound_blocks (p : ℕ) (m m' : Message)
    (hm : m.length < 2^128) (hm' : m'.length < 2^128) (hne : m ≠ m')
    (hp : blocks m.length ≤ p) (hp' : blocks m'.length ≤ p) :
    uniformProb (fun k : IdealKey => hash k m = hash k m') ≤
      min 1 (((p+1 : ℕ) : ℚ≥0)/2^128)
```

## [ChainHash128V3Comb.lean](ProvenHashes/ChainHash128V3Comb.lean)

`ProvenHashes.ChainHash.V3_128.partnerExponent_injective`

```lean
theorem partnerExponent_injective : Function.Injective (fun j => exponent (partner j))
```

`ProvenHashes.ChainHash.V3_128.wordIndex_decode`

```lean
theorem wordIndex_decode (i : ℕ) : wordIndex (blockOf i) (slotOf i) = i
```

`ProvenHashes.ChainHash.V3_128.blockOf_lt`

```lean
theorem blockOf_lt (i n : ℕ) (hi : 16 * i < n) : blockOf i < blocks n
```

`ProvenHashes.ChainHash.V3_128.slotOf_active`

```lean
theorem slotOf_active (m : Message) (i : ℕ) (hi : 16 * i < m.length) :
    (slotOf i).1 ∈ active m (blockOf i)
```

`ProvenHashes.ChainHash.V3_128.comb_encoding_injective`

```lean
theorem comb_encoding_injective (m m' : Message) (hlen : m.length = m'.length)
    (h : ∀ t, t < blocks m.length → ∀ j : Slot, j.1 ∈ active m t → data m t j = data m' t j) :
    m = m'
```

`ProvenHashes.ChainHash.V3_128.blocks_pos`

```lean
theorem blocks_pos (n : ℕ) : 0 < blocks n
```

`ProvenHashes.ChainHash.V3_128.blocks_mono`

```lean
theorem blocks_mono {n m : ℕ} (h : n ≤ m) : blocks n ≤ blocks m
```

`ProvenHashes.ChainHash.V3_128.blocks_examples`

```lean
theorem blocks_examples :
    ([0,1,17,33,113,256,2048,2049,4096,4097].map blocks) = [1,1,2,3,8,8,8,8,8,9]
```

`ProvenHashes.ChainHash.V3_128.square_injective`

```lean
theorem square_injective {K : Type*} [Field K] [CharP K 2] :
    Function.Injective (fun x : K => x ^ 2)
```

`ProvenHashes.ChainHash.V3_128.frobenius_root_count`

```lean
theorem frobenius_root_count {K : Type*} [Field K] [Fintype K] [CharP K 2]
    [DecidableEq K] (h : K[X]) (hne : h ≠ 0) :
    (Finset.univ.filter fun x : K => (h.comp (X^2)).eval x = 0).card ≤ h.natDegree
```

## [ChainHash128V3Evaluation.lean](ProvenHashes/ChainHash128V3Evaluation.lean)

`ProvenHashes.ChainHash.V3_128.serialHorner_expansion`

```lean
theorem serialHorner_expansion {K : Type*} [CommSemiring K] (ell y : K) (cs : List K) :
    serialHorner ell y cs = ell*y^cs.length +
      ∑ i ∈ Finset.range cs.length, cs[i]?.getD 0 * y^i
```

`ProvenHashes.ChainHash.V3_128.hornerValue_eq_serial`

```lean
theorem hornerValue_eq_serial {K : Type*} [CommRing K] {p : ℕ}
    (ell y : K) (c : Fin p → K) :
    hornerValue ell c y = serialHorner ell y (List.ofFn c)
```

`ProvenHashes.ChainHash.V3_128.scheduledHorner_eq_serial`

```lean
theorem scheduledHorner_eq_serial {K : Type*} [CommSemiring K]
    (k : ℕ) (hk : 0 < k) : scheduledHorner (K := K) k = serialHorner
```

`ProvenHashes.ChainHash.V3_128.map_serialHorner`

```lean
theorem map_serialHorner {R K : Type*} [CommSemiring R] [CommSemiring K]
    (reduce : R →+* K) (ell y : R) (cs : List R) :
    reduce (serialHorner ell y cs) = serialHorner (reduce ell) (reduce y) (cs.map reduce)
```

`ProvenHashes.ChainHash.V3_128.evaluation_independence`

```lean
theorem evaluation_independence (k : ℕ) (hk : 0 < k) (ell y : BitsPolynomial) :
    (fun cs => (AdjoinRoot.mk modulus) (serialHorner ell y cs)) =
      (fun cs => scheduledHorner k ((AdjoinRoot.mk modulus) ell)
        ((AdjoinRoot.mk modulus) y) (cs.map (AdjoinRoot.mk modulus)))
```

`ProvenHashes.ChainHash.V3_128.hash_evaluation_independence`

```lean
theorem hash_evaluation_independence (stride : ℕ) (hstride : 0 < stride) :
    scheduledHash stride = hash
```

## [ChainHash128V3Horner.lean](ProvenHashes/ChainHash128V3Horner.lean)

`ProvenHashes.ChainHash.V3_128.hornerPoly_top`

```lean
theorem hornerPoly_top {K : Type*} [CommRing K] {p : ℕ} (ell : K) (c : Fin p → K) :
    (hornerPoly ell c).coeff p = ell
```

`ProvenHashes.ChainHash.V3_128.hornerPoly_degree`

```lean
theorem hornerPoly_degree {K : Type*} [CommRing K] {p : ℕ} (ell : K) (c : Fin p → K) :
    (hornerPoly ell c).natDegree ≤ p
```

`ProvenHashes.ChainHash.V3_128.hornerPoly_equal_length_difference`

```lean
theorem hornerPoly_equal_length_difference {K : Type*} [Field K] {p : ℕ}
    (ell : K) (c d : Fin p → K) (hne : c ≠ d) :
    hornerPoly ell c - hornerPoly ell d ≠ 0 ∧
      (hornerPoly ell c - hornerPoly ell d).natDegree ≤ p-1
```

`ProvenHashes.ChainHash.V3_128.hornerPoly_distinct_length`

```lean
theorem hornerPoly_distinct_length {K : Type*} [Field K] {p : ℕ}
    (ell ell' : K) (c d : Fin p → K) (hne : ell ≠ ell') :
    hornerPoly ell c - hornerPoly ell' d ≠ 0
```

`ProvenHashes.ChainHash.V3_128.hornerPoly_distinct_blocks`

```lean
theorem hornerPoly_distinct_blocks {K : Type*} [Field K] {p q : ℕ}
    (ell ell' : K) (c : Fin p → K) (d : Fin q → K) (hpq : q < p) (hne : ell ≠ 0) :
    hornerPoly ell c - hornerPoly ell' d ≠ 0
```

`ProvenHashes.ChainHash.V3_128.hornerValue_expansion`

```lean
theorem hornerValue_expansion {K : Type*} [CommRing K] {p : ℕ}
    (ell : K) (c : Fin p → K) (y : K) :
    hornerValue ell c y = ell*y^p + ∑ i, c i*y^i.val
```

`ProvenHashes.ChainHash.V3_128.horner_equal_collision`

```lean
theorem horner_equal_collision {K : Type*} [Field K] [Fintype K] {p : ℕ}
    (ell : K) (c d : Fin p → K) (hne : c ≠ d) :
    uniformProb (fun y : K => hornerValue ell c y = hornerValue ell d y) ≤
      ((p-1 : ℕ) : ℚ≥0) / Fintype.card K
```

`ProvenHashes.ChainHash.V3_128.horner_equal_from_stages`

```lean
theorem horner_equal_from_stages {K A J : Type*} [Field K] [Fintype K]
    [Fintype A] [Fintype J] [Nonempty A] [Nonempty J]
    (p D : ℕ) (hp : 0 < p) (ell : K) (s s' : A → Fin p → K) (g : J → K → K)
    (hs : uniformProb (fun a => s a = s' a) ≤ (D : ℚ≥0)/Fintype.card K)
    (hg : ∀ v w, v ≠ w → uniformProb (fun j => g j v = g j w) ≤ 1/Fintype.card K) :
    uniformProb (fun k : (A × K) × J =>
      g k.2 (hornerValue ell (s k.1.1) k.1.2) =
      g k.2 (hornerValue ell (s' k.1.1) k.1.2)) ≤
      ((D+p : ℕ) : ℚ≥0)/Fintype.card K
```

## [ChainHash128V3Keys.lean](ProvenHashes/ChainHash128V3Keys.lean)

`ProvenHashes.ChainHash.V3_128.unposition_position`

```lean
theorem unposition_position (j : Slot) : unposition (position j) = j
```

`ProvenHashes.ChainHash.V3_128.position_unposition`

```lean
theorem position_unposition (i : Fin 32) : position (unposition i) = i
```

`ProvenHashes.ChainHash.V3_128.encode_decodeIdeal`

```lean
theorem encode_decodeIdeal (k : Key39) : encodeIdeal (decodeIdeal k) = k
```

`ProvenHashes.ChainHash.V3_128.decode_encodeIdeal`

```lean
theorem decode_encodeIdeal (k : IdealKey) : decodeIdeal (encodeIdeal k) = k
```

`ProvenHashes.ChainHash.V3_128.encode_decodeModelA`

```lean
theorem encode_decodeModelA (k : Key8) : encodeModelA (decodeModelA k) = k
```

`ProvenHashes.ChainHash.V3_128.decode_encodeModelA`

```lean
theorem decode_encodeModelA (k : ModelAKey) : decodeModelA (encodeModelA k) = k
```

`ProvenHashes.ChainHash.V3_128.expandedWords_power`

```lean
theorem expandedWords_power (k : ModelAKey) (j : Fin 32) :
    fieldRepr (expandedWords k ⟨j.val,by omega⟩) = k.1.1^(j.val+1)
```

`ProvenHashes.ChainHash.V3_128.encode_decodeKeyBytes`

```lean
theorem encode_decodeKeyBytes (n : ℕ) (b : Fin (16*n) → Byte) :
    encodeKeyBytes n (decodeKeyBytes n b) = b
```

`ProvenHashes.ChainHash.V3_128.decode_encodeKeyBytes`

```lean
theorem decode_encodeKeyBytes (n : ℕ) (w : Fin n → Word 128) :
    decodeKeyBytes n (encodeKeyBytes n w) = w
```

`ProvenHashes.ChainHash.V3_128.digestWord_injective`

```lean
theorem digestWord_injective : Function.Injective digestWord
```

`ProvenHashes.ChainHash.V3_128.digestBytes_injective`

```lean
theorem digestBytes_injective : Function.Injective digestBytes
```

`ProvenHashes.ChainHash.V3_128.paper_collision_bound_bytes`

```lean
theorem paper_collision_bound_bytes (L : ℕ) (hL : 8*L < 2^128)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Key39 => hashBytes k m = hashBytes k m') ≤ paperEpsilon L
```

`ProvenHashes.ChainHash.V3_128.paper_collision_bound_key_bytes`

```lean
theorem paper_collision_bound_key_bytes (L : ℕ) (hL : 8*L < 2^128)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Fin 624 → Byte => hashIdealKeyBytes k m = hashIdealKeyBytes k m') ≤
      paperEpsilon L
```

`ProvenHashes.ChainHash.V3_128.paper_collision_bound_output`

```lean
theorem paper_collision_bound_output (L : ℕ) (hL : 8*L < 2^128)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Key39 => hashOutput k m = hashOutput k m') ≤ paperEpsilon L
```

`ProvenHashes.ChainHash.V3_128.modelA_collision_bound_bytes`

```lean
theorem modelA_collision_bound_bytes (L : ℕ) (hL : 0 < L) (hcap : 8*L < 2^128)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Fin 128 → Byte => modelAHashBytes k m = modelAHashBytes k m') ≤
      modelAEpsilon L
```

`ProvenHashes.ChainHash.V3_128.modelA_coarse_bound_bytes`

```lean
theorem modelA_coarse_bound_bytes (L : ℕ) (hL : 0 < L) (hcap : 8*L < 2^128)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Fin 128 → Byte => modelAHashBytes k m = modelAHashBytes k m') ≤
      modelACoarseEpsilon L
```

`ProvenHashes.ChainHash.V3_128.paper_collision_bound_bytes_blocks`

```lean
theorem paper_collision_bound_bytes_blocks (p : ℕ) (m m' : List UInt8)
    (hm : m.length < 2^128) (hm' : m'.length < 2^128) (hne : m ≠ m')
    (hp : blocks m.length ≤ p) (hp' : blocks m'.length ≤ p) :
    uniformProb (fun k : Key39 => hashBytes k m = hashBytes k m') ≤
      min 1 (((p+1 : ℕ) : ℚ≥0)/2^128)
```

`ProvenHashes.ChainHash.V3_128.modelA_coarse_bound_bytes_blocks`

```lean
theorem modelA_coarse_bound_bytes_blocks (p : ℕ) (m m' : List UInt8)
    (hm : m.length < 2^128) (hm' : m'.length < 2^128) (hne : m ≠ m')
    (hp : blocks m.length ≤ p) (hp' : blocks m'.length ≤ p) :
    uniformProb (fun k : Fin 128 → Byte => modelAHashBytes k m = modelAHashBytes k m') ≤
      min 1 (((p+32 : ℕ) : ℚ≥0)/2^128)
```

## [ChainHash128V3Lazy.lean](ProvenHashes/ChainHash128V3Lazy.lean)

`ProvenHashes.ChainHash.V3_128.rawPolynomial_degree`

```lean
theorem rawPolynomial_degree (u : RawState) : (rawPolynomial u).natDegree < 256
```

`ProvenHashes.ChainHash.V3_128.rawPolynomial_split`

```lean
theorem rawPolynomial_split (p : BitsPolynomial) (hp : p.natDegree < 256) :
    rawPolynomial (splitRaw p) = p
```

`ProvenHashes.ChainHash.V3_128.alpha_eq_tail`

```lean
theorem alpha_eq_tail : alpha = (AdjoinRoot.mk modulus) (X^7+X^2+X+1)
```

`ProvenHashes.ChainHash.V3_128.testBit_135`

```lean
theorem testBit_135 (i : ℕ) (hi : 8 ≤ i) : Nat.testBit 135 i = false
```

`ProvenHashes.ChainHash.V3_128.tail_word_135`

```lean
theorem tail_word_135 : (pack 128 (lengthWord 135)) = (X^7+X^2+X+1 : BitsPolynomial)
```

`ProvenHashes.ChainHash.V3_128.alpha_eq_135`

```lean
theorem alpha_eq_135 : alpha = fieldRepr (lengthWord 135)
```

`ProvenHashes.ChainHash.V3_128.lazyRawStep_degree`

```lean
theorem lazyRawStep_degree (y : Word 128) (u c : RawState) :
    (lazyRawStep y u c).natDegree < 256
```

`ProvenHashes.ChainHash.V3_128.lazyStep_reduce`

```lean
theorem lazyStep_reduce (y : Word 128) (u c : RawState) :
    rawReduce (lazyStep y u c) = fieldRepr y * rawReduce u + rawReduce c
```

`ProvenHashes.ChainHash.V3_128.lazyHorner_eq_serial`

```lean
theorem lazyHorner_eq_serial (ell : RawState) (y : Word 128) :
    (fun cs => rawReduce (lazyHorner ell y cs)) =
      (fun cs => serialHorner (rawReduce ell) (fieldRepr y) (cs.map rawReduce))
```

`ProvenHashes.ChainHash.V3_128.lazyHorner_eq_schedule`

```lean
theorem lazyHorner_eq_schedule (k : ℕ) (hk : 0 < k) (ell : RawState) (y : Word 128) :
    (fun cs => rawReduce (lazyHorner ell y cs)) =
      (fun cs => scheduledHorner k (rawReduce ell) (fieldRepr y) (cs.map rawReduce))
```

`ProvenHashes.ChainHash.V3_128.reduce_clnh`

```lean
theorem reduce_clnh (a : Finset (Fin 16)) (m k : Slot → Word 128) :
    (AdjoinRoot.mk modulus) (clnh a m k) =
      reducedPH a (fun j => fieldRepr (m j)) (fun j => fieldRepr (k j))
```

`ProvenHashes.ChainHash.V3_128.rawBlock_matches`

```lean
theorem rawBlock_matches (m : Message) (k : Slot → F) (t : ℕ) :
    rawReduce (rawBlock m k t) = reducedPH (active m t) (data m t) k
```

`ProvenHashes.ChainHash.V3_128.rawCoefficients_matches`

```lean
theorem rawCoefficients_matches (m : Message) (k : Slot → F) :
    (rawCoefficients m k).map rawReduce = List.ofFn (coefficients m k)
```

`ProvenHashes.ChainHash.V3_128.rawLength_matches`

```lean
theorem rawLength_matches (n : ℕ) : rawReduce (lengthWord n,0) = lengthField n
```

`ProvenHashes.ChainHash.V3_128.lazyHash_eq_hash`

```lean
theorem lazyHash_eq_hash : lazyHash = hash
```

`ProvenHashes.ChainHash.V3_128.complete_evaluation_independence`

```lean
theorem complete_evaluation_independence (k : ℕ) (hk : 0 < k) :
    scheduledHash k = hash ∧ lazyHash = hash
```

## [ChainHash128V3Model.lean](ProvenHashes/ChainHash128V3Model.lean)

`ProvenHashes.ChainHash.V3_128.idealKey_card`

```lean
theorem idealKey_card : Fintype.card IdealKey = (2^128)^39
```

`ProvenHashes.ChainHash.V3_128.modelAKey_card`

```lean
theorem modelAKey_card : Fintype.card ModelAKey = (2^128)^8
```

`ProvenHashes.ChainHash.V3_128.lengthField_injective`

```lean
theorem lengthField_injective {n m : ℕ} (hn : n < 2^128) (hm : m < 2^128)
    (h : lengthField n = lengthField m) : n = m
```

`ProvenHashes.ChainHash.V3_128.blocks_le_words`

```lean
theorem blocks_le_words (L : ℕ) (hL : 0 < L) : blocks (8*L) ≤ L
```

`ProvenHashes.ChainHash.V3_128.degreeBudget_pos`

```lean
theorem degreeBudget_pos (L : ℕ) : 1 ≤ degreeBudget L
```

`ProvenHashes.ChainHash.V3_128.degreeBudget_le`

```lean
theorem degreeBudget_le (L : ℕ) : degreeBudget L ≤ 32
```

`ProvenHashes.ChainHash.V3_128.paper_envelope_arithmetic`

```lean
theorem paper_envelope_arithmetic (L : ℕ) (hL : 0 < L) : paperNumerator L ≤ 2*L
```

`ProvenHashes.ChainHash.V3_128.modelA_envelope_arithmetic`

```lean
theorem modelA_envelope_arithmetic (L : ℕ) (hL : 0 < L) : modelANumerator L ≤ 2*L
```

`ProvenHashes.ChainHash.V3_128.coarse_envelope_arithmetic`

```lean
theorem coarse_envelope_arithmetic (L : ℕ) (hL : 0 < L) : coarseNumerator L ≤ 33*L
```

`ProvenHashes.ChainHash.V3_128.modelA_le_coarse`

```lean
theorem modelA_le_coarse (L : ℕ) : modelAEpsilon L ≤ modelACoarseEpsilon L
```

`ProvenHashes.ChainHash.V3_128.paper_score_ratio`

```lean
theorem paper_score_ratio (L : ℕ) (hL : 0 < L) :
    paperEpsilon L ≤ (L : ℚ≥0)/2^127
```

`ProvenHashes.ChainHash.V3_128.modelA_score_ratio`

```lean
theorem modelA_score_ratio (L : ℕ) (hL : 0 < L) :
    modelAEpsilon L ≤ (L : ℚ≥0)/2^127
```

`ProvenHashes.ChainHash.V3_128.coarse_score_ratio`

```lean
theorem coarse_score_ratio (L : ℕ) (hL : 0 < L) :
    modelACoarseEpsilon L ≤ 33*(L : ℚ≥0)/2^128
```

`ProvenHashes.ChainHash.V3_128.numerators_at_one`

```lean
theorem numerators_at_one : paperNumerator 1 = 2 ∧ modelANumerator 1 = 2 ∧ coarseNumerator 1 = 33
```

`ProvenHashes.ChainHash.V3_128.score_attained`

```lean
theorem score_attained : paperEpsilon 1 = 1/2^127 ∧ modelAEpsilon 1 = 1/2^127 ∧
    modelACoarseEpsilon 1 = 33/2^128
```

`ProvenHashes.ChainHash.V3_128.paperEpsilon_pos`

```lean
theorem paperEpsilon_pos (L : ℕ) : 0 < paperEpsilon L
```

`ProvenHashes.ChainHash.V3_128.modelAEpsilon_pos`

```lean
theorem modelAEpsilon_pos (L : ℕ) : 0 < modelAEpsilon L
```

`ProvenHashes.ChainHash.V3_128.coarseEpsilon_pos`

```lean
theorem coarseEpsilon_pos (L : ℕ) : 0 < modelACoarseEpsilon L
```

## [ChainHash128V3PH.lean](ProvenHashes/ChainHash128V3PH.lean)

`ProvenHashes.ChainHash.V3_128.eval_phPoly`

```lean
theorem eval_phPoly {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m : Slot → F) (s : F) : (phPoly a m).eval s = ph a m s
```

`ProvenHashes.ChainHash.V3_128.phPoly_difference`

```lean
theorem phPoly_difference {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m m' : Slot → F) (t : F) :
    phPoly a m - phPoly a m' - C t = differencePoly a m m' t
```

`ProvenHashes.ChainHash.V3_128.differencePoly_coeff`

```lean
theorem differencePoly_coeff {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m m' : Slot → F) (t : F) (j : Slot) (hj : j.1 ∈ a) :
    (differencePoly a m m' t).coeff (exponent (partner j)) = m j - m' j
```

`ProvenHashes.ChainHash.V3_128.differencePoly_nonzero_degree`

```lean
theorem differencePoly_nonzero_degree {F : Type*} [Field F]
    (a : Finset (Fin 16)) (m m' : Slot → F) (t : F) (D : ℕ)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j)
    (hD : ∀ j : Slot, j.1 ∈ a → m j ≠ m' j → exponent (partner j) ≤ D) :
    differencePoly a m m' t ≠ 0 ∧ (differencePoly a m m' t).natDegree ≤ D
```

`ProvenHashes.ChainHash.V3_128.polynomial_probability_le`

```lean
theorem polynomial_probability_le {F : Type*} [Field F] [Fintype F]
    (p : F[X]) (hp : p ≠ 0) (D : ℕ) (hd : p.natDegree ≤ D) :
    uniformProb (fun s : F => p.eval s = 0) ≤ (D : ℚ≥0) / Fintype.card F
```

`ProvenHashes.ChainHash.V3_128.ph_equal_groups_bound`

```lean
theorem ph_equal_groups_bound {F : Type*} [Field F] [Fintype F]
    (a : Finset (Fin 16)) (m m' : Slot → F) (t : F) (D : ℕ)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j)
    (hD : ∀ j : Slot, j.1 ∈ a → m j ≠ m' j → exponent (partner j) ≤ D) :
    uniformProb (fun s : F => ph a m s - ph a m' s = t) ≤
      (D : ℚ≥0) / Fintype.card F
```

`ProvenHashes.ChainHash.V3_128.reducedPH_difference`

```lean
theorem reducedPH_difference {K : Type*} [Field K]
    (a : Finset (Fin 16)) (m m' k : Slot → K) :
    reducedPH a m k - reducedPH a m' k =
      constantDiff a m m' 0 + ∑ j, reducedCoefficient a m m' j * k j
```

`ProvenHashes.ChainHash.V3_128.reducedPH_difference_uniform`

```lean
theorem reducedPH_difference_uniform {K : Type*} [Field K] [Fintype K]
    (a : Finset (Fin 16)) (m m' : Slot → K)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j) (z : K) :
    uniformProb (fun k : Slot → K => reducedPH a m k - reducedPH a m' k = z) =
      1 / Fintype.card K
```

## [ChainHash128V3Scores.lean](ProvenHashes/ChainHash128V3Scores.lean)

`ProvenHashes.ChainHash.V3_128.score_lower_bound`

```lean
theorem score_lower_bound (epsilon : ℕ → ℚ≥0) (L : ℕ)
    (hpos : 0 < epsilon L) (hbound : epsilon L ≤ (L : ℚ≥0)/2^127) :
    127 ≤ score epsilon L
```

`ProvenHashes.ChainHash.V3_128.score_lower_bound_coarse`

```lean
theorem score_lower_bound_coarse (epsilon : ℕ → ℚ≥0) (L : ℕ)
    (hpos : 0 < epsilon L) (hbound : epsilon L ≤ 33*(L : ℚ≥0)/2^128) :
    128 - Real.logb 2 33 ≤ score epsilon L
```

`ProvenHashes.ChainHash.V3_128.paper_score`

```lean
theorem paper_score (L : ℕ) (hL : 0 < L) : 127 ≤ score paperEpsilon L
```

`ProvenHashes.ChainHash.V3_128.modelA_score`

```lean
theorem modelA_score (L : ℕ) (hL : 0 < L) : 127 ≤ score modelAEpsilon L
```

`ProvenHashes.ChainHash.V3_128.coarse_score`

```lean
theorem coarse_score (L : ℕ) (hL : 0 < L) : 128 - Real.logb 2 33 ≤ score modelACoarseEpsilon L
```

`ProvenHashes.ChainHash.V3_128.scores_at_one`

```lean
theorem scores_at_one : score paperEpsilon 1 = 127 ∧ score modelAEpsilon 1 = 127
```

`ProvenHashes.ChainHash.V3_128.coarse_score_at_one`

```lean
theorem coarse_score_at_one : score modelACoarseEpsilon 1 = 128 - Real.logb 2 33
```

`ProvenHashes.ChainHash.V3_128.paper_score_minimum`

```lean
theorem paper_score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score paperEpsilon L.val)) 127
```

`ProvenHashes.ChainHash.V3_128.modelA_score_minimum`

```lean
theorem modelA_score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score modelAEpsilon L.val)) 127
```

`ProvenHashes.ChainHash.V3_128.modelA_coarse_score_minimum`

```lean
theorem modelA_coarse_score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score modelACoarseEpsilon L.val))
      (128 - Real.logb 2 33)
```

`ProvenHashes.ChainHash.V3_128.envelope_table`

```lean
theorem envelope_table :
    ([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20].map modelANumerator) =
      [2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,10,10]
```

`ProvenHashes.ChainHash.V3_128.envelope_large_examples`

```lean
theorem envelope_large_examples :
    ([128, 131072].map (fun L => (paperNumerator L, coarseNumerator L, modelANumerator L))) =
      [(9, 40, 16), (2049, 2080, 2080)]
```

## [ChainHash128V3Seeded.lean](ProvenHashes/ChainHash128V3Seeded.lean)

`ProvenHashes.ChainHash.V3_128.halfPoly_comp`

```lean
theorem halfPoly_comp {K : Type*} [CommRing K] (a : Finset (Fin 16)) (m m' : Slot → K)
    (hpad : ∀ i, m (i,true)=0 ∧ m' (i,true)=0) :
    (halfPoly a m m').comp (X^2) = differencePoly a m m' 0
```

`ProvenHashes.ChainHash.V3_128.ph_frobenius_bound`

```lean
theorem ph_frobenius_bound {K : Type*} [Field K] [Fintype K] [CharP K 2]
    (a : Finset (Fin 16)) (m m' : Slot → K) (D : ℕ)
    (hpad : ∀ i, m (i,true)=0 ∧ m' (i,true)=0)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j)
    (hD : ∀ i, i ∈ a → m (i,false) ≠ m' (i,false) → i.val+1 ≤ D) :
    uniformProb (fun s : K => ph a m s = ph a m' s) ≤ (D : ℚ≥0)/Fintype.card K
```

`ProvenHashes.ChainHash.V3_128.partner_exponent_budget`

```lean
theorem partner_exponent_budget (L t : ℕ) (hL : 17 ≤ L) (j : Slot)
    (hj : 2 * wordIndex t j < L) : exponent (partner j) ≤ degreeBudget L
```

`ProvenHashes.ChainHash.V3_128.field_char_two`

```lean
theorem field_char_two : CharP F 2
```

`ProvenHashes.ChainHash.V3_128.seeded_coefficients_collision`

```lean
theorem seeded_coefficients_collision (L : ℕ) (hL : 0 < L) (m m' : Message)
    (hm : m.length ≤ 8*L) (hlen : m.length = m'.length) (hne : m ≠ m') :
    uniformProb (fun s : F => coefficientsAt m (blocks m.length) (powerKey s) =
      coefficientsAt m' (blocks m.length) (powerKey s)) ≤
      (degreeBudget L : ℚ≥0)/Fintype.card F
```

`ProvenHashes.ChainHash.V3_128.modelA_collision_equal_length`

```lean
theorem modelA_collision_equal_length (L : ℕ) (hL : 0 < L) (m m' : Message)
    (hm : m.length ≤ 8*L) (hlen : m.length = m'.length) (hne : m ≠ m') :
    uniformProb (fun k : ModelAKey => modelAHash k m = modelAHash k m') ≤ modelAEpsilon L
```

`ProvenHashes.ChainHash.V3_128.chainHashHorner_modelA_collision_bound`

```lean
theorem chainHashHorner_modelA_collision_bound (L : ℕ) (hL : 0 < L) (hcap : 8*L < 2^128)
    (m m' : Message) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : ModelAKey => modelAHash k m = modelAHash k m') ≤ modelAEpsilon L
```

`ProvenHashes.ChainHash.V3_128.chainHashHorner_modelA_coarse_bound`

```lean
theorem chainHashHorner_modelA_coarse_bound (L : ℕ) (hL : 0 < L) (hcap : 8*L < 2^128)
    (m m' : Message) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : ModelAKey => modelAHash k m = modelAHash k m') ≤
      modelACoarseEpsilon L
```

`ProvenHashes.ChainHash.V3_128.partner_exponent_le`

```lean
theorem partner_exponent_le (j : Slot) : exponent (partner j) ≤ 32
```

`ProvenHashes.ChainHash.V3_128.seeded_coefficients_collision_coarse`

```lean
theorem seeded_coefficients_collision_coarse (m m' : Message)
    (hlen : m.length = m'.length) (hne : m ≠ m') :
    uniformProb (fun s : F => coefficientsAt m (blocks m.length) (powerKey s) =
      coefficientsAt m' (blocks m.length) (powerKey s)) ≤
      ((32 : ℕ) : ℚ≥0)/Fintype.card F
```

`ProvenHashes.ChainHash.V3_128.chainHashHorner_modelA_coarse_bound_blocks`

```lean
theorem chainHashHorner_modelA_coarse_bound_blocks (p : ℕ) (m m' : Message)
    (hm : m.length < 2^128) (hm' : m'.length < 2^128) (hne : m ≠ m')
    (hp : blocks m.length ≤ p) (hp' : blocks m'.length ≤ p) :
    uniformProb (fun k : ModelAKey => modelAHash k m = modelAHash k m') ≤
      min 1 (((p+32 : ℕ) : ℚ≥0)/2^128)
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

## [ChainHashV3Bytes.lean](ProvenHashes/ChainHashV3Bytes.lean)

`ProvenHashes.ChainHash.V3.coefficientsAt_collision`

```lean
theorem coefficientsAt_collision (m m' : Message) (hlen : m.length = m'.length)
    (hne : m ≠ m') :
    uniformProb (fun k : Slot → F => coefficientsAt m (blocks m.length) k =
      coefficientsAt m' (blocks m.length) k) ≤ 1/Fintype.card F
```

`ProvenHashes.ChainHash.V3.paper_collision_equal_length`

```lean
theorem paper_collision_equal_length (m m' : Message) (hlen : m.length = m'.length)
    (hne : m ≠ m') :
    uniformProb (fun k : IdealKey => hash k m = hash k m') ≤
      ((blocks m.length+1 : ℕ) : ℚ≥0)/2^64
```

`ProvenHashes.ChainHash.V3.lengthField_zero`

```lean
theorem lengthField_zero : lengthField 0 = 0
```

`ProvenHashes.ChainHash.V3.lengthField_ne_zero`

```lean
theorem lengthField_ne_zero {n : ℕ} (hn : n < 2^64) (hpos : 0 < n) : lengthField n ≠ 0
```

`ProvenHashes.ChainHash.V3.byte_polynomial_ne`

```lean
theorem byte_polynomial_ne (m m' : Message) (hm : m.length < 2^64) (hm' : m'.length < 2^64)
    (hne : m.length ≠ m'.length) (k : Slot → F) :
    hornerPoly (lengthField m.length) (coefficients m k) -
      hornerPoly (lengthField m'.length) (coefficients m' k) ≠ 0
```

`ProvenHashes.ChainHash.V3.horner_collision_of_nonzero`

```lean
theorem horner_collision_of_nonzero {K : Type*} [Field K] [Fintype K] {p q : ℕ}
    (ell ell' : K) (c : Fin p → K) (d : Fin q → K)
    (hne : hornerPoly ell c - hornerPoly ell' d ≠ 0) :
    uniformProb (fun y : K => hornerValue ell c y = hornerValue ell' d y) ≤
      ((max p q : ℕ) : ℚ≥0)/Fintype.card K
```

`ProvenHashes.ChainHash.V3.family_collision_unequal_length`

```lean
theorem family_collision_unequal_length {A : Type*} [Fintype A] [Nonempty A]
    (expand : A → Slot → F) (m m' : Message)
    (hm : m.length < 2^64) (hm' : m'.length < 2^64) (hne : m.length ≠ m'.length) :
    uniformProb (fun k : (A × F) × (F × (Fin 5 → F)) =>
      hash ((expand k.1.1,k.1.2),k.2) m = hash ((expand k.1.1,k.1.2),k.2) m') ≤
      ((max (blocks m.length) (blocks m'.length)+1 : ℕ) : ℚ≥0)/2^64
```

`ProvenHashes.ChainHash.V3.chainHashHorner_collision_bound`

```lean
theorem chainHashHorner_collision_bound (L : ℕ) (hL : 8*L < 2^64)
    (m m' : Message) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : IdealKey => hash k m = hash k m') ≤ paperEpsilon L
```

## [ChainHashV3Comb.lean](ProvenHashes/ChainHashV3Comb.lean)

`ProvenHashes.ChainHash.V3.partnerExponent_injective`

```lean
theorem partnerExponent_injective : Function.Injective (fun j => exponent (partner j))
```

`ProvenHashes.ChainHash.V3.wordIndex_decode`

```lean
theorem wordIndex_decode (i : ℕ) : wordIndex (blockOf i) (slotOf i) = i
```

`ProvenHashes.ChainHash.V3.blockOf_lt`

```lean
theorem blockOf_lt (i n : ℕ) (hi : 8 * i < n) : blockOf i < blocks n
```

`ProvenHashes.ChainHash.V3.slotOf_active`

```lean
theorem slotOf_active (m : Message) (i : ℕ) (hi : 8 * i < m.length) :
    (slotOf i).1 ∈ active m (blockOf i)
```

`ProvenHashes.ChainHash.V3.comb_encoding_injective`

```lean
theorem comb_encoding_injective (m m' : Message) (hlen : m.length = m'.length)
    (h : ∀ t, t < blocks m.length → ∀ j : Slot, j.1 ∈ active m t → data m t j = data m' t j) :
    m = m'
```

`ProvenHashes.ChainHash.V3.blocks_pos`

```lean
theorem blocks_pos (n : ℕ) : 0 < blocks n
```

`ProvenHashes.ChainHash.V3.blocks_mono`

```lean
theorem blocks_mono {n m : ℕ} (h : n ≤ m) : blocks n ≤ blocks m
```

`ProvenHashes.ChainHash.V3.square_injective`

```lean
theorem square_injective {K : Type*} [Field K] [CharP K 2] :
    Function.Injective (fun x : K => x ^ 2)
```

`ProvenHashes.ChainHash.V3.frobenius_root_count`

```lean
theorem frobenius_root_count {K : Type*} [Field K] [Fintype K] [CharP K 2]
    [DecidableEq K] (h : K[X]) (hne : h ≠ 0) :
    (Finset.univ.filter fun x : K => (h.comp (X^2)).eval x = 0).card ≤ h.natDegree
```

## [ChainHashV3Evaluation.lean](ProvenHashes/ChainHashV3Evaluation.lean)

`ProvenHashes.ChainHash.V3.serialHorner_expansion`

```lean
theorem serialHorner_expansion {K : Type*} [CommSemiring K] (ell y : K) (cs : List K) :
    serialHorner ell y cs = ell*y^cs.length +
      ∑ i ∈ Finset.range cs.length, cs[i]?.getD 0 * y^i
```

`ProvenHashes.ChainHash.V3.hornerValue_eq_serial`

```lean
theorem hornerValue_eq_serial {K : Type*} [CommRing K] {p : ℕ}
    (ell y : K) (c : Fin p → K) :
    hornerValue ell c y = serialHorner ell y (List.ofFn c)
```

`ProvenHashes.ChainHash.V3.scheduledHorner_eq_serial`

```lean
theorem scheduledHorner_eq_serial {K : Type*} [CommSemiring K]
    (k : ℕ) (hk : 0 < k) : scheduledHorner (K := K) k = serialHorner
```

`ProvenHashes.ChainHash.V3.map_serialHorner`

```lean
theorem map_serialHorner {R K : Type*} [CommSemiring R] [CommSemiring K]
    (reduce : R →+* K) (ell y : R) (cs : List R) :
    reduce (serialHorner ell y cs) = serialHorner (reduce ell) (reduce y) (cs.map reduce)
```

`ProvenHashes.ChainHash.V3.evaluation_independence`

```lean
theorem evaluation_independence (k : ℕ) (hk : 0 < k) (ell y : BitsPolynomial) :
    (fun cs => (AdjoinRoot.mk modulus) (serialHorner ell y cs)) =
      (fun cs => scheduledHorner k ((AdjoinRoot.mk modulus) ell)
        ((AdjoinRoot.mk modulus) y) (cs.map (AdjoinRoot.mk modulus)))
```

`ProvenHashes.ChainHash.V3.hash_evaluation_independence`

```lean
theorem hash_evaluation_independence (stride : ℕ) (hstride : 0 < stride) :
    scheduledHash stride = hash
```

## [ChainHashV3Horner.lean](ProvenHashes/ChainHashV3Horner.lean)

`ProvenHashes.ChainHash.V3.hornerPoly_top`

```lean
theorem hornerPoly_top {K : Type*} [CommRing K] {p : ℕ} (ell : K) (c : Fin p → K) :
    (hornerPoly ell c).coeff p = ell
```

`ProvenHashes.ChainHash.V3.hornerPoly_degree`

```lean
theorem hornerPoly_degree {K : Type*} [CommRing K] {p : ℕ} (ell : K) (c : Fin p → K) :
    (hornerPoly ell c).natDegree ≤ p
```

`ProvenHashes.ChainHash.V3.hornerPoly_equal_length_difference`

```lean
theorem hornerPoly_equal_length_difference {K : Type*} [Field K] {p : ℕ}
    (ell : K) (c d : Fin p → K) (hne : c ≠ d) :
    hornerPoly ell c - hornerPoly ell d ≠ 0 ∧
      (hornerPoly ell c - hornerPoly ell d).natDegree ≤ p-1
```

`ProvenHashes.ChainHash.V3.hornerPoly_distinct_length`

```lean
theorem hornerPoly_distinct_length {K : Type*} [Field K] {p : ℕ}
    (ell ell' : K) (c d : Fin p → K) (hne : ell ≠ ell') :
    hornerPoly ell c - hornerPoly ell' d ≠ 0
```

`ProvenHashes.ChainHash.V3.hornerPoly_distinct_blocks`

```lean
theorem hornerPoly_distinct_blocks {K : Type*} [Field K] {p q : ℕ}
    (ell ell' : K) (c : Fin p → K) (d : Fin q → K) (hpq : q < p) (hne : ell ≠ 0) :
    hornerPoly ell c - hornerPoly ell' d ≠ 0
```

`ProvenHashes.ChainHash.V3.hornerValue_expansion`

```lean
theorem hornerValue_expansion {K : Type*} [CommRing K] {p : ℕ}
    (ell : K) (c : Fin p → K) (y : K) :
    hornerValue ell c y = ell*y^p + ∑ i, c i*y^i.val
```

`ProvenHashes.ChainHash.V3.horner_equal_collision`

```lean
theorem horner_equal_collision {K : Type*} [Field K] [Fintype K] {p : ℕ}
    (ell : K) (c d : Fin p → K) (hne : c ≠ d) :
    uniformProb (fun y : K => hornerValue ell c y = hornerValue ell d y) ≤
      ((p-1 : ℕ) : ℚ≥0) / Fintype.card K
```

`ProvenHashes.ChainHash.V3.horner_equal_from_stages`

```lean
theorem horner_equal_from_stages {K A J : Type*} [Field K] [Fintype K]
    [Fintype A] [Fintype J] [Nonempty A] [Nonempty J]
    (p D : ℕ) (hp : 0 < p) (ell : K) (s s' : A → Fin p → K) (g : J → K → K)
    (hs : uniformProb (fun a => s a = s' a) ≤ (D : ℚ≥0)/Fintype.card K)
    (hg : ∀ v w, v ≠ w → uniformProb (fun j => g j v = g j w) ≤ 1/Fintype.card K) :
    uniformProb (fun k : (A × K) × J =>
      g k.2 (hornerValue ell (s k.1.1) k.1.2) =
      g k.2 (hornerValue ell (s' k.1.1) k.1.2)) ≤
      ((D+p : ℕ) : ℚ≥0)/Fintype.card K
```

## [ChainHashV3Keys.lean](ProvenHashes/ChainHashV3Keys.lean)

`ProvenHashes.ChainHash.V3.unposition_position`

```lean
theorem unposition_position (j : Slot) : unposition (position j) = j
```

`ProvenHashes.ChainHash.V3.position_unposition`

```lean
theorem position_unposition (i : Fin 32) : position (unposition i) = i
```

`ProvenHashes.ChainHash.V3.encode_decodeIdeal`

```lean
theorem encode_decodeIdeal (k : Key39) : encodeIdeal (decodeIdeal k) = k
```

`ProvenHashes.ChainHash.V3.decode_encodeIdeal`

```lean
theorem decode_encodeIdeal (k : IdealKey) : decodeIdeal (encodeIdeal k) = k
```

`ProvenHashes.ChainHash.V3.encode_decodeModelA`

```lean
theorem encode_decodeModelA (k : Key8) : encodeModelA (decodeModelA k) = k
```

`ProvenHashes.ChainHash.V3.decode_encodeModelA`

```lean
theorem decode_encodeModelA (k : ModelAKey) : decodeModelA (encodeModelA k) = k
```

`ProvenHashes.ChainHash.V3.expandedWords_power`

```lean
theorem expandedWords_power (k : ModelAKey) (j : Fin 32) :
    fieldRepr (expandedWords k ⟨j.val,by omega⟩) = k.1.1^(j.val+1)
```

`ProvenHashes.ChainHash.V3.encode_decodeKeyBytes`

```lean
theorem encode_decodeKeyBytes (n : ℕ) (b : Fin (8*n) → Byte) :
    encodeKeyBytes n (decodeKeyBytes n b) = b
```

`ProvenHashes.ChainHash.V3.decode_encodeKeyBytes`

```lean
theorem decode_encodeKeyBytes (n : ℕ) (w : Fin n → Word 64) :
    decodeKeyBytes n (encodeKeyBytes n w) = w
```

`ProvenHashes.ChainHash.V3.digestWord_injective`

```lean
theorem digestWord_injective : Function.Injective digestWord
```

`ProvenHashes.ChainHash.V3.paper_collision_bound_bytes`

```lean
theorem paper_collision_bound_bytes (L : ℕ) (hL : 8*L < 2^64)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Key39 => hashBytes k m = hashBytes k m') ≤ paperEpsilon L
```

`ProvenHashes.ChainHash.V3.modelA_collision_bound_bytes`

```lean
theorem modelA_collision_bound_bytes (L : ℕ) (hL : 0 < L) (hcap : 8*L < 2^64)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Fin 64 → Byte => modelAHashBytes k m = modelAHashBytes k m') ≤ modelAEpsilon L
```

## [ChainHashV3Lazy.lean](ProvenHashes/ChainHashV3Lazy.lean)

`ProvenHashes.ChainHash.V3.rawPolynomial_degree`

```lean
theorem rawPolynomial_degree (u : RawState) : (rawPolynomial u).natDegree < 128
```

`ProvenHashes.ChainHash.V3.rawPolynomial_split`

```lean
theorem rawPolynomial_split (p : BitsPolynomial) (hp : p.natDegree < 128) :
    rawPolynomial (splitRaw p) = p
```

`ProvenHashes.ChainHash.V3.alpha_eq_tail`

```lean
theorem alpha_eq_tail : alpha = (AdjoinRoot.mk modulus) (X^4+X^3+X+1)
```

`ProvenHashes.ChainHash.V3.tail_word_27`

```lean
theorem tail_word_27 : (pack 64 (lengthWord 27)) = (X^4+X^3+X+1 : BitsPolynomial)
```

`ProvenHashes.ChainHash.V3.alpha_eq_27`

```lean
theorem alpha_eq_27 : alpha = fieldRepr (lengthWord 27)
```

`ProvenHashes.ChainHash.V3.lazyRawStep_degree`

```lean
theorem lazyRawStep_degree (y : Word 64) (u c : RawState) :
    (lazyRawStep y u c).natDegree < 128
```

`ProvenHashes.ChainHash.V3.lazyStep_reduce`

```lean
theorem lazyStep_reduce (y : Word 64) (u c : RawState) :
    rawReduce (lazyStep y u c) = fieldRepr y * rawReduce u + rawReduce c
```

`ProvenHashes.ChainHash.V3.lazyHorner_eq_serial`

```lean
theorem lazyHorner_eq_serial (ell : RawState) (y : Word 64) :
    (fun cs => rawReduce (lazyHorner ell y cs)) =
      (fun cs => serialHorner (rawReduce ell) (fieldRepr y) (cs.map rawReduce))
```

`ProvenHashes.ChainHash.V3.lazyHorner_eq_schedule`

```lean
theorem lazyHorner_eq_schedule (k : ℕ) (hk : 0 < k) (ell : RawState) (y : Word 64) :
    (fun cs => rawReduce (lazyHorner ell y cs)) =
      (fun cs => scheduledHorner k (rawReduce ell) (fieldRepr y) (cs.map rawReduce))
```

`ProvenHashes.ChainHash.V3.reduce_clnh`

```lean
theorem reduce_clnh (a : Finset (Fin 16)) (m k : Slot → Word 64) :
    (AdjoinRoot.mk modulus) (clnh a m k) =
      reducedPH a (fun j => fieldRepr (m j)) (fun j => fieldRepr (k j))
```

`ProvenHashes.ChainHash.V3.rawBlock_matches`

```lean
theorem rawBlock_matches (m : Message) (k : Slot → F) (t : ℕ) :
    rawReduce (rawBlock m k t) = reducedPH (active m t) (data m t) k
```

`ProvenHashes.ChainHash.V3.rawCoefficients_matches`

```lean
theorem rawCoefficients_matches (m : Message) (k : Slot → F) :
    (rawCoefficients m k).map rawReduce = List.ofFn (coefficients m k)
```

`ProvenHashes.ChainHash.V3.rawLength_matches`

```lean
theorem rawLength_matches (n : ℕ) : rawReduce (lengthWord n,0) = lengthField n
```

`ProvenHashes.ChainHash.V3.lazyHash_eq_hash`

```lean
theorem lazyHash_eq_hash : lazyHash = hash
```

`ProvenHashes.ChainHash.V3.complete_evaluation_independence`

```lean
theorem complete_evaluation_independence (k : ℕ) (hk : 0 < k) :
    scheduledHash k = hash ∧ lazyHash = hash
```

## [ChainHashV3Model.lean](ProvenHashes/ChainHashV3Model.lean)

`ProvenHashes.ChainHash.V3.idealKey_card`

```lean
theorem idealKey_card : Fintype.card IdealKey = (2^64)^39
```

`ProvenHashes.ChainHash.V3.modelAKey_card`

```lean
theorem modelAKey_card : Fintype.card ModelAKey = (2^64)^8
```

`ProvenHashes.ChainHash.V3.lengthField_injective`

```lean
theorem lengthField_injective {n m : ℕ} (hn : n < 2^64) (hm : m < 2^64)
    (h : lengthField n = lengthField m) : n = m
```

`ProvenHashes.ChainHash.V3.paper_envelope_arithmetic`

```lean
theorem paper_envelope_arithmetic (L : ℕ) (hL : 0 < L) : blocks (8*L)+1 ≤ 2*L
```

`ProvenHashes.ChainHash.V3.modelA_envelope_arithmetic`

```lean
theorem modelA_envelope_arithmetic (L : ℕ) (hL : 0 < L) :
    degreeBudget L + blocks (8*L) ≤ 2*L
```

`ProvenHashes.ChainHash.V3.paper_score_ratio`

```lean
theorem paper_score_ratio (L : ℕ) (hL : 0 < L) :
    paperEpsilon L ≤ (L : ℚ≥0)/2^63
```

`ProvenHashes.ChainHash.V3.modelA_score_ratio`

```lean
theorem modelA_score_ratio (L : ℕ) (hL : 0 < L) :
    modelAEpsilon L ≤ (L : ℚ≥0)/2^63
```

`ProvenHashes.ChainHash.V3.score_attained`

```lean
theorem score_attained : paperEpsilon 1 = 1/2^63 ∧ modelAEpsilon 1 = 1/2^63
```

## [ChainHashV3PH.lean](ProvenHashes/ChainHashV3PH.lean)

`ProvenHashes.ChainHash.V3.eval_phPoly`

```lean
theorem eval_phPoly {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m : Slot → F) (s : F) : (phPoly a m).eval s = ph a m s
```

`ProvenHashes.ChainHash.V3.phPoly_difference`

```lean
theorem phPoly_difference {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m m' : Slot → F) (t : F) :
    phPoly a m - phPoly a m' - C t = differencePoly a m m' t
```

`ProvenHashes.ChainHash.V3.differencePoly_coeff`

```lean
theorem differencePoly_coeff {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m m' : Slot → F) (t : F) (j : Slot) (hj : j.1 ∈ a) :
    (differencePoly a m m' t).coeff (exponent (partner j)) = m j - m' j
```

`ProvenHashes.ChainHash.V3.differencePoly_nonzero_degree`

```lean
theorem differencePoly_nonzero_degree {F : Type*} [Field F]
    (a : Finset (Fin 16)) (m m' : Slot → F) (t : F) (D : ℕ)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j)
    (hD : ∀ j : Slot, j.1 ∈ a → m j ≠ m' j → exponent (partner j) ≤ D) :
    differencePoly a m m' t ≠ 0 ∧ (differencePoly a m m' t).natDegree ≤ D
```

`ProvenHashes.ChainHash.V3.polynomial_probability_le`

```lean
theorem polynomial_probability_le {F : Type*} [Field F] [Fintype F]
    (p : F[X]) (hp : p ≠ 0) (D : ℕ) (hd : p.natDegree ≤ D) :
    uniformProb (fun s : F => p.eval s = 0) ≤ (D : ℚ≥0) / Fintype.card F
```

`ProvenHashes.ChainHash.V3.ph_equal_groups_bound`

```lean
theorem ph_equal_groups_bound {F : Type*} [Field F] [Fintype F]
    (a : Finset (Fin 16)) (m m' : Slot → F) (t : F) (D : ℕ)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j)
    (hD : ∀ j : Slot, j.1 ∈ a → m j ≠ m' j → exponent (partner j) ≤ D) :
    uniformProb (fun s : F => ph a m s - ph a m' s = t) ≤
      (D : ℚ≥0) / Fintype.card F
```

`ProvenHashes.ChainHash.V3.reducedPH_difference`

```lean
theorem reducedPH_difference {K : Type*} [Field K]
    (a : Finset (Fin 16)) (m m' k : Slot → K) :
    reducedPH a m k - reducedPH a m' k =
      constantDiff a m m' 0 + ∑ j, reducedCoefficient a m m' j * k j
```

`ProvenHashes.ChainHash.V3.reducedPH_difference_uniform`

```lean
theorem reducedPH_difference_uniform {K : Type*} [Field K] [Fintype K]
    (a : Finset (Fin 16)) (m m' : Slot → K)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j) (z : K) :
    uniformProb (fun k : Slot → K => reducedPH a m k - reducedPH a m' k = z) =
      1 / Fintype.card K
```

## [ChainHashV3Scores.lean](ProvenHashes/ChainHashV3Scores.lean)

`ProvenHashes.ChainHash.V3.score_lower_bound`

```lean
theorem score_lower_bound (epsilon : ℕ → ℚ≥0) (L : ℕ)
    (hpos : 0 < epsilon L) (hbound : epsilon L ≤ (L : ℚ≥0)/2^63) :
    63 ≤ score epsilon L
```

`ProvenHashes.ChainHash.V3.paper_score`

```lean
theorem paper_score (L : ℕ) (hL : 0 < L) : 63 ≤ score paperEpsilon L
```

`ProvenHashes.ChainHash.V3.modelA_score`

```lean
theorem modelA_score (L : ℕ) (hL : 0 < L) : 63 ≤ score modelAEpsilon L
```

`ProvenHashes.ChainHash.V3.scores_at_one`

```lean
theorem scores_at_one : score paperEpsilon 1 = 63 ∧ score modelAEpsilon 1 = 63
```

`ProvenHashes.ChainHash.V3.paper_score_minimum`

```lean
theorem paper_score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score paperEpsilon L.val)) 63
```

`ProvenHashes.ChainHash.V3.modelA_score_minimum`

```lean
theorem modelA_score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score modelAEpsilon L.val)) 63
```

`ProvenHashes.ChainHash.V3.envelope_table`

```lean
theorem envelope_table :
    ([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20].map
      (fun L => degreeBudget L+blocks (8*L))) =
      [2,3,4,4,5,5,6,6,8,8,8,8,8,8,8,8,10,12,12,12]
```

`ProvenHashes.ChainHash.V3.envelope_large_examples`

```lean
theorem envelope_large_examples :
    ([32,121,128,129,1024,131072].map (fun L => degreeBudget L+blocks (8*L))) =
      [12,36,36,37,64,4128]
```

## [ChainHashV3Seeded.lean](ProvenHashes/ChainHashV3Seeded.lean)

`ProvenHashes.ChainHash.V3.halfPoly_comp`

```lean
theorem halfPoly_comp {K : Type*} [CommRing K] (a : Finset (Fin 16)) (m m' : Slot → K)
    (hpad : ∀ i, m (i,true)=0 ∧ m' (i,true)=0) :
    (halfPoly a m m').comp (X^2) = differencePoly a m m' 0
```

`ProvenHashes.ChainHash.V3.ph_frobenius_bound`

```lean
theorem ph_frobenius_bound {K : Type*} [Field K] [Fintype K] [CharP K 2]
    (a : Finset (Fin 16)) (m m' : Slot → K) (D : ℕ)
    (hpad : ∀ i, m (i,true)=0 ∧ m' (i,true)=0)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j)
    (hD : ∀ i, i ∈ a → m (i,false) ≠ m' (i,false) → i.val+1 ≤ D) :
    uniformProb (fun s : K => ph a m s = ph a m' s) ≤ (D : ℚ≥0)/Fintype.card K
```

`ProvenHashes.ChainHash.V3.partner_exponent_budget`

```lean
theorem partner_exponent_budget (L t : ℕ) (hL : 9 ≤ L) (j : Slot)
    (hj : wordIndex t j < L) : exponent (partner j) ≤ degreeBudget L
```

`ProvenHashes.ChainHash.V3.field_char_two`

```lean
theorem field_char_two : CharP F 2
```

`ProvenHashes.ChainHash.V3.seeded_coefficients_collision`

```lean
theorem seeded_coefficients_collision (L : ℕ) (hL : 0 < L) (m m' : Message)
    (hm : m.length ≤ 8*L) (hlen : m.length = m'.length) (hne : m ≠ m') :
    uniformProb (fun s : F => coefficientsAt m (blocks m.length) (powerKey s) =
      coefficientsAt m' (blocks m.length) (powerKey s)) ≤
      (degreeBudget L : ℚ≥0)/Fintype.card F
```

`ProvenHashes.ChainHash.V3.modelA_collision_equal_length`

```lean
theorem modelA_collision_equal_length (L : ℕ) (hL : 0 < L) (m m' : Message)
    (hm : m.length ≤ 8*L) (hlen : m.length = m'.length) (hne : m ≠ m') :
    uniformProb (fun k : ModelAKey => modelAHash k m = modelAHash k m') ≤ modelAEpsilon L
```

`ProvenHashes.ChainHash.V3.chainHashHorner_modelA_collision_bound`

```lean
theorem chainHashHorner_modelA_collision_bound (L : ℕ) (hL : 0 < L) (hcap : 8*L < 2^64)
    (m m' : Message) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : ModelAKey => modelAHash k m = modelAHash k m') ≤ modelAEpsilon L
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
theorem encode_injective : Function.Injective (encode (F := F))
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
theorem integerTwist_bijective {F : Type*} {N : ℕ} (word : F ≃ ZMod N) (τ : F) :
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

## [ModelA.lean](ProvenHashes/ModelA.lean)

`ProvenHashes.ChainHash.ModelA.chainhash_equal_length_from_seeded_stages`

```lean
theorem chainhash_equal_length_from_seeded_stages {F K J : Type*}
    [Field F] [Fintype F] [Fintype K] [Fintype J] [Nonempty K] [Nonempty J]
    (D p : ℕ) (s s' : K → List (F × F)) (g : J → F → F)
    (hlen : ∀ k, (s k).length = (s' k).length)
    (hmax : ∀ k, (s k).length ≤ p)
    (hstream : uniformProb (fun k => s k = s' k) ≤ (D : ℚ≥0) / Fintype.card F)
    (hfinal : ∀ v v', v ≠ v' → uniformProb (fun j => g j v = g j v') ≤ 1 / Fintype.card F) :
    uniformProb (fun k : (K × (Fin 3 → F)) × J =>
      g k.2 (Recurrence.hash (s k.1.1) k.1.2) =
        g k.2 (Recurrence.hash (s' k.1.1) k.1.2)) ≤
      ((D + p + 1 : ℕ) : ℚ≥0) / Fintype.card F
```

`ProvenHashes.ChainHash.ModelA.key_card`

```lean
theorem key_card : Fintype.card Key = (2 ^ 64) ^ 10
```

`ProvenHashes.ChainHash.ModelA.expandedKey_power`

```lean
theorem expandedKey_power (k : Key) (j : Fin 32) :
    fieldRepr (expandedKey k ⟨j.val, by omega⟩) = k.1.1 ^ (j.val + 1)
```

`ProvenHashes.ChainHash.ModelA.referenceHash_expanded`

```lean
theorem referenceHash_expanded (k : Key) (m : Message) :
    referenceHash (expandedKey k) m = fieldRepr.symm (hash k m)
```

`ProvenHashes.ChainHash.ModelA.probability_le_one`

```lean
theorem probability_le_one {K : Type*} [Fintype K] [Nonempty K] (E : K → Prop) :
    uniformProb E ≤ 1
```

`ProvenHashes.ChainHash.ModelA.collision_bound_fixed`

```lean
theorem collision_bound_fixed (L : ℕ) (hL : 0 < L) (m m' : Message)
    (hm : m.length = 8 * L) (hm' : m'.length = 8 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key => hash k m = hash k m') ≤ epsilonFixed L
```

`ProvenHashes.ChainHash.ModelA.reference_collision_bound_fixed`

```lean
theorem reference_collision_bound_fixed (L : ℕ) (hL : 0 < L)
    (m m' : Message) (hm : m.length = 8 * L) (hm' : m'.length = 8 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key => referenceHash (expandedKey k) m = referenceHash (expandedKey k) m') ≤
      epsilonFixed L
```

`ProvenHashes.ChainHash.ModelA.collision_bound_different_blocks`

```lean
theorem collision_bound_different_blocks (p : ℕ) (m m' : Message)
    (hlen : blockCount m ≠ blockCount m') (hm : blockCount m ≤ p) (hm' : blockCount m' ≤ p) :
    uniformProb (fun k : Key => hash k m = hash k m') ≤
      min 1 (((p + 2 : ℕ) : ℚ≥0) / 2 ^ 64)
```

`ProvenHashes.ChainHash.ModelA.envelope_arithmetic`

```lean
theorem envelope_arithmetic (L : ℕ) (hL : 0 < L) :
    0 < wordBlocks L ∧ 0 < lastGroups L ∧ lastGroups L ≤ 8 ∧
      wordBlocks L + 2 ≤ envelopeNumerator L ∧
      countBudget (wordBlocks L) (lastGroups L) + wordBlocks L + 1 ≤ envelopeNumerator L ∧
      ∀ k, 0 < k → k < wordBlocks L → countBudget k 8 + k + 1 ≤ envelopeNumerator L
```

`ProvenHashes.ChainHash.ModelA.message_cap_arithmetic`

```lean
theorem message_cap_arithmetic (L : ℕ) (hL : 0 < L) (m : Message) (hm : m.length ≤ 8 * L) :
    blockCount m ≤ wordBlocks L ∧
      (blockCount m = wordBlocks L → blockGroups m (blockCount m - 1) ≤ lastGroups L)
```

`ProvenHashes.ChainHash.ModelA.collision_bound_common_blocks`

```lean
theorem collision_bound_common_blocks (G : ℕ) (hG : 0 < G) (hG8 : G ≤ 8)
    (m m' : Message) (hm : m.length < 2 ^ 64) (hm' : m'.length < 2 ^ 64)
    (hne : m ≠ m') (hc : blockCount m = blockCount m')
    (hg : blockGroups m (blockCount m - 1) ≤ G)
    (hg' : blockGroups m' (blockCount m - 1) ≤ G) :
    uniformProb (fun k : Key => hash k m = hash k m') ≤
      ((countBudget (blockCount m) G + blockCount m + 1 : ℕ) : ℚ≥0) / 2 ^ 64
```

`ProvenHashes.ChainHash.ModelA.collision_bound_atMost`

```lean
theorem collision_bound_atMost (L : ℕ) (hL : 0 < L) (hcap : 8 * L < 2 ^ 64)
    (m m' : Message) (hm : m.length ≤ 8 * L) (hm' : m'.length ≤ 8 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key => hash k m = hash k m') ≤ epsilonAtMost L
```

`ProvenHashes.ChainHash.ModelA.reference_collision_bound_atMost`

```lean
theorem reference_collision_bound_atMost (L : ℕ) (hL : 0 < L) (hcap : 8 * L < 2 ^ 64)
    (m m' : Message) (hm : m.length ≤ 8 * L) (hm' : m'.length ≤ 8 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key => referenceHash (expandedKey k) m = referenceHash (expandedKey k) m') ≤
      epsilonAtMost L
```

## [ModelAStream.lean](ProvenHashes/ModelAStream.lean)

`ProvenHashes.ChainHash.ModelA.wordAt_zero`

```lean
theorem wordAt_zero (m : Message) (j : ℕ) (hj : m.length ≤ 8 * j) : wordAt m j = 0
```

`ProvenHashes.ChainHash.ModelA.reduce_seeded_clnh`

```lean
theorem reduce_seeded_clnh (a : Finset (Fin 16)) (m : Slot → Word 64) (s : F) :
    AdjoinRoot.mk modulus (clnh a m (seededKey s)) =
      ph a (fun j => fieldRepr (m j)) s
```

`ProvenHashes.ChainHash.ModelA.seededStream_equal_length_component`

```lean
theorem seededStream_equal_length_component (m m' : Message) (hl : m.length = m'.length)
    (t : ℕ) (ht : t < blockCount m) (s : F)
    (hs : seededStream m s = seededStream m' s) :
    ph (activePairs m t) (fun j => fieldRepr (blockData m t j)) s =
      ph (activePairs m t) (fun j => fieldRepr (blockData m' t j)) s
```

`ProvenHashes.ChainHash.ModelA.partner_exponent_budget`

```lean
theorem partner_exponent_budget (L : ℕ) (hL : 3 ≤ L) (j : Slot)
    (hj : (pairPosition j).val < L) : exponent (partner j) ≤ degreeBudget L
```

`ProvenHashes.ChainHash.ModelA.seededStream_fixed_bound`

```lean
theorem seededStream_fixed_bound (L : ℕ) (hL : 0 < L) (m m' : Message)
    (hm : m.length = 8 * L) (hm' : m'.length = 8 * L) (hne : m ≠ m') :
    uniformProb (fun s : F => seededStream m s = seededStream m' s) ≤
      (degreeBudget L : ℚ≥0) / Fintype.card F
```

`ProvenHashes.ChainHash.ModelA.reduced_lengthMask_injective`

```lean
theorem reduced_lengthMask_injective {n n' : ℕ} (hn : n < 2 ^ 64) (hn' : n' < 2 ^ 64)
    (h : AdjoinRoot.mk modulus (lengthMask n) = AdjoinRoot.mk modulus (lengthMask n')) :
    n = n'
```

`ProvenHashes.ChainHash.ModelA.blockGroups_properties`

```lean
theorem blockGroups_properties (m : Message) (t : ℕ) :
    blockGroups m t ≤ 8 ∧ activePairs m t = groupPairs (blockGroups m t)
```

`ProvenHashes.ChainHash.ModelA.seededStream_last_component`

```lean
theorem seededStream_last_component (m m' : Message) (hc : blockCount m = blockCount m')
    (s : F) (hs : seededStream m s = seededStream m' s) :
    let t := blockCount m - 1
    ph (activePairs m t) (fun j => fieldRepr (blockData m t j)) s -
      ph (activePairs m' t) (fun j => fieldRepr (blockData m' t j)) s =
      AdjoinRoot.mk modulus (lengthMask m'.length) - AdjoinRoot.mk modulus (lengthMask m.length)
```

`ProvenHashes.ChainHash.ModelA.seededStream_common_count_bound`

```lean
theorem seededStream_common_count_bound (G : ℕ) (hG : 0 < G) (hG8 : G ≤ 8)
    (m m' : Message) (hm : m.length < 2 ^ 64) (hm' : m'.length < 2 ^ 64)
    (hne : m ≠ m') (hc : blockCount m = blockCount m')
    (hg : blockGroups m (blockCount m - 1) ≤ G)
    (hg' : blockGroups m' (blockCount m - 1) ≤ G) :
    uniformProb (fun s : F => seededStream m s = seededStream m' s) ≤
      (countBudget (blockCount m) G : ℚ≥0) / Fintype.card F
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
theorem keyPolynomial_injective : Function.Injective (keyPolynomial (F := F))
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

`ProvenHashes.ChainHash.ModelA.differencePoly_coeff`

```lean
theorem differencePoly_coeff {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m m' : Slot → F) (t : F) (j : Slot) (hj : j.1 ∈ a) :
    (differencePoly a m m' t).coeff (exponent (partner j)) = m j - m' j
```

`ProvenHashes.ChainHash.ModelA.differencePoly_nonzero_degree`

```lean
theorem differencePoly_nonzero_degree {F : Type*} [Field F]
    (a : Finset (Fin 16)) (m m' : Slot → F) (t : F) (D : ℕ)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j)
    (hD : ∀ j : Slot, j.1 ∈ a → m j ≠ m' j → exponent (partner j) ≤ D) :
    differencePoly a m m' t ≠ 0 ∧ (differencePoly a m m' t).natDegree ≤ D
```

`ProvenHashes.ChainHash.ModelA.polynomial_probability_le`

```lean
theorem polynomial_probability_le {F : Type*} [Field F] [Fintype F]
    (p : F[X]) (hp : p ≠ 0) (D : ℕ) (hd : p.natDegree ≤ D) :
    uniformProb (fun s : F => p.eval s = 0) ≤ (D : ℚ≥0) / Fintype.card F
```

`ProvenHashes.ChainHash.ModelA.ph_equal_groups_bound`

```lean
theorem ph_equal_groups_bound {F : Type*} [Field F] [Fintype F]
    (a : Finset (Fin 16)) (m m' : Slot → F) (t : F) (D : ℕ)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j)
    (hD : ∀ j : Slot, j.1 ∈ a → m j ≠ m' j → exponent (partner j) ≤ D) :
    uniformProb (fun s : F => ph a m s - ph a m' s = t) ≤
      (D : ℚ≥0) / Fintype.card F
```

`ProvenHashes.ChainHash.ModelA.pairPoly_monic_degree`

```lean
theorem pairPoly_monic_degree {F : Type*} [Field F] (m : Slot → F) (i : Fin 16) :
    (pairPoly m i).Monic ∧
      (pairPoly m i).natDegree = 8 * (i.val / 2) + 2 * (i.val % 2) + 4
```

`ProvenHashes.ChainHash.ModelA.phPoly_group_degree`

```lean
theorem phPoly_group_degree {F : Type*} [Field F] (g : ℕ) (hg : 0 < g)
    (hg8 : g ≤ 8) (m : Slot → F) :
    (phPoly (groupPairs g) m).natDegree = 8 * g - 2 ∧
      (phPoly (groupPairs g) m).Monic
```

`ProvenHashes.ChainHash.ModelA.ph_unequal_groups_polynomial`

```lean
theorem ph_unequal_groups_polynomial {F : Type*} [Field F]
    (g h : ℕ) (hgh : g < h) (hh : h ≤ 8) (m m' : Slot → F) (t : F) :
    let p := phPoly (groupPairs g) m - phPoly (groupPairs h) m' - C t
    p ≠ 0 ∧ p.natDegree = 8 * h - 2
```

`ProvenHashes.ChainHash.ModelA.ph_unequal_groups_bound`

```lean
theorem ph_unequal_groups_bound {F : Type*} [Field F] [Fintype F]
    (g h : ℕ) (hgh : g < h) (hh : h ≤ 8) (m m' : Slot → F) (t : F) :
    uniformProb (fun s : F => ph (groupPairs g) m s - ph (groupPairs h) m' s = t) ≤
      ((8 * h - 2 : ℕ) : ℚ≥0) / Fintype.card F
```

`ProvenHashes.ChainHash.ModelA.cubic_linear_probability`

```lean
theorem cubic_linear_probability {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    (a b : F) (hne : a ≠ 0 ∨ b ≠ 0) :
    uniformProb (fun s : F => s ^ 3 * (a + b * s) = 0) ≤
      ((if b = 0 then 1 else 2 : ℕ) : ℚ≥0) / Fintype.card F
```

`ProvenHashes.ChainHash.ModelA.ph_small_bound`

```lean
theorem ph_small_bound {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    (m m' : Slot → F)
    (hpad : ∀ i : Fin 16, i.val < 2 → m (i, true) = 0 ∧ m' (i, true) = 0)
    (hne : m (0, false) ≠ m' (0, false) ∨ m (1, false) ≠ m' (1, false)) :
    uniformProb (fun s : F => ph (groupPairs 1) m s = ph (groupPairs 1) m' s) ≤
      ((if m (1, false) = m' (1, false) then 1 else 2 : ℕ) : ℚ≥0) / Fintype.card F
```

`ProvenHashes.ChainHash.ModelA.ph_nonzero_target_bound`

```lean
theorem ph_nonzero_target_bound {F : Type*} [Field F] [Fintype F]
    (g h G : ℕ) (hg : g ≤ G) (hh : h ≤ G) (hG : 0 < G) (hG8 : G ≤ 8)
    (m m' : Slot → F) (t : F) (ht : t ≠ 0) :
    uniformProb (fun s : F => ph (groupPairs g) m s - ph (groupPairs h) m' s = t) ≤
      ((8 * G - 2 : ℕ) : ℚ≥0) / Fintype.card F
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
    readWord m (i / 8) ⟨8 * (i % 8) + b.val, by have := b.isLt; omega⟩ =
      m.getD i 0 b
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

