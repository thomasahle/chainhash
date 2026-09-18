import ProvenHashes.ConcreteWords
import ProvenHashes.WordRepresentation
import ProvenHashes.Finalizer

noncomputable section
namespace ProvenHashes.ChainHash
open Polynomial

/-- `gfmul`: the 64-bit remainder of the unreduced binary-polynomial product. -/
def wordMul (a b : Word 64) : Word 64 := lowWord ((pack 64 a * pack 64 b) %ₘ modulus)

/-- Unsigned addition modulo 2^64, including carries. -/
def wordAdd (a b : Word 64) : Word 64 :=
  (wordIntegerEquiv 64).symm (wordIntegerEquiv 64 a + wordIntegerEquiv 64 b)

theorem fieldRepr_wordMul (a b : Word 64) :
    fieldRepr (wordMul a b) = fieldRepr a * fieldRepr b := by
  rw [wordMul, ← fieldRepr_mul, AddEquiv.apply_symm_apply]

def wordChain5 (c : Fin 5 → Word 64) (v : Word 64) : Word 64 :=
  let y := wordMul v v
  let z := wordMul (y + c 0) (v + y + c 1)
  wordMul (v + c 2) (z + c 3) + c 4

theorem wordChain5_matches (c : Fin 5 → Word 64) (v : Word 64) :
    fieldRepr (wordChain5 c v) = chain5 (fun i => fieldRepr (c i)) (fieldRepr v) := by
  simp only [wordChain5, chain5, map_add, fieldRepr_wordMul]

theorem lowWord_add (p q : BitsPolynomial) : lowWord (p + q) = lowWord p + lowWord q := by
  funext i; exact coeff_add p q i.val

theorem highWord_add (p q : BitsPolynomial) : highWord (p + q) = highWord p + highWord q := by
  funext i; exact coeff_add p q (i.val + 64)

theorem lengthMask_low (n : ℕ) : lowWord (lengthMask n) = lengthWord n := by
  funext i
  simp only [lowWord, lengthMask, mul_add, mul_one, coeff_add]
  rw [Polynomial.coeff_mul_X_pow']
  have hi : ¬ 64 ≤ i.val := by omega
  simp only [hi, ↓reduceIte, add_zero]
  exact Polynomial.ofFn_coeff_eq_val_of_lt (lengthWord n) i.isLt

theorem lengthMask_high (n : ℕ) : highWord (lengthMask n) = lengthWord n := by
  funext i
  simp only [highWord, lengthMask, mul_add, mul_one, coeff_add, Polynomial.coeff_mul_X_pow]
  have hz : (pack 64 (lengthWord n)).coeff (i.val + 64) = 0 :=
    Polynomial.ofFn_coeff_eq_zero_of_ge _ (by omega)
  rw [hz, zero_add]
  exact Polynomial.ofFn_coeff_eq_val_of_lt (lengthWord n) i.isLt

/-- Exactly the reference's CLNH, low/high split, and length XOR in both halves. -/
def wordDigest (m : Message) (k : BlockKey) (t : ℕ) : Word 64 × Word 64 :=
  let a := clnh (activePairs m t) (blockData m t) k
  let len := if t + 1 = blockCount m then lengthWord m.length else 0
  (lowWord a + len, highWord a + len)

theorem wordDigest_matches (m : Message) (k : BlockKey) (t : ℕ) :
    (lowWord (rawDigest m k t), highWord (rawDigest m k t)) = wordDigest m k t := by
  unfold rawDigest wordDigest
  rw [lowWord_add, highWord_add]
  split_ifs
  · rw [lengthMask_low, lengthMask_high]
  · have hl : lowWord (0 : BitsPolynomial) = 0 := by funext i; simp [lowWord]
    have hh : highWord (0 : BitsPolynomial) = 0 := by funext i; simp [highWord]
    rw [hl, hh]

def wordFold (u y : Word 64) (s : List (Word 64 × Word 64)) (p : Word 64) : Word 64 :=
  s.foldl (fun p ab => ab.1 + wordMul (ab.2 + y) (p + u)) p

theorem wordFold_matches (u y : Word 64) (s : List (Word 64 × Word 64)) (p : Word 64) :
    fieldRepr (wordFold u y s p) =
      (s.map fun ab => (fieldRepr ab.1, fieldRepr ab.2)).foldl
        (fun p ab => ab.1 + (ab.2 + fieldRepr y) * (p + fieldRepr u)) (fieldRepr p) := by
  induction s generalizing p with
  | nil => rfl
  | cons ab s ih =>
    simp only [wordFold, List.foldl_cons, List.map_cons] at ih ⊢
    rw [ih]
    simp only [map_add, fieldRepr_wordMul]

end ProvenHashes.ChainHash
