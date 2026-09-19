import ProvenHashes.ChainHashV3Evaluation
import ProvenHashes.ChainHashV3Seeded

noncomputable section
namespace ProvenHashes.ChainHash.V3
open Polynomial
open scoped BigOperators

abbrev RawState := Word 64 × Word 64

def rawPolynomial (u : RawState) : BitsPolynomial := pack 64 u.1 + pack 64 u.2 * X^64
def rawReduce (u : RawState) : F := (AdjoinRoot.mk modulus) (rawPolynomial u)
def splitRaw (p : BitsPolynomial) : RawState := (lowWord p, highWord p)
def alpha : F := (AdjoinRoot.mk modulus) (X^64)

theorem rawPolynomial_degree (u : RawState) : (rawPolynomial u).natDegree < 128 := by
  have ha := Polynomial.ofFn_natDegree_lt (by omega : 1 ≤ 64) u.1
  have hb := Polynomial.ofFn_natDegree_lt (by omega : 1 ≤ 64) u.2
  have hc : (pack 64 u.2 * X^64).natDegree ≤ (pack 64 u.2).natDegree + (X^64 : BitsPolynomial).natDegree := Polynomial.natDegree_mul_le
  have hd := Polynomial.natDegree_add_le (pack 64 u.1) (pack 64 u.2 * X^64)
  simp only [natDegree_X_pow] at hc
  change (pack 64 u.1).natDegree < 64 at ha
  change (pack 64 u.2).natDegree < 64 at hb
  unfold rawPolynomial
  omega
-- checkpoint: rawPolynomial_degree

theorem rawPolynomial_split (p : BitsPolynomial) (hp : p.natDegree < 128) :
    rawPolynomial (splitRaw p) = p := by
  ext i
  simp only [rawPolynomial, splitRaw, pack, coeff_add, coeff_mul_X_pow']
  by_cases hi : i < 64
  · rw [if_neg (by omega), add_zero, Polynomial.ofFn_coeff_eq_val_of_lt _ hi]
    rfl
  · rw [if_pos (by omega), Polynomial.ofFn_coeff_eq_zero_of_ge _ (by omega), zero_add]
    by_cases hi' : i < 128
    · rw [Polynomial.ofFn_coeff_eq_val_of_lt _ (by omega)]
      simp only [highWord, Nat.sub_add_cancel (by omega : 64 ≤ i)]
    · rw [Polynomial.ofFn_coeff_eq_zero_of_ge _ (by omega),
        Polynomial.coeff_eq_zero_of_natDegree_lt (by omega : p.natDegree < i)]
-- checkpoint: rawPolynomial_split

theorem alpha_eq_tail : alpha = (AdjoinRoot.mk modulus) (X^4+X^3+X+1) := by
  have h : alpha + (AdjoinRoot.mk modulus) (X^4+X^3+X+1) = 0 := by
    rw [alpha, ← map_add]
    convert (show (AdjoinRoot.mk modulus) modulus = 0 from AdjoinRoot.mk_self) using 1 <;> simp [modulus] <;> ring
  exact eq_of_sub_eq_zero (by simpa [sub_eq_add_neg, CharTwo.neg_eq] using h)
-- checkpoint: alpha_eq_tail

theorem tail_word_27 : (pack 64 (lengthWord 27)) = (X^4+X^3+X+1 : BitsPolynomial) := by
  unfold pack
  ext i
  by_cases hi : i < 64
  · rw [Polynomial.ofFn_coeff_eq_val_of_lt _ hi]
    interval_cases i <;> norm_num only [Polynomial.coeff_add, Polynomial.coeff_X_pow, Polynomial.coeff_X, Polynomial.coeff_one] <;> decide +revert
  · rw [Polynomial.ofFn_coeff_eq_zero_of_ge _ (by omega)]
    simp [Polynomial.coeff_X_pow, Polynomial.coeff_X, Polynomial.coeff_one, show i ≠ 4 by omega,
      show i ≠ 3 by omega, show i ≠ 1 by omega, show i ≠ 0 by omega] <;> omega
-- checkpoint: tail_word_27

theorem alpha_eq_27 : alpha = fieldRepr (lengthWord 27) := by
  rw [alpha_eq_tail, ← tail_word_27]
  rfl
-- checkpoint: alpha_eq_27

/-- Two 64-by-64 carry-less products, with the high companion reduced in GF64. -/
def lazyRawStep (y : Word 64) (u c : RawState) : BitsPolynomial :=
  pack 64 u.1 * pack 64 y +
    pack 64 u.2 * pack 64 (fieldRepr.symm (alpha * fieldRepr y)) + rawPolynomial c

def lazyStep (y : Word 64) (u c : RawState) : RawState := splitRaw (lazyRawStep y u c)

theorem lazyRawStep_degree (y : Word 64) (u c : RawState) :
    (lazyRawStep y u c).natDegree < 128 := by
  have hp (v w : Word 64) : (pack 64 v * pack 64 w).natDegree ≤ 126 := by
    have hv := Polynomial.ofFn_natDegree_lt (by omega : 1 ≤ 64) v
    have hw := Polynomial.ofFn_natDegree_lt (by omega : 1 ≤ 64) w
    have h : (pack 64 v * pack 64 w).natDegree ≤ (pack 64 v).natDegree + (pack 64 w).natDegree := Polynomial.natDegree_mul_le
    change (pack 64 v).natDegree < 64 at hv
    change (pack 64 w).natDegree < 64 at hw
    omega
  apply Nat.lt_succ_iff.mpr
  exact Polynomial.natDegree_add_le_of_degree_le
    ((Polynomial.natDegree_add_le_of_degree_le (hp u.1 y)
      (hp u.2 (fieldRepr.symm (alpha * fieldRepr y)))).trans (by omega))
    (Nat.le_of_lt_succ (rawPolynomial_degree c))
-- checkpoint: lazyRawStep_degree

theorem lazyStep_reduce (y : Word 64) (u c : RawState) :
    rawReduce (lazyStep y u c) = fieldRepr y * rawReduce u + rawReduce c := by
  unfold rawReduce lazyStep
  rw [rawPolynomial_split _ (lazyRawStep_degree y u c)]
  simp only [lazyRawStep, rawPolynomial, map_add, map_mul]
  change fieldRepr u.1 * fieldRepr y +
    fieldRepr u.2 * fieldRepr (fieldRepr.symm (alpha * fieldRepr y)) +
    (fieldRepr c.1 + fieldRepr c.2 * alpha) =
    fieldRepr y * (fieldRepr u.1 + fieldRepr u.2 * alpha) +
      (fieldRepr c.1 + fieldRepr c.2 * alpha)
  rw [AddEquiv.apply_symm_apply]
  ring
-- checkpoint: lazyStep_reduce

/-- Reverse chronological coefficients, exactly as in `serialHorner`. -/
def lazyHorner (ell : RawState) (y : Word 64) : List RawState → RawState
  | [] => ell
  | c :: cs => lazyStep y (lazyHorner ell y cs) c

theorem lazyHorner_eq_serial (ell : RawState) (y : Word 64) :
    (fun cs => rawReduce (lazyHorner ell y cs)) =
      (fun cs => serialHorner (rawReduce ell) (fieldRepr y) (cs.map rawReduce)) := by
  funext cs
  induction cs with
  | nil => rfl
  | cons c cs ih =>
    simp only [lazyHorner, lazyStep_reduce, List.map_cons, serialHorner, ih]
    ring
-- checkpoint: lazyHorner_eq_serial

theorem lazyHorner_eq_schedule (k : ℕ) (hk : 0 < k) (ell : RawState) (y : Word 64) :
    (fun cs => rawReduce (lazyHorner ell y cs)) =
      (fun cs => scheduledHorner k (rawReduce ell) (fieldRepr y) (cs.map rawReduce)) := by
  rw [scheduledHorner_eq_serial k hk]
  exact lazyHorner_eq_serial ell y
-- checkpoint: lazyHorner_eq_schedule

theorem reduce_clnh (a : Finset (Fin 16)) (m k : Slot → Word 64) :
    (AdjoinRoot.mk modulus) (clnh a m k) =
      reducedPH a (fun j => fieldRepr (m j)) (fun j => fieldRepr (k j)) := by
  simp only [clnh, map_sum, map_mul, map_add]
  rfl
-- checkpoint: reduce_clnh

def rawBlock (m : Message) (k : Slot → F) (t : ℕ) : RawState :=
  splitRaw (clnh (active m t) (fun j => wordAt m (wordIndex t j)) (fun j => fieldRepr.symm (k j)))

theorem rawBlock_matches (m : Message) (k : Slot → F) (t : ℕ) :
    rawReduce (rawBlock m k t) = reducedPH (active m t) (data m t) k := by
  unfold rawReduce rawBlock
  rw [rawPolynomial_split _ (lt_of_le_of_lt (clnh_natDegree_le (active m t) (fun j => wordAt m (wordIndex t j))
    (fun j => fieldRepr.symm (k j))) (by omega)), reduce_clnh]
  simp only [AddEquiv.apply_symm_apply]
  rfl
-- checkpoint: rawBlock_matches

def rawCoefficients (m : Message) (k : Slot → F) : List RawState :=
  List.ofFn (fun i : Fin (blocks m.length) => rawBlock m k (blocks m.length-1-i.val))

theorem rawCoefficients_matches (m : Message) (k : Slot → F) :
    (rawCoefficients m k).map rawReduce = List.ofFn (coefficients m k) := by
  simp only [rawCoefficients, List.map_ofFn, coefficients, coefficientsAt, Function.comp_def,
    rawBlock_matches]
  rfl
-- checkpoint: rawCoefficients_matches

theorem rawLength_matches (n : ℕ) : rawReduce (lengthWord n,0) = lengthField n := by
  simp only [rawReduce, rawPolynomial, map_zero, zero_mul, add_zero]
  rfl
-- checkpoint: rawLength_matches

def lazyHash (k : IdealKey) (m : Message) : F :=
  chain5 k.2.2 (integerTwist fieldIntegerEquiv k.2.1
    (rawReduce (lazyHorner (lengthWord m.length,0) (fieldRepr.symm k.1.2)
      (rawCoefficients m k.1.1))))

theorem lazyHash_eq_hash : lazyHash = hash := by
  funext k m
  unfold lazyHash hash
  rw [congrFun (lazyHorner_eq_serial (lengthWord m.length,0) (fieldRepr.symm k.1.2))
    (rawCoefficients m k.1.1)]
  rw [rawLength_matches, AddEquiv.apply_symm_apply, rawCoefficients_matches, ← hornerValue_eq_serial]
-- checkpoint: lazyHash_eq_hash

/-- Equality of complete hash functions: serial paper model, physical k-lane
exact-count schedule, and bounded 128-bit lazy state, for every positive k. -/
theorem complete_evaluation_independence (k : ℕ) (hk : 0 < k) :
    scheduledHash k = hash ∧ lazyHash = hash :=
  ⟨hash_evaluation_independence k hk, lazyHash_eq_hash⟩
-- checkpoint: complete_evaluation_independence

end ProvenHashes.ChainHash.V3
