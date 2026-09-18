import ProvenHashes.Composition

/-!
# The ChainHash byte-string encoding

This module formalises the map that ChainHash applies to a byte string before
any key is used: the cut into sub-blocks, the zero padding of the last partial
32-byte group, the strided pairing `π`, and the byte length XORed into both
halves of the last stream pair.

Indices are 0-based: sub-block `t` (`0 ≤ t < p`) is sub-block `t+1` of the
paper and covers the bytes `[t * 8 * Ws, (t+1) * 8 * Ws)` of the message.
`Ws` is the number of 64-bit words of a sub-block and `S` the number of
sub-blocks of a block, so a block is `S * 8 * Ws` bytes; the shipped
configurations are `(Ws, S) = (32, 1)` and `(Ws, S) = (64, 2)`.

A 64-bit word is kept as its eight little-endian bytes, `Fin 8 → Byte`, and is
mapped into the field by an arbitrary injective `enc`; for `GF(2^64)` this is
the identification of a 64-bit word with a polynomial of degree `< 64`, which
is a bijection.
-/

namespace ProvenHashes
namespace Encoding

/-- A byte. -/
abbrev Byte := Fin 256

/-! ## The encoding -/

/-- Byte `i` of the message, reading `0` beyond its end: the zero padding of
the last partial group (`word_at` of the reference implementation). -/
def byteAt (m : List Byte) (i : ℕ) : Byte := m.getD i 0

/-- The eight little-endian bytes of the 64-bit word at word index `i`. -/
def wordAt (m : List Byte) (i : ℕ) : Fin 8 → Byte := fun j => byteAt m (8 * i + (j : ℕ))

/-- `π`: the involution of word positions swapping `4j+1` with `4j+2`, i.e. the
strided pairing `(w_{4j}, w_{4j+2})`, `(w_{4j+1}, w_{4j+3})` of a 32-byte
group. -/
def swapMid (j : ℕ) : ℕ := if j % 4 = 1 then j + 1 else if j % 4 = 2 then j - 1 else j

/-- `r_t`: the number of message bytes inside sub-block `t`. -/
def tailLen (Ws ℓ t : ℕ) : ℕ := min (8 * Ws) (ℓ - t * (8 * Ws))

/-- `G_t = ⌈r_t / 32⌉`: the number of 32-byte groups of sub-block `t`. -/
def groupCount (Ws ℓ t : ℕ) : ℕ := (tailLen Ws ℓ t + 31) / 32

/-- `w_t = 2 G_t`: the pair count of sub-block `t`. -/
def pairCount (Ws ℓ t : ℕ) : ℕ := 2 * groupCount Ws ℓ t

/-- `2 w_t = 4 G_t`: the number of 64-bit words of sub-block `t`. -/
def wordCount (Ws ℓ t : ℕ) : ℕ := 4 * groupCount Ws ℓ t

/-- `n(m) = max {1, ⌈ℓ / B⌉}` with `B = S * 8 * Ws` bytes per block. -/
def blockCount (Ws S ℓ : ℕ) : ℕ := max 1 ((ℓ + S * (8 * Ws) - 1) / (S * (8 * Ws)))

/-- `p(m) = S n(m)`: the number of sub-blocks. -/
def subBlockCount (Ws S ℓ : ℕ) : ℕ := S * blockCount Ws S ℓ

/-- Sub-block `t` as a list of `4 G_t` words, in the strided order `π`, the
bytes past the end of the message reading as zero. -/
def subBlockOctets (Ws : ℕ) (m : List Byte) (t : ℕ) : List (Fin 8 → Byte) :=
  (List.range (wordCount Ws m.length t)).map fun j => wordAt m (t * Ws + swapMid j)

variable {F : Type*}

/-- Sub-block `t` read into the field. -/
def subBlock (enc : (Fin 8 → Byte) → F) (Ws : ℕ) (m : List Byte) (t : ℕ) : List F :=
  (subBlockOctets Ws m t).map enc

/-- All `p(m)` sub-blocks of the message. -/
def subBlocks (enc : (Fin 8 → Byte) → F) (Ws S : ℕ) (m : List Byte) : List (List F) :=
  (List.range (subBlockCount Ws S m.length)).map (subBlock enc Ws m)

/-! ## Arithmetic of the cut -/

lemma le_ceil_mul {B ℓ : ℕ} (hB : 0 < B) : ℓ ≤ (ℓ + B - 1) / B * B := by
  rcases Nat.eq_zero_or_pos ℓ with h | h
  · simp [h]
  have h1 : ℓ + B - 1 = ℓ - 1 + B := by omega
  have h2 : ℓ - 1 < B * ((ℓ - 1) / B + 1) := Nat.lt_mul_div_succ (ℓ - 1) hB
  have h3 : ℓ ≤ B * ((ℓ - 1) / B + 1) := by
    have h4 := Nat.succ_le_of_lt h2
    rwa [Nat.succ_eq_add_one, Nat.sub_add_cancel h] at h4
  rw [h1, Nat.add_div_right _ hB, Nat.mul_comm]
  exact h3

lemma blockCount_pos {Ws S ℓ : ℕ} : 0 < blockCount Ws S ℓ := by
  simp [blockCount]

lemma subBlockCount_pos {Ws S ℓ : ℕ} (hS : 0 < S) : 0 < subBlockCount Ws S ℓ :=
  Nat.mul_pos hS blockCount_pos

/-- Every byte of the message lies in one of the `p(m)` sub-blocks. -/
lemma le_subBlockCount_mul {Ws S ℓ : ℕ} (hWs : 0 < Ws) (hS : 0 < S) :
    ℓ ≤ subBlockCount Ws S ℓ * (8 * Ws) := by
  have hB : 0 < S * (8 * Ws) := Nat.mul_pos hS (by omega)
  have h1 : ℓ ≤ (ℓ + S * (8 * Ws) - 1) / (S * (8 * Ws)) * (S * (8 * Ws)) := le_ceil_mul hB
  have h2 : (ℓ + S * (8 * Ws) - 1) / (S * (8 * Ws)) ≤ blockCount Ws S ℓ := le_max_right _ _
  refine h1.trans ?_
  calc (ℓ + S * (8 * Ws) - 1) / (S * (8 * Ws)) * (S * (8 * Ws))
      ≤ blockCount Ws S ℓ * (S * (8 * Ws)) := Nat.mul_le_mul_right _ h2
    _ = subBlockCount Ws S ℓ * (8 * Ws) := by simp [subBlockCount]; ring

/-- A message of at most `n` blocks has at most `S n` sub-blocks. -/
lemma blockCount_le {Ws S ℓ n : ℕ} (hWs : 0 < Ws) (hS : 0 < S) (hn : 0 < n)
    (h : ℓ ≤ n * (S * (8 * Ws))) : blockCount Ws S ℓ ≤ n := by
  have hB : 0 < S * (8 * Ws) := Nat.mul_pos hS (by omega)
  have h2 : ℓ + S * (8 * Ws) - 1 ≤ S * (8 * Ws) * n + (S * (8 * Ws) - 1) := by
    have : ℓ ≤ S * (8 * Ws) * n := by rw [Nat.mul_comm]; exact h
    omega
  have h1 : (ℓ + S * (8 * Ws) - 1) / (S * (8 * Ws)) ≤ n := by
    calc (ℓ + S * (8 * Ws) - 1) / (S * (8 * Ws))
        ≤ (S * (8 * Ws) * n + (S * (8 * Ws) - 1)) / (S * (8 * Ws)) := Nat.div_le_div_right h2
      _ = n + (S * (8 * Ws) - 1) / (S * (8 * Ws)) := Nat.mul_add_div hB _ _
      _ = n := by
          rw [Nat.div_eq_of_lt (show S * (8 * Ws) - 1 < S * (8 * Ws) by omega)]
          omega
  exact max_le hn h1

lemma subBlockCount_le {Ws S ℓ n : ℕ} (hWs : 0 < Ws) (hS : 0 < S) (hn : 0 < n)
    (h : ℓ ≤ n * (S * (8 * Ws))) : subBlockCount Ws S ℓ ≤ S * n :=
  Nat.mul_le_mul_left _ (blockCount_le hWs hS hn h)

/-- The words of a sub-block fit in its key segment: `4 G_t ≤ Ws`, i.e.
`w_t ≤ Ws / 2` pairs. -/
lemma wordCount_le {Ws ℓ t : ℕ} (h4 : 4 ∣ Ws) : wordCount Ws ℓ t ≤ Ws := by
  obtain ⟨c, rfl⟩ := h4
  simp only [wordCount, groupCount, tailLen]
  omega

/-- The pair count never exceeds `Ws/2`: the key segment of a sub-block is
long enough (`4 G_t ≤ Ws` words). -/
theorem two_mul_pairCount_le {Ws ℓ t : ℕ} (h4 : 4 ∣ Ws) : 2 * pairCount Ws ℓ t ≤ Ws := by
  have h := wordCount_le (Ws := Ws) (ℓ := ℓ) (t := t) h4
  simp only [wordCount] at h
  simp only [pairCount]
  omega

lemma swapMid_involutive (j : ℕ) : swapMid (swapMid j) = j := by
  simp only [swapMid]
  split_ifs <;> omega

lemma swapMid_lt {j G : ℕ} (h : j < 4 * G) : swapMid j < 4 * G := by
  simp only [swapMid]
  split_ifs <;> omega

/-! ## Basic list facts -/

lemma getD_map_range {α : Type*} (f : ℕ → α) {p t : ℕ} (d : α) (ht : t < p) :
    ((List.range p).map f).getD t d = f t := by
  rw [List.getD_eq_getElem _ _ (by simpa using ht)]
  simp

lemma subBlock_eq_map (enc : (Fin 8 → Byte) → F) (Ws : ℕ) (m : List Byte) (t : ℕ) :
    subBlock enc Ws m t =
      (List.range (wordCount Ws m.length t)).map fun j => enc (wordAt m (t * Ws + swapMid j)) := by
  simp [subBlock, subBlockOctets, List.map_map, Function.comp]

@[simp] lemma subBlock_length (enc : (Fin 8 → Byte) → F) (Ws : ℕ) (m : List Byte) (t : ℕ) :
    (subBlock enc Ws m t).length = 2 * pairCount Ws m.length t := by
  simp [subBlock_eq_map, wordCount, pairCount]
  ring

@[simp] lemma subBlocks_length (enc : (Fin 8 → Byte) → F) (Ws S : ℕ) (m : List Byte) :
    (subBlocks enc Ws S m).length = subBlockCount Ws S m.length := by
  simp [subBlocks]

lemma subBlock_eq_nil_of_pairCount_zero (enc : (Fin 8 → Byte) → F) {Ws : ℕ} {m : List Byte}
    {t : ℕ} (h : pairCount Ws m.length t = 0) : subBlock enc Ws m t = [] := by
  have : wordCount Ws m.length t = 0 := by
    simp only [pairCount] at h
    simp only [wordCount]
    omega
  simp [subBlock_eq_map, this]

/-! ## Injectivity of the encoding -/

lemma subBlocks_eq_of_forall (enc : (Fin 8 → Byte) → F) {Ws S : ℕ} {m m' : List Byte}
    (hlen : m.length = m'.length)
    (h : ∀ t < subBlockCount Ws S m.length, subBlock enc Ws m t = subBlock enc Ws m' t) :
    subBlocks enc Ws S m = subBlocks enc Ws S m' := by
  simp only [subBlocks, hlen]
  refine List.map_congr_left ?_
  intro t ht
  exact h t (by rw [hlen]; simpa using ht)

lemma subBlock_eq_of_subBlocks_eq {enc : (Fin 8 → Byte) → F} {Ws S : ℕ} {m m' : List Byte}
    (hp : subBlockCount Ws S m.length = subBlockCount Ws S m'.length)
    (h : subBlocks enc Ws S m = subBlocks enc Ws S m')
    {t : ℕ} (ht : t < subBlockCount Ws S m.length) :
    subBlock enc Ws m t = subBlock enc Ws m' t := by
  have h1 := congrArg (fun l => l.getD t ([] : List F)) h
  simp only [subBlocks] at h1
  rwa [getD_map_range _ _ ht, getD_map_range _ _ (by rwa [← hp])] at h1

/-- The sub-block sequence and the byte length determine the message: the
paper's "the tuple `(m_1, …, m_p, ℓ)` determines `m`". -/
theorem eq_of_subBlocks_eq {enc : (Fin 8 → Byte) → F} (hinj : Function.Injective enc)
    {Ws S : ℕ} (hWs : 0 < Ws) (hS : 0 < S) {m m' : List Byte}
    (hlen : m.length = m'.length) (h : subBlocks enc Ws S m = subBlocks enc Ws S m') :
    m = m' := by
  have hBs : 0 < 8 * Ws := by omega
  -- every word of every sub-block agrees
  have hword : ∀ t j, t < subBlockCount Ws S m.length → j < wordCount Ws m.length t →
      wordAt m (t * Ws + swapMid j) = wordAt m' (t * Ws + swapMid j) := by
    intro t j ht hj
    have h1 := subBlock_eq_of_subBlocks_eq (by rw [hlen]) h ht
    rw [subBlock_eq_map, subBlock_eq_map] at h1
    have h2 : ((List.range (wordCount Ws m.length t)).map
          fun j => enc (wordAt m (t * Ws + swapMid j))).getD j (enc (wordAt m 0)) =
        ((List.range (wordCount Ws m'.length t)).map
          fun j => enc (wordAt m' (t * Ws + swapMid j))).getD j (enc (wordAt m 0)) := by
      rw [h1]
    rw [getD_map_range _ _ hj, getD_map_range _ _ (by rwa [← hlen])] at h2
    exact hinj h2
  -- hence every byte agrees
  refine List.ext_getElem hlen ?_
  intro i h1 h2
  have hb : byteAt m i = byteAt m' i := by
    obtain ⟨t, o, ho, hio⟩ : ∃ t o, o < 8 * Ws ∧ i = t * (8 * Ws) + o :=
      ⟨i / (8 * Ws), i % (8 * Ws), Nat.mod_lt _ hBs, by
        rw [Nat.mul_comm]; exact (Nat.div_add_mod i (8 * Ws)).symm⟩
    have ht : t < subBlockCount Ws S m.length := by
      by_contra hcon
      push_neg at hcon
      have hmul : subBlockCount Ws S m.length * (8 * Ws) ≤ t * (8 * Ws) :=
        Nat.mul_le_mul_right _ hcon
      have hti : t * (8 * Ws) ≤ i := by rw [hio]; exact Nat.le_add_right _ _
      have := le_subBlockCount_mul (S := S) (ℓ := m.length) hWs hS
      omega
    have hr : o < tailLen Ws m.length t := by
      simp only [tailLen]
      refine lt_min ho ?_
      omega
    have hj : o / 8 < wordCount Ws m.length t := by
      simp only [wordCount, groupCount]
      omega
    have hw := hword t (swapMid (o / 8)) ht (by
      simpa only [wordCount] using swapMid_lt (G := groupCount Ws m.length t) (by
        simpa only [wordCount] using hj))
    rw [swapMid_involutive] at hw
    have hbyte := congrFun hw ⟨o % 8, by omega⟩
    simp only [wordAt] at hbyte
    have hidx : 8 * (t * Ws + o / 8) + o % 8 = i := by
      have h8 := Nat.div_add_mod o 8
      calc 8 * (t * Ws + o / 8) + o % 8 = t * (8 * Ws) + (8 * (o / 8) + o % 8) := by ring
        _ = t * (8 * Ws) + o := by rw [h8]
        _ = i := hio.symm
    rwa [hidx] at hbyte
  rw [byteAt, byteAt, List.getD_eq_getElem _ _ h1, List.getD_eq_getElem _ _ h2] at hb
  exact hb

/-- The encoding `m ↦ (ℓ(m), sub-blocks of m)` is injective. -/
theorem encoding_injective {enc : (Fin 8 → Byte) → F} (hinj : Function.Injective enc)
    {Ws S : ℕ} (hWs : 0 < Ws) (hS : 0 < S) :
    Function.Injective (fun m : List Byte => (m.length, subBlocks enc Ws S m)) := by
  intro m m' h
  exact eq_of_subBlocks_eq hinj hWs hS (congrArg Prod.fst h) (congrArg Prod.snd h)

/-- Two distinct messages of the same length differ in a non-empty sub-block:
the hypothesis of the equal-length case of the stream lemma. -/
theorem exists_subBlock_ne {enc : (Fin 8 → Byte) → F} (hinj : Function.Injective enc)
    {Ws S : ℕ} (hWs : 0 < Ws) (hS : 0 < S) {m m' : List Byte}
    (hlen : m.length = m'.length) (hne : m ≠ m') :
    ∃ t < subBlockCount Ws S m.length,
      0 < pairCount Ws m.length t ∧ subBlock enc Ws m t ≠ subBlock enc Ws m' t := by
  by_contra hcon
  push_neg at hcon
  refine hne (eq_of_subBlocks_eq hinj hWs hS hlen (subBlocks_eq_of_forall enc hlen ?_))
  intro t ht
  rcases Nat.eq_zero_or_pos (pairCount Ws m.length t) with h0 | h0
  · rw [subBlock_eq_nil_of_pairCount_zero enc h0,
      subBlock_eq_nil_of_pairCount_zero enc (m := m') (by rwa [← hlen])]
  · exact hcon t ht h0

/-! ## The stream

Level 1′ of the paper: one pair per sub-block, the pair being the two halves of
the level-1 digest of that sub-block, and the byte length added into **both**
halves of the last pair.  The level-1 digest is an arbitrary key-indexed
`bh : ℕ → List F → F × F` here, taking the position `i(t) = t % S` of the
sub-block inside its block and the sub-block itself; CLNH is one instance.
-/

section Stream

variable {F : Type*} [Field F]

/-- Pair `t` of the stream `σ_κ(m)`. -/
def streamPair (enc : (Fin 8 → Byte) → F) (Ws S : ℕ) (bh : ℕ → List F → F × F)
    (len : ℕ → F) (m : List Byte) (t : ℕ) : F × F :=
  if t + 1 = subBlockCount Ws S m.length then
    bh (t % S) (subBlock enc Ws m t) + (len m.length, len m.length)
  else bh (t % S) (subBlock enc Ws m t)

/-- The stream `σ_κ(m) = ((a_1,b_1), …, (a_p,b_p))` that the recurrence consumes. -/
def stream (enc : (Fin 8 → Byte) → F) (Ws S : ℕ) (bh : ℕ → List F → F × F)
    (len : ℕ → F) (m : List Byte) : List (F × F) :=
  (List.range (subBlockCount Ws S m.length)).map (streamPair enc Ws S bh len m)

@[simp] lemma stream_length (enc : (Fin 8 → Byte) → F) (Ws S : ℕ) (bh : ℕ → List F → F × F)
    (len : ℕ → F) (m : List Byte) :
    (stream enc Ws S bh len m).length = subBlockCount Ws S m.length := by
  simp [stream]

/-- A message of at most `n` blocks has a stream of at most `S n` pairs: the
`hmax` hypothesis of the composition theorems. -/
lemma stream_length_le {enc : (Fin 8 → Byte) → F} {Ws S : ℕ} {bh : ℕ → List F → F × F}
    {len : ℕ → F} {m : List Byte} {n : ℕ} (hWs : 0 < Ws) (hS : 0 < S) (hn : 0 < n)
    (hm : m.length ≤ n * (S * (8 * Ws))) :
    (stream enc Ws S bh len m).length ≤ S * n := by
  simpa using subBlockCount_le hWs hS hn hm

/-- Equal block counts give streams of equal length, for every key: the `hlen`
hypothesis of the equal-length composition theorem. -/
lemma stream_length_eq {enc : (Fin 8 → Byte) → F} {Ws S : ℕ} {bh : ℕ → List F → F × F}
    {len : ℕ → F} {m m' : List Byte}
    (h : blockCount Ws S m.length = blockCount Ws S m'.length) :
    (stream enc Ws S bh len m).length = (stream enc Ws S bh len m').length := by
  simp [subBlockCount, h]

/-- Different block counts give streams of different lengths, for every key: the
`hlen` hypothesis of the unequal-length composition theorem. -/
lemma stream_length_ne {enc : (Fin 8 → Byte) → F} {Ws S : ℕ} {bh : ℕ → List F → F × F}
    {len : ℕ → F} {m m' : List Byte} (hS : 0 < S)
    (h : blockCount Ws S m.length ≠ blockCount Ws S m'.length) :
    (stream enc Ws S bh len m).length ≠ (stream enc Ws S bh len m').length := by
  simp only [stream_length, subBlockCount, ne_eq]
  exact fun hc => h (Nat.eq_of_mul_eq_mul_left hS hc)

lemma subBlockCount_eq_of_stream_eq {enc : (Fin 8 → Byte) → F} {Ws S : ℕ}
    {bh : ℕ → List F → F × F} {len : ℕ → F} {m m' : List Byte}
    (hs : stream enc Ws S bh len m = stream enc Ws S bh len m') :
    subBlockCount Ws S m.length = subBlockCount Ws S m'.length := by
  simpa using congrArg List.length hs

lemma streamPair_eq_of_stream_eq {enc : (Fin 8 → Byte) → F} {Ws S : ℕ}
    {bh : ℕ → List F → F × F} {len : ℕ → F} {m m' : List Byte}
    (hs : stream enc Ws S bh len m = stream enc Ws S bh len m') {t : ℕ}
    (ht : t < subBlockCount Ws S m.length) :
    streamPair enc Ws S bh len m t = streamPair enc Ws S bh len m' t := by
  have hp := subBlockCount_eq_of_stream_eq hs
  have h1 := congrArg (fun l : List (F × F) => l.getD t 0) hs
  simp only [stream] at h1
  rwa [getD_map_range _ _ ht, getD_map_range _ _ (by rwa [← hp])] at h1

/-- Equal lengths: a stream collision forces the level-1 digests of every
sub-block to agree, the length terms cancelling. -/
lemma blockHash_eq_of_stream_eq {enc : (Fin 8 → Byte) → F} {Ws S : ℕ}
    {bh : ℕ → List F → F × F} {len : ℕ → F} {m m' : List Byte}
    (hL : m.length = m'.length)
    (hs : stream enc Ws S bh len m = stream enc Ws S bh len m') {t : ℕ}
    (ht : t < subBlockCount Ws S m.length) :
    bh (t % S) (subBlock enc Ws m t) = bh (t % S) (subBlock enc Ws m' t) := by
  have h1 := streamPair_eq_of_stream_eq hs ht
  simp only [streamPair, hL] at h1
  split_ifs at h1 with hc
  · exact add_right_cancel h1
  · exact h1

/-- Unequal lengths: a stream collision forces the level-1 digests of the two
last sub-blocks to differ by the constant `C = (ℓ + ℓ')(1 + X^64)` of the stream
lemma, i.e. by the same nonzero value in both halves. -/
lemma last_blockHash_sub_of_stream_eq {enc : (Fin 8 → Byte) → F} {Ws S : ℕ}
    {bh : ℕ → List F → F × F} {len : ℕ → F} {m m' : List Byte} (hS : 0 < S)
    (hs : stream enc Ws S bh len m = stream enc Ws S bh len m') :
    bh ((subBlockCount Ws S m.length - 1) % S)
        (subBlock enc Ws m (subBlockCount Ws S m.length - 1)) -
      bh ((subBlockCount Ws S m.length - 1) % S)
        (subBlock enc Ws m' (subBlockCount Ws S m.length - 1)) =
      (len m'.length - len m.length, len m'.length - len m.length) := by
  have hp := subBlockCount_eq_of_stream_eq hs
  have hpos : 0 < subBlockCount Ws S m.length := subBlockCount_pos hS
  have ht : subBlockCount Ws S m.length - 1 < subBlockCount Ws S m.length := by omega
  have h1 := streamPair_eq_of_stream_eq hs ht
  simp only [streamPair] at h1
  rw [if_pos (by omega), if_pos (by omega)] at h1
  rw [show ((len m'.length - len m.length, len m'.length - len m.length) : F × F) =
      (len m'.length, len m'.length) - (len m.length, len m.length) from
      (Prod.mk_sub_mk _ _ _ _).symm]
  linear_combination h1

/-- Case (a) of the stream lemma: when the padded sub-blocks of two messages of
different byte lengths coincide, the length XOR separates the streams for
**every** key. -/
theorem stream_ne_of_subBlocks_eq {enc : (Fin 8 → Byte) → F} {Ws S : ℕ}
    {bh : ℕ → List F → F × F} {len : ℕ → F} {m m' : List Byte} (hS : 0 < S)
    (hsub : subBlocks enc Ws S m = subBlocks enc Ws S m')
    (hL : len m.length ≠ len m'.length) :
    stream enc Ws S bh len m ≠ stream enc Ws S bh len m' := by
  intro hs
  have hp : subBlockCount Ws S m.length = subBlockCount Ws S m'.length := by
    simpa using congrArg List.length hsub
  have hpos : 0 < subBlockCount Ws S m.length := subBlockCount_pos hS
  have ht : subBlockCount Ws S m.length - 1 < subBlockCount Ws S m.length := by omega
  have h1 := last_blockHash_sub_of_stream_eq (bh := bh) (len := len) hS hs
  have h2 : subBlock enc Ws m (subBlockCount Ws S m.length - 1) =
      subBlock enc Ws m' (subBlockCount Ws S m.length - 1) :=
    subBlock_eq_of_subBlocks_eq hp hsub ht
  rw [h2, sub_self] at h1
  exact hL (by
    have := congrArg Prod.fst h1
    simp only [Prod.fst_zero] at this
    exact sub_eq_zero.mp this.symm |>.symm)

end Stream

/-! ## Why the length is in the stream

Appending a zero byte to a message whose length is not a multiple of `32`
changes no sub-block at all: it only fills one byte of the zero padding of the
last group.  The sub-block sequence is therefore *not* injective on byte
strings, and the byte length carried by the last stream pair is what separates
the two messages — deterministically, for every key.
-/

section AppendZero

lemma byteAt_append_zero (m : List Byte) (i : ℕ) : byteAt (m ++ [0]) i = byteAt m i := by
  simp only [byteAt]
  rcases lt_trichotomy i m.length with h | h | h
  · rw [List.getD_eq_getElem _ _ (by simp; omega), List.getD_eq_getElem _ _ h,
      List.getElem_append_left h]
  · rw [List.getD_eq_getElem _ _ (by simp; omega), List.getD_eq_default _ _ (le_of_eq h.symm)]
    simp [h]
  · rw [List.getD_eq_default _ _ (by simp; omega), List.getD_eq_default _ _ (le_of_lt h)]

lemma wordAt_append_zero (m : List Byte) (i : ℕ) : wordAt (m ++ [0]) i = wordAt m i := by
  funext j
  simp [wordAt, byteAt_append_zero]

lemma groupCount_succ {Ws ℓ t : ℕ} (hd : 32 ∣ 8 * Ws) (h : ¬ (32 ∣ ℓ)) :
    groupCount Ws (ℓ + 1) t = groupCount Ws ℓ t := by
  have hx : 32 ∣ t * (8 * Ws) := Dvd.dvd.mul_left hd t
  simp only [groupCount, tailLen]
  omega

lemma blockCount_succ {Ws S ℓ : ℕ} (hWs : 0 < Ws) (hS : 0 < S) (hd : 32 ∣ 8 * Ws)
    (h : ¬ (32 ∣ ℓ)) : blockCount Ws S (ℓ + 1) = blockCount Ws S ℓ := by
  have hB : 0 < S * (8 * Ws) := Nat.mul_pos hS (by omega)
  have hdB : 32 ∣ S * (8 * Ws) := Dvd.dvd.mul_left hd S
  have hl : 0 < ℓ := by
    rcases Nat.eq_zero_or_pos ℓ with rfl | hp
    · simp at h
    · exact hp
  have hnB : ¬ (S * (8 * Ws) ∣ ℓ) := fun hc => h (dvd_trans hdB hc)
  have e1 : ℓ + 1 + S * (8 * Ws) - 1 = ℓ + S * (8 * Ws) := by omega
  have e2 : ℓ + S * (8 * Ws) - 1 = (ℓ - 1) + S * (8 * Ws) := by omega
  have e3 : ℓ / (S * (8 * Ws)) = (ℓ - 1) / (S * (8 * Ws)) := by
    conv_lhs => rw [show ℓ = (ℓ - 1) + 1 by omega]
    rw [Nat.succ_div, if_neg (by rw [show (ℓ - 1) + 1 = ℓ by omega]; exact hnB)]
    simp
  simp only [blockCount, e1, e2, Nat.add_div_right _ hB, e3]

variable {F : Type*}

lemma subBlock_append_zero {enc : (Fin 8 → Byte) → F} {Ws : ℕ} (hd : 32 ∣ 8 * Ws)
    {m : List Byte} (h : ¬ (32 ∣ m.length)) (t : ℕ) :
    subBlock enc Ws (m ++ [0]) t = subBlock enc Ws m t := by
  have hw : wordCount Ws (m ++ [0]).length t = wordCount Ws m.length t := by
    simp only [List.length_append, List.length_cons, List.length_nil, wordCount]
    rw [groupCount_succ hd h]
  simp only [subBlock_eq_map, hw, wordAt_append_zero]

/-- The padded sub-blocks of `m` and `m ‖ 0x00` coincide whenever `32 ∤ ℓ(m)`. -/
theorem subBlocks_append_zero {enc : (Fin 8 → Byte) → F} {Ws S : ℕ} (hWs : 0 < Ws) (hS : 0 < S)
    (hd : 32 ∣ 8 * Ws) {m : List Byte} (h : ¬ (32 ∣ m.length)) :
    subBlocks enc Ws S (m ++ [0]) = subBlocks enc Ws S m := by
  have hb : subBlockCount Ws S (m ++ [0]).length = subBlockCount Ws S m.length := by
    simp only [List.length_append, List.length_cons, List.length_nil, subBlockCount]
    rw [blockCount_succ hWs hS hd h]
  simp only [subBlocks, hb]
  exact List.map_congr_left fun t _ => subBlock_append_zero hd h t

/-- Case (a) of the stream lemma, concretely: with `32 ∤ ℓ(m)` the messages `m`
and `m ‖ 0x00` have the same sub-blocks, and only the length XOR separates their
streams — which it does, for every key. -/
theorem stream_ne_append_zero [Field F] {enc : (Fin 8 → Byte) → F} {Ws S : ℕ}
    {bh : ℕ → List F → F × F} {len : ℕ → F} (hWs : 0 < Ws) (hS : 0 < S) (hd : 32 ∣ 8 * Ws)
    {m : List Byte} (h : ¬ (32 ∣ m.length)) (hlen : len (m.length + 1) ≠ len m.length) :
    stream enc Ws S bh len (m ++ [0]) ≠ stream enc Ws S bh len m :=
  stream_ne_of_subBlocks_eq hS (subBlocks_append_zero hWs hS hd h) (by simpa using hlen)

end AppendZero

/-! ## The stream lemma, conditional on level-1 universality

The level-1 hypotheses below are exactly the two parts of the paper's CLNH
lemma, stated for an arbitrary key-indexed block hash; they are hypotheses
here, not proved.  Everything else — the encoding, the padding, the length
XOR — is discharged.
-/

section Probability

variable {F : Type*} [Field F] [Fintype F]

/-- Full-width XOR-universality of the level-1 block hash on sub-blocks of the
same pair count: part (i) of the paper's CLNH lemma.  The sub-blocks are the
ones a key segment of `Ws` words covers, i.e. of pair count at most `Ws / 2`. -/
def BlockHashUniversal {K : Type*} [Fintype K] (Ws : ℕ) (bh : K → ℕ → List F → F × F) : Prop :=
  ∀ (i : ℕ) (g g' : List F), g.length ≤ Ws → g'.length ≤ Ws → g.length = g'.length → g ≠ g' →
    ∀ C : F × F, uniformProb (fun κ => bh κ i g - bh κ i g' = C) ≤ 1 / Fintype.card F

/-- The same for sub-blocks of different pair counts and a nonzero constant:
part (ii) of the paper's CLNH lemma, which needs `C ≠ 0`. -/
def BlockHashUniversalLt {K : Type*} [Fintype K] (Ws : ℕ) (bh : K → ℕ → List F → F × F) : Prop :=
  ∀ (i : ℕ) (g g' : List F), g.length ≤ Ws → g'.length ≤ Ws → g.length < g'.length →
    ∀ C : F × F, C ≠ 0 → uniformProb (fun κ => bh κ i g - bh κ i g' = C) ≤ 1 / Fintype.card F

lemma uniformProb_le_of_not {K : Type*} [Fintype K] [Nonempty K] {E : K → Prop}
    (h : ∀ k, ¬ E k) (b : ℚ≥0) : uniformProb E ≤ b := by
  classical
  refine (uniformProb_mono (D := fun _ : K => False) (fun k hk => h k hk)).trans ?_
  rw [uniformProb_const]
  simp

/-- The stream lemma for byte strings: distinct messages give distinct streams
but with probability at most `1/|F|`, for every pair of messages, of equal or
unequal byte length and of equal or unequal block count. -/
theorem stream_collision_bound {K : Type*} [Fintype K] [Nonempty K]
    {enc : (Fin 8 → Byte) → F} (hinj : Function.Injective enc)
    {Ws S : ℕ} (hWs : 0 < Ws) (hS : 0 < S) (h4 : 4 ∣ Ws)
    {bh : K → ℕ → List F → F × F} {len : ℕ → F}
    (hu : BlockHashUniversal Ws bh) (hu' : BlockHashUniversalLt Ws bh)
    {m m' : List Byte} (hne : m ≠ m')
    (hlen : m.length ≠ m'.length → len m.length ≠ len m'.length) :
    uniformProb (fun κ => stream enc Ws S (bh κ) len m = stream enc Ws S (bh κ) len m')
      ≤ 1 / Fintype.card F := by
  classical
  have hfit : ∀ (m'' : List Byte) (t : ℕ), (subBlock enc Ws m'' t).length ≤ Ws := by
    intro m'' t
    rw [subBlock_length]
    exact two_mul_pairCount_le h4
  by_cases hp : subBlockCount Ws S m.length = subBlockCount Ws S m'.length
  · by_cases hL : m.length = m'.length
    · obtain ⟨t, ht, -, hsne⟩ := exists_subBlock_ne hinj hWs hS hL hne
      refine (uniformProb_mono (D := fun κ =>
        bh κ (t % S) (subBlock enc Ws m t) - bh κ (t % S) (subBlock enc Ws m' t) = 0) ?_).trans
        (hu (t % S) _ _ (hfit m t) (hfit m' t) (by simp [hL]) hsne 0)
      intro κ hκ
      exact sub_eq_zero_of_eq (blockHash_eq_of_stream_eq hL hκ ht)
    · set t := subBlockCount Ws S m.length - 1 with hdt
      set g := subBlock enc Ws m t with hdg
      set g' := subBlock enc Ws m' t with hdg'
      set C : F × F := (len m'.length - len m.length, len m'.length - len m.length) with hdC
      have hCne : C ≠ 0 := by
        intro hcon
        have h0 := congrArg Prod.fst hcon
        rw [hdC] at h0
        simp only [Prod.fst_zero] at h0
        exact hlen hL (sub_eq_zero.mp h0).symm
      refine (uniformProb_mono (D := fun κ => bh κ (t % S) g - bh κ (t % S) g' = C)
        (fun κ hκ => last_blockHash_sub_of_stream_eq hS hκ)).trans ?_
      rcases lt_trichotomy g.length g'.length with h1 | h1 | h1
      · exact hu' (t % S) g g' (hfit m t) (hfit m' t) h1 C hCne
      · by_cases hgg : g = g'
        · refine uniformProb_le_of_not (fun κ hκ => hCne ?_) _
          rw [← hκ, hgg, sub_self]
        · exact hu (t % S) g g' (hfit m t) (hfit m' t) h1 hgg C
      · refine (uniformProb_mono (D := fun κ => bh κ (t % S) g' - bh κ (t % S) g = -C)
          ?_).trans (hu' (t % S) g' g (hfit m' t) (hfit m t) h1 (-C) (neg_ne_zero.mpr hCne))
        intro κ hκ
        rw [← hκ]
        abel
  · refine uniformProb_le_of_not (fun κ hκ => hp ?_) _
    simpa using congrArg List.length hκ

/-- ChainHash's collision bound for byte strings, conditional on the two level-1
hypotheses and on the finalizer bound: `(S n + 2)/|F|` for messages of at most
`n` blocks.  The encoding obligations of the composition theorems — the stream
lengths and the stream collision probability — are discharged here. -/
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
      ((S * n + 2 : ℕ) : ℚ≥0) / Fintype.card F := by
  by_cases hb : blockCount Ws S m.length = blockCount Ws S m'.length
  · exact chainhash_equal_length_from_stages (F := F) (K := K) (J := J) (S * n)
      (fun κ => stream enc Ws S (bh κ) len m) (fun κ => stream enc Ws S (bh κ) len m') fin
      (fun _ => stream_length_eq hb)
      (fun _ => stream_length_le hWs hS hn hm)
      (stream_collision_bound hinj hWs hS h4 hu hu' hne hlen) hfin
  · refine chainhash_different_lengths_from_stages (F := F) (K := K) (J := J) (S * n)
      (fun κ => stream enc Ws S (bh κ) len m) (fun κ => stream enc Ws S (bh κ) len m') fin
      (fun _ => stream_length_ne hS hb) (fun _ => ?_) hfin
    simp only [stream_length]
    exact max_le (subBlockCount_le hWs hS hn hm) (subBlockCount_le hWs hS hn hm')

end Probability

/-! ## The word type, and the shipped configurations

The `enc` of every statement above is an arbitrary injection of 64-bit words
into the field; such an injection exists as soon as `|F| ≥ 2^64`, and for
`GF(2^64)` the standard little-endian reading is a bijection.  The remaining
statements check the definitions against the numbers quoted in the paper for
the `256`-byte configuration `(Ws, S) = (32, 1)` (`BLOCK_WORDS = 32`, `S = 1`,
`41 = 32 + 9` key words).
-/

section Concrete

/-- A 64-bit word is eight bytes. -/
theorem card_word : Fintype.card (Fin 8 → Byte) = 2 ^ 64 := by
  rw [Fintype.card_fun]
  norm_num

/-- Any field of at least `2^64` elements reads 64-bit words injectively. -/
theorem exists_injective_enc {F : Type*} [Fintype F] (h : 2 ^ 64 ≤ Fintype.card F) :
    ∃ enc : (Fin 8 → Byte) → F, Function.Injective enc := by
  obtain ⟨e⟩ := Function.Embedding.nonempty_of_card_le
    (α := (Fin 8 → Byte)) (β := F) (by rw [card_word]; exact h)
  exact ⟨e, e.injective⟩

/-- The four words of a 32-byte group are listed in the strided order
`ω₀, ω₂, ω₁, ω₃`, so that its two pairs are `(ω₀, ω₂)` and `(ω₁, ω₃)`. -/
theorem swapMid_group : swapMid 0 = 0 ∧ swapMid 1 = 2 ∧ swapMid 2 = 1 ∧ swapMid 3 = 3 := by
  decide

theorem subBlockOctets_getElem {Ws : ℕ} {m : List Byte} {t j : ℕ}
    (h : j < wordCount Ws m.length t) :
    (subBlockOctets Ws m t)[j]'(by simpa [subBlockOctets] using h) =
      wordAt m (t * Ws + swapMid j) := by
  simp [subBlockOctets]

/-- The first 32-byte group of the first sub-block, spelled out. -/
theorem subBlockOctets_first_group {Ws : ℕ} {m : List Byte} (h : 4 ≤ wordCount Ws m.length 0) :
    (subBlockOctets Ws m 0).take 4 = [wordAt m 0, wordAt m 2, wordAt m 1, wordAt m 3] := by
  have hlen : (subBlockOctets Ws m 0).length = wordCount Ws m.length 0 := by
    simp [subBlockOctets]
  refine List.ext_getElem (by simp [hlen]; omega) ?_
  intro i h1 h2
  have hi : i < 4 := by simpa using h2
  rw [List.getElem_take]
  simp only [subBlockOctets, List.getElem_map, List.getElem_range, Nat.zero_mul, Nat.zero_add]
  interval_cases i <;> simp [swapMid]

/-- `(Ws, S) = (32, 1)`: `n(m) = max {1, ⌈ℓ/256⌉}` sub-blocks of 256 bytes. -/
theorem subBlockCount_256 (ℓ : ℕ) : subBlockCount 32 1 ℓ = max 1 ((ℓ + 255) / 256) := by
  norm_num [subBlockCount, blockCount]

/-- The empty message is one block of `S` empty sub-blocks. -/
theorem subBlockCount_zero {Ws S : ℕ} (hWs : 0 < Ws) (hS : 0 < S) :
    subBlockCount Ws S 0 = S := by
  have hB : 0 < S * (8 * Ws) := Nat.mul_pos hS (by omega)
  simp only [subBlockCount, blockCount, Nat.zero_add,
    Nat.div_eq_of_lt (show S * (8 * Ws) - 1 < S * (8 * Ws) by omega)]
  simp

/-- An empty sub-block has no pairs, and no words. -/
@[simp] theorem pairCount_zero_length (Ws t : ℕ) : pairCount Ws 0 t = 0 := by
  simp [pairCount, groupCount, tailLen]

/-- A message of 1–16 bytes has pair count 2 (its second pair all padding). -/
theorem pairCount_le_sixteen {ℓ : ℕ} (h1 : 1 ≤ ℓ) (h2 : ℓ ≤ 16) : pairCount 32 ℓ 0 = 2 := by
  simp only [pairCount, groupCount, tailLen]
  omega

/-- A full 256-byte sub-block has 16 pairs, i.e. all `Ws = 32` key words. -/
theorem pairCount_full {ℓ t : ℕ} (h : (t + 1) * 256 ≤ ℓ) : pairCount 32 ℓ t = 16 := by
  simp only [pairCount, groupCount, tailLen]
  omega

end Concrete

end Encoding
end ProvenHashes
