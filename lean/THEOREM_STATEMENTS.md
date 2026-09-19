# Exported theorem statements

Verbatim source signatures; namespace and source are given for each.
Variables declared at module/section scope remain implicit here; see the linked module for their context.

## [BinaryField.lean](ProvenHashes/BinaryField.lean)

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

`ProvenHashes.ChainHash.wordAt_zero`

```lean
theorem wordAt_zero (m : Message) (j : ℕ) (hj : m.length ≤ 8 * j) : wordAt m j = 0
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

## [ChainHash/Bytes.lean](ProvenHashes/ChainHash/Bytes.lean)

`ProvenHashes.ChainHash.coefficientsAt_collision`

```lean
theorem coefficientsAt_collision (m m' : Message) (hlen : m.length = m'.length)
    (hne : m ≠ m') :
    uniformProb (fun k : Slot → F => coefficientsAt m (blocks m.length) k =
      coefficientsAt m' (blocks m.length) k) ≤ 1/Fintype.card F
```

`ProvenHashes.ChainHash.idealKey_collision_equal_length`

```lean
theorem idealKey_collision_equal_length (m m' : Message) (hlen : m.length = m'.length)
    (hne : m ≠ m') :
    uniformProb (fun k : IdealKey => hash k m = hash k m') ≤
      ((blocks m.length+1 : ℕ) : ℚ≥0)/2^64
```

`ProvenHashes.ChainHash.lengthField_zero`

```lean
theorem lengthField_zero : lengthField 0 = 0
```

`ProvenHashes.ChainHash.lengthField_ne_zero`

```lean
theorem lengthField_ne_zero {n : ℕ} (hn : n < 2^64) (hpos : 0 < n) : lengthField n ≠ 0
```

`ProvenHashes.ChainHash.byte_polynomial_ne`

```lean
theorem byte_polynomial_ne (m m' : Message) (hm : m.length < 2^64) (hm' : m'.length < 2^64)
    (hne : m.length ≠ m'.length) (k : Slot → F) :
    hornerPoly (lengthField m.length) (coefficients m k) -
      hornerPoly (lengthField m'.length) (coefficients m' k) ≠ 0
```

`ProvenHashes.ChainHash.horner_collision_of_nonzero`

```lean
theorem horner_collision_of_nonzero {K : Type*} [Field K] [Fintype K] {p q : ℕ}
    (ell ell' : K) (c : Fin p → K) (d : Fin q → K)
    (hne : hornerPoly ell c - hornerPoly ell' d ≠ 0) :
    uniformProb (fun y : K => hornerValue ell c y = hornerValue ell' d y) ≤
      ((max p q : ℕ) : ℚ≥0)/Fintype.card K
```

`ProvenHashes.ChainHash.family_collision_unequal_length`

```lean
theorem family_collision_unequal_length {A : Type*} [Fintype A] [Nonempty A]
    (expand : A → Slot → F) (m m' : Message)
    (hm : m.length < 2^64) (hm' : m'.length < 2^64) (hne : m.length ≠ m'.length) :
    uniformProb (fun k : (A × F) × (F × (Fin 5 → F)) =>
      hash ((expand k.1.1,k.1.2),k.2) m = hash ((expand k.1.1,k.1.2),k.2) m') ≤
      ((max (blocks m.length) (blocks m'.length)+1 : ℕ) : ℚ≥0)/2^64
```

`ProvenHashes.ChainHash.idealKey_collision_bound_message`

```lean
theorem idealKey_collision_bound_message (L : ℕ) (hL : 8*L < 2^64)
    (m m' : Message) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : IdealKey => hash k m = hash k m') ≤ idealKeyEpsilon L
```

## [ChainHash/Comb.lean](ProvenHashes/ChainHash/Comb.lean)

`ProvenHashes.ChainHash.partnerExponent_injective`

```lean
theorem partnerExponent_injective : Function.Injective (fun j => exponent (partner j))
```

`ProvenHashes.ChainHash.wordIndex_decode`

```lean
theorem wordIndex_decode (i : ℕ) : wordIndex (blockOf i) (slotOf i) = i
```

`ProvenHashes.ChainHash.blockOf_lt`

```lean
theorem blockOf_lt (i n : ℕ) (hi : 8 * i < n) : blockOf i < blocks n
```

`ProvenHashes.ChainHash.slotOf_active`

```lean
theorem slotOf_active (m : Message) (i : ℕ) (hi : 8 * i < m.length) :
    (slotOf i).1 ∈ active m (blockOf i)
```

`ProvenHashes.ChainHash.comb_encoding_injective`

```lean
theorem comb_encoding_injective (m m' : Message) (hlen : m.length = m'.length)
    (h : ∀ t, t < blocks m.length → ∀ j : Slot, j.1 ∈ active m t → data m t j = data m' t j) :
    m = m'
```

`ProvenHashes.ChainHash.blocks_pos`

```lean
theorem blocks_pos (n : ℕ) : 0 < blocks n
```

`ProvenHashes.ChainHash.blocks_mono`

```lean
theorem blocks_mono {n m : ℕ} (h : n ≤ m) : blocks n ≤ blocks m
```

`ProvenHashes.ChainHash.square_injective`

```lean
theorem square_injective {K : Type*} [Field K] [CharP K 2] :
    Function.Injective (fun x : K => x ^ 2)
```

`ProvenHashes.ChainHash.frobenius_root_count`

```lean
theorem frobenius_root_count {K : Type*} [Field K] [Fintype K] [CharP K 2]
    [DecidableEq K] (h : K[X]) (hne : h ≠ 0) :
    (Finset.univ.filter fun x : K => (h.comp (X^2)).eval x = 0).card ≤ h.natDegree
```

## [ChainHash/Evaluation.lean](ProvenHashes/ChainHash/Evaluation.lean)

`ProvenHashes.ChainHash.serialHorner_expansion`

```lean
theorem serialHorner_expansion {K : Type*} [CommSemiring K] (ell y : K) (cs : List K) :
    serialHorner ell y cs = ell*y^cs.length +
      ∑ i ∈ Finset.range cs.length, cs[i]?.getD 0 * y^i
```

`ProvenHashes.ChainHash.hornerValue_eq_serial`

```lean
theorem hornerValue_eq_serial {K : Type*} [CommRing K] {p : ℕ}
    (ell y : K) (c : Fin p → K) :
    hornerValue ell c y = serialHorner ell y (List.ofFn c)
```

`ProvenHashes.ChainHash.scheduledHorner_eq_serial`

```lean
theorem scheduledHorner_eq_serial {K : Type*} [CommSemiring K]
    (k : ℕ) (hk : 0 < k) : scheduledHorner (K := K) k = serialHorner
```

`ProvenHashes.ChainHash.map_serialHorner`

```lean
theorem map_serialHorner {R K : Type*} [CommSemiring R] [CommSemiring K]
    (reduce : R →+* K) (ell y : R) (cs : List R) :
    reduce (serialHorner ell y cs) = serialHorner (reduce ell) (reduce y) (cs.map reduce)
```

`ProvenHashes.ChainHash.raw_evaluation_independence`

```lean
theorem raw_evaluation_independence (k : ℕ) (hk : 0 < k) (ell y : BitsPolynomial) :
    (fun cs => (AdjoinRoot.mk modulus) (serialHorner ell y cs)) =
      (fun cs => scheduledHorner k ((AdjoinRoot.mk modulus) ell)
        ((AdjoinRoot.mk modulus) y) (cs.map (AdjoinRoot.mk modulus)))
```

`ProvenHashes.ChainHash.hash_evaluation_independence`

```lean
theorem hash_evaluation_independence (stride : ℕ) (hstride : 0 < stride) :
    scheduledHash stride = hash
```

## [ChainHash/Horner.lean](ProvenHashes/ChainHash/Horner.lean)

`ProvenHashes.ChainHash.hornerPoly_top`

```lean
theorem hornerPoly_top {K : Type*} [CommRing K] {p : ℕ} (ell : K) (c : Fin p → K) :
    (hornerPoly ell c).coeff p = ell
```

`ProvenHashes.ChainHash.hornerPoly_degree`

```lean
theorem hornerPoly_degree {K : Type*} [CommRing K] {p : ℕ} (ell : K) (c : Fin p → K) :
    (hornerPoly ell c).natDegree ≤ p
```

`ProvenHashes.ChainHash.hornerPoly_equal_length_difference`

```lean
theorem hornerPoly_equal_length_difference {K : Type*} [Field K] {p : ℕ}
    (ell : K) (c d : Fin p → K) (hne : c ≠ d) :
    hornerPoly ell c - hornerPoly ell d ≠ 0 ∧
      (hornerPoly ell c - hornerPoly ell d).natDegree ≤ p-1
```

`ProvenHashes.ChainHash.hornerPoly_distinct_length`

```lean
theorem hornerPoly_distinct_length {K : Type*} [Field K] {p : ℕ}
    (ell ell' : K) (c d : Fin p → K) (hne : ell ≠ ell') :
    hornerPoly ell c - hornerPoly ell' d ≠ 0
```

`ProvenHashes.ChainHash.hornerPoly_distinct_blocks`

```lean
theorem hornerPoly_distinct_blocks {K : Type*} [Field K] {p q : ℕ}
    (ell ell' : K) (c : Fin p → K) (d : Fin q → K) (hpq : q < p) (hne : ell ≠ 0) :
    hornerPoly ell c - hornerPoly ell' d ≠ 0
```

`ProvenHashes.ChainHash.hornerValue_expansion`

```lean
theorem hornerValue_expansion {K : Type*} [CommRing K] {p : ℕ}
    (ell : K) (c : Fin p → K) (y : K) :
    hornerValue ell c y = ell*y^p + ∑ i, c i*y^i.val
```

`ProvenHashes.ChainHash.horner_equal_collision`

```lean
theorem horner_equal_collision {K : Type*} [Field K] [Fintype K] {p : ℕ}
    (ell : K) (c d : Fin p → K) (hne : c ≠ d) :
    uniformProb (fun y : K => hornerValue ell c y = hornerValue ell d y) ≤
      ((p-1 : ℕ) : ℚ≥0) / Fintype.card K
```

`ProvenHashes.ChainHash.horner_equal_from_stages`

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

## [ChainHash/Keys.lean](ProvenHashes/ChainHash/Keys.lean)

`ProvenHashes.ChainHash.unposition_position`

```lean
theorem unposition_position (j : Slot) : unposition (position j) = j
```

`ProvenHashes.ChainHash.position_unposition`

```lean
theorem position_unposition (i : Fin 32) : position (unposition i) = i
```

`ProvenHashes.ChainHash.encode_decodeIdeal`

```lean
theorem encode_decodeIdeal (k : Key39) : encodeIdeal (decodeIdeal k) = k
```

`ProvenHashes.ChainHash.decode_encodeIdeal`

```lean
theorem decode_encodeIdeal (k : IdealKey) : decodeIdeal (encodeIdeal k) = k
```

`ProvenHashes.ChainHash.encode_decodeKey`

```lean
theorem encode_decodeKey (k : Key8) : encodeKey (decodeKey k) = k
```

`ProvenHashes.ChainHash.decode_encodeKey`

```lean
theorem decode_encodeKey (k : Key) : decodeKey (encodeKey k) = k
```

`ProvenHashes.ChainHash.expandedWords_power`

```lean
theorem expandedWords_power (k : Key) (j : Fin 32) :
    fieldRepr (expandedWords k ⟨j.val,by omega⟩) = k.1.1^(j.val+1)
```

`ProvenHashes.ChainHash.encode_decodeKeyBytes`

```lean
theorem encode_decodeKeyBytes (n : ℕ) (b : Fin (8*n) → Byte) :
    encodeKeyBytes n (decodeKeyBytes n b) = b
```

`ProvenHashes.ChainHash.decode_encodeKeyBytes`

```lean
theorem decode_encodeKeyBytes (n : ℕ) (w : Fin n → Word 64) :
    decodeKeyBytes n (encodeKeyBytes n w) = w
```

`ProvenHashes.ChainHash.digestWord_injective`

```lean
theorem digestWord_injective : Function.Injective digestWord
```

`ProvenHashes.ChainHash.ideal_key_collision_bound`

```lean
theorem ideal_key_collision_bound (L : ℕ) (hL : 8*L < 2^64)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Key39 => idealHashBytes k m = idealHashBytes k m') ≤ idealKeyEpsilon L
```

`ProvenHashes.ChainHash.collision_bound`

```lean
theorem collision_bound (L : ℕ) (hL : 0 < L) (hcap : 8*L < 2^64)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Fin 64 → Byte => chainHashBytes k m = chainHashBytes k m') ≤ epsilon L
```

## [ChainHash/Lazy.lean](ProvenHashes/ChainHash/Lazy.lean)

`ProvenHashes.ChainHash.rawPolynomial_degree`

```lean
theorem rawPolynomial_degree (u : RawState) : (rawPolynomial u).natDegree < 128
```

`ProvenHashes.ChainHash.rawPolynomial_split`

```lean
theorem rawPolynomial_split (p : BitsPolynomial) (hp : p.natDegree < 128) :
    rawPolynomial (splitRaw p) = p
```

`ProvenHashes.ChainHash.alpha_eq_tail`

```lean
theorem alpha_eq_tail : alpha = (AdjoinRoot.mk modulus) (X^4+X^3+X+1)
```

`ProvenHashes.ChainHash.tail_word_27`

```lean
theorem tail_word_27 : (pack 64 (lengthWord 27)) = (X^4+X^3+X+1 : BitsPolynomial)
```

`ProvenHashes.ChainHash.alpha_eq_27`

```lean
theorem alpha_eq_27 : alpha = fieldRepr (lengthWord 27)
```

`ProvenHashes.ChainHash.lazyRawStep_degree`

```lean
theorem lazyRawStep_degree (y : Word 64) (u c : RawState) :
    (lazyRawStep y u c).natDegree < 128
```

`ProvenHashes.ChainHash.lazyStep_reduce`

```lean
theorem lazyStep_reduce (y : Word 64) (u c : RawState) :
    rawReduce (lazyStep y u c) = fieldRepr y * rawReduce u + rawReduce c
```

`ProvenHashes.ChainHash.lazyHorner_eq_serial`

```lean
theorem lazyHorner_eq_serial (ell : RawState) (y : Word 64) :
    (fun cs => rawReduce (lazyHorner ell y cs)) =
      (fun cs => serialHorner (rawReduce ell) (fieldRepr y) (cs.map rawReduce))
```

`ProvenHashes.ChainHash.lazyHorner_eq_schedule`

```lean
theorem lazyHorner_eq_schedule (k : ℕ) (hk : 0 < k) (ell : RawState) (y : Word 64) :
    (fun cs => rawReduce (lazyHorner ell y cs)) =
      (fun cs => scheduledHorner k (rawReduce ell) (fieldRepr y) (cs.map rawReduce))
```

`ProvenHashes.ChainHash.reduce_clnh`

```lean
theorem reduce_clnh (a : Finset (Fin 16)) (m k : Slot → Word 64) :
    (AdjoinRoot.mk modulus) (clnh a m k) =
      reducedPH a (fun j => fieldRepr (m j)) (fun j => fieldRepr (k j))
```

`ProvenHashes.ChainHash.rawBlock_matches`

```lean
theorem rawBlock_matches (m : Message) (k : Slot → F) (t : ℕ) :
    rawReduce (rawBlock m k t) = reducedPH (active m t) (data m t) k
```

`ProvenHashes.ChainHash.rawCoefficients_matches`

```lean
theorem rawCoefficients_matches (m : Message) (k : Slot → F) :
    (rawCoefficients m k).map rawReduce = List.ofFn (coefficients m k)
```

`ProvenHashes.ChainHash.rawLength_matches`

```lean
theorem rawLength_matches (n : ℕ) : rawReduce (lengthWord n,0) = lengthField n
```

`ProvenHashes.ChainHash.lazyHash_eq_hash`

```lean
theorem lazyHash_eq_hash : lazyHash = hash
```

`ProvenHashes.ChainHash.evaluation_independence`

```lean
theorem evaluation_independence (k : ℕ) (hk : 0 < k) :
    scheduledHash k = hash ∧ lazyHash = hash
```

## [ChainHash/Model.lean](ProvenHashes/ChainHash/Model.lean)

`ProvenHashes.ChainHash.idealKey_card`

```lean
theorem idealKey_card : Fintype.card IdealKey = (2^64)^39
```

`ProvenHashes.ChainHash.key_card`

```lean
theorem key_card : Fintype.card Key = (2^64)^8
```

`ProvenHashes.ChainHash.lengthField_injective`

```lean
theorem lengthField_injective {n m : ℕ} (hn : n < 2^64) (hm : m < 2^64)
    (h : lengthField n = lengthField m) : n = m
```

`ProvenHashes.ChainHash.idealKey_envelope_arithmetic`

```lean
theorem idealKey_envelope_arithmetic (L : ℕ) (hL : 0 < L) : blocks (8*L)+1 ≤ 2*L
```

`ProvenHashes.ChainHash.envelope_arithmetic`

```lean
theorem envelope_arithmetic (L : ℕ) (hL : 0 < L) :
    degreeBudget L + blocks (8*L) ≤ 2*L
```

`ProvenHashes.ChainHash.idealKey_score_ratio`

```lean
theorem idealKey_score_ratio (L : ℕ) (hL : 0 < L) :
    idealKeyEpsilon L ≤ (L : ℚ≥0)/2^63
```

`ProvenHashes.ChainHash.score_ratio`

```lean
theorem score_ratio (L : ℕ) (hL : 0 < L) :
    epsilon L ≤ (L : ℚ≥0)/2^63
```

`ProvenHashes.ChainHash.score_attained`

```lean
theorem score_attained : idealKeyEpsilon 1 = 1/2^63 ∧ epsilon 1 = 1/2^63
```

## [ChainHash/PH.lean](ProvenHashes/ChainHash/PH.lean)

`ProvenHashes.ChainHash.eval_phPoly`

```lean
theorem eval_phPoly {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m : Slot → F) (s : F) : (phPoly a m).eval s = ph a m s
```

`ProvenHashes.ChainHash.phPoly_difference`

```lean
theorem phPoly_difference {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m m' : Slot → F) (t : F) :
    phPoly a m - phPoly a m' - C t = differencePoly a m m' t
```

`ProvenHashes.ChainHash.differencePoly_coeff`

```lean
theorem differencePoly_coeff {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m m' : Slot → F) (t : F) (j : Slot) (hj : j.1 ∈ a) :
    (differencePoly a m m' t).coeff (exponent (partner j)) = m j - m' j
```

`ProvenHashes.ChainHash.differencePoly_nonzero_degree`

```lean
theorem differencePoly_nonzero_degree {F : Type*} [Field F]
    (a : Finset (Fin 16)) (m m' : Slot → F) (t : F) (D : ℕ)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j)
    (hD : ∀ j : Slot, j.1 ∈ a → m j ≠ m' j → exponent (partner j) ≤ D) :
    differencePoly a m m' t ≠ 0 ∧ (differencePoly a m m' t).natDegree ≤ D
```

`ProvenHashes.ChainHash.polynomial_probability_le`

```lean
theorem polynomial_probability_le {F : Type*} [Field F] [Fintype F]
    (p : F[X]) (hp : p ≠ 0) (D : ℕ) (hd : p.natDegree ≤ D) :
    uniformProb (fun s : F => p.eval s = 0) ≤ (D : ℚ≥0) / Fintype.card F
```

`ProvenHashes.ChainHash.ph_equal_groups_bound`

```lean
theorem ph_equal_groups_bound {F : Type*} [Field F] [Fintype F]
    (a : Finset (Fin 16)) (m m' : Slot → F) (t : F) (D : ℕ)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j)
    (hD : ∀ j : Slot, j.1 ∈ a → m j ≠ m' j → exponent (partner j) ≤ D) :
    uniformProb (fun s : F => ph a m s - ph a m' s = t) ≤
      (D : ℚ≥0) / Fintype.card F
```

`ProvenHashes.ChainHash.reducedPH_difference`

```lean
theorem reducedPH_difference {K : Type*} [Field K]
    (a : Finset (Fin 16)) (m m' k : Slot → K) :
    reducedPH a m k - reducedPH a m' k =
      constantDiff a m m' 0 + ∑ j, reducedCoefficient a m m' j * k j
```

`ProvenHashes.ChainHash.reducedPH_difference_uniform`

```lean
theorem reducedPH_difference_uniform {K : Type*} [Field K] [Fintype K]
    (a : Finset (Fin 16)) (m m' : Slot → K)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j) (z : K) :
    uniformProb (fun k : Slot → K => reducedPH a m k - reducedPH a m' k = z) =
      1 / Fintype.card K
```

## [ChainHash/Scores.lean](ProvenHashes/ChainHash/Scores.lean)

`ProvenHashes.ChainHash.score_lower_bound`

```lean
theorem score_lower_bound (epsilon : ℕ → ℚ≥0) (L : ℕ)
    (hpos : 0 < epsilon L) (hbound : epsilon L ≤ (L : ℚ≥0)/2^63) :
    63 ≤ score epsilon L
```

`ProvenHashes.ChainHash.idealKey_score`

```lean
theorem idealKey_score (L : ℕ) (hL : 0 < L) : 63 ≤ score idealKeyEpsilon L
```

`ProvenHashes.ChainHash.epsilon_score`

```lean
theorem epsilon_score (L : ℕ) (hL : 0 < L) : 63 ≤ score epsilon L
```

`ProvenHashes.ChainHash.scores_at_one`

```lean
theorem scores_at_one : score idealKeyEpsilon 1 = 63 ∧ score epsilon 1 = 63
```

`ProvenHashes.ChainHash.ideal_key_score_minimum`

```lean
theorem ideal_key_score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score idealKeyEpsilon L.val)) 63
```

`ProvenHashes.ChainHash.score_minimum`

```lean
theorem score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score epsilon L.val)) 63
```

`ProvenHashes.ChainHash.envelope_table`

```lean
theorem envelope_table :
    ([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20].map
      (fun L => degreeBudget L+blocks (8*L))) =
      [2,3,4,4,5,5,6,6,8,8,8,8,8,8,8,8,10,12,12,12]
```

`ProvenHashes.ChainHash.envelope_large_examples`

```lean
theorem envelope_large_examples :
    ([32,121,128,129,1024,131072].map (fun L => degreeBudget L+blocks (8*L))) =
      [12,36,36,37,64,4128]
```

## [ChainHash/Seeded.lean](ProvenHashes/ChainHash/Seeded.lean)

`ProvenHashes.ChainHash.halfPoly_comp`

```lean
theorem halfPoly_comp {K : Type*} [CommRing K] (a : Finset (Fin 16)) (m m' : Slot → K)
    (hpad : ∀ i, m (i,true)=0 ∧ m' (i,true)=0) :
    (halfPoly a m m').comp (X^2) = differencePoly a m m' 0
```

`ProvenHashes.ChainHash.ph_frobenius_bound`

```lean
theorem ph_frobenius_bound {K : Type*} [Field K] [Fintype K] [CharP K 2]
    (a : Finset (Fin 16)) (m m' : Slot → K) (D : ℕ)
    (hpad : ∀ i, m (i,true)=0 ∧ m' (i,true)=0)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j)
    (hD : ∀ i, i ∈ a → m (i,false) ≠ m' (i,false) → i.val+1 ≤ D) :
    uniformProb (fun s : K => ph a m s = ph a m' s) ≤ (D : ℚ≥0)/Fintype.card K
```

`ProvenHashes.ChainHash.partner_exponent_budget`

```lean
theorem partner_exponent_budget (L t : ℕ) (hL : 9 ≤ L) (j : Slot)
    (hj : wordIndex t j < L) : exponent (partner j) ≤ degreeBudget L
```

`ProvenHashes.ChainHash.field_char_two`

```lean
theorem field_char_two : CharP F 2
```

`ProvenHashes.ChainHash.seeded_coefficients_collision`

```lean
theorem seeded_coefficients_collision (L : ℕ) (hL : 0 < L) (m m' : Message)
    (hm : m.length ≤ 8*L) (hlen : m.length = m'.length) (hne : m ≠ m') :
    uniformProb (fun s : F => coefficientsAt m (blocks m.length) (powerKey s) =
      coefficientsAt m' (blocks m.length) (powerKey s)) ≤
      (degreeBudget L : ℚ≥0)/Fintype.card F
```

`ProvenHashes.ChainHash.collision_equal_length`

```lean
theorem collision_equal_length (L : ℕ) (hL : 0 < L) (m m' : Message)
    (hm : m.length ≤ 8*L) (hlen : m.length = m'.length) (hne : m ≠ m') :
    uniformProb (fun k : Key => chainHash k m = chainHash k m') ≤ epsilon L
```

`ProvenHashes.ChainHash.collision_bound_message`

```lean
theorem collision_bound_message (L : ℕ) (hL : 0 < L) (hcap : 8*L < 2^64)
    (m m' : Message) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Key => chainHash k m = chainHash k m') ≤ epsilon L
```

## [ChainHash128/BinaryField.lean](ProvenHashes/ChainHash128/BinaryField.lean)

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

`ProvenHashes.ChainHash128.wordAt_zero`

```lean
theorem wordAt_zero (m : Message) (j : ℕ) (hj : m.length ≤ 16 * j) : wordAt m j = 0
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

`ProvenHashes.ChainHash128.outputBytes_length`

```lean
theorem outputBytes_length (w : Word 128) : (outputBytes w).length = 16
```

`ProvenHashes.ChainHash128.outputBytes_decode`

```lean
theorem outputBytes_decode (w : Word 128) : wordAt (outputBytes w) 0 = w
```

`ProvenHashes.ChainHash128.outputBytes_injective`

```lean
theorem outputBytes_injective : Function.Injective outputBytes
```

## [ChainHash128/ByteInterface.lean](ProvenHashes/ChainHash128/ByteInterface.lean)

`ProvenHashes.ChainHash128.bytesToMessage_injective`

```lean
theorem bytesToMessage_injective : Function.Injective bytesToMessage
```

## [ChainHash128/Bytes.lean](ProvenHashes/ChainHash128/Bytes.lean)

`ProvenHashes.ChainHash128.coefficientsAt_collision`

```lean
theorem coefficientsAt_collision (m m' : Message) (hlen : m.length = m'.length)
    (hne : m ≠ m') :
    uniformProb (fun k : Slot → F => coefficientsAt m (blocks m.length) k =
      coefficientsAt m' (blocks m.length) k) ≤ 1/Fintype.card F
```

`ProvenHashes.ChainHash128.idealKey_collision_equal_length`

```lean
theorem idealKey_collision_equal_length (m m' : Message) (hlen : m.length = m'.length)
    (hne : m ≠ m') :
    uniformProb (fun k : IdealKey => hash k m = hash k m') ≤
      ((blocks m.length+1 : ℕ) : ℚ≥0)/2^128
```

`ProvenHashes.ChainHash128.lengthField_zero`

```lean
theorem lengthField_zero : lengthField 0 = 0
```

`ProvenHashes.ChainHash128.lengthField_ne_zero`

```lean
theorem lengthField_ne_zero {n : ℕ} (hn : n < 2^128) (hpos : 0 < n) : lengthField n ≠ 0
```

`ProvenHashes.ChainHash128.byte_polynomial_ne`

```lean
theorem byte_polynomial_ne (m m' : Message) (hm : m.length < 2^128) (hm' : m'.length < 2^128)
    (hne : m.length ≠ m'.length) (k : Slot → F) :
    hornerPoly (lengthField m.length) (coefficients m k) -
      hornerPoly (lengthField m'.length) (coefficients m' k) ≠ 0
```

`ProvenHashes.ChainHash128.horner_collision_of_nonzero`

```lean
theorem horner_collision_of_nonzero {K : Type*} [Field K] [Fintype K] {p q : ℕ}
    (ell ell' : K) (c : Fin p → K) (d : Fin q → K)
    (hne : hornerPoly ell c - hornerPoly ell' d ≠ 0) :
    uniformProb (fun y : K => hornerValue ell c y = hornerValue ell' d y) ≤
      ((max p q : ℕ) : ℚ≥0)/Fintype.card K
```

`ProvenHashes.ChainHash128.family_collision_unequal_length`

```lean
theorem family_collision_unequal_length {A : Type*} [Fintype A] [Nonempty A]
    (expand : A → Slot → F) (m m' : Message)
    (hm : m.length < 2^128) (hm' : m'.length < 2^128) (hne : m.length ≠ m'.length) :
    uniformProb (fun k : (A × F) × (F × (Fin 5 → F)) =>
      hash ((expand k.1.1,k.1.2),k.2) m = hash ((expand k.1.1,k.1.2),k.2) m') ≤
      ((max (blocks m.length) (blocks m'.length)+1 : ℕ) : ℚ≥0)/2^128
```

`ProvenHashes.ChainHash128.idealKey_collision_bound_message`

```lean
theorem idealKey_collision_bound_message (L : ℕ) (hL : 8*L < 2^128)
    (m m' : Message) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : IdealKey => hash k m = hash k m') ≤ idealKeyEpsilon L
```

`ProvenHashes.ChainHash128.idealKey_collision_bound_message_blocks`

```lean
theorem idealKey_collision_bound_message_blocks (p : ℕ) (m m' : Message)
    (hm : m.length < 2^128) (hm' : m'.length < 2^128) (hne : m ≠ m')
    (hp : blocks m.length ≤ p) (hp' : blocks m'.length ≤ p) :
    uniformProb (fun k : IdealKey => hash k m = hash k m') ≤
      min 1 (((p+1 : ℕ) : ℚ≥0)/2^128)
```

## [ChainHash128/Comb.lean](ProvenHashes/ChainHash128/Comb.lean)

`ProvenHashes.ChainHash128.partnerExponent_injective`

```lean
theorem partnerExponent_injective : Function.Injective (fun j => exponent (partner j))
```

`ProvenHashes.ChainHash128.wordIndex_decode`

```lean
theorem wordIndex_decode (i : ℕ) : wordIndex (blockOf i) (slotOf i) = i
```

`ProvenHashes.ChainHash128.blockOf_lt`

```lean
theorem blockOf_lt (i n : ℕ) (hi : 16 * i < n) : blockOf i < blocks n
```

`ProvenHashes.ChainHash128.slotOf_active`

```lean
theorem slotOf_active (m : Message) (i : ℕ) (hi : 16 * i < m.length) :
    (slotOf i).1 ∈ active m (blockOf i)
```

`ProvenHashes.ChainHash128.comb_encoding_injective`

```lean
theorem comb_encoding_injective (m m' : Message) (hlen : m.length = m'.length)
    (h : ∀ t, t < blocks m.length → ∀ j : Slot, j.1 ∈ active m t → data m t j = data m' t j) :
    m = m'
```

`ProvenHashes.ChainHash128.blocks_pos`

```lean
theorem blocks_pos (n : ℕ) : 0 < blocks n
```

`ProvenHashes.ChainHash128.blocks_mono`

```lean
theorem blocks_mono {n m : ℕ} (h : n ≤ m) : blocks n ≤ blocks m
```

`ProvenHashes.ChainHash128.blocks_examples`

```lean
theorem blocks_examples :
    ([0,1,17,33,113,256,2048,2049,4096,4097].map blocks) = [1,1,2,3,8,8,8,8,8,9]
```

`ProvenHashes.ChainHash128.square_injective`

```lean
theorem square_injective {K : Type*} [Field K] [CharP K 2] :
    Function.Injective (fun x : K => x ^ 2)
```

`ProvenHashes.ChainHash128.frobenius_root_count`

```lean
theorem frobenius_root_count {K : Type*} [Field K] [Fintype K] [CharP K 2]
    [DecidableEq K] (h : K[X]) (hne : h ≠ 0) :
    (Finset.univ.filter fun x : K => (h.comp (X^2)).eval x = 0).card ≤ h.natDegree
```

## [ChainHash128/ConcreteWords.lean](ProvenHashes/ChainHash128/ConcreteWords.lean)

`ProvenHashes.ChainHash128.clnh_natDegree_le`

```lean
theorem clnh_natDegree_le {I : Type*} [DecidableEq I]
    (s : Finset I) (m k : I × Bool → Word 128) : (clnh s m k).natDegree ≤ 254
```

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

`ProvenHashes.ChainHash128.field_card`

```lean
theorem field_card {F : Type*} [AddGroup F] [Fintype F] (repr : Word 128 ≃+ F) :
    Fintype.card F = 2 ^ 128
```

## [ChainHash128/Evaluation.lean](ProvenHashes/ChainHash128/Evaluation.lean)

`ProvenHashes.ChainHash128.serialHorner_expansion`

```lean
theorem serialHorner_expansion {K : Type*} [CommSemiring K] (ell y : K) (cs : List K) :
    serialHorner ell y cs = ell*y^cs.length +
      ∑ i ∈ Finset.range cs.length, cs[i]?.getD 0 * y^i
```

`ProvenHashes.ChainHash128.hornerValue_eq_serial`

```lean
theorem hornerValue_eq_serial {K : Type*} [CommRing K] {p : ℕ}
    (ell y : K) (c : Fin p → K) :
    hornerValue ell c y = serialHorner ell y (List.ofFn c)
```

`ProvenHashes.ChainHash128.scheduledHorner_eq_serial`

```lean
theorem scheduledHorner_eq_serial {K : Type*} [CommSemiring K]
    (k : ℕ) (hk : 0 < k) : scheduledHorner (K := K) k = serialHorner
```

`ProvenHashes.ChainHash128.map_serialHorner`

```lean
theorem map_serialHorner {R K : Type*} [CommSemiring R] [CommSemiring K]
    (reduce : R →+* K) (ell y : R) (cs : List R) :
    reduce (serialHorner ell y cs) = serialHorner (reduce ell) (reduce y) (cs.map reduce)
```

`ProvenHashes.ChainHash128.raw_evaluation_independence`

```lean
theorem raw_evaluation_independence (k : ℕ) (hk : 0 < k) (ell y : BitsPolynomial) :
    (fun cs => (AdjoinRoot.mk modulus) (serialHorner ell y cs)) =
      (fun cs => scheduledHorner k ((AdjoinRoot.mk modulus) ell)
        ((AdjoinRoot.mk modulus) y) (cs.map (AdjoinRoot.mk modulus)))
```

`ProvenHashes.ChainHash128.hash_evaluation_independence`

```lean
theorem hash_evaluation_independence (stride : ℕ) (hstride : 0 < stride) :
    scheduledHash stride = hash
```

## [ChainHash128/Horner.lean](ProvenHashes/ChainHash128/Horner.lean)

`ProvenHashes.ChainHash128.hornerPoly_top`

```lean
theorem hornerPoly_top {K : Type*} [CommRing K] {p : ℕ} (ell : K) (c : Fin p → K) :
    (hornerPoly ell c).coeff p = ell
```

`ProvenHashes.ChainHash128.hornerPoly_degree`

```lean
theorem hornerPoly_degree {K : Type*} [CommRing K] {p : ℕ} (ell : K) (c : Fin p → K) :
    (hornerPoly ell c).natDegree ≤ p
```

`ProvenHashes.ChainHash128.hornerPoly_equal_length_difference`

```lean
theorem hornerPoly_equal_length_difference {K : Type*} [Field K] {p : ℕ}
    (ell : K) (c d : Fin p → K) (hne : c ≠ d) :
    hornerPoly ell c - hornerPoly ell d ≠ 0 ∧
      (hornerPoly ell c - hornerPoly ell d).natDegree ≤ p-1
```

`ProvenHashes.ChainHash128.hornerPoly_distinct_length`

```lean
theorem hornerPoly_distinct_length {K : Type*} [Field K] {p : ℕ}
    (ell ell' : K) (c d : Fin p → K) (hne : ell ≠ ell') :
    hornerPoly ell c - hornerPoly ell' d ≠ 0
```

`ProvenHashes.ChainHash128.hornerPoly_distinct_blocks`

```lean
theorem hornerPoly_distinct_blocks {K : Type*} [Field K] {p q : ℕ}
    (ell ell' : K) (c : Fin p → K) (d : Fin q → K) (hpq : q < p) (hne : ell ≠ 0) :
    hornerPoly ell c - hornerPoly ell' d ≠ 0
```

`ProvenHashes.ChainHash128.hornerValue_expansion`

```lean
theorem hornerValue_expansion {K : Type*} [CommRing K] {p : ℕ}
    (ell : K) (c : Fin p → K) (y : K) :
    hornerValue ell c y = ell*y^p + ∑ i, c i*y^i.val
```

`ProvenHashes.ChainHash128.horner_equal_collision`

```lean
theorem horner_equal_collision {K : Type*} [Field K] [Fintype K] {p : ℕ}
    (ell : K) (c d : Fin p → K) (hne : c ≠ d) :
    uniformProb (fun y : K => hornerValue ell c y = hornerValue ell d y) ≤
      ((p-1 : ℕ) : ℚ≥0) / Fintype.card K
```

`ProvenHashes.ChainHash128.horner_equal_from_stages`

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

## [ChainHash128/Keys.lean](ProvenHashes/ChainHash128/Keys.lean)

`ProvenHashes.ChainHash128.unposition_position`

```lean
theorem unposition_position (j : Slot) : unposition (position j) = j
```

`ProvenHashes.ChainHash128.position_unposition`

```lean
theorem position_unposition (i : Fin 32) : position (unposition i) = i
```

`ProvenHashes.ChainHash128.encode_decodeIdeal`

```lean
theorem encode_decodeIdeal (k : Key39) : encodeIdeal (decodeIdeal k) = k
```

`ProvenHashes.ChainHash128.decode_encodeIdeal`

```lean
theorem decode_encodeIdeal (k : IdealKey) : decodeIdeal (encodeIdeal k) = k
```

`ProvenHashes.ChainHash128.encode_decodeKey`

```lean
theorem encode_decodeKey (k : Key8) : encodeKey (decodeKey k) = k
```

`ProvenHashes.ChainHash128.decode_encodeKey`

```lean
theorem decode_encodeKey (k : Key) : decodeKey (encodeKey k) = k
```

`ProvenHashes.ChainHash128.expandedWords_power`

```lean
theorem expandedWords_power (k : Key) (j : Fin 32) :
    fieldRepr (expandedWords k ⟨j.val,by omega⟩) = k.1.1^(j.val+1)
```

`ProvenHashes.ChainHash128.encode_decodeKeyBytes`

```lean
theorem encode_decodeKeyBytes (n : ℕ) (b : Fin (16*n) → Byte) :
    encodeKeyBytes n (decodeKeyBytes n b) = b
```

`ProvenHashes.ChainHash128.decode_encodeKeyBytes`

```lean
theorem decode_encodeKeyBytes (n : ℕ) (w : Fin n → Word 128) :
    decodeKeyBytes n (encodeKeyBytes n w) = w
```

`ProvenHashes.ChainHash128.digestWord_injective`

```lean
theorem digestWord_injective : Function.Injective digestWord
```

`ProvenHashes.ChainHash128.digestBytes_injective`

```lean
theorem digestBytes_injective : Function.Injective digestBytes
```

`ProvenHashes.ChainHash128.ideal_key_collision_bound`

```lean
theorem ideal_key_collision_bound (L : ℕ) (hL : 8*L < 2^128)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Key39 => idealHashBytes k m = idealHashBytes k m') ≤ idealKeyEpsilon L
```

`ProvenHashes.ChainHash128.ideal_key_collision_bound_key_bytes`

```lean
theorem ideal_key_collision_bound_key_bytes (L : ℕ) (hL : 8*L < 2^128)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Fin 624 → Byte => idealHashKeyBytes k m = idealHashKeyBytes k m') ≤
      idealKeyEpsilon L
```

`ProvenHashes.ChainHash128.ideal_key_collision_bound_output`

```lean
theorem ideal_key_collision_bound_output (L : ℕ) (hL : 8*L < 2^128)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Key39 => hashOutput k m = hashOutput k m') ≤ idealKeyEpsilon L
```

`ProvenHashes.ChainHash128.collision_bound`

```lean
theorem collision_bound (L : ℕ) (hL : 0 < L) (hcap : 8*L < 2^128)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Fin 128 → Byte => chainHashBytes k m = chainHashBytes k m') ≤
      epsilon L
```

`ProvenHashes.ChainHash128.coarse_collision_bound`

```lean
theorem coarse_collision_bound (L : ℕ) (hL : 0 < L) (hcap : 8*L < 2^128)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Fin 128 → Byte => chainHashBytes k m = chainHashBytes k m') ≤
      coarseEpsilon L
```

`ProvenHashes.ChainHash128.ideal_key_collision_bound_blocks`

```lean
theorem ideal_key_collision_bound_blocks (p : ℕ) (m m' : List UInt8)
    (hm : m.length < 2^128) (hm' : m'.length < 2^128) (hne : m ≠ m')
    (hp : blocks m.length ≤ p) (hp' : blocks m'.length ≤ p) :
    uniformProb (fun k : Key39 => idealHashBytes k m = idealHashBytes k m') ≤
      min 1 (((p+1 : ℕ) : ℚ≥0)/2^128)
```

`ProvenHashes.ChainHash128.coarse_collision_bound_blocks`

```lean
theorem coarse_collision_bound_blocks (p : ℕ) (m m' : List UInt8)
    (hm : m.length < 2^128) (hm' : m'.length < 2^128) (hne : m ≠ m')
    (hp : blocks m.length ≤ p) (hp' : blocks m'.length ≤ p) :
    uniformProb (fun k : Fin 128 → Byte => chainHashBytes k m = chainHashBytes k m') ≤
      min 1 (((p+32 : ℕ) : ℚ≥0)/2^128)
```

## [ChainHash128/Lazy.lean](ProvenHashes/ChainHash128/Lazy.lean)

`ProvenHashes.ChainHash128.rawPolynomial_degree`

```lean
theorem rawPolynomial_degree (u : RawState) : (rawPolynomial u).natDegree < 256
```

`ProvenHashes.ChainHash128.rawPolynomial_split`

```lean
theorem rawPolynomial_split (p : BitsPolynomial) (hp : p.natDegree < 256) :
    rawPolynomial (splitRaw p) = p
```

`ProvenHashes.ChainHash128.alpha_eq_tail`

```lean
theorem alpha_eq_tail : alpha = (AdjoinRoot.mk modulus) (X^7+X^2+X+1)
```

`ProvenHashes.ChainHash128.testBit_135`

```lean
theorem testBit_135 (i : ℕ) (hi : 8 ≤ i) : Nat.testBit 135 i = false
```

`ProvenHashes.ChainHash128.tail_word_135`

```lean
theorem tail_word_135 : (pack 128 (lengthWord 135)) = (X^7+X^2+X+1 : BitsPolynomial)
```

`ProvenHashes.ChainHash128.alpha_eq_135`

```lean
theorem alpha_eq_135 : alpha = fieldRepr (lengthWord 135)
```

`ProvenHashes.ChainHash128.lazyRawStep_degree`

```lean
theorem lazyRawStep_degree (y : Word 128) (u c : RawState) :
    (lazyRawStep y u c).natDegree < 256
```

`ProvenHashes.ChainHash128.lazyStep_reduce`

```lean
theorem lazyStep_reduce (y : Word 128) (u c : RawState) :
    rawReduce (lazyStep y u c) = fieldRepr y * rawReduce u + rawReduce c
```

`ProvenHashes.ChainHash128.lazyHorner_eq_serial`

```lean
theorem lazyHorner_eq_serial (ell : RawState) (y : Word 128) :
    (fun cs => rawReduce (lazyHorner ell y cs)) =
      (fun cs => serialHorner (rawReduce ell) (fieldRepr y) (cs.map rawReduce))
```

`ProvenHashes.ChainHash128.lazyHorner_eq_schedule`

```lean
theorem lazyHorner_eq_schedule (k : ℕ) (hk : 0 < k) (ell : RawState) (y : Word 128) :
    (fun cs => rawReduce (lazyHorner ell y cs)) =
      (fun cs => scheduledHorner k (rawReduce ell) (fieldRepr y) (cs.map rawReduce))
```

`ProvenHashes.ChainHash128.reduce_clnh`

```lean
theorem reduce_clnh (a : Finset (Fin 16)) (m k : Slot → Word 128) :
    (AdjoinRoot.mk modulus) (clnh a m k) =
      reducedPH a (fun j => fieldRepr (m j)) (fun j => fieldRepr (k j))
```

`ProvenHashes.ChainHash128.rawBlock_matches`

```lean
theorem rawBlock_matches (m : Message) (k : Slot → F) (t : ℕ) :
    rawReduce (rawBlock m k t) = reducedPH (active m t) (data m t) k
```

`ProvenHashes.ChainHash128.rawCoefficients_matches`

```lean
theorem rawCoefficients_matches (m : Message) (k : Slot → F) :
    (rawCoefficients m k).map rawReduce = List.ofFn (coefficients m k)
```

`ProvenHashes.ChainHash128.rawLength_matches`

```lean
theorem rawLength_matches (n : ℕ) : rawReduce (lengthWord n,0) = lengthField n
```

`ProvenHashes.ChainHash128.lazyHash_eq_hash`

```lean
theorem lazyHash_eq_hash : lazyHash = hash
```

`ProvenHashes.ChainHash128.evaluation_independence`

```lean
theorem evaluation_independence (k : ℕ) (hk : 0 < k) :
    scheduledHash k = hash ∧ lazyHash = hash
```

## [ChainHash128/Model.lean](ProvenHashes/ChainHash128/Model.lean)

`ProvenHashes.ChainHash128.idealKey_card`

```lean
theorem idealKey_card : Fintype.card IdealKey = (2^128)^39
```

`ProvenHashes.ChainHash128.key_card`

```lean
theorem key_card : Fintype.card Key = (2^128)^8
```

`ProvenHashes.ChainHash128.lengthField_injective`

```lean
theorem lengthField_injective {n m : ℕ} (hn : n < 2^128) (hm : m < 2^128)
    (h : lengthField n = lengthField m) : n = m
```

`ProvenHashes.ChainHash128.blocks_le_words`

```lean
theorem blocks_le_words (L : ℕ) (hL : 0 < L) : blocks (8*L) ≤ L
```

`ProvenHashes.ChainHash128.degreeBudget_pos`

```lean
theorem degreeBudget_pos (L : ℕ) : 1 ≤ degreeBudget L
```

`ProvenHashes.ChainHash128.degreeBudget_le`

```lean
theorem degreeBudget_le (L : ℕ) : degreeBudget L ≤ 32
```

`ProvenHashes.ChainHash128.idealKey_envelope_arithmetic`

```lean
theorem idealKey_envelope_arithmetic (L : ℕ) (hL : 0 < L) : idealKeyNumerator L ≤ 2*L
```

`ProvenHashes.ChainHash128.envelope_arithmetic`

```lean
theorem envelope_arithmetic (L : ℕ) (hL : 0 < L) : numerator L ≤ 2*L
```

`ProvenHashes.ChainHash128.coarse_envelope_arithmetic`

```lean
theorem coarse_envelope_arithmetic (L : ℕ) (hL : 0 < L) : coarseNumerator L ≤ 33*L
```

`ProvenHashes.ChainHash128.epsilon_le_coarse`

```lean
theorem epsilon_le_coarse (L : ℕ) : epsilon L ≤ coarseEpsilon L
```

`ProvenHashes.ChainHash128.idealKey_score_ratio`

```lean
theorem idealKey_score_ratio (L : ℕ) (hL : 0 < L) :
    idealKeyEpsilon L ≤ (L : ℚ≥0)/2^127
```

`ProvenHashes.ChainHash128.score_ratio`

```lean
theorem score_ratio (L : ℕ) (hL : 0 < L) :
    epsilon L ≤ (L : ℚ≥0)/2^127
```

`ProvenHashes.ChainHash128.coarse_score_ratio`

```lean
theorem coarse_score_ratio (L : ℕ) (hL : 0 < L) :
    coarseEpsilon L ≤ 33*(L : ℚ≥0)/2^128
```

`ProvenHashes.ChainHash128.numerators_at_one`

```lean
theorem numerators_at_one : idealKeyNumerator 1 = 2 ∧ numerator 1 = 2 ∧ coarseNumerator 1 = 33
```

`ProvenHashes.ChainHash128.score_attained`

```lean
theorem score_attained : idealKeyEpsilon 1 = 1/2^127 ∧ epsilon 1 = 1/2^127 ∧
    coarseEpsilon 1 = 33/2^128
```

`ProvenHashes.ChainHash128.idealKeyEpsilon_pos`

```lean
theorem idealKeyEpsilon_pos (L : ℕ) : 0 < idealKeyEpsilon L
```

`ProvenHashes.ChainHash128.epsilon_pos`

```lean
theorem epsilon_pos (L : ℕ) : 0 < epsilon L
```

`ProvenHashes.ChainHash128.coarseEpsilon_pos`

```lean
theorem coarseEpsilon_pos (L : ℕ) : 0 < coarseEpsilon L
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

## [ChainHash128/PH.lean](ProvenHashes/ChainHash128/PH.lean)

`ProvenHashes.ChainHash128.eval_phPoly`

```lean
theorem eval_phPoly {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m : Slot → F) (s : F) : (phPoly a m).eval s = ph a m s
```

`ProvenHashes.ChainHash128.phPoly_difference`

```lean
theorem phPoly_difference {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m m' : Slot → F) (t : F) :
    phPoly a m - phPoly a m' - C t = differencePoly a m m' t
```

`ProvenHashes.ChainHash128.differencePoly_coeff`

```lean
theorem differencePoly_coeff {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m m' : Slot → F) (t : F) (j : Slot) (hj : j.1 ∈ a) :
    (differencePoly a m m' t).coeff (exponent (partner j)) = m j - m' j
```

`ProvenHashes.ChainHash128.differencePoly_nonzero_degree`

```lean
theorem differencePoly_nonzero_degree {F : Type*} [Field F]
    (a : Finset (Fin 16)) (m m' : Slot → F) (t : F) (D : ℕ)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j)
    (hD : ∀ j : Slot, j.1 ∈ a → m j ≠ m' j → exponent (partner j) ≤ D) :
    differencePoly a m m' t ≠ 0 ∧ (differencePoly a m m' t).natDegree ≤ D
```

`ProvenHashes.ChainHash128.polynomial_probability_le`

```lean
theorem polynomial_probability_le {F : Type*} [Field F] [Fintype F]
    (p : F[X]) (hp : p ≠ 0) (D : ℕ) (hd : p.natDegree ≤ D) :
    uniformProb (fun s : F => p.eval s = 0) ≤ (D : ℚ≥0) / Fintype.card F
```

`ProvenHashes.ChainHash128.ph_equal_groups_bound`

```lean
theorem ph_equal_groups_bound {F : Type*} [Field F] [Fintype F]
    (a : Finset (Fin 16)) (m m' : Slot → F) (t : F) (D : ℕ)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j)
    (hD : ∀ j : Slot, j.1 ∈ a → m j ≠ m' j → exponent (partner j) ≤ D) :
    uniformProb (fun s : F => ph a m s - ph a m' s = t) ≤
      (D : ℚ≥0) / Fintype.card F
```

`ProvenHashes.ChainHash128.reducedPH_difference`

```lean
theorem reducedPH_difference {K : Type*} [Field K]
    (a : Finset (Fin 16)) (m m' k : Slot → K) :
    reducedPH a m k - reducedPH a m' k =
      constantDiff a m m' 0 + ∑ j, reducedCoefficient a m m' j * k j
```

`ProvenHashes.ChainHash128.reducedPH_difference_uniform`

```lean
theorem reducedPH_difference_uniform {K : Type*} [Field K] [Fintype K]
    (a : Finset (Fin 16)) (m m' : Slot → K)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j) (z : K) :
    uniformProb (fun k : Slot → K => reducedPH a m k - reducedPH a m' k = z) =
      1 / Fintype.card K
```

## [ChainHash128/Scores.lean](ProvenHashes/ChainHash128/Scores.lean)

`ProvenHashes.ChainHash128.score_lower_bound`

```lean
theorem score_lower_bound (epsilon : ℕ → ℚ≥0) (L : ℕ)
    (hpos : 0 < epsilon L) (hbound : epsilon L ≤ (L : ℚ≥0)/2^127) :
    127 ≤ score epsilon L
```

`ProvenHashes.ChainHash128.score_lower_bound_coarse`

```lean
theorem score_lower_bound_coarse (epsilon : ℕ → ℚ≥0) (L : ℕ)
    (hpos : 0 < epsilon L) (hbound : epsilon L ≤ 33*(L : ℚ≥0)/2^128) :
    128 - Real.logb 2 33 ≤ score epsilon L
```

`ProvenHashes.ChainHash128.idealKey_score`

```lean
theorem idealKey_score (L : ℕ) (hL : 0 < L) : 127 ≤ score idealKeyEpsilon L
```

`ProvenHashes.ChainHash128.epsilon_score`

```lean
theorem epsilon_score (L : ℕ) (hL : 0 < L) : 127 ≤ score epsilon L
```

`ProvenHashes.ChainHash128.coarse_score`

```lean
theorem coarse_score (L : ℕ) (hL : 0 < L) : 128 - Real.logb 2 33 ≤ score coarseEpsilon L
```

`ProvenHashes.ChainHash128.scores_at_one`

```lean
theorem scores_at_one : score idealKeyEpsilon 1 = 127 ∧ score epsilon 1 = 127
```

`ProvenHashes.ChainHash128.coarse_score_at_one`

```lean
theorem coarse_score_at_one : score coarseEpsilon 1 = 128 - Real.logb 2 33
```

`ProvenHashes.ChainHash128.ideal_key_score_minimum`

```lean
theorem ideal_key_score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score idealKeyEpsilon L.val)) 127
```

`ProvenHashes.ChainHash128.score_minimum`

```lean
theorem score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score epsilon L.val)) 127
```

`ProvenHashes.ChainHash128.coarse_score_minimum`

```lean
theorem coarse_score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score coarseEpsilon L.val))
      (128 - Real.logb 2 33)
```

`ProvenHashes.ChainHash128.envelope_table`

```lean
theorem envelope_table :
    ([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20].map numerator) =
      [2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,10,10]
```

`ProvenHashes.ChainHash128.envelope_large_examples`

```lean
theorem envelope_large_examples :
    ([128, 131072].map (fun L => (idealKeyNumerator L, coarseNumerator L, numerator L))) =
      [(9, 40, 16), (2049, 2080, 2080)]
```

## [ChainHash128/Seeded.lean](ProvenHashes/ChainHash128/Seeded.lean)

`ProvenHashes.ChainHash128.halfPoly_comp`

```lean
theorem halfPoly_comp {K : Type*} [CommRing K] (a : Finset (Fin 16)) (m m' : Slot → K)
    (hpad : ∀ i, m (i,true)=0 ∧ m' (i,true)=0) :
    (halfPoly a m m').comp (X^2) = differencePoly a m m' 0
```

`ProvenHashes.ChainHash128.ph_frobenius_bound`

```lean
theorem ph_frobenius_bound {K : Type*} [Field K] [Fintype K] [CharP K 2]
    (a : Finset (Fin 16)) (m m' : Slot → K) (D : ℕ)
    (hpad : ∀ i, m (i,true)=0 ∧ m' (i,true)=0)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j)
    (hD : ∀ i, i ∈ a → m (i,false) ≠ m' (i,false) → i.val+1 ≤ D) :
    uniformProb (fun s : K => ph a m s = ph a m' s) ≤ (D : ℚ≥0)/Fintype.card K
```

`ProvenHashes.ChainHash128.partner_exponent_budget`

```lean
theorem partner_exponent_budget (L t : ℕ) (hL : 17 ≤ L) (j : Slot)
    (hj : 2 * wordIndex t j < L) : exponent (partner j) ≤ degreeBudget L
```

`ProvenHashes.ChainHash128.field_char_two`

```lean
theorem field_char_two : CharP F 2
```

`ProvenHashes.ChainHash128.seeded_coefficients_collision`

```lean
theorem seeded_coefficients_collision (L : ℕ) (hL : 0 < L) (m m' : Message)
    (hm : m.length ≤ 8*L) (hlen : m.length = m'.length) (hne : m ≠ m') :
    uniformProb (fun s : F => coefficientsAt m (blocks m.length) (powerKey s) =
      coefficientsAt m' (blocks m.length) (powerKey s)) ≤
      (degreeBudget L : ℚ≥0)/Fintype.card F
```

`ProvenHashes.ChainHash128.collision_equal_length`

```lean
theorem collision_equal_length (L : ℕ) (hL : 0 < L) (m m' : Message)
    (hm : m.length ≤ 8*L) (hlen : m.length = m'.length) (hne : m ≠ m') :
    uniformProb (fun k : Key => chainHash k m = chainHash k m') ≤ epsilon L
```

`ProvenHashes.ChainHash128.collision_bound_message`

```lean
theorem collision_bound_message (L : ℕ) (hL : 0 < L) (hcap : 8*L < 2^128)
    (m m' : Message) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Key => chainHash k m = chainHash k m') ≤ epsilon L
```

`ProvenHashes.ChainHash128.coarse_collision_bound_message`

```lean
theorem coarse_collision_bound_message (L : ℕ) (hL : 0 < L) (hcap : 8*L < 2^128)
    (m m' : Message) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Key => chainHash k m = chainHash k m') ≤
      coarseEpsilon L
```

`ProvenHashes.ChainHash128.partner_exponent_le`

```lean
theorem partner_exponent_le (j : Slot) : exponent (partner j) ≤ 32
```

`ProvenHashes.ChainHash128.seeded_coefficients_collision_coarse`

```lean
theorem seeded_coefficients_collision_coarse (m m' : Message)
    (hlen : m.length = m'.length) (hne : m ≠ m') :
    uniformProb (fun s : F => coefficientsAt m (blocks m.length) (powerKey s) =
      coefficientsAt m' (blocks m.length) (powerKey s)) ≤
      ((32 : ℕ) : ℚ≥0)/Fintype.card F
```

`ProvenHashes.ChainHash128.coarse_collision_bound_message_blocks`

```lean
theorem coarse_collision_bound_message_blocks (p : ℕ) (m m' : Message)
    (hm : m.length < 2^128) (hm' : m'.length < 2^128) (hne : m ≠ m')
    (hp : blocks m.length ≤ p) (hp' : blocks m'.length ≤ p) :
    uniformProb (fun k : Key => chainHash k m = chainHash k m') ≤
      min 1 (((p+32 : ℕ) : ℚ≥0)/2^128)
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

`ProvenHashes.ChainHash.field_card`

```lean
theorem field_card {F : Type*} [AddGroup F] [Fintype F] (repr : Word 64 ≃+ F) :
    Fintype.card F = 2 ^ 64
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

## [Finalizer.lean](ProvenHashes/Finalizer.lean)

`ProvenHashes.ChainHash.decode_quinticCoefficients`

```lean
theorem decode_quinticCoefficients {F : Type*} [CommRing F] (c : Fin 5 → F) :
    decodeQuinticCoefficients (quinticCoefficients c) = c
```

`ProvenHashes.ChainHash.quinticCoefficients_decode`

```lean
theorem quinticCoefficients_decode {F : Type*} [CommRing F] (e : Fin 5 → F) :
    quinticCoefficients (decodeQuinticCoefficients e) = e
```

`ProvenHashes.ChainHash.chain5_expansion`

```lean
theorem chain5_expansion {F : Type*} [CommRing F] (c : Fin 5 → F) (v : F) :
    chain5 c v = v ^ 5 + ∑ i : Fin 5, quinticCoefficients c i * v ^ (i : ℕ)
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

`ProvenHashes.ChainHash.finalStage_collision_bound`

```lean
theorem finalStage_collision_bound {F : Type*} [Field F] [Fintype F] {N : ℕ}
    (word : F ≃ ZMod N) (v v' : F) (hne : v ≠ v') :
    uniformProb (fun j : F × (Fin 5 → F) =>
      chain5 j.2 (integerTwist word j.1 v) = chain5 j.2 (integerTwist word j.1 v')) ≤
        1 / Fintype.card F
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
    (fun i => chain5 c (v i)) = quinticValues v (quinticCoefficients c)
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

`ProvenHashes.probability_le_one`

```lean
theorem probability_le_one {K : Type*} [Fintype K] [Nonempty K] (E : K → Prop) :
    uniformProb E ≤ 1
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

